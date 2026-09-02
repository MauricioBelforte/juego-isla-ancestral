## Autoload que gestiona el diseño visual de todos los NPCs (M161).
extends Node

## Diccionario de diseños visuales: npc_id -> NPCVisualData.
var visuals: Dictionary = {}

func _ready() -> void:
	_load_all_visuals()

## Carga todos los diseños visuales de las carpetas por isla + raíz.
## Fix 2026-09-02 (deepseek-v4-flash-vision-exp): recorrido RECURSIVO —
## antes solo miraba la raíz de data/npc_visuals/ y cargaba 1 de los 23.
func _load_all_visuals() -> void:
	visuals.clear()
	_cargar_diq("res://data/npc_visuals/")
	print("[NPCVisualDatabase] Cargados %d diseños visuales" % visuals.size())

func _cargar_dir(dir: DirAccess, ruta: String) -> void:
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		var ruta_archivo := ruta + file_name
		if dir.current_is_dir() and file_name != "." and file_name != "..":
			_cargar_diq(ruta_archivo + "/")
		elif file_name.ends_with(".tres"):
			var visual = load(ruta_archivo) as NPCVisualData
			if visual and visual.npc_id != "":
				visuals[visual.npc_id] = visual
			else:
				push_warning("[NPCVisualDatabase] .tres ignorado (sin NPCVisualData/npc_id): " + ruta_archivo)
		file_name = dir.get_next()
	dir.list_dir_end()

func _cargar_diq(ruta: String) -> void:
	var dir := DirAccess.open(ruta)
	if dir:
		_cargar_dir(dir, ruta)

## Obtiene el diseño visual de un NPC.
func get_visual(npc_id: String) -> NPCVisualData:
	return visuals.get(npc_id)

## Obtiene todos los NPCs de una isla.
func get_visuals_by_island(isla: String) -> Array[NPCVisualData]:
	var result: Array[NPCVisualData] = []
	for v in visuals.values():
		if v.isla == isla:
			result.append(v)
	return result

## Obtiene la variante estacional de un NPC.
func get_seasonal_variant(npc_id: String, estacion: String) -> NPCVisualData:
	var visual = get_visual(npc_id)
	if visual:
		return visual.get_seasonal_variant(estacion)
	return null
