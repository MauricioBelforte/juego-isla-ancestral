# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M88: Fuentes Tipográficas — Test headless
# Valida: FontCatalog (fuentes por id/familia, licencias) y FontAuditor.
# Exit code != 0 si falla.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.

extends SceneTree

const _SC_AUDITOR := preload("res://scripts/fonts/font_auditor.gd")

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M88] Test de Fuentes Tipográficas ===")
	_test_catalog()
	_test_auditor()
	_test_auditor_errores()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _test_catalog() -> void:
	print("--- FontCatalog: fuentes y familias ---")
	var fc := root.get_node_or_null("FontCatalog")
	if fc == null:
		_check("FontCatalog autoload presente", false)
		_summary()
		quit(1)
		return
	_check("FontCatalog autoload presente", true)
	_check("4 fuentes", fc.config.get("fuentes", []).size() == 4, "size=%d" % fc.config.get("fuentes", []).size())
	var museo = fc.fuente("museo_moderno")
	_check("museo_moderno existe", not museo.is_empty() and museo.get("licencia", "") == "OFL")
	_check("fuente inexistente -> {}", fc.fuente("no_existe").is_empty())
	var body = fc.fuentes_por_familia("body")
	_check("familia body (1)", body.size() == 1, "size=%d" % body.size())
	_check("licencias permitidas (4)", fc.licencias_permitidas().size() == 4)

func _test_auditor() -> void:
	print("--- FontAuditor: data real ---")
	var fc := root.get_node_or_null("FontCatalog")
	var errores = fc.auditar()
	_check("catálogo válido (0 errores)", errores.is_empty(), "errores=%s" % str(errores))
	_check("reporte OK", _SC_AUDITOR.reporte([]).contains("OK"))

func _test_auditor_errores() -> void:
	print("--- FontAuditor: errores detectados ---")
	var malo = {
		"licencias_permitidas": ["OFL"],
		"fuentes": [
			{"id": "", "licencia": "", "pesos": []},
			{"id": "a", "licencia": "BSD", "pesos": ["regular"]},
			{"id": "b", "licencia": "OFL", "pesos": []}
		]
	}
	var errores = _SC_AUDITOR.validar(malo)
	_check("sin licencia detectado", str(errores).contains("sin licencia"))
	_check("licencia no permitida detectada", str(errores).contains("BSD"))
	_check("sin pesos detectado", str(errores).contains("sin pesos"))

func _summary() -> void:
	print("=== Resumen M88: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M88 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M88 OK — todos los checks pasaron")
		quit(0)