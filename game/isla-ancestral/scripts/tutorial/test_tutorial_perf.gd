# Modelo: Ling-3.1-Flash
# Plataforma: Kilo Code
# Fecha: 2026-10-12
#
# M92 S11: test de rendimiento — presupuesto ≤ 0.2 ms/frame (RN4/Q8).
# Mide el costo de _process() del TutorialManager en escenario denso:
# triggers de mundo activos (con jugador fake en grupo "player"),
# pistas vivas (máx. 2) y capítulo activo con watchdog.
# Criterio: promedio por tick < 200 µs (0.2 ms) tras warmup.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/tutorial/test_tutorial_perf.gd

extends SceneTree

const ITERACIONES: int = 2000
const WARMUP: int = 200
const PRESUPUESTO_US: int = 200

var _fallos: int = 0
var _tut: Node = null
var _fake_player: Node3D = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_tut = root.get_node_or_null("Tutorial")
	_check(_tut != null, "Tutorial autoload presente")
	if _tut == null:
		print("=== TEST M92 PERF: 1 fallo(s) ===")
		quit(1)
		return
	_fake_player = Node3D.new()
	_fake_player.name = "M92PerfPlayer"
	root.add_child(_fake_player)
	_fake_player.add_to_group("player")
	_escenario_denso()
	_medir("denso (targets + pistas + capítulo activo)")
	_tut.descartar_pistas("perf_fin")
	_tut.activo_actual = ""
	_tut.estado = 1
	_medir("hot path vacío (sin targets ni pistas)")
	_limpiar()
	print("=== TEST M92 PERF: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

## Escenario denso: 8 triggers de mundo, 2 pistas vivas, capítulo activo
func _escenario_denso() -> void:
	for i in range(8):
		_tut.registrar_trigger_mundo("perf_target_%d" % i, Vector3(float(i) * 2.0, 0.0, 0.0), 5.0, "prologo")
	_tut.registrar_pista("perf_pista_1", "prologo", 25.0)
	_tut.registrar_pista("perf_pista_2", "prologo", 25.0)
	_tut.desplegar_capitulo("interactuar")
	_check(_tut.pistas_vivas() == 2, "PERF: 2 pistas vivas (máx. del presupuesto)")
	_check(_tut.esta_activo(), "PERF: capítulo activo para el watchdog")

func _medir(etiqueta: String) -> void:
	for i in range(WARMUP):
		_tut._process(0.016)
	var inicio: int = Time.get_ticks_usec()
	for i in range(ITERACIONES):
		_tut._process(0.016)
	var fin: int = Time.get_ticks_usec()
	var total_us: int = fin - inicio
	var promedio_us: float = float(total_us) / float(ITERACIONES)
	print("[M92 PERF] %s: %d ticks, total %d µs, promedio %.2f µs/tick (presupuesto %d µs)" % [etiqueta, ITERACIONES, total_us, promedio_us, PRESUPUESTO_US])
	_check(promedio_us < float(PRESUPUESTO_US),
		"PERF: %s promedio %.2f µs < %d µs (0.2 ms)" % [etiqueta, promedio_us, PRESUPUESTO_US])

func _limpiar() -> void:
	for i in range(8):
		_tut.desregistrar_trigger_mundo("perf_target_%d" % i)
	if _fake_player != null:
		_fake_player.remove_from_group("player")
		_fake_player.queue_free()
		_fake_player = null
