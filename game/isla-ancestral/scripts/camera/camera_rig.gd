## camera_rig.gd — Nodo principal del sistema de cámara
## Módulo 12: Cámara — Estilo Animal Crossing (vista cenital fija ~50°)
class_name CameraRig
extends Node3D

## Señal emitida cuando cambia el modo de cámara
signal mode_changed(new_mode: CameraMode.ModoCamara)

## Señal emitida cuando cambia el nivel de zoom
signal zoom_changed(new_level: int, new_distance: float)

## Nodo de cámara
@onready var camera: Camera3D = $Camera3D

## Spring-arm con colisión
@onready var spring_arm: CameraSpring = $CameraSpring

## Modo actual
var _current_mode: CameraMode.ModoCamara = CameraMode.ModoCamara.EXPLORE

## Nivel de zoom actual (0, 1, 2 para Explore)
var _zoom_level: int = 1

## Distancia de zoom actual
var _zoom_distance: float = 5.0

## Referencia al jugador (pivot)
var _player_pivot: Node3D = null

## Ángulo de pitch fijo (grados desde horizontal) — Animal Crossing ~50°
var _current_pitch: float = 50.0

## Posición de la cámara relativa al pivot (calculada una vez, no rota)
var _camera_offset: Vector3 = Vector3.ZERO

## Tiempo de suavizado
var _smooth_time: float = 0.15

## Posición suavizada
var _smooth_position: Vector3 = Vector3.ZERO

## Estado de shake
var _shake_active: bool = false
var _shake_amplitude: float = 0.0
var _shake_duration: float = 0.0
var _shake_timer: float = 0.0
var _shake_offset: Vector3 = Vector3.ZERO

## Inicialización
func _ready() -> void:
	# Configurar spring-arm
	if spring_arm:
		spring_arm.collision_detected.connect(_on_spring_collision)
		spring_arm.collision_released.connect(_on_spring_release)
	
	# Configurar cámara
	if camera:
		camera.fov = 70.0  # Anti-mareo: FOV fijo
	
	# Calcular offset fijo de la cámara (Animal Crossing: ángulo fijo, sin rotación)
	_update_camera_offset()

## Actualiza el offset fijo de la cámara basado en pitch
func _update_camera_offset() -> void:
	var pitch_rad: float = deg_to_rad(_current_pitch)
	# La cámara está detrás y arriba del pivot
	# yaw fijo = 0 (mirando desde "atrás" del jugador, dirección sur por defecto)
	_camera_offset = Vector3(
		0.0,
		sin(pitch_rad) * _zoom_distance,
		cos(pitch_rad) * _zoom_distance
	)

## Actualización por frame
func _process(delta: float) -> void:
	_update_shake(delta)
	_update_camera_position(delta)

## Actualiza la posición de la cámara (Animal Crossing: sigue al pivot sin rotar)
func _update_camera_position(delta: float) -> void:
	if not _player_pivot or not spring_arm:
		return
	
	# La cámara siempre mira desde el mismo ángulo (sin rotación)
	# Calcula la dirección del offset basado en pitch fijo
	var pitch_rad: float = deg_to_rad(_current_pitch)
	var direction: Vector3 = Vector3(
		0.0,
		sin(pitch_rad),
		cos(pitch_rad)
	).normalized()
	
	# Actualizar spring-arm con dirección fija
	spring_arm.set_direction(direction)
	
	# Obtener posición de la cámara desde el spring-arm
	var spring_position: Vector3 = spring_arm.get_camera_position()
	
	# La posición final es el pivot + offset del spring-arm
	var target_position: Vector3 = _player_pivot.global_position + spring_position
	
	# Suavizado de posición
	_smooth_position = _smooth_position.lerp(target_position, delta / _smooth_time)
	
	# Aplicar offset de shake
	var final_position: Vector3 = _smooth_position + _shake_offset
	
	# Actualizar posición de la cámara
	camera.global_position = final_position
	
	# La cámara mira al pivot (con protección contra colinealidad)
	var look_dir: Vector3 = _player_pivot.global_position - camera.global_position
	if look_dir.length() > 0.001:
		if abs(look_dir.normalized().dot(Vector3.UP)) > 0.999:
			camera.look_at(_player_pivot.global_position, Vector3.FORWARD)
		else:
			camera.look_at(_player_pivot.global_position, Vector3.UP)

## Cambia el modo de cámara
func set_mode(new_mode: CameraMode.ModoCamara) -> void:
	if _current_mode == new_mode:
		return
	
	_current_mode = new_mode
	
	# Actualizar configuración según el modo
	match new_mode:
		CameraMode.ModoCamara.EXPLORE:
			_set_explore_mode()
		CameraMode.ModoCamara.BUILD:
			_set_build_mode()
		CameraMode.ModoCamara.DIALOG:
			_set_dialog_mode()
		CameraMode.ModoCamara.CUTSCENE:
			_set_cutscene_mode()
		CameraMode.ModoCamara.MINIMAP:
			_set_minimap_mode()
	
	# Emitir señal
	mode_changed.emit(new_mode)

