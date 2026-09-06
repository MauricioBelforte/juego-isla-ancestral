# Modelo: agnes-2.5-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-05
#
# M49: ValidateLighting — verificación automatizada del sistema de iluminación
# Valida: WorldEnvironment configurado, nodos de luz presentes, curvas data-driven,
#         shadow settings razonables, tonemap ACES.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/world/validate_lighting_m49.gd

extends SceneTree

var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_world_environment()
	_test_luz_direccional()
	_test_curvas_data_driven()
	_test_ambient_minimum()
	_test_sombras()
	print("=== TEST M49 ILUMINACIÓN: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
	else:
		print("OK: " + msg)

## RF1: WorldEnvironment con tonemapping ACES y ambient light mínimo
func _test_world_environment() -> void:
	var world_env := _get_node_or_null("WorldEnvironment")
	_check(world_env != null, "WorldEnvironment presente en escena")
	if world_env == null:
		return
	var env := world_env.environment
	_check(env != null, "environment resource asignado")
	if env != null:
		# Tonemap ACES (mode 3 = ACES)
		_check(int(env.tonemap_mode) == 3, "tonemap_mode = ACES (3): %d" % int(env.tonemap_mode))
		# Ambient light energy >= 0.15 (anti-oscuridad)
		_check(float(env.ambient_light_energy) >= 0.15, "ambient_light_energy >= 0.15: %.2f" % float(env.ambient_light_energy))
		# Fog debe estar presente (M49 §fog)
		_check(bool(env.fog_enabled), "fog habilitado en environment")

## RF1+RF2: Nodos de luz direccional presentes (sol y luna)
func _test_luz_direccional() -> void:
	var sun := _get_node_or_null("DirectionalLight")
	var moon := _get_node_or_null("DirLightLuna")
	_check(sun != null, "DirectionalLight (sol) presente")
	_check(moon != null, "DirLightLuna presente")
	if sun != null:
		_check(float(sun.light_energy) > 0.0, "sol con energy > 0: %.2f" % float(sun.light_energy))
		_check(bool(sun.shadow_enabled), "sombras del sol habilitadas")
	if moon != null:
		_check(float(moon.light_energy) >= 0.0, "luna con energy >= 0: %.2f" % float(moon.light_energy))

## RF1: Curvas data-driven existen
func _test_curvas_data_driven() -> void:
	var light_dir := "res://data/light/"
	var curvas := ["day_curve.tres", "sky_curve.tres", "moon_curve.tres", "fog_curve.tres"]
	for curva in curvas:
		var path := light_dir + curva
		_check(FileAccess.file_exists(path), "curva existe: %s" % curva)
		if FileAccess.file_exists(path):
			var loaded := load(path)
			_check(loaded is Curve, "%s carga como Curve" % curva)

## RF1: Ambiente cálido (color no azulado en día)
func _test_ambient_minimum() -> void:
	var world_env := _get_node_or_null("WorldEnvironment")
	if world_env == null or world_env.environment == null:
		return
	var ambient := world_env.environment.ambient_light_color
	# El color ambiental debe tener más rojo que azul (cálido/cozy)
	_check(ambient.r > ambient.b or ambient.g > ambient.b, "ambient cálido: R=%.2f G=%.2f B=%.2f" % [ambient.r, ambient.g, ambient.b])

## RF2: Sombras configuradas correctamente
func _test_sombras() -> void:
	var sun := _get_node_or_null("DirectionalLight")
	if sun == null:
		return
	# Shadow bias razonable (no muy alto para evitar artefactos)
	_check(float(sun.shadow_bias) <= 0.1, "shadow_bias <= 0.1: %.3f" % float(sun.shadow_bias))
	# Shadow normal bias para reducir acne
	_check(float(sun.shadow_normal_bias) >= 1.0, "shadow_normal_bias >= 1.0: %.1f" % float(sun.shadow_normal_bias))
	# Max distance razonable para voxel world
	_check(int(sun.directional_shadow_max_distance) <= 200, "shadow max_distance <= 200: %d" % int(sun.directional_shadow_max_distance))

## Helper para buscar nodos por nombre
func _get_node_or_null(nombre: String) -> Node:
	return Engine.get_main_loop().root.get_node_or_null(nombre)
