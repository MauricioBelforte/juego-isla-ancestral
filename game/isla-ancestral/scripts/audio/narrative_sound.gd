# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M150: Diseño Sonoro Narrativo — NarrativeSound (autoload)
# Catálogo de sonidos narrativos por momento: sellos, templos, resonancia,
# Elysia, leitmotifs, reglas narrativas. Data-driven desde JSON.
# Adaptación Godot 4.7/GDScript del diseño (04-Codigo.md §2).
# ⚠️ Sin class_name: es autoload (pitfall §9.17/§9.41).

extends Node

const RUTA_NARRATIVA := "res://data/audio/narrative_sound.json"

var config: Dictionary = {}

func _ready() -> void:
	_cargar_narrativa()
	_registrar_servicio()
	print("[M150] NarrativeSound listo (%d momentos)" % config.get("momentos", {}).size())

func _cargar_narrativa() -> void:
	if not FileAccess.file_exists(RUTA_NARRATIVA):
		push_warning("[M150] narrative_sound.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_NARRATIVA))
	if typeof(parsed) == TYPE_DICTIONARY:
		config = parsed

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("narrative_sound"):
		sr.register("narrative_sound", self)

## Obtiene la configuración de sonido para un momento narrativo.
func momento(id: String) -> Dictionary:
	return config.get("momentos", {}).get(id, {})

func leitmotif(id: String) -> Dictionary:
	return config.get("leitmotifs", {}).get(id, {})

func regla(nombre: String) -> bool:
	return bool(config.get("reglas", {}).get(nombre, false))

func momentos_ids() -> Array:
	return config.get("momentos", {}).keys()