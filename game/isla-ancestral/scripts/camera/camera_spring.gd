## camera_spring.gd — Spring-arm con colisión contra bloques
## Módulo 12: Cámara
class_name CameraSpring
extends Node3D

## Señal emitida cuando la cámara colisiona con un bloque
signal collision_detected(collision_point: Vector3)

## Señal emitida cuando la cámara se libera de la colisión
signal collision_released()

## Distancia máxima del brazo (metros)
@export var max_distance: float = 5.0

## Separación mínima al colisionar (metros)
@export var min_distance: float = 0.8

## Tiempo de suavizado posicional (segundos)
@export var smooth_time: float = 0.15

## Velocidad de retorno tras colisión
@export var return_speed: float = 6.67

## Layer de colisión (bloques del terreno)
@export var collision_layer: int = 1

## Dirección del raycast (desde pivot hacia cámara)
var _ray_direction: Vector3 = Vector3.ZERO

## Distancia actual del brazo
var _current_distance: float = 5.0

## Distancia objetivo
var _target_distance: float = 5.0

## Posición actual suavizada
var _current_position: Vector3 = Vector3.ZERO

## Posición objetivo
var _target_position: Vector3 = Vector3.ZERO

## Estado de colisión
var _is_colliding: bool = false

## Punto de colisión actual
var _collision_point: Vector3 = Vector3.ZERO

## Referencia al raycast
@onready var _raycast: RayCast3D = $RayCast3D

## Inicialización
func _ready() -> void:
	_current_distance = max_distance
	_target_distance = max_distance
	
	# Configurar raycast
	if _raycast:
		_raycast.target_position = Vector3(0, 0, -max_distance)
		_raycast.collision_mask = collision_layer
		_raycast.collide_with_areas = false
		_raycast.collide_with_bodies = true

## Actualización por frame de física
func _physics_process(delta: float) -> void:
	_update_raycast()
	_update_distance(delta)
	_update_position(delta)

## Actualiza el raycast de colisión
func _update_raycast() -> void:
	if not _raycast:
		return
	
	# Configurar dirección del raycast
	_raycast.target_position = Vector3(0, 0, -max_distance)
	_raycast.force_raycast_update()
	
	# Verificar colisión
	if _raycast.is_colliding():
		var collision_point: Vector3 = _raycast.get_collision_point()
		var collision_distance: float = global_position.distance_to(collision_point)
		
		# Calcular distancia con separación mínima
		var desired_distance: float = max(collision_distance - min_distance, min_distance)
		
		if desired_distance < _target_distance:
			_target_distance = desired_distance
			_collision_point = collision_point
			
			if not _is_colliding:
				_is_colliding = true
				collision_detected.emit(collision_point)
	else:
		# No hay colisión — volver a distancia máxima
		_target_distance = max_distance
		
		if _is_colliding:
			_is_colliding = false
			collision_released.emit()

## Actualiza la distancia con suavizado
func _update_distance(delta: float) -> void:
	# Suavizado de distancia
	_current_distance = lerp(_current_distance, _target_distance, return_speed * delta)

## Actualiza la posición con suavizado
func _update_position(delta: float) -> void:
	# Calcular posición objetivo basada en la distancia actual
	_target_position = global_position + (_ray_direction * _current_distance)
	
	# Suavizado posicional
	_current_position = _current_position.lerp(_target_position, delta / smooth_time)

## Establece la dirección del brazo (desde pivot hacia cámara)
func set_direction(direction: Vector3) -> void:
	_ray_direction = direction.normalized()

## Obtiene la distancia actual del brazo
func get_current_distance() -> float:
	return _current_distance

## Obtiene la posición final de la cámara (después del spring-arm)
func get_camera_position() -> Vector3:
	return _current_position

## Verifica si la cámara está colisionando
func is_colliding() -> bool:
	return _is_colliding

## Resetea el brazo a la distancia máxima
func reset() -> void:
	_target_distance = max_distance
	_is_colliding = false

## Ajusta la distancia máxima (para zoom)
func set_max_distance(distance: float) -> void:
	max_distance = distance
	if not _is_colliding:
		_target_distance = max_distance

## Ajusta la distancia mínima (para interiores)
func set_min_distance(distance: float) -> void:
	min_distance = distance
