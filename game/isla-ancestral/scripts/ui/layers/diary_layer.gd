# T-053-067: DiaryLayer — capa del diario del jugador (M55)
# Muestra las entradas del diario organizadas por categorías.
# Consume DiaryService (M55) de forma defensiva.

class_name DiaryLayer
extends UILayer

signal cerrar_pedido

var _buttons: Array[Button] = []
var _category_list: VBoxContainer
var _entry_list: VBoxContainer
var _current_category: String = ""

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

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	panel.add_child(hbox)

	# Panel de categorías (izquierda)
	var cat_vbox := VBoxContainer.new()
	cat_vbox.custom_minimum_size = Vector2(160, 0)
	hbox.add_child(cat_vbox)

	var cat_title := Label.new()
	cat_title.text = _t("DIARY.CATEGORIAS")
	cat_title.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_H2)
	cat_vbox.add_child(cat_title)

	var sep := HSeparator.new()
	cat_vbox.add_child(sep)

	_category_list = VBoxContainer.new()
	_category_list.add_theme_constant_override("separation", 4)
	cat_vbox.add_child(_category_list)

	# Panel de entradas (derecha)
	var entry_vbox := VBoxContainer.new()
	entry_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(entry_vbox)

	var entry_title := Label.new()
	entry_title.text = _t("DIARY.ENTRADAS")
	entry_title.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_H2)
	entry_vbox.add_child(entry_title)

	var sep2 := HSeparator.new()
	entry_vbox.add_child(sep2)

	_entry_list = VBoxContainer.new()
	_entry_list.add_theme_constant_override("separation", 4)
	entry_vbox.add_child(_entry_list)

	# Botón cerrar
	var close_btn := Button.new()
	close_btn.text = _t("SETTINGS.CERRAR")
	close_btn.pressed.connect(func(): cerrar_pedido.emit())
	entry_vbox.add_child(close_btn)

	# Cargar categorías
	_cargar_categorias()


func _cargar_categorias() -> void:
	if _category_list == null:
		return

	# Limpiar categorías previas
	for child in _category_list.get_children():
		child.queue_free()

	# Intentar cargar desde DiaryService
	var diary = get_node_or_null("/root/Diary")
	if diary and diary.has_method("get_categorias"):
		var categorias: Array = diary.get_categorias()
		for cat in categorias:
			var btn := Button.new()
			btn.text = _t("DIARY.CAT_" + str(cat).to_upper())
			btn.pressed.connect(func(): _seleccionar_categoria(str(cat)))
			_category_list.add_child(btn)
			_buttons.append(btn)
	else:
		# Categorías por defecto si DiaryService no está disponible
		var default_cats := ["descubrimientos", "misiones", "personajes", "lugares"]
		for cat in default_cats:
			var btn := Button.new()
			btn.text = _t("DIARY.CAT_" + cat.to_upper())
			btn.pressed.connect(func(): _seleccionar_categoria(cat))
			_category_list.add_child(btn)
			_buttons.append(btn)


func _seleccionar_categoria(category: String) -> void:
	_current_category = category
	_cargar_entradas(category)


func _cargar_entradas(category: String) -> void:
	if _entry_list == null:
		return

	# Limpiar entradas previas
	for child in _entry_list.get_children():
		child.queue_free()

	# Intentar cargar desde DiaryService
	var diary = get_node_or_null("/root/Diary")
	if diary and diary.has_method("get_entradas_por_categoria"):
		var entradas: Array = diary.get_entradas_por_categoria(category)
		for entrada in entradas:
			var label := Label.new()
			label.text = str(entrada.get("titulo", "Sin título"))
			label.add_theme_font_size_override("font_size", 14)
			_entry_list.add_child(label)
	else:
		# Mensaje por defecto
		var label := Label.new()
		label.text = _t("DIARY.SIN_ENTRADAS")
		label.add_theme_font_size_override("font_size", 14)
		_entry_list.add_child(label)


func _t(clave: String) -> String:
	var loc = get_node_or_null("/root/Localization")
	if loc and loc.has_method("traducir_clave"):
		var res = loc.traducir_clave(clave)
		if res != clave:
			return res
	return clave


## ── UILayer virtual ──────────────────────────────────────

func on_layer_opened() -> void:
	_cargar_categorias()
	if _buttons.size() > 0:
		_buttons[0].grab_focus()


func on_layer_closed() -> void:
	visible = false


func focus_first() -> Control:
	if _buttons.size() > 0:
		return _buttons[0]
	return null
