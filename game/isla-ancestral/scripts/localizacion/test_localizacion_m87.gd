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
	_test_pt()
	_test_interpolacion()
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
	_check("3 idiomas", lm.idiomas_disponibles().size() == 3, "size=%d" % lm.idiomas_disponibles().size())
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

func _test_pt() -> void:
	print("--- Nuevo idioma pt (portugués) ---")
	var lm := root.get_node_or_null("LocalizationManager")
	_check("3 idiomas (es/en/pt)", lm.idiomas_disponibles().size() == 3, "size=%d" % lm.idiomas_disponibles().size())
	_check("11 cadenas PT", lm.cantidad_cadenas("pt") == 11, "size=%d" % lm.cantidad_cadenas("pt"))
	_check("ui.inventario PT", lm.get_texto("ui.inventario", {}, "pt") == "Inventário")
	_check("npc.hola PT", lm.get_texto("npc.hola", {}, "pt") == "Olá")

func _test_interpolacion() -> void:
	print("--- Interpolación de {vars} ---")
	var lm := root.get_node_or_null("LocalizationManager")
	lm.set_cadena("es", "msg.tienes", "Tienes {n} objetos")
	_check("interpolación n=5", lm.get_texto("msg.tienes", {"n": 5}) == "Tienes 5 objetos")
	_check("interpolación n=1", lm.get_texto("msg.tienes", {"n": 1}) == "Tienes 1 objetos")
	lm.set_cadena("es", "msg.bienvenido", "Hola {nombre}, bienvenido a {isla}")
	_check("interpolación múltiple", lm.get_texto("msg.bienvenido", {"nombre": "Ana", "isla": "Aurora"}) == "Hola Ana, bienvenido a Aurora")

func _summary() -> void:
	print("=== Resumen M87: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M87 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M87 OK — todos los checks pasaron")
		quit(0)