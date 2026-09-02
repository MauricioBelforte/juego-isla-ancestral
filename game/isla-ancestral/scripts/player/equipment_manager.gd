## Gestor central de equipamiento del jugador (M155).
## Autoload: accesible como EquipmentManager desde cualquier script.
extends Node

## Equipamiento actual del jugador.
var player_equipment: PlayerEquipment = null

## Catálogo de prendas disponibles (cargado desde .tres).
var catalog: Dictionary = {}

## Tabla de bonos por terreno (cargado desde .tres).
var terrain_bonus_table: Dictionary = {}

## Señales.
signal equipment_changed(slot_type: int, new_item_id: String)
signal terrain_bonus_updated(total_bonus: float)

func _ready() -> void:
	player_equipment = PlayerEquipment.new()
	_load_catalog()
	_load_terrain_bonus_table()

## Carga el catálogo de prendas definido en código (16 prendas iniciales).
func _load_catalog() -> void:
	catalog = {
		"feet_boots_mud": {
			"name": "Botas de barro",
			"slot": "feet",
			"terrain_bonuses": {"mud": 0.35, "grass": 0.0, "pavement": 0.0},
			"comfort_penalty": 0.0,
			"description": "Botas resistentes para terrenos embarrados",
			"rarity": "common"
		},
		"feet_skates": {
			"name": "Patines",
			"slot": "feet",
			"terrain_bonuses": {"pavement": 0.30, "mud": -0.60, "sand": -0.70},
			"comfort_penalty": 0.0,
			"description": "Rápidos en pavimento, lentos en barro y arena",
			"rarity": "uncommon"
		},
		"feet_bike": {
			"name": "Bicicleta",
			"slot": "feet",
			"terrain_bonuses": {"road": 0.20, "pavement": 0.40, "mud": -0.50},
			"comfort_penalty": 0.0,
			"description": "Eficiente en caminos y pavimento",
			"rarity": "rare"
		},
		"feet_boots_water": {
			"name": "Botas de agua",
			"slot": "feet",
			"terrain_bonuses": {"shallow_water": 0.30, "mud": 0.10, "grass": 0.0},
			"comfort_penalty": 0.0,
			"description": "Impermeables para zonas húmedas",
			"rarity": "uncommon"
		},
		"feet_sandals": {
			"name": "Sandalias",
			"slot": "feet",
			"terrain_bonuses": {"sand": 0.20, "grass": 0.05, "snow": -0.15},
			"comfort_penalty": 0.0,
			"description": "Ligeras y frescas para arena",
			"rarity": "common"
		},
		"feet_boots_winter": {
			"name": "Botas de invierno",
			"slot": "feet",
			"terrain_bonuses": {"snow": 0.20, "ice": 0.15, "mud": 0.05},
			"comfort_penalty": 0.0,
			"description": "Aislantes para climas fríos",
			"rarity": "uncommon"
		},
		"head_hat_fisher": {
			"name": "Sombrero de pescador",
			"slot": "head",
			"terrain_bonuses": {},
			"comfort_penalty": -0.10,
			"description": "Reduce malestar en lluvia",
			"rarity": "common"
		},
		"head_helm_explorer": {
			"name": "Casco de explorador",
			"slot": "head",
			"terrain_bonuses": {},
			"comfort_penalty": 0.0,
			"description": "Protección ligera para exploración",
			"rarity": "uncommon"
		},
		"head_scarf_warm": {
			"name": "Bufanda de lana",
			"slot": "head",
			"terrain_bonuses": {},
			"comfort_penalty": 0.15,
			"description": "Aumenta comodidad en frío",
			"rarity": "common"
		},
		"body_coat_rain": {
			"name": "Capa impermeable",
			"slot": "body",
			"terrain_bonuses": {},
			"comfort_penalty": 0.25,
			"description": "+25% comodidad en lluvia",
			"rarity": "uncommon"
		},
		"body_shirt_casual": {
			"name": "Camisa casual",
			"slot": "body",
			"terrain_bonuses": {},
			"comfort_penalty": 0.0,
			"description": "Ropa básica sin bonos",
			"rarity": "common"
		},
		"acc_lantern": {
			"name": "Linterna",
			"slot": "accessory",
			"terrain_bonuses": {},
			"comfort_penalty": 0.0,
			"description": "+20% visibilidad en cuevas",
			"rarity": "common"
		},
		"acc_compass": {
			"name": "Brújula",
			"slot": "accessory",
			"terrain_bonuses": {},
			"comfort_penalty": 0.0,
			"description": "Muestra dirección en el HUD",
			"rarity": "common"
		},
		"acc_amulet_ancestral": {
			"name": "Amuleto ancestral",
			"slot": "accessory",
			"terrain_bonuses": {"grass": 0.10, "mountain": 0.10, "snow": 0.10},
			"comfort_penalty": 0.0,
			"description": "+10% en todos los terrenos",
			"rarity": "legendary",
			"unlock": {"tipo": "chapter", "valor": "3"}
		},
		"body_vest_explorer": {
			"name": "Chaleco explorador",
			"slot": "body",
			"terrain_bonuses": {},
			"comfort_penalty": 0.0,
			"description": "+10% capacidad de inventario (M14)",
			"rarity": "rare",
			"unlock": {"tipo": "flag", "valor": "mochila_mejorada"}
		},
		"acc_backpack": {
			"name": "Mochila",
			"slot": "accessory",
			"terrain_bonuses": {},
			"comfort_penalty": 0.0,
			"description": "+5 slots de inventario (M14)",
			"rarity": "uncommon",
			"unlock": {"tipo": "none", "valor": ""}
		}
	}
	print("[EquipmentManager] Catálogo cargado: %d prendas" % catalog.size())

