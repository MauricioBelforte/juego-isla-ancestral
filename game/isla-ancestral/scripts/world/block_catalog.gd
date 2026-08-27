class_name BlockCatalog
extends RefCounted

## Módulo 08: Mundo Voxel — Catálogo centralizado de bloques
## Proporciona el VoxelBlockyLibrary y acceso por ID

## Diccionario de bloques por ID
var _blocks: Dictionary = {}

## Library de Voxel Tools (para VoxelMesherBlocky)
var _library: VoxelBlockyLibrary = null

## Número de modelos en la library
var _model_count: int = 0

func _init() -> void:
	_build_catalog()
	_build_library()

## Construye el catálogo con todos los bloques del juego
func _build_catalog() -> void:
	# Registrar solo los bloques que VoxelBlockyLibrary soporta como modelos
	# En Godot con Voxel Tools, los modelos se agregan como VoxelBlockyModelCube
	# o VoxelBlockyModelEmpty para el aire
	
	var block_ids := [
		BlockType.AIR,
		BlockType.DIRT,
		BlockType.GRASS,
		BlockType.STONE,
		BlockType.BEDROCK,
		BlockType.SAND,
		BlockType.CLAY,
		BlockType.WOOD,
		BlockType.PLANKS,
		BlockType.COPPER_ORE,
		BlockType.IRON_ORE,
		BlockType.CRYSTAL,
		BlockType.GEMSTONE,
		BlockType.GLASS,
		BlockType.ICE,
		BlockType.WATER,
		BlockType.SNOW,
		BlockType.GRAVEL,
		BlockType.MOSS,
		BlockType.MUD,
	]
	
	for bid in block_ids:
		_blocks[bid] = BlockType.create_default(bid)

## Construye la VoxelBlockyLibrary para VoxelMesherBlocky
func _build_library() -> void:
	_library = VoxelBlockyLibrary.new()
	
	# Modelo 0: Aire (siempre primero)
	var air_model := VoxelBlockyModelEmpty.new()
	air_model.set_name("air")
	_library.add_model(air_model)
	_model_count = 1
	
	# Modelos sólidos: cada bloque se convierte en un Cubo
	var solid_blocks := [
		BlockType.DIRT,
		BlockType.GRASS,
		BlockType.STONE,
		BlockType.BEDROCK,
		BlockType.SAND,
		BlockType.CLAY,
		BlockType.WOOD,
		BlockType.PLANKS,
		BlockType.COPPER_ORE,
		BlockType.IRON_ORE,
		BlockType.CRYSTAL,
		BlockType.GEMSTONE,
		BlockType.GLASS,
		BlockType.ICE,
		BlockType.SNOW,
		BlockType.GRAVEL,
		BlockType.MOSS,
		BlockType.MUD,
	]
	
	for bid in solid_blocks:
		var bt: BlockType = _blocks[bid]
		var model := VoxelBlockyModelCube.new()
		model.set_name(bt.display_name)
		# VoxelBlockyModelCube no tiene set_material
		# Los colores se asignan por VoxelMesherBlocky o por script
		_library.add_model(model)
		_model_count += 1
	
	# Water como modelo especial
	var water_model := VoxelBlockyModelCube.new()
	water_model.set_name("Agua")
	_library.add_model(water_model)
	_model_count += 1
	
	# Bake de la library (OBLIGATORIO según guía Godot §2.3)
	_library.bake()

## Obtiene la VoxelBlockyLibrary (ya bakesada)
func get_library() -> VoxelBlockyLibrary:
	return _library

## Obtiene el BlockType por ID
func get_block(block_id: int) -> BlockType:
	return _blocks.get(block_id, null)

## Obtiene el índice del modelo en la library para un block_id
func get_model_index(block_id: int) -> int:
	# Los modelos se agregan en orden: 0=air, 1=dirt, 2=grass, etc.
	# Usamos el mismo orden que solid_blocks
	var solid_blocks := [
		BlockType.AIR,
		BlockType.DIRT,
		BlockType.GRASS,
		BlockType.STONE,
		BlockType.BEDROCK,
		BlockType.SAND,
		BlockType.CLAY,
		BlockType.WOOD,
		BlockType.PLANKS,
		BlockType.COPPER_ORE,
		BlockType.IRON_ORE,
		BlockType.CRYSTAL,
		BlockType.GEMSTONE,
		BlockType.GLASS,
		BlockType.ICE,
		BlockType.SNOW,
		BlockType.GRAVEL,
		BlockType.MOSS,
		BlockType.MUD,
		BlockType.WATER,
	]
	return solid_blocks.find(block_id)

## Número total de modelos
func get_model_count() -> int:
	return _model_count
