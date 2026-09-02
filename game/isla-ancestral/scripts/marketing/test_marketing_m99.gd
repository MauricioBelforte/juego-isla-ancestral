# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M99: Marketing — Test headless
# Valida: MarketingValidator (canales, campañas, presupuesto, KPIs).
# Exit code != 0 si falla.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.

extends SceneTree

const _SC_VALIDATOR := preload("res://scripts/marketing/marketing_validator.gd")
const RUTA_DATA := "res://data/marketing/marketing_plan.json"

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M99] Test de Marketing ===")
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
	print("--- Datos: marketing_plan.json ---")
	var data = _cargar()
	_check("marketing_plan.json cargado", not data.is_empty())
	_check("6 canales", data.get("canales", []).size() == 6, "size=%d" % data.get("canales", []).size())
	_check("3 campañas", data.get("campanas", []).size() == 3, "size=%d" % data.get("campanas", []).size())
	_check("presupuesto $5000", int(data.get("presupuesto", {}).get("total_usd", 0)) == 5000)
	_check("4 KPIs", data.get("kpis", []).size() == 4, "size=%d" % data.get("kpis", []).size())

func _test_validator() -> void:
	print("--- MarketingValidator: data real ---")
	var data = _cargar()
	var errores = _SC_VALIDATOR.validar(data)
	_check("data válida (0 errores)", errores.is_empty(), "errores=%s" % str(errores))
	_check("reporte OK", _SC_VALIDATOR.reporte([]).contains("OK"))

func _test_validator_errores() -> void:
	print("--- MarketingValidator: errores detectados ---")
	var malo = {
		"canales": [],
		"campanas": [
			{"nombre": "", "canal": "", "fase": ""},
			{"nombre": "x", "canal": "steam", "fase": "F1"}
		],
		"presupuesto": {"total_usd": 0},
		"kpis": []
	}
	var errores = _SC_VALIDATOR.validar(malo)
	_check("sin canales detectado", str(errores).contains("canales"))
	_check("campaña sin nombre detectado", str(errores).contains("sin nombre"))
	_check("presupuesto 0 detectado", str(errores).contains("Presupuesto"))
	_check("sin KPIs detectado", str(errores).contains("KPIs"))

func _summary() -> void:
	print("=== Resumen M99: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M99 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M99 OK — todos los checks pasaron")
		quit(0)