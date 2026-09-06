# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-04
#
# M87: Test iteración 4 — robustez determinista (edge cases).
# Complementa test_localization.gd (núcleo) + iter2 + iter3.
# Foco: parseo .po corrupto sin crash (T-084), placeholders mal formados
# (T-085/T-086/T-087), estado de catálogos RF21 (missing/vacías), edge cases
# de fecha n=0/negativos, contexto gettext con catálogo real.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/localization/test_localizacion_iter4.gd

extends SceneTree

var _fallos: int = 0
var _loc: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_loc = root.get_node_or_null("Localization")
	_check(_loc != null, "Localization autoload presente")
	if _loc == null:
		print("=== TEST M87 ITER4: 1 fallo(s) ===")
		quit(1)
		return
	_test_parseo_po_corrupto()
	_test_format_text_edge_cases()
	_test_estado_catalogos()
	_test_plurales_numeros_fechas_edge()
	_test_contexto_clave_compuesta()
	print("=== TEST M87 ITER4: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

## T-084: .po con msgstr[ malformado/ausente no tira error de parseo → el
## catálogo se degrada con gracia y las claves sanas siguen traduciendo.
func _test_parseo_po_corrupto() -> void:
	var po_corrupto := "res://locales_test/po_corrupto.po"
	var dir := DirAccess.open("res://")
	if not dir.dir_exists("locales_test"):
		dir.make_dir("locales_test")
	var f := FileAccess.open(po_corrupto, FileAccess.WRITE)
	f.store_string("msgid \"K.SANA\"\nmsgstr \"Sana\"\n")
	f.store_string("msgid \"K.PLURAL\"\nmsgid_plural \"K.PLURAL\"\n")
	f.store_string("msgstr[0] \"Uno\"\nmsgstr[1] \"Varios\"\n")
	f.store_string("msgid \"K.CORRUPTA\"\nmsgstr[sin_indice] \"Roto\"\n")
	f.store_string("msgid \"K.MAL_CIERRE\"\nmsgstr[99] \"Fuera de rango\"\n")
	f.close()
	var resultado: Dictionary = _loc._parse_po(po_corrupto)
	_check(resultado.mensajes.get("K.SANA", "") == "Sana", "clave sana parseada: " + str(resultado.mensajes.get("K.SANA")))
	var formas: Array = resultado.plural_func.get("K.PLURAL", [])
	var plural_sano: bool = formas.size() == 2 and formas[0] == "Uno" and formas[1] == "Varios"
	_check(plural_sano, "plural sano conservado: " + str(formas))
	_check(not resultado.mensajes.has("K.CORRUPTA"), "msgstr[ sin índice omitido sin crash")
	_check(not resultado.mensajes.has("K.MAL_CIERRE"), "msgstr[99] fuera de rango omitido sin crash")
	_dir_recursivo("res://locales_test/")

## T-085/T-086/T-087: placeholder sin cierre no rompe; sin valor queda literal;
## params extra no usan no dañan el texto.
func _test_format_text_edge_cases() -> void:
	var t1: String = _loc.format_text("Hola {mundo", {"mundo": "X"})
	_check(t1 == "Hola {mundo", "placeholder sin cierre queda literal: " + t1)
	var t2: String = _loc.format_text("Hola {nombre}", {})
	_check(t2 == "Hola {nombre}", "placeholder sin valor queda literal: " + t2)
	var t3: String = _loc.format_text("Solo {a}", {"a": "1", "b": "2", "c": "3"})
	_check(t3 == "Solo 1", "params extra no usados ignorados: " + t3)
	var t4: String = _loc.format_text("Sin placeholders", {})
	_check(t4 == "Sin placeholders", "texto sin placeholders intacto")
	var t5: String = _loc.format_text("{a}{b}{a}", {"a": "x", "b": "y"})
	_check(t5 == "xyx", "multiples placeholders repetidos: " + t5)

## RF21 ampliado: obtener_estado_catalogos reporta faltantes/vacías por idioma.
func _test_estado_catalogos() -> void:
	var estado: Dictionary = _loc.obtener_estado_catalogos()
	_check(estado.has("es") and estado.has("en"), "estado cubre es+en")
	_check(bool(estado["es"].ok), "es (fuente) siempre ok")
	# en.po debe cubrir el subconjunto del es.po representado en el boot
	_check(estado["en"].has("total"), "en tiene total")
	_check(typeof(estado["en"].faltantes) == TYPE_ARRAY, "en faltantes es array")

func _test_plurales_numeros_fechas_edge() -> void:
	_loc.set_locale("es")
	# n=0 (es: plural), n=1 (singular), n=2 (plural), n=-3 (plural), n decimal vía int
	_check(_loc.tr_key("ITEMS", "SE_OFRECEN", "", {}, 0) == "Se ofrecen 0 objetos", "es n=0 plural: " + _loc.tr_key("ITEMS", "SE_OFRECEN", "", {}, 0))
	_check(_loc.tr_key("ITEMS", "SE_OFRECEN", "", {}, 2) == "Se ofrecen 2 objetos", "es n=2 plural: " + _loc.tr_key("ITEMS", "SE_OFRECEN", "", {}, 2))
	_check(_loc.tr_key("ITEMS", "SE_OFRECEN", "", {}, -3) == "Se ofrecen -3 objetos", "es n=-3 plural: " + _loc.tr_key("ITEMS", "SE_OFRECEN", "", {}, -3))
	_check(_loc.format_number(0.0) == "0,00", "es 0,00: " + _loc.format_number(0.0))
	_check(_loc.format_number(-1234.5) == "-1.234,50", "es negativo: " + _loc.format_number(-1234.5))
	_check(_loc.format_number(1e6) == "1.000.000,00", "es millón: " + _loc.format_number(1e6))
	_loc.set_locale("en")
	_check(_loc.format_number(-1234.5) == "-1,234.50", "en negativo: " + _loc.format_number(-1234.5))
	_check(_loc.format_hora(0, 5) == "12:05 AM", "en medianoche 12h: " + _loc.format_hora(0, 5))
	# Fechas: año < 1000 (relleno 4 dígitos) y día/mes de un dígito (relleno 2)
	_loc.set_locale("es")
	_check(_loc.format_date(7, 3, 26) == "07/03/0026", "es fecha relleno: " + _loc.format_date(7, 3, 26))

func _test_contexto_clave_compuesta() -> void:
	# El mecanismo gettext usa clave compuesta "ctx|clave"; sin entrada de contexto
	# en el .po real cae al fallback (clave literal) pero NO rompe ni devuelve vacío
	var t1: String = _loc.tr_ctx("ui", "MENUS", "BOTONES", "CERRAR")
	var t2: String = _loc.tr_ctx("narrativa", "MENUS", "BOTONES", "CERRAR")
	_check(t1 != "" and t2 != "", "tr_ctx devuelve strings no vacíos")
	_check(_loc.tr_key("MENUS", "BOTONES", "ui|CERRAR") == t1, "tr_ctx == tr_key compuesta")

func _dir_recursivo(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir != null:
		for archivo in dir.get_files():
			dir.remove(archivo)
	DirAccess.remove_absolute(path) if DirAccess.dir_exists_absolute(path) else null