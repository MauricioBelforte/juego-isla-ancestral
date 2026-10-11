extends SceneTree
## M83 iter3 — Test escaneo vacío + addon sin licencia + notices.

const CHECKS_MINIMOS := 5
var _total := 0
var _fallos := 0
var _scanner: RefCounted

func _init() -> void:
	_scanner = load("res://scripts/licensing/license_scanner.gd").new()
	var vacio: Array = _scanner.scan_directory("res://no_existe_", 1)
	_check(vacio.size() == 0, "Escaneo dir inexistente = 0")
	var sin_lic: Dictionary = _scanner.scan_addon("res://addons/")
	_check(sin_lic is Dictionary, "scan_addonAddon devuelve Dictionary")
	var notice: String = _scanner.generate_notice([])
	_check(notice.contains("THIRD_PARTY"), "generate_notice vacío contiene header")
	var dry: String = _scanner.dry_run([])
	_check(dry.contains("DRY-RUN"), "dry_run contiene DRY-RUN")
	var ruta: String = _scanner.save_notices([{"name": "test", "version": "1.0", "license": "MIT"}], "user://test_notices/")
	_check(ruta.contains("THIRD_PARTY"), "save_notices devuelve ruta")
	_resumen()

func _check(cond: bool, label: String) -> void:
	_total += 1
	if cond:
		print("  [OK] %s" % label)
	else:
		_fallos += 1
		print("  [FAIL] %s" % label)

func _resumen() -> void:
	print("=== M83 iter3: %d checks, %d fallos ===" % [_total, _fallos])
	if _fallos > 0 or _total < CHECKS_MINIMOS:
		quit(1)
	else:
		print("TEST M83 iter3 OK")
		quit(0)
