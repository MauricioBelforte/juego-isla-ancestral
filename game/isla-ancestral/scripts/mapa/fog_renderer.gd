# Modelo: mimo-v2.5-free
# Plataforma: OpenCode
# Fecha: 2026-09-14
#
# M54: Mapa — FogRenderer (niebla de guerra visual)
# Renderiza la niebla de guerra como una textura superpuesta al mapa.
# Mosaicos sucios se actualizan solo cuando exploration_changed emite.

extends TextureRect
class_name FogRenderer

var _fog_image: Image
var _fog_texture: ImageTexture
var _tile_size: int = 32
var _dirty_tiles: Array[int] = []

func _ready() -> void:
	stretch_mode = TextureRect.STRETCH_SCALE
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func refresh(explorer_node: Node, map_size: Vector2i, dirty: Array[int]) -> void:
	if explorer_node == null:
		return

	# Create fog image if needed
	if _fog_image == null or _fog_image.get_size() != Vector2i(map_size):
		_fog_image = Image.create(map_size.x, map_size.y, false, Image.FORMAT_RGBA8)
		_fog_image.fill(Color(0.05, 0.05, 0.05, 0.9))

	# Update dirty tiles
	if dirty.is_empty():
		# Full refresh
		_apply_fog_from_explorer(explorer_node, map_size)
	else:
		for tile_id in dirty:
			_apply_tile(explorer_node, tile_id, map_size)

	# Create texture
	_fog_texture = ImageTexture.create_from_image(_fog_image)
	texture = _fog_texture

func _apply_fog_from_explorer(explorer_node: Node, map_size: Vector2i) -> void:
	if _fog_image == null:
		return
	# Clear fog for explored regions
	if explorer_node.has_method("get_explored_regions"):
		var regions = explorer_node.get_explored_regions()
		for region_id in regions:
			_unfog_region(region_id, map_size)

func _apply_tile(explorer_node: Node, tile_id: int, map_size: Vector2i) -> void:
	if _fog_image == null:
		return
	# Simplified: just unfog a region by tile_id
	_unfog_region(tile_id, map_size)

func _unfog_region(region_id: int, map_size: Vector2i) -> void:
	if _fog_image == null:
		return
	# Map region_id to a position (simplified hash)
	var hash_val := region_id * 7919  # Prime for distribution
	var x := absi(hash_val) % map_size.x
	var y := absi(hash_val / map_size.x) % map_size.y
	var radius := 32

	# Clear a circle in the fog
	for dx in range(-radius, radius + 1):
		for dy in range(-radius, radius + 1):
			if dx * dx + dy * dy <= radius * radius:
				var px := clampi(x + dx, 0, map_size.x - 1)
				var py := clampi(y + dy, 0, map_size.y - 1)
				_fog_image.set_pixel(px, py, Color.TRANSPARENT)

func set_tile_size(size: int) -> void:
	_tile_size = size
