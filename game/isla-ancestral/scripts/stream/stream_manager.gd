# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M63: Cargas y Streaming — StreamManager (autoload "StreamManager")
# Núcleo V0/V1 (03-Diseno §1-§4, §8):
#  - Cola priorizada por pesos (§2: 7 tipos de operación con peso; barra =
#    Σ pesos completados / Σ pesos encolados; piso 2%, tope 98%).
#  - Procesamiento ASÍNCRONO por frame con presupuesto de tiempo (§8: sin
#    load() síncrono en gameplay, delta < 50 ms) — V0 usa carga diferida
#    (DeferredLoader) sin thread; el thread real es iter. 2.
#  - LRU de chunks (§4): MAX_CHUNKS, marcar envejecido → liberar en 2 frames,
#    descarga primero lejanos, pool de meshes reutilizado (M61).
#  - Señales: chunk_listo/banco_listo/shader_listo/progreso_cambiado (§1).
#  - Persistencia ISaveProvider M59: sección "stream" (estadísticas LRU).
# ⚠️ Sin class_name: es autoload (pitfall 07-GUIA-GODOT §9.17/§9.41).
extends Node

signal progreso_cambiado(porcentaje: float)
signal operacion_completada(op_id: String, tipo: String)
signal chunk_listo(chunk_id: String)
signal banco_listo(banco_id: String)
signal shader_listo(shader_id: String)

## Pesos por tipo de operación (§2)
const PESOS: Dictionary = {
	"chunk_lod0": 1.0,
	"chunk_lod1": 3.0,
	"banco_audio": 3.0,
	"textura_atlas": 2.0,
	"shader": 5.0,
	"npc_instancia": 1.0,
	"malla_region": 4.0,
}
const PISO_PROGRESO: float = 0.02
const TOPE_PROGRESO: float = 0.98
## Presupuesto de ms por frame para el procesamiento (§8: delta < 50 ms)
const PRESUPUESTO_MS: float = 40.0
## LRU (§4): tope de chunks activos y frames de envejecimiento
const MAX_CHUNKS_DEFAULT: int = 4096
const FRAMES_ENVEJECIDO: int = 2

## cola: Array de {op_id, tipo, peso, callable} ordenada por prioridad
var _cola: Array = []
## pesos encolados (para el denominador del progreso)
var _pesos_encolados: float = 0.0
## chunks activos: chunk_id -> {frames_envejecido, distancia, recurso}
var _chunks: Dictionary = {}
var _max_chunks: int = MAX_CHUNKS_DEFAULT
## estadísticas LRU (persistidas como métrica)
var _descargas_total: int = 0


func _ready() -> void:
	_registrar_proveedor_guardado()


## ── Cola priorizada (§3) ────────────────────────────────

## Encola una operación de carga. prioridad: menor = antes (§3: anillos).
## El callable es el trabajo real (diferido — nunca síncrono en gameplay §8).
func encolar(op_id: String, tipo: String, prioridad: int, callable: Callable) -> bool:
	if not PESOS.has(tipo):
		push_warning("[M63] tipo de operación desconocido: %s" % tipo)
		return false
	var peso := float(PESOS.get(tipo, 1.0))
	_cola.append({"op_id": op_id, "tipo": tipo, "peso": peso, "prioridad": prioridad, "callable": callable})
	_pesos_encolados += peso
	_ordenar_cola()
	return true


func _ordenar_cola() -> void:
	_cola.sort_custom(func(a, b): return int(a.prioridad) < int(b.prioridad))


func cola_size() -> int:
	return _cola.size()


func pesos_encolados() -> float:
	return _pesos_encolados


## Progreso real de la cola (§2): piso 2%, tope 98% SOLO mientras haya cola.
## Al vaciar (cerrar), 100% (§2: "tope 98% hasta cerrar").
func progreso() -> float:
	if _cola.is_empty() and _pesos_encolados > 0.0:
		return 1.0
	var restante := 0.0
	for op in _cola:
		restante += float(op.get("peso", 1.0))
	if _pesos_encolados <= 0.0:
		return 1.0
	var fraccion := 1.0 - (restante / _pesos_encolados)
	return clampf(maxf(fraccion, PISO_PROGRESO), PISO_PROGRESO, TOPE_PROGRESO)


