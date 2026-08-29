extends Camera3D

## Cámara estilo Animal Crossing — M12
## Rotación con mouse, zoom con scroll, colisión con terreno

@export var follow_speed := 12.0
@export var zoom_speed := 2.0
@export var min_distance := 4.0
@export var max_distance := 20.0
@export var min_pitch := -10.0
@export var max_pitch := 60.0

var _target: Node3D
var _yaw: float = 0.0
var _pitch: float = 30.0
var _distance: float = 12.0
var _terrain: VoxelTerrain
var _settings: Node = null

func _ready() -> void:
	_settings = get_node_or_null("/root/GameSettings")
	await get_tree().process_frame
	if not is_inside_tree():
		return
	_target = get_tree().get_first_node_in_group("player")
	if _target:
		global_position = _target.global_position + _get_offset()
		look_at(_target.global_position + Vector3(0, 1, 0))
	_terrain = _find_terrain()

func _find_terrain() -> VoxelTerrain:
	var root = get_tree().current_scene
	if root:
		return root.get_node_or_null("VoxelTerrain")
	return null

func _unhandled_input(event: InputEvent) -> void:
	if not _target:
		return
	
	# Rotación con mouse cuando está capturado
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var sens: float = 0.032
		var invert: bool = false
		if _settings:
			sens = _settings.mouse_sensitivity
			invert = _settings.invert_y
		_yaw -= event.relative.x * sens
		var pitch_dir: float = -1.0 if invert else 1.0
		_pitch = clamp(_pitch + event.relative.y * sens * pitch_dir, min_pitch, max_pitch)
	
	# Zoom con scroll
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_distance = max(_distance - zoom_speed, min_distance)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_distance = min(_distance + zoom_speed, max_distance)

func _physics_process(delta: float) -> void:
	# M21-fix: reintentar buscar al target si nunca se encontro (el _ready con
	# await puede correr antes de que el Player este en el grupo)
	if not _target or not is_instance_valid(_target):
		_target = get_tree().get_first_node_in_group("player")
		if _target == null:
			_target = get_tree().current_scene.get_node_or_null("Player")
		if _target:
			print("[Camera] Target encontrado: " + _target.name)
	if not _target:
		return
	
	var offset := _get_offset()
	var desired := _target.global_position + offset
	
	# Colisión con terreno: acortar distancia si hay obstáculo
	if _terrain:
		var ray_origin := _target.global_position + Vector3(0, 1, 0)
		var ray_dir := (desired - ray_origin).normalized()
		var tool := _terrain.get_voxel_tool()
		tool.channel = VoxelBuffer.CHANNEL_TYPE
		var result = tool.raycast(ray_origin, ray_dir, _distance)
		if result:
			var hit_dist: float = ray_origin.distance_to(result.position)
			if hit_dist < _distance:
				desired = ray_origin + ray_dir * (hit_dist - 0.5)
	
	global_position = global_position.lerp(desired, follow_speed * delta)
	
	# Mirar al jugador
	var look_target := _target.global_position + Vector3(0, 1.0, 0)
	look_at(look_target)

func _get_offset() -> Vector3:
	var pitch_rad := deg_to_rad(_pitch)
	var yaw_rad := deg_to_rad(_yaw)
	return Vector3(
		sin(yaw_rad) * cos(pitch_rad) * _distance,
		sin(pitch_rad) * _distance,
		cos(yaw_rad) * cos(pitch_rad) * _distance
	)

## Retorna la dirección horizontal "adelante" desde la cámara (hacia el jugador)
func get_camera_forward_xz() -> Vector3:
	var yaw_rad := deg_to_rad(_yaw)
	return Vector3(-sin(yaw_rad), 0.0, -cos(yaw_rad)).normalized()

## Retorna la dirección horizontal "derecha" desde la cámara
func get_camera_right_xz() -> Vector3:
	var yaw_rad := deg_to_rad(_yaw)
	return Vector3(cos(yaw_rad), 0.0, -sin(yaw_rad)).normalized()
