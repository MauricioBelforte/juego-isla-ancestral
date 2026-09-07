# Modelo: agnes-2.5-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-05
#
# M54: Mapa — MinimapWidget conectado a MapManager con visión.
# Mejoras visuales: colores por bioma, marcadores con forma según tipo,
# región explorada/oculta, posición del jugador en tiempo real.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/ui/widgets/test_minimap_m54.gd

extends Control
class_name MinimapWidget

## ── Colores ──────────────────────────────────────────────
const COLOR_BG := Color(0.15, 0.18, 0.22, 0.85)
const COLOR_WATER := Color(0.2, 0.4, 0.7, 0.6)
const COLOR_PLAYER := Color(1.0, 0.85, 0.2)
const COLOR_MARKER_LUGAR := Color(0.2, 0.8, 0.4)
const COLOR_MARKER_TEMPLO := Color(0.9, 0.5, 0.2)
const COLOR_MARKER_TIENDA := Color(0.6, 0.4, 0.9)
const COLOR_MARKER_VIAJE := Color(0.3, 0.8, 0.9)
const COLOR_FOG := Color(0.1, 0.1, 0.1, 0.9)
const COLOR_EXPLORED := Color(0.3, 0.5, 0.3, 0.5)

## ── Configuración ────────────────────────────────────────
const MAP_SIZE := Vector2(140, 140)
const PLAYER_SIZE := 6.0
const MARKER_SIZE := 5.0
const WORLD_SIZE := 640.0  # Mundo 0..640 en X y Z
const ZOOM_MIN := 0.6
const ZOOM_MAX := 3.0
const ZOOM_STEP := 0.1

## ── Nodos ────────────────────────────────────────────────
var _bg_rect: ColorRect
var _fog_rect: ColorRect
var _player_dot: ColorRect
var _markers: Array[ColorRect] = []

## ── Estado ──────────────────────────────────────────────
var _player_pos: Vector2 = Vector2(0.5, 0.5)
var _explorados: Dictionary = {}
var _regiones_exploradas: Dictionary = {}
var _zoom: float = 1.0
var _pan_offset: Vector2 = Vector2.ZERO
var _is_dragging: bool = false
var _drag_start: Vector2 = Vector2.ZERO

## ── Ciclo de vida ───────────────────────────────────────

func _ready() -> void:
	_build_ui()
	_refresh_from_map_manager()
	_update_transform()
	# Conectar al MapManager si existe
	var mm := _get_map_manager()
	if mm != null:
		mm.exploration_changed.connect(_on_exploracion_cambiada)
		mm.pines_changed.connect(_on_pines_cambiados)
		print("[MinimapWidget] Conectado a MapManager")

## ── Input handling ───────────────────────────────────────

func _unhandled_input(event: InputEvent) -> void:
	# Zoom con rueda del ratón
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		_zoom = clampf(_zoom + ZOOM_STEP, ZOOM_MIN, ZOOM_MAX)
		_update_transform()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		_zoom = clampf(_zoom - ZOOM_STEP, ZOOM_MIN, ZOOM_MAX)
		_update_transform()
		get_viewport().set_input_as_handled()
	# Pan con arrastre
	elif event is InputEventMouseMotion and _is_dragging:
		_pan_offset += event.relative
		_update_transform()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		_is_dragging = event.pressed
		if event.pressed:
			_drag_start = event.position

## ── API pública ─────────────────────────────────────────

func refresh() -> void:
	_refresh_from_map_manager()
	_update_player_position()
	_update_markers()

func _refresh_from_map_manager() -> void:
	var mm := _get_map_manager()
	if mm == null:
		return
	# Actualizar exploración desde el manager
	for id in mm.config.get("marcadores", []):
		var marcador_id := String(id.get("id", ""))
		if marcador_id.is_empty():
			continue
		_explorados[marcador_id] = mm.esta_explorada(marcador_id)
	# Actualizar regiones
	for region in mm.config.get("islas", []):
		var region_str := String(region)
		_regiones_exploradas[region_str] = mm.region_explorada(region_str)

func _update_player_position() -> void:
	var player := _get_player()
	if player != null and player.has_method("get_global_position"):
		var wp: Vector3 = player.get_global_position()
		_player_pos = Vector2(
			clampf(wp.x / WORLD_SIZE, 0.0, 1.0),
			clampf(wp.z / WORLD_SIZE, 0.0, 1.0)
		)
	_update_transform()

