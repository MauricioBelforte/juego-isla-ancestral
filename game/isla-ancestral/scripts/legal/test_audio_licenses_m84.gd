# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M84: Música y Audio Legal — Test headless
# Valida: AudioLicenseValidator (data-driven). Exit code != 0 si falla.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.

extends SceneTree

const _SC_VALIDATOR := preload("res://scripts/legal/audio_license_validator.gd")
const RUTA_DATA := "res://data/legal/audio_licenses.json"

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M84] Test de Música y Audio Legal ===")
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
	print("--- Datos: audio_licenses.json ---")
	var data = _cargar()
	_check("audio_licenses.json cargado", not data.is_empty())
	_check("3 tracks", data.get("tracks", []).size() == 3, "size=%d" % data.get("tracks", []).size())

func _test_validator() -> void:
	print("--- AudioLicenseValidator: data real ---")
	var data = _cargar()
	var errores = _SC_VALIDATOR.validar(data)
	_check("data válida (0 errores)", errores.is_empty(), "errores=%s" % str(errores))
	_check("reporte OK", _SC_VALIDATOR.reporte([]).contains("OK"))

func _test_validator_errores() -> void:
	print("--- AudioLicenseValidator: errores detectados ---")
	var malo = {
		"tracks": [
			{"id": "", "licencia": ""},
			{"id": "a", "licencia": "CC-BY", "attribution": ""}
		],
		"politicas": {}
	}
	var errores = _SC_VALIDATOR.validar(malo)
	_check("track sin id detectado", str(errores).contains("sin id"))
	_check("sin licencia detectado", str(errores).contains("sin licencia"))
	_check("CC-BY sin atribución detectado", str(errores).contains("CC-BY"))
	_check("sin políticas detectado", str(errores).contains("políticas"))

func _summary() -> void:
	print("=== Resumen M84: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M84 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M84 OK — todos los checks pasaron")
		quit(0)