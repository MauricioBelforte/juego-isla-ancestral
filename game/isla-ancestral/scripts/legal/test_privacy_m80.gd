# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M80: Legal Privacidad — Test headless
# Valida: PrivacyValidator (datos data-driven). Exit code != 0 si falla.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.

extends SceneTree

const _SC_VALIDATOR := preload("res://scripts/legal/privacy_validator.gd")
const RUTA_DATA := "res://data/legal/privacidad.json"

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M80] Test de Legal Privacidad ===")
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
	print("--- Datos: privacidad.json ---")
	var data = _cargar()
	_check("privacidad.json cargado", not data.is_empty())
	_check("4 datos recolectados", data.get("datos_recolectados", []).size() == 4, "size=%d" % data.get("datos_recolectados", []).size())
	_check("3 regiones", data.get("regiones", []).size() == 3, "size=%d" % data.get("regiones", []).size())
	_check("3 políticas", data.get("politicas", {}).size() == 3, "size=%d" % data.get("politicas", {}).size())

func _test_validator() -> void:
	print("--- PrivacyValidator: data real ---")
	var data = _cargar()
	var errores = _SC_VALIDATOR.validar(data)
	_check("data válida (0 errores)", errores.is_empty(), "errores=%s" % str(errores))
	_check("reporte OK", _SC_VALIDATOR.reporte([]).contains("OK"))

func _test_validator_errores() -> void:
	print("--- PrivacyValidator: errores detectados ---")
	var malo = {
		"datos_recolectados": [
			{"id": "", "tipo": "", "base_legal": ""}
		],
		"regiones": [],
		"politicas": {}
	}
	var errores = _SC_VALIDATOR.validar(malo)
	_check("dato sin id detectado", str(errores).contains("sin id"))
	_check("sin tipo detectado", str(errores).contains("sin tipo"))
	_check("sin base legal detectado", str(errores).contains("base legal"))
	_check("sin regiones detectado", str(errores).contains("regiones"))

func _summary() -> void:
	print("=== Resumen M80: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M80 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M80 OK — todos los checks pasaron")
		quit(0)