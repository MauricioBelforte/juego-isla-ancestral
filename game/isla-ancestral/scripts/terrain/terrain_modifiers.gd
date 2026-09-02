extends RefCounted
# ⚠️ RENOMBRADA (2026-09-02, deepseek-v4-flash-vision-exp): la clase global
# 'TerrainModifiers' colisionaba con la vigente del módulo M156
# (scripts/terrenos/terrain_modifiers.gd, clase del sistema de terrenos).
# Nadie usa esta variante (el único consumidor era el test M156, que usa la
# vigente) — se conserva aquí como heredada del paquete del mundo.
class_name TerrainModifiersLegacy

static func calculate_effective_speed(base_speed: float, terrain_modifier: float, equipment_bonus: float) -> float:
	var speed := base_speed
	speed *= terrain_modifier
	speed += equipment_bonus
	if speed < 0.0:
		speed = 0.0
	return speed
