# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M167: Escena de inspeccion visual de la costa (QA visual L.3-L.5).
# Replica EXACTAMENTE la config de main_island.gd (semilla 42, radio 256,
# max_height 40, paleta Maldivas, misma libreria con SHALLOW_WATER id 30)
# y posiciona el VoxelViewer en la playa mirando al mar, para verificar:
#   - plato de arena plano (L.3)
#   - banda de agua clara turquesa SHALLOW_WATER (L.4)
#   - agua profunda azul (L.5)
# Uso: escena res://scenes/captura_playa.tscn con este script en el root.

extends Node3D

var _terrain: VoxelTerrain

func _ready() -> void:
	_setup_terrain()
	_setup_camara()
	print("=== M167: CAPTURA COSTA (QA visual L.3-L.5) ===")
	await get_tree().process_frame
	await get_tree().process_frame

func _add_block(library: VoxelBlockyLibrary, block_name: String, color: Color) -> void:
	var cube := VoxelBlockyModelCube.new()
	cube.set_name(block_name)
	cube.set_color(color)
	library.add_model(cube)

func _setup_terrain() -> void:
	_terrain = _terrain if _terrain else VoxelTerrain.new()
	_terrain.name = "VoxelTerrain"
	if _terrain.get_parent() == null:
		add_child(_terrain)

	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	_terrain.material_override = mat

	var mesher := VoxelMesherBlocky.new()
	var library := VoxelBlockyLibrary.new()

	var air := VoxelBlockyModelEmpty.new()
	air.set_name("air")
	library.add_model(air)

	# Paleta Maldivas — MISMOS colores y ORDEN que main_island.gd (la identidad
	# de cada bloque en la library depende del orden de modelos).
	_add_block(library, "dirt", Color(0.55, 0.35, 0.16))
	_add_block(library, "grass", Color(0.33, 0.44, 0.12))
	_add_block(library, "stone", Color(0.49, 0.49, 0.52))
	_add_block(library, "bedrock", Color(0.2, 0.2, 0.2))
	_add_block(library, "sand", Color(0.96, 0.94, 0.88))
	_add_block(library, "clay", Color(0.6, 0.5, 0.4))
	_add_block(library, "wood", Color(0.45, 0.3, 0.15))
	_add_block(library, "planks", Color(0.6, 0.45, 0.25))
	_add_block(library, "copper_ore", Color(0.7, 0.45, 0.2))
	_add_block(library, "iron_ore", Color(0.6, 0.6, 0.65))
	_add_block(library, "crystal", Color(0.4, 0.7, 0.9))
	_add_block(library, "gemstone", Color(0.9, 0.7, 0.1))
	_add_block(library, "glass", Color(0.8, 0.9, 1.0))
	_add_block(library, "ancient_crystal", Color(0.6, 0.8, 1.0))
	_add_block(library, "lamp_glyph", Color(1.0, 0.9, 0.4))
	_add_block(library, "ice", Color(0.7, 0.85, 1.0))
	_add_block(library, "water", Color(0.10, 0.45, 0.75))
	_add_block(library, "pressure_plate", Color(0.35, 0.3, 0.28))
	_add_block(library, "light_receiver", Color(0.9, 0.8, 0.3))
	_add_block(library, "glyph_emitter", Color(0.3, 0.8, 0.8))
	_add_block(library, "sliding_block", Color(0.45, 0.5, 0.55))
	_add_block(library, "flow_vase", Color(0.75, 0.45, 0.3))
	_add_block(library, "adobe_wall", Color(0.8, 0.65, 0.45))
	_add_block(library, "floor_tile", Color(0.85, 0.8, 0.7))
	_add_block(library, "roof_tile", Color(0.7, 0.3, 0.25))
	_add_block(library, "snow", Color(0.95, 0.95, 0.98))
	_add_block(library, "gravel", Color(0.55, 0.5, 0.45))
	_add_block(library, "moss", Color(0.25, 0.5, 0.2))
	_add_block(library, "mud", Color(0.35, 0.25, 0.15))
	_add_block(library, "shallow_water", Color(0.25, 0.82, 0.78)) # id 30 turquesa

	library.bake()
	mesher.library = library
	_terrain.mesher = mesher

	var generator = load("res://scripts/world/world_generator.gd").new()
	generator.world_seed = 42
	generator.island_radius = 256
	generator.max_height = 40
	_terrain.generator = generator

	# Reporte de alturas reales en los puntos de interes
	var ig = generator._get_island_gen()
	print("[M167] playa (486,256): h=%d" % ig.get_height(486, 256))
	print("[M167] agua clara (503,256): h=%d block=%d" % [ig.get_height(503, 256), ig.get_block_at(503, ig.get_height(503, 256) + 1, 256)])
	print("[M167] agua profunda (530,256): h=%d block=%d" % [ig.get_height(530, 256), ig.get_block_at(530, 1, 256)])

func _setup_camara() -> void:
	# Camera: mirando la playa y el mar hacia +Z (la montaña central queda atras).
	var cam := Camera3D.new()
	cam.position = Vector3(486, 28, 216)
	cam.rotation_degrees = Vector3(-15, 0, 0)
	add_child(cam)

	var viewer := VoxelViewer.new()
	viewer.position = Vector3(486, 16, 256)
	viewer.view_distance = 256.0
	add_child(viewer)

	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, 30, 0)
	light.light_energy = 1.6
	light.shadow_enabled = true
	add_child(light)
