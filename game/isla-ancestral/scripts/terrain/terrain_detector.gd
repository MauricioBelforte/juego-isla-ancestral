extends Node
class_name TerrainDetector

signal terrain_changed(terrain_id: int)

@export var detection_interval: float = 0.1
@export var ray_length: float = 2.0
@export var collision_layer: int = 1

var _timer: float = 0.0
var _current_terrain_id: int = 0
var _last_terrain_id: int = -1
var _ray: RayCast3D

func _ready() -> void:
	_ray = RayCast3D.new()
	_ray.enabled = true
	_ray.target_position = Vector3.DOWN * ray_length
	_ray.collision_mask = collision_layer
	add_child(_ray)

func _process(delta: float) -> void:
	_timer += delta
	if _timer >= detection_interval:
		_timer = 0.0
		_detect_terrain()

func _detect_terrain() -> void:
	if not _ray.is_colliding():
		_current_terrain_id = 0
		_emit_if_changed()
		return

	var collider = _ray.get_collider()
	if collider == null:
		_current_terrain_id = 0
		_emit_if_changed()
		return

	if collider.has_method("get_terrain_id"):
		_current_terrain_id = collider.get_terrain_id()
	else:
		_current_terrain_id = 0

	_emit_if_changed()

func _emit_if_changed() -> void:
	if _current_terrain_id != _last_terrain_id:
		_last_terrain_id = _current_terrain_id
		terrain_changed.emit(_current_terrain_id)

func get_current_terrain_id() -> int:
	return _current_terrain_id
