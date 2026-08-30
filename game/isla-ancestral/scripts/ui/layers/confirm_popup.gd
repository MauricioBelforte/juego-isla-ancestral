# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M53: ConfirmPopup — popup genérico de confirmación (modal POPUP).
# No compite por el foco principal; superpuesto. Título, mensaje, OK/Cancelar.
# Localizado (M87); navegable por teclado/gamepad.

class_name ConfirmPopup
extends UILayer

var _title_label: Label
var _message_label: Label
var _ok_button: Button
var _cancel_button: Button
var _on_ok: Callable = Callable()
var _on_cancel: Callable = Callable()

func _ready() -> void:
	layer_type = UILayerType.Type.POPUP
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_crear_ui()
	visible = false

func _crear_ui() -> void:
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.96, 0.92, 0.86, 0.98)
	sb.border_color = Color(0.72, 0.55, 0.30)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(12)
	sb.set_content_margin_all(18)
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	vbox.custom_minimum_size = Vector2(320, 0)
	panel.add_child(vbox)

	_title_label = Label.new()
	_title_label.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_H2)
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_title_label)

	_message_label = Label.new()
	_message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message_label.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_BODY)
	vbox.add_child(_message_label)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	hbox.alignment = BoxContainer.ALIGNMENT_END
	vbox.add_child(hbox)

	_cancel_button = Button.new()
	_cancel_button.pressed.connect(func(): _cerrar(false))
	hbox.add_child(_cancel_button)

	_ok_button = Button.new()
	_ok_button.pressed.connect(func(): _cerrar(true))
	hbox.add_child(_ok_button)

## Configura el popup y lo muestra
func configurar(title_key: String, message_key: String, on_ok: Callable, on_cancel: Callable = Callable()) -> void:
	_title_label.text = _t(title_key)
	_message_label.text = _t(message_key)
	_cancel_button.text = _t("SETTINGS.CANCELAR")
	_ok_button.text = _t("SETTINGS.CONFIRMAR")
	_on_ok = on_ok
	_on_cancel = on_cancel
	visible = true
	if _cancel_button:
		_cancel_button.grab_focus()

func _cerrar(aceptar: bool) -> void:
	visible = false
	if aceptar and _on_ok.is_valid():
		_on_ok.call()
	elif not aceptar and _on_cancel.is_valid():
		_on_cancel.call()

func _t(clave: String) -> String:
	var loc = get_node_or_null("/root/Localization")
	if loc and loc.has_method("traducir_clave"):
		var res = loc.traducir_clave(clave)
		if res != clave:
			return res
	return clave
