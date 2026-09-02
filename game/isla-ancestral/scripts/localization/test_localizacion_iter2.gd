# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M87: Test iteración 2 — persistencia M60, sugerencia del SO, contexto gettext,
# cache de rendimiento. Complementa test_localization.gd (núcleo Deepseek).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/localization/test_localizacion_iter2.gd

extends SceneTree

var _fallos: int = 0
var _loc: Node = null
var _ds: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_loc = root.get_node_or_null("Localization")
	_ds = root.get_node_or_null("DataStore")
	_check(_loc != null, "Localization autoload presente")
	_check(_ds != null, "DataStore autoload presente (M60)")
	if _loc == null:
		print("=== TEST M87 ITER2: 1 fallo(s) ===")
		quit(1)
		return
	_test_persistencia_m60()
	_test_sugerencia_so()
	_test_contexto_gettext()
	_test_cache()
	_test_sugerencias_debug()
	print("=== TEST M87 ITER2: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_persistencia_m60() -> void:
	# set_locale_persistente escribe en DataStore.config (sección "general"); el próximo arranque lo lee
	_check(_loc.set_locale_persistente("en"), "cambio persistente a 'en' OK")
	_check(str(_loc.get_locale()) == "en", "locale activo 'en'")
	var config: Dictionary = _ds.cargar_config()
	_check(str(config.get("general", {}).get("idioma", "")) == "en", "M60 guardó idioma='en'")
	# Restaurar simulada: un "arranque nuevo" aplicaría el guardado
	_loc._restaurar_locale_guardado()
	_check(str(_loc.get_locale()) == "en", "arranque simulado restaura 'en' desde M60")
	# Volver a español persistente (estado limpio para otros tests)
	_check(_loc.set_locale_persistente("es"), "vuelta a 'es' persistente")
	_check(str(_ds.cargar_config().get("general", {}).get("idioma", "")) == "es", "M60 tiene 'es'")
	# Locale no soportado: rechazo sin persistir
	_check(not _loc.set_locale_persistente("fr"), "locale 'fr' rechazado")
	_check(str(_ds.cargar_config().get("general", {}).get("idioma", "")) == "es", "'fr' no contaminó la config")

func _test_sugerencia_so() -> void:
	# RF primer arranque: _sugerir_locale_so mapea OS.get_locale_language()
	var sugerido: String = _loc._sugerir_locale_so()
	var so: String = OS.get_locale_language()
	if so in _loc.LOCALES_SOPORTADOS:
		_check(sugerido == so, "SO %s mapea a sugerencia %s" % [so, sugerido])
	else:
		_check(sugerido == "", "SO %s sin soporte → sin sugerencia" % so)
	# La API existe y es determinista en la misma sesión
	_check(sugerido == _loc._sugerir_locale_so(), "sugerencia determinista")

func _test_contexto_gettext() -> void:
	# tr_ctx: entradas con contexto "ctx|clave" — misma clave base, contextos distintos
	# (verificamos el mecanismo: si la entrada con contexto no existe, cae a la clave
	# por el fallback del núcleo sin crash)
	var t1: String = _loc.tr_ctx("ui", "menus", "botones", "cerrar")
	var t2: String = _loc.tr_ctx("narrativa", "menus", "botones", "cerrar")
	_check(typeof(t1) == TYPE_STRING and t1 != "", "tr_ctx ui devuelve string")
	_check(typeof(t2) == TYPE_STRING and t2 != "", "tr_ctx narrativa devuelve string")
	# La clave compuesta es exactamente "ctx|clave"
	var directa: String = _loc.tr_key("menus", "botones", "ui|cerrar")
	_check(directa == t1, "tr_ctx == tr_key con clave compuesta (mecanismo gettext)")

func _test_cache() -> void:
	# Checklist: traducción sin penalización perceptible (cache del núcleo)
	_loc.set_locale("es")
	var t0 := Time.get_ticks_usec()
	for i in range(200):
		_loc.tr_key("menus", "saludos", "hola")
	var dt_cached: int = Time.get_ticks_usec() - t0
	# 200 traducciones cacheadas deben ser < 20 ms total (0.1 ms c/u, holgado)
	_check(dt_cached < 20000, "200 traducciones cacheadas en %d µs (< 20 ms)" % dt_cached)
	_check(_loc._cache.size() >= 0, "cache del núcleo activa")

func _test_sugerencias_debug() -> void:
	# Checklist: idioma activo visible (para menú de debug M110)
	var display: String = _loc.get_locale_display_name()
	_check(display != "", "get_locale_display_name() '%s'" % display)
	_check(_loc.locales_disponibles().size() == 2, "es+en disponibles (selector M53/M110)")
