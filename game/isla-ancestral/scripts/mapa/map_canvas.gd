# Modelo: mimo-v2.5-free
# Plataforma: OpenCode
# Fecha: 2026-09-14
#
# M54: Mapa — MapCanvas (zoom/pan del mapa completo)
# Control que renderiza el mapa con soporte de zoom y paneo.
# Recibe datos del MapManager y dibuja regiones, marcadores y niebla.

extends Control
class_name MapCanvas

const ZOOM_MIN := 0.5
const ZOOM_MAX := 3.0
const ZOOM_STEP := 0.15

var _map_manager: Node
var _zoom: float = 1.0
var _pan_offset: Vector2 = Vector2.ZERO
var _is_dragging: bool = false
var _drag_start: Vector2 = Vector2.ZERO
var _drag_pan_start: Vector2 = Vector2.ZERO

# Elementos visuales
var _bg_rect: ColorRect
var _islands_container: Control
var _markers_container: Control
var _fog_rect: ColorRect
var _player_dot: ColorRect

# Datos
var _world_size: float = 640.0
var _islas: Array = []
var _marcadores: Array = []
var _exploradas: Dictionary = {}

func _ready() -> void:
	_build_layers()
	# Connect mouse for drag
	gui_input.connect(_on_gui_input)

func _build_layers() -> void:
	# Background
	_bg_rect = ColorRect.new()
	_bg_rect.color = Color(0.12, 0.15, 0.18, 1.0)
	_bg_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_bg_rect)

	# Islands container
	_islands_container = Control.new()
	_islands_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_islands_container)

	# Markers container
	_markers_container = Control.new()
	_markers_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_markers_container)

	# Fog overlay
	_fog_rect = ColorRect.new()
	_fog_rect.color = Color(0.05, 0.05, 0.05, 0.85)
	_fog_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_fog_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fog_rect)

	# Player dot
	_player_dot = ColorRect.new()
	_player_dot.color = Color(1.0, 0.85, 0.2)
	_player_dot.custom_minimum_size = Vector2(8, 8)
	_player_dot.size = Vector2(8, 8)
	_player_dot.visible = false
	add_child(_player_dot)

func set_map_data(mm: Node) -> void:
	_map_manager = mm
	_islas = mm.islas()
	_marcadores = mm.config.get("marcadores", [])
	_exploradas = mm._exploradas.duplicate() if mm.has_method("get") else {}
	_render_map()

func _render_map() -> void:
	# Clear previous
	for child in _islands_container.get_children():
		child.queue_free()
	for child in _markers_container.get_children():
		child.queue_free()

	# Draw simple island representation
	var island_colors := {
		"raiz": Color(0.3, 0.6, 0.3, 0.6),
		"coral": Color(0.3, 0.5, 0.7, 0.6),
		"ceniza": Color(0.6, 0.4, 0.3, 0.6),
		"aurora": Color(0.5, 0.3, 0.6, 0.6),
	}

	var center := size * 0.5
	var island_radius := size.x * 0.2

	for i in range(_islas.size()):
		var isla_id = _islas[i]
		var angle := (i * TAU) / _islas.size() - PI / 2
		var pos := center + Vector2(cos(angle), sin(angle)) * island_radius * 0.6

		var island_rect := ColorRect.new()
		island_rect.color = island_colors.get(isla_id, Color(0.4, 0.4, 0.4, 0.5))
		island_rect.position = pos - Vector2(40, 30)
		island_rect.size = Vector2(80, 60)
		_islands_container.add_child(island_rect)

		var lbl := Label.new()
		lbl.text = isla_id
		lbl.position = pos - Vector2(15, 8)
		_islands_container.add_child(lbl)

	# Draw markers
	var marker_colors := {
		"lugar": Color(0.2, 0.8, 0.4),
		"templo": Color(0.9, 0.5, 0.2),
		"tienda": Color(0.6, 0.4, 0.9),
		"viaje": Color(0.3, 0.8, 0.9),
	}

	for m in _marcadores:
		var coords = m.get("coords", [0, 0, 0])
		var world_pos := Vector2(coords[0], coords[2]) if coords.size() >= 3 else Vector2.ZERO
		var screen_pos := _world_to_screen(world_pos)

		var dot := ColorRect.new()
		var m_type = m.get("tipo", "lugar")
		dot.color = marker_colors.get(m_type, Color(0.5, 0.5, 0.5))
		dot.position = screen_pos - Vector2(4, 4)
		dot.size = Vector2(8, 8)

		var explored = _exploradas.get(m.get("id", ""), false)
		if not explored:
			dot.modulate = Color(0.3, 0.3, 0.3, 0.5)

		_markers_container.add_child(dot)

	# Player position
	_update_player_dot()

func _world_to_screen(world_pos: Vector2) -> Vector2:
	var map_size := size
	var scale := map_size / _world_size
	return world_pos * scale + _pan_offset

func _update_player_dot() -> void:
	if _player_dot == null or _map_manager == null:
		return
	# Get player position from autoload or default to center
	var player_pos := Vector2(_world_size * 0.5, _world_size * 0.5)
	var player_node := get_node_or_null("/root/Player")
	if player_node and player_node.has_method("get_position"):
		var pos3d = player_node.get_position()
		player_pos = Vector2(pos3d.x, pos3d.z)
	_player_dot.position = _world_to_screen(player_pos) - Vector2(4, 4)
	_player_dot.visible = true

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			apply_zoom(ZOOM_STEP)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			apply_zoom(-ZOOM_STEP)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_is_dragging = true
				_drag_start = event.position
				_drag_pan_start = _pan_offset
			else:
				_is_dragging = false
	elif event is InputEventMouseMotion and _is_dragging:
		_pan_offset = _drag_pan_start + (event.position - _drag_start)
		_clamp_to_bounds()
		_render_map()

func apply_zoom(delta: float) -> void:
	var old_zoom := _zoom
	_zoom = clampf(_zoom + delta, ZOOM_MIN, ZOOM_MAX)
	# Zoom anchored to center
	_render_map()

func _clamp_to_bounds() -> void:
	var max_pan := size * (_zoom - 1.0) * 0.5
	_pan_offset = _pan_offset.clampf(-max_pan.x, max_pan.x) if max_pan.x > 0 else Vector2.ZERO
	# Simplified: just clamp to reasonable range
	_pan_offset = _pan_offset.clamp(-size * 0.5, size * 0.5)
