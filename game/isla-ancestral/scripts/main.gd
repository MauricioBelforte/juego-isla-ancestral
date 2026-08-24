extends Node3D

# Escena de prueba de Voxel Tools
# Verifica que el voxel funcione a 60 FPS

@onready var terrain = $VoxelTerrain
@onready var fps_label = $UI/FPSLabel

var time := 0.0

func _ready():
	# Configurar generador de terreno simple
	var generator = VoxelGeneratorWaves.new()
	terrain.generator = generator
	
	# Configurar mesher
	var mesher = VoxelMesherBlocky.new()
	terrain.mesher = mesher
	
	# Configurar tamaño de区块
	terrain.view_distance = 8
	
	print("Isla Ancestral - Prueba de Voxel Tools")
	print("FPS objetivo: 60")

func _process(delta):
	time += delta
	
	# Actualizar FPS cada 0.5 segundos
	if time >= 0.5:
		var fps = Engine.get_frames_per_second()
		if fps_label:
			fps_label.text = "FPS: %d" % fps
		
		# Cambiar color según FPS
		if fps >= 55:
			fps_label.modulate = Color.GREEN
		elif fps >= 30:
			fps_label.modulate = Color.YELLOW
		else:
			fps_label.modulate = Color.RED
		
		time = 0.0

func _input(event):
	# Mover cámara con WASD
	var speed = 5.0 * get_process_delta_time()
	
	if event is InputEventKey:
		if event.pressed:
			match event.keycode:
				KEY_W:
					$Camera.position.z -= speed
				KEY_S:
					$Camera.position.z += speed
				KEY_A:
					$Camera.position.x -= speed
				KEY_D:
					$Camera.position.x += speed
				KEY_SPACE:
					$Camera.position.y += speed
				KEY_SHIFT:
					$Camera.position.y -= speed
