# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M87: Localización — LocalizationManager (autoload "Localization").
# Capa central de gestión de idioma (RF1-RF24): carga catálogos .po en
# TranslationServer, cambia idioma en vivo, traduce con placeholders/plurales,
# formatea números/fechas, fallback a español y valida catálogos (RF21).
# ⚠️ Sin class_name: es autoload (pitfall 07-GUIA-GODOT §9.17/§9.41).

extends Node

signal locale_changed(locale: String)

const LOCALES_SOPORTADOS := ["es", "en"]
const LOCALE_DEFECTO := "es"
const RUTA_CATALOGOS := "res://locales/"

var _locale_actual: String = LOCALE_DEFECTO
var _cache: Dictionary = {}          # "clave|n" -> texto (RF cache)
var _catalogs: Dictionary = {}       # locale -> Dictionary(clave -> texto)
var _plural_forms: Dictionary = {}   # locale -> func_n identidad

func _ready() -> void:
	_cargar_catalogos()
	_restaurar_locale_guardado()

## ── Carga de catálogos ───────────────────────────────────

func _cargar_catalogos() -> void:
	for locale in LOCALES_SOPORTADOS:
		var path: String = RUTA_CATALOGOS + locale + ".po"
		var data: Dictionary = _parse_po(path)
		_catalogs[locale] = data.mensajes
		_plural_forms[locale] = data.plural_func
		# Registrar en TranslationServer (para tr() estándar si alguien lo usa)
		var trans := Translation.new()
		trans.locale = locale
		for clave in data.mensajes:
			trans.add_message(clave, str(data.mensajes[clave]))
		TranslationServer.add_translation(trans)

func _restaurar_locale_guardado() -> void:
	# glm-5.3-flash (2026-09-01, iter. 2): persistencia REAL vía M60 DataStore
	# (el núcleo consultaba GameSettings que no existe — placeholder honesto).
	# Orden: config M60 → (primer arranque) sugerencia del SO → español.
	var guardado := _leer_locale_m60()
	if guardado != "" and guardado in LOCALES_SOPORTADOS:
		_aplicar_locale(guardado)
		return
	# RF primer arranque: sugerir el idioma del SO con confirmación pendiente
	# (la UI de confirmación es de M53; acá solo proponemos y persistimos la
	# sugerencia como locale activo si el SO soporta uno de los disponibles).
	var sugerido := _sugerir_locale_so()
	if sugerido != "" and sugerido in LOCALES_SOPORTADOS:
		_aplicar_locale(sugerido)
		print("[M87] Primer arranque: sugerido idioma del SO '%s' (confirmación con M53)" % sugerido)
		_persistir_locale(sugerido)
		return
	_aplicar_locale(LOCALE_DEFECTO)

## Persistencia vía M60 DataStore (sección "general" de gestor_config)
func _leer_locale_m60() -> String:
	var ds := get_node_or_null("/root/DataStore")
	if ds == null or not ds.has_method("cargar_config"):
		return ""
	var config: Dictionary = ds.cargar_config()
	var general: Dictionary = config.get("general", {})
	return str(general.get("idioma", ""))


func _sugerir_locale_so() -> String:
	var so := OS.get_locale_language()  # "es", "en", ...
	if so in LOCALES_SOPORTADOS:
		return so
	return ""

## ── API pública ──────────────────────────────────────────

## Cambia el idioma y persiste la elección (checklist "persistir entre sesiones")
func set_locale_persistente(locale: String) -> bool:
	var ok := set_locale(locale)
	if ok:
		_persistir_locale(locale)
	return ok

## Contexto gettext (checklist "entradas con contexto"): clave "ctx|clave"
## desambigua términos iguales con traducciones distintas (ej. "Cerrar" botón
## vs "Cerrar" narrativo). El .po guarda las entradas con el prefijo.
func tr_ctx(contexto: String, module: String, section: String, key: String, params: Dictionary = {}) -> String:
	return tr_key(module, section, contexto + "|" + key, params)

