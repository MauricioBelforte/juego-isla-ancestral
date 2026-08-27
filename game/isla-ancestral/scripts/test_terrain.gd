extends Node3D

## Escena de prueba — escribe voxels directamente con VoxelTool

func _ready() -> void:
	# Crear terreno
	var terrain := VoxelTerrain.new()
	add_child(terrain)
	
	# Crear mesher con 2 modelos
	var mesher := VoxelMesherBlocky.new()
	var library := VoxelBlockyLibrary.new()
	
	# Modelo 0: Aire
	var air := VoxelBlockyModelEmpty.new()
	air.set_name("air")
	library.add_model(air)
	
	# Modelo 1: Bloque verde (césped)
	var cube := VoxelBlockyModelCube.new()
	cube.set_name("grass")
	library.add_model(cube)
	
	# Modelo 2: Bloque marrón (tierra)
	var dirt := VoxelBlockyModelCube.new()
	dirt.set_name("dirt")
	library.add_model(dirt)
	
	library.bake()
	mesher.library = library
	terrain.mesher = mesher
	
	# Material con vertex color
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	terrain.material_override = mat
	
	# NO usar generator — escribir voxels directamente
	
	# Esperar un frame para que el terreno inicialice
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Escribir voxels directamente
	var vt := terrain.get_voxel_tool()
	if vt:
		vt.channel = VoxelBuffer.CHANNEL_TYPE
		print("VoxelTool obtenido, escribiendo voxels...")
		
		# Crear una plataforma de 20x20 bloques
		for x in range(-10, 10):
			for z in range(-10, 10):
				# Superficie: césped (tipo 1)
				vt.value = 1
				# do_point() devuelve void (corregido 2026-08-25, ox-alpha):
				# no se puede asignar su retorno ni compararlo con -1.
				vt.do_point(Vector3i(x, 0, z))
				
				# Debajo: tierra (tipo 2)
				vt.value = 2
				vt.do_point(Vector3i(x, -1, z))
				vt.do_point(Vector3i(x, -2, z))
		
		print("Voxels escritos: 20x20x3 = 1200 bloques")
	else:
		print("ERROR: No se pudo obtener VoxelTool")
	
	# Cámara
	var cam := Camera3D.new()
	cam.position = Vector3(0, 15, 15)
	cam.rotation_degrees = Vector3(-50, 0, 0)
	add_child(cam)
	
	# VoxelViewer
	var viewer := VoxelViewer.new()
	viewer.view_distance = 256.0
	cam.add_child(viewer)
	
	# Luz
	var light := DirectionalLight3D.new()
	light.position = Vector3(0, 50, 0)
	light.rotation_degrees = Vector3(-45, 0, 0)
	light.light_energy = 1.5
	light.shadow_enabled = true
	add_child(light)
	
	print("=== TEST TERRAIN (VoxelTool directo) ===")
	print("Plataforma: 20x20 bloques")
	print("Altura: 3 bloques (césped + 2 tierra)")
	print("Camera pos: (0, 15, 15)")
	print("=========================================")
