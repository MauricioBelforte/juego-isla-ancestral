# Modelo: Step-5-WorkBuddy
# Plataforma: WorkBuddy
# Fecha: 2026-10-15
#
# M31 lote 1 (msg 49 del director De-Director V4.1, 2026-10-15): cielo
# procedural por hora + canvas de estrellas (alpha 0->100% 20:00-22:00, datos
# de fase_umbral.json §estrellas) + transiciones amanecer/atardecer de 90 s
# (time_config.tres, M29). Extiende test_curvas_luz.gd (no lo reemplaza).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/world/test_cielo_estrellas_m31.gd

extends SceneTree

var _fallos: int = 0
var _checks: int = 0
const CHECKS_MINIMOS := 39   # medido en verde (1a corrida: 39 checks)

const BLOQUES := ["A", "B", "C", "D"]
var _vistos: Dictionary = {}

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
	_test_datos_umbrales()
	_fin("A")
	_test_alpha_estrellas()
	_fin("B")
	_test_cielo_procedural()
	_fin("C")
	_test_transicion_90s()
	_fin("D")

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
	print("=== TEST M31 CIELO/ESTRELLAS: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

## A. Datos: fase_umbral.json §estrellas/§transicion + time_config.tres (M29)
func _test_datos_umbrales() -> void:
	var texto := FileAccess.get_file_as_string("res://data/light/fase_umbral.json")
	var datos: Variant = JSON.parse_string(texto)
	_check(typeof(datos) == TYPE_DICTIONARY, "fase_umbral.json parsea")
	if typeof(datos) != TYPE_DICTIONARY:
		return
	var estrellas: Variant = datos.get("estrellas", {})
	_check(estrellas is Dictionary, "§estrellas presente")
	if estrellas is Dictionary:
		_check(int(estrellas.get("alpha_inicio", 0)) == 20, "estrellas alpha_inicio 20 (§P6)")
		_check(int(estrellas.get("alpha_fin", 0)) == 22, "estrellas alpha_fin 22 (§P6)")
		_check(absf(float(estrellas.get("alpha_max", 0)) - 1.0) < 0.001, "estrellas alpha_max 1.0 (§P6)")
	var transicion: Variant = datos.get("transicion", {})
	if transicion is Dictionary:
		_check(absf(float(transicion.get("duracion_seg", 0)) - 1.0) < 0.001, "transicion 1 s (§transicion)")
	var cfg: Variant = load("res://data/time/time_config.tres")
	_check(cfg != null, "time_config.tres cargable (M29)")
	if cfg != null:
		_check(absf(float(cfg.get("duracion_gradiente_amanecer")) - 90.0) < 0.001, "duracion_gradiente_amanecer 90 s")
		_check(absf(float(cfg.get("duracion_gradiente_atardecer")) - 90.0) < 0.001, "duracion_gradiente_atardecer 90 s")

## B. alpha_estrellas(hora) pura: subida 20->22, noche sostenida, bajada 5->7
func _test_alpha_estrellas() -> void:
	var ciclo: Node3D = load("res://scripts/world/day_night_cycle.gd").new()
	_check(absf(ciclo.alpha_estrellas(12.0)) < 0.001, "alpha 12:00 = 0 (dia)")
	_check(absf(ciclo.alpha_estrellas(19.0)) < 0.001, "alpha 19:00 = 0 (antes de la subida)")
	_check(absf(ciclo.alpha_estrellas(20.0)) < 0.001, "alpha 20:00 = 0 (inicio subida §P6)")
	_check(absf(ciclo.alpha_estrellas(21.0) - 0.5) < 0.001, "alpha 21:00 = 0.5 (mitad de la subida)")
	_check(absf(ciclo.alpha_estrellas(22.0) - 1.0) < 0.001, "alpha 22:00 = 1.0 (fin subida §P6)")
	_check(absf(ciclo.alpha_estrellas(23.0) - 1.0) < 0.001, "alpha 23:00 = 1.0 (noche sostenida)")
	_check(absf(ciclo.alpha_estrellas(3.0) - 1.0) < 0.001, "alpha 03:00 = 1.0 (noche profunda)")
	_check(absf(ciclo.alpha_estrellas(6.0) - 0.5) < 0.001, "alpha 06:00 = 0.5 (bajada por el alba)")
	_check(absf(ciclo.alpha_estrellas(7.0)) < 0.001, "alpha 07:00 = 0 (dia)")
	var a20: float = ciclo.alpha_estrellas(20.5)
	var a20b: float = ciclo.alpha_estrellas(20.0)
	var a21: float = ciclo.alpha_estrellas(21.0)
	_check(a20 > a20b and a20 < a21, "subida monotona 20->21")
	ciclo.free()

## C. Cielo procedural + domo de estrellas sobre la estructura hermano real
func _test_cielo_procedural() -> void:
	var ciclo: Node3D = load("res://scripts/world/day_night_cycle.gd").new()
	ciclo.name = "DayNightCycle"
	var padre := Node3D.new()
	padre.name = "AmbienteCieloTest"
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
	# _ready ya corrio: cielo procedural + domo creados
	_check(ciclo._cielo_mat != null, "cielo procedural creado (ProceduralSkyMaterial)")
	_check(ciclo._estrella_domo != null, "domo de estrellas creado")
	_check(ciclo._estrella_domo is MeshInstance3D and ciclo._estrella_domo.mesh != null, "domo con malla")
	# mediodia: energia del cielo = sky_curve(0.5) (§P5), estrellas apagadas
	var sky := load("res://data/light/sky_curve.tres") as Curve
	var ramp := load("res://data/light/sky_color_ramp.tres") as Gradient
	ciclo._aplicar_iluminacion(12, false)
	_check(absf(ciclo._cielo_mat.sky_energy_multiplier - sky.sample(12.0 / 24.0)) < 0.01, "cielo 12:00 energia = curva sky_curve (§P5)")
	_check(ciclo._cielo_mat.sky_top_color.is_equal_approx(ramp.sample(12.0 / 24.0)), "cielo 12:00 top color = ramp sky_color (§P3)")
	_check(absf(ciclo._estrella_mat.albedo_color.a) < 0.001, "estrellas 12:00 alpha 0")
	# noche profunda: energia 0.15 (anti-oscuridad), estrellas al maximo
	ciclo._aplicar_iluminacion(3, false)
	_check(absf(ciclo._cielo_mat.sky_energy_multiplier - 0.15) < 0.01, "cielo 03:00 energia 0.15 (anti-oscuridad §P5)")
	_check(absf(ciclo._estrella_mat.albedo_color.a - 1.0) < 0.001, "estrellas 03:00 alpha 1.0")
	# subida visible en el material
	ciclo._aplicar_iluminacion(21, false)
	_check(absf(ciclo._estrella_mat.albedo_color.a - 0.5) < 0.001, "estrellas 21:00 alpha 0.5 (mitad subida)")
	# gradiente por hora: el color del cielo cambia entre dia y noche
	ciclo._aplicar_iluminacion(12, false)
	var top_dia: Color = ciclo._cielo_mat.sky_top_color
	ciclo._aplicar_iluminacion(3, false)
	var top_noche: Color = ciclo._cielo_mat.sky_top_color
	_check(not top_dia.is_equal_approx(top_noche), "cielo: color dia != color noche (gradiente por hora)")
	# textura procedural: 600 estrellas deterministas (semilla 31031)
	var tex: Variant = ciclo._estrella_mat.albedo_texture
	_check(tex is ImageTexture, "textura de estrellas es ImageTexture (procedural)")
	if tex is ImageTexture:
		var img: Variant = tex.get_image()
		_check(img != null, "imagen de estrellas legible")
		if img != null:
			var opacos := 0
			for y in range(img.get_height()):
				for x in range(img.get_width()):
					if img.get_pixel(x, y).a > 0.0:
						opacos += 1
			_check(opacos >= 590 and opacos <= 600, "estrellas dibujadas: %d de 600 (determinista)" % opacos)
	# ruta con tween: el crossfade se crea con la duracion recibida
	ciclo._aplicar_iluminacion(19, true, 90.0)
	_check(ciclo._tween != null and ciclo._tween.is_valid(), "tween de crossfade creado (duracion parametrizada)")
	padre.queue_free()

## D. Transiciones de 90 s (time_config.tres cargado por _ready)
func _test_transicion_90s() -> void:
	var ciclo: Node3D = load("res://scripts/world/day_night_cycle.gd").new()
	ciclo.name = "DayNightCycleDur"
	root.add_child(ciclo)
	# valores CARGADOS de time_config.tres (no los defaults del script)
	_check(absf(ciclo._duracion_transicion(4, 0) - 90.0) < 0.001, "PROFUNDA->ALBA = 90 s (amanecer)")
	_check(absf(ciclo._duracion_transicion(0, 1) - 90.0) < 0.001, "ALBA->DIA = 90 s (amanecer)")
	_check(absf(ciclo._duracion_transicion(1, 2) - 90.0) < 0.001, "DIA->ATARDECER = 90 s (atardecer)")
	_check(absf(ciclo._duracion_transicion(2, 3) - 90.0) < 0.001, "ATARDECER->NOCHE = 90 s (atardecer)")
	_check(absf(ciclo._duracion_transicion(3, 4) - 1.0) < 0.001, "NOCHE->PROFUNDA = 1 s (crossfade §transicion)")
	_check(absf(ciclo._duracion_transicion(1, 1) - 1.0) < 0.001, "hora dentro del dia = 1 s")
	ciclo.queue_free()
