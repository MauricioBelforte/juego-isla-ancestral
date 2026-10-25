# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M16: CraftingUI — panel de crafting (RF16) como capa M53 (MODAL_SIMPLE).
# Lista de recetas conocidas de la estación, detalle de materiales (RF10: faltantes
# en rojo con origen M15), creación 1x (RF7) y múltiple (RF8). Consumo SOLO del
# CraftingService (API de solo lectura + señales) — nunca toca Inventario directo
# (separación de capas, AGENTS §9 / 03-Diseno §1).
# Textos cozy y localizados (M87). Sin tiempos de espera ni fallos destructivos.

class_name CraftingUI
extends UILayer

var _estacion_actual: int = CraftingRecipe.Estacion.MESA_TRABAJO
var _receta_seleccionada: CraftingRecipe = null

var _title_label: Label
var _recetas_box: VBoxContainer
var _detalle_label: RichTextLabel
var _preview_box: HBoxContainer
var _preview_icon: ColorRect
var _preview_label: Label
var _btn_crear1: Button
var _btn_crear_n: Button
var _mensaje_label: Label
var _mejora_box: VBoxContainer
var _mejora_label: RichTextLabel
var _btn_mejorar: Button

func _ready() -> void:
	layer_type = UILayerType.Type.MODAL_SIMPLE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_crear_ui()
	visible = false
	var cs = get_node_or_null("/root/Crafting")
	if cs:
		cs.crafting_completed.connect(_on_craft_result)
		cs.crafting_failed.connect(_on_craft_failed)

## ── Construcción de la UI ────────────────────────────────

func _crear_ui() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.4)
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
	sb.bg_color = Color(ThemeUx.COLOR_TEXT_DARK, 0.98)  # M53 L159: token (alpha 0.98 se pasa explicito)
	sb.border_color = Color(0.72, 0.55, 0.30)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(16)
	sb.set_content_margin_all(18)
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	vbox.custom_minimum_size = Vector2(460, 320)
	panel.add_child(vbox)

	_title_label = Label.new()
	_title_label.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_H2)
	vbox.add_child(_title_label)

	var sep := HSeparator.new()
	vbox.add_child(sep)

	# Lista de recetas (scroll)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 150)
	vbox.add_child(scroll)
	_recetas_box = VBoxContainer.new()
	_recetas_box.add_theme_constant_override("separation", 4)
	_recetas_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_recetas_box)

	# Detalle de materiales (RF10)
	_detalle_label = RichTextLabel.new()
	_detalle_label.bbcode_enabled = true
	_detalle_label.fit_content = true
	_detalle_label.custom_minimum_size = Vector2(0, 90)
	vbox.add_child(_detalle_label)

	# Preview del resultado (RF9) — V1: swatch de color + nombre del item
	_preview_box = HBoxContainer.new()
	_preview_box.add_theme_constant_override("separation", 8)
	vbox.add_child(_preview_box)
	_preview_icon = ColorRect.new()
	_preview_icon.custom_minimum_size = Vector2(28, 28)
	_preview_icon.color = Color(0.8, 0.75, 0.65, 1)
	_preview_box.add_child(_preview_icon)
	_preview_label = Label.new()
	_preview_label.text = ""
	_preview_box.add_child(_preview_label)

	# Botones de creación
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	vbox.add_child(hbox)

	_btn_crear1 = Button.new()
	_btn_crear1.pressed.connect(_on_crear_1)
	hbox.add_child(_btn_crear1)

	_btn_crear_n = Button.new()
	_btn_crear_n.pressed.connect(_on_crear_n)
	hbox.add_child(_btn_crear_n)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)

	var btn_cerrar := Button.new()
	btn_cerrar.text = _t("SETTINGS.CERRAR")
	btn_cerrar.pressed.connect(_cerrar)
	hbox.add_child(btn_cerrar)

	# MR12/MR13 (N.3): panel de mejora — visible solo si el resultado de la
	# receta seleccionada es una herramienta del schema MR3.
	_mejora_box = VBoxContainer.new()
	_mejora_box.add_theme_constant_override("separation", 4)
	vbox.add_child(_mejora_box)
	_mejora_label = RichTextLabel.new()
	_mejora_label.bbcode_enabled = true
	_mejora_label.fit_content = true
	_mejora_label.add_theme_font_size_override("normal_font_size", ThemeUx.FONT_SIZE_SMALL)
	_mejora_box.add_child(_mejora_label)
	_btn_mejorar = Button.new()
	_btn_mejorar.text = _t("SETTINGS.MEJORAR")
	_btn_mejorar.pressed.connect(_on_mejorar)
	_mejora_box.add_child(_btn_mejorar)
	_mejora_box.visible = false

	# Mensaje cozy de resultado
	_mensaje_label = Label.new()
	_mensaje_label.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_SMALL)
	_mensaje_label.add_theme_color_override("font_color", Color(0.4, 0.55, 0.3))
	vbox.add_child(_mensaje_label)

