# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M156: Terrenos — TerrainModifiers (estático, diseño §1.4).
# Cálculos de velocidad efectiva puros (sin estado): testable unitario.
class_name TerrainModifiers
extends RefCounted

## Velocidad efectiva = base × terreno × (1 + equipo). Cap de equipo 50% (§3.1)
static func calculate_effective_speed(base_speed: float, terrain_modifier: float, equipment_bonus: float) -> float:
	var bonus := clampf(equipment_bonus, 0.0, 0.5)
	return base_speed * maxf(terrain_modifier, 0.1) * (1.0 + bonus)


## Modificador desde el provider (desconocido → 1.0, §10.2)
static func get_terrain_modifier(provider: Node, terrain_id: int) -> float:
	if provider != null and provider.has_method("get_speed_modifier"):
		return float(provider.get_speed_modifier(terrain_id))
	return 1.0


## Bonificación de equipación desde M155 (0.0 si no está, §3.1)
static func get_equipment_bonus(equipment_system: Node, terrain_id: int) -> float:
	if equipment_system != null and equipment_system.has_method("get_terrain_bonus"):
		return float(equipment_system.get_terrain_bonus(terrain_id))
	return 0.0
