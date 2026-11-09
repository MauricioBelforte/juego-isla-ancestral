# Modelo: deepseek-v4-flash-vision-exp (iter. 1-4) · DeepSeek-V4.1-Flash / WorkBuddy (iter. 5)
# Plataforma: Kilo Code (iter. 1-4) · WorkBuddy (iter. 5)
# Fecha: 2026-09-02 (iter. 1-4) · 2026-09-13 (iter. 5: pool + determinismo + límites)
#
# M52 iter 5: VfxDirector — conecta señales de eventos del juego con el catálogo
# VFX a través de un POOL de emisores reutilizables (VfxPool).
#
# Cambio clave de la iter. 5: antes el director llamaba a `VfxFactory.crear()`,
# que asignaba `GPUParticles3D.mesh` (propiedad ELIMINADA en Godot 4.3 → hoy
# `draw_pass_1`). El error abortaba la función en silencio, `crear()` devolvía
# null y **no se instanciaba ningún VFX** pese a los tests en verde (solo
# probaban funciones puras). Ahora todo pasa por el pool, que además:
#   T-027  presta y libera emisores (no allocar por disparo)
#   T-029  permite precalentar emisores antes de necesitarlos
#   T-093  fija una semilla determinista por (evento, emisión)
#   y aplica límites de emisores/partículas con política de reciclado.
#
# Además: el pool emite `emision_descartada` y el director lo escribe como log
# `VFX-SKIP` en GameLogger (RF3) — antes el descarte era invisible.
#
# ⚠️ HALLAZGO DE LA ITER. 6 (Log 1002) — el enganche a eventos reales NO funciona:
# `_ready()` intenta `EventBus.evento_generico`, una señal que **NO EXISTE** en
# ningún archivo del repo (`scripts/core/event_bus.gd` no la declara). El
# `has_signal()` devuelve false y el director queda mudo: **ningún VFX se
# disparaba por un evento real de juego**. El EventBus del proyecto es
# namespaced (`world.block_placed`, `quest.prereq_met`, `weather.clima_cambio`…),
# no plano. La ruta que SÍ funciona es `vfx_trigger.gd` (VfxTrigger), que deriva
# el mapa bus -> vfx del catálogo, resuelve los namespaces reales y REPORTA los
# que no puede resolver. Los 13 buses del catálogo están verificados contra
# `event_bus.gd` por `test_vfx_m52_iter6.gd` (bloque F).
# Queda PENDIENTE migrar este director a VfxTrigger (no se hizo acá para no
# cambiar el modelo de eventos en el mismo ciclo que el catálogo).

# ✅ CERRADO EN LA ITER. 7 (2026-11-08, DS-V4.1-Flash-Opencode — crítico de la
# evaluación Nemotron): el director YA usa VfxTrigger. `_ready()` construye el
# trigger desde el catálogo y conecta los 13 buses namespaced REALES contra
# `/root/EventBus`; los que no resuelven se reportan en `buses_faltantes()` y
# por `push_warning`. Además: `_process()` llama `actualizar(delta)` (antes el
# director liberaba emisores solo si alguien lo llamaba a mano) y `_exit_tree()`
# llama `finalizar()` (antes los nodos del pool quedaban huérfanos al cerrar).
# La posición del VFX sale de los argumentos de la señal (Vector3/Vector3i) o,
# si el evento no trae posición, de un proveedor externo / la cámara.

class_name VfxDirector
extends Node

const FACTORY := preload("res://scripts/particles/vfx_factory.gd")
const POOL := preload("res://scripts/particles/vfx_pool.gd")
const TRIGGER := preload("res://scripts/particles/vfx_trigger.gd")

## Índice de `GameLogger.Category.WORLD`. No usar el identificador global del
## enum: un autoload NO resuelve como identificador en `--script` (trampa §9.52).
const LOG_CAT_WORLD := 3

