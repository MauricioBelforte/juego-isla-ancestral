class_name BlockCatalog
extends RefCounted

## Módulo 08: Mundo Voxel — Catálogo centralizado y CANÓNICO de bloques.
## Fuente única de la VoxelBlockyLibrary del juego.
## Invariante crítico: el índice de cada modelo en la library == BlockType id
## del bloque (VoxelMesherBlocky usa el valor del canal CHANNEL_TYPE como
## índice del modelo). Si se registra un id sin modelo —o en desorden— el
## renderizado voxel se rompe silenciosamente.
## Unificación (Log 1728, encargo mimo #27): antes main_island.gd construía su
## propia library inline y BlockCatalog otra divergente (modelos 14-19 mapeados
## a ids 16/26/27/28/29/17). Ahora TODOS consumen get_library().

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
## (ids 0..MAX contiguos — sin huecos, ver guarda en _build_library).
func _build_catalog() -> void:
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
		BlockType.ANCIENT_CRYSTAL,
		BlockType.LAMP_GLYPH,
		BlockType.ICE,
		BlockType.WATER,
		BlockType.PRESSURE_PLATE,
		BlockType.LIGHT_RECEIVER,
		BlockType.GLYPH_EMITTER,
		BlockType.SLIDING_BLOCK,
		BlockType.FLOW_VASE,
		BlockType.ADOBE_WALL,
		BlockType.FLOOR_TILE,
		BlockType.ROOF_TILE,
		BlockType.SNOW,
		BlockType.GRAVEL,
		BlockType.MOSS,
		BlockType.MUD,
		BlockType.SHALLOW_WATER,
		BlockType.TIERRA_ARADA,
		BlockType.TIERRA_ARADA_HUMEDA,
	]

	for bid in block_ids:
		_blocks[bid] = BlockType.create_default(bid)

## Colores canónicos de renderizado (terrain.material_override usa
## vertex_color_use_as_albedo). Tabla afinada originalmente para la library
## inline de main_island.gd (MiMo V2.5) — trasladada aquí como fuente única.
func _color_canonico(block_id: int) -> Color:
	match block_id:
		BlockType.DIRT: return Color(0.55, 0.35, 0.16)
		BlockType.GRASS: return Color(0.33, 0.44, 0.12)
		BlockType.STONE: return Color(0.49, 0.49, 0.52)
		BlockType.BEDROCK: return Color(0.2, 0.2, 0.2)
		BlockType.SAND: return Color(0.96, 0.94, 0.88)
		BlockType.CLAY: return Color(0.6, 0.5, 0.4)
		BlockType.WOOD: return Color(0.45, 0.3, 0.15)
		BlockType.PLANKS: return Color(0.6, 0.45, 0.25)
		BlockType.COPPER_ORE: return Color(0.7, 0.45, 0.2)
		BlockType.IRON_ORE: return Color(0.6, 0.6, 0.65)
		BlockType.CRYSTAL: return Color(0.4, 0.7, 0.9)
		BlockType.GEMSTONE: return Color(0.9, 0.7, 0.1)
		BlockType.GLASS: return Color(0.8, 0.9, 1.0)
		BlockType.ANCIENT_CRYSTAL: return Color(0.6, 0.8, 1.0)
		BlockType.LAMP_GLYPH: return Color(1.0, 0.9, 0.4)
		BlockType.ICE: return Color(0.7, 0.85, 1.0)
		BlockType.WATER: return Color(0.10, 0.45, 0.75)  # azul océano más claro
		BlockType.PRESSURE_PLATE: return Color(0.35, 0.3, 0.28)
		BlockType.LIGHT_RECEIVER: return Color(0.9, 0.8, 0.3)
		BlockType.GLYPH_EMITTER: return Color(0.3, 0.8, 0.8)
		BlockType.SLIDING_BLOCK: return Color(0.45, 0.5, 0.55)
		BlockType.FLOW_VASE: return Color(0.75, 0.45, 0.3)
		BlockType.ADOBE_WALL: return Color(0.8, 0.65, 0.45)
		BlockType.FLOOR_TILE: return Color(0.85, 0.8, 0.7)
		BlockType.ROOF_TILE: return Color(0.7, 0.3, 0.25)
		BlockType.SNOW: return Color(0.95, 0.95, 0.98)
		BlockType.GRAVEL: return Color(0.55, 0.5, 0.45)
		BlockType.MOSS: return Color(0.25, 0.5, 0.2)
		BlockType.MUD: return Color(0.35, 0.25, 0.15)
		BlockType.SHALLOW_WATER: return Color(0.25, 0.82, 0.78)
		BlockType.TIERRA_ARADA: return Color(0.48, 0.32, 0.18)
		BlockType.TIERRA_ARADA_HUMEDA: return Color(0.32, 0.22, 0.12)
		_: return BlockType.create_default(block_id).debug_color  # futuro-proof

## Construye la VoxelBlockyLibrary en orden de ID: modelo en el índice N ==
## bloque con id N. Es la única propiedad que mantiene correcto el renderizado
## blocky (el canal CHANNEL_TYPE guarda el id y el mesher lo usa como índice).
func _build_library() -> void:
	# Guarda de integridad: los ids registrados deben ser contiguos desde 0.
	# Si hay un hueco, el índice deja de coincidir con el id y el renderizado
	# se rompe silenciosamente — abortamos el bake antes de servir una library
	# corrupta.
	var ids: Array = _blocks.keys()
	ids.sort()
	for i in ids.size():
		if int(ids[i]) != i:
			push_error("[M08 BlockCatalog] ids no contiguos: índice %d tiene id %s — library corrupta, bake abortado" % [i, ids[i]])
			return

	_library = VoxelBlockyLibrary.new()
	_model_count = 0
	for bid in ids:
		var bid_int := int(bid)
		if bid_int == BlockType.AIR:
			# Modelo 0: Aire (VoxelBlockyModelEmpty, siempre primero)
			var air_model := VoxelBlockyModelEmpty.new()
			air_model.set_name("air")
			_library.add_model(air_model)
		else:
			var bt: BlockType = _blocks[bid]
			# VoxelBlockyModelCube no tiene set_material: el color va por
			# vértice (set_color) y el material del terrain usa vertex_color.
			var model := VoxelBlockyModelCube.new()
			model.set_name(bt.display_name)
			model.set_color(_color_canonico(bid_int))
			_library.add_model(model)
		_model_count += 1

	# Bake de la library (OBLIGATORIO según guía Godot §2.3)
	_library.bake()

## Obtiene la VoxelBlockyLibrary (ya bakeada)
func get_library() -> VoxelBlockyLibrary:
	return _library

## Obtiene el BlockType por ID
func get_block(block_id: int) -> BlockType:
	return _blocks.get(block_id, null)

## Obtiene el índice del modelo en la library para un block_id.
## Por construcción (invariante), el índice SIEMPRE es igual al id.
func get_model_index(block_id: int) -> int:
	return block_id

## Número total de modelos
func get_model_count() -> int:
	return _model_count
