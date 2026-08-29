class_name IslandGenerator
extends RefCounted

## Módulo 09/10: Generador de Isla — Heightmap procedural
## Genera el terreno de la Isla Raíz (principal)

## Semilla del mundo (para PRNG determinista)
var seed_value: int = 42

## Tamaño de la isla en voxels
var island_radius: int = 64

## Altura máxima de la isla
var max_height: int = 40

## Profundidad del agua alrededor
var water_level: int = 2

## Referencia al catálogo de bloques
var _catalog: BlockCatalog = null

## Ruido para la forma de la isla
var _island_noise: FastNoiseLite = null

## Ruido para el terreno (detalles)
var _terrain_noise: FastNoiseLite = null

## Ruido para biomas
var _biome_noise: FastNoiseLite = null

func _init(catalog: BlockCatalog, world_seed: int = 42) -> void:
	_catalog = catalog
	seed_value = world_seed
	_setup_noises()

## Configura los ruidos para generación procedural
func _setup_noises() -> void:
	# Ruido de forma de isla (bordes suaves)
	_island_noise = FastNoiseLite.new()
	_island_noise.seed = seed_value
	_island_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_island_noise.frequency = 0.02
	_island_noise.fractal_octaves = 3
	
	# Ruido de terreno (detalles, montañas)
	_terrain_noise = FastNoiseLite.new()
	_terrain_noise.seed = seed_value + 1000
	_terrain_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_terrain_noise.frequency = 0.04
	_terrain_noise.fractal_octaves = 4
	
	# Ruido de biomas (distribución de biomas)
	_biome_noise = FastNoiseLite.new()
	_biome_noise.seed = seed_value + 2000
	_biome_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_biome_noise.frequency = 0.01
	_biome_noise.fractal_octaves = 2

## Genera el valor de altura para una posición (x, z)
func get_height(x: int, z: int) -> int:
	# Distancia al centro de la isla (normalizada 0-1)
	var dx := float(x - island_radius)
	var dz := float(z - island_radius)
	var dist := sqrt(dx * dx + dz * dz) / float(island_radius)
	
	# Forma de la isla: curva pronunciada con playa clara
	var island_shape: float = 1.0 - clamp(dist, 0.0, 1.0)
	# Curva pronunciada: suavidad en bordes, plano en centro
	island_shape = pow(island_shape, 1.5)
	
	# Suavizar bordes con ruido
	var shape_noise := _island_noise.get_noise_2d(float(x), float(z))
	island_shape *= (0.7 + shape_noise * 0.5)

	# Directiva 2026-08-29: el terreno cubre casi todo el mundo (meseta minima de 8
	# con pasto), el agua queda recien en el borde exterior (85%+ del radio).
	if island_shape <= 0.0 or dist >= 0.85:
		return 0

	# Si la forma es muy baja pero seguimos dentro del terreno, usar la meseta
	if island_shape < 0.15:
		island_shape = 0.15

	# Ruido de terreno para detalles
	var terrain_noise := _terrain_noise.get_noise_2d(float(x), float(z))

	# Altura final: forma * max_height + detalles, con piso minimo de 8
	var height := int(maxf(island_shape * max_height, 8.0) + terrain_noise * 5)
	return maxi(height, 0)

## Obtiene el tipo de bloque para una posición (x, y, z)
func get_block_at(x: int, y: int, z: int) -> int:
	var height := get_height(x, z)
	
	# Fuera del agua
	if y > height:
		if y <= water_level:
			return BlockType.WATER
		return BlockType.AIR
	
	# Roca madre en el fondo
	if y <= 0:
		return BlockType.BEDROCK
	
	# Bioma
	var biome := _get_biome(x, z)
	
	# Capas de terreno según bioma
	if y == height:
		# Superficie
		match biome:
			"beach":
				return BlockType.SAND
			"snow":
				return BlockType.SNOW
			"forest", "grassland":
				return BlockType.GRASS
			"mountain":
				return BlockType.STONE
			_:
				return BlockType.GRASS
	elif y > height - 3:
		# Justo debajo de la superficie
		match biome:
			"beach":
				return BlockType.SAND
			"mountain":
				return BlockType.STONE
			_:
				return BlockType.DIRT
	else:
		# Profundidad: piedra con minerales
		if y < height - 10 and _has_ore(x, y, z):
			return _get_ore_type(y)
		return BlockType.STONE

## Determina el bioma basado en posición y altura
func _get_biome(x: int, z: int) -> String:
	var height := get_height(x, z)
	var biome_val := _biome_noise.get_noise_2d(float(x), float(z))
	
	# Playa: cerca del nivel del agua (0-3)
	if height <= 3:
		return "beach"
	
	# Montaña: alta altitud
	if height > max_height * 0.65:
		return "mountain"
	
	# Nieve: muy alta
	if height > max_height * 0.8:
		return "snow"
	
	# Bosque vs pradera según ruido
	if biome_val > 0.0:
		return "forest"
	
	return "grassland"

## Verifica si hay un mineral en esta posición
func _has_ore(x: int, y: int, z: int) -> bool:
	var ore_noise := FastNoiseLite.new()
	ore_noise.seed = seed_value + 3000
	ore_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	ore_noise.frequency = 0.1
	
	var val := ore_noise.get_noise_3d(float(x), float(y), float(z))
	return val > 0.6

## Obtiene el tipo de mineral
func _get_ore_type(y: int) -> int:
	# Profundidad determina el mineral
	if y < 5:
		return BlockType.COPPER_ORE
	elif y < 15:
		return BlockType.IRON_ORE
	else:
		return BlockType.CRYSTAL

## Obtiene el color de debug para una posición (para visualización procedural)
func get_debug_color(x: int, y: int, z: int) -> Color:
	var block_id := get_block_at(x, y, z)
	var bt: BlockType = _catalog.get_block(block_id)
	if bt:
		return bt.debug_color
	return Color.MAGENTA
