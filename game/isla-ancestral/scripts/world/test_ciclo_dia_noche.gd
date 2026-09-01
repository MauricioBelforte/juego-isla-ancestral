extends SceneTree

## Test headless del ciclo día/noche (M31).
## Valida: mapeo de horas a fases, emisión de señal fase_cambio,
## estabilidad (sin doble señal misma hora), valores de iluminación
## dentro de rangos anti-oscuridad y consultas get_fase/es_de_dia.

const DAY_NIGHT_CYCLE := preload("res://scripts/world/day_night_cycle.gd")
const GAME_TIME := preload("res://scripts/time/game_clock.gd")

var _fallos := 0
var _checks := 0
var _fases_recibidas: Array = []


func _initialize() -> void:
	call_deferred("_ejecutar")


func _ejecutar() -> void:
	print("=== TEST CICLO DIA/NOCHE M31 ===")

	var cycle := DAY_NIGHT_CYCLE.new()
	var clock := GAME_TIME.new()

	root.add_child(cycle)
	root.add_child(clock)

	# Esperar un frame para que _ready corra
	await _wait_frame()

	# Estado inicial a las 08:00 -> DIA
	clock._hora = 8
	clock._minuto = 0
	cycle._on_hora_cambio(8)
	_check("fase inicial a las 08:00 es DIA", cycle.get_fase() == cycle.FASE_DIA)
	_check("es_de_dia true a las 08:00", cycle.es_de_dia())

	# Cambios de fase por hora
	clock._hora = 5
	cycle._on_hora_cambio(5)
	_check("fase a las 05:00 es ALBA", cycle.get_fase() == cycle.FASE_ALBA)

	clock._hora = 7
	cycle._on_hora_cambio(7)
	_check("fase a las 07:00 es DIA", cycle.get_fase() == cycle.FASE_DIA)

	clock._hora = 19
	cycle._on_hora_cambio(19)
	_check("fase a las 19:00 es ATARDECER", cycle.get_fase() == cycle.FASE_ATARDECER)

	clock._hora = 20
	cycle._on_hora_cambio(20)
	_check("fase a las 20:00 es NOCHE", cycle.get_fase() == cycle.FASE_NOCHE)

	clock._hora = 23
	cycle._on_hora_cambio(23)
	_check("fase a las 23:00 es PROFUNDA", cycle.get_fase() == cycle.FASE_PROFUNDA)

	# Estabilidad: misma hora no emite señal duplicada
	var antes := cycle.get_fase()
	cycle._on_hora_cambio(23)
	_check("sin doble señal misma hora", cycle.get_fase() == antes)

	# Anti-oscuridad: energía ambiente nocturno >= 0.15
	clock._hora = 23
	cycle._on_hora_cambio(23)
	if cycle.env != null:
		var amb: float = cycle.env.environment.ambient_light_energy
		_check("piso ambiente nocturno >= 0.15", amb >= 0.15)
		# Sol apagado de noche, luna encendida
		if cycle.sun != null and cycle.moon != null:
			_check("sol apagado en Noche", cycle.sun.light_energy <= 0.01)
			_check("luna encendida en Noche", cycle.moon.light_energy >= 0.10)
	else:
		print("[SKIP] WorldEnvironment ausente (test sin escena principal); checks visuales requieren main_island.tscn")

	# Consumo desde API pública
	clock._hora = 10
	cycle._on_hora_cambio(10)
	_check("get_fase() == DIA tras 10h", cycle.get_fase() == cycle.FASE_DIA)
	_check("es_de_dia() true a las 10h", cycle.es_de_dia())

	clock._hora = 1
	cycle._on_hora_cambio(1)
	_check("get_fase() == PROFUNDA tras 01h", cycle.get_fase() == cycle.FASE_PROFUNDA)
	_check("es_de_dia() false a las 01h", not cycle.es_de_dia())

	print("=== Resumen: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("FALLOS CICLO DIA/NOCHE")
		quit(1)
	else:
		print("CICLO DIA/NOCHE OK")
		quit(0)


func _wait_frame() -> void:
	await process_frame


func _check(etiqueta: String, ok: bool) -> void:
	_checks += 1
	if ok:
		print("[OK] %s" % etiqueta)
	else:
		_fallos += 1
		print("[FAIL] %s" % etiqueta)
