# Modelo: GLM-5.3-Flash (G-5.3-Flash-Agente)
# Plataforma: Kilo Code
# Fecha: 2026-10-23
#
# M58: QA del escalado de accesibilidad (0.8-2.0 sobre CanvasLayer) y de los
# glifos espanoles de las fuentes M88. Ejecutar: Godot --headless --path
# game\isla-ancestral --script res://scripts/ui/qa_m58_escalado.gd

extends SceneTree

var _checks: int = 0
var _fallos: int = 0

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _summary() -> void:
	print("=== Resumen QA escalado+glifos M58: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _nuevo():
	return (load("res://scripts/ui/ui_access_scale.gd") as Script)

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	var sc = _nuevo()

	# --- escalado: clamp inferior / superior / medio, y persistencia
	var canvas := CanvasLayer.new()
	root.add_child(canvas)

	var r1: float = sc.aplicar(canvas, 0.5)
	_check(abs(r1 - 0.8) < 0.001, "clamp inferior 0.5 -> 0.8, fue %.2f" % r1)
	_check(abs(sc.actual(canvas) - 0.8) < 0.001, "persistencia tras clamp inferior")

	var r2: float = sc.aplicar(canvas, 2.5)
	_check(abs(r2 - 2.0) < 0.001, "clamp superior 2.5 -> 2.0, fue %.2f" % r2)

	var r3: float = sc.aplicar(canvas, 1.4)
	_check(abs(r3 - 1.4) < 0.001, "valor medio 1.4 pasa tal cual")

	var r4: float = sc.aplicar(canvas, 2.0)
	_check(abs(r4 - 2.0) < 0.001, "borde superior 2.0 exacto")
	var r5: float = sc.aplicar(canvas, 0.8)
	_check(abs(r5 - 0.8) < 0.001, "borde inferior 0.8 exacto")

	_check(sc.aplicar(null, 1.5) == 0.8, "canvas nulo no crashea (devuelve MIN)")
	_check(abs(sc.actual(null)) < 0.001, "actual(null) devuelve 0.0")

	# --- glifos espanoles de las fuentes M88 (tildes, enie, puntuacion es)
	var glifos := "aeiouáéíóúñÑü¿¡ÁÉÍÓÚ"
	for fuente_path in ["res://assets/fonts/Nunito-Regular.ttf", "res://assets/fonts/Nunito-Bold.ttf", "res://assets/fonts/FredokaOne-Regular.ttf"]:
		var f = load(fuente_path)
		_check(f != null, "fuente carga: " + fuente_path)
		if f == null:
			continue
		if f.has_method("get_supported_chars"):
			var chars: String = f.get_supported_chars()
			var faltan := ""
			for ch in glifos:
				if not chars.contains(ch):
					faltan += ch
			_check(faltan == "", fuente_path.get_file() + " cubre glifos ES (faltan: " + faltan + ")")
		else:
			print("NOTA: %s sin get_supported_chars (no verificable headless)" % fuente_path.get_file())
