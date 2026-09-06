# Modelo: minimax-m3-free
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M131: Créditos - CreditsManager (autoload "credits_manager").
# Carga el catalogo data-driven desde data/legal/creditos.json, expone API
# para la UI (M53), y maneja conmutacion de idioma (RF4: es/en).
# Diseno data-driven: cualquier seccion agregada al JSON aparece
# automaticamente en la UI sin tocar codigo.
#
# Sin class_name (autoload, 07-GUIA-GODOT 9.17/9.41).
# Sin acoplamiento con M87 Localization: si M87 existe, lo consume;
# si no, el fallback de idioma es hard-coded en este manager.

extends Node

const RUTA_DATA := "res://data/legal/creditos.json"
const ValidatorRef = preload("res://scripts/legal/credits_validator.gd")
const DEFAULT_LANG := "es"
const COPYRIGHT := "Isla Ancestral Team"
const DEFAULT_YEAR := 2026

## Senales para la UI (RF5: navegacion y control de reproduccion)
signal seccion_cambiada(seccion_id: String, idx: int)
signal idioma_cambiado(nuevo: String)
signal catalogo_cargado()

## Estado
var _secciones: Array = []  # Array de Dictionary (secciones del JSON)
var _politicas: Dictionary = {}
var _seccion_actual: int = 0  # Indice para RF5 (control de reproduccion)
var _idioma: String = DEFAULT_LANG
var _titulos_traducidos: Dictionary = {}  # es -> en simple map

func _ready() -> void:
	# Traducciones hard-coded (M87 se puede integrar despues; el manager tolera sin el)
	_titulos_traducidos = {
		"es": {
			"desarrollo": "Desarrollo",
			"musica": "Música y Sonido",
			"arte": "Arte y Animación",
			"qa": "QA y Testing",
			"comunidad": "Comunidad",
			"agradecimientos": "Agradecimientos",
			"assets_terceros": "Assets de Terceros",
		},
		"en": {
			"desarrollo": "Development",
			"musica": "Music and Sound",
			"arte": "Art and Animation",
			"qa": "QA and Testing",
			"comunidad": "Community",
			"agradecimientos": "Acknowledgements",
			"assets_terceros": "Third-Party Assets",
		},
	}
	cargar_catalogo()
	# Si M87 Localization existe, sincronizar idioma
	# (fix parser 2026-09-02: get_node_or_null devuelve Node — el := no
	# puede inferir, hay que declarar el tipo explicito)
	var loc: Node = Engine.get_main_loop().root.get_node_or_null("LocalizationManager")
	if loc != null and loc.has_signal("idioma_cambiado"):
		loc.idioma_cambiado.connect(_on_m87_idioma)
		if loc.has_method("get_idioma_actual"):
			_idioma = String(loc.get_idioma_actual())

func cargar_catalogo() -> bool:
	"""Carga el catalogo desde el JSON. Devuelve true si OK."""
	if not FileAccess.file_exists(RUTA_DATA):
		push_error("[M131] %s no existe" % RUTA_DATA)
		return false
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_DATA))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("[M131] %s no es Dictionary" % RUTA_DATA)
		return false
	_secciones = parsed.get("secciones", [])
	_politicas = parsed.get("politicas", {})
	# Validar
	var errores: Array = ValidatorRef.validar(parsed)
	if not errores.is_empty():
		push_error("[M131] errores en catalog: %s" % str(errores))
		return false
	catalogo_cargado.emit()
	return true

## ── API publica ─────────────────────────────────────────

func obtener_secciones() -> Array:
	"""Devuelve copia del array de secciones."""
	return _secciones.duplicate()

func _traducir_titulo(id_seccion: String) -> String:
	"""Devuelve el titulo traducido de una seccion segun el idioma actual."""
	if _titulos_traducidos.has(_idioma) and _titulos_traducidos[_idioma].has(id_seccion):
		return _titulos_traducidos[_idioma][id_seccion]
	# Fallback: devuelve el titulo del JSON
	for sec in _secciones:
		if String(sec.get("id", "")) == id_seccion:
			return String(sec.get("titulo", ""))
	return ""

func obtener_seccion(idx: int) -> Dictionary:
	"""Devuelve la sección por indice (con título traducido)."""
	if idx < 0 or idx >= _secciones.size():
		return {}
	var sec: Dictionary = _secciones[idx].duplicate()
	# Traducir titulo segun idioma
	var id: String = String(sec.get("id", ""))
	if _titulos_traducidos.has(_idioma) and _titulos_traducidos[_idioma].has(id):
		sec["titulo"] = _titulos_traducidos[_idioma][id]
	return sec

func cantidad_secciones() -> int:
	return _secciones.size()

func obtener_seccion_actual() -> Dictionary:
	return obtener_seccion(_seccion_actual)

func ir_a_seccion(idx: int) -> bool:
	"""RF5: navegacion. Devuelve true si cambio."""
	if idx < 0 or idx >= _secciones.size():
		return false
	if _seccion_actual == idx:
		return false
	_seccion_actual = idx
	seccion_cambiada.emit(String(_secciones[idx].get("id", "")), idx)
	return true

func siguiente_seccion() -> bool:
	return ir_a_seccion(_seccion_actual + 1)

func seccion_anterior() -> bool:
	return ir_a_seccion(_seccion_actual - 1)

## ── M131 iter 2 (minimax-m3) ─────────────────────────────────────────────

