extends VoxelGeneratorScript

## Generador de suelo plano con colinas suaves

@export var ground_level: float = 0.0
@export var hill_height: float = 4.0
@export var hill_frequency: float = 0.01

var _noise: FastNoiseLite

func _get_noise() -> FastNoiseLite:
	if not _noise:
		_noise = FastNoiseLite.new()
		_noise.seed = 42
		_noise.frequency = hill_frequency
		_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	return _noise

func _generate_block(out_buffer: VoxelBuffer, origin: Vector3i, _block_size: int) -> void:
	var n := _get_noise()
	var size := out_buffer.get_size()
	
	for z in range(size.z):
		for x in range(size.x):
			var world_x: float = origin.x + x
			var world_z: float = origin.z + z
			
			var noise_val: float = n.get_noise_2d(world_x, world_z)
			var height: float = ground_level + (noise_val + 1.0) * 0.5 * hill_height
			
			for y in range(size.y):
				var world_y: float = origin.y + y
				if world_y <= height:
					out_buffer.set_voxel(1, x, y, z, VoxelBuffer.CHANNEL_TYPE)
				else:
					out_buffer.set_voxel(0, x, y, z, VoxelBuffer.CHANNEL_TYPE)