var _container: Node = null
var _por_evento: Dictionary = {}
var _por_id: Dictionary = {}     # id de catálogo (vfx_*) -> entrada
var _ultimo_disparo: String = ""
var _pool = null
var _vida: Dictionary = {}      # emisor -> segundos de vida restantes
var _disparos: int = 0
var _fallos: int = 0
var _skips: int = 0             # emisiones rechazadas por el pool (VFX-SKIP)
var _catalogo: Array = []
var _trigger = null
var _faltantes: Array = []
var _posicion_proveedor: Callable = Callable()
var _ultima_posicion: Vector3 = Vector3.ZERO

func _init(pool = null) -> void:
	_pool = pool if pool != null else POOL.new()
	# Log VFX-SKIP: el pool avisa y el director (que sí es un Node en el árbol)
	# lo escribe en GameLogger. Sin esto el descarte era invisible.
	if _pool != null and _pool.has_signal("emision_descartada"):
		_pool.emision_descartada.connect(_on_descarte)

func _ready() -> void:
	_catalogo = FACTORY.cargar_catalogo()
	for vfx in _catalogo:
		var ev := str(vfx.get("evento", ""))
		_por_evento[ev] = vfx
		_por_id[str(vfx.get("id", ""))] = vfx
	# Contenedor propio: si nadie llamó `set_container()`, los emisores del pool
	# cuelgan del director (antes quedaban SIN padre y no se liberaban solos).
	if _container == null:
		var c := Node3D.new()
		c.name = "VfxContainer"
		add_child(c)
		_container = c
	# M52 iter. 7: el enganche real es VfxTrigger (buses namespaced), NO la
	# señal plana `evento_generico` que no existe en el EventBus del proyecto.
	_trigger = TRIGGER.new()
	_trigger.construir(_catalogo)
	_faltantes.clear()
	var event_bus := get_node_or_null("/root/EventBus")
	if event_bus != null:
		var r: Dictionary = _trigger.conectar(event_bus, _on_bus)
		_faltantes = (r.get("faltantes", []) as Array).duplicate()
		for bus in _faltantes:
			push_warning("[M52] bus del catálogo sin señal real en EventBus: %s" % str(bus))
	else:
		push_warning("[M52] VfxDirector sin /root/EventBus: los VFX no responden a eventos")
	print("[M52] VfxDirector listo (%d eventos, %d buses conectados, %d faltantes)" % [
		_por_evento.size(),
		(_trigger.buses().size() - _faltantes.size()),
		_faltantes.size()])

func _process(delta: float) -> void:
	actualizar(delta)

func _exit_tree() -> void:
	finalizar()

## Conexión externa (tests / previews): permite inyectar de dónde tomar la
## posición cuando el evento no trae una (p. ej. la posición del jugador).
func set_posicion_proveedor(cb: Callable) -> void:
	_posicion_proveedor = cb

## Buses del catálogo que el EventBus real NO expone (hallazgo, no silencio).
func buses_faltantes() -> Array:
	return _faltantes.duplicate()

## Buses namespaced efectivamente conectados.
func buses_conectados() -> int:
	return _trigger.buses().size() - _faltantes.size() if _trigger != null else 0

func set_container(node: Node) -> void:
	_container = node

func get_pool():
	return _pool

## Precarga emisores en el pool para cada evento del catálogo (T-029).
## Devuelve cuántos se crearon (el pool respeta `max_emisores`).
func precalentar(n_por_evento: int = 1) -> int:
	var total := 0
	for evento in _por_evento:
		total += _pool.precalentar(_por_evento[evento], n_por_evento)
	return total