func _update_markers() -> void:
	# Limpiar marcadores previos
	for m in _markers:
		if is_instance_valid(m):
			m.queue_free()
	_markers.clear()
	# Agregar marcadores del MapManager
	var mm := _get_map_manager()
	if mm == null:
		return
	for marker_data in mm.config.get("marcadores", []):
		var m_id := String(marker_data.get("id", ""))
		var m_tipo := String(marker_data.get("tipo", ""))
		var m_coords: Array = marker_data.get("coords", [0, 0, 0])
		if m_coords.size() < 2:
			continue
		# Solo mostrar si está explorado o es visible inicial
		var explored: bool = _explorados.get(m_id, false)
		if not explored:
			explored = bool(marker_data.get("visible_inicial", false))
		if not explored:
			continue
		var dot := ColorRect.new()
		dot.size = Vector2(MARKER_SIZE, MARKER_SIZE)
		dot.color = _color_por_tipo(m_tipo)
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		dot.set_meta("marker_id", m_id)
		# Posición normalizada
		var pos_2d := Vector2(float(m_coords[0]) / WORLD_SIZE, float(m_coords[2]) / WORLD_SIZE)
		dot.set_meta("base_pos", pos_2d)
		_update_marker_position(dot)
		add_child(dot)
		_markers.append(dot)

func _update_transform() -> void:
	# Aplicar zoom y pan al fondo
	if _bg_rect != null:
		_bg_rect.scale = Vector2(_zoom, _zoom)
		_bg_rect.position = _pan_offset
	# Actualizar posición del jugador y marcadores
	if _player_dot != null:
		var map_area := MAP_SIZE * _zoom
		_player_dot.position = Vector2(
			4.0 * _zoom + _player_pos.x * map_area.x - PLAYER_SIZE / 2.0 + _pan_offset.x,
			4.0 * _zoom + _player_pos.y * map_area.y - PLAYER_SIZE / 2.0 + _pan_offset.y
		)
	for m in _markers:
		if is_instance_valid(m):
			_update_marker_position(m)

func _update_marker_position(marker: ColorRect) -> void:
	if not marker.has_meta("base_pos"):
		return
	var base_pos: Vector2 = marker.get_meta("base_pos")
	var map_area := MAP_SIZE * _zoom
	marker.position = Vector2(
		4.0 * _zoom + base_pos.x * map_area.x - MARKER_SIZE / 2.0 + _pan_offset.x,
		4.0 * _zoom + base_pos.y * map_area.y - MARKER_SIZE / 2.0 + _pan_offset.y
	)

func _color_por_tipo(tipo: String) -> Color:
	match tipo:
		"templo": return COLOR_MARKER_TEMPLO
		"tienda": return COLOR_MARKER_TIENDA
		"viaje": return COLOR_MARKER_VIAJE
		_: return COLOR_MARKER_LUGAR

## ── Construcción UI ─────────────────────────────────────

func _build_ui() -> void:
	# Fondo del minimapa
	_bg_rect = ColorRect.new()
	_bg_rect.size = MAP_SIZE
	_bg_rect.color = COLOR_BG
	_bg_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bg_rect)
	
	# Rectángulo de región no explorada (fog)
	_fog_rect = ColorRect.new()
	_fog_rect.size = MAP_SIZE - Vector2(8, 8)
	_fog_rect.color = COLOR_FOG
	_fog_rect.position = Vector2(4, 4)
	_fog_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fog_rect)
	
	# Dot del jugador
	_player_dot = ColorRect.new()
	_player_dot.size = Vector2(PLAYER_SIZE, PLAYER_SIZE)
	_player_dot.color = COLOR_PLAYER
	_player_dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_player_dot)
	
	# Borde decorativo
	var border := ColorRect.new()
	border.size = MAP_SIZE
	border.color = Color(0.5, 0.4, 0.3, 0.3)
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(border)

## ── Callbacks ───────────────────────────────────────────

func _on_exploracion_cambiada(_region_ids: Array) -> void:
	_refresh_from_map_manager()
	_update_markers()

func _on_pines_cambiados(_pines: Array) -> void:
	# Los pines se podrían mostrar como marcadores adicionales
	pass

## ── Utilidades ──────────────────────────────────────────

func _get_map_manager() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("MapManager")

func _get_player() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("Player")
