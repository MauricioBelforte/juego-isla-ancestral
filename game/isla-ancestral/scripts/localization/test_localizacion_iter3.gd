# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M87: Test iter. 3 — integración M88 (cobertura de caracteres por idioma,
# FontLoader selecciona fuente según idioma activo).
# Ejecutar: Godot --headless --path game\isla-ancestral --script res://scripts/localization/test_localizacion_iter3.gd

extends SceneTree

# --- Guardia anti-falso-verde (3 capas): _fin() por bloque + CHECKS_MINIMOS MEDIDO
#     + _summary() diferido. Instrumentacion LOTE 2 (mis suites propias), 2026-10-08,
#     DeepSeek-V4.1-Flash (msg 100). Piso = checks reales MEDIDOS (Log 1490).
#     NO cambia logica ni aserciones; solo agrega contador + control de bloques.
const CHECKS_MINIMOS := 12
const _WB_BLOQUES: Array[String] = ["_test_cobertura_data", "_test_fuente_por_idioma", "_test_validacion_cobertura"]
var _checks: int = 0
var _wb_vistos: Dictionary = {}
var _wb_cerrado: bool = false

func _fin(nombre: String) -> void:
	_wb_vistos[nombre] = true


func _summary() -> void:
	if _wb_cerrado:
		return
	_wb_cerrado = true
	for b in _WB_BLOQUES:
		if not _wb_vistos.has(b):
			_fallos += 1
			print("[FAIL] bloque %s NO se ejecuto (posible SCRIPT ERROR)" % b)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen M87: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)



var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	var loc := root.get_node_or_null("Localization")
	_check(loc != null, "Localization presente")
	if loc == null:
		print("=== TEST M87 ITER3: 1+ fallo(s) ===")
		_summary()
		return
	var script_catalog := load("res://scripts/fonts/font_catalog.gd")
	var catalog = script_catalog.new()
	root.add_child(catalog)
	_test_cobertura_data(catalog)
	_fin("_test_cobertura_data")
	_test_fuente_por_idioma(catalog, loc)
	_fin("_test_fuente_por_idioma")
	_test_validacion_cobertura(catalog)
	_fin("_test_validacion_cobertura")
	catalog.queue_free()
	_summary()

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_cobertura_data(catalog) -> void:
	# El catálogo declara cobertura por fuente (data-driven)
	_check(catalog.soporta_idioma("texto_cozy", "es"), "texto_cozy soporta es")
	_check(catalog.soporta_idioma("texto_cozy", "en"), "texto_cozy soporta en")
	_check(not catalog.soporta_idioma("texto_cozy", "ru"), "texto_cozy NO soporta ru")
	_check(catalog.soporta_idioma("museo_moderno", "en"), "museo_moderno soporta todos")
	_check(catalog.soporta_idioma("script_isla", "es"), "script_isla soporta es")
	_check(not catalog.soporta_idioma("script_isla", "en"), "script_isla NO soporta en")

func _test_fuente_por_idioma(catalog, loc) -> void:
	# FontLoader: fuente del body según idioma activo
	loc.set_locale("es")
	var f_es: Dictionary = catalog.fuente_para_idioma("es")
	_check(not f_es.is_empty(), "fuente body para es existe")
	_check(String(f_es.get("id", "")) == "texto_cozy", "es → texto_cozy (cobertura es,en)")
	loc.set_locale("en")
	var f_en: Dictionary = catalog.fuente_para_idioma("en")
	_check(String(f_en.get("id", "")) == "texto_cozy", "en → texto_cozy (último cambio de locale persiste)")
	loc.set_locale("es")

func _test_validacion_cobertura(catalog) -> void:
	# RF14: cobertura para los locales activos (es, en) sin errores
	var errores: Array = catalog.validar_cobertura_idiomas(["es", "en"])
	_check(errores.is_empty(), "todas las fuentes cubren es/en (%s)" % str(errores))
	# Con un locale que 2 fuentes no cubren (texto_cozy es/en, script_isla es):
	# las de cobertura "todos" (museo_moderno, mono_debug) sí cubren
	var errores_ru: Array = catalog.validar_cobertura_idiomas(["ru"])
	_check(errores_ru.size() == 2, "locale ru sin cobertura: 2 fuentes no cubren (%d)" % errores_ru.size())
