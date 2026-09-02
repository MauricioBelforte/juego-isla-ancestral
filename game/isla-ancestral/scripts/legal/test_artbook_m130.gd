# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M130: Artbook — Test headless
# Valida: ArtbookValidator (data-driven). Exit code != 0 si falla.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.

extends SceneTree

const _SC_VALIDATOR := preload("res://scripts/legal/artbook_validator.gd")
const RUTA_DATA := "res://data/legal/artbook.json"

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M130] Test de Artbook ===")
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
	print("--- Datos: artbook.json ---")
	var data = _cargar()
	_check("artbook.json cargado", not data.is_empty())
	_check("4 secciones", data.get("secciones", []).size() == 4, "size=%d" % data.get("secciones", []).size())

func _test_validator() -> void:
	print("--- ArtbookValidator: data real ---")
	var data = _cargar()
	var errores = _SC_VALIDATOR.validar(data)
	_check("data válida (0 errores)", errores.is_empty(), "errores=%s" % str(errores))
	_check("reporte OK", _SC_VALIDATOR.reporte([]).contains("OK"))

func _test_validator_errores() -> void:
	print("--- ArtbookValidator: errores detectados ---")
	var malo = {
		"secciones": [
			{"id": "", "nombre": "", "estado": ""}
		],
		"politicas": {}
	}
	var errores = _SC_VALIDATOR.validar(malo)
	_check("sin id detectado", str(errores).contains("sin id"))
	_check("sin nombre detectado", str(errores).contains("sin nombre"))
	_check("sin estado detectado", str(errores).contains("sin estado"))
	_check("sin políticas detectado", str(errores).contains("políticas"))

func _summary() -> void:
	print("=== Resumen M130: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M130 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M130 OK — todos los checks pasaron")
		quit(0)