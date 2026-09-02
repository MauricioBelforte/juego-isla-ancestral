# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M52 iter 4: VfxDirector — conecta señales de eventos del juego con el
# catálogo VFX (VfxFactory). `disparar(evento_id, pos)` busca el VFX en el
# catálogo y lo instancia en un container (por defecto el árbol de la escena
# real). El EventBus se registra si está disponible (señal "generico").

class_name VfxDirector
extends Node

const FACTORY = preload("res://scripts/particles/vfx_factory.gd")

var _container: Node = null
var _por_evento: Dictionary = {}
var _ultimo_disparo: String = ""

func _ready() -> void:
	var catalogo: Array = FACTORY.cargar_catalogo()
	for vfx in catalogo:
		_por_evento[String(vfx.get("evento", ""))] = vfx
	# registrar en bus de eventos si existe
	var event_bus := get_node_or_null("/root/EventBus")
	if event_bus and event_bus.has_signal("evento_generico"):
		event_bus.evento_generico.connect(_on_evento)
	print("[M52] VfxDirector listo (%d eventos del catálogo)" % _por_evento.size())

func set_container(node: Node) -> void:
	_container = node

## Dispara el VFX de un evento en la posición dada.
func disparar(evento_id: String, pos: Vector3) -> bool:
	var vfx: Dictionary = _por_evento.get(evento_id, {})
	if vfx.is_empty():
		return false
	_ultimo_disparo = evento_id
	if _container != null:
		FACTORY.crear(_container, vfx, pos)
	return true

func _on_evento(evento_id: String) -> void:
	disparar(evento_id, Vector3.ZERO)

func eventos_registrados() -> int:
	return _por_evento.size()

func ultimo_disparo() -> String:
	return _ultimo_disparo
