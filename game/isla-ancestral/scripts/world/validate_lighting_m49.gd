# Modelo: agnes-2.5-flash (original 2026-09-05) — fix de hy3 / WorkBuddy (Tencent Hunyuan) 2026-09-18
# Plataforma: Kilo Code
#
# M49: ValidateLighting — verificación automatizada del sistema de iluminación
# Valida: WorldEnvironment configurado, nodos de luz presentes, curvas data-driven,
#         shadow settings razonables, tonemap ACES.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/world/validate_lighting_m49.gd
#
# FIX hy3 (2026-09-18, Log de hy3):
#   BUG 1 — parse errors de type-inference (L39/66/77): se anotan tipos explícitos en los
#           destinos (Environment / Color / String / Array[String]) para que el `:=` no deba
#           inferir desde un Variant dinámico.
#   BUG 2 — el validador NUNCA cargaba la escena: `Engine.get_main_loop().root` está vacío
#           cuando se corre con --script, así que `_get_node_or_null` devolvía null siempre y
#           todos los checks fallaban en vacío. Ahora se carga la escena real
#           (res://scenes/main_island.tscn) con load()+instantiate() y se busca con find_child
#           recursivo, de modo que los checks reportan resultados REALES por ítem.

extends SceneTree

var _fallos: int = 0
var _advertencias: int = 0
var _escena: Node = null

func _init() -> void:
	call_deferred("_iniciar")

func _iniciar() -> void:
	# BUG 2: cargar la escena real antes de validar (sin ella, root está vacío).
	var escena_path := "res://scenes/main_island.tscn"
	if not ResourceLoader.exists(escena_path):
		push_error("ESCENA NO ENCONTRADA: " + escena_path)
		_fallos += 1
		print("FALLO: escena no encontrada " + escena_path)
		_run_fin()
		return
	var packed := load(escena_path)
	if packed == null or not (packed is PackedScene):
		push_error("No se pudo cargar PackedScene: " + escena_path)
		_fallos += 1
		print("FALLO: PackedScene nula o inválida para " + escena_path)
		_run_fin()
		return
	_escena = packed.instantiate()
	if _escena == null:
		push_error("instantiate() devolvió null para " + escena_path)
		_fallos += 1
		print("FALLO: escena no instanciada")
		_run_fin()
		return
	_run()

func _run() -> void:
	_test_world_environment()
	_test_luz_direccional()
	_test_curvas_data_driven()
	_test_ambient_minimum()
	_test_sombras()
	_run_fin()

func _run_fin() -> void:
	print("=== TEST M49 ILUMINACIÓN: %d fallo(s), %d advertencia(s) ===" % [_fallos, _advertencias])
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
	else:
		print("OK: " + msg)

func _warn(msg: String) -> void:
	_advertencias += 1
	print("ADVERTENCIA: " + msg)

## RF1: WorldEnvironment con tonemapping ACES y ambient light mínimo
func _test_world_environment() -> void:
	var world_env := _get_node_or_null("WorldEnvironment")
	_check(world_env != null, "WorldEnvironment presente en escena")
	if world_env == null:
		return
	# BUG 1 (L39): tipo explícito Environment para no inferir desde Variant dinámico.
	var env: Environment = world_env.environment
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
	# BUG 1 (L65): Array tipado para que la iteración no devuelva Variant.
	var curvas: Array[String] = ["day_curve.tres", "sky_curve.tres", "moon_curve.tres", "fog_curve.tres"]
	for curva in curvas:
		# BUG 1 (L66): tipo explícito String para la concatenación.
		var path: String = light_dir + curva
		_check(FileAccess.file_exists(path), "curva existe: %s" % curva)
		if FileAccess.file_exists(path):
			var loaded := load(path)
			_check(loaded is Curve, "%s carga como Curve" % curva)

## RF1: Ambiente cálido (color no azulado en día)
func _test_ambient_minimum() -> void:
	var world_env := _get_node_or_null("WorldEnvironment")
	if world_env == null or world_env.environment == null:
		return
	# BUG 1 (L77): tipo explícito Color para no inferir desde Variant dinámico.
	var ambient: Color = world_env.environment.ambient_light_color
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

## Helper para buscar nodos por nombre (recursivo, en la escena cargada)
func _get_node_or_null(nombre: String) -> Node:
	if _escena == null:
		return null
	return _escena.find_child(nombre, true, false)
