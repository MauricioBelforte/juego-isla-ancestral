extends Node3D

const FASE_ALBA: int = 0
const FASE_DIA: int = 1
const FASE_ATARDECER: int = 2
const FASE_NOCHE: int = 3
const FASE_PROFUNDA: int = 4

const PHASE_NAMES: Array[String] = ["ALBA", "DIA", "ATARDECER", "NOCHE", "PROFUNDA"]

## M31 iter. 2 (glm-5.3-flash): iluminación data-driven.
## Las curvas .tres de data/light/ (diseño §P1-P5) reemplazan los valores
## hardcodeados; el JSON fase_umbral.json documenta los parámetros y franjas.
## Fallback: si una curva falta, se usan los valores del núcleo de Log 302.
@onready var sun: DirectionalLight3D = get_node_or_null("../DirectionalLight")
@onready var moon: DirectionalLight3D = get_node_or_null("../DirLightLuna")
@onready var env: WorldEnvironment = get_node_or_null("../WorldEnvironment")

var _fase_actual: int = -1
var _tween: Tween = null
var _gt: Node = null
## Curvas data-driven (null = fallback hardcodeado del núcleo)
var _day_curve: Curve = null
var _sky_curve: Curve = null
var _moon_curve: Curve = null
## M49 iter. 3 (glm-5.3-flash): ramps de COLOR por franja (diseño M49 §P1-P4)
var _sun_color_ramp: Gradient = null
var _sky_color_ramp: Gradient = null

## ── M31 lote 1 (Step-5-WorkBuddy, 2026-10-15, msg 49 del director) ──
## Cielo procedural por hora + canvas de estrellas + transiciones de 90 s.
## Datos: fase_umbral.json (§estrellas, §transicion), sky_curve.tres,
## sky_color_ramp.tres y time_config.tres (duracion_gradiente_*, M29).
## Cierra los ítems K.2 L218/L219, B-P6 (L44) y D (L87) del checklist.
const RUTA_UMBRALES: String = "res://data/light/fase_umbral.json"
const RUTA_TIME_CONFIG: String = "res://data/time/time_config.tres"

## Domo de estrellas: esfera invertida (se ve desde dentro) con textura
## procedural generada con semilla fija (determinista entre sesiones).
const RADIO_DOMO_ESTRELLAS: float = 900.0
const ESTRELLAS_SEMILLA: int = 31031
const ESTRELLAS_CANTIDAD: int = 600
const ESTRELLAS_TEX_W: int = 512
const ESTRELLAS_TEX_H: int = 256

var _umbrales: Dictionary = {}
var _duracion_amanecer: float = 90.0
var _duracion_atardecer: float = 90.0
var _duracion_hora: float = 1.0
var _cielo_mat: ProceduralSkyMaterial = null
var _estrella_domo: MeshInstance3D = null
var _estrella_mat: StandardMaterial3D = null


func _ready() -> void:
	_cargar_curvas()
	_cargar_umbrales()
	_cargar_duraciones()
	_asegurar_cielo()
	_gt = get_node_or_null("/root/GameTime")
	if _gt == null:
		push_warning("[DayNightCycle] GameTime no disponible; el ciclo no se actualizara por hora")
	if sun == null:
		push_warning("[DayNightCycle] DirectionalLight no encontrado en la escena")
	if moon == null:
		push_warning("[DayNightCycle] DirLightLuna no encontrado en la escena")
	if env == null:
		push_warning("[DayNightCycle] WorldEnvironment no encontrado en la escena")
	var hora_inicial: int = 8
	if _gt != null and _gt.has_method("get_hora"):
		hora_inicial = int(_gt.get_hora())
	_aplicar_iluminacion(hora_inicial, false)
	if _gt != null and _gt.has_signal("hora_cambio"):
		_gt.hora_cambio.connect(_on_hora_cambio)