## ── Apertura / cierre ────────────────────────────────────

## Abre el panel para una estación (llamado por CraftingStation).
func abrir(estacion: int) -> void:
	_estacion_actual = estacion
	visible = true
	_receta_seleccionada = null
	var nombres := {
		CraftingRecipe.Estacion.MESA_TRABAJO: "SETTINGS.MESA_TRABAJO",
		CraftingRecipe.Estacion.FOGATA: "SETTINGS.FOGATA",
		CraftingRecipe.Estacion.TELAR: "SETTINGS.TELAR",
	}
	_title_label.text = _t(str(nombres.get(estacion, "SETTINGS.MESA_TRABAJO")))
	_mensaje_label.text = ""
	_refrescar_lista()
	_refrescar_detalle()

func _cerrar() -> void:
	visible = false
	_receta_seleccionada = null

## ── Lista de recetas ─────────────────────────────────────

func _refrescar_lista() -> void:
	for child in _recetas_box.get_children():
		child.queue_free()
	var cs = get_node_or_null("/root/Crafting")
	if cs == null:
		return
	var recetas: Array = cs.recetas_por_estacion(_estacion_actual)
	if recetas.is_empty():
		var vacio := Label.new()
		vacio.text = _t("SETTINGS.SIN_RECETAS")
		_recetas_box.add_child(vacio)
		return
	for receta in recetas:
		var btn := Button.new()
		var icono := "🔒 " if receta.origen == CraftingRecipe.Origen.EXPERIMENTACION else ""
		btn.text = icono + receta.nombre
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_seleccionar.bind(receta))
		_recetas_box.add_child(btn)

func _on_seleccionar(receta: CraftingRecipe) -> void:
	_receta_seleccionada = receta
	_refrescar_detalle()

## ── Detalle de materiales (RF10) ─────────────────────────

func _refrescar_detalle() -> void:
	var inv = get_node_or_null("/root/Inventario")
	if _receta_seleccionada == null:
		_detalle_label.text = _t("SETTINGS.SELECCIONA_RECETA")
		_preview_label.text = ""
		_preview_icon.color = Color(0.8, 0.75, 0.65, 1)
		_actualizar_botones(0)
		return
	var receta: CraftingRecipe = _receta_seleccionada
	# RF9 preview: nombre del resultado + swatch derivado de su id
	_preview_label.text = "→ %s" % receta.resultado_id
	_preview_icon.color = _color_de_item(receta.resultado_id)
	var lineas: Array = []
	var cs = get_node_or_null("/root/Crafting")
	var max_n: int = cs.max_craftable(receta.id) if cs else 0
	for item_id in receta.materiales:
		var necesario: int = int(receta.materiales[item_id])
		var tengo: int = int(inv.count_item(str(item_id), true)) if inv else 0
		if tengo < necesario:
			# RF10: faltante en rojo + origen de obtención (M15)
			var origen := _origen_de(item_id)
			lineas.append("[color=#c0392b]%s: %d/%d — %s[/color]" % [str(item_id), tengo, necesario, origen])
		else:
			lineas.append("[color=#2e7d32]%s: %d/%d[/color]" % [str(item_id), tengo, necesario])
	# RF5: aviso de temporada si bloqueada
	if cs != null and cs.receta_bloqueada(receta.id):
		lineas.append("[color=#8e6e1a]%s[/color]" % _t("SETTINGS.FUERA_TEMPORADA"))
	_detalle_label.text = "\n".join(lineas)
	_actualizar_botones(max_n)
	_refrescar_mejora()


## Color del swatch de preview (RF9): hash determinista del item_id.
func _color_de_item(item_id: String) -> Color:
	if item_id == "":
		return Color(0.8, 0.75, 0.65, 1)
	var h: int = 0
	for i in range(item_id.length()):
		h = (h * 31 + int(item_id.unicode_at(i))) & 0xFFFFFFFF
	var r: float = 0.4 + 0.6 * float((h & 0xFF)) / 255.0
	var g: float = 0.4 + 0.6 * float(((h >> 8) & 0xFF)) / 255.0
	var b: float = 0.4 + 0.6 * float(((h >> 16) & 0xFF)) / 255.0
	return Color(r, g, b, 1)

func _origen_de(item_id: String) -> String:
	var rm = get_node_or_null("/root/ResourceManager")
	if rm and rm.has_method("obtener_def"):
		var def = rm.obtener_def(StringName(item_id))
		if def != null and str(def.display_name) != "":
			return str(def.display_name)
	return "recolectable"