# Busqueda data-driven: filtra entradas por texto, rol, o equipo.
# RF-iter2: Sistema de busqueda en creditos (C del plan-actual).
# Devuelve Array de Dictionary: [{seccion_id, seccion_titulo, entrada, matches: int}]
func buscar(query: String) -> Array:
	"""Busca por query en nombre de entrada, rol y titulo de seccion.
	Devuelve lista de matches ordenados por relevancia.
	Iter 2: normaliza acentos para que 'musica' matchee 'Música'."""
	if query.strip_edges() == "":
		return []
	var q: String = _normalize(query.to_lower())
	var matches: Array = []
	for sec in _secciones:
		var sec_id: String = String(sec.get("id", ""))
		var sec_titulo: String = String(sec.get("titulo", ""))
		var sec_titulo_translated: String = _traducir_titulo(sec_id)
		for entrada in sec.get("entradas", []):
			var entrada_str: String = _normalize(String(entrada).to_lower())
			var score: int = 0
			if entrada_str.contains(q):
				score += 10
			if _normalize(sec_titulo.to_lower()).contains(q):
				score += 5
			if _normalize(sec_titulo_translated.to_lower()).contains(q):
				score += 5
			if score > 0:
				matches.append({
					"seccion_id": sec_id,
					"seccion_titulo": sec_titulo_translated,
					"entrada": String(entrada),
					"matches": score,
				})
	# Ordenar por score descendente
	matches.sort_custom(func(a, b): return int(a.get("matches", 0)) > int(b.get("matches", 0)))
	return matches

## Normaliza acentos (NFD + quitar combining marks). Util para busqueda.
func _normalize(texto: String) -> String:
	var t: String = texto
	# Mapeo manual de acentos comunes (mas simple que NFD en GDScript)
	t = t.replace("á", "a").replace("é", "e").replace("í", "i").replace("ó", "o").replace("ú", "u")
	t = t.replace("à", "a").replace("è", "e").replace("ì", "i").replace("ò", "o").replace("ù", "u")
	t = t.replace("ä", "a").replace("ë", "e").replace("ï", "i").replace("ö", "o").replace("ü", "u")
	t = t.replace("â", "a").replace("ê", "e").replace("î", "i").replace("ô", "o").replace("û", "u")
	t = t.replace("ñ", "n").replace("ç", "c")
	return t

# Scroll automatico (RF-iter2: D del plan-actual)
# Avanza la seccion actual a la velocidad dada (ms por seccion).
# Devuelve true si avanzo, false si llego al final.
func scroll_automatico(velocidad_s: float) -> bool:
	if velocidad_s <= 0.0:
		return false
	if _seccion_actual >= _secciones.size() - 1:
		return false
	# En produccion: tween, timer, etc. Iter 2: solo avanza
	return siguiente_seccion()

# Color de texto con contraste accesible (M58)
# Devuelve Color blanco o negro segun luminancia del fondo.
func color_contraste_accesible(fondo: Color) -> Color:
	# Misma formula que M115 hardware_manager.cumple_requisitos_recomendados
	var lum: float = 0.2126 * fondo.r + 0.7152 * fondo.g + 0.0722 * fondo.b
	if lum < 0.5:
		return Color(1.0, 1.0, 1.0)  # blanco
	return Color(0.05, 0.05, 0.05)  # casi negro

# Tamano de fuente base ajustable (L del plan-actual)
# escala: 1.0 = base, 1.5 = 50% mas grande
func tamano_fuente_base(escala: float = 1.0) -> int:
	return maxi(int(round(16.0 * escala)), 12)

func obtener_idioma() -> String:
	return _idioma

## Alias para consistencia con checklist (RF6)
func obtener_idioma_actual() -> String:
	return obtener_idioma()

## RF: obtener lista de contribuyentes (todos los nombres de todas las secciones)
func obtener_contribuyentes() -> Array[String]:
	var result: Array[String] = []
	for sec in _secciones:
		for entrada in sec.get("entradas", []):
			var s := String(entrada)
			if s not in result:
				result.append(s)
	return result

## RF: obtener lista de assets de terceros (seccion assets_terceros)
func obtener_assets_terceros() -> Array[Dictionary]:
	for sec in _secciones:
		if String(sec.get("id", "")) == "assets_terceros":
			return sec.get("entradas", [])
	return []

func cambiar_idioma(nuevo: String) -> bool:
	"""RF4: conmuta entre es/en. Devuelve true si cambio."""
	if nuevo != "es" and nuevo != "en":
		return false
	if _idioma == nuevo:
		return false
	_idioma = nuevo
	idioma_cambiado.emit(nuevo)
	return true

func obtener_year() -> int:
	# RF6: copyright y año actual
	if int(_politicas.get("year_display", 1)) == 1:
		# year_display: 1 = auto, usar Time.get_datetime_dict_from_system()
		var fecha: Dictionary = Time.get_datetime_dict_from_system()
		return int(fecha.get("year", DEFAULT_YEAR))
	return int(_politicas.get("year", DEFAULT_YEAR))

func obtener_copyright() -> String:
	return "%s © %d" % [COPYRIGHT, obtener_year()]

func obtener_politicas() -> Dictionary:
	return _politicas.duplicate()

## ── Validacion ────────────────────────────────────────────

func validar_catalogo() -> Array:
	"""Devuelve array de errores (vacio = OK)."""
	if _secciones.is_empty():
		return ["Catalogo no cargado"]
	return []

## ── Callbacks ─────────────────────────────────────────────

func _on_m87_idioma(nuevo: String) -> void:
	cambiar_idioma(nuevo)
