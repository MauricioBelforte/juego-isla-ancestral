extends Camera3D

## Cámara estilo Animal Crossing — M12
## Rotación con mouse, zoom con scroll, colisión con terreno
## Shake, fade, FOV — portados de camera_rig.gd (código muerto → canónico)

## ── Modos de cámara (enum local) ──────────────────────────────
enum ModoCamara { EXPLORE, BUILD, DIALOG, CUTSCENE, MINIMAP }

## ── Señales ───────────────────────────────────────────────────
signal mode_changed(new_mode: ModoCamara)
signal shake_finished()
signal transition_finished()

## ── Follow / orbit ────────────────────────────────────────────
@export var follow_speed := 12.0
@export var zoom_speed := 2.0
@export var min_distance := 4.0
@export var max_distance := 20.0
@export var min_pitch := -10.0
@export var max_pitch := 60.0

## ── FOV (anti-mareo, §H.1) ────────────────────────────────────
@export var target_fov: float = 70.0

## ── Shake (§F) ────────────────────────────────────────────────
@export var shake_max_amplitude: float = 0.15
@export var shake_max_duration: float = 0.5
@export var shake_frequency: float = 8.0

## ── Fade (§E) ─────────────────────────────────────────────────
@export var fade_color: Color = Color.BLACK
@export var fade_default_time: float = 0.3

## ── State ─────────────────────────────────────────────────────
var _target: Node3D
var _yaw: float = 0.0
var _pitch: float = 30.0
var _distance: float = 12.0
var _terrain: VoxelTerrain
var _settings: Node = null
var _current_mode: ModoCamara = ModoCamara.EXPLORE

## Shake state
var _shake_active: bool = false
var _shake_amplitude: float = 0.0
var _shake_duration: float = 0.0
var _shake_timer: float = 0.0
var _shake_offset: Vector3 = Vector3.ZERO

## Fade state
var _fade_overlay: ColorRect = null
var _fade_tween: Tween = null

func _ready() -> void:
	_settings = get_node_or_null("/root/GameSettings")
	# FOV inicial
	fov = target_fov
	# Crear overlay de fade (CanvasLayer independiente)
	_setup_fade_overlay()
	# Conectar shake desde EventBus si existe
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus and event_bus.has_signal("shake_requested"):
		event_bus.shake_requested.connect(_on_shake_requested)
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

## ── Input ─────────────────────────────────────────────────────
func _unhandled_input(event: InputEvent) -> void:
	if not _target:
		return
	# Bloquear input en Dialog/Cutscene
	if _current_mode in [ModoCamara.DIALOG, ModoCamara.CUTSCENE]:
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

## ── Physics ───────────────────────────────────────────────────
func _physics_process(delta: float) -> void:
	# Reintentar target (fix M21)
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
	# Aplicar shake offset
	var final_position := desired + _shake_offset
	global_position = global_position.lerp(final_position, follow_speed * delta)
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

## ── Direcciones para player.gd ────────────────────────────────
func get_camera_forward_xz() -> Vector3:
	var yaw_rad := deg_to_rad(_yaw)
	return Vector3(-sin(yaw_rad), 0.0, -cos(yaw_rad)).normalized()

func get_camera_right_xz() -> Vector3:
	var yaw_rad := deg_to_rad(_yaw)
	return Vector3(cos(yaw_rad), 0.0, -sin(yaw_rad)).normalized()

## ── Modos de cámara ───────────────────────────────────────────
func set_mode(new_mode: ModoCamara) -> void:
	if new_mode == _current_mode:
		return
	_current_mode = new_mode
	mode_changed.emit(new_mode)

func get_mode() -> ModoCamara:
	return _current_mode

## ── Shake (§F) ────────────────────────────────────────────────
func trigger_shake(amplitude: float, duration: float) -> void:
	amplitude = clampf(amplitude, 0.0, shake_max_amplitude)
	duration = clampf(duration, 0.0, shake_max_duration)
	if amplitude <= 0.0 or duration <= 0.0:
		return
	_shake_active = true
	_shake_amplitude = amplitude
	_shake_duration = duration
	_shake_timer = 0.0

func _on_shake_requested(amplitude: float, duration: float) -> void:
	trigger_shake(amplitude, duration)

func _process(delta: float) -> void:
	# FOV suave
	fov = lerpf(fov, target_fov, 8.0 * delta)
	# Shake
	_update_shake(delta)

func _update_shake(delta: float) -> void:
	if not _shake_active:
		return
	_shake_timer += delta
	if _shake_timer >= _shake_duration:
		_shake_active = false
		_shake_offset = Vector3.ZERO
		shake_finished.emit()
		return
	# Decaimiento lineal
	var progress := _shake_timer / _shake_duration
	var current_amp := _shake_amplitude * (1.0 - progress)
	# Frecuencia: offset aleatorio escalado
	var freq := shake_frequency * _shake_timer
	_shake_offset = Vector3(
		sin(freq * 12.9898) * current_amp,
		sin(freq * 78.233) * current_amp * 0.5,
		cos(freq * 43.758) * current_amp
	)

## ── Fade (§E) ─────────────────────────────────────────────────
func _setup_fade_overlay() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "CameraFadeCanvas"
	canvas.layer = 100
	add_child(canvas)
	_fade_overlay = ColorRect.new()
	_fade_overlay.name = "FadeOverlay"
	_fade_overlay.color = Color(fade_color, 0.0)
	_fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(_fade_overlay)

func fade_screen(color: Color, time: float) -> void:
	if _fade_overlay == null:
		return
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_overlay.color = Color(color, 0.0)
	_fade_tween = create_tween()
	_fade_tween.tween_property(_fade_overlay, "color:a", 1.0, time * 0.5)
	_fade_tween.tween_property(_fade_overlay, "color:a", 0.0, time * 0.5)
	_fade_tween.tween_callback(transition_finished.emit)

func fade_to_black(time: float = -1.0) -> void:
	if time < 0.0:
		time = fade_default_time
	fade_screen(fade_color, time)

func fade_from_black(time: float = -1.0) -> void:
	if time < 0.0:
		time = fade_default_time
	if _fade_overlay == null:
		return
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_overlay.color = Color(fade_color, 1.0)
	_fade_tween = create_tween()
	_fade_tween.tween_property(_fade_overlay, "color:a", 0.0, time)
	_fade_tween.tween_callback(transition_finished.emit)