func set_locale(locale: String) -> bool:
	if not locale in LOCALES_SOPORTADOS:
		push_warning("[M87] Locale no soportado: " + locale)
		return false
	_aplicar_locale(locale)
	_persistir_locale(locale)
	return true

func get_locale() -> String:
	return _locale_actual

func get_locale_display_name() -> String:
	return LocaleUtils.get_nombre_nativo(_locale_actual)

func locales_disponibles() -> Array:
	return LOCALES_SOPORTADOS

func _aplicar_locale(locale: String) -> void:
	_locale_actual = locale
	_cache.clear()
	TranslationServer.set_locale(locale)
	locale_changed.emit(locale)

## Traduce `MODULO.SECCION.CLAVE` con params y opcional plural (n).
func tr_key(module: String, section: String, key: String, params: Dictionary = {}, n: int = -1) -> String:
	var clave := (module + "." + section).to_upper()
	if key != "":
		clave += "." + key.to_upper()
	return _tr_clave(clave, params, n)

## Traduce una clave completa ya formada (útil para catálogos).
func _tr_clave(clave: String, params: Dictionary = {}, n: int = -1) -> String:
	var cache_key := clave + "|" + str(n)
	if _cache.has(cache_key):
		return _cache[cache_key]
	var texto := _buscar_texto(clave, n)
	# Inyectar {n} del plural si no viene en params
	var params_final := params.duplicate()
	if n >= 0 and not params_final.has("n"):
		params_final["n"] = n
	var resuelto := format_text(texto, params_final)
	_cache[cache_key] = resuelto
	return resuelto

## Traduce una clave COMPLETA (ej "MAIN_MENU.PLAY" o "ITEMS.SE_OFRECEN").
## Expone la traducción de claves tal como viven en el catálogo .po, sin dividir.
func traducir_clave(clave: String, params: Dictionary = {}, n: int = -1) -> String:
	return _tr_clave(clave, params, n)

## Busca en el catálogo activo; si falta, en español; si falta, la clave literal.
func _buscar_texto(clave: String, n: int) -> String:
	# Plurales primero: las claves plural viven en _plural_forms, no en mensajes.
	if n >= 0:
		var plural_data = _plural_forms.get(_locale_actual, {})
		if plural_data.has(clave):
			var formas: Array = plural_data[clave]
			var idx := _indice_plural(_locale_actual, n, formas.size())
			if idx < formas.size() and formas[idx] != "":
				return str(formas[idx])
		# Fallback de plural a español si falta en el idioma activo
		if _locale_actual != LOCALE_DEFECTO:
			var plural_es = _plural_forms.get(LOCALE_DEFECTO, {})
			if plural_es.has(clave):
				var formas_es: Array = plural_es[clave]
				var idx_es := _indice_plural(LOCALE_DEFECTO, n, formas_es.size())
				if idx_es < formas_es.size() and formas_es[idx_es] != "":
					return str(formas_es[idx_es])
	var activo: Dictionary = _catalogs.get(_locale_actual, {})
	var texto = activo.get(clave, null)
	if texto == null and _locale_actual != LOCALE_DEFECTO:
		var es: Dictionary = _catalogs.get(LOCALE_DEFECTO, {})
		texto = es.get(clave, null)
	if texto == null:
		push_warning("[M87] Clave sin traducción: " + clave)
		return clave
	return str(texto)

## Reemplaza {param} por su valor; claves sin valor quedan literales (warning dev).
func format_text(texto: String, params: Dictionary) -> String:
	var resultado := texto
	for clave in params:
		resultado = resultado.replace("{" + clave + "}", str(params[clave]))
	return resultado

## ── Formato delegado a LocaleUtils ───────────────────────

func format_number(value: float, decimales: int = -1) -> String:
	return LocaleUtils.format_number(value, _locale_actual, decimales)

func format_date(dia: int, mes: int, anio: int) -> String:
	return LocaleUtils.format_date(dia, mes, anio, _locale_actual)

func format_hora(hora: int, minuto: int) -> String:
	return LocaleUtils.format_hora(hora, minuto, _locale_actual)

