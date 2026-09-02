## Datos de un slot de equipamiento individual.
class_name EquipmentSlot
extends Resource

enum SlotType { HEAD, BODY, FEET, ACCESSORY }

## Tipo de slot (cabeza, cuerpo, pies, accesorio).
@export var slot_type: SlotType = SlotType.ACCESSORY

## ID del item equipado (referencia a ItemData.id de M159).
@export var item_id: String = ""

## Nombre localizable de la prenda.
@export var item_name: String = ""

## Mesh voxel opcional para renderizar en el personaje (M45).
@export var cosmetic_mesh: Mesh = null

## Bonos por terreno: { "terrain_type": bonus_float }.
@export var terrain_bonuses: Dictionary = {}

## Penalización de comodidad (negativo) si se usa en terreno no adecuado.
@export var comfort_penalty: float = 0.0

## Descripción localizable.
@export var description: String = ""

## Rareza (common, uncommon, rare, legendary).
@export var rarity: String = "common"

## Verifica si este slot tiene algo equipado.
func is_equipped() -> bool:
	return item_id != ""

## Devuelve el bono para un terreno específico.
func get_terrain_bonus(terrain_type: String) -> float:
	if terrain_type in terrain_bonuses:
		return float(terrain_bonuses[terrain_type])
	return 0.0

## Vacía el slot.
func clear() -> void:
	item_id = ""
	item_name = ""
	cosmetic_mesh = null
	terrain_bonuses.clear()
	comfort_penalty = 0.0
	description = ""
	rarity = "common"
