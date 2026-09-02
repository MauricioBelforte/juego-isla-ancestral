# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M82: Clasificación por Edades — Test headless
# Valida: RatingValidator (data-driven). Exit code != 0 si falla.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.

extends SceneTree

const _SC_VALIDATOR := preload("res://scripts/legal/rating_validator.gd")
const RUTA_DATA := "res://data/legal/clasificacion.json"

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M82] Test de Clasificación por Edades ===")
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
	print("--- Datos: clasificacion.json ---")
	var data = _cargar()
	_check("clasificacion.json cargado", not data.is_empty())
	_check("4 organismos", data.get("clasificaciones", {}).size() == 4, "size=%d" % data.get("clasificaciones", {}).size())
	_check("2 políticas", data.get("politicas", {}).size() == 2, "size=%d" % data.get("politicas", {}).size())

func _test_validator() -> void:
	print("--- RatingValidator: data real ---")
	var data = _cargar()
	var errores = _SC_VALIDATOR.validar(data)
	_check("data válida (0 errores)", errores.is_empty(), "errores=%s" % str(errores))
	_check("reporte OK", _SC_VALIDATOR.reporte([]).contains("OK"))

func _test_validator_errores() -> void:
	print("--- RatingValidator: errores detectados ---")
	var malo = {
		"clasificaciones": {"pegi": {"rating": "", "region": "", "contenidos": ["xyz"]}},
		"contenidos_posibles": ["violencia_muy_ligera"],
		"politicas": {}
	}
	var errores = _SC_VALIDATOR.validar(malo)
	_check("sin rating detectado", str(errores).contains("sin rating"))
	_check("sin región detectado", str(errores).contains("sin región"))
	_check("contenido inválido detectado", str(errores).contains("xyz"))
	_check("sin políticas detectado", str(errores).contains("políticas"))

func _summary() -> void:
	print("=== Resumen M82: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M82 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M82 OK — todos los checks pasaron")
		quit(0)