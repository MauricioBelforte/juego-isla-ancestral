# Modelo: agnes-3-flash
# Plataforma: Kilo Code
# Fecha: 2026-10-09
# M110-UI: DebugVisualizer — capa visual de debug (colliders, chunks, navegación, hitboxes, estados IA).
# Consume las señales del backend debug_menu.gd (toggle_visual_cambiado, etc.).
# No modifica el backend; solo dibuja.
extends Node3D
class_name DebugVisualizer

signal estado_visual_cambiado(tipo: String, activo: bool)

const MAX_CHUNKS_RADIO := 5.0
const MAX_NAVIGATION_RADIO := 50.0
const MAX_AI_STATES_RADIO := 50.0

var _debug_menu: Node = null
var _colores := {
	"colliders": Color(1.0, 0.3, 0.3, 0.5),
	"chunks": Color(0.3, 1.0, 0.3, 0.3),
	"navigation": Color(0.3, 0.3, 1.0, 0.6),
	"hitboxes": Color(1.0, 1.0, 0.3, 0.5),
	"ai_states": Color(0.8, 0.3, 1.0, 0.5),
}
var _activo := {
	"colliders": false,
	"chunks": false,
	"navigation": false,
	"hitboxes": false,
	"ai_states": false,
}
var _jugador: Node3D = null

func _ready() -> void:
	_debug_menu = _buscar_debug_menu()
	if _debug_menu != null:
		if _debug_menu.has_signal("toggle_visual_cambiado"):
			_debug_menu.connect("toggle_visual_cambiado", _on_toggle_visual.bind())
		if _debug_menu.has_method("obtener_config_visual"):
			_sincronizar_desde_backend()
	for tipo in _activo:
		_activo[tipo] = false
	# Buscar jugador
	var grupo := get_tree().get_nodes_in_group("player")
	_jugador = grupo[0] if grupo.size() > 0 else null

func _buscar_debug_menu() -> Node:
	return get_node_or_null("/root/DebugMenu")

func _sincronizar_desde_backend() -> void:
	if _debug_menu.has_method("obtener_config_visual"):
		var cfg: Dictionary = _debug_menu.obtener_config_visual()
		for clave in cfg:
			if clave in _activo:
				_activo[clave] = bool(cfg[clave])

func _on_toggle_visual(tipo: String, activo: bool) -> void:
	if tipo in _activo:
		_activo[tipo] = activo
		estado_visual_cambiado.emit(tipo, activo)
		queue_redraw()

func _process(delta: float) -> void:
	if not _debug_menu != null:
		if _debug_menu.has_method("esta_visible") and not _debug_menu.esta_visible():
			return
	# Redraw solo si hay algo activo
	for tipo in _activo:
		if _activo[tipo]:
			queue_redraw()
			return

func _draw() -> void:
	if _jugador == null:
		return
	var pos: Vector3 = _jugador.global_position
	if _activo.get("colliders", false):
		_dibujar_colliders(pos)
	if _activo.get("chunks", false):
		_dibujar_chunks(pos)
	if _activo.get("navigation", false):
		_dibujar_navegacion(pos)
	if _activo.get("hitboxes", false):
		_dibujar_hitboxes(pos)
	if _activo.get("ai_states", false):
		_dibujar_estados_ia(pos)

func _dibujar_colliders(pos: Vector3) -> void:
	var col = _colores["colliders"]
	# Dibuja caja de referencia alrededor del jugador como proxy de collider
	draw_box(Vector3(-1, -0.5, -1), Vector3(1, 1.5, 1), col, true, 2.0)

func _dibujar_chunks(pos: Vector3) -> void:
	var col = _colores["chunks"]
	var radio := MAX_CHUNKS_RADIO
	var celda := int(radio)
	for x in range(-celda, celda + 1):
		for z in range(-celda, celda + 1):
			var origen := Vector3(pos.x + float(x) * 8.0, pos.y - 0.5, pos.z + float(z) * 8.0)
			var tam := Vector3(8.0, 1.0, 8.0)
			draw_rect(origen, tam, col, true, 1.0)

func _dibujar_navegacion(pos: Vector3) -> void:
	var col = _colores["navigation"]
	var radio := MAX_NAVIGATION_RADIO
	# Línea de radio de navegación
	var pasos := 32
	for i in range(pasos + 1):
		var ang := TAU * float(i) / float(pasos)
		var p := Vector3(pos.x + cos(ang) * radio, pos.y, pos.z + sin(ang) * radio)
		if i > 0:
			var prev := Vector3(pos.x + cos(TAU * float(i - 1) / float(pasos)) * radio, pos.y, pos.z + sin(TAU * float(i - 1) / float(pasos)) * radio)
			draw_line(prev, p, col, 2.0)

func _dibujar_hitboxes(pos: Vector3) -> void:
	var col = _colores["hitboxes"]
	draw_box(Vector3(-0.5, -0.25, -0.25), Vector3(0.5, 0.25, 0.25), col, true, 2.0)

func _dibujar_estados_ia(pos: Vector3) -> void:
	var col = _colores["ai_states"]
	var radio := MAX_AI_STATES_RADIO
	var pasos := 16
	for i in range(pasos + 1):
		var ang := TAU * float(i) / float(pasos)
		var p := Vector3(pos.x + cos(ang) * radio, pos.y, pos.z + sin(ang) * radio)
		if i > 0:
			var prev := Vector3(pos.x + cos(TAU * float(i - 1) / float(pasos)) * radio, pos.y, pos.z + sin(TAU * float(i - 1) / float(pasos)) * radio)
			draw_line(prev, p, col, 1.5)

## Configura el visualizador manualmente (para tests).
func configurar_manual(tipo: String, activo: bool) -> void:
	if tipo in _activo:
		_activo[tipo] = activo
		queue_redraw()
		estado_visual_cambiado.emit(tipo, activo)

## Devuelve el estado de todos los toggles (para tests).
func obtener_estado() -> Dictionary:
	return _activo.duplicate()
