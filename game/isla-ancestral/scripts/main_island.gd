extends Node3D

## Escena principal — Isla Raíz con generación procedural (M09/M10)

@onready var fps_label = $UI/FPSLabel
@onready var terrain: VoxelTerrain = $VoxelTerrain
@onready var viewer: VoxelViewer = $VoxelViewer

var time := 0.0

func _ready():
	_setup_terrain()
	_setup_player_visual()
	_crear_ruina()
	_crear_ui_dialogo()
	print("Isla Ancestral — Isla Raíz")

func _crear_ruina() -> void:
	var ruina := RuinaChozavil.new()
	ruina.name = "RuinaChozavil"
	add_child(ruina)

## M21: instancia la UI de diálogo (CanvasLayer autocontenido)
func _crear_ui_dialogo() -> void:
	var ui := DialogueUI.new()
	ui.name = "DialogueUI"
	add_child(ui)

func _setup_terrain() -> void:
	if not terrain:
		print("ERROR: VoxelTerrain no encontrado")
		return
	
	# Material con vertex color
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	terrain.material_override = mat
	
	# Mesher con catálogo de bloques por bioma
	var mesher := VoxelMesherBlocky.new()
	var library := VoxelBlockyLibrary.new()
	
	# Modelo 0: Aire
	var air := VoxelBlockyModelEmpty.new()
	air.set_name("air")
	library.add_model(air)
	
	# Modelos 1-20: Bloques con colores de bioma
	_add_block(library, "dirt", Color(0.55, 0.35, 0.16))
	_add_block(library, "grass", Color(0.33, 0.44, 0.12))  # 55711E
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
	_add_block(library, "water", Color(0.04, 0.29, 0.57))
	# IDs 18-25: placeholders alineados con BlockType (M24-M26 los usarán a futuro)
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
	_add_block(library, "shallow_water", Color(0.25, 0.82, 0.78))
	
	library.bake()
	mesher.library = library
	terrain.mesher = mesher
	
	# Generador de isla con biomas (M09/M10)
	var generator = load("res://scripts/world/world_generator.gd").new()
	generator.world_seed = 42
	generator.island_radius = 256
	generator.max_height = 40
	terrain.generator = generator
	
	# Spawn del jugador: sobre la superficie de la isla (cae y aterriza en la cresta,
	# nunca en el agua del océano que está a nivel de mar)
	var player = get_node_or_null("Player")
	if player:
		player.global_position = Vector3(256, 16, 256)
	var voxel_viewer_node = get_node_or_null("VoxelViewer")
	if voxel_viewer_node:
		voxel_viewer_node.global_position = Vector3(256, 30, 256)
	_ajustar_spawn_superficie.call_deferred()
	
	print("[M09] Isla Aurora — terreno con biomas (semilla: 42)")

func _add_block(library: VoxelBlockyLibrary, block_name: String, color: Color) -> void:
	var cube := VoxelBlockyModelCube.new()
	cube.set_name(block_name)
	cube.set_color(color)
	library.add_model(cube)

func _setup_player_visual() -> void:
	var player = get_node_or_null("Player")
	if not player:
		return
	var mesh_inst: MeshInstance3D = player.get_node_or_null("BodyMesh")
	if mesh_inst:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.2, 0.5, 0.9)
		mesh_inst.material_override = mat
		print("[M08] Jugador coloreado de azul")

func _process(delta: float) -> void:
	var viewer_seg = get_node_or_null("VoxelViewer")
	var jugador_seg = get_node_or_null("Player")
	if viewer_seg and jugador_seg:
		viewer_seg.global_position = jugador_seg.global_position
	time += delta
	if time >= 0.5:
		var fps = Engine.get_frames_per_second()
		if fps_label:
			fps_label.text = "FPS: %d" % fps
			if fps >= 55:
				fps_label.modulate = Color.GREEN
			elif fps >= 30:
				fps_label.modulate = Color.YELLOW
			else:
				fps_label.modulate = Color.RED
		time = 0.0

func _ajustar_spawn_superficie() -> void:
	# Altura calculada directo del generador (sin teleport de 4s):
	# el jugador nace ya sobre la superficie real de la columna del spawn
	var gen = terrain.generator
	if gen != null and gen.has_method("_get_island_gen"):
		var altura_spawn: int = int(gen._get_island_gen().get_height(256, 256))
		var player = get_node_or_null("Player")
		if player:
			player.global_position = Vector3(256, altura_spawn + 3, 256)
			print("[M09] Spawn sobre superficie calculada Y=", altura_spawn + 3)
