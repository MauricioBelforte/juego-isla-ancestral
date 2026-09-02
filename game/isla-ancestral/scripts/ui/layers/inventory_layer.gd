# Modelo: Claude (Cline) — unificación BUG-001 2026-09-02
# Plataforma: Cline
#
# M53: InventoryLayer — ÚNICO panel de inventario del juego (capa M53).
#
# UNIFICACIÓN 2026-09-02 (BUG-001): se eliminó el doble sistema con player.gd.
# La acción `inventario` (tecla B) abre SOLO esta capa vía UIManager, y al
# cerrar se oculta la capa completa (overlay FondoDim incluido) → nunca queda
# pegado. Conserva del legacy M14: pestañas de categoría, búsqueda, sort,
# drag/swap por dos clicks, favoritos (doble click), tooltip y contador.
# Lectura/escritura vía InventarioService (autoload /root/Inventario, M14).

class_name InventoryLayer
extends UILayer

const CATEGORY_NAMES := {
	-1: "Todos",
	0: "Mobiliario", 1: "Decoración", 2: "Iluminación",
	3: "Plantas", 4: "Alfombras", 5: "Cocina",
	6: "Trabajo", 7: "Exteriores", 8: "Naturaleza",
	9: "Construcción", 10: "Herramientas", 11: "Items",
	12: "Ropa", 13: "Arte", 14: "Evento", 15: "Secreto",
}

const SORT_MODES := ["Favoritos+ID", "Nombre", "Categoría", "Rareza"]

var _grid: GridContainer
var _titulo_label: Label
var _info_label: Label
var _slots: Array = []          # Botones del grid (índice = slot del contenedor)
var _drag_source: int = -1      # Slot origen para swap por dos clicks

# Features portadas del legacy M14 (E3/E4/sección E)
var _categoria_activa: int = -1
var _busqueda: String = ""
var _sort_mode: int = 0
var _sort_option: OptionButton = null

func _ready() -> void:
	layer_type = UILayerType.Type.MODAL_SIMPLE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_crear_ui()
	visible = false
	var inv = get_node_or_null("/root/Inventario")
	if inv:
		if inv.has_signal("item_added"):
			inv.item_added.connect(_on_inv_changed)
		if inv.has_signal("item_removed"):
			inv.item_removed.connect(_on_inv_changed)
		if inv.has_signal("inventario_actualizado"):
			inv.inventario_actualizado.connect(_on_inv_any)

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
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	_titulo_label = Label.new()
	_titulo_label.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_H2)
	_titulo_label.text = _t("SETTINGS.INVENTARIO")
	vbox.add_child(_titulo_label)

	_info_label = Label.new()
	_info_label.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_SMALL)
	_info_label.add_theme_color_override("font_color", Color(0.55, 0.5, 0.45))
	vbox.add_child(_info_label)

	_construir_tabs(vbox)
	_construir_busqueda(vbox)
	_construir_sort(vbox)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 260)
	vbox.add_child(scroll)

	_grid = GridContainer.new()
	_grid.columns = 6
	_grid.add_theme_constant_override("h_separation", 6)
	_grid.add_theme_constant_override("v_separation", 6)
	_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_grid)

	_construir_slots()

	var hint := Label.new()
	hint.text = _t("SETTINGS.INVENTARIO_HINT")
	hint.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_SMALL)
	vbox.add_child(hint)
## Pestañas de categoría (portado del legacy M14 — E-categorías).
func _construir_tabs(parent: Control) -> void:
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 4)
	parent.add_child(tabs)
	for cat_id in CATEGORY_NAMES.keys():
		var btn := Button.new()
		btn.text = CATEGORY_NAMES[cat_id]
		btn.custom_minimum_size = Vector2(0, 26)
		btn.pressed.connect(_on_category_pressed.bind(int(cat_id)))
		tabs.add_child(btn)

## Barra de búsqueda por texto (portado del legacy M14 — E3).
func _construir_busqueda(parent: Control) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	parent.add_child(row)
	var line := LineEdit.new()
	line.placeholder_text = _t("SETTINGS.BUSCAR")
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.text_changed.connect(_on_search_changed)
	row.add_child(line)

