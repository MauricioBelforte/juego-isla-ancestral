# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
# M06: Control de Versiones — Test headless
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.
extends SceneTree
const _SC_VALIDATOR := preload("res://scripts/proyecto/version_control_validator.gd")
const RUTA_DATA := "res://data/proyecto/versiones.json"
var _fallos: int = 0; var _checks: int = 0
func _init() -> void: call_deferred("_run")
func _run() -> void:
	print("=== [M06] Test de Control de Versiones ===")
	_test_data(); _test_validator(); _test_validator_errores(); _summary()
func _check(n: String, c: bool, d: String = "") -> void:
	_checks += 1
	if c: print("  [OK] %s" % n)
	else: _fallos += 1; print("  [FAIL] %s %s" % [n, d])
func _cargar() -> Dictionary:
	var p: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_DATA))
	return p if typeof(p) == TYPE_DICTIONARY else {}
func _test_data() -> void:
	print("--- Datos: versiones.json ---")
	var d = _cargar()
	_check("versiones.json cargado", not d.is_empty())
	_check("4 reglas", d.get("reglas", []).size() == 4, "size=%d" % d.get("reglas", []).size())
func _test_validator() -> void:
	print("--- VersionControlValidator: data real ---")
	var errores = _SC_VALIDATOR.validar(_cargar())
	_check("data válida (0 errores)", errores.is_empty(), "errores=%s" % str(errores))
	_check("reporte OK", _SC_VALIDATOR.reporte([]).contains("OK"))
func _test_validator_errores() -> void:
	print("--- VersionControlValidator: errores detectados ---")
	var malo = {"reglas": [{"id": "", "regla": ""}], "politicas": {}}
	var errores = _SC_VALIDATOR.validar(malo)
	_check("sin id detectado", str(errores).contains("sin id"))
	_check("sin regla detectado", str(errores).contains("sin regla"))
func _summary() -> void:
	print("=== Resumen M06: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0: print("TEST M06 FALLIDO — salida con código 1"); quit(1)
	else: print("TEST M06 OK — todos los checks pasaron"); quit(0)