## Carga la tabla de bonos por terreno definida en código.
func _load_terrain_bonus_table() -> void:
	terrain_bonus_table = {
		"grass": {
			"feet_boots_mud": 0.0, "feet_skates": 0.90, "feet_bike": 1.20,
			"feet_boots_water": 0.0, "feet_sandals": 1.05, "feet_boots_winter": 0.75
		},
		"mud": {
			"feet_boots_mud": 0.95, "feet_skates": 0.40, "feet_bike": 0.50,
			"feet_boots_water": 0.70, "feet_sandals": 0.55, "feet_boots_winter": 0.85
		},
		"pavement": {
			"feet_boots_mud": 0.0, "feet_skates": 1.30, "feet_bike": 1.40,
			"feet_boots_water": 0.0, "feet_sandals": 1.00, "feet_boots_winter": 0.90
		},
		"sand": {
			"feet_boots_mud": 0.80, "feet_skates": 0.30, "feet_bike": 0.60,
			"feet_boots_water": 0.75, "feet_sandals": 1.20, "feet_boots_winter": 0.60
		},
		"shallow_water": {
			"feet_boots_mud": 0.60, "feet_skates": 0.0, "feet_bike": 0.0,
			"feet_boots_water": 1.30, "feet_sandals": 0.40, "feet_boots_winter": 0.75
		},
		"snow": {
			"feet_boots_mud": 0.85, "feet_skates": 0.50, "feet_bike": 0.70,
			"feet_boots_water": 0.75, "feet_sandals": 0.60, "feet_boots_winter": 1.20
		},
		"rock": {
			"feet_boots_mud": 0.90, "feet_skates": 0.80, "feet_bike": 0.0,
			"feet_boots_water": 0.90, "feet_sandals": 0.85, "feet_boots_winter": 0.90
		}
	}
	print("[EquipmentManager] Tabla de bonos por terrain cargada")

## Equipa una prenda en el slot correspondiente.
## Devuelve true si se equipó correctamente.
func equip_item(item_id: String, slot_type: EquipmentSlot.SlotType) -> bool:
	if not _is_item_in_catalog(item_id):
		print("[EquipmentManager] ERROR: item_id %s no está en el catálogo" % item_id)
		return false

	var item_data: Dictionary = catalog[item_id]
	var required_slot: EquipmentSlot.SlotType = _get_slot_type_from_id(item_id)
	if required_slot != slot_type:
		print("[EquipmentManager] ERROR: %s no pertenece a slot %s" % [item_id, slot_type])
		return false

	var slot: EquipmentSlot = player_equipment.get_slot(slot_type)
	if slot == null:
		slot = EquipmentSlot.new()
		player_equipment.set_slot(slot_type, slot)

	var previous_item_id: String = slot.item_id
	slot.item_id = item_id
	slot.item_name = item_data.get("name", item_id)
	slot.terrain_bonuses = item_data.get("terrain_bonuses", {})
	slot.comfort_penalty = float(item_data.get("comfort_penalty", 0.0))
	slot.description = item_data.get("description", "")
	slot.rarity = item_data.get("rarity", "common")

	equipment_changed.emit(slot_type, item_id)
	_emit_terrain_bonus_update()
	print("[EquipmentManager] Equipado: %s en slot %s" % [item_id, slot_type])
	return true

