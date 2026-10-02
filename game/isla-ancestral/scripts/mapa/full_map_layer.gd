# Modelo: mimo-v2.5-free
# Plataforma: OpenCode
# Fecha: 2026-09-14
#
# M54: Mapa — FullMapLayer (mapa completo modal)
# Capa UI que muestra el mapa completo con zoom, pan, marcadores y niebla.
# Se abre con la accion map_toggle (M/Escape) y se cierra con Esc.

extends Control
class_name FullMapLayer

signal closed

const ZOOM_MIN := 0.5
const ZOOM_MAX := 3.0
const ZOOM_STEP := 0.15
const MAP_BASE_SIZE := Vector2(512, 512)

var _canvas: MapCanvas
var _fog: FogRenderer
var _player_dot: ColorRect
var _markers_container: Control
var _legend_panel: VBoxContainer
var _cancel_btn: Button
var _type_filters: Dictionary = {}
var _is_open: bool = false

func _ready() -> void:
	visible = false
	_mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _build_ui() -> void:
	# Fondo oscuro semitransparente
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.7)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bg)
	bg.gui_input.connect(_on_bg_input)

	# Panel central del mapa
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE, Vector2(600, 500))
	panel.position -= Vector2(300, 250)
	add_child(panel)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_child(vbox)

	# Header
	var header := HBoxContainer.new()
	vbox.add_child(header)

	var title := Label.new()
	title.text = "Mapa de la Isla"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var close_btn := Button.new()
	close_btn.text = "X"
	close_btn.pressed.connect(close_map)
	header.add_child(close_btn)

	var center_btn := Button.new()
	center_btn.text = "Jugador"
	center_btn.tooltip_text = "Volver al jugador (map_center_player)"
	center_btn.pressed.connect(_center_on_player)
	header.add_child(center_btn)

	var cancel_btn := Button.new()
	cancel_btn.text = "Cancelar viaje"
	cancel_btn.visible = false
	cancel_btn.pressed.connect(_cancel_travel)
	header.add_child(cancel_btn)
	_cancel_btn = cancel_btn

	# Canvas del mapa
	_canvas = MapCanvas.new()
	_canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(_canvas)

	# Leyenda
	_legend_panel = VBoxContainer.new()
	_legend_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(_legend_panel)
	_build_legend()

func _build_legend() -> void:
	var lbl := Label.new()
	lbl.text = "Leyenda / Filtros:"
	_legend_panel.add_child(lbl)

	var types := [
		["lugar", "Lugar", Color(0.2, 0.8, 0.4)],
		["templo", "Templo", Color(0.9, 0.5, 0.2)],
		["tienda", "Tienda", Color(0.6, 0.4, 0.9)],
		["viaje", "Viaje", Color(0.3, 0.8, 0.9)],
	]
	_type_filters = {}
	for entry in types:
		var tipo_id: String = entry[0]
		var tipo_name: String = entry[1]
		var tipo_color: Color = entry[2]
		var hbox := HBoxContainer.new()
		_legend_panel.add_child(hbox)
		var checkbox := CheckBox.new()
		checkbox.text = tipo_name
		checkbox.button_pressed = true
		checkbox.pressed.connect(func(): _toggle_type_filter(tipo_id))
		_type_filters[tipo_id] = checkbox
		hbox.add_child(checkbox)
		var dot := ColorRect.new()
		dot.color = tipo_color
		dot.custom_minimum_size = Vector2(12, 12)
		hbox.add_child(dot)

func _toggle_type_filter(tipo_id: String) -> void:
	var visible: bool = _type_filters[tipo_id].button_pressed
	# Actualizar visibilidad de marcadores en el canvas
	if _canvas != null:
		_canvas.set_type_visible(tipo_id, visible)

func open_map() -> void:
	if _is_open:
		return
	# Convivencia con pila de capas: no abrir si hay capa modal activa
	if _hay_capa_modal_activa():
		return
	_is_open = true
	visible = true
	_refresh_from_manager()
	_connect_signals()
	# Foco inicial: centrar en el jugador (map_center_player)
	if _canvas != null:
		_canvas.center_on_player()
	# Pausar el tiempo del juego (M29/M30)
	var time_mgr := get_node_or_null("/root/TimeCalendar")
	if time_mgr and time_mgr.has_method("pausa"):
		time_mgr.pausa()

func _hay_capa_modal_activa() -> bool:
	# Verificar si DialogLayer, PauseLayer u otra capa UIRoot está visible
	var ui_root := get_tree().root.get_node_or_null("UIRoot")
	if ui_root:
		if ui_root.get("dialog_layer") and ui_root.get("dialog_layer").visible:
			return true
		if ui_root.get("pause_layer") and ui_root.get("pause_layer").visible:
			return true
		if ui_root.get("menus_layer") and ui_root.get("menus_layer").visible:
			return true
	return false

func close_map() -> void:
	if not _is_open:
		return
	_is_open = false
	visible = false
	_disconnect_signals()
	closed.emit()
	var time_mgr := get_node_or_null("/root/TimeCalendar")
	if time_mgr and time_mgr.has_method("resume"):
		time_mgr.resume()

func _connect_signals() -> void:
	var mm := get_node_or_null("/root/MapManager")
	if mm == null:
		return
	if not mm.exploration_changed.is_connected(_on_exploration_changed):
		mm.exploration_changed.connect(_on_exploration_changed)
	if not mm.markers_changed.is_connected(_on_markers_changed):
		mm.markers_changed.connect(_on_markers_changed)

func _disconnect_signals() -> void:
	var mm := get_node_or_null("/root/MapManager")
	if mm == null:
		return
	if mm.exploration_changed.is_connected(_on_exploration_changed):
		mm.exploration_changed.disconnect(_on_exploration_changed)
	if mm.markers_changed.is_connected(_on_markers_changed):
		mm.markers_changed.disconnect(_on_markers_changed)

func _on_exploration_changed(_region_ids: Array) -> void:
	if not _is_open:
		return
	_refresh_from_manager()

func _on_markers_changed(_markers: Array) -> void:
	if not _is_open:
		return
	_refresh_from_manager()

func _center_on_player() -> void:
	if _canvas != null:
		_canvas.center_on_player()

func _cancel_travel() -> void:
	var mm := get_node_or_null("/root/MapManager")
	if mm == null:
		return
	mm.cancelar_viaje()
	_refresh_from_manager()

func _refresh_from_manager() -> void:
	var mm := get_node_or_null("/root/MapManager")
	if mm == null:
		return
	if _canvas:
		if _canvas._islas.is_empty():
			_canvas.set_map_data(mm)
		else:
			_canvas.update_markers()

func _on_bg_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			close_map()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_crear_pin_en_cursor(event.position)

func _crear_pin_en_cursor(screen_pos: Vector2) -> void:
	if _canvas == null:
		return
	var world_coord: Vector2 = _canvas.screen_to_world(screen_pos)
	if world_coord == Vector2.ZERO:
		return
	var mm := get_node_or_null("/root/MapManager")
	if mm == null:
		return
	mm.agregar_pin(int(world_coord.x), 0, int(world_coord.y), "", "pin")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close_map()
		get_viewport().set_input_as_handled()
	elif event is InputEventKey:
		if event.pressed and not event.echo:
			if event.keycode == KEY_M:
				if _is_open:
					close_map()
				else:
					open_map()
				get_viewport().set_input_as_handled()
