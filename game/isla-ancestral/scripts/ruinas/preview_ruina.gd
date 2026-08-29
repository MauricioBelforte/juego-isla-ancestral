# Modelo: Hy3
# Plataforma: Kilo
# Fecha: 2026-08-29
#
# M25: Escena preview de la ruina — ruina construida sobre la altura REAL del
# terreno del generador de la isla (seed 42); camara fija a 45 grados para
# validar legibilidad con vision (captura PrintWindow / in-engine).

extends Node3D

var terrain: VoxelTerrain = null
var _altura: int = 1

func _ready() -> void:
	_crear_terreno_y_ruina()

func _crear_terreno_y_ruina() -> void:
	terrain = get_node("VoxelTerrain") as VoxelTerrain
	if terrain == null:
		return
	_setup_mesher_y_library()
	var generator = load("res://scripts/world/world_generator.gd").new()
	generator.world_seed = 42
	generator.island_radius = 64
	generator.max_height = 40
	terrain.generator = generator
	var viewer := VoxelViewer.new()
	viewer.name = "VoxelViewer"
	viewer.position = Vector3(8, 14, 8)
	add_child(viewer)
	_esperar_y_construir()

func _setup_mesher_y_library() -> void:
	var mesher := VoxelMesherBlocky.new()
	var library := VoxelBlockyLibrary.new()
	var air := VoxelBlockyModelEmpty.new()
	air.set_name("air")
	library.add_model(air)
	_add(library, "dirt", Color(0.55, 0.35, 0.2))
	_add(library, "grass", Color(0.3, 0.6, 0.2))
	_add(library, "stone", Color(0.5, 0.5, 0.5))
	_add(library, "sand", Color(0.85, 0.8, 0.55))
	_add(library, "wood", Color(0.45, 0.3, 0.15))
	library.bake()
	mesher.library = library
	terrain.mesher = mesher
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	terrain.material_override = mat

func _add(library: VoxelBlockyLibrary, block_name: String, color: Color) -> void:
	var cube := VoxelBlockyModelCube.new()
	cube.set_name(block_name)
	cube.set_color(color)
	library.add_model(cube)

func _esperar_y_construir() -> void:
	await get_tree().create_timer(8.0).timeout
	_generar_ruina()
	_encuadrar_y_capturar()

func _buscar_altura(x: int, z: int) -> int:
	var vt := terrain.get_voxel_tool()
	if vt == null:
		return 10
	vt.channel = VoxelBuffer.CHANNEL_TYPE
	for y in range(70, -10, -1):
		if int(vt.get_voxel(Vector3i(x, y, z))) != 0:
			return y
	return 10

func _generar_ruina() -> void:
	var vt := terrain.get_voxel_tool()
	if vt == null:
		return
	vt.channel = VoxelBuffer.CHANNEL_TYPE
	_altura = _buscar_altura(8, 8) + 1
	var by := _altura
	# Muro oeste (x=6) y este (x=9) a lo largo de z, mas muro sur (z=3)
	for dz in range(10):
		_write(vt, Vector3i(6, by, 3 + dz), 3)
		_write(vt, Vector3i(9, by, 3 + dz), 3)
	for dx in range(4):
		_write(vt, Vector3i(6 + dx, by, 3), 3)
	# Esquina derrumbada (muro alto hacia el norte)
	_write(vt, Vector3i(6, by + 1, 5), 3)
	_write(vt, Vector3i(6, by + 1, 6), 3)
	_write(vt, Vector3i(6, by + 1, 7), 3)
	# Vano de puerta en el oeste
	_write(vt, Vector3i(6, by, 8), 0)
	_write(vt, Vector3i(6, by + 1, 8), 0)
	# Columna de madera rota en la esquina
	_write(vt, Vector3i(6, by + 1, 4), 7)
	# Piso interior de arena
	for dx in range(3):
		for dz in range(4):
			if int(vt.get_voxel(Vector3i(7 + dx, by, 4 + dz))) == 0:
				_write(vt, Vector3i(7 + dx, by, 4 + dz), 5)
	print("[M25-PREVIEW] Ruina construida sobre superficie real y=", _altura)

func _write(vt: VoxelTool, pos: Vector3i, value: int) -> void:
	vt.value = value
	vt.do_point(pos)

func _encuadrar_y_capturar() -> void:
	var cam := get_node("Camera3D") as Camera3D
	if cam != null:
		cam.position = Vector3(16, _altura + 8, 16)
		cam.look_at(Vector3(8, _altura + 2, 8))
	await get_tree().create_timer(2.0).timeout
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	var ruta := ProjectSettings.globalize_path("res://") + "../../tools/mcp/godot-mcp/capturas/25-Ruinas/cap_25_preview_ruina.png"
	img.save_png(ruta)
	print("[M25-PREVIEW] Captura in-engine: ", ruta)
