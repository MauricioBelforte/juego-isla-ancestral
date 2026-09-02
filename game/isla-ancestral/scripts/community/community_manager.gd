# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M100: Community Management — CommunityManager (autoload)
# Canales de comunidad, calendario de contenido, KPIs data-driven
# (community_calendar.json). Adaptación Godot 4.7/GDScript del diseño.
# ⚠️ Sin class_name: es autoload (pitfall §9.17/§9.41).

extends Node

const RUTA_CALENDARIO := "res://data/community/community_calendar.json"

var config: Dictionary = {}

func _ready() -> void:
	_cargar_calendario()
	_registrar_servicio()
	print("[M100] CommunityManager listo (%d canales, %d eventos)" % [config.get("canales", []).size(), config.get("calendario", []).size()])

func _cargar_calendario() -> void:
	if not FileAccess.file_exists(RUTA_CALENDARIO):
		push_warning("[M100] community_calendar.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_CALENDARIO))
	if typeof(parsed) == TYPE_DICTIONARY:
		config = parsed

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("community"):
		sr.register("community", self)

func canales() -> Array:
	return config.get("canales", []).duplicate()

func eventos_por_canal(canal: String) -> Array:
	var resultado: Array = []
	for e in config.get("calendario", []):
		if String(e.get("canal", "")) == canal:
			resultado.append(e)
	return resultado

func eventos_por_tipo(tipo: String) -> Array:
	var resultado: Array = []
	for e in config.get("calendario", []):
		if String(e.get("tipo", "")) == tipo:
			resultado.append(e)
	return resultado

func kpis() -> Array:
	return config.get("metricas", {}).get("kpis", []).duplicate()