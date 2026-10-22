# Modelo: Reflection Beam 1.0
# Plataforma: Kilo Code
# Fecha: 2026-10-22
#
# M56 Navigator — réplica lógica de la cámara real (un render, M61).
# Mueve la cámara real del juego (sin duplicar render) con WASD/gamepad +
# zoom (FOV 0.5x-8x) + rotación orbital con límites de inclinación.
# Se activa en modo foto y se restaura al salir.

extends Camera3D

## Velocidad de traslación (m/s) en modo foto.
@export var velocidad_traslacion: float = 8.0
## FOV base (grados) de la cámara real.
@export var fov_base: float = 75.0
## Rango de zoom (multiplicador sobre fov_base).
@export var zoom_min: float = 0.5
@export var zoom_max: float = 8.0
## Límites de inclinación (grados).
@export var pitch_min: float = -80.0
@export var pitch_max: float = 80.0
## Sensibilidad del mouse para orbit.
@export var sensibilidad_orbit: float = 0.3

var _yaw: float = 0.0
var _pitch: float = 0.0
var _zoom: float = 1.0
var _activo: bool = false
var _capturando_mouse: bool = false


func _ready() -> void:
	fov = fov_base
	# Iniciar desactivado; se activa al entrar al modo foto.
	current = false


func activar(camara_origen: Camera3D) -> void:
	# Réplica: copia transform de la cámara real (sin duplicar render).
	if camara_origen != null:
		global_transform = camara_origen.global_transform
		fov = camara_origen.fov
		fov_base = camara_origen.fov
	_yaw = rotation_degrees.y
	_pitch = rotation_degrees.x
	_zoom = 1.0
	_activo = true
	current = true
	print("[NAVIGATOR] activado (pos=%s, fov=%.1f)" % [str(global_position), fov])


func desactivar() -> void:
	_activo = false
	current = false
	print("[NAVIGATOR] desactivado")


func _process(delta: float) -> void:
	if not _activo:
		return
	# Traslación WASD (en espacio local de la cámara) con colisión suave (raycast).
	var dir := Vector3.ZERO
	if Input.is_action_pressed("ui_left"):
		dir.x -= 1.0
	if Input.is_action_pressed("ui_right"):
		dir.x += 1.0
	if Input.is_action_pressed("ui_up"):
		dir.z -= 1.0
	if Input.is_action_pressed("ui_down"):
		dir.z += 1.0
	if dir != Vector3.ZERO:
		dir = dir.normalized()
		# Mover en espacio local (forward = -Z).
		var forward := -global_transform.basis.z
		var right := global_transform.basis.x
		var movimiento := (right * dir.x + forward * dir.z) * velocidad_traslacion * delta
		# Colisión suave: raycast en la dirección del movimiento.
		var espacio := get_world_3d().direct_space_state
		if espacio != null:
			var origen := global_position
			var destino := origen + movimiento
			var query := PhysicsRayQueryParameters3D.create(origen, destino)
			query.collision_mask = 1  # terreno
			var resultado := espacio.intersect_ray(query)
			if resultado.size() > 0:
				# Clamp al punto de impacto con margen.
				var hit_pos: Vector3 = resultado["position"]
				var margen := 0.5
				var dir_norm := movimiento.normalized()
				var dist := origen.distance_to(hit_pos) - margen
				if dist > 0.0:
					movimiento = dir_norm * minf(movimiento.length(), dist)
				else:
					movimiento = Vector3.ZERO
		global_position += movimiento
	# Zoom (FOV).
	fov = clampf(fov_base / _zoom, fov_base / zoom_max, fov_base / zoom_min)


func _unhandled_input(event: InputEvent) -> void:
	if not _activo:
		return
	# Zoom con rueda del mouse.
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom = clampf(_zoom * 1.1, zoom_min, zoom_max)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom = clampf(_zoom / 1.1, zoom_min, zoom_max)
	# Orbit con botón derecho (drag).
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		_yaw -= event.relative.x * sensibilidad_orbit
		_pitch -= event.relative.y * sensibilidad_orbit
		_pitch = clampf(_pitch, pitch_min, pitch_max)
		rotation_degrees = Vector3(_pitch, _yaw, 0.0)