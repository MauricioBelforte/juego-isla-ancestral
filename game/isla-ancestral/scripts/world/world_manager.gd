extends Node3D

## Módulo 08/09/10: World Manager — Versión simplificada que funciona
## Copia exacta del setup minimal_test.gd que genera terreno visible

## Semilla del mundo
@export var world_seed: int = 42

## Radio de la isla
@export var island_radius: int = 64

## Altura máxima
@export var max_height: int = 40

## Referencia al VoxelTerrain (hermano, no hijo)
@onready var terrain: VoxelTerrain = $"../VoxelTerrain"

func _ready() -> void:
	# Setup EXACTAMENTE igual al minimal_test que funciona
	_setup_terrain()
	print("WorldManager: Isla Raíz inicializada (semilla: %d)" % world_seed)

## Setup idéntico al minimal_test.gd que genera terreno visible
func _setup_terrain() -> void:
	if not terrain:
		print("WorldManager: ERROR - VoxelTerrain no encontrado")
		return
	
	# 1. Material con vertex color
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	terrain.material_override = mat
	
	# 2. Mesher con 2 modelos (air + block)
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
	noise.seed = world_seed
	noise.frequency = 0.02
	
	generator.noise = noise
	terrain.generator = generator
	
	print("WorldManager: Setup completado (2 modelos, VoxelGeneratorNoise2D)")
