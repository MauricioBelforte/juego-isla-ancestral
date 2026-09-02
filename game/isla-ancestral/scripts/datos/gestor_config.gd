# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M60: Datos y Serialización — GestorConfig
# Configuración persistente del juego (M58 accesibilidad, M90 gráficos, M91
# audio) vía ConfigFile de Godot (D7). Lee al arranque con defaults para
# claves ausentes; escribe al cambiar opciones. Independiente de la partida.

class_name GestorConfig
extends RefCounted

const RUTA_CONFIG: String = "user://config.cfg"

## Secciones registradas (M58/90/91 consumen las suyas).
## "general": añadida por glm-5.3-flash (M87 iter. 2) para el idioma del juego.
const SECCIONES: Array[String] = ["graficos", "audio", "accesibilidad", "general"]

## Defaults base por sección (todos los valores de referencia del módulo).
const DEFAULTS_BASE: Dictionary = {
	"graficos": {
		"calidad": "media",
		"vsync": true,
		"resolucion_escala": 1.0,
	},
	"audio": {
		"volumen_maestro": 0.8,
		"volumen_musica": 0.7,
		"volumen_sfx": 0.8,
		"volumen_ambiente": 0.7,
		"volumen_voz": 0.9,
	},
	"accesibilidad": {
		"tamano_texto": 1.0,
		"daltonismo": false,
		"subtitulos": true,
		"reducir_movimiento": false,
	},
	"general": {
		"idioma": "es",
	},
}

## Carga config desde user://config.cfg con defaults.
## Se lee el formato checksum\npayload (WriterAtomico, variante cruda).
## Devuelve { "graficos": {...}, "audio": {...}, "accesibilidad": {...} }.
## Merge de defaults: claves ausentes o nuevas de versiones futuras -> default sano.
static func cargar_config(defaults: Dictionary = DEFAULTS_BASE) -> Dictionary:
	var resultado: Dictionary = {}
	for seccion in SECCIONES:
		resultado[seccion] = (defaults.get(seccion, {}) as Dictionary).duplicate(true)
	if FileAccess.file_exists(RUTA_CONFIG):
		var doc := WriterAtomico.parsear_documento_crudo(FileAccess.get_file_as_string(RUTA_CONFIG))
		if not doc.get("ok", false):
			push_warning("[M60] config.cfg corrupto o con formato antiguo; usando defaults")
			return resultado
		var cf := ConfigFile.new()
		cf.parse(String(doc["payload_str"]))
		for seccion in SECCIONES:
			if cf.has_section(seccion):
				for clave in cf.get_section_keys(seccion):
					var valor: Variant = cf.get_value(seccion, clave, defaults.get(seccion, {}).get(clave))
					var target: Dictionary = resultado[seccion]
					target[clave] = valor
	return resultado

## Guarda config con escritura atómica usando el wrapper checksum crudo.
## Devuelve Error.
static func guardar_config(datos: Dictionary) -> Error:
	var cf := ConfigFile.new()
	for seccion in SECCIONES:
		var seccion_data: Variant = datos.get(seccion, {})
		if typeof(seccion_data) != TYPE_DICTIONARY:
			continue
		for clave in seccion_data:
			cf.set_value(seccion, clave, seccion_data[clave])
	var contenido := cf.encode_to_text()
	return WriterAtomico.escribir_atomicamente_crudo(RUTA_CONFIG, contenido)