# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M87: Localización — LocalizationManager (autoload)
# Catálogo de cadenas por idioma (data-driven, strings_*.json), idioma activo,
# fallback a ES, interpolación {var}, pluralización simple, persistencia en M58.
# ⚠️ Sin class_name (autoload).

extends Node

const DIR_LOC := "res://data/localizacion/"
const IDIOMAS_BASE := ["es", "en"]

var _cadenas: Dictionary = {}  # idioma -> {clave: texto}
var idioma_actual: String = "es"

func _ready() -> void:
	_cargar_idiomas()
	_registrar_servicio()
	print("[M87] LocalizationManager listo (%d idiomas)" % _cadenas.size())

func _cargar_idiomas() -> void:
	for lang in IDIOMAS_BASE:
		var ruta := "%sstrings_%s.json" % [DIR_LOC, lang]
		if not FileAccess.file_exists(ruta):
			push_warning("[M87] No encontrado: %s" % ruta)
			continue
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(ruta))
		if typeof(parsed) == TYPE_DICTIONARY:
			_cadenas[lang] = parsed.get("cadenas", {})

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("localizacion"):
		sr.register("localizacion", self)

## get_texto con interpolación de {vars} y fallback ES.
func get_texto(clave: String, vars: Dictionary = {}, lang: String = "") -> String:
	var idioma := lang if lang != "" else idioma_actual
	var texto := _buscar(clave, idioma)
	if texto == "" and idioma != "es":
		texto = _buscar(clave, "es")
	if texto == "":
		return clave
	for k in vars:
		texto = texto.replace("{%s}" % k, str(vars[k]))
	return texto

func _buscar(clave: String, lang: String) -> String:
	var cadenas: Dictionary = _cadenas.get(lang, {})
	return String(cadenas.get(clave, ""))

## Pluralización simple: elige la forma según cantidad (clave_base / clave_base_plural).
func get_plural(clave_base: String, cantidad: int, vars: Dictionary = {}) -> String:
	var vars_con_n := vars.duplicate()
	vars_con_n["n"] = cantidad
	if cantidad == 1:
		return get_texto(clave_base, vars_con_n)
	return get_texto(clave_base + "_plural", vars_con_n)

func set_idioma(lang: String) -> bool:
	if not _cadenas.has(lang):
		return false
	idioma_actual = lang
	return true

func idiomas_disponibles() -> Array:
	return _cadenas.keys().duplicate()

func cantidad_cadenas(lang: String) -> int:
	return int(_cadenas.get(lang, {}).size())

func set_cadena(lang: String, clave: String, texto: String) -> void:
	if _cadenas.has(lang):
		_cadenas[lang][clave] = texto