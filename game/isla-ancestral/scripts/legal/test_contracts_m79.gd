# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M79: Legal Contratos — Test headless
# Valida: ContractValidator (datos data-driven). Exit code != 0 si falla.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.

extends SceneTree

const _SC_VALIDATOR := preload("res://scripts/legal/contract_validator.gd")
const RUTA_DATA := "res://data/legal/contratos.json"

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M79] Test de Legal Contratos ===")
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
	print("--- Datos: contratos.json ---")
	var data = _cargar()
	_check("contratos.json cargado", not data.is_empty())
	_check("3 contratos", data.get("contratos", []).size() == 3, "size=%d" % data.get("contratos", []).size())
	_check("2 políticas", data.get("politicas", {}).size() == 2, "size=%d" % data.get("politicas", {}).size())

func _test_validator() -> void:
	print("--- ContractValidator: data real ---")
	var data = _cargar()
	var errores = _SC_VALIDATOR.validar(data)
	_check("data válida (0 errores)", errores.is_empty(), "errores=%s" % str(errores))
	_check("reporte OK", _SC_VALIDATOR.reporte([]).contains("OK"))

func _test_validator_errores() -> void:
	print("--- ContractValidator: errores detectados ---")
	var malo = {
		"contratos": [
			{"id": "", "tipo": "", "proveedor": "", "estado": ""}
		],
		"politicas": {}
	}
	var errores = _SC_VALIDATOR.validar(malo)
	_check("contrato sin id detectado", str(errores).contains("sin id"))
	_check("sin tipo detectado", str(errores).contains("sin tipo"))
	_check("sin proveedor detectado", str(errores).contains("sin proveedor"))
	_check("sin políticas detectado", str(errores).contains("políticas"))

func _summary() -> void:
	print("=== Resumen M79: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M79 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M79 OK — todos los checks pasaron")
		quit(0)