func _cargar_curvas() -> void:
	# M31 iter. 2: datos §P1/P2/P5 del diseño — si un .tres falta, fallback al núcleo
	_day_curve = load("res://data/light/day_curve.tres") as Curve
	_sky_curve = load("res://data/light/sky_curve.tres") as Curve
	_moon_curve = load("res://data/light/moon_curve.tres") as Curve
	# M49 iter. 3: ramps de color por franja (amanecer/mediodía/atardecer/noche)
	_sun_color_ramp = load("res://data/light/sun_color_ramp.tres") as Gradient
	_sky_color_ramp = load("res://data/light/sky_color_ramp.tres") as Gradient
	if _day_curve != null:
		print("[DayNightCycle] Curvas data-driven cargadas (data/light/)")
	else:
		push_warning("[DayNightCycle] day_curve.tres ausente; fallback a valores del núcleo")
	if _sun_color_ramp != null:
		print("[DayNightCycle] Ramps de color cargados (sun/sky) — M49 iter. 3")


## M31 lote 1 (Step-5-WorkBuddy 2026-10-15): umbrales de fase_umbral.json
## (§estrellas para el canvas, §transicion para el crossfade entre horas).
func _cargar_umbrales() -> void:
	var texto := FileAccess.get_file_as_string(RUTA_UMBRALES)
	if texto.is_empty():
		push_warning("[DayNightCycle] fase_umbral.json ausente; estrellas/transicion con valores por defecto")
		return
	var datos: Variant = JSON.parse_string(texto)
	if typeof(datos) != TYPE_DICTIONARY:
		push_warning("[DayNightCycle] fase_umbral.json no parsea como Dictionary")
		return
	_umbrales = datos
	var transicion: Variant = _umbrales.get("transicion", {})
	if transicion is Dictionary:
		var d: Variant = transicion.get("duracion_seg", 1.0)
		if d != null:
			_duracion_hora = float(d)


## M31 lote 1 (Step-5-WorkBuddy 2026-10-15): los 90 s de las transiciones de
## amanecer/atardecer salen de time_config.tres (M29), antes definidos y sin
## consumidor (ítem K.2 L218 del checklist).
func _cargar_duraciones() -> void:
	var cfg: Variant = load(RUTA_TIME_CONFIG)
	if cfg == null:
		return
	var amanecer: Variant = cfg.get("duracion_gradiente_amanecer")
	if amanecer != null:
		_duracion_amanecer = float(amanecer)
	var atardecer: Variant = cfg.get("duracion_gradiente_atardecer")
	if atardecer != null:
		_duracion_atardecer = float(atardecer)


## M31 lote 1 (Step-5-WorkBuddy 2026-10-15): asegura el cielo procedural
## (ProceduralSkyMaterial, diseño §P3) y el domo de estrellas. El material se
## DUPLICA: no se muta el recurso compartido cacheado de la escena.
func _asegurar_cielo() -> void:
	_asegurar_cielo_procedural()
	_asegurar_domo_estrellas()


func _asegurar_cielo_procedural() -> void:
	if env == null or env.environment == null:
		return
	var cielo: Sky = env.environment.sky
	if cielo == null:
		cielo = Sky.new()
		env.environment.sky = cielo
	if cielo.sky_material == null:
		cielo.sky_material = ProceduralSkyMaterial.new()
	elif not (cielo.sky_material is ProceduralSkyMaterial):
		# el material de la escena no es procedural: reemplazar (diseño §P3)
		cielo.sky_material = ProceduralSkyMaterial.new()
	if _cielo_mat == null:
		_cielo_mat = (cielo.sky_material as ProceduralSkyMaterial).duplicate()
		cielo.sky_material = _cielo_mat


## M31 lote 1 (Step-5-WorkBuddy 2026-10-15): domo de estrellas = esfera
## invertida (flip_faces) con textura procedural (ImageTexture de semilla
## fija) y material unshaded transparente; el alpha lo maneja
## alpha_estrellas(hora) con los datos de fase_umbral.json §estrellas.
func _asegurar_domo_estrellas() -> void:
	if _estrella_domo != null:
		return
	var malla := SphereMesh.new()
	malla.radius = RADIO_DOMO_ESTRELLAS
	malla.height = RADIO_DOMO_ESTRELLAS * 2.0
	malla.radial_segments = 48
	malla.rings = 24
	malla.flip_faces = true
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.albedo_texture = _generar_textura_estrellas()
	mat.albedo_color = Color(1, 1, 1, 0)
	_estrella_mat = mat
	_estrella_domo = MeshInstance3D.new()
	_estrella_domo.name = "DomoEstrellas"
	_estrella_domo.mesh = malla
	_estrella_domo.material_override = mat
	_estrella_domo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_estrella_domo)


