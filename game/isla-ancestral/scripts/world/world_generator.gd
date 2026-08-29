extends VoxelGeneratorScript

## Módulo 10: Generador de Mundo Integrado
## Conecta IslandGenerator (biomas, minerales) con VoxelTerrain
## Semilla fija → generación determinista

@export var world_seed: int = 42
@export var island_radius: int = 2560
@export var max_height: int = 40

var _island_gen: IslandGenerator

## Referencia estatica fuerte: evita que el IslandGenerator se libere mientras
## los threads de generacion del VoxelTerrain lo estan usando (error
## "get_block_at in previously freed" — bug documentado en la guia Godot 10.14).
static var _instancia_global: IslandGenerator

func _get_island_gen() -> IslandGenerator:
	if not _island_gen or not is_instance_valid(_island_gen):
		_island_gen = IslandGenerator.new(null, world_seed)
		_island_gen.island_radius = island_radius
		_island_gen.max_height = max_height
		_instancia_global = _island_gen
	return _island_gen

func _get_used_channels_mask() -> int:
	return 1 << VoxelBuffer.CHANNEL_TYPE

func _generate_block(out_buffer: VoxelBuffer, origin: Vector3i, _block_size: int) -> void:
	var gen := _get_island_gen()
	var size := out_buffer.get_size()
	
	for z in range(size.z):
		for x in range(size.x):
			var world_x: int = origin.x + x
			var world_z: int = origin.z + z
			
			for y in range(size.y):
				var world_y: int = origin.y + y
				var block_id: int = gen.get_block_at(world_x, world_y, world_z)
				out_buffer.set_voxel(block_id, x, y, z, VoxelBuffer.CHANNEL_TYPE)
