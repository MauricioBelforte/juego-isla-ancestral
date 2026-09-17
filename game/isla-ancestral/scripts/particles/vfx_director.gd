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

class_name VfxDirector
extends Node

const FACTORY := preload("res://scripts/particles/vfx_factory.gd")
const POOL := preload("res://scripts/particles/vfx_pool.gd")

## Índice de `GameLogger.Category.WORLD`. No usar el identificador global del
## enum: un autoload NO resuelve como identificador en `--script` (trampa §9.52).
const LOG_CAT_WORLD := 3

var _container: Node = null
var _por_evento: Dictionary = {}
var _ultimo_disparo: String = ""
var _pool = null
var _vida: Dictionary = {}      # emisor -> segundos de vida restantes
var _disparos: int = 0
var _fallos: int = 0
var _skips: int = 0             # emisiones rechazadas por el pool (VFX-SKIP)

func _init(pool = null) -> void:
	_pool = pool if pool != null else POOL.new()
	# Log VFX-SKIP: el pool avisa y el director (que sí es un Node en el árbol)
	# lo escribe en GameLogger. Sin esto el descarte era invisible.
	if _pool != null and _pool.has_signal("emision_descartada"):
		_pool.emision_descartada.connect(_on_descarte)

func _ready() -> void:
	var catalogo: Array = FACTORY.cargar_catalogo()
	for vfx in catalogo:
		_por_evento[str(vfx.get("evento", ""))] = vfx
	# registrar en bus de eventos si existe
	var event_bus := get_node_or_null("/root/EventBus")
	if event_bus and event_bus.has_signal("evento_generico"):
		event_bus.evento_generico.connect(_on_evento)
	print("[M52] VfxDirector listo (%d eventos del catálogo)" % _por_evento.size())

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
