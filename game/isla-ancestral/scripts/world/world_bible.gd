# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M147: World Building — WorldBible (autoload)
# Acceso runtime de solo lectura al canon del mundo (world_data.json).
# Carga única, canon_version, getters por personaje/lugar/símbolo y capas
# de revelación por Sello. Diseño original (04-Codigo.md §2.1, world.gd).
#
# ⚠️ Sin class_name: es autoload (pitfall §9.17/§9.41).

extends Node

const RUTA_CANON := "res://data/world_data.json"

signal canon_changed(version: String)

var _data: Dictionary = {}
var canon_version: String = "0.0.0"

func _ready() -> void:
	cargar_canon()
	_registrar_servicio()
	print("[M147] WorldBible listo: canon %s (%d personajes, %d lugares)" % [canon_version, _data.get("personajes", {}).size(), _data.get("lugares", {}).size()])

func cargar_canon() -> void:
	if not FileAccess.file_exists(RUTA_CANON):
		push_error("[M147] No se pudo cargar world_data.json")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_CANON))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("[M147] world_data.json inválido")
		return
	_data = parsed
	canon_version = String(_data.get("canon_version", "0.0.0"))
	emit_signal("canon_changed", canon_version)

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("world"):
		sr.register("world", self)

## Getters (solo lectura)
func get_personaje(id: String) -> Dictionary:
	return _data.get("personajes", {}).get(id, {})

func get_lugar(id: String) -> Dictionary:
	return _data.get("lugares", {}).get(id, {})

func get_simbolo(id: String) -> Dictionary:
	return _data.get("simbolos", {}).get(id, {})

## Capa mínima de revelación de un conjunto de IDs (por Sellos).
## 0 = siempre visible; 1..4 = requiere el Sello de ese orden.
func get_capa_minima(ids: Array) -> int:
	var capas: Dictionary = _data.get("capas_por_sello", {})
	var minima := 0
	for id in ids:
		for sello in capas:
			var revela: Array = capas[sello].get("revela", [])
			if id in revela:
				var orden: int = int(capas[sello].get("orden", 99))
				if orden > minima:
					minima = orden
	return minima

func linea_tiempo() -> Array:
	return _data.get("linea_tiempo", [])

func version() -> String:
	return canon_version