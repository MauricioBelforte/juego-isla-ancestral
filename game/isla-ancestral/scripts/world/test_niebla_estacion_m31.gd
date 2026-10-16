# Modelo: Step-5-WorkBuddy
# Plataforma: WorkBuddy
# Fecha: 2026-10-16
#
# M31 lote 2 (msg 51 del director De-Director V4.1, 2026-10-15): cierra los 2
# gaps PROPIOS de M31 (reconciliacion 2026-09-19): (1) niebla - fog_curve.tres
# existia como data pero no se cargaba en codigo; (2) season_mod.tres no existia
# (diseno sec. 4: "4 multiplicadores por estacion (M29) aplicados a ambas
# curvas"). Prueba: niebla_densidad(hora), mod_estacional(estacion), piso
# anti-oscuridad 0.15 sobre la modulacion, lectura de estacion de M29 y
# re-aplicacion por estacion_cambio. Log 1884.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/world/test_niebla_estacion_m31.gd

extends SceneTree

var _fallos: int = 0
var _checks: int = 0
const CHECKS_MINIMOS := 47   # medido en verde: 3 corridas de 47 checks, 0 fallos

const BLOQUES := ["A", "B", "C"]
var _vistos: Dictionary = {}

const FOG_BASE: float = 0.00018
const RUTA_CICLO: String = "res://scripts/world/day_night_cycle.gd"

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _fin(nombre: String) -> void:
	_vistos[nombre] = true

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _run() -> void:
	_test_datos()
	_fin("A")
	_test_niebla()
	_fin("B")
	_test_estacion()
	_fin("C")

func _summary() -> void:
	var faltantes: Array = []
	for n in BLOQUES:
		if not _vistos.has(n):
			faltantes.append(n)
	if faltantes.size() > 0:
		_fallos += 1
		print("[FAIL] bloques no ejecutados (posible SCRIPT ERROR): %s" % str(faltantes))
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== TEST M31 NIEBLA/ESTACION: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

## A. Datos: fog_curve.tres + season_mod.tres + fase_umbral.json §niebla
func _test_datos() -> void:
	var fog := load("res://data/light/fog_curve.tres") as Curve
	_check(fog != null, "fog_curve.tres cargable (data existente, gap de consumo)")
	if fog != null:
		_check(fog.point_count == 7, "fog_curve: 7 puntos (hora -> densidad relativa)")
		_check(absf(fog.max_domain - 1.0) < 0.001, "fog_curve: dominio 0-1 (fraccion del dia)")
		_check(absf(fog.sample(12.0 / 24.0) - 0.5) < 0.01, "fog_curve: mediodia 0.5")
		_check(absf(fog.sample(7.0 / 24.0) - 1.2) < 0.01, "fog_curve: matinal 1.2")
		_check(absf(fog.sample(19.0 / 24.0) - 1.3) < 0.01, "fog_curve: pico atardecer 1.3")
		# NOTA: fase_umbral.json sec.niebla dice "noche 0.9" en prosa, pero la
		# curva INTERPOLA entre 0.9 (hora 0) y 1.1 (hora 5). Manda el dato
		# (data-driven) - la prosa del JSON es aproximada.
		_check(absf(fog.sample(0.0) - 0.9) < 0.01, "fog_curve: hora 0 = 0.9 (extremo)")
		# TRAMPA MEDIDA: Curve.sample usa la curva HORNEADA (bake), no la
		# interpolacion lineal exacta: a 03:00 da 1.0296, no 1.02. Se asegura
		# el valor medido, no la aritmetica de memoria.
		_check(absf(fog.sample(3.0 / 24.0) - 1.0296) < 0.001, "fog_curve: 03:00 = 1.0296 (medido, bake)")
	var sm := load("res://data/light/season_mod.tres") as Curve
	_check(sm != null, "season_mod.tres cargable (gap cerrado: no existia)")
	if sm != null:
		_check(sm.point_count == 4, "season_mod: 4 puntos (uno por estacion)")
		_check(absf(sm.min_domain) < 0.001 and absf(sm.max_domain - 3.0) < 0.001, "season_mod: dominio 0-3 (indice de estacion)")
		_check(absf(sm.sample(0.0) - 1.0) < 0.001, "season_mod: Primavera 1.0")
		_check(absf(sm.sample(1.0) - 1.1) < 0.001, "season_mod: Verano 1.1")
		_check(absf(sm.sample(2.0) - 0.95) < 0.001, "season_mod: Otono 0.95")
		_check(absf(sm.sample(3.0) - 0.85) < 0.001, "season_mod: Invierno 0.85")
	var texto := FileAccess.get_file_as_string("res://data/light/fase_umbral.json")
	var datos: Variant = JSON.parse_string(texto)
	if typeof(datos) == TYPE_DICTIONARY:
		var niebla: Variant = datos.get("niebla", {})
		if niebla is Dictionary:
			_check(str(niebla.get("curva", "")) == "res://data/light/fog_curve.tres", "fase_umbral.json sec.niebla apunta a fog_curve.tres")
		else:
			_check(false, "fase_umbral.json sec.niebla presente")
	else:
		_check(false, "fase_umbral.json parsea")

