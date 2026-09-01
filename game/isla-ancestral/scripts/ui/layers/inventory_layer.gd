# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M53: InventoryLayer — panel de inventario (RF4, sección E) como capa M53.
# Grid de slots del bolsillo (M14 InventarioService + ContenedorInventario),
# favoritos (F), tooltip por hover/foco, conteo de slots usados.
# Lectura por señales y refresh puntual; la lógica de inventario vive en M14.
# Abre con acción `inventario` (I), cierra con `pausa`/Esc.

class_name InventoryLayer
extends UILayer

var _grid: GridContainer
var _titulo_label: Label
var _info_label: Label
var _slots: Array = []   # Botones del grid (índice = slot del contenedor)
var _drag_source: int = -1  # Slot origen para swap por dos clicks

func _ready() -> void:
	layer_type = UILayerType.Type.MODAL_SIMPLE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_crear_ui()
	visible = false
	var inv = get_node_or_null("/root/Inventario")
	if inv:
		inv.item_added.connect(_on_inv_changed)
		inv.item_removed.connect(_on_inv_changed)

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
	vbox.add_child(_titulo_label)

	_info_label = Label.new()
	_info_label.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_SMALL)
	_info_label.add_theme_color_override("font_color", Color(0.55, 0.5, 0.45))
	vbox.add_child(_info_label)

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

## Refresca el contenido de los slots desde el contenedor bolsillo (M14).
func _refrescar_contenido() -> void:
	var inv = get_node_or_null("/root/Inventario")
	var usados: int = 0
	for i in range(_slots.size()):
		var btn: Button = _slots[i]
		var texto := ""
		var tooltip := _t("SETTINGS.SLOT_LIBRE")
		var item_id := ""
		if inv:
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

func _nombre_item(item_id: String) -> String:
	# Nombre amable: convierte "madera_roble" -> "Madera roble" (catálogo M88 pendiente)
	var limpio := item_id.replace("_", " ").strip_edges()
	if limpio.length() > 0:
		limpio = limpio[0].to_upper() + limpio.substr(1)
	return limpio

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

## ── Input ────────────────────────────────────────────────

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("inventario") or event.is_action_pressed("pausa"):
		visible = false
		get_viewport().set_input_as_handled()

## Abre/cierra el panel (toggle). Se llama por la acción `inventario` global.
func toggle() -> void:
	visible = not visible
	if visible:
		_refrescar_contenido()
		_freeze_world(true)
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
