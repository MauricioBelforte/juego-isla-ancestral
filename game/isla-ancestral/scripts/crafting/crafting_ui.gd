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
var _btn_crear1: Button
var _btn_crear_n: Button
var _mensaje_label: Label

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
	sb.bg_color = Color(0.96, 0.92, 0.86, 0.98)
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
		_actualizar_botones(0)
		return
	var receta: CraftingRecipe = _receta_seleccionada
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
	_detalle_label.text = "\n".join(lineas)
	_actualizar_botones(max_n)

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