## B. niebla_densidad(hora): fallback sin data + valores cargados + aplicado al Environment
func _test_niebla() -> void:
	# instancia fresca (sin _ready): _fog_curve es null -> fallback FOG_BASE
	var fresco: Node3D = load(RUTA_CICLO).new()
	_check(absf(fresco.niebla_densidad(12.0) - FOG_BASE) < 0.000001, "sin data: niebla_densidad = FOG_BASE (fallback)")
	_check(absf(fresco.niebla_densidad(3.0) - FOG_BASE) < 0.000001, "sin data: niebla_densidad constante (fallback)")
	fresco.free()
	# instancia viva (con _ready): curvas cargadas
	var ciclo: Node3D = load(RUTA_CICLO).new()
	ciclo.name = "DayNightCycle"
	var padre := Node3D.new()
	padre.name = "AmbienteNieblaTest"
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
	_check(ciclo._fog_curve != null, "ciclo con fog_curve cargada tras _ready")
	_check(absf(ciclo.niebla_densidad(12.0) - FOG_BASE * 0.5) < 0.000001, "niebla 12:00 = base x 0.5 (mediodia)")
	_check(absf(ciclo.niebla_densidad(19.0) - FOG_BASE * 1.3) < 0.000001, "niebla 19:00 = base x 1.3 (pico atardecer)")
	_check(absf(ciclo.niebla_densidad(3.0) - FOG_BASE * 1.0296) < 0.000001, "niebla 03:00 = base x 1.0296 (medido, bake)")
	var n12: float = ciclo.niebla_densidad(12.0)
	var n3: float = ciclo.niebla_densidad(3.0)
	var n19: float = ciclo.niebla_densidad(19.0)
	_check(n12 < n3 and n3 < n19, "orden por hora: mediodia < noche < atardecer")
	_check(absf(ciclo.niebla_densidad(99.0) - ciclo.niebla_densidad(24.0)) < 0.000001, "hora fuera de rango clampeada a 24")
	# aplicada al Environment por hora
	ciclo._aplicar_iluminacion(19, false)
	_check(env.environment.fog_enabled, "fog_enabled tras aplicar")
	_check(absf(env.environment.fog_density - ciclo.niebla_densidad(19.0)) < 0.000001, "Environment fog_density = niebla_densidad(19)")
	ciclo._aplicar_iluminacion(12, false)
	_check(absf(env.environment.fog_density - ciclo.niebla_densidad(12.0)) < 0.000001, "Environment fog_density cambia con la hora (12)")
	_check(env.environment.fog_density != 0.0, "niebla nunca 0 (la curva tiene minimo 0.5)")
	padre.queue_free()

