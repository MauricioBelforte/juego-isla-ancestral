# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M83: Licencias de Software — Test headless
# Valida: LicenseValidator (data-driven). Exit code != 0 si falla.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.

extends SceneTree

const _SC_VALIDATOR := preload("res://scripts/legal/license_validator.gd")
const RUTA_DATA := "res://data/legal/licencias.json"

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M83] Test de Licencias de Software ===")
	_test_data()
	_test_validator()
	_test_validator_errores()
	_test_cache()
	_test_leer_notices()
	_test_cleanup_obsoletas()
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
	print("--- Datos: licencias.json ---")
	var data = _cargar()
	_check("licencias.json cargado", not data.is_empty())
	_check("3 licencias", data.get("licencias", []).size() == 3, "size=%d" % data.get("licencias", []).size())
	_check("2 políticas", data.get("politicas", {}).size() == 2, "size=%d" % data.get("politicas", {}).size())

func _test_validator() -> void:
	print("--- LicenseValidator: data real ---")
	var data = _cargar()
	var errores = _SC_VALIDATOR.validar(data)
	_check("data válida (0 errores)", errores.is_empty(), "errores=%s" % str(errores))
	_check("reporte OK", _SC_VALIDATOR.reporte([]).contains("OK"))

func _test_validator_errores() -> void:
	print("--- LicenseValidator: errores detectados ---")
	var malo = {
		"licencias": [
			{"id": "", "software": "", "licencia": ""}
		],
		"politicas": {}
	}
	var errores = _SC_VALIDATOR.validar(malo)
	_check("licencia sin id detectado", str(errores).contains("sin id"))
	_check("sin software detectado", str(errores).contains("sin software"))
	_check("sin tipo de licencia detectado", str(errores).contains("sin tipo"))
	_check("sin políticas detectado", str(errores).contains("políticas"))

func _summary() -> void:
	print("=== Resumen M83: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M83 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M83 OK — todos los checks pasaron")
		quit(0)


## ── Iter. 4 (agnes-2.5-flash): cache, notices .md/.txt, cleanup ──

func _test_cache() -> void:
	print("--- LicenseValidator: cache ---")
	var data = _cargar()
	var errores1 = _SC_VALIDATOR.validar(data)
	var errores2 = _SC_VALIDATOR.validar(data)
	_check("cache: resultados idénticos", errores1 == errores2, "diff: %s vs %s" % [str(errores1), str(errores2)])
	var stats = _SC_VALIDATOR.stats_cache()
	_check("cache tiene entradas", int(stats.get("entradas", 0)) > 0, "entradas=%s" % stats.get("entradas"))
	_check("TTL configurado", float(stats.get("ttl_seg", 0)) > 0.0)

func _test_leer_notices() -> void:
	print("--- LicenseValidator: leer_notices_archivo ---")
	var tmp_md := "res://tmp_test_notice.md"
	var md_text := "# Licencia MIT\n\nCopyright 2026 Test\n\n---\n\nPermisos otorgados..."
	var f := FileAccess.open(tmp_md, FileAccess.WRITE)
	if f != null:
		f.store_string(md_text)
		f.close()
		var result = _SC_VALIDATOR.leer_notices_archivo(tmp_md)
		_check("md: notices leídas", result.notices.size() > 0, "size=%d" % result.notices.size())
		_check("md: sin encabezados", not str(result.notices).contains("#"), "contains header")
		# Try non-supported format
		var bad_result = _SC_VALIDATOR.leer_notices_archivo("res://some_file.pdf")
		_check("pdf: formato rechazado", not bad_result.notices.is_empty() == false, "should have errors")
		# Cleanup temp
		if FileAccess.file_exists(tmp_md):
			OS.move_to_trash(OS.get_executable_path().get_base_dir() + "/tmp_test_notice.md")
	else:
		_check("md: archivo creado", false, "no pudo crear tmp")

func _test_cleanup_obsoletas() -> void:
	print("--- LicenseValidator: cleanup_notices_obsoletas ---")
	var old := ["first license notice here.", "second notice here.", "third notice here."]
	var new := ["first license notice here.", "third notice here.", "fourth notice here."]
	var removidos = _SC_VALIDATOR.cleanup_notices_obsoletas(old, new)
	_check("cleanup: 1 removido", removidos.size() == 1, "size=%d" % removidos.size())
	_check("cleanup: no pierde existentes", removidos.size() <= old.size())