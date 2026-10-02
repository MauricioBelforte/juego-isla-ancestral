# Modelo: glm-5.3-flash (iter. 1-3) · DeepSeek-V4.1-Flash (iter. 5)
# Plataforma: Kilo Code · WorkBuddy
# Fecha: 2026-09-01 · 2026-10-02
#
# M63: Cargas y Streaming — StreamManager (autoload "StreamManager")
# Núcleo V0/V1 (03-Diseno §1-§4, §8):
#  - Cola priorizada por pesos (§2: 7 tipos de operación con peso; barra =
#    Σ pesos completados / Σ pesos encolados; piso 2%, tope 98%).
#  - Procesamiento ASÍNCRONO por frame con presupuesto de tiempo (§8: sin
#    load() síncrono en gameplay, delta < 50 ms).
#  - LRU de chunks (§4): MAX_CHUNKS, marcar envejecido → liberar en 2 frames,
#    descarga primero lejanos, pool de meshes reutilizado (M61).
#  - Señales: chunk_listo/banco_listo/shader_listo/progreso_cambiado (§1).
#  - Persistencia ISaveProvider M59: sección "stream" (estadísticas LRU).
# iter. 5 (Log 1192, DeepSeek-V4.1-Flash):
#  - HANDSHAKE CON M62 (§5.3) — lado 63: el 63 DECLARA qué recursos está
#    cargando/usando (`avisar_carga_iniciada/terminada`) y el 62 no los
#    descarga. Registro de rutas en vuelo (anti doble carga) + registro de
#    chunks como candidatos de descarga en M62. DESACOPLADO: si M62 no está
#    presente (tests sueltos, orden de autoloads), todo es no-op.
#  - PRECALENTAMIENTO (§7): `precalentar_mundo()` + `operaciones_restantes()`.
#  - STREAMING POR REGIÓN (§5): coronas LOD del océano, pisos del subterráneo,
#    StreamableBox por isla (matemática pura, testeable headless).
# ⚠️ Sin class_name: es autoload (pitfall GUIA-GODOT/09-godot4-migracion.md §9.17/§9.41).
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
## RF Pausa (iter. 2, Log 603): pausa del procesamiento de la cola
## (mundo congelado/menús/pantallas modales no deben consumir presupuesto)
var _cargas_pausadas: bool = false

## ── iter. 5: handshake con M62 (§5.3) ───────────────────
## Recursos que el 63 declaró "en carga" ante M62: instance_id -> Resource.
var _en_carga: Dictionary = {}
## Rutas con al menos una operación en vuelo: ruta -> nº de operaciones.
## Sirve de anti doble carga (L158): no encolar dos veces la misma ruta.
var _rutas_en_carga: Dictionary = {}
## Cuántas veces se avisó a M62 (observabilidad; 0 si M62 no está presente).
var _avisos_m62: int = 0


func _ready() -> void:
	_registrar_proveedor_guardado()


## ── Cola priorizada (§3) ────────────────────────────────

## Encola una operación de carga. prioridad: menor = antes (§3: anillos).
## El callable es el trabajo real (diferido — nunca síncrono en gameplay §8).
## RF2 (iter. 3, Log 622): si la operación es de RECURSO (textura_atlas/
## banco_audio/escena), se usa ResourceLoader.load_threaded_request REAL
## (thread del engine); el callable queda como callback de notificación.
func encolar(op_id: String, tipo: String, prioridad: int, callable: Callable, ruta_recurso: String = "") -> bool:
	if not PESOS.has(tipo):
		push_warning("[M63] tipo de operación desconocido: %s" % tipo)
		return false
	var peso := float(PESOS.get(tipo, 1.0))
	var usa_thread := ruta_recurso != "" and ResourceLoader.exists(ruta_recurso)
	if usa_thread:
		var err := ResourceLoader.load_threaded_request(ruta_recurso)
		if err != OK:
			push_warning("[M63] load_threaded falló para %s (%d); cae a callable" % [ruta_recurso, err])
			usa_thread = false
		else:
			# iter. 5: la ruta queda "en vuelo" hasta que la op se complete
			# (anti doble carga L158 + base del handshake con M62).
			_abrir_ruta(ruta_recurso)
	_cola.append({"op_id": op_id, "tipo": tipo, "peso": peso, "prioridad": prioridad, "callable": callable, "ruta": ruta_recurso, "threaded": usa_thread})
	_pesos_encolados += peso
	_ordenar_cola()
	return true


