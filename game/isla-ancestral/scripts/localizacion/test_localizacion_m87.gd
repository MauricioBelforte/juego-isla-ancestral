# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M87: Localización — Test headless
# Valida: LocalizationManager (catálogos ES/EN, get_texto con fallback,
# set_idioma, idiomas disponibles). Exit code != 0 si falla.

extends SceneTree

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M87] Test de Localización ===")
	_test_config()
	_test_texto()
	_test_idiomas()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _test_config() -> void:
	print("--- Config: catálogos ES/EN ---")
	var lm := root.get_node_or_null("LocalizationManager")
	if lm == null:
		_check("LocalizationManager autoload presente", false)
		_summary()
		quit(1)
		return
	_check("LocalizationManager autoload presente", true)
	_check("2 idiomas", lm.idiomas_disponibles().size() == 2, "size=%d" % lm.idiomas_disponibles().size())
	_check("11 cadenas ES", lm.cantidad_cadenas("es") == 11, "size=%d" % lm.cantidad_cadenas("es"))
	_check("11 cadenas EN", lm.cantidad_cadenas("en") == 11, "size=%d" % lm.cantidad_cadenas("en"))

func _test_texto() -> void:
	print("--- get_texto: traducción y fallback ---")
	var lm := root.get_node_or_null("LocalizationManager")
	lm.set_idioma("es")
	_check("ui.inventario ES", lm.get_texto("ui.inventario") == "Inventario")
	_check("npc.adios ES", lm.get_texto("npc.adios") == "Adiós")
	lm.set_idioma("en")
	_check("ui.inventario EN", lm.get_texto("ui.inventario") == "Inventory")
	_check("clave inexistente -> clave", lm.get_texto("clave_no_existe") == "clave_no_existe")

func _test_idiomas() -> void:
	print("--- set_idioma y persistencia ---")
	var lm := root.get_node_or_null("LocalizationManager")
	_check("set_idioma('en') ok", lm.set_idioma("en") == true)
	_check("set_idioma inexistente -> false", lm.set_idioma("fr") == false)
	_check("idioma actual = en", lm.idioma_actual == "en")
	lm.set_idioma("es")

func _summary() -> void:
	print("=== Resumen M87: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M87 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M87 OK — todos los checks pasaron")
		quit(0)