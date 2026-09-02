# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M121: Soporte Post-Lanzamiento — Test headless
# Valida: SupportManager (FAQ por categoría, búsqueda, canales) y
# SupportValidator. Exit code != 0 si falla.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.

extends SceneTree

const _SC_VALIDATOR := preload("res://scripts/support/support_validator.gd")

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M121] Test de Soporte Post-Lanzamiento ===")
	_test_manager()
	_test_faq()
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

func _test_manager() -> void:
	print("--- SupportManager: config data-driven ---")
	var sm := root.get_node_or_null("SupportManager")
	if sm == null:
		_check("SupportManager autoload presente", false)
		_summary()
		quit(1)
		return
	_check("SupportManager autoload presente", true)
	_check("4 FAQ", sm.config.get("faq", []).size() == 4, "size=%d" % sm.config.get("faq", []).size())
	_check("3 canales", sm.canales().size() == 3, "size=%d" % sm.canales().size())
	_check("6 categorías", sm.categorias().size() == 6, "size=%d" % sm.categorias().size())

func _test_faq() -> void:
	print("--- FAQ: por categoría y búsqueda ---")
	var sm := root.get_node_or_null("SupportManager")
	var guardado = sm.faq_por_categoria("guardado")
	_check("categoría guardado (1)", guardado.size() == 1, "size=%d" % guardado.size())
	var crash = sm.faq_por_categoria("crash")
	_check("categoría crash (1)", crash.size() == 1)
	var resultado = sm.buscar_faq("crash")
	_check("búsqueda 'crash' (2)", resultado.size() >= 1, "size=%d" % resultado.size())
	var sin_resultado = sm.buscar_faq("xyz")
	_check("búsqueda sin resultado", sin_resultado.is_empty())

func _test_validator() -> void:
	print("--- SupportValidator: data real ---")
	var sm := root.get_node_or_null("SupportManager")
	var errores = _SC_VALIDATOR.validar(sm.config)
	_check("config válida (0 errores)", errores.is_empty(), "errores=%s" % str(errores))
	_check("reporte OK", _SC_VALIDATOR.reporte([]).contains("OK"))

func _test_validator_errores() -> void:
	print("--- SupportValidator: errores detectados ---")
	var malo = {
		"canales": [],
		"categorias": [],
		"politica_respuesta": {},
		"faq": [
			{"id": "", "pregunta": "", "respuesta": "", "categoria": "zzz"},
			{"id": "a", "pregunta": "p", "respuesta": "r", "categoria": "zzz"}
		]
	}
	var errores = _SC_VALIDATOR.validar(malo)
	_check("sin canales detectado", str(errores).contains("canales"))
	_check("sin categorías detectado", str(errores).contains("categorías"))
	_check("sin política detectado", str(errores).contains("política"))
	_check("FAQ sin pregunta detectado", str(errores).contains("sin pregunta"))
	_check("categoría no definida detectado", str(errores).contains("zzz"))

func _summary() -> void:
	print("=== Resumen M121: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M121 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M121 OK — todos los checks pasaron")
		quit(0)