# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M53: PauseLayer — menú de pausa (modal completo).
# Muestra opciones de pausa (Continuar, Ajustes, Guardar, Volver al título).
# Registrada en UIManager; navegable por teclado y gamepad (MenuNavigator).

class_name PauseLayer
extends UILayer

signal continuar_pedido
signal ajustes_pedido
signal guardar_pedido
signal salir_pedido

var _buttons: Array[Button] = []

func _ready() -> void:
	layer_type = UILayerType.Type.MODAL_FULL
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_crear_ui()
	visible = false

func _crear_ui() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dim.name = "FondoDim"
	add_child(dim)
	dim.move_to_front()

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.96, 0.92, 0.86, 0.98)
	sb.border_color = Color(0.72, 0.55, 0.30)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(16)
	sb.set_content_margin_all(24)
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	vbox.custom_minimum_size = Vector2(280, 0)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = _t("SETTINGS.PAUSA")
	title.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_H1)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var sep := HSeparator.new()
	vbox.add_child(sep)

	var sep_small := VSeparator.new()
	sep_small.visible = false
	vbox.add_child(sep_small)

	_agregar_boton(vbox, "SETTINGS.CONTINUAR", func(): continuar_pedido.emit())
	_agregar_boton(vbox, "SETTINGS.AJUSTES", func(): ajustes_pedido.emit())
	_agregar_boton(vbox, "SETTINGS.GUARDAR", func(): guardar_pedido.emit())
	_agregar_boton(vbox, "SETTINGS.SALIR", func(): salir_pedido.emit())

func _agregar_boton(vbox: VBoxContainer, clave: String, cb: Callable) -> void:
	var btn := Button.new()
	btn.text = _t(clave)
	btn.pressed.connect(cb)
	vbox.add_child(btn)
	_buttons.append(btn)

func _t(clave: String) -> String:
	var loc = get_node_or_null("/root/Localization")
	if loc and loc.has_method("traducir_clave"):
		var res = loc.traducir_clave(clave)
		if res != clave:
			return res
	return clave

## ── UILayer virtual ──────────────────────────────────────

func on_layer_opened() -> void:
	if _buttons.size() > 0:
		_buttons[0].grab_focus()

func on_layer_closed() -> void:
	visible = false

func focus_first() -> Control:
	if _buttons.size() > 0:
		return _buttons[0]
	return null