## Fila de ordenamiento (portado del legacy M14 — E4).
func _construir_sort(parent: Control) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	parent.add_child(row)
	var label := Label.new()
	label.text = _t("SETTINGS.ORDENAR")
	row.add_child(label)
	_sort_option = OptionButton.new()
	for mode_name in SORT_MODES:
		_sort_option.add_item(mode_name)
	_sort_option.selected = _sort_mode
	_sort_option.item_selected.connect(_on_sort_mode_changed)
	row.add_child(_sort_option)
	var btn := Button.new()
	btn.text = _t("SETTINGS.APLICAR")
	btn.pressed.connect(_on_sort_pressed)
	row.add_child(btn)

## Crea los botones de slots (se reconstruyen al refrescar el contenido).
func _construir_slots() -> void:
	for child in _grid.get_children():
		child.queue_free()
	_slots.clear()
	var inv = get_node_or_null("/root/Inventario")
	var total: int = 20
	if inv and inv.has_method("total_slots"):
		total = int(inv.total_slots(0))
	for i in range(total):
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(56, 56)
		btn.tooltip_text = ""
		btn.pressed.connect(_on_slot_pressed.bind(i))
		_grid.add_child(btn)
		_slots.append(btn)
	_refrescar_contenido()
## Refresca el contenido de los slots desde el contenedor bolsillo (M14),
## aplicando los filtros portados del legacy: categoría y búsqueda.
func _refrescar_contenido() -> void:
	var inv = get_node_or_null("/root/Inventario")
	var usados: int = 0
	for i in range(_slots.size()):
		var btn: Button = _slots[i]
		var texto := ""
		var tooltip := _t("SETTINGS.SLOT_LIBRE")
		var item_id := ""
		if inv and _slot_visible(inv, i):
			var slot = _leer_slot(inv, i)
			if slot != null and not slot.esta_libre():
				item_id = str(slot.item_id)
				usados += 1
				var estrella := "⭐ " if slot.favorito else ""
				texto = estrella + _nombre_item(item_id) + "\nx" + str(slot.cantidad)
				tooltip = item_id
		btn.text = texto
		btn.tooltip_text = tooltip
	if _info_label:
		_info_label.text = "%s: %d/%d" % [_t("SETTINGS.SLOTS"), usados, _slots.size()]

## Determina si un slot pasa los filtros de categoría y búsqueda.
func _slot_visible(inv: Node, indice: int) -> bool:
	var slot = _leer_slot(inv, indice)
	if slot == null or slot.esta_libre():
		return false
	var item = _get_item(str(slot.item_id))
	if _categoria_activa != -1:
		if item == null or int(item.categoria) != _categoria_activa:
			return false
	if _busqueda != "":
		var b := _busqueda.to_lower()
		var match_name: bool = (item != null and str(item.nombre).to_lower().contains(b))
		var match_id: bool = str(slot.item_id).to_lower().contains(b)
		var match_desc: bool = (item != null and str(item.descripcion).to_lower().contains(b))
		if not match_name and not match_id and not match_desc:
			return false
	return true

## Lee un slot del contenedor bolsillo (0) de forma defensiva.
func _leer_slot(inv: Node, indice: int):
	var contenedores = inv.get("contenedores")
	if contenedores == null or contenedores.size() == 0:
		return null
	var bolsillo = contenedores[0]
	if bolsillo == null or not bolsillo.has_method("get"):
		return null
	var slots: Array = bolsillo.get("slots")
	if indice >= slots.size():
		return null
	return slots[indice]

## Obtiene el ItemData del catálogo (autoload /root/ItemDatabase, M159).
func _get_item(item_id: String):
	var db = get_node_or_null("/root/ItemDatabase")
	if db and db.has_method("get_item"):
		return db.get_item(item_id)
	return null

func _nombre_item(item_id: String) -> String:
	var item = _get_item(item_id)
	if item != null and str(item.nombre) != "":
		return str(item.nombre)
	var limpio := item_id.replace("_", " ").strip_edges()
	if limpio.length() > 0:
		limpio = limpio[0].to_upper() + limpio.substr(1)
	return limpio

## ── Filtros portados (categoría / búsqueda / sort) ────────

func _on_category_pressed(cat_id: int) -> void:
	_categoria_activa = cat_id
	_cancel_drag()
	_refrescar_contenido()

func _on_search_changed(texto: String) -> void:
	_busqueda = texto
	_refrescar_contenido()

func _on_sort_mode_changed(index: int) -> void:
	_sort_mode = index

func _on_sort_pressed() -> void:
	var inv = get_node_or_null("/root/Inventario")
	if inv and inv.has_method("sort_container"):
		inv.sort_container(0, _sort_mode)
	_cancel_drag()
	_refrescar_contenido()
