## Equipamiento completo del jugador (4 slots).
class_name PlayerEquipment
extends Resource

## Slots de equipamiento.
@export var head: EquipmentSlot = null
@export var body: EquipmentSlot = null
@export var feet: EquipmentSlot = null
@export var accessory: EquipmentSlot = null

## Array de accesorios adicionales (máximo 4).
@export var accessories: Array[EquipmentSlot] = []

## Obtiene el slot por tipo.
func get_slot(slot_type: EquipmentSlot.SlotType) -> EquipmentSlot:
	match slot_type:
		EquipmentSlot.SlotType.HEAD:
			return head
		EquipmentSlot.SlotType.BODY:
			return body
		EquipmentSlot.SlotType.FEET:
			return feet
		EquipmentSlot.SlotType.ACCESSORY:
			return accessory
	return null

## Establece un slot por tipo.
func set_slot(slot_type: EquipmentSlot.SlotType, slot: EquipmentSlot) -> void:
	match slot_type:
		EquipmentSlot.SlotType.HEAD:
			head = slot
		EquipmentSlot.SlotType.BODY:
			body = slot
		EquipmentSlot.SlotType.FEET:
			feet = slot
		EquipmentSlot.SlotType.ACCESSORY:
			accessory = slot

## Calcula el bono total de velocidad para un terreno.
func get_total_terrain_bonus(terrain_type: String) -> float:
	var bonus: float = 0.0
	var all_slots: Array[EquipmentSlot] = [head, body, feet, accessory]
	for slot in all_slots:
		if slot and slot.is_equipped():
			bonus += slot.get_terrain_bonus(terrain_type)
	for slot in accessories:
		if slot and slot.is_equipped():
			bonus += slot.get_terrain_bonus(terrain_type)
	return clamp(bonus, -0.15, 0.40)

## Calcula la penalización de comodidad total.
func get_comfort_penalty(terrain_type: String) -> float:
	var penalty: float = 0.0
	var all_slots: Array[EquipmentSlot] = [head, body, feet, accessory]
	for slot in all_slots:
		if slot and slot.is_equipped() and slot.comfort_penalty < 0:
			penalty += slot.comfort_penalty
	for slot in accessories:
		if slot and slot.is_equipped() and slot.comfort_penalty < 0:
			penalty += slot.comfort_penalty
	return clamp(penalty, -0.15, 0.0)

## Obtiene todos los slots ocupados.
func get_equipped_slots() -> Array[EquipmentSlot]:
	var result: Array[EquipmentSlot] = []
	var all_slots: Array[EquipmentSlot] = [head, body, feet, accessory]
	for slot in all_slots:
		if slot and slot.is_equipped():
			result.append(slot)
	result.append_array(accessories)
	return result

## Verifica si un item está equipado en algún slot.
func is_item_equipped(item_id: String) -> bool:
	var all_slots: Array[EquipmentSlot] = [head, body, feet, accessory]
	for slot in all_slots:
		if slot and slot.is_equipped() and slot.item_id == item_id:
			return true
	for slot in accessories:
		if slot and slot.is_equipped() and slot.item_id == item_id:
			return true
	return false

## Serializa a Dictionary para guardado.
func to_dict() -> Dictionary:
	var data: Dictionary = {}
	data["head"] = _slot_to_dict(head)
	data["body"] = _slot_to_dict(body)
	data["feet"] = _slot_to_dict(feet)
	data["accessory"] = _slot_to_dict(accessory)
	data["accessories"] = []
	for slot in accessories:
		data["accessories"].append(_slot_to_dict(slot))
	return data

## Deserializa desde Dictionary.
func from_dict(data: Dictionary) -> void:
	if data.has("head"):
		head = _dict_to_slot(data["head"])
	if data.has("body"):
		body = _dict_to_slot(data["body"])
	if data.has("feet"):
		feet = _dict_to_slot(data["feet"])
	if data.has("accessory"):
		accessory = _dict_to_slot(data["accessory"])
	accessories.clear()
	if data.has("accessories"):
		for slot_data in data["accessories"]:
			accessories.append(_dict_to_slot(slot_data))

## Limpia todos los slots.
func clear_all() -> void:
	if head:
		head.clear()
	if body:
		body.clear()
	if feet:
		feet.clear()
	if accessory:
		accessory.clear()
	for slot in accessories:
		slot.clear()
	accessories.clear()

func _slot_to_dict(slot: EquipmentSlot) -> Dictionary:
	if slot == null or not slot.is_equipped():
		return {}
	return {
		"slot_type": slot.slot_type,
		"item_id": slot.item_id,
		"item_name": slot.item_name,
		"terrain_bonuses": slot.terrain_bonuses,
		"comfort_penalty": slot.comfort_penalty,
		"description": slot.description,
		"rarity": slot.rarity
	}

func _dict_to_slot(d: Dictionary) -> EquipmentSlot:
	if d.is_empty():
		return null
	var slot = EquipmentSlot.new()
	slot.slot_type = d.get("slot_type", EquipmentSlot.SlotType.ACCESSORY)
	slot.item_id = d.get("item_id", "")
	slot.item_name = d.get("item_name", "")
	slot.terrain_bonuses = d.get("terrain_bonuses", {})
	slot.comfort_penalty = float(d.get("comfort_penalty", 0.0))
	slot.description = d.get("description", "")
	slot.rarity = d.get("rarity", "common")
	return slot
