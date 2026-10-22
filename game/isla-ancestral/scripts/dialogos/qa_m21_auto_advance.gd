# Modelo: GLM-5.3-Flash (G-5.3-Flash-Agente)
# Plataforma: Kilo Code
# Fecha: 2026-10-22
#
# M21: QA del AutoAdvanceManager (RF8 avance automatico con temporizador,
# item [S] del 05-Checklist; turno 2-BIS).
# Ejecutar: Godot --headless --path game\isla-ancestral --script res://scripts/dialogos/qa_m21_auto_advance.gd

extends SceneTree

var _checks: int = 0
var _fallos: int = 0

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _summary() -> void:
	print("=== Resumen QA auto-advance M21: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _nuevo() -> Node:
	return (load("res://scripts/dialogos/auto_advance_manager.gd") as Script).new()

func _run() -> void:
	var aa: Node = _nuevo()
	root.add_child(aa)
	var eventos: Array = []
	aa.auto_advancing.connect(func(d: float): eventos.append("advancing"))
	aa.auto_advance_skipped.connect(func(): eventos.append("skipped"))
	aa.auto_advance_complete.connect(func(): eventos.append("complete"))

	# 1. Ciclo basico: inicio, acumular delta hasta el delay, complete
	var delays: Array = []
	aa.start_auto_advance(1.0)
	_check(aa.get("auto_advance_delay") == 1.0, "RF8: delay configurable via start (1.0 s)")
	_check(eventos.has("advancing"), "RF8: senal auto_advancing al iniciar")
	aa.update(0.5)
	_check(aa.get("_timer") > 0.0, "RF8: el temporizador acumula delta")
	aa.update(0.6)
	_check(eventos.has("complete"), "RF8: auto_advance_complete al vencer el delay")
	_check(aa.get("_active") == false, "RF8: se desactiva al completar")

	# 2. Pausa con opciones visibles (pause_on_options)
	aa.start_auto_advance(0.5)
	aa.set_has_options(true)
	aa.update(0.3)
	aa.update(0.3)
	_check(aa.get("_timer") < 0.5, "RF8: pausa con opciones visibles (no acumula)")
	aa.set_has_options(false)
	aa.update(0.6)
	_check(eventos.count("complete") >= 2, "RF8: retoma tras quitar opciones")

	# 3. skip manual: salta al final y emite skipped + complete
	var n_ev: int = eventos.size()
	aa.start_auto_advance(99.0)
	aa.skip()
	_check(eventos.slice(n_ev).has("skipped"), "RF8: skip emite auto_advance_skipped")
	_check(eventos.count("complete") >= 3, "RF8: skip dispara complete (avance manual)")

	# 4. stop: apaga sin eventos
	aa.start_auto_advance(0.2)
	var n_ev2: int = eventos.size()  # tras el advancing del start: el stop debe dejarlos ahi
	aa.stop()
	aa.update(1.5)
	_check(eventos.size() == n_ev2, "RF8: stop detiene el flujo (sin avance ni complete)")

	# 5. validate_config
	_check(ed(aa.validate_config({"auto_advance_delay": 0.1})) > 0, "config: delay demasiado bajo reportado")
	_check(ed(aa.validate_config({"auto_advance_delay": 31.0})) > 0, "config: delay demasiado alto reportado")
	_check(ed(aa.validate_config({"auto_advance_delay": 3.0})) == 0, "config: delay 3.0 valido")

	# 6. create_default (fabrica con defaults cozy)
	var d: Node = aa.create_default()
	_check(float(d.auto_advance_delay) == 3.0 and bool(d.pause_on_options) == true,
		"config: create_default con defaults cozy (3.0 s, pausa en opciones)")
	d.queue_free()
	aa.queue_free()
	_summary()

func ed(arr: Array) -> int:
	return arr.size()
