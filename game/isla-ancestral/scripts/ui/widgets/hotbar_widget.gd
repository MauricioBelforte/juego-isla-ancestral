extends Control
class_name HotbarWidget
## Hotbar de herramientas (M53 - HUD)
##
## Muestra los slots de acceso rápido del inventario.
## Se sincroniza con Inventario (M14) vía señales.
## 8 slots horizontales con highlight en el seleccionado.

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

## ── Ciclo de vida ──────────────────────────────────────

func _ready() -> void:
	_build_ui()
	_connect_signals()
	refresh()


## ── API pública ─────────────────────────────────────────

## Selecciona un slot de la hotbar
func select_slot(index: int) -> void:
	_selected_slot = clampi(index, 0, SLOT_COUNT - 1)
	_update_highlights()


## Actualiza los datos de la hotbar
func refresh() -> void:
	var inv := _get_inventario()
	if not inv:
		return

	for i in range(SLOT_COUNT):
		var item_id := ""
		var quantity := 0

		if inv.has_method("get_hotbar_item"):
			var data: Variant = inv.get_hotbar_item(i)
			if data is Dictionary:
				item_id = str(data.get("id", ""))
				quantity = int(data.get("quantity", 0))

		_update_slot(i, item_id, quantity)


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

	_update_highlights()


func _update_slot(index: int, item_id: String, quantity: int) -> void:
	if index < 0 or index >= _slot_labels.size():
		return

	var label := _slot_labels[index]
	if quantity > 0:
		# Mostrar cantidad y primeras letras del ID
		var display := item_id.left(3) if not item_id.is_empty() else "?"
		if quantity > 1:
			display += "\n%d" % quantity
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


func _get_inventario() -> Node:
	return get_node_or_null("/root/Inventario")


func _get_event_bus() -> Node:
	return get_node_or_null("/root/EventBus")
