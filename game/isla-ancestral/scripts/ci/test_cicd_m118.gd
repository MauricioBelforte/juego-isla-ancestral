# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M118: CI/CD — Test headless
# Valida: CiCdManager (carga de ci_gates.json, verificación de gates,
# resultados, checklist de integración, reportes). Exit code != 0 si falla.

extends SceneTree

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M118] Test de CI/CD ===")
	_test_config()
	_test_gates()
	_test_checklist()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _test_config() -> void:
	print("--- Config: ci_gates.json ---")
	var ci := root.get_node_or_null("CiCdManager")
	if ci == null:
		_check("CiCdManager autoload presente", false)
		_summary()
		quit(1)
		return
	_check("CiCdManager autoload presente", true)
	_check("3 gates configurados", ci.config.get("gates", {}).size() == 3, "size=%d" % ci.config.get("gates", {}).size())
	_check("checklist con 5 ítems", ci.checklist_integracion().size() == 5, "size=%d" % ci.checklist_integracion().size())

func _test_gates() -> void:
	print("--- Gates: verificación con resultados ---")
	var ci := root.get_node_or_null("CiCdManager")
	# Sin resultados -> gate PR falla
	var sin_resultados = ci.verificar_gate("pr")
	_check("gate PR sin resultados falla", not sin_resultados["ok"])
	# Marcar todos los requisitos del PR
	ci.registrar_resultado("lint", true)
	ci.registrar_resultado("tests_rapidos", true)
	ci.registrar_resultado("stress_save", true)
	var con_resultados = ci.verificar_gate("pr")
	_check("gate PR con resultados OK", con_resultados["ok"], "faltantes=%s" % str(con_resultados["faltantes"]))
	# Gate inexistente
	var inexistente = ci.verificar_gate("no_existe")
	_check("gate inexistente falla", not inexistente["ok"])
	# Reportes
	var reporte_ok = ci.reporte_gate("pr")
	_check("reporte OK contiene OK", reporte_ok.contains("OK"))

func _test_checklist() -> void:
	print("--- Checklist de integración ---")
	var ci := root.get_node_or_null("CiCdManager")
	var checklist = ci.checklist_integracion()
	var ids: Array = []
	for item in checklist:
		ids.append(item.get("id", ""))
	_check("build_limpio en checklist", "build_limpio" in ids)
	_check("docs_actualizadas en checklist", "docs_actualizadas" in ids)
	_check("logs_generados en checklist", "logs_generados" in ids)

func _summary() -> void:
	print("=== Resumen M118: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M118 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M118 OK — todos los checks pasaron")
		quit(0)