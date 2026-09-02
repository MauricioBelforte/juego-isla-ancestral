extends Node
class_name TerrainDataProvider

var _terrains: Dictionary = {}

func _ready() -> void:
	_build_map()

func _build_map() -> void:
	_terrains.clear()
	var dir := DirAccess.open("res://resources/terrain/")
	if dir == null:
		push_warning("M156: resources/terrain/ no existe.")
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var terrain := load("res://resources/terrain/" + file_name) as TerrainData
			if terrain != null:
				_terrains[terrain.terrain_id] = terrain
		file_name = dir.get_next()
	dir.list_dir_end()

func get_terrain_data(terrain_id: int) -> TerrainData:
	return _terrains.get(terrain_id)

func get_speed_modifier(terrain_id: int) -> float:
	var terrain := _terrains.get(terrain_id)
	if terrain == null:
		return 1.0
	return terrain.speed_modifier

func get_visual_config(terrain_id: int) -> Dictionary:
	var terrain := _terrains.get(terrain_id)
	if terrain == null:
		return {}
	return terrain.visual_config

func get_audio_config(terrain_id: int) -> Dictionary:
	var terrain := _terrains.get(terrain_id)
	if terrain == null:
		return {}
	return terrain.audio_config
