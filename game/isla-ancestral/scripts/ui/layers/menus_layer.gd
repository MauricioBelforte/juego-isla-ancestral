# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M53: MenusLayer — menú principal (M89 consume esta capa).
# Botones: Jugar, Continuar, Ajustes, Créditos, Salir.
# Navegable por teclado/gamepad (MenuNavigator) y localizado (M87).

class_name MenusLayer
extends UILayer

signal jugar_pedido
signal continuar_pedido
signal ajustes_pedido
signal creditos_pedido
signal salir_pedido

var _buttons: Array[Button] = []

func _ready() -> void:
	layer_type = UILayerType.Type.MODAL_FULL
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_crear_ui()
	visible = false

func _crear_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.14, 0.16, 0.24)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.name = "Fondo"
	add_child(bg)
	bg.move_to_front()

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	vbox.custom_minimum_size = Vector2(320, 0)
	center.add_child(vbox)

	var title := Label.new()
	title.text = _t("SETTINGS.TITULO")
	title.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_H1)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var sep := HSeparator.new()
	vbox.add_child(sep)

	var perfil_label := Label.new()
	perfil_label.name = "PerfilLabel"
	perfil_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	perfil_label.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_SMALL)
	perfil_label.add_theme_color_override("font_color", ThemeUx.COLOR_ACCENT_OCRE)
	vbox.add_child(perfil_label)
	_actualizar_perfil_label(perfil_label)
	_conectar_perfil(perfil_label)

	_agregar_boton(vbox, "SETTINGS.JUGAR", func(): jugar_pedido.emit())
	_agregar_boton(vbox, "SETTINGS.CONTINUAR", func(): continuar_pedido.emit())
	_agregar_boton(vbox, "SETTINGS.AJUSTES", func(): ajustes_pedido.emit())
	_agregar_boton(vbox, "SETTINGS.CREDITOS", func(): creditos_pedido.emit())
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

func on_layer_opened() -> void:
	if _buttons.size() > 0:
		_buttons[0].grab_focus()

func on_layer_closed() -> void:
	visible = false

func focus_first() -> Control:
	if _buttons.size() > 0:
		return _buttons[0]
	return null


## M58 ítem [42]: indicador visual del perfil de control activo (AccesibilidadManager).
func _actualizar_perfil_label(label: Label) -> void:
	var acc := get_node_or_null("/root/AccesibilidadManager")
	if acc == null or not acc.has_method("get_perfil"):
		label.text = ""
		label.visible = false
		return
	var perfil: Dictionary = acc.get_perfil()
	var nombre := String(perfil.get("nombre", "custom"))
	if nombre.is_empty():
		nombre = "custom"
	label.text = "Controles: " + nombre
	label.visible = true


func _conectar_perfil(label: Label) -> void:
	var acc := get_node_or_null("/root/AccesibilidadManager")
	if acc != null and acc.has_signal("profile_changed"):
		if not acc.profile_changed.is_connected(_on_profile_changed):
			acc.profile_changed.connect(_on_profile_changed)
		_label_perfil_ref = label

var _label_perfil_ref: Label = null


func _on_profile_changed(profile_name: String) -> void:
	if _label_perfil_ref != null and is_instance_valid(_label_perfil_ref):
		_label_perfil_ref.text = "Controles: " + profile_name
