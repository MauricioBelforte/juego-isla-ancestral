extends Node3D

## Escena principal simplificada — Camera3D directa + Jugador

@onready var terrain = $VoxelTerrain
@onready var fps_label = $UI/FPSLabel
@onready var camera: Camera3D = $SimpleCamera
@onready var player: CharacterBody3D = $Player

var time := 0.0

func _ready():
	_setup_terrain()
	camera.set_player(player)
	print("Isla Ancestral — Modo simple")

func _setup_terrain() -> void:
	if not terrain:
		return
	
	var library = VoxelBlockyLibrary.new()
	
	var air = VoxelBlockyModelEmpty.new()
	air.set_name("air")
	library.add_model(air)
	
	var cube = VoxelBlockyModelCube.new()
	cube.set_name("tierra")
	library.add_model(cube)
	
	library.bake()
	
	terrain.mesher = VoxelMesherBlocky.new()
	terrain.mesher.library = library
	terrain.generator = VoxelGeneratorFlat.new()
	terrain.generator.voxel_type = 1

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

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			else:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				MOUSE_BUTTON_WHEEL_UP:
					camera.zoom_in()
				MOUSE_BUTTON_WHEEL_DOWN:
					camera.zoom_out()
