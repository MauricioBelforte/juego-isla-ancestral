extends Node3D

const FASE_ALBA: int = 0
const FASE_DIA: int = 1
const FASE_ATARDECER: int = 2
const FASE_NOCHE: int = 3
const FASE_PROFUNDA: int = 4

const PHASE_NAMES: Array[String] = ["ALBA", "DIA", "ATARDECER", "NOCHE", "PROFUNDA"]

@onready var sun: DirectionalLight3D = get_node_or_null("../DirectionalLight")
@onready var moon: DirectionalLight3D = get_node_or_null("../DirLightLuna")
@onready var env: WorldEnvironment = get_node_or_null("../WorldEnvironment")

var _fase_actual: int = -1
var _tween: Tween = null
var _gt: Node = null


func _ready() -> void:
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


func _on_hora_cambio(hora: int) -> void:
	_evaluar_fase(hora)
	_aplicar_iluminacion(hora, true)


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


func _aplicar_iluminacion(hora: int, tween: bool) -> void:
	if sun == null or moon == null or env == null:
		return

	var sun_energy: float = 0.0
	var moon_energy: float = 0.0
	var ambient_energy: float = 0.0
	var sun_color: Color = Color(1.0, 0.95, 0.85, 1)
	var moon_color: Color = Color(0.7, 0.75, 0.9, 1)

	if hora >= 7 and hora <= 17:
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

	var duracion: float = 1.0 if tween else 0.0

	if _tween != null and _tween.is_valid():
		_tween.kill()
	if duracion > 0.0:
		_tween = create_tween()
		_tween.tween_property(sun, "light_energy", sun_energy, duracion)
		_tween.parallel().tween_property(moon, "light_energy", moon_energy, duracion)
		_tween.parallel().tween_property(env.environment, "ambient_light_energy", ambient_energy, duracion)
		if sun_energy > 0.0:
			_tween.parallel().tween_property(sun, "light_color", sun_color, duracion)
		if moon_energy > 0.0:
			_tween.parallel().tween_property(moon, "light_color", moon_color, duracion)
	else:
		sun.light_energy = sun_energy
		moon.light_energy = moon_energy
		env.environment.ambient_light_energy = ambient_energy
		if sun_energy > 0.0:
			sun.light_color = sun_color
		if moon_energy > 0.0:
			moon.light_color = moon_color

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