func _ordenar_cola() -> void:
	_cola.sort_custom(func(a, b): return int(a.prioridad) < int(b.prioridad))


func cola_size() -> int:
	return _cola.size()


## ── RF Pausa de cargas (iter. 2, Log 603) ───────────────

## Pausa el procesamiento de la cola (menús/pausa del juego/mundos congelados).
## La cola queda intacta: al reanudar continúa donde quedó.
func pausar_cargas() -> void:
	if _cargas_pausadas:
		return
	_cargas_pausadas = true
	print("[M63] Cargas PAUSADAS (cola intacta: %d operaciones)" % _cola.size())


## Reanuda el procesamiento de la cola.
func reanudar_cargas() -> void:
	if not _cargas_pausadas:
		return
	_cargas_pausadas = false
	print("[M63] Cargas REANUDADAS (cola: %d operaciones)" % _cola.size())


func cargas_pausadas() -> bool:
	return _cargas_pausadas


func pesos_encolados() -> float:
	return _pesos_encolados


## ── Handshake con M62 (diseño §5.3) — LADO 63 ───────────
## El 62 decide qué LIBERAR; el 63 decide qué CARGAR. El puente es este
## contrato: el 63 DECLARA qué recursos tiene en vuelo/uso y el 62 los veta
## en su política de descarga (`MemoryMonitor._puede_descargar`).
##
## DESACOPLAMIENTO: todo pasa por `_mem()`, que devuelve el autoload o null.
## Si M62 no existe (tests sueltos, orden de carga, build sin memoria), los
## avisos son no-op y el 63 sigue funcionando igual. Nunca se hace `has_method`
## sobre un nodo nulo sin comprobarlo antes.

## El autoload de M62, o null si no está presente.
func _mem() -> Node:
	return get_node_or_null("/root/MemoryMonitor")


## Declara ante M62 que el 63 empieza a cargar/usar `recurso`: el 62 NO lo
## descargará mientras siga declarado.
func avisar_carga_iniciada(recurso: Resource) -> void:
	if recurso == null:
		return
	_en_carga[recurso.get_instance_id()] = recurso
	var mem := _mem()
	if mem != null and mem.has_method("avisar_carga_iniciada"):
		mem.avisar_carga_iniciada(recurso)
		_avisos_m62 += 1


## Declara que el 63 terminó con `recurso`: el 62 puede volver a considerarlo.
func avisar_carga_terminada(recurso: Resource) -> void:
	if recurso == null:
		return
	_en_carga.erase(recurso.get_instance_id())
	var mem := _mem()
	if mem != null and mem.has_method("avisar_carga_terminada"):
		mem.avisar_carga_terminada(recurso)


func recursos_en_carga_63() -> int:
	return _en_carga.size()


func esta_en_carga_63(recurso: Resource) -> bool:
	return recurso != null and _en_carga.has(recurso.get_instance_id())


## Cuántos avisos efectivos se hicieron a M62 (0 = M62 ausente: no-op).
func avisos_m62() -> int:
	return _avisos_m62


## ── Anti doble carga (L158) ─────────────────────────────

## ¿Ya hay alguna operación en vuelo para esta ruta? El 63 evita encolar dos
## veces el mismo recurso (ResourceCache con un solo dueño).
func esta_cargando_ruta(ruta: String) -> bool:
	return int(_rutas_en_carga.get(ruta, 0)) > 0


func rutas_en_carga() -> int:
	return _rutas_en_carga.size()


func _abrir_ruta(ruta: String) -> void:
	if ruta == "":
		return
	_rutas_en_carga[ruta] = int(_rutas_en_carga.get(ruta, 0)) + 1


func _cerrar_ruta(ruta: String) -> void:
	if ruta == "":
		return
	var n := int(_rutas_en_carga.get(ruta, 0)) - 1
	if n <= 0:
		_rutas_en_carga.erase(ruta)
	else:
		_rutas_en_carga[ruta] = n


