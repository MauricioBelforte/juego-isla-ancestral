extends Node3D

## Escena principal — Isla Ancestral
## Cámara Animal Crossing + Jugador con movimiento

@onready var terrain = $VoxelTerrain
@onready var fps_label = $UI/FPSLabel
@onready var camera_rig: CameraRig = $CameraRig
@onready var player: CharacterBody3D = $Player

## Tiempo para actualizar FPS
var time := 0.0

func _ready():
	_setup_terrain()
	_setup_camera()
	
	print("Isla Ancestral — Estilo Animal Crossing")
	print("Controles: WASD mover, Scroll zoom, Escape liberar mouse")

## Configura el terreno voxel — plano simple para probar
func _setup_terrain() -> void:
	if not terrain:
		return
	
	var library = VoxelBlockyLibrary.new()
	
	# Modelo 0: aire
	var air = VoxelBlockyModelEmpty.new()
	air.set_name("air")
	library.add_model(air)
	
	# Modelo 1: tierra (cubo verde)
	var cube = VoxelBlockyModelCube.new()
	cube.set_name("tierra")
	library.add_model(cube)
	
	library.bake()
	
	terrain.mesher = VoxelMesherBlocky.new()
	terrain.mesher.library = library
	
	# Generador plano: una capa sólida de tierra en Y=0
	terrain.generator = VoxelGeneratorFlat.new()
	terrain.generator.voxel_type = 1  # tierra

## Configura la cámara para seguir al jugador
func _setup_camera() -> void:
	if not camera_rig:
		return
	
	camera_rig.set_player_pivot(player)

## Actualización por frame
func _process(delta: float) -> void:
	time += delta
	if time >= 0.5:
		var fps = Engine.get_frames_per_second()
		if fps_label:
			fps_label.text = "FPS: %d" % fps
			if fps >= 55:
				fps_label.modulate = Color.GREEN
			elif fps >= 30:
				fps_label.modulate = Color.YELLOW
			else:
				fps_label.modulate = Color.RED
		time = 0.0

## Input del mouse (solo zoom, sin rotación de cámara)
func _unhandled_input(event: InputEvent) -> void:
	# Escape para liberar/capturar mouse
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			else:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Zoom con scroll
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				MOUSE_BUTTON_WHEEL_UP:
					camera_rig.zoom_in()
				MOUSE_BUTTON_WHEEL_DOWN:
					camera_rig.zoom_out()
