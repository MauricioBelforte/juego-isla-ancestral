extends Camera3D

## Cámara estilo Animal Crossing — Sin look_at para preservar VoxelViewer

var _player: Node3D = null
@export var distance: float = 15.0
@export var pitch: float = 50.0
@export var smooth_speed: float = 5.0

var _offset: Vector3 = Vector3.ZERO

func _ready() -> void:
	_calc_offset()
	global_position = _offset
	rotation.x = -deg_to_rad(pitch)

func _process(delta: float) -> void:
	if not _player:
		return
	var target_pos: Vector3 = _player.global_position + _offset
	global_position = global_position.lerp(target_pos, delta * smooth_speed)

func set_player(p: Node3D) -> void:
	_player = p
	if p:
		global_position = p.global_position + _offset

func zoom_in() -> void:
	distance = max(distance - 2.0, 3.0)
	_calc_offset()
	global_position = _player.global_position + _offset if _player else _offset

func zoom_out() -> void:
	distance = min(distance + 2.0, 20.0)
	_calc_offset()
	global_position = _player.global_position + _offset if _player else _offset

func _calc_offset() -> void:
	var pitch_rad := deg_to_rad(pitch)
	_offset = Vector3(
		0.0,
		sin(pitch_rad) * distance,
		cos(pitch_rad) * distance
	)
