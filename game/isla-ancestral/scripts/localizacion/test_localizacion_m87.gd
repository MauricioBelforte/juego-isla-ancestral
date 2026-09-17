# Modelo: deepseek-v4-flash (iter. 1) · DeepSeek-V4.1-Flash / WorkBuddy (fix BUG-032)
# Plataforma: Kilo Code (iter. 1) · WorkBuddy (fix BUG-032)
# Fecha: 2026-09-02 (iter. 1) · 2026-09-14 (fix BUG-032)
#
# M87: Localización — Test headless
# Valida: LocalizationManager (catálogos ES/EN, get_texto con fallback,
# set_idioma, idiomas disponibles). Exit code != 0 si falla.
#
# ⚠️ Este test apunta al autoload **`LocalizationManager`**
# (`scripts/localizacion/localization_manager.gd`, data-driven desde
# `data/localizacion/strings_*.json`), que es el que consumen M16
# (`inventario_iter4.gd`) y M131 (`credits_manager.gd`). Existe ADEMÁS el autoload
# **`Localization`** (`scripts/localization/localization_manager.gd`, catálogos
# `.po`, 85 claves) que consume M21. Son DOS implementaciones vivas: duplicado
# arquitectónico registrado como hallazgo H-1 en `148-.../`→ ver Log 874/882.
#
# fix BUG-032 (2026-09-14): las aserciones de conteo estaban fijadas a 11 claves
# y el catálogo semilla creció a 25 → **false-red** en CI/QA (3 fallos con el
# módulo funcionalmente correcto). Ahora se compara contra el **JSON fuente**
# leído en tiempo de test (detecta carga parcial sin romperse en cada expansión)
# y se exige un mínimo histórico. No volver a fijar el número.

extends SceneTree

const DIR_LOC := "res://data/localizacion/"
const MIN_CADENAS := 11   # mínimo histórico del catálogo semilla (M87 iter. 1)

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

## Nº de claves del JSON fuente del idioma (-1 si no se puede leer).
## Es la fuente de verdad: comparar contra él detecta una carga parcial del
## catálogo sin fijar un número que se rompa en cada expansión (BUG-032).
func _cadenas_en_json(lang: String) -> int:
	var ruta := "%sstrings_%s.json" % [DIR_LOC, lang]
	if not FileAccess.file_exists(ruta):
		return -1
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(ruta))
	if typeof(parsed) != TYPE_DICTIONARY:
		return -1
	var cadenas: Variant = (parsed as Dictionary).get("cadenas", {})
	if typeof(cadenas) != TYPE_DICTIONARY:
		return -1
	return (cadenas as Dictionary).size()

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
	# Conteo contra el JSON fuente (no fijo): el catálogo real tiene 25 claves.
	var n_es := _cadenas_en_json("es")
	var n_en := _cadenas_en_json("en")
	_check("catálogo ES cargado completo (%d claves)" % n_es, lm.cantidad_cadenas("es") == n_es,
		"manager=%d json=%d" % [lm.cantidad_cadenas("es"), n_es])
	_check("catálogo EN cargado completo (%d claves)" % n_en, lm.cantidad_cadenas("en") == n_en,
		"manager=%d json=%d" % [lm.cantidad_cadenas("en"), n_en])
	_check("catálogo ES no vacío (>= %d)" % MIN_CADENAS, lm.cantidad_cadenas("es") >= MIN_CADENAS,
		"size=%d" % lm.cantidad_cadenas("es"))

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
	var n_pt := _cadenas_en_json("pt")
	_check("catálogo PT cargado completo (%d claves)" % n_pt, lm.cantidad_cadenas("pt") == n_pt,
		"manager=%d json=%d" % [lm.cantidad_cadenas("pt"), n_pt])
	# Coherencia: los 3 idiomas deben exponer el MISMO nº de claves (un idioma
	# rezagado = traducción incompleta, regresión real de datos).
	# ⚠️ Tipo explícito: `lm` es `Node`, así que `:=` no puede inferir (trampa §8).
	var c_es: int = lm.cantidad_cadenas("es")
	var c_en: int = lm.cantidad_cadenas("en")
	var c_pt: int = lm.cantidad_cadenas("pt")
	_check("los 3 idiomas tienen el mismo nº de claves", c_es == c_en and c_en == c_pt,
		"es=%d en=%d pt=%d" % [c_es, c_en, c_pt])
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