func _actualizar_botones(max_n: int) -> void:
	var hay_receta := _receta_seleccionada != null
	_btn_crear1.text = _t("SETTINGS.CREAR_1")
	_btn_crear_n.text = _t("SETTINGS.CREAR_N") + " (%d)" % maxi(max_n, 0)
	_btn_crear1.disabled = not hay_receta or max_n < 1
	_btn_crear_n.disabled = not hay_receta or max_n < 1



## ── MR12/MR13: panel de mejora de herramientas ───────────

func _refrescar_mejora() -> void:
	var cs = get_node_or_null("/root/Crafting")
	var inv = get_node_or_null("/root/Inventario")
	_mejora_box.visible = false
	if cs == null or inv == null or not cs.has_method("mejorar_herramienta") or _receta_seleccionada == null:
		return
	var resultado: String = String(_receta_seleccionada.resultado_id)
	var tipo: String = cs._tipo_de(resultado)
	if tipo == "":
		return
	var cfg: Dictionary = cs._mejora_cfg.get("tipos", {}).get(tipo, {})
	if cfg.is_empty():
		return
	var nivel_actual: int = cs._nivel_de(resultado)
	var nivel_max: int = int(cfg.get("nivel_maximo", 0))
	var lineas: Array = [_t("SETTINGS.NIVEL_MEJORA") + "%d/%d" % [nivel_actual, nivel_max]]
	var puede := nivel_actual < nivel_max
	if not puede:
		lineas.append(_t("SETTINGS.MEJORA_MAXIMA"))
	else:
		var coste: Dictionary = cfg.get("coste_nivel", [])[nivel_actual]
		for it in coste:
			var necesario: int = int(coste[it])
			var tengo: int = int(inv.count_item(String(it), true))
			var ok_mat := tengo >= necesario
			puede = puede and ok_mat
			if ok_mat:
				lineas.append("%s: %d" % [String(it), necesario])
			else:
				lineas.append("[color=#c0392b]%s: %d/%d[/color]" % [String(it), tengo, necesario])
	lineas.append(_t("SETTINGS.DURABILIDAD_NIVEL") + "%d" % cs.durabilidad_maxima(tipo, nivel_actual + 1))
	_mejora_label.text = "\n".join(lineas)
	_btn_mejorar.disabled = not puede
	_btn_mejorar.visible = nivel_actual < nivel_max
	_mejora_box.visible = true


func _on_mejorar() -> void:
	var cs = get_node_or_null("/root/Crafting")
	if cs == null or _receta_seleccionada == null or not cs.has_method("mejorar_herramienta"):
		return
	var r: Dictionary = cs.mejorar_herramienta(String(_receta_seleccionada.resultado_id))
	if r.get("ok") == true:
		_mensaje_label.text = _t("SETTINGS.MEJORAR") + " OK"
		var fb = get_node_or_null("/root/CraftingFeedback")
		if fb != null and fb.has_method("_notificar"):
			fb._notificar(_t("SETTINGS.MEJORAR") + " " + String(_receta_seleccionada.resultado_id), "ok")
	else:
		_mensaje_label.text = str(r.get("motivo", ""))
	_refrescar_mejora()
	_refrescar_detalle()


## ── Acciones de creación (RF7 / RF8) ─────────────────────

func _on_crear_1() -> void:
	if _receta_seleccionada == null:
		return
	var cs = get_node_or_null("/root/Crafting")
	if cs:
		cs.craft(_receta_seleccionada.id, 1)

func _on_crear_n() -> void:
	if _receta_seleccionada == null:
		return
	var cs = get_node_or_null("/root/Crafting")
	if cs:
		cs.craft(_receta_seleccionada.id, cs.max_craftable(_receta_seleccionada.id))

## ── Callbacks del servicio ───────────────────────────────

func _on_craft_result(receta: CraftingRecipe, cantidad: int) -> void:
	if not visible:
		return
	_mensaje_label.text = _t("SETTINGS.CRAFT_OK") % [str(cantidad), receta.nombre]
	_refrescar_lista()
	_refrescar_detalle()

func _on_craft_failed(_receta: CraftingRecipe, _motivo: String) -> void:
	if not visible:
		return
	_mensaje_label.text = _t("SETTINGS.CRAFT_FALLO")
	_refrescar_detalle()

## ── Input ────────────────────────────────────────────────

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("pausa"):
		_cerrar()
		get_viewport().set_input_as_handled()

## ── Utilidades ───────────────────────────────────────────

func _t(clave: String) -> String:
	var loc = get_node_or_null("/root/Localization")
	if loc and loc.has_method("traducir_clave"):
		var res = loc.traducir_clave(clave)
		if res != clave:
			return res
	return clave

func on_layer_opened() -> void:
	pass

func on_layer_closed() -> void:
	visible = false