## Dispara el VFX de un evento en la posición dada. Devuelve true si se
## instanció/reutilizó un emisor; false si el evento no existe o el pool lo
## descartó por límites.
func disparar(evento_id: String, pos: Vector3) -> bool:
	var vfx: Dictionary = _por_evento.get(evento_id, {})
	if vfx.is_empty():
		_fallos += 1
		return false
	_ultimo_disparo = evento_id
	_ultima_posicion = pos
	var nodo = _pool.prestar(vfx, pos, _container)
	if nodo == null:
		_fallos += 1
		return false
	_disparos += 1
	_vida[nodo] = maxf(0.2, float(FACTORY.parametros(vfx)["emision"]))
	return true

## Avanza el tiempo y devuelve al pool los emisores ya agotados. Devuelve
## cuántos se liberaron. Sin esto el pool se llenaría de emisores "activos".
func actualizar(delta: float) -> int:
	var liberados := 0
	for nodo in _vida.keys():
		_vida[nodo] = float(_vida[nodo]) - delta
		if float(_vida[nodo]) <= 0.0:
			_pool.liberar(nodo)
			_vida.erase(nodo)
			liberados += 1
	return liberados

func _on_evento(evento_id: String) -> void:
	disparar(evento_id, Vector3.ZERO)

## Handler de un bus real del EventBus: el trigger traduce bus -> ids del
## catálogo y acá se dispara cada VFX en la posición del evento (si la trae).
func _on_bus(bus: String, contexto: Dictionary) -> void:
	if _trigger == null:
		return
	var ids: Array = _trigger.disparar(bus, contexto, _catalogo)
	if ids.is_empty():
		return
	var pos := _posicion_de(contexto)
	for vid in ids:
		var e: Dictionary = _por_id.get(str(vid), {})
		if e.is_empty():
			continue
		disparar(str(e.get("evento", "")), pos)

## Posición del VFX: primer Vector3/Vector3i de los argumentos de la señal; si
## el evento no trae posición, el proveedor externo o la cámara activa.
func _posicion_de(contexto: Dictionary) -> Vector3:
	var args: Variant = contexto.get("args", [])
	if typeof(args) == TYPE_ARRAY:
		for a in args:
			if a is Vector3:
				return a
			if a is Vector3i:
				return Vector3(a)
	return _posicion_defecto()

func _posicion_defecto() -> Vector3:
	if _posicion_proveedor.is_valid():
		var p: Variant = _posicion_proveedor.call()
		if p is Vector3:
			return p
		if p is Vector3i:
			return Vector3(p)
	if is_inside_tree():
		var vp := get_viewport()
		if vp != null:
			var cam := vp.get_camera_3d()
			if cam != null:
				return cam.global_position
	return Vector3.ZERO

## Handler del log VFX-SKIP (RF3). El nodo del logger se busca por ruta porque
## el autoload no es identificador global; si no existe (tests headless) solo
## se contabiliza.
func _on_descarte(id: String, motivo: String) -> void:
	_skips += 1
	var logger := get_node_or_null("/root/GameLogger")
	if logger != null and logger.has_method("warning"):
		logger.warning("VFX-SKIP %s: %s" % [id, motivo], LOG_CAT_WORLD)

func eventos_registrados() -> int:
	return _por_evento.size()

func ultimo_disparo() -> String:
	return _ultimo_disparo

func ultima_posicion() -> Vector3:
	return _ultima_posicion

func disparos() -> int:
	return _disparos

func fallos() -> int:
	return _fallos

## Emisiones rechazadas por el pool (log VFX-SKIP).
func skips() -> int:
	return _skips

func stats() -> Dictionary:
	var s: Dictionary = _pool.stats()
	s["disparos"] = _disparos
	s["fallos"] = _fallos
	s["skips"] = _skips
	s["eventos"] = _por_evento.size()
	return s

## Libera TODOS los emisores del pool (nodos incluidos). Llamar al cerrar o
## al cambiar de escena: un nodo sin padre no se libera solo.
func finalizar() -> void:
	_vida.clear()
	for gp in _pool.nodos():
		if gp is Node and not gp.is_queued_for_deletion():
			gp.queue_free()
	_pool.vaciar()
