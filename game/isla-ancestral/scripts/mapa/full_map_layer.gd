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
	# Pausar el juego si M29 esta disponible
	var time_mgr := get_node_or_null("/root/TimeManager")
	if time_mgr and time_mgr.has_method("pause"):
		time_mgr.pause()

func close_map() -> void:
	if not _is_open:
		return
	_is_open = false
	visible = false
	closed.emit()
	var time_mgr := get_node_or_null("/root/TimeManager")
	if time_mgr and time_mgr.has_method("resume"):
		time_mgr.resume()

func _refresh_from_manager() -> void:
	var mm := get_node_or_null("/root/MapManager")
	if mm == null:
		return
	if _canvas:
		_canvas.set_map_data(mm)

func _on_bg_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			close_map()

func _unhandled_input(event: InputEvent) -> void:
	if not _is_open:
		return
	if event.is_action_pressed("ui_cancel"):
		close_map()
		get_viewport().set_input_as_handled()
