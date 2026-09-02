# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M101: QA General — Test headless
# Valida: QaValidator (sesiones, DoD por hito, smoke/severidades/tono).
# Exit code != 0 si falla.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.

extends SceneTree

const _SC_VALIDATOR := preload("res://scripts/qa/qa_validator.gd")

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M101] Test de QA General ===")
	var v = _SC_VALIDATOR.new()
	v.cargar_schema()
	_test_sesion(v)
	_test_dod(v)
	_test_reportes()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _test_sesion(v) -> void:
	print("--- Sesión: campos obligatorios y hitos ---")
	var ok_sesion = v.validar_sesion({"build": "abc123", "fecha": "2026-09-02", "tester": "deepseek-v4-flash", "hito": "M137"})
	_check("sesión válida", ok_sesion.is_empty(), "errores=%s" % str(ok_sesion))
	var falta = v.validar_sesion({"build": "abc123", "tester": "x", "hito": "M137"})
	_check("falta fecha detectado", not falta.is_empty())
	var hito_malo = v.validar_sesion({"build": "a", "fecha": "d", "tester": "x", "hito": "M999"})
	_check("hito inválido detectado", str(hito_malo).contains("inválido"))

func _test_dod(v) -> void:
	print("--- DoD por hito: smoke/severidades/tono ---")
	var ok = v.validar_dod("M137", true, 0, 0, 1.2)
	_check("M137 DoD ok", ok.is_empty(), "errores=%s" % str(ok))
	var smoke_fail = v.validar_dod("M137", false, 0, 0, 1.2)
	_check("smoke fallido detectado", not smoke_fail.is_empty())
	var s1 = v.validar_dod("M137", true, 2, 0, 1.2)
	_check("S1 excedido detectado", not s1.is_empty())
	var tono_bajo = v.validar_dod("M137", true, 0, 0, 0.2)
	_check("tono bajo detectado", not tono_bajo.is_empty())
	var prealpha = v.validar_dod("M139", true, 0, 0, 1.1)
	_check("M139 DoD ok", prealpha.is_empty(), "errores=%s" % str(prealpha))
	var prealpha_s2 = v.validar_dod("M139", true, 0, 1, 1.1)
	_check("M139 S2 crítico detectado", not prealpha_s2.is_empty())
	var hito_sin_dod = v.validar_dod("M999", true, 0, 0, 2.0)
	_check("hito sin DoD detectado", not hito_sin_dod.is_empty())

func _test_reportes() -> void:
	print("--- Reportes ---")
	_check("reporte OK cuando limpio", _SC_VALIDATOR.reporte([]).contains("OK"))
	_check("reporte con errores", _SC_VALIDATOR.reporte(["x"]).contains("1 ERRORES"))

func _summary() -> void:
	print("=== Resumen M101: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M101 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M101 OK — todos los checks pasaron")
		quit(0)