## M31 lote 1 (Step-5-WorkBuddy 2026-10-15): campo de estrellas procedural
## determinista (misma semilla = misma textura). Brillo y tinte por estrella.
func _generar_textura_estrellas() -> ImageTexture:
	var img := Image.create(ESTRELLAS_TEX_W, ESTRELLAS_TEX_H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var rng := RandomNumberGenerator.new()
	rng.seed = ESTRELLAS_SEMILLA
	for i in range(ESTRELLAS_CANTIDAD):
		var x := rng.randi_range(0, ESTRELLAS_TEX_W - 1)
		var y := rng.randi_range(0, ESTRELLAS_TEX_H - 1)
		var brillo := rng.randf_range(0.35, 1.0)
		var calido := rng.randf_range(0.0, 1.0)
		img.set_pixel(x, y, Color(1.0, 1.0 - 0.08 * calido, 1.0 - 0.18 * calido, brillo))
	return ImageTexture.create_from_image(img)


## M31 lote 1 (Step-5-WorkBuddy 2026-10-15): alpha del canvas de estrellas
## según fase_umbral.json §estrellas (diseño §P6): subida 0→100% entre
## alpha_inicio (20:00) y alpha_fin (22:00). La noche sostenida (22→05) queda
## en alpha_max y la bajada es el espejo del gradiente de subida (2 h) sobre
## la franja del alba (5→7); el diseño §P6 solo fija la subida.
func alpha_estrellas(hora: float) -> float:
	var ai: float = float(_umbrales.get("estrellas", {}).get("alpha_inicio", 20))
	var af: float = float(_umbrales.get("estrellas", {}).get("alpha_fin", 22))
	var amax: float = float(_umbrales.get("estrellas", {}).get("alpha_max", 1.0))
	if hora >= ai and hora <= af:
		return amax * (hora - ai) / maxf(af - ai, 0.001)
	if hora >= 5.0 and hora <= 7.0:
		return amax * (1.0 - (hora - 5.0) / 2.0)
	if hora > af or hora < 5.0:
		return amax
	return 0.0


## M31 lote 1 (Step-5-WorkBuddy 2026-10-15): duración del crossfade al cambiar
## de hora. Amanecer y atardecer usan los 90 s de time_config.tres (ítem
## K.2 L218); el resto mantiene el crossfade de 1 s de fase_umbral.json
## §transicion (comportamiento del núcleo Log 302).
func _duracion_transicion(fase_anterior: int, fase_nueva: int) -> float:
	if fase_anterior == FASE_ALBA or fase_nueva == FASE_ALBA:
		return _duracion_amanecer
	if fase_anterior == FASE_ATARDECER or fase_nueva == FASE_ATARDECER:
		return _duracion_atardecer
	return _duracion_hora


func _on_hora_cambio(hora: int) -> void:
	var fase_anterior := _fase_actual
	_evaluar_fase(hora)
	var duracion := _duracion_transicion(fase_anterior, _fase_actual)
	_aplicar_iluminacion(hora, true, duracion)


func _evaluar_fase(hora: int) -> void:
	var nueva_fase: int = _fase_de_hora(hora)
	if nueva_fase != _fase_actual:
		var anterior: int = _fase_actual
		_fase_actual = nueva_fase
		var bus: Node = get_node_or_null("/root/EventBus")
		if bus != null and bus.time != null and bus.time.has_signal("fase_cambio"):
			bus.time.fase_cambio.emit(nueva_fase)
		print("[DayNightCycle] fase_cambio: %s -> %s" % [_nombre_fase(anterior), _nombre_fase(nueva_fase)])


func _fase_de_hora(hora: int) -> int:
	if hora >= 5 and hora <= 6:
		return FASE_ALBA
	elif hora >= 7 and hora <= 18:
		return FASE_DIA
	elif hora == 19:
		return FASE_ATARDECER
	elif hora >= 20 and hora <= 22:
		return FASE_NOCHE
	else:
		return FASE_PROFUNDA


## duracion < 0 = valor por defecto del núcleo (compatibilidad con
## test_curvas_luz.gd, que llama con 2 argumentos).
func _aplicar_iluminacion(hora: int, tween: bool, duracion: float = -1.0) -> void:
	if sun == null or moon == null or env == null:
		return

	var sun_energy: float = 0.0
	var moon_energy: float = 0.0
	var ambient_energy: float = 0.0
	var sun_color: Color = Color(1.0, 0.95, 0.85, 1)
	var moon_color: Color = Color(0.7, 0.75, 0.9, 1)

	# M31 iter. 2: data-driven por curvas 24-puntos (diseño §P1/P2/P5);
	# el dominio de la curva es 0-1 (fracción del día) → sample(hora/24.0).
	# Fallback a los valores del núcleo (Log 302) si los .tres faltan.
	if _day_curve != null and _sky_curve != null and _moon_curve != null:
		var t := float(clampi(hora, 0, 24)) / 24.0
		sun_energy = _day_curve.sample(t)
		ambient_energy = _sky_curve.sample(t)
		moon_energy = _moon_curve.sample(t)
		# M49 iter. 3: color por ramp data-driven; fallback al hardcode anterior
		if _sun_color_ramp != null and sun_energy > 0.0:
			sun_color = _sun_color_ramp.sample(t)
		elif sun_energy > 0.0 and hora <= 8:
			sun_color = Color(1.0, 0.7, 0.5, 1)  # amanecer cálido
		elif sun_energy > 0.0 and hora >= 17:
			sun_color = Color(0.9, 0.5, 0.3, 1)  # atardecer
		if _sky_color_ramp != null:
			env.environment.ambient_light_color = _sky_color_ramp.sample(t)
	elif hora >= 7 and hora <= 17:
		sun_energy = 1.0
		ambient_energy = 1.0
	elif hora == 6 or hora == 18:
		sun_energy = 0.5
		ambient_energy = 0.6
		sun_color = Color(1.0, 0.7, 0.5, 1)
	elif hora == 19:
		sun_energy = 0.2
		ambient_energy = 0.4
		sun_color = Color(0.9, 0.5, 0.3, 1)
	elif hora >= 20 and hora <= 21:
		sun_energy = 0.0
		moon_energy = 0.15
		ambient_energy = 0.22
	else:
		sun_energy = 0.0
		moon_energy = 0.12
		ambient_energy = 0.15

	var dur: float = 1.0 if duracion < 0.0 else duracion
	duracion = dur if tween else 0.0
	# M49 iter. 3: color ambiente por ramp también se anima
	var ambient_color: Color = env.environment.ambient_light_color
	if _sky_color_ramp != null:
		ambient_color = _sky_color_ramp.sample(float(clampi(hora, 0, 24)) / 24.0)

	# M31 lote 1 (Step-5-WorkBuddy 2026-10-15): cielo procedural + estrellas
	# por hora (ítems K.2 L219, B-P6 L44, D L87 del checklist).
	var t_cielo := float(clampi(hora, 0, 24)) / 24.0
	var energia_cielo: float = _sky_curve.sample(t_cielo) if _sky_curve != null else 1.0
	var color_cielo: Color = _sky_color_ramp.sample(t_cielo) if _sky_color_ramp != null else Color(0.4, 0.55, 0.8, 1)
	var cielo_top: Color = color_cielo
	var cielo_horizon: Color = color_cielo.lerp(Color(1, 1, 1, 1), 0.3)
	var suelo_horizon: Color = color_cielo.lerp(Color(0.25, 0.2, 0.15, 1), 0.5)
	var suelo_bottom: Color = color_cielo.lerp(Color(0.15, 0.12, 0.1, 1), 0.7)
	var alpha_est: float = alpha_estrellas(float(hora))
	var color_estrellas: Color = Color(1, 1, 1, 0)
	if _estrella_mat != null:
		color_estrellas = _estrella_mat.albedo_color
		color_estrellas.a = alpha_est

	if _tween != null and _tween.is_valid():
		_tween.kill()
	if duracion > 0.0:
		_tween = create_tween()
		_tween.tween_property(sun, "light_energy", sun_energy, duracion)
		_tween.parallel().tween_property(moon, "light_energy", moon_energy, duracion)
		_tween.parallel().tween_property(env.environment, "ambient_light_energy", ambient_energy, duracion)
		_tween.parallel().tween_property(env.environment, "ambient_light_color", ambient_color, duracion)
		if sun_energy > 0.0:
			_tween.parallel().tween_property(sun, "light_color", sun_color, duracion)
		if moon_energy > 0.0:
			_tween.parallel().tween_property(moon, "light_color", moon_color, duracion)
		if _cielo_mat != null:
			_tween.parallel().tween_property(_cielo_mat, "sky_energy_multiplier", energia_cielo, duracion)
			_tween.parallel().tween_property(_cielo_mat, "sky_top_color", cielo_top, duracion)
			_tween.parallel().tween_property(_cielo_mat, "sky_horizon_color", cielo_horizon, duracion)
			_tween.parallel().tween_property(_cielo_mat, "ground_horizon_color", suelo_horizon, duracion)
			_tween.parallel().tween_property(_cielo_mat, "ground_bottom_color", suelo_bottom, duracion)
		if _estrella_mat != null:
			_tween.parallel().tween_property(_estrella_mat, "albedo_color", color_estrellas, duracion)
	else:
		sun.light_energy = sun_energy
		moon.light_energy = moon_energy
		env.environment.ambient_light_energy = ambient_energy
		env.environment.ambient_light_color = ambient_color
		if sun_energy > 0.0:
			sun.light_color = sun_color
		if moon_energy > 0.0:
			moon.light_color = moon_color
		if _cielo_mat != null:
			_cielo_mat.sky_energy_multiplier = energia_cielo
			_cielo_mat.sky_top_color = cielo_top
			_cielo_mat.sky_horizon_color = cielo_horizon
			_cielo_mat.ground_horizon_color = suelo_horizon
			_cielo_mat.ground_bottom_color = suelo_bottom
		if _estrella_mat != null:
			_estrella_mat.albedo_color = color_estrellas

	_rotar_fuentes(hora)


func _rotar_fuentes(hora: int) -> void:
	if sun == null or moon == null:
		return
	var angulo: float = (float(hora) / 24.0) * TAU - PI / 2.0
	var radio: float = 50.0
	var sun_pos: Vector3 = Vector3(cos(angulo), 20.0, sin(angulo)) * radio
	var moon_pos: Vector3 = -sun_pos

	if sun_pos.length() > 0.001:
		var look_target: Vector3 = Vector3.ZERO
		var dir: Vector3 = (look_target - sun_pos).normalized()
		if abs(dir.dot(Vector3.UP)) > 0.999:
			dir = Vector3.FORWARD
		sun.global_position = sun_pos
		sun.look_at(look_target, Vector3.UP)

	if moon_pos.length() > 0.001:
		var dir_m: Vector3 = (Vector3.ZERO - moon_pos).normalized()
		if abs(dir_m.dot(Vector3.UP)) > 0.999:
			dir_m = Vector3.FORWARD
		moon.global_position = moon_pos
		moon.look_at(Vector3.ZERO, Vector3.UP)


func _nombre_fase(fase: int) -> String:
	if fase >= 0 and fase < PHASE_NAMES.size():
		return PHASE_NAMES[fase]
	return "DESCONOCIDA"


func get_fase() -> int:
	return _fase_actual


func es_de_dia() -> bool:
	return _fase_actual == FASE_DIA or _fase_actual == FASE_ALBA
