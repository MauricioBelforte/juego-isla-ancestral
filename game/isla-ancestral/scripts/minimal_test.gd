extends Node3D

## Setup minimal según quick start de Voxel Tools

@onready var terrain: VoxelTerrain = $VoxelTerrain

func _ready() -> void:
	# 1. Material con vertex color
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	terrain.material_override = mat
	
	# 2. Mesher
	var mesher := VoxelMesherBlocky.new()
	var library := VoxelBlockyLibrary.new()
	
	# Modelo 0: Aire
	var air := VoxelBlockyModelEmpty.new()
	air.set_name("air")
	library.add_model(air)
	
	# Modelo 1: Bloque sólido
	var cube := VoxelBlockyModelCube.new()
	cube.set_name("block")
	library.add_model(cube)
	
	library.bake()
	mesher.library = library
	terrain.mesher = mesher
	
	# 3. Generador
	var generator := VoxelGeneratorNoise2D.new()
	generator.channel = VoxelBuffer.CHANNEL_TYPE
	
	var noise := FastNoiseLite.new()
	noise.seed = 42
	noise.frequency = 0.02
	
	generator.noise = noise
	terrain.generator = generator
	
	print("MinimalTest: Setup completo")
	print("  - 2 modelos en library (air + block)")
	print("  - generator: VoxelGeneratorNoise2D")
	print("  - channel: TYPE")
