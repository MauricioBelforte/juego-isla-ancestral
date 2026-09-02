# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M124: Contenido Generado por Usuarios — UgcManager (autoload)
# Catálogo de contenido UGC data-driven (ugc_catalog.json): tipos, estados,
# revisión, publicación. Adaptación Godot 4.7/GDScript del diseño.
# ⚠️ Sin class_name: es autoload (pitfall §9.17/§9.41).

extends Node

const RUTA_CATALOGO := "res://data/ugc/ugc_catalog.json"

var config: Dictionary = {}

func _ready() -> void:
	_cargar_catalogo()
	_registrar_servicio()
	print("[M124] UgcManager listo (%d piezas UGC)" % config.get("contenido", []).size())

func _cargar_catalogo() -> void:
	if not FileAccess.file_exists(RUTA_CATALOGO):
		push_warning("[M124] ugc_catalog.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_CATALOGO))
	if typeof(parsed) == TYPE_DICTIONARY:
		config = parsed

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("ugc"):
		sr.register("ugc", self)

func contenido(id: String) -> Dictionary:
	for c in config.get("contenido", []):
		if String(c.get("id", "")) == id:
			return c
	return {}

func por_estado(estado: String) -> Array:
	var resultado: Array = []
	for c in config.get("contenido", []):
		if String(c.get("estado", "")) == estado:
			resultado.append(c)
	return resultado

func por_tipo(tipo: String) -> Array:
	var resultado: Array = []
	for c in config.get("contenido", []):
		if String(c.get("tipo", "")) == tipo:
			resultado.append(c)
	return resultado

func tipos_validos() -> Array:
	return config.get("tipos_validos", []).duplicate()

func estados_validos() -> Array:
	return config.get("estados_validos", []).duplicate()

func politica() -> Dictionary:
	return config.get("politica", {}).duplicate(true)