## ── Progreso real de la cola (§2) ───────────────────────
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
	# RF Pausa (iter. 2): con cargas pausadas el progreso NO avanza y la cola
	# queda intacta (se reanuda donde quedó — sin descartar operaciones).
	if _cargas_pausadas:
		return
	if _cola.is_empty():
		return
	var inicio := Time.get_ticks_usec()
	while not _cola.is_empty():
		var op: Dictionary = _cola.pop_front()
		var callable: Callable = op.get("callable", Callable())
		# RF2 (iter. 3): si la op es threaded, recolectar el resultado del
		# thread del engine; si aún no está listo, RE-ENCOLAR al final
		# (no bloquea el frame — §8) y continuar con la siguiente.
		if bool(op.get("threaded", false)):
			var ruta := String(op.get("ruta", ""))
			var estado := ResourceLoader.load_threaded_get_status(ruta)
			if estado == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				_cola.append(op)  # re-encolar sin reclamar peso
				_ordenar_cola()
				if (Time.get_ticks_usec() - inicio) / 1000.0 >= 2.0:
					break  # pequeño chequeo por frame
				continue
			if estado == ResourceLoader.THREAD_LOAD_LOADED:
				var rec: Resource = ResourceLoader.load_threaded_get(ruta)
				_cerrar_ruta(ruta)
				# Handshake (§5.3): mientras el 63 ENTREGA el recurso al
				# consumidor, el 62 no puede descargarlo. Es la ventana de
				# carga; para protección de vida larga el consumidor llama a
				# `avisar_carga_iniciada()` y la cierra cuando suelta.
				avisar_carga_iniciada(rec)
				if callable.is_valid():
					callable.call(rec)
				avisar_carga_terminada(rec)
			else:
				# THREAD_LOAD_FAILED / INVALID_RESOURCE: fallback al callable
				_cerrar_ruta(ruta)
				if callable.is_valid():
					callable.call()
				push_warning("[M63] thread load falló para %s" % ruta)
		else:
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

## Registra un chunk activo con su distancia al jugador.
## iter. 5 (handshake §5.3): al dar de alta un chunk NUEVO con recurso, el 63
## OFRECE ese recurso al 62 como candidato a descarga (con su distancia), que
## es la mitad "el 62 decide qué liberar" del contrato. Solo en el ALTA: si el
## chunk ya estaba registrado no se vuelve a ofrecer (si no, la cola del 62
## crecería con el mismo chunk re-registrado cada frame).
## OJO: `ejecutar_descarga` de M62 NO libera el recurso (solo decide y cuenta);
## el drop real lo sigue haciendo el LRU de este manager. Ofrecer es seguro.
func registrar_chunk(chunk_id: String, distancia: float, recurso: Resource = null) -> void:
	var es_nuevo := not _chunks.has(chunk_id)
	_chunks[chunk_id] = {"frames_envejecido": 0, "distancia": distancia, "recurso": recurso}
	if es_nuevo and recurso != null:
		var mem := _mem()
		if mem != null and mem.has_method("registrar_candidato_descarga"):
			mem.registrar_candidato_descarga(recurso, int(PESOS.get("chunk_lod0", 1.0)), distancia)


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
			# Handshake: el 63 deja de reclamar el recurso ANTES de soltar la
			# referencia, para que no quede un frame en que M62 lo vea libre y
			# M63 todavía lo esté usando.
			avisar_carga_terminada(rec)
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


## ── Precalentamiento del menú principal (§7) ────────────

## Rutas REALES de shaders del mundo/efectos (verificadas en el repo).
const SHADERS_MUNDO: Array[String] = [
	"res://shaders/agua_olas.gdshader",
	"res://shaders/oceano.gdshader",
]
## Banco de ambiente por bioma (M42); el bioma inicial es el 1.º del JSON.
const BANCO_BIOMA: String = "res://data/audio/ambient_biome_bank.json"
## §7.1: si hay partida, se precargan 3 anillos alrededor del punto de guardado.
const ANILLOS_SPAWN: int = 3
## §7.2: tras precalentar, "Continuar" debería encolar MENOS que esto.
const OPERACIONES_CONTINUAR_MAX: int = 30

var _precalentado: bool = false


## Precalienta el mundo desde el menú principal (§7.1): shaders del mundo y
## efectos, banco del bioma inicial, atlas base y —si hay partida— el seed del
## spawn (3 anillos). Prioridades §3: los chunks del seed van primero (0-1),
## después bancos/atlas (3) y shaders (4).
## Devuelve cuántas operaciones encoló. IDEMPOTENTE: una 2.ª llamada sin
## `forzar` no encola nada (el menú puede re-entrar por reintentos de UI).
## `opciones`: shaders/bancos/atlas (Array de rutas), hay_partida, anillos,
## forzar.
func precalentar_mundo(opciones: Dictionary = {}) -> int:
	if _precalentado and not bool(opciones.get("forzar", false)):
		return 0
	_precalentado = true
	var n := 0
	# §7.1 seed del spawn primero: es lo que el jugador ve al entrar.
	if bool(opciones.get("hay_partida", false)):
		var anillos := int(opciones.get("anillos", ANILLOS_SPAWN))
		for i in range(anillos):
			if encolar("spawn_anillo_%d" % i, "chunk_lod0", 1, Callable()):
				n += 1
	# §7.1 bancos del bioma inicial + atlas base (prioridad de región §3).
	for ruta in opciones.get("bancos", [BANCO_BIOMA]):
		n += _encolar_precarga(String(ruta), "banco_audio", 3)
	for ruta in opciones.get("atlas", []):
		n += _encolar_precarga(String(ruta), "textura_atlas", 3)
	# §7.1 shaders del mundo y efectos.
	for ruta in opciones.get("shaders", SHADERS_MUNDO):
		n += _encolar_precarga(String(ruta), "shader", 4)
	print("[M63] precalentamiento: %d operaciones encoladas (peso total %.0f)"
		% [n, _pesos_encolados])
	return n


## Encola una precarga evitando la DOBLE CARGA (L158): si la ruta ya está en
## vuelo, no se vuelve a encolar. Devuelve 1 si encoló, 0 si no.
func _encolar_precarga(ruta: String, tipo: String, prioridad: int) -> int:
	if ruta == "" or esta_cargando_ruta(ruta):
		return 0
	if not encolar("pre_%s" % ruta.get_file(), tipo, prioridad, Callable(), ruta):
		return 0
	return 1


## Operaciones que aún faltan para entrar al mundo (§7.2). Tras
## `precalentar_mundo()` el "Continuar" debería quedar por debajo de
## OPERACIONES_CONTINUAR_MAX.
func operaciones_restantes() -> int:
	return _cola.size()


func precalentado() -> bool:
	return _precalentado


## ── Streaming por región (§5) ───────────────────────────
## MATEMÁTICA PURA, testeable headless. Acá se decide QUÉ corona/piso/caja
## toca; instanciar geometría es de M08/M09/M27/M28 (dueños externos).

## Coronas de LOD del océano (§5): 0 = costa (detallada), 1 = medio, 2 = lejano.
const CORONAS_OCEANO: int = 3
## Pisos del subterráneo (§5): 0 = techo/cueva real, 1-2 = profundidad.
const PISOS_SUBTERRANEO: int = 3
## Radio del StreamableBox por isla (§5), en metros.
const RADIO_STREAMABLE_BOX: float = 10.0
## §5: el vuelo de aproximación (M28) precarga el destino al 60% de la ruta.
const FRACCION_PRECARGA_RUTA: float = 0.6


## Corona de océano para una distancia (m): más cerca = más detalle.
func corona_oceano(distancia: float) -> int:
	if distancia <= RADIO_STREAMABLE_BOX:
		return 0
	if distancia <= RADIO_STREAMABLE_BOX * 4.0:
		return 1
	return 2


## Piso del subterráneo por profundidad (m). 0 = superficie/techo.
func piso_subterraneo(profundidad: float) -> int:
	if profundidad <= 0.0:
		return 0
	if profundidad <= 32.0:
		return 1
	return 2


## ¿El jugador está dentro del StreamableBox de la isla? (§5: radio 10 m)
func dentro_streamable_box(pos_jugador: Vector3, centro_isla: Vector3) -> bool:
	return pos_jugador.distance_to(centro_isla) <= RADIO_STREAMABLE_BOX


## ¿Toca precargar el destino? (§5: al 60% de la ruta de vuelo M28)
func toca_precargar_destino(progreso_ruta: float) -> bool:
	return progreso_ruta >= FRACCION_PRECARGA_RUTA


## Encadenado al cambiar de piso (§5: "descarga del piso al subir, sin
## huecos"): el piso que se deja NO se libera hasta que el destino tenga su
## LOD 0 listo. Devuelve el piso liberable, o -1 si todavía no.
func piso_liberable(piso_actual: int, destino_lod0_listo: bool) -> int:
	if not destino_lod0_listo:
		return -1
	return maxi(piso_actual - 1, -1)


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
