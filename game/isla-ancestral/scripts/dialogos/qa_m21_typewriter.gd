# Modelo: GLM-5.3-Flash (G-5.3-Flash-Agente)
# Plataforma: Kilo Code
# Fecha: 2026-10-22
#
# M21: QA del TypewriterEffect (RF3 tipografia progresiva con velocidad
# configurable) + guardia del BUG-146 (start() ya no emite typing_complete).
# Ejecutar: Godot --headless --path game\isla-ancestral --script res://scripts/dialogos/qa_m21_typewriter.gd

extends SceneTree

var _checks: int = 0
var _fallos: int = 0

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _summary() -> void:
	print("=== Resumen QA typewriter M21: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _nuevo() -> Node:
	return (load("res://scripts/dialogos/typewriter_effect.gd") as Script).new()

func _run() -> void:
	var tw: Node = _nuevo()
	root.add_child(tw)
	var completadas: Array = []
	tw.typing_complete.connect(func(): completadas.append(1))

	# BUG-146: start() NO emite typing_complete (solo reinicia estado)
	tw.start("Hola isla ancestral")
	_check(completadas.is_empty(), "BUG-146: start() NO emite typing_complete")

	# RF3: velocidad configurable (chars_per_second es @export)
	_check(float(tw.chars_per_second) == 30.0, "RF3: velocidad default 30 cps")
	tw.chars_per_second = 60.0
	_check(float(tw.chars_per_second) == 60.0, "RF3: velocidad configurable (60 cps)")

	# Progreso proporcional: 1 s con 60 cps => 60 chars visibles
	var parcial: String = tw.update(1.0)
	_check(parcial.length() == 19, "RF3: progreso proporcional (texto completo de 19 chars visible tras 1 s a 60 cps: %d)" % parcial.length())
	# 19 chars a 60 cps se completan antes de 1 s acumulado
	# 19 chars a 60 cps: ~0.32 s acumulados; ya se completo con 1 s
	_check(tw.is_finished(), "tipeo completado tras acumular 1 s (19 chars < 60)")
	_check(completadas.size() == 1, "typing_complete emitio UNA vez al completar")
	parcial = tw.update(0.5)
	_check(completadas.size() == 1, "sin emisiones extra tras completar (update posterior)")

	# skip(): completo inmediato con emit
	tw.clear()
	tw.start("texto de prueba skip")
	tw.chars_per_second = 10.0
	tw.update(0.0)
	var full: String = tw.skip()
	_check(full == "texto de prueba skip" and tw.is_finished(), "skip: completo inmediato")
	_check(completadas.size() == 2, "skip emite typing_complete (1 por linea)")

	# validate_config (API estatica)
	var errs: Array = tw.validate_config({"chars_per_second": 0.0})
	_check(ed(errs) > 0, "validate_config: cps invalido reportado")
	errs = tw.validate_config({"chars_per_second": 55.0})
	_check(ed(errs) == 0, "validate_config: cps valido sin errores")
	tw.queue_free()
	_summary()

func ed(arr: Array) -> int:
	return arr.size()
