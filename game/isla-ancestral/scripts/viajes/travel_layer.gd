# M28: Viajes — TravelLayer (RF3 del 05 real, ítem [31] de la cola).
# Pantalla de travesía: overlay UI que muestra el progreso live del viaje
# (suscribe travel_started/progress/arrived/cancelled del TravelService).
# No toca la lógica del service (solo presentación) — el compositor visual
# sigue el tema D102 (panel noche + borde dorado + texto cream).
# G-5.3-Flash-Agente / Kilo Code — 2026-10-19.
class_name TravelLayer
extends UILayer

var _label_origen: Label
var _label_destino: Label
var _barra: ProgressBar
var _label_porcentaje: Label
var _btn_cancelar: Button


func _ready() -> void:
	layer_type = UILayerType.Type.MODAL_FULL
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_crear_ui()
	visible = false
	_conectar_service()


func _conectar_service() -> void:
	var ts := get_node_or_null("/root/TravelService")
	if ts == null:
		return
	ts.travel_started.connect(_on_started)
	ts.travel_progress.connect(_on_progress)
	ts.travel_arrived.connect(_on_arrived)
	ts.travel_cancelled.connect(_on_cancelled)


func _crear_ui() -> void:
	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(centro)

	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = ThemeUx.COLOR_BG_ARENA
	sb.border_color = ThemeUx.COLOR_HIGHLIGHT_GOLD
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(16)
	sb.set_content_margin_all(28)
	panel.add_theme_stylebox_override("panel", sb)
	centro.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	vbox.custom_minimum_size = Vector2(420, 0)
	panel.add_child(vbox)

	var titulo := Label.new()
	titulo.text = "Viaje"
	titulo.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_H1)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(titulo)

	_label_origen = Label.new()
	_label_origen.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_label_origen)

	_barra = ProgressBar.new()
	_barra.min_value = 0.0
	_barra.max_value = 1.0
	_barra.show_percentage = false
	_barra.custom_minimum_size = Vector2(420, 22)
	vbox.add_child(_barra)

	_label_porcentaje = Label.new()
	_label_porcentaje.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_label_porcentaje)

	_label_destino = Label.new()
	_label_destino.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_label_destino)

	_btn_cancelar = Button.new()
	_btn_cancelar.text = "Cancelar viaje"
	_btn_cancelar.pressed.connect(func():
		var ts := get_node_or_null("/root/TravelService")
		if ts != null and ts.has_method("cancel_travel"):
			ts.cancel_travel())
	vbox.add_child(_btn_cancelar)


func _on_started(route_id: StringName) -> void:
	visible = true
	_barra.value = 0.0
	_label_porcentaje.text = "0%"
	var ts := get_node_or_null("/root/TravelService")
	if ts != null and ts.has_method("get_current_state"):
		pass  # el service mantiene la ruta activa; las etiquetas se modernizan por el caller


func _on_progress(p: float) -> void:
	if not visible:
		return
	_barra.value = clampf(p, 0.0, 1.0)
	_label_porcentaje.text = "%d%%" % roundi(clampf(p, 0.0, 1.0) * 100.0)


func _on_arrived(island_id: String) -> void:
	visible = false
	_label_destino.text = str(island_id)


func _on_cancelled(_refund: int) -> void:
	visible = false
