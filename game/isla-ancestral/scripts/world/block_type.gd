class_name BlockType
extends Resource

## Módulo 08: Mundo Voxel — Modelo de datos de bloque
## Cada bloque del mundo es un Resource con propiedades definidas

## ID único del bloque (para serialización)
@export var id: int = 0

## Nombre legible
@export var display_name: String = ""

## Tipo de bloque para VoxelBlockyLibrary
enum BlockCategory {
	SOLID,       # Bloque sólido opaco
	TRANSPARENT, # Bloque transparente (vidrio, cristal)
	LIQUID,      # Líquido (agua)
	EMISSIVE,    # Emisivo (lámparas, glifos)
}

@export var category: BlockCategory = BlockCategory.SOLID

## Herramienta requerida para extraer
enum ToolRequirement {
	NONE,    # No requiere herramienta
	SHOVEL,  # Pala
	PICKAXE, # Pico
	AXE,     # Hacha
}

@export var tool_required: ToolRequirement = ToolRequirement.NONE

## ¿Es permanente? (no se puede extraer, ej: roca madre, ruinas)
@export var permanent: bool = false

## ¿Tiene gravedad? (arena suelta, etc.)
@export var has_gravity: bool = false

## ¿Es constructive? (se puede colocar como bloque de construcción)
@export var is_constructive: bool = false

## Items que dropea al extraer (item_id → cantidad)
@export var drops: Array[Dictionary] = []

## Sonidos (placeholder para M43)
@export var sound_hit: String = ""
@export var sound_place: String = ""
@export var sound_break: String = ""

## Color aproximado para debug/renderizado procedural
@export var debug_color: Color = Color.MAGENTA

## IDs de bloques conocidos (catálogo)
const AIR: int = 0
const DIRT: int = 1
const GRASS: int = 2
const STONE: int = 3
const BEDROCK: int = 4
const SAND: int = 5
const CLAY: int = 6
const WOOD: int = 7
const PLANKS: int = 8
const COPPER_ORE: int = 9
const IRON_ORE: int = 10
const CRYSTAL: int = 11
const GEMSTONE: int = 12
const GLASS: int = 13
const ANCIENT_CRYSTAL: int = 14
const LAMP_GLYPH: int = 15
const ICE: int = 16
const WATER: int = 17
const PRESSURE_PLATE: int = 18
const LIGHT_RECEIVER: int = 19
const GLYPH_EMITTER: int = 20
const SLIDING_BLOCK: int = 21
const FLOW_VASE: int = 22
const ADOBE_WALL: int = 23
const FLOOR_TILE: int = 24
const ROOF_TILE: int = 25
const SNOW: int = 26
const GRAVEL: int = 27
const MOSS: int = 28
const MUD: int = 29

## Crea un BlockType con valores por defecto para un ID dado
static func create_default(block_id: int) -> BlockType:
	var bt := BlockType.new()
	bt.id = block_id
	
	match block_id:
		AIR:
			bt.display_name = "Aire"
			bt.category = BlockCategory.TRANSPARENT
			bt.debug_color = Color(0, 0, 0, 0)
		DIRT:
			bt.display_name = "Tierra"
			bt.tool_required = ToolRequirement.SHOVEL
			bt.debug_color = Color(0.55, 0.35, 0.2)
		GRASS:
			bt.display_name = "Césped"
			bt.tool_required = ToolRequirement.SHOVEL
			bt.drops = [{"item_id": DIRT, "amount": 1}]
			bt.debug_color = Color(0.3, 0.6, 0.2)
		STONE:
			bt.display_name = "Piedra"
			bt.tool_required = ToolRequirement.PICKAXE
			bt.debug_color = Color(0.5, 0.5, 0.5)
		BEDROCK:
			bt.display_name = "Roca Madre"
			bt.permanent = true
			bt.debug_color = Color(0.2, 0.2, 0.2)
		SAND:
			bt.display_name = "Arena"
			bt.tool_required = ToolRequirement.SHOVEL
			bt.has_gravity = true
			bt.debug_color = Color(0.85, 0.8, 0.55)
		CLAY:
			bt.display_name = "Arcilla"
			bt.tool_required = ToolRequirement.SHOVEL
			bt.debug_color = Color(0.6, 0.5, 0.4)
		WOOD:
			bt.display_name = "Madera"
			bt.tool_required = ToolRequirement.AXE
			bt.debug_color = Color(0.45, 0.3, 0.15)
		PLANKS:
			bt.display_name = "Tablones"
			bt.is_constructive = true
			bt.debug_color = Color(0.6, 0.45, 0.25)
		COPPER_ORE:
			bt.display_name = "Cobre"
			bt.tool_required = ToolRequirement.PICKAXE
			bt.debug_color = Color(0.7, 0.45, 0.2)
		IRON_ORE:
			bt.display_name = "Hierro"
			bt.tool_required = ToolRequirement.PICKAXE
			bt.debug_color = Color(0.6, 0.6, 0.65)
		CRYSTAL:
			bt.display_name = "Cristal de Resonancia"
			bt.tool_required = ToolRequirement.PICKAXE
			bt.category = BlockCategory.EMISSIVE
			bt.debug_color = Color(0.4, 0.7, 0.9)
		GEMSTONE:
			bt.display_name = "Gema"
			bt.tool_required = ToolRequirement.PICKAXE
			bt.debug_color = Color(0.9, 0.7, 0.1)
		GLASS:
			bt.display_name = "Vidrio"
			bt.category = BlockCategory.TRANSPARENT
			bt.debug_color = Color(0.8, 0.9, 1.0, 0.3)
		ANCIENT_CRYSTAL:
			bt.display_name = "Cristal Antiguo"
			bt.category = BlockCategory.TRANSPARENT
			bt.debug_color = Color(0.6, 0.8, 1.0, 0.5)
		LAMP_GLYPH:
			bt.display_name = "Lámpara de Glifo"
			bt.category = BlockCategory.EMISSIVE
			bt.debug_color = Color(1.0, 0.9, 0.4)
		ICE:
			bt.display_name = "Hielo"
			bt.category = BlockCategory.TRANSPARENT
			bt.debug_color = Color(0.7, 0.85, 1.0, 0.6)
		WATER:
			bt.display_name = "Agua"
			bt.category = BlockCategory.LIQUID
			bt.debug_color = Color(0.2, 0.4, 0.8, 0.6)
		SNOW:
			bt.display_name = "Nieve"
			bt.tool_required = ToolRequirement.SHOVEL
			bt.debug_color = Color(0.95, 0.95, 0.98)
		GRAVEL:
			bt.display_name = "Grava"
			bt.tool_required = ToolRequirement.SHOVEL
			bt.has_gravity = true
			bt.debug_color = Color(0.55, 0.5, 0.45)
		MOSS:
			bt.display_name = "Musgo"
			bt.debug_color = Color(0.25, 0.5, 0.2)
		MUD:
			bt.display_name = "Barro"
			bt.tool_required = ToolRequirement.SHOVEL
			bt.debug_color = Color(0.35, 0.25, 0.15)
		_:
			bt.display_name = "Desconocido"
			bt.debug_color = Color.MAGENTA
	
	return bt
