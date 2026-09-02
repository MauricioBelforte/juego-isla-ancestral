## UI de equipamiento del jugador (M155).
## Muestra los 4 slots y permite equipar/des-equipar prendas.
extends CanvasLayer

## Referencia al EquipmentManager autoload.
var equipment_manager: Node = null

## Nodos UI.
var _head_slot: Control = null
var _body_slot: Control = null
var _feet_slot: Control = null
var _accessory_slot: Control = null

## Tooltip service (M53).
var _tooltip_service: Node = null

func _ready() -> void:
    equipment_manager = get_node_or_null("/root/EquipmentManager")
    _tooltip_service = get_node_or_null("/root/TooltipService")
    _setup_slots()
    _connect_signals()
    _refresh_all_slots()

func _setup_slots() -> void:
    _head_slot = $Panel/VBox/HeadSlot
    _body_slot = $Panel/VBox/BodySlot
    _feet_slot = $Panel/VBox/FeetSlot
    _accessory_slot = $Panel/VBox/AccessorySlot

func _connect_signals() -> void:
    if equipment_manager:
        equipment_manager.equipment_changed.connect(_on_equipment_changed)
        equipment_manager.terrain_bonus_updated.connect(_on_terrain_bonus_updated)

func _refresh_all_slots() -> void:
    if equipment_manager:
        _refresh_slot(_head_slot, EquipmentSlot.SlotType.HEAD)
        _refresh_slot(_body_slot, EquipmentSlot.SlotType.BODY)
        _refresh_slot(_feet_slot, EquipmentSlot.SlotType.FEET)
        _refresh_slot(_accessory_slot, EquipmentSlot.SlotType.ACCESSORY)

func _refresh_slot(slot_control: Control, slot_type: EquipmentSlot.SlotType) -> void:
    if not equipment_manager or not slot_control:
        return
    var slot: EquipmentSlot = equipment_manager.get_equipped_item(slot_type)
    if slot and slot.is_equipped():
        slot_control.get_node("Icon").texture = null
        slot_control.get_node("Label").text = slot.item_name
        slot_control.get_node("Rarity").visible = true
        slot_control.get_node("Rarity").text = slot.rarity
    else:
        slot_control.get_node("Label").text = "Vacío"
        slot_control.get_node("Rarity").visible = false

func _on_equipment_changed(slot_type: int, new_item_id: String) -> void:
    var slot_control: Control = _get_slot_control(slot_type)
    if slot_control:
        _refresh_slot(slot_control, slot_type)

func _on_terrain_bonus_updated(total_bonus: float) -> void:
    var bonus_label: Label = $Panel/VBox/BonusLabel
    if bonus_label:
        bonus_label.text = "Bono terreno: +%.0f%%" % (total_bonus * 100.0)

func _get_slot_control(slot_type: int) -> Control:
    match slot_type:
        EquipmentSlot.SlotType.HEAD:
            return _head_slot
        EquipmentSlot.SlotType.BODY:
            return _body_slot
        EquipmentSlot.SlotType.FEET:
            return _feet_slot
        EquipmentSlot.SlotType.ACCESSORY:
            return _accessory_slot
    return null

func _on_slot_clicked(slot_type: int) -> void:
    if not equipment_manager:
        return
    var slot: EquipmentSlot = equipment_manager.get_equipped_item(slot_type)
    if slot and slot.is_equipped():
        equipment_manager.unequip_slot(slot_type)
    else:
        _show_equip_menu(slot_type)

func _show_equip_menu(slot_type: int) -> void:
    if not equipment_manager:
        return
    var catalog: Dictionary = equipment_manager.catalog
    var options: Array[String] = []
    for item_id in catalog.keys():
        if catalog[item_id].get("slot", "").to_lower() == _slot_type_to_string(slot_type):
            options.append(item_id)
    # TODO: mostrar menú de selección (M53 UI)
    print("[EquipmentUI] Items disponibles para slot %s: %s" % [_slot_type_to_string(slot_type), options])

func _slot_type_to_string(slot_type: int) -> String:
    match slot_type:
        EquipmentSlot.SlotType.HEAD:
            return "head"
        EquipmentSlot.SlotType.BODY:
            return "body"
        EquipmentSlot.SlotType.FEET:
            return "feet"
        EquipmentSlot.SlotType.ACCESSORY:
            return "accessory"
    return "accessory"
