# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M31: Test iter. 2 — curvas data-driven (day/sky/moon) + umbrales JSON +
# enganche reset_dia de M71 con day_started.
# Complementa test_ciclo_dia_noche.gd (núcleo Log 302) — no lo reemplaza.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/world/test_curvas_luz.gd

extends SceneTree

var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_curvas_cargables()
	_test_valores_diseno()
	_test_umbrales_json()
	_test_data_driven_nucleo()
	_test_reset_dia_m71()
	print("=== TEST M31 CURVAS: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_curvas_cargables() -> void:
	var day := load("res://data/light/day_curve.tres") as Curve
	var sky := load("res://data/light/sky_curve.tres") as Curve
	var moon := load("res://data/light/moon_curve.tres") as Curve
	_check(day != null, "day_curve.tres cargable")
	_check(sky != null, "sky_curve.tres cargable")
	_check(moon != null, "moon_curve.tres cargable")

func _test_valores_diseno() -> void:
	# ⚠️ El dominio de la curva es 0-1 (fracción del día) → sample(hora/24.0)
	# §P1: sol 1.0 día pleno, 0 de noche
	var day := load("res://data/light/day_curve.tres") as Curve
	_check(absf(day.sample(12.0 / 24.0) - 1.0) < 0.01, "sol mediodía = 1.0 (§P1)")
	_check(absf(day.sample(23.0 / 24.0)) < 0.01, "sol 23:00 = 0 (§P1)")
	# §P2: luna 0.12 profunda, 0.18 noche
	var moon := load("res://data/light/moon_curve.tres") as Curve
	_check(absf(moon.sample(3.0 / 24.0) - 0.12) < 0.01, "luna profunda = 0.12 (§P2)")
	_check(absf(moon.sample(21.0 / 24.0) - 0.18) < 0.01, "luna noche = 0.18 (§P2)")
	# §P5: cielo 0.15 anti-oscuridad profunda, 1.0 día
	var sky := load("res://data/light/sky_curve.tres") as Curve
	_check(absf(sky.sample(3.0 / 24.0) - 0.15) < 0.01, "cielo profunda = 0.15 (anti-oscuridad §P5)")
	_check(absf(sky.sample(12.0 / 24.0) - 1.0) < 0.01, "cielo mediodía = 1.0 (§P5)")
	# Rampa amanecer: 6:00 entre 0 y pico (transición suave)
	var s6 := day.sample(6.0 / 24.0)
	_check(s6 > 0.0 and s6 < 1.0, "amanecer 6:00 en transición (%.2f)" % s6)

func _test_umbrales_json() -> void:
	var texto := FileAccess.get_file_as_string("res://data/light/fase_umbral.json")
	var datos: Variant = JSON.parse_string(texto)
	_check(typeof(datos) == TYPE_DICTIONARY, "fase_umbral.json parsea")
	if typeof(datos) != TYPE_DICTIONARY:
		return
	var franjas: Array = datos.get("fase_umbral", {}).get("franjas", [])
	_check(franjas.size() == 5, "5 franjas declaradas (diseño §P13)")
	var luces: Dictionary = datos.get("luces_artificiales", {})
	_check(absf(float(luces.get("umbral_encendido", 0)) - 0.35) < 0.001, "umbral luces 0.35 (§P10)")
	_check(int(luces.get("temperatura_k", 0)) == 3200, "luces 3200K (§P12)")
	var estrellas: Dictionary = datos.get("estrellas", {})
	_check(int(estrellas.get("alpha_inicio", 0)) == 20, "estrellas desde 20:00 (§P6)")

func _test_data_driven_nucleo() -> void:
	# day_night_cycle con curvas aplica valores de las curvas (no hardcode).
	# El ciclo resuelve sun/moon/env vía get_node_or_null("../X"): el test
	# monta la estructura hermana real (ciclo + nodos bajo un mismo padre).
	var ciclo: Node3D = load("res://scripts/world/day_night_cycle.gd").new()
	ciclo.name = "DayNightCycle"
	var padre := Node3D.new()
	padre.name = "AmbienteTest"
	var sun := DirectionalLight3D.new()
	sun.name = "DirectionalLight"
	var moon := DirectionalLight3D.new()
	moon.name = "DirLightLuna"
	var env := WorldEnvironment.new()
	env.name = "WorldEnvironment"
	env.environment = Environment.new()
	padre.add_child(ciclo)
	padre.add_child(sun)
	padre.add_child(moon)
	padre.add_child(env)
	root.add_child(padre)
	# mediodía con curvas: sol 1.0, cielo 1.0, luna 0
	ciclo._aplicar_iluminacion(12, false)
	_check(absf(sun.light_energy - 1.0) < 0.01, "núcleo data-driven: sol 12:00 = 1.0")
	_check(absf(env.environment.ambient_light_energy - 1.0) < 0.01, "núcleo data-driven: cielo 12:00 = 1.0")
	_check(absf(moon.light_energy) < 0.01, "núcleo data-driven: luna 12:00 = 0")
	# profunda con curvas: sol 0, cielo 0.15 (anti-oscuridad), luna 0.12
	ciclo._aplicar_iluminacion(3, false)
	_check(absf(sun.light_energy) < 0.01, "núcleo data-driven: sol 3:00 = 0")
	_check(absf(env.environment.ambient_light_energy - 0.15) < 0.01, "núcleo data-driven: cielo 3:00 = 0.15")
	_check(absf(moon.light_energy - 0.12) < 0.01, "núcleo data-driven: luna 3:00 = 0.12")
	padre.queue_free()

func _test_reset_dia_m71() -> void:
	# M71: day_started M29 → PlayerProfile.reset_dia (enganche en ProgressionManager)
	var pp := root.get_node_or_null("PlayerProfile")
	var bus := root.get_node_or_null("EventBus")
	_check(pp != null and bus != null, "PlayerProfile + EventBus presentes")
	if pp == null or bus == null:
		return
	pp.incrementar("items_recolectados", 5)
	_check(int(pp.estadisticas_dia().get("items_recolectados", 0)) == 5, "estadística del día acumulada")
	bus.calendar.day_started.emit(2, "Verano")
	_check(pp.estadisticas_dia().is_empty(), "day_started resetea estadísticas del día (M71 ↔ M29)")
	var totales: int = int(pp.get_stat("items_recolectados"))
	_check(totales >= 5, "totales NO se resetean (%d)" % totales)
