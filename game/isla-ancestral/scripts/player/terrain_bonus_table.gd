## Tabla de bonos por terreno para el sistema de equipamiento (M155).
class_name TerrainBonusTable
extends Resource

## Diccionario de bonos por terreno: { terrain_type: { item_id: bonus_float } }
@export var bonuses: Dictionary = {}

## Obtiene el bono para un item en un terreno específico.
func get_bonus(terrain_type: String, item_id: String) -> float:
	if bonuses.has(terrain_type):
		var terrain_bonuses: Dictionary = bonuses[terrain_type]
		if terrain_bonuses.has(item_id):
			return float(terrain_bonuses[item_id])
	return 0.0

## Obtiene todos los bonos para un terreno.
func get_all_bonuses_for_terrain(terrain_type: String) -> Dictionary:
	if bonuses.has(terrain_type):
		return bonuses[terrain_type]
	return {}
