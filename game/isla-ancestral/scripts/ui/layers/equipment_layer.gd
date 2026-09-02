# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M155: EquipmentLayer — panel de vestimenta como capa M53 (reemplaza el
# esqueleto roto scripts/ui/equipment_ui.gd que esperaba $Panel/VBox/... sin
# escena). 4 slots + catálogo de prendas con desbloqueo progresivo (UnlockCondition)
# + bono de terreno del equipo. Abre con acción `equipamiento` (E), cierra con
# `equipamiento`/`pausa`. Copia el patrón de InventoryLayer (M53 sección E).

class_name EquipmentLayer
extends UILayer

const _CATALOGO_SLOTS: Array[String] = ["head", "body", "feet", "accessory"]

var _slots_btn: Dictionary = {}        # slot_type(int) -> Button
var _grid: GridContainer
var _bonus_label: Label
var _info_label: Label
var _manager: Node = null

func _ready() -> void:
	layer_type = UILayerType.Type.MODAL_SIMPLE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_crear_ui()
	visible = false
	_manager = get_node_or_null("/root/EquipmentManager")
	if _manager:
		_manager.equipment_changed.connect(_on_equipment_changed)
		_manager.terrain_bonus_updated.connect(_on_terrain_bonus_updated)

## ── Construcción (por código, patrón InventoryLayer) ─────

func _crear_ui() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.4)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dim.name = "FondoDim"
	add_child(dim)

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

	var titulo := Label.new()
	titulo.text = "Vestimenta del jugador"
	titulo.add_theme_font_size_override("font_size", 26)
	vbox.add_child(titulo)

	_bonus_label = Label.new()
	_bonus_label.text = "Bono terreno: +0%"
	_bonus_label.add_theme_font_size_override("font_size", 15)
	vbox.add_child(_bonus_label)

	_info_label = Label.new()
	_info_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(_info_label)

	var slots_box := GridContainer.new()
	slots_box.columns = 2
	slots_box.add_theme_constant_override("h_separation", 8)
	slots_box.add_theme_constant_override("v_separation", 6)
	vbox.add_child(slots_box)

	for tipo in _CATALOGO_SLOTS:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(230, 46)
		var st: int = _tipo_a_slot(tipo)
		btn.pressed.connect(_on_slot_clicked.bind(st))
		slots_box.add_child(btn)
		_slots_btn[st] = btn

	var sep := HSeparator.new()
	vbox.add_child(sep)

	var grid_title := Label.new()
	grid_title.text = "Prendas del catálogo (click para equipar)"
	grid_title.add_theme_font_size_override("font_size", 15)
	vbox.add_child(grid_title)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(480, 220)
	vbox.add_child(scroll)
	_grid = GridContainer.new()
	_grid.columns = 2
	_grid.add_theme_constant_override("h_separation", 6)
	_grid.add_theme_constant_override("v_separation", 6)
	_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_grid)

	var hint := Label.new()
	hint.text = "E / ESC para cerrar — los 🔒 se desbloquean con capítulo o banderas (M71)"
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color(0.55, 0.5, 0.45))
	vbox.add_child(hint)

	_refresh_equipo()

## ── Refresh ─────────────────────────────────────────────

func _refresh_equipo() -> void:
	if _manager == null:
		return
	for tipo in _CATALOGO_SLOTS:
		var st: int = _tipo_a_slot(tipo)
		var btn: Button = _slots_btn.get(st)
		if btn == null:
			continue
		var slot = _manager.get_equipped_item(st)
		if slot and slot.is_equipped():
			btn.text = "%s: %s" % [tipo.capitalize(), slot.item_name]
			btn.tooltip_text = "Click para quitar — %s (%s)" % [slot.item_id, slot.rarity]
		else:
			btn.text = "%s: (vacío)" % tipo.capitalize()
			btn.tooltip_text = "Selecciona una prenda del catálogo para equipar aquí"
	var total_bonus := 0.0
	if _manager.has_method("get_terrain_bonus_total"):
		total_bonus = float(_manager.get_terrain_bonus_total())
	elif _manager.get("player_equipment") and _manager.player_equipment.has_method("get_total_terrain_bonus"):
		total_bonus = float(_manager.player_equipment.get_total_terrain_bonus("current"))
	_bonus_label.text = "Bono de terreno del equipo: +%d%%" % int(total_bonus * 100.0)

	# Grid de prendas con estado de desbloqueo
	for child in _grid.get_children():
		child.queue_free()
	var player_state: Dictionary = {"capitulo_actual": 1, "flags": {}}
	var items: Array = _manager.catalog.keys()
	items.sort()
	for item_id in items:
		var data: Dictionary = _manager.catalog[item_id]
		var desbloqueada: bool = _manager.is_item_unlocked(item_id, player_state)
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(220, 40)
		btn.text = ("%s — %s (%s)" % [data.get("name", item_id), data.get("rarity", "?"), item_id]) if desbloqueada else "🔒 %s (%s)" % [data.get("name", item_id), item_id]
		btn.tooltip_text = "Tipo: %s — %s" % [data.get("slot", "?"), data.get("description", "")]
		btn.disabled = not desbloqueada
		btn.pressed.connect(_on_item_pressed.bind(item_id))
		_grid.add_child(btn)
	_info_label.text = "%d prendas en el catálogo" % items.size()

## ── Interacción ──────────────────────────────────────────

func _on_slot_clicked(slot_type: int) -> void:
	if _manager == null:
		return
	var slot = _manager.get_equipped_item(slot_type)
	if slot and slot.is_equipped():
		_manager.unequip_slot(slot_type)
		_refresh_equipo()

func _on_item_pressed(item_id: String) -> void:
	if _manager == null:
		return
	var data: Dictionary = _manager.catalog.get(item_id, {})
	var slot_str: String = data.get("slot", "accessory")
	var result: bool = _manager.equip_item(item_id, _tipo_a_slot(slot_str))
	print("[EquipmentUI] equipar %s -> %s: %s" % [item_id, slot_str, "OK" if result else "rechazado"])
	_refresh_equipo()

func _on_equipment_changed(_slot_type: int, _new_item_id: String) -> void:
	if visible:
		_refresh_equipo()

func _on_terrain_bonus_updated(_total: float) -> void:
	if visible:
		_refresh_equipo()

func _tipo_a_slot(tipo: String) -> int:
	match tipo:
		"head":
			return EquipmentSlot.SlotType.HEAD
		"body":
			return EquipmentSlot.SlotType.BODY
		"feet":
			return EquipmentSlot.SlotType.FEET
		_:
			return EquipmentSlot.SlotType.ACCESSORY

## ── Ciclo de capa ────────────────────────────────────────

func toggle() -> void:
	visible = not visible
	if visible:
		_refresh_equipo()
		focus_first()

func on_layer_opened() -> void:
	_refresh_equipo()

func on_layer_closed() -> void:
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("equipamiento") or event.is_action_pressed("pausa"):
		visible = false
		get_viewport().set_input_as_handled()
