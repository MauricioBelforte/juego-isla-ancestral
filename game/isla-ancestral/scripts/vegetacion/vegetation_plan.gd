# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M50 iter 3: Plan completo de vegetación determinista para la isla.
# Genera la lista de instancias (tipo, posición, rotación) por bioma con la
# misma semilla del mundo (42); el mundo (M08) la consume para poblar.
class_name VegetationPlan
extends RefCounted

const VM = preload("res://scripts/vegetacion/vegetation_manager.gd")

static func generar_plan(centro: Vector2, radio: float, semilla: int = 42) -> Array:
	var plan := []
	# BUG-020 fix: playa limitada a 0.90-0.93 para no sobrepasar la linea de
	# costa (el agua CLARA empieza en dist > 0.94 segun island_generator.gd).
	var zonas := {
		"playa": _anillo(centro, radio, 0.85, 0.93),
		"montana": _anillo(centro, radio, 0.35, 0.80),
		"pradera": _anillo(centro, radio, 0.55, 0.85),
		"bosque": _anillo(centro, radio, 0.45, 0.80),
		"ribera": _anillo(centro, radio, 0.80, 0.90),
	}
	var rng := RandomNumberGenerator.new()
	rng.seed = semilla
	for bioma in zonas:
		var tipos: Array = VM.tipos_para_bioma(bioma)
		if tipos.is_empty():
			continue
		var densidad: int = VM.densidad(bioma)
		for i in range(densidad):
			var pos := _pos_en_zona(zonas[bioma], rng, centro)
			var tipo: String = String(tipos[rng.randi_range(0, tipos.size() - 1)])
			plan.append({
				"bioma": bioma,
				"tipo": tipo,
				"posicion": {"x": pos.x, "z": pos.y},
				"rotacion_y": rng.randf_range(0.0, TAU),
				"seed_item": semilla + i,
			})
	# Iter. 6 (Log 644): vegetación alrededor del SPAWN del jugador (320,320)
	# para que sea visible desde el primer frame. Radio 40m, 25 instancias.
	# Iter. contenido 3 (Log 646): mix con árboles para referencia de escala.
	var tipos_c := [
		"50-Vegetacion_hierba_alta", "50-Vegetacion_hierba_alta",
		"50-Vegetacion_flor_isla", "50-Vegetacion_flor_isla",
		"50-Vegetacion_arbusto_redondo",
		"50-Vegetacion_helecho_chico",
		"50-Vegetacion_arbol_frutal",
		"50-Vegetacion_palmera_joven",
	]
	if not tipos_c.is_empty():
		var rng_spawn := RandomNumberGenerator.new()
		rng_spawn.seed = semilla + 999  # distinto seed para variedad
		var spawn_pos := Vector2(320, 320)
		for i in range(25):
			var ang := rng_spawn.randf_range(0.0, TAU)
			var dist := rng_spawn.randf_range(3.0, 40.0)
			var pos := spawn_pos + Vector2(cos(ang), sin(ang)) * dist
			var tipo: String = String(tipos_c[rng_spawn.randi_range(0, tipos_c.size() - 1)])
			plan.append({
				"bioma": "cercanias_spawn",
				"tipo": tipo,
				"posicion": {"x": pos.x, "z": pos.y},
				"rotacion_y": rng_spawn.randf_range(0.0, TAU),
				"seed_item": semilla + 999 + i,
			})
	return plan

static func _anillo(_centro: Vector2, radio: float, min_r: float, max_r: float) -> Array:
	return [radio * min_r, radio * max_r]

static func _pos_en_zona(anillo: Array, rng: RandomNumberGenerator, centro: Vector2) -> Vector2:
	var dist := rng.randf_range(float(anillo[0]), float(anillo[1]))
	var ang := rng.randf_range(0.0, TAU)
	return centro + Vector2(cos(ang), sin(ang)) * dist