## Configura el modo Explore (Animal Crossing)
func _set_explore_mode() -> void:
	_zoom_distance = CameraMode.get_zoom_distance(_current_mode, _zoom_level)
	_current_pitch = CameraMode.PITCH_ANGLES[CameraMode.ModoCamara.EXPLORE]
	spring_arm.set_max_distance(_zoom_distance)
	_update_camera_offset()

## Configura el modo Build
func _set_build_mode() -> void:
	_zoom_distance = CameraMode.get_zoom_distance(_current_mode, 0)
	_current_pitch = CameraMode.PITCH_ANGLES[CameraMode.ModoCamara.BUILD]
	spring_arm.set_max_distance(_zoom_distance)
	_update_camera_offset()

## Configura el modo Dialog
func _set_dialog_mode() -> void:
	_zoom_distance = CameraMode.get_zoom_distance(_current_mode, 0)
	_current_pitch = CameraMode.PITCH_ANGLES[CameraMode.ModoCamara.DIALOG]
	spring_arm.set_max_distance(_zoom_distance)
	_update_camera_offset()

## Configura el modo Cutscene
func _set_cutscene_mode() -> void:
	_zoom_distance = CameraMode.get_zoom_distance(_current_mode, 0)
	_current_pitch = CameraMode.PITCH_ANGLES[CameraMode.ModoCamara.CUTSCENE]
	spring_arm.set_max_distance(_zoom_distance)
	_update_camera_offset()

## Configura el modo Minimap
func _set_minimap_mode() -> void:
	_zoom_distance = CameraMode.get_zoom_distance(_current_mode, 0)
	_current_pitch = CameraMode.PITCH_ANGLES[CameraMode.ModoCamara.MINIMAP]
	spring_arm.set_max_distance(_zoom_distance)
	_update_camera_offset()

## Cambia el nivel de zoom
func set_zoom_level(level: int) -> void:
	if _current_mode != CameraMode.ModoCamara.EXPLORE:
		return
	
	_zoom_level = clampi(level, 0, 2)
	_zoom_distance = CameraMode.get_zoom_distance(_current_mode, _zoom_level)
	spring_arm.set_max_distance(_zoom_distance)
	_update_camera_offset()
	zoom_changed.emit(_zoom_level, _zoom_distance)

## Aumenta el zoom (acercar)
func zoom_in() -> void:
	set_zoom_level(_zoom_level + 1)

## Disminuye el zoom (alejar)
func zoom_out() -> void:
	set_zoom_level(_zoom_level - 1)

## Establece la referencia al jugador
func set_player_pivot(pivot: Node3D) -> void:
	_player_pivot = pivot

## Activa el shake de cámara
func trigger_shake(amplitude: float, duration: float) -> void:
	amplitude = min(amplitude, CameraMode.SHAKE_AMPLITUDE_MAX)
	duration = min(duration, CameraMode.SHAKE_DURATION_MAX)
	
	_shake_active = true
	_shake_amplitude = amplitude
	_shake_duration = duration
	_shake_timer = 0.0

## Actualiza el shake de cámara
func _update_shake(delta: float) -> void:
	if not _shake_active:
		_shake_offset = Vector3.ZERO
		return
	
	_shake_timer += delta
	
	if _shake_timer >= _shake_duration:
		_shake_active = false
		_shake_offset = Vector3.ZERO
		return
	
	var progress: float = _shake_timer / _shake_duration
	var decay: float = 1.0 - progress
	
	_shake_offset = Vector3(
		randf_range(-1.0, 1.0) * _shake_amplitude * decay,
		randf_range(-1.0, 1.0) * _shake_amplitude * decay * 0.5,
		randf_range(-1.0, 1.0) * _shake_amplitude * decay
	)

## Callback de colisión del spring-arm
func _on_spring_collision(_collision_point: Vector3) -> void:
	pass

## Callback de liberación del spring-arm
func _on_spring_release() -> void:
	pass

## Obtiene el modo actual
func get_current_mode() -> CameraMode.ModoCamara:
	return _current_mode

## Obtiene el nivel de zoom actual
func get_zoom_level() -> int:
	return _zoom_level

## Obtiene la distancia de zoom actual
func get_zoom_distance_value() -> float:
	return _zoom_distance

## Verifica si la cámara está en modo de input del jugador
func allows_player_input() -> bool:
	return CameraMode.allows_player_input(_current_mode)

## Verifica si el HUD debe estar visible
func should_show_hud() -> bool:
	return not CameraMode.hides_hud(_current_mode)

## Resetea la cámara al modo Explore
func reset() -> void:
	set_mode(CameraMode.ModoCamara.EXPLORE)
	_zoom_level = 1
	_current_pitch = CameraMode.PITCH_ANGLES[CameraMode.ModoCamara.EXPLORE]
	_update_camera_offset()
	if spring_arm:
		spring_arm.reset()