## C. mod_estacional + piso anti-oscuridad + lectura de estacion M29
func _test_estacion() -> void:
	# instancia fresca (sin data cargada): modulacion neutra
	var fresco: Node3D = load(RUTA_CICLO).new()
	_check(absf(fresco.mod_estacional(3) - 1.0) < 0.001, "sin data: mod_estacional = 1.0 (neutro)")
	_check(absf(fresco.mod_estacional(0) - 1.0) < 0.001, "sin data: mod_estacional(0) = 1.0 (neutro)")
	fresco.free()
	# instancia viva
	var ciclo: Node3D = load(RUTA_CICLO).new()
	ciclo.name = "DayNightCycle"
	var padre := Node3D.new()
	padre.name = "AmbienteEstacionTest"
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
	_check(ciclo._season_mod != null, "ciclo con season_mod cargada tras _ready")
	_check(absf(ciclo.mod_estacional(0) - 1.0) < 0.001, "mod Primavera 1.0")
	_check(absf(ciclo.mod_estacional(1) - 1.1) < 0.001, "mod Verano 1.1")
	_check(absf(ciclo.mod_estacional(2) - 0.95) < 0.001, "mod Otono 0.95")
	_check(absf(ciclo.mod_estacional(3) - 0.85) < 0.001, "mod Invierno 0.85")
	_check(absf(ciclo.mod_estacional(99) - 0.85) < 0.001, "mod fuera de dominio clampeado a Invierno")
	# lectura de la estacion vigente de M29 (game_clock.get_estacion)
	var gt := root.get_node_or_null("/root/GameTime")
	if gt != null and gt.has_method("get_estacion"):
		_check(ciclo._estacion_actual == int(gt.get_estacion()), "estacion inicial leida de GameTime (_ready)")
	else:
		_check(false, "GameTime disponible para leer estacion")
	# modulacion aplicada: Verano mediodia sol = 1.0 x 1.1 (la luna NO se modula)
	ciclo._estacion_actual = 1
	ciclo._aplicar_iluminacion(12, false)
	_check(absf(sun.light_energy - 1.1) < 0.01, "Verano 12:00 sol = 1.1 (modulacion sobre day_curve)")
	_check(absf(moon.light_energy) < 0.01, "Verano 12:00 luna = 0 (moon_curve NO modulada)")
	# piso anti-oscuridad: Invierno profunda 0.15 x 0.85 = 0.1275 -> clamp 0.15
	ciclo._estacion_actual = 3
	ciclo._aplicar_iluminacion(3, false)
	_check(absf(env.environment.ambient_light_energy - 0.15) < 0.001, "Invierno 03:00 ambiente = 0.15 (piso gana a la modulacion)")
	_check(env.environment.ambient_light_energy >= 0.15, "regla de oro: ambiente NUNCA bajo 0.15")
	_check(absf(ciclo._cielo_mat.sky_energy_multiplier - 0.15) < 0.01, "Invierno 03:00 energia del cielo = 0.15 (piso)")
	# re-aplicacion por estacion_cambio (hora vigente trackeada)
	ciclo._aplicar_iluminacion(19, false)
	_check(ciclo._hora_actual == 19, "_hora_actual trackeada (19)")
	ciclo._on_estacion_cambio(2)
	_check(ciclo._estacion_actual == 2, "estacion_cambio actualiza _estacion_actual")
	_check(env.environment.ambient_light_energy >= 0.15, "tras estacion_cambio el piso 0.15 sigue en pie")
	# Primavera (mod 1.0) = comportamiento aceptado por test_curvas_luz.gd
	ciclo._estacion_actual = 0
	ciclo._aplicar_iluminacion(12, false)
	_check(absf(sun.light_energy - 1.0) < 0.01, "Primavera 12:00 sol = 1.0 (regresion aceptada)")
	_check(absf(env.environment.ambient_light_energy - 1.0) < 0.01, "Primavera 12:00 ambiente = 1.0 (regresion aceptada)")
	padre.queue_free()
