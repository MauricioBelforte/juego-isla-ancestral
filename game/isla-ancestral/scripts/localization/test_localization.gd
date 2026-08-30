# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M87: Test de LocalizationManager + LocaleUtils.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/localization/test_localization.gd

extends SceneTree

var _fallos: int = 0
var _loc: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_loc = root.get_node_or_null("Localization")
	_check(_loc != null, "Localization autoload presente")
	if _loc == null:
		print("=== TEST M87 LOCALIZACION: 1 fallo(s) ===")
		quit(1)
		return
	_test_catalogos()
	_test_traduccion_es()
	_test_traduccion_en()
	_test_placeholders_y_plurales()
	_test_formato()
	_test_fallback()
	print("=== TEST M87 LOCALIZACION: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_catalogos() -> void:
	_check(_loc.locales_disponibles().size() == 2, "2 idiomas soportados")
	var faltantes: Array = _loc.validar_catalogos()
	_check(faltantes.is_empty(), "sin claves faltantes en: " + str(faltantes))

func _test_traduccion_es() -> void:
	_loc.set_locale("es")
	_check(_loc.get_locale() == "es", "locale es")
	var texto: String = _loc.tr_key("MAIN_MENU", "PLAY", "")
	_check(texto == "Jugar", "es: MAIN_MENU.PLAY = " + texto)
	_check(_loc.get_locale_display_name() == "Español", "nombre nativo es = Español")

func _test_traduccion_en() -> void:
	var ok: bool = _loc.set_locale("en")
	_check(ok, "set_locale en OK")
	_check(_loc.get_locale() == "en", "locale en")
	var texto: String = _loc.tr_key("MAIN_MENU", "PLAY", "")
	_check(texto == "Play", "en: MAIN_MENU.PLAY = " + texto)
	_check(_loc.get_locale_display_name() == "English", "nombre nativo en = English")

func _test_placeholders_y_plurales() -> void:
	_loc.set_locale("es")
	var singular: String = _loc.tr_key("ITEMS", "SE_OFRECEN", "", {}, 1)
	_check(singular == "Se ofrece 1 objeto", "es plural n=1: " + singular)
	var plural: String = _loc.tr_key("ITEMS", "SE_OFRECEN", "", {}, 5)
	_check(plural == "Se ofrecen 5 objetos", "es plural n=5: " + plural)
	_loc.set_locale("en")
	var en_sing: String = _loc.tr_key("ITEMS", "SE_OFRECEN", "", {}, 1)
	_check(en_sing == "Offering 1 item", "en plural n=1: " + en_sing)
	var ft: String = _loc.format_text("Hola {nombre}", {"nombre": "Ana"})
	_check(ft == "Hola Ana", "format_text: " + ft)

func _test_formato() -> void:
	_loc.set_locale("es")
	_check(_loc.format_number(1234.56) == "1.234,56", "es numero: " + _loc.format_number(1234.56))
	_check(_loc.format_date(17, 8, 2026) == "17/08/2026", "es fecha: " + _loc.format_date(17, 8, 2026))
	_check(_loc.format_hora(14, 30) == "14:30", "es hora 24h: " + _loc.format_hora(14, 30))
	_loc.set_locale("en")
	_check(_loc.format_number(1234.56) == "1,234.56", "en numero: " + _loc.format_number(1234.56))
	_check(_loc.format_date(17, 8, 2026) == "08/17/2026", "en fecha: " + _loc.format_date(17, 8, 2026))
	_check(_loc.format_hora(14, 30) == "2:30 PM", "en hora 12h: " + _loc.format_hora(14, 30))

func _test_fallback() -> void:
	_loc.set_locale("en")
	_check(_loc.tr_key("HUD", "ENERGIA", "") == "Energy", "en HUD.ENERGIA")
	_loc._catalogs["es"]["TEST.FALLBACK"] = "Texto espanol"
	var fallback: String = _loc.tr_key("TEST", "FALLBACK", "")
	_check(fallback == "Texto espanol", "fallback a espanol: " + fallback)
	var literal: String = _loc.tr_key("NOPE", "NOPE", "X")
	_check(literal != "", "clave inexistente no vacia: " + literal)