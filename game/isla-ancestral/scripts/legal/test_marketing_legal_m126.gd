# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M126: Marketing Legal — Test headless
# Valida: MarketingLegalValidator (data-driven). Exit code != 0 si falla.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.

extends SceneTree

const _SC_VALIDATOR := preload("res://scripts/legal/marketing_legal_validator.gd")
const RUTA_DATA := "res://data/legal/marketing_legal.json"

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M126] Test de Marketing Legal ===")
	_test_data()
	_test_validator()
	_test_validator_errores()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _cargar() -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_DATA))
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed
	return {}

func _test_data() -> void:
	print("--- Datos: marketing_legal.json ---")
	var data = _cargar()
	_check("marketing_legal.json cargado", not data.is_empty())
	_check("4 cumplimientos", data.get("cumplimientos", []).size() == 4, "size=%d" % data.get("cumplimientos", []).size())
	_check("2 políticas", data.get("politicas", {}).size() == 2, "size=%d" % data.get("politicas", {}).size())

func _test_validator() -> void:
	print("--- MarketingLegalValidator: data real ---")
	var data = _cargar()
	var errores = _SC_VALIDATOR.validar(data)
	_check("data válida (0 errores)", errores.is_empty(), "errores=%s" % str(errores))
	_check("reporte OK", _SC_VALIDATOR.reporte([]).contains("OK"))

func _test_validator_errores() -> void:
	print("--- MarketingLegalValidator: errores detectados ---")
	var malo = {
		"cumplimientos": [
			{"id": "", "regla": "", "aplica_a": []}
		],
		"politicas": {}
	}
	var errores = _SC_VALIDATOR.validar(malo)
	_check("sin id detectado", str(errores).contains("sin id"))
	_check("sin regla detectado", str(errores).contains("sin regla"))
	_check("sin alcance detectado", str(errores).contains("aplica_a"))
	_check("sin políticas detectado", str(errores).contains("políticas"))

func _summary() -> void:
	print("=== Resumen M126: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M126 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M126 OK — todos los checks pasaron")
		quit(0)