## ── Validación de catálogos (RF21) ───────────────────────

## Devuelve lista de claves faltantes entre idiomas (activio vs español).
func validar_catalogos() -> Array:
	var faltantes: Array = []
	var es: Dictionary = _catalogs.get(LOCALE_DEFECTO, {})
	for locale in LOCALES_SOPORTADOS:
		if locale == LOCALE_DEFECTO:
			continue
		var cat: Dictionary = _catalogs.get(locale, {})
		for clave in es:
			if not cat.has(clave):
				faltantes.append(locale + ":" + str(clave))
	return faltantes

## ── Parseo .po (RF5, RF10, RN10) ─────────────────────────

## Devuelve {mensajes: {clave: texto}, plural_func: {clave: [formas]}}
func _parse_po(path: String) -> Dictionary:
	var mensajes: Dictionary = {}
	var plurales: Dictionary = {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_warning("[M87] No se pudo abrir catálogo: " + path)
		return {"mensajes": {}, "plural_func": {}}
	var lineas := f.get_as_text().split("\n")
	var clave_actual := ""
	var formas_actuales: Array = []
	var en_plural := false
	for raw in lineas:
		var linea := raw.strip_edges()
		if linea.begins_with("#") or linea.is_empty():
			continue
		if linea.begins_with("msgid_plural"):
			en_plural = true
		elif linea.begins_with("msgid"):
			# Cerrar entrada anterior
			if clave_actual != "":
				if en_plural and not formas_actuales.is_empty():
					plurales[clave_actual] = formas_actuales
				clave_actual = ""
				en_plural = false
				formas_actuales = []
			var resto := linea.substr(5).strip_edges()
			clave_actual = _quitar_comillas(resto)
			en_plural = false
		elif linea.begins_with("msgstr["):
			var idx := int(linea.substr(7, 1))
			var resto := linea.split("]", 1)[1].strip_edges()
			var valor := _quitar_comillas(resto)
			while idx >= formas_actuales.size():
				formas_actuales.append("")
			formas_actuales[idx] = valor
		elif linea.begins_with("msgstr"):
			var valor := _quitar_comillas(linea.substr(6).strip_edges())
			if clave_actual != "":
				mensajes[clave_actual] = valor
		else:
			# Continuación multilinea (string contiguo)
			var cont := _quitar_comillas(linea)
			if en_plural and not formas_actuales.is_empty():
				formas_actuales[formas_actuales.size() - 1] += cont
			elif mensajes.has(clave_actual):
				mensajes[clave_actual] = str(mensajes[clave_actual]) + cont
	# Commit de la última entrada (plurales al final del archivo)
	if clave_actual != "" and en_plural and not formas_actuales.is_empty():
		plurales[clave_actual] = formas_actuales
	return {"mensajes": mensajes, "plural_func": plurales}

func _quitar_comillas(s: String) -> String:
	var t := s.strip_edges()
	if t.begins_with("\"") and t.ends_with("\""):
		t = t.substr(1, t.length() - 2)
	return t.replace("\\n", "\n")

## Índice plural para es/en: 0 si n==1, 1 si no (nplurals=2).
func _indice_plural(locale: String, n: int, nformas: int) -> int:
	if locale == "es" or locale == "en":
		return 0 if n == 1 else mini(1, nformas - 1)
	return 0

## ── Persistencia (M60) ───────────────────────────────────

func _persistir_locale(locale: String) -> void:
	# glm-5.3-flash (2026-09-01): persistencia REAL vía M60 DataStore, sección
	# "general" de gestor_config (reemplaza el placeholder GameSettings).
	var ds := get_node_or_null("/root/DataStore")
	if ds == null or not ds.has_method("guardar_config"):
		push_warning("[M87] DataStore ausente; elección de idioma no persistida")
		return
	var config: Dictionary = ds.cargar_config()
	if typeof(config.get("general")) != TYPE_DICTIONARY:
		config["general"] = {}
	var general: Dictionary = config["general"]
	general["idioma"] = locale
	ds.guardar_config(config)
