extends Control
class_name HotbarWidget
## Hotbar de herramientas (M53 - HUD)
##
## Muestra los slots de acceso rápido del inventario.
## Se sincroniza con Inventario (M14) vía señales.
## 8 slots horizontales con highlight en el seleccionado.
## Refresh bidireccional: seleccionar slot notifica al inventario.

## ── Configuración ───────────────────────────────────────
const SLOT_COUNT := 8
const SLOT_SIZE := Vector2(40, 40)
const SLOT_SPACING := 4
const HIGHLIGHT_COLOR := Color(0.85, 0.72, 0.35, 0.8)
const SLOT_BG := Color(0.20, 0.18, 0.15, 0.7)

## ── Estado ──────────────────────────────────────────────
var _selected_slot: int = 0
var _slot_labels: Array[Label] = []
var _slot_panels: Array[PanelContainer] = []
var _slot_tooltips: Array[String] = []

## ── Ciclo de vida ──────────────────────────────────────

func _ready() -> void:
	_build_ui()
	_connect_signals()
	refresh()


## ── API pública ─────────────────────────────────────────

## Selecciona un slot de la hotbar y notifica al inventario
func select_slot(index: int) -> void:
	_selected_slot = clampi(index, 0, SLOT_COUNT - 1)
	_update_highlights()
	_notify_inventory_selection()


## Actualiza los datos de la hotbar desde el inventario
func refresh() -> void:
	var inv := _get_inventario()
	if not inv:
		return

	for i in range(SLOT_COUNT):
		var item_id := ""
		var quantity := 0
		var tooltip_text := ""

		# Intentar leer del inventario directamente
		var slot_data := _read_hotbar_slot(inv, i)
		if slot_data != null:
			item_id = str(slot_data.get("item_id", ""))
			quantity = int(slot_data.get("cantidad", 0))
			tooltip_text = _build_tooltip(item_id, quantity)

		_update_slot(i, item_id, quantity)
		if i < _slot_tooltips.size():
			_slot_tooltips[i] = tooltip_text
		if i < _slot_panels.size():
			_slot_panels[i].tooltip_text = tooltip_text


## ── Métodos privados ────────────────────────────────────

func _build_ui() -> void:
	var hbox := HBoxContainer.new()
	hbox.name = "SlotsContainer"
	hbox.add_theme_constant_override("separation", SLOT_SPACING)
	add_child(hbox)

	for i in range(SLOT_COUNT):
		var panel := PanelContainer.new()
		panel.custom_minimum_size = SLOT_SIZE

		# Estilo del slot
		var style := StyleBoxFlat.new()
		style.bg_color = SLOT_BG
		style.set_corner_radius_all(6)
		style.set_border_width_all(1)
		style.border_color = Color(0.4, 0.35, 0.30, 0.5)
		panel.add_theme_stylebox_override("panel", style)

		# Label del ítem
		var label := Label.new()
		label.name = "SlotLabel_%d" % i
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		panel.add_child(label)

		hbox.add_child(panel)
		_slot_panels.append(panel)
		_slot_labels.append(label)
		_slot_tooltips.append("")

	_update_highlights()


func _update_slot(index: int, item_id: String, quantity: int) -> void:
	if index < 0 or index >= _slot_labels.size():
		return

	var label := _slot_labels[index]
	if quantity > 0:
		# Mostrar nombre amable y cantidad
		var display := _friendly_name(item_id) if not item_id.is_empty() else "?"
		if quantity > 1:
			display += "\nx%d" % quantity
		label.text = display
	else:
		label.text = ""


func _update_highlights() -> void:
	for i in range(_slot_panels.size()):
		var style: StyleBoxFlat = _slot_panels[i].get_theme_stylebox("panel") as StyleBoxFlat
		if style:
			if i == _selected_slot:
				style.border_color = HIGHLIGHT_COLOR
				style.set_border_width_all(2)
			else:
				style.border_color = Color(0.4, 0.35, 0.30, 0.5)
				style.set_border_width_all(1)


func _connect_signals() -> void:
	var bus := _get_event_bus()
	if not bus:
		return

	# Señales de inventario
	if bus.get("inventory"):
		var inv_events: Variant = bus.inventory
		if inv_events != null and inv_events.has_signal("hotbar_selected"):
			inv_events.hotbar_selected.connect(select_slot)


func _read_hotbar_slot(inv: Node, index: int) -> Variant:
	# Intentar get_hotbar_item (API M14)
	if inv.has_method("get_hotbar_item"):
		var data: Variant = inv.get_hotbar_item(index)
		if data is Dictionary:
			return data
	# Fallback: leer del contenedor bolsillo directamente
	var contenedores = inv.get("contenedores")
	if contenedores != null and contenedores.size() > 0:
		var bolsillo = contenedores[0]
		if bolsillo != null:
			var slots: Array = bolsillo.get("slots", [])
			if index < slots.size():
				var slot = slots[index]
				if slot != null and not slot.esta_libre():
					return {"item_id": str(slot.get("item_id", "")), "cantidad": int(slot.get("cantidad", 0))}
	return null


func _notify_inventory_selection() -> void:
	var inv := _get_inventario()
	if inv and inv.has_method("select_hotbar_slot"):
		inv.select_hotbar_slot(_selected_slot)


func _friendly_name(item_id: String) -> String:
	return item_id.replace("_", " ").capitalize()


func _build_tooltip(item_id: String, quantity: int) -> String:
	if item_id.is_empty():
		return ""
	var name := _friendly_name(item_id)
	if quantity > 1:
		return "%s (x%d)" % [name, quantity]
	return name


func _get_inventario() -> Node:
	return get_node_or_null("/root/Inventario")


func _get_event_bus() -> Node:
	return get_node_or_null("/root/EventBus")
