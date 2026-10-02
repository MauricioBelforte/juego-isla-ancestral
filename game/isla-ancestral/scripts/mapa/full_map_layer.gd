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
	lbl.text = "Leyenda:"
	_legend_panel.add_child(lbl)

	var types := [
		["Lugar", Color(0.2, 0.8, 0.4)],
		["Templo", Color(0.9, 0.5, 0.2)],
		["Tienda", Color(0.6, 0.4, 0.9)],
		["Viaje", Color(0.3, 0.8, 0.9)],
		["Jugador", Color(1.0, 0.85, 0.2)],
	]
	for entry in types:
		var hbox := HBoxContainer.new()
		_legend_panel.add_child(hbox)
		var dot := ColorRect.new()
		dot.color = entry[1]
		dot.custom_minimum_size = Vector2(12, 12)
		hbox.add_child(dot)
		var lbl2 := Label.new()
		lbl2.text = " " + entry[0]
		hbox.add_child(lbl2)

func open_map() -> void:
	if _is_open:
		return
	_is_open = true
	visible = true
	_refresh_from_manager()
	_connect_signals()
	# Pausar el juego si M29 esta disponible
	var time_mgr := get_node_or_null("/root/TimeManager")
	if time_mgr and time_mgr.has_method("pause"):
		time_mgr.pause()

func close_map() -> void:
	if not _is_open:
		return
	_is_open = false
	visible = false
	_disconnect_signals()
	closed.emit()
	var time_mgr := get_node_or_null("/root/TimeManager")
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
