extends Node
## CruceroAmbiental — Módulo 169 (L-04): diálogo ambiental de 1 línea por NPC.
##
## Fallback de ambiente: cuando el jugador interactúa con un NPC a bordo que NO tiene
## diálogo guionado (M21), se muestra su línea ambiental. NO reemplaza a M21: solo da
## vida a los NPCs sin guion. Data-driven (data/crucero/ambiental.json).

const RUTA := "res://data/crucero/ambiental.json"
const PREFIJO_LOG := "[CRU-AMB]"

var _lineas: Dictionary = {}   ## npc_id -> linea


func _ready() -> void:
	_cargar()


func _cargar() -> void:
	if not FileAccess.file_exists(RUTA):
		push_error("%s no existe %s" % [PREFIJO_LOG, RUTA])
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("%s JSON invalido en %s" % [PREFIJO_LOG, RUTA])
		return
	var lista: Variant = (parsed as Dictionary).get("npcs", [])
	_lineas.clear()
	for item: Variant in (lista as Array):
		if typeof(item) == TYPE_DICTIONARY:
			var d: Dictionary = item
			var id := String(d.get("id", ""))
			if id != "":
				_lineas[id] = String(d.get("linea", ""))


## Línea ambiental del NPC ("" si no tiene).
func linea(npc_id: StringName) -> String:
	return String(_lineas.get(String(npc_id), ""))


## IDs de NPCs con línea ambiental.
func npcs() -> Array:
	return _lineas.keys()


func tiene(npc_id: StringName) -> bool:
	return _lineas.has(String(npc_id))