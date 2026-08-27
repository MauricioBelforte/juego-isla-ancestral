extends Node3D

## Escena de prueba simple: piso + jugador + cámara

@onready var fps_label = $UI/FPSLabel
@onready var camera: Camera3D = $SimpleCamera
@onready var player: CharacterBody3D = $Player

var time := 0.0

func _ready():
	camera.set_player(player)
	print("Isla Ancestral — TestScene")

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
