# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M156: Terrenos — TerrainDetector (diseño §1.2 adaptado a VoxelTerrain M08).
# Raycast vertical desde el jugador; debounce anti-flickering (§10.2).
# Si el raycast no golpea voxel, consulta GameTime TerrainLocator (altura).
class_name TerrainDetector
extends RayCast3D

@export var detection_interval: float = 0.1
@export var ray_length: float = 2.0
## Debounce: cambios con menos de este intervalo se ignoran (§10.2 flickering)
@export var debounce_seg: float = 0.15

signal terrain_changed(new_terrain_id: int)

var current_terrain_id: int = 0
var detection_timer: float = 0.0
var _ultimo_cambio: float = 0.0


func _ready() -> void:
	target_position = Vector3(0, -ray_length, 0)
	enabled = true


func _physics_process(delta: float) -> void:
	detection_timer += delta
	if detection_timer >= detection_interval:
		detection_timer = 0.0
		_detect_terrain()


func _detect_terrain() -> void:
	if is_colliding():
		var collider = get_collider()
		# VoxelTerrain de M08: mapear block_id → terrain_id vía provider
		var new_terrain_id := current_terrain_id
		if collider is VoxelTerrain:
			var pos := get_collision_point() - Vector3(0, 0.1, 0)
			var block_id := _block_id_en(pos)
			new_terrain_id = _block_a_terrain(block_id)
		elif collider != null and collider.has_method("get_terrain_id"):
			new_terrain_id = int(collider.get_terrain_id())
		if new_terrain_id != current_terrain_id:
			var now := Time.get_ticks_msec() / 1000.0
			if now - _ultimo_cambio >= debounce_seg:
				_ultimo_cambio = now
				current_terrain_id = new_terrain_id
				terrain_changed.emit(current_terrain_id)


## Bloque voxel bajo el punto (M08 VoxelTool)
func _block_id_en(pos: Vector3) -> int:
	var terrain_node := get_tree().get_first_node_in_group("voxel_terrain")
	if terrain_node == null:
		# fallback por nombre (escena main_island)
		var main := get_tree().current_scene
		if main != null:
			terrain_node = main.get_node_or_null("VoxelTerrain")
	if terrain_node != null and terrain_node.get("storage") != null:
		var vt = terrain_node.get_voxel_tool()
		if vt != null:
			return int(vt.get_voxel(Vector3i(int(floor(pos.x)), int(floor(pos.y)), int(floor(pos.z)))))
	return -1


## Mapeo block_id (M08 set de bloques) → terrain_id (M156)
## 1-3 césped/tierra, 4 arena, 5 nieve, 6+ rocas/piedra, agua según M08
func _block_a_terrain(block_id: int) -> int:
	match block_id:
		1, 2, 3:
			return 0  # césped
		4:
			return 3  # arena
		5:
			return 5  # nieve
		-1, 0:
			return 0  # aire/unknown → césped (default §10.2)
		_:
			return 6  # rocas (default para sólidos)


func get_current_terrain_id() -> int:
	return current_terrain_id