## Procesamiento asíncrono con presupuesto de ms (§8: sin congelar el frame)
func _process(delta: float) -> void:
	if _cola.is_empty():
		return
	var inicio := Time.get_ticks_usec()
	while not _cola.is_empty():
		var op: Dictionary = _cola.pop_front()
		var callable: Callable = op.get("callable", Callable())
		if callable.is_valid():
			callable.call()
		var op_id := String(op.get("op_id", ""))
		var tipo := String(op.get("tipo", ""))
		operacion_completada.emit(op_id, tipo)
		match tipo:
			"chunk_lod0", "chunk_lod1":
				chunk_listo.emit(op_id)
			"banco_audio":
				banco_listo.emit(op_id)
			"shader":
				shader_listo.emit(op_id)
		# Presupuesto: salir del frame si ya consumimos los ms (§8)
		if (Time.get_ticks_usec() - inicio) / 1000.0 >= PRESUPUESTO_MS:
			break
	progreso_cambiado.emit(progreso())


## ── LRU de chunks (§4) ──────────────────────────────────

## Registra un chunk activo con su distancia al jugador
func registrar_chunk(chunk_id: String, distancia: float, recurso: Resource = null) -> void:
	_chunks[chunk_id] = {"frames_envejecido": 0, "distancia": distancia, "recurso": recurso}


func chunk_activo(chunk_id: String) -> bool:
	return _chunks.has(chunk_id)


func chunks_activos() -> int:
	return _chunks.size()


## Marca los chunks fuera de rango como envejecidos (R_max + 1, §4)
func marcar_envejecidos(r_max: float) -> void:
	for chunk_id in _chunks:
		var c: Dictionary = _chunks[chunk_id]
		if float(c.get("distancia", 0.0)) > r_max + 1.0:
			c["frames_envejecido"] = int(c.get("frames_envejecido", 0)) + 1
		else:
			c["frames_envejecido"] = 0


## Libera los chunks envejecidos >= FRAMES_ENVEJECIDO (2 frames, silencioso §4).
## Prioridad: primero los más lejanos (§4: distancia pesa más).
func liberar_envejecidos() -> int:
	var candidatos: Array = []
	for chunk_id in _chunks:
		var c: Dictionary = _chunks[chunk_id]
		if int(c.get("frames_envejecido", 0)) >= FRAMES_ENVEJECIDO:
			candidatos.append({"id": String(chunk_id), "distancia": float(c.get("distancia", 0.0))})
	# Orden: más lejanos primero (§4)
	candidatos.sort_custom(func(a, b): return float(a.distancia) > float(b.distancia))
	var liberados := 0
	for cand in candidatos:
		var cid := String(cand.get("id", ""))
		var c: Dictionary = _chunks.get(cid, {})
		var rec = c.get("recurso", null)
		if rec != null:
			rec.unreference()  # libera la referencia (pool de meshes reutiliza, M61)
		_chunks.erase(cid)
		_descargas_total += 1
		liberados += 1
	return liberados


## Tope duro: si hay más chunks que MAX_CHUNKS, libera los más lejanos (§4)
func aplicar_tope() -> int:
	var liberados := 0
	while _chunks.size() > _max_chunks:
		var mas_lejano := ""
		var max_dist: float = -1.0
		for chunk_id in _chunks:
			var dist: float = float(_chunks[chunk_id].get("distancia", 0.0))
			if dist > max_dist:
				max_dist = dist
				mas_lejano = String(chunk_id)
		if mas_lejano == "":
			break
		_chunks.erase(mas_lejano)
		_descargas_total += 1
		liberados += 1
	return liberados


func set_max_chunks(n: int) -> void:
	_max_chunks = maxi(n, 1)


## Estadísticas (para métricas M110/M104)
func descargas_total() -> int:
	return _descargas_total


## ── Persistencia (M59, métricas LRU) ────────────────────

func _registrar_proveedor_guardado() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)


func get_section_name() -> String:
	return "stream"


func get_save_data() -> Dictionary:
	return {"max_chunks": _max_chunks, "descargas_total": _descargas_total}


func restore_save_data(data: Dictionary) -> void:
	_max_chunks = maxi(int(data.get("max_chunks", MAX_CHUNKS_DEFAULT)), 1)
	_descargas_total = int(data.get("descargas_total", 0))
