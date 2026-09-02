class_name IslandGenerator
extends RefCounted

## Módulo 09/10: Generador de Isla — Heightmap procedural
## Genera el terreno de la Isla Raíz (principal)

## Semilla del mundo (para PRNG determinista)
var seed_value: int = 42

## Tamaño de la isla en voxels
var island_radius: int = 2560

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

	# Directiva 2026-08-29: terreno continuo; el agua queda recien en el borde
	# exterior, con transicion suave (playa -> oceano).

	# Si la forma es muy baja pero seguimos dentro del terreno, usar la meseta
	if island_shape < 0.15:
		island_shape = 0.15

	# Ruido de terreno para detalles
	var terrain_noise := _terrain_noise.get_noise_2d(float(x), float(z))

	# Ruido de terreno para el detalle de la montaña central
	var mountain_noise := _terrain_noise.get_noise_2d(float(x) / 12.0, float(z) / 12.0)
	var height := 0
	
	# PERFIL EN CAPAS (spec del usuario, fotos isla-modelo-2/3):
	# 1) AGUA: ultimo anillo (98-100%) -> height 0 -> water_level pone oceano.
	# 2) ANILLO CIRCULAR: centro hasta 98% -> arena plana/playa (height 3-4, SAND).
	# 3) MONTANAS DE PIEDRA: dentro del 55%, picos escarpados de roca gris (STONE
	#    via bioma mountain, height > max_height*0.65) con selva/bosque en la base.
	# AGUAS EN DOS NIVELES (spec usuario): 0.94-0.98 = agua CLARA (fondo a
	# altura 2: el jugador camina de pie sumergido hasta la cintura); >0.98 =
	# agua PROFUNDA (fondo a 0: se hunde).
	if dist <= 0.94:
		height = 3 + int(maxf(0.0, terrain_noise) * 1.5)
	elif dist <= 0.98:
		height = 2
	else:
		height = 0
	var crestas := _terrain_noise.get_noise_2d(float(x) / 6.0, float(z) / 6.0)
	# MONTANAS TIPO VOLCAN adentro del 55% (forma de antes: island_shape *
	# max_height: picos altos de piedra por bioma mountain + selva en laderas),
	# y PEQUENOS MONTICULOS DE PASTO en la llanura exterior (0.55-0.94).
	# NUNCA rellenar fuera del 55% (eso hacia la isla infinita sin orilla).
	# Ladera continua: la montana se estira hasta dist 0.78 y llega EXACTAMENTE
	# a la altura de la planicie (3) — sin muro ni escalon. La pendiente es
	# conica continua desde el pico (centro) hasta la llanura de arena.
	# MONTANAS MULTIPLES (monticulos que varian entre ellos — spec usuario):
	# pico_original usa el ruido de la isla => VARIOS volcanes de alturas y
	# formas distintas. Se mezclan con la planicie mediante lerp suave
	# (sin muros verticales de torta) y la costa (0.94-1.0) queda intacta:
	# arena -> agua clara -> agua profunda.
	var pico_original := pow(maxf(island_shape, 0.0), 1.5) * max_height
	var pendiente := clampf((0.85 - dist) / 0.85, 0.0, 1.0)
	var altura_suave := 3.0 + pow(pendiente, 1.3) * 10.0
	var alturas := maxf(pico_original, altura_suave)
	if crestas > 0.0:
		alturas += crestas * 6.0
	var peso_montana := clampf((0.85 - dist) / 0.15, 0.0, 1.0)
	height = int(lerpf(float(height), float(alturas), peso_montana))
	return maxi(height, 0)

## Obtiene el tipo de bloque para una posición (x, y, z)
func get_block_at(x: int, y: int, z: int) -> int:
	var height := get_height(x, z)
	var dist := sqrt(pow(float(x - island_radius), 2.0) + pow(float(z - island_radius), 2.0)) / float(island_radius)
	
	# Fuera del terreno: agua en dos niveles (spec M167). Banda costera
	# 0.94-0.98 = agua CLARA turquesa (SHALLOW_WATER) pisable sobre el fondo de
	# arena; >0.98 = agua PROFUNDA azul. La capa de agua clara se coloca en
	# y = height+1 (=3) para que el jugador camine sumergido hasta la cintura
	# (fix 2026-09-01, deepseek-v4-flash-vision-exp: antes y <= water_level
	# dejaba esa celda como AIR -> el agua turquesa nunca se generaba).
	if y > height:
		if y <= water_level + 1:
			if dist > 0.94 and dist <= 0.98:
				return BlockType.SHALLOW_WATER
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