## Desequipa un slot y devuelve el item_id anterior (para devolver al inventario).
func unequip_slot(slot_type: EquipmentSlot.SlotType) -> String:
	var slot: EquipmentSlot = player_equipment.get_slot(slot_type)
	if slot == null or not slot.is_equipped():
		return ""
	var previous_item_id: String = slot.item_id
	slot.clear()
	equipment_changed.emit(slot_type, "")
	_emit_terrain_bonus_update()
	print("[EquipmentManager] Desequipado slot %s, item %s devuelto al inventario" % [slot_type, previous_item_id])
	return previous_item_id

## Obtiene el item equipado en un slot.
func get_equipped_item(slot_type: EquipmentSlot.SlotType) -> EquipmentSlot:
	return player_equipment.get_slot(slot_type)

## Verifica si un item está equipado en cualquier slot.
func is_item_equipped(item_id: String) -> bool:
	return player_equipment.is_item_equipped(item_id)

## Calcula el bono total de velocidad para un terreno.
func get_terrain_bonus(terrain_type: String) -> float:
	if player_equipment == null:
		return 0.0
	return player_equipment.get_total_terrain_bonus(terrain_type)

## Obtiene la penalización de comodidad para un terreno.
func get_comfort_penalty(terrain_type: String) -> float:
	if player_equipment == null:
		return 0.0
	return player_equipment.get_comfort_penalty(terrain_type)

## Emite la señal de actualización de bonus de terreno.
func _emit_terrain_bonus_update() -> void:
	var total_bonus: float = 0.0
	if player_equipment:
		total_bonus = player_equipment.get_total_terrain_bonus("current")
	terrain_bonus_updated.emit(total_bonus)

## Verifica si un item está en el catálogo.
func _is_item_in_catalog(item_id: String) -> bool:
	return catalog.has(item_id)

## Obtiene el slot_type correspondiente a un item_id.
func _get_slot_type_from_id(item_id: String) -> EquipmentSlot.SlotType:
	if not catalog.has(item_id):
		return EquipmentSlot.SlotType.ACCESSORY
	var item_data: Dictionary = catalog[item_id]
	var slot_str: String = item_data.get("slot", "accessory")
	match slot_str.to_lower():
		"head":
			return EquipmentSlot.SlotType.HEAD
		"body":
			return EquipmentSlot.SlotType.BODY
		"feet":
			return EquipmentSlot.SlotType.FEET
		_:
			return EquipmentSlot.SlotType.ACCESSORY

## Verifica si un item está desbloqueado para el jugador.
func is_item_unlocked(item_id: String, player_state: Dictionary) -> bool:
	if not catalog.has(item_id):
		return false
	var item_data: Dictionary = catalog[item_id]
	if not item_data.has("unlock"):
		return true
	var unlock_data: Dictionary = item_data["unlock"]
	var condition = UnlockCondition.new()
	condition.tipo = unlock_data.get("tipo", "none")
	condition.valor = unlock_data.get("valor", "")
	return condition.is_unlocked(player_state)

## Serializa el equipamiento a Dictionary para guardado (M59).
func to_dict() -> Dictionary:
	if player_equipment:
		return player_equipment.to_dict()
	return {}

## Deserializa el equipamiento desde Dictionary (M59).
func from_dict(data: Dictionary) -> void:
	if player_equipment:
		player_equipment.from_dict(data)
		_emit_terrain_bonus_update()

## Obtiene los items desbloqueados del catálogo.
func get_unlocked_items(player_state: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for item_id in catalog.keys():
		if is_item_unlocked(item_id, player_state):
			result.append(item_id)
	return result
