# Genera .tres canónicos de las curvas M31.
# ⚠️ Curve.add_point espera Vector2 y el DOMINIO de posición es 0..1 (curva
# normalizada, NO un eje de horas). El consumidor samplea con hora/24.0.
# Descubrimiento documentado en 07-GUIA-GODOT §9.60.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/world/gen_curvas.gd
extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_day_curve()
	_sky_curve()
	_moon_curve()
	_fog_curve()
	print("=== CURVAS GENERADAS ===")
	quit(0)

func _guardar(curva: Curve, ruta: String) -> void:
	var err := ResourceSaver.save(curva, ruta)
	print("%s -> err=%d" % [ruta, err])

## Convierte puntos (hora, valor) a dominio normalizado 0-1
func _agregar(c: Curve, puntos: Array) -> void:
	for p in puntos:
		var hora: float = float(p.x)
		c.add_point(Vector2(hora / 24.0, float(p.y)))

func _day_curve() -> void:
	var c := Curve.new()
	c.min_value = 0.0
	c.max_value = 1.0
	_agregar(c, [Vector2(0, 0), Vector2(5, 0), Vector2(6, 0.5), Vector2(7, 1), Vector2(17, 1), Vector2(18, 0.5), Vector2(19, 0.2), Vector2(20, 0), Vector2(24, 0)])
	_guardar(c, "res://data/light/day_curve.tres")

func _sky_curve() -> void:
	var c := Curve.new()
	c.min_value = 0.0
	c.max_value = 1.0
	_agregar(c, [Vector2(0, 0.15), Vector2(5, 0.15), Vector2(6, 0.6), Vector2(7, 1), Vector2(17, 1), Vector2(18, 0.6), Vector2(19, 0.4), Vector2(20, 0.22), Vector2(21, 0.15), Vector2(24, 0.15)])
	_guardar(c, "res://data/light/sky_curve.tres")

func _moon_curve() -> void:
	var c := Curve.new()
	c.min_value = 0.0
	c.max_value = 1.0
	_agregar(c, [Vector2(0, 0.12), Vector2(5, 0.12), Vector2(6, 0.05), Vector2(7, 0), Vector2(17, 0), Vector2(18, 0.05), Vector2(20, 0.15), Vector2(21, 0.18), Vector2(24, 0.12)])
	_guardar(c, "res://data/light/moon_curve.tres")

func _fog_curve() -> void:
	var c := Curve.new()
	c.min_value = 0.0
	c.max_value = 2.0
	_agregar(c, [Vector2(0, 0.9), Vector2(5, 1.1), Vector2(7, 1.2), Vector2(12, 0.5), Vector2(17, 1), Vector2(19, 1.3), Vector2(24, 0.9)])
	_guardar(c, "res://data/light/fog_curve.tres")
