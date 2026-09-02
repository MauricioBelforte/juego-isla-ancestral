extends RefCounted
class_name TerrainModifiers

static func calculate_effective_speed(base_speed: float, terrain_modifier: float, equipment_bonus: float) -> float:
	var speed := base_speed
	speed *= terrain_modifier
	speed += equipment_bonus
	if speed < 0.0:
		speed = 0.0
	return speed
