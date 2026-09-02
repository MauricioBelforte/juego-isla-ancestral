# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M86: IA Generativa — Test headless
# Valida: GenAIValidator (data-driven). Exit code != 0 si falla.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.

extends SceneTree

const _SC_VALIDATOR := preload("res://scripts/legal/genai_validator.gd")
const RUTA_DATA := "res://data/legal/ia_generativa.json"

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M86] Test de IA Generativa ===")
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
	print("--- Datos: ia_generativa.json ---")
	var data = _cargar()
	_check("ia_generativa.json cargado", not data.is_empty())
	_check("3 usos permitidos", data.get("politicas", {}).get("uso_permitido", []).size() == 3, "size=%d" % data.get("politicas", {}).get("uso_permitido", []).size())
	_check("4 usos prohibidos", data.get("politicas", {}).get("uso_prohibido", []).size() == 4, "size=%d" % data.get("politicas", {}).get("uso_prohibido", []).size())

func _test_validator() -> void:
	print("--- GenAIValidator: data real ---")
	var data = _cargar()
	var errores = _SC_VALIDATOR.validar(data)
	_check("data válida (0 errores)", errores.is_empty(), "errores=%s" % str(errores))
	_check("reporte OK", _SC_VALIDATOR.reporte([]).contains("OK"))

func _test_validator_errores() -> void:
	print("--- GenAIValidator: errores detectados ---")
	var malo = {
		"politicas": {"uso_permitido": [], "uso_prohibido": []},
		"atribucion": {"requerida": false}
	}
	var errores = _SC_VALIDATOR.validar(malo)
	_check("sin usos permitidos detectado", str(errores).contains("permitidos"))
	_check("sin usos prohibidos detectado", str(errores).contains("prohibidos"))
	_check("sin atribución detectado", str(errores).contains("Atribución"))

func _summary() -> void:
	print("=== Resumen M86: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M86 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M86 OK — todos los checks pasaron")
		quit(0)