## ── Interacción ──────────────────────────────────────────

## Click/foco en un slot: drag & drop por dos clicks (selección → swap).
## Primer click selecciona, segundo click intercambia con el destino.
func _on_slot_pressed(indice: int) -> void:
	var inv = get_node_or_null("/root/Inventario")
	if inv == null:
		return
	var slot = _leer_slot(inv, indice)
	if slot == null or slot.esta_libre():
		# Slot libre: si hay origen seleccionado, mover ítem aquí
		if _drag_source >= 0 and _drag_source != indice:
			_swap_slots(_drag_source, indice)
			_cancel_drag()
		return

	if _drag_source < 0:
		# Primer click: seleccionar origen
		_drag_source = indice
		_resaltar_slot(indice, true)
	elif _drag_source == indice:
		# Segundo click en mismo slot: toggle favorito
		slot.favorito = not slot.favorito
		_cancel_drag()
		_refrescar_contenido()
	else:
		# Segundo click en otro slot: intercambiar
		_swap_slots(_drag_source, indice)
		_cancel_drag()

## Intercambia el contenido de dos slots vía InventarioService.
func _swap_slots(a: int, b: int) -> void:
	var inv = get_node_or_null("/root/Inventario")
	if inv == null:
		return
	if inv.has_method("swap_slots"):
		inv.swap_slots(0, a, 0, b)
		_refrescar_contenido()
		return
	# Fallback: swap manual si el servicio no tiene el método aún
	var slot_a = _leer_slot(inv, a)
	var slot_b = _leer_slot(inv, b)
	if slot_a == null or slot_b == null:
		return
	# Copia temporal
	var tmp_id: String = str(slot_a.get("item_id", ""))
	var tmp_cant: int = int(slot_a.get("cantidad", 0))
	var tmp_fav: bool = bool(slot_a.get("favorito", false))
	# B → A
	if slot_b.has_method("set"):
		slot_a.item_id = str(slot_b.get("item_id", ""))
		slot_a.cantidad = int(slot_b.get("cantidad", 0))
		slot_a.favorito = bool(slot_b.get("favorito", false))
		slot_b.item_id = tmp_id
		slot_b.cantidad = tmp_cant
		slot_b.favorito = tmp_fav
	_refrescar_contenido()

## Resalta/des resalta un slot visualmente.
func _resaltar_slot(indice: int, activo: bool) -> void:
	if indice < 0 or indice >= _slots.size():
		return
	var btn: Button = _slots[indice]
	if activo:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.85, 0.72, 0.35, 0.3)
		sb.set_corner_radius_all(6)
		sb.set_border_width_all(2)
		sb.border_color = Color(0.85, 0.72, 0.35, 1.0)
		btn.add_theme_stylebox_override("normal", sb)
	else:
		btn.remove_theme_stylebox_override("normal")

## Cancela el estado de drag & drop.
func _cancel_drag() -> void:
	if _drag_source >= 0:
		_resaltar_slot(_drag_source, false)
	_drag_source = -1

## ── Callbacks ────────────────────────────────────────────

func _on_inv_changed(_item_id: String, _cantidad: int) -> void:
	if visible:
		_refrescar_contenido()

func _on_inv_any(_a = null, _b = null) -> void:
	if visible:
		_refrescar_contenido()
## ── Input ────────────────────────────────────────────────

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("inventario") or event.is_action_pressed("pausa"):
		visible = false
		_freeze_world(false)
		_cancel_drag()
		get_viewport().set_input_as_handled()

## Abre/cierra el panel (toggle). Se llama por la acción `inventario` global.
func toggle() -> void:
	visible = not visible
	if visible:
		_refrescar_contenido()
		_freeze_world(true)
		# Restaurar filtros al abrir
		_categoria_activa = -1
		_busqueda = ""
	else:
		_freeze_world(false)
		_cancel_drag()

## Congela/descongela el mundo al abrir/cerrar inventario (pausa suave).
func _freeze_world(frozen: bool) -> void:
	var game_time = get_node_or_null("/root/GameTime")
	if game_time and game_time.has_method("set_paused"):
		game_time.set_paused(frozen)
	# También notificar al UIManager si está disponible
	var ui_mgr = get_node_or_null("/root/UIManager")
	if ui_mgr and ui_mgr.has_method("set_world_frozen"):
		ui_mgr.set_world_frozen(frozen)

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
	_cancel_drag()
	_freeze_world(false)