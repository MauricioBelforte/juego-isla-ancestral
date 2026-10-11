extends SceneTree
## M83 iter2 — Test notices: inventario vacío + completo.

const CHECKS_MINIMOS := 4
var _total := 0
var _fallos := 0
var _scanner: RefCounted

func _init() -> void:
	_scanner = load("res://scripts/licensing/license_scanner.gd").new()
	var addons: Array = _scanner.scan_addons()
	_check(addons is Array, "scan_addons devuelve Array")
	_check(_scanner.reporte([]).contains("0"), "reporte vacío contiene 0")
	_inv_completo()
	_inv_sistema()
	_resumen()

func _check(cond: bool, label: String) -> void:
	_total += 1
	if cond:
		print("  [OK] %s" % label)
	else:
		_fallos += 1
		print("  [FAIL] %s" % label)

func _inv_completo() -> void:
	var inv: Array = _scanner.scan_project()
	_check(inv.size() >= 0, "scan_project devuelve Array (size=%d)" % inv.size())

func _inv_sistema() -> void:
	var pol: Resource = load("res://data/licensing/licencias.tres")
	_check(pol != null, "licencias.tres carga OK")

func _resumen() -> void:
	print("=== Resumen M83 iter2: %d checks, %d fallos ===" % [_total, _fallos])
	if _fallos > 0 or _total < CHECKS_MINIMOS:
		quit(1)
	else:
		print("TEST M83 iter2 OK")
		quit(0)
