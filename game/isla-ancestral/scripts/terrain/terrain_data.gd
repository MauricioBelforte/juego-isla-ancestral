class_name TerrainData
extends Resource

enum TerrainId {
	CEPED,
	BARRO,
	PAVIMENTO,
	ARENA,
	AGUA,
	NIEVE,
	ROCAS
}

@export var terrain_id: TerrainId = TerrainId.CEPED
@export var nombre: String = ""
@export var speed_modifier: float = 1.0
@export var visual_config: Dictionary = {}
@export var audio_config: Dictionary = {}
