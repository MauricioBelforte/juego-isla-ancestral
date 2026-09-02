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

func obtener_idioma() -> String:
	return _idioma

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
