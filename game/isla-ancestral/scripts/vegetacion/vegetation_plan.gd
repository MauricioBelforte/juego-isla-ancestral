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
	var config: Dictionary = VM.cargar_config()
	var zonas := {
		"playa": _anillo(centro, radio, 0.90, 0.99),
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
	return plan

static func _anillo(centro: Vector2, radio: float, min_r: float, max_r: float) -> Array:
	return [radio * min_r, radio * max_r]

static func _pos_en_zona(anillo: Array, rng: RandomNumberGenerator, centro: Vector2) -> Vector2:
	var dist := rng.randf_range(float(anillo[0]), float(anillo[1]))
	var ang := rng.randf_range(0.0, TAU)
	return centro + Vector2(cos(ang), sin(ang)) * dist
