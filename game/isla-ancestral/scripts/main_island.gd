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
	_crear_ui_root()
	_poblar_recursos()
	_crear_estaciones_crafting()
	_crear_farm_controller()
	_crear_shaman()
	print("Isla Ancestral — Isla Raíz")

## M33 (iter. 2): controller agrícola (arar/regar/cosechar con interactuar)
func _crear_farm_controller() -> void:
	var script := load("res://scripts/farm/farm_tool_controller.gd")
	if script:
		var ctrl = script.new()
		ctrl.name = "FarmToolController"
		add_child(ctrl)
		print("[M33] FarmToolController montado")

## M53: instala el framework de capas (DialogLayer, PauseLayer, MenusLayer, ConfirmPopup)
func _crear_ui_root() -> void:
	var root_script := load("res://scripts/ui/ui_root.gd")
	if root_script:
		var ui_root = root_script.new()
		ui_root.name = "UIRoot"
		add_child(ui_root)

## M16: coloca la estación de crafting inicial (mesa de trabajo) cerca del spawn.
func _crear_estaciones_crafting() -> void:
	var station_script := load("res://scripts/crafting/crafting_station.gd")
	if station_script == null:
		return
	var mesa = station_script.new()
	mesa.name = "MesaTrabajo"
	mesa.tipo = 0  # CraftingStation.Tipo.MESA_TRABAJO
	add_child(mesa)
	# M09 iter.: centro real de la isla (mundo 5120², antes esquina 320,320)
	var mundo = get_node_or_null("/root/MundoRaiz")
	var sx: float = mundo.SPAWN_CONTENIDO.x + 6.0 if mundo else 326.0
	var sz: float = mundo.SPAWN_CONTENIDO.z + 2.0 if mundo else 322.0
	# Posicionar sobre el terreno real (anti-flotamiento, M167)
	var locator = get_node_or_null("/root/TerrainLocator")
	if locator and locator.has_method("posicionar_sobre_terreno"):
		locator.posicionar_sobre_terreno.call_deferred(mesa, sx, sz)
	else:
		mesa.global_position = Vector3(sx, 20, sz)
	print("[M16] Mesa de trabajo colocada en (%.0f, ~, %.0f)" % [sx, sz])

## M15: población inicial de recursos alrededor del centro de la isla (deferred).
func _poblar_recursos() -> void:
	var rm = get_node_or_null("/root/ResourceManager")
	if rm and rm.has_method("poblar_isla"):
		# M09 iter.: centro real (mundo 5120²) — antes esquina (320,320)
		var mundo = get_node_or_null("/root/MundoRaiz")
		var centro: Vector3 = mundo.SPAWN_CONTENIDO if mundo != null else Vector3(320, 0, 320)
		rm.poblar_isla.call_deferred(centro)
		print("[M15] Recursos alrededor de (%.0f, %.0f)" % [centro.x, centro.z])

func _crear_ruina() -> void:
	var ruina := RuinaChozavil.new()
	ruina.name = "RuinaChozavil"
	add_child(ruina)

## M21/M53: la presentación del diálogo la provee DialogLayer (UIRoot).
## La DialogueUI autocontenida se mantiene solo como fallback si UIRoot falla.
func _crear_ui_dialogo() -> void:
	var root_script := load("res://scripts/ui/ui_root.gd")
	if root_script:
		return  # UIRoot monta DialogLayer (capa formal M53)
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
	_add_block(library, "water", Color(0.10, 0.45, 0.75))  # azul oceano mas claro
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
	
	# Generador de isla con biomas (M09/M10) — PERFIL ORIGINAL (M167 config
	# fija: max_height 40, sin boost — restaurado Log 791 tras el rechazo
	# del terreno escalado)
	var generator = load("res://scripts/world/world_generator.gd").new()
	generator.world_seed = 42
	generator.island_radius = 2560
	generator.max_height = 40
	generator.max_height_boost = 1.0
	terrain.generator = generator
	
	# M09 iter. (Log 759, idea del usuario "terreno sólido"): los chunks
	# reales (detallados, minables) SOLO cerca (1600m). El resto de la isla
	# se ve con el impostor sólido lowpoly (terreno_horizonte.gd) — malla de
	# alturas del mismo generador, siempre visible, 1 draw call.
	var voxel_viewer_node = get_node_or_null("VoxelViewer")
	if voxel_viewer_node:
		voxel_viewer_node.view_distance = 1024.0
		# Diferido: evita ERROR "!is_inside_tree()" de get_global_transform si el
		# viewer no está listo en este punto del _ready (BUG-024). La posición
		# real la pone _enganchar_voxel_viewer (sigue al Player).
		voxel_viewer_node.set_deferred("global_position", Vector3(2560, 30, 2560))
		# LOD del terreno: 5 niveles — anillos con cubos 2×/4×/8×/16×/32×
		var terrain_node = get_node_or_null("VoxelTerrain")
		if terrain_node:
			if terrain_node.get("lod_split_count") != null:
				terrain_node.lod_split_count = 5
			if terrain_node.get("lod_distance") != null:
				terrain_node.lod_distance = 160.0
		var mesher_node = terrain_node
		if mesher_node and mesher_node.mesher != null:
			# full_load_distance NO existe en VoxelMesherBlocky (rompía el boot
			# con Debugger Break — quitado 2026-09-03, deepseek-v4-flash-vision-exp);
			# el LOD del terreno lo controla VoxelTerrain.lod_distance/lod_split_count.
			pass
	
	_crear_oceano()
	_crear_base_verde_isla()

	# Spawn del jugador: sobre la superficie de la isla (cae y aterriza en la cresta,
	# nunca en el agua del océano que está a nivel de mar)
	var player = get_node_or_null("Player")
	if player:
		player.set_deferred("global_position", Vector3(256, 16, 256))
	_ajustar_spawn_superficie.call_deferred()
	
	print("[M09] Isla Aurora — terreno con biomas (semilla: 42)")

## Superficie de océano lisa (2026-09-03, deepseek-v4-flash-vision-exp):
## el mar lejano se veía como fondo marrón (lecho/rocas sin superficie aguada
## apreciable). Un plano azul a y=2.8 cubre el océano con superficie lisa
## (la banda costera turquesa —agua en y=3— se mantiene visible por encima).
func _crear_oceano() -> void:
	var oceano := MeshInstance3D.new()
	oceano.name = "Oceano"
	var plano := PlaneMesh.new()
	# 4096: el borde del plano queda muy fuera del view (512) — nunca se ve el
	# final del océano (el 2048 dejaba un borde marrón visible).
	plano.size = Vector2(4096, 4096)
	oceano.mesh = plano
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.08, 0.35, 0.62)
	mat.roughness = 0.5
	oceano.material_override = mat
	oceano.position = Vector3(256, 1.2, 256)
	# PlaneMesh en Godot 4 ya es horizontal (normal +Y): NO rotar (la rotación
	# -90 lo dejaba VERTICAL / pared azul — fix 2026-09-03).
	add_child(oceano)
	# Niebla marina: el borde del océano se funde con el cielo (adiós línea
	# marrón del horizonte) — color azul-mar, densidad baja.
	var env_node := get_node_or_null("WorldEnvironment")
	if env_node and env_node.environment:
		env_node.environment.fog_enabled = true
		env_node.environment.fog_light_color = Color(0.75, 0.85, 0.95)
		env_node.environment.fog_density = 0.00018
		env_node.environment.fog_sky_affect = 0.25
		env_node.environment.fog_aerial_perspective = 0.4

## Disco de arena blanca de la isla (idea del usuario, 2026-09-03): un
## cilindro-disco de radio 266 (costa 240 + margen 2) en y=2.95 con color de
## arena blanca — por arriba del océano (2.8) y por debajo de la playa (3-4).
## Refuerza la isla en la distancia (el agua no "entra" visualmente por los
## valles bajos) y se funde con la playa real.
func _crear_base_verde_isla() -> void:
	var disco := MeshInstance3D.new()
	disco.name = "BaseArenaBlancaIsla"
	var cilindro := CylinderMesh.new()
	cilindro.top_radius = 242.0
	cilindro.bottom_radius = 242.0
	cilindro.height = 0.02
	disco.mesh = cilindro
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.96, 0.94, 0.88)   # arena blanca (paleta Maldivas)
	mat.roughness = 1.0
	mat.metallic = 0.0
	disco.material_override = mat
	disco.position = Vector3(256, 2.95, 256)
	add_child(disco)

func _add_block(library: VoxelBlockyLibrary, block_name: String, color: Color) -> void:
	var cube := VoxelBlockyModelCube.new()
	cube.set_name(block_name)
	cube.set_color(color)
	library.add_model(cube)

func _setup_player_visual() -> void:
	var player = get_node_or_null("Player")
	if not player:
		return
	# M45 iter. 1: el jugador voxel tiene colores propios (piel/camisa/pantalón)
	# — el override azul legacy solo aplica si aún usa la cápsula BodyMesh.
	if player.get_node_or_null("ModeloVoxel"):
		print("[M08] Jugador voxel M45 en uso — override azul omitido")
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
	# M09 iter. (fix caída doble): este ajuste corre UNA sola vez — los
	# reintentos de locator solo reprograman el chequeo, nunca re-teleportan
	# al jugador (la doble caída era el ajuste aplicándose 2 veces).
	if _spawn_ajustado:
		return
	# Altura calculado directo del generador (sin teleport de 4s):
	# el jugador nace ya sobre la superficie real de la columna del spawn
	# Estrategia anti-flotamiento: usar el TerrainLocator (un solo punto de verdad).
	var locator = get_node_or_null("/root/TerrainLocator")
	# M09 iter.: spawn en el centro real de la isla (mundo 5120², interior
	# con bosque/montañas) — antes (256,256) era la esquina playa.
	var mundo = get_node_or_null("/root/MundoRaiz")
	var spawn_x: float = mundo.SPAWN_JUGADOR.x if mundo else 256.0
	var spawn_z: float = mundo.SPAWN_JUGADOR.z if mundo else 256.0
	if locator:
		var altura_spawn: int = locator.get_height(spawn_x, spawn_z)
		var player = get_node_or_null("Player")
		if player:
			if altura_spawn >= 0 and not _spawn_ajustado:
				_spawn_ajustado = true  # guard: UNA sola vez (fix caída doble)
				player.global_position = Vector3(spawn_x, altura_spawn + 3, spawn_z)
				print("[M09] Spawn sobre superficie calculada Y=", altura_spawn + 3, " en (%.0f, %.0f)" % [spawn_x, spawn_z])
				# M09 iter. (mundo 10×): el VoxelViewer sigue al jugador para
				# que el streaming genere chunks alrededor del spawn (el
				# viewer fijo en (0,5,0) no generaba nada a r=3860 y el
				# jugador caía al vacío).
				_enganchar_voxel_viewer(player)
				# M09 iter. (fix "caída bajo el agua" Log 786): congelar la
				# física HASTA que el voxel de la superficie exista de verdad
				# (verificación con VoxelTool cada 0.5s). El timer fijo de 8s
				# liberaba antes de tiempo → caída al vacío eterna.
				player.set_physics_process(false)
				_verificar_chunk_y_liberar(player, spawn_x, altura_spawn, spawn_z, 0)
			elif not _spawn_ajustado:
				# M167: el locator aún no tiene el terreno en el arranque
				# (h = -1). NO enterrar al jugador: conservar posición y
				# reintentar hasta que el generador esté disponible.
				player.set_physics_process(false)
				_reintentar_spawn()
			else:
				print("[M09] Spawn: locator sin terreno tras reintentos, en (%.0f, 16, %.0f)" % [spawn_x, spawn_z])

## M09 iter.: el VoxelViewer determina DÓNDE el streamer genera chunks.
## Reparentado al Player → el terreno se genera alrededor del jugador.
func _enganchar_voxel_viewer(player: Node) -> void:
	var viewer := get_node_or_null("VoxelViewer") as VoxelViewer
	if viewer == null or player == null:
		return
	viewer.position = Vector3.ZERO
	player.add_child(viewer)
	print("[M09] VoxelViewer enganchado al Player — streaming alrededor del spawn")

func _liberar_fisica_player(player: Node) -> void:
	if player != null and is_instance_valid(player):
		player.set_physics_process(true)
		print("[M09] Física del jugador liberada tras streaming del spawn")

## M09 iter. (fix caída bajo el agua, Log 786): verifica con VoxelTool que el
## voxel de la superficie del spawn YA esté materializado antes de liberar la
## física. Polling cada 0.5s (no bloqueante). Timeout 120 chequeos (60s).
## NOTA: get_voxel NO bloquea si se consulta tras el streaming del frame —
## el tile del chunk puede tardar, pero la consulta devuelve 0 sin colgar.
func _verificar_chunk_y_liberar(player: Node, sx: float, altura: int, sz: float, intento: int) -> void:
	if player == null or not is_instance_valid(player):
		return
	var terrain := get_node_or_null("VoxelTerrain") as VoxelTerrain
	if terrain != null:
		var vt := terrain.get_voxel_tool()
		if vt != null:
			var bloque := vt.get_voxel(Vector3i(int(sx), altura, int(sz)))
			if bloque != 0:
				player.set_physics_process(true)
				print("[M09] Chunk del spawn materializado (bloque ", bloque, " en Y=", altura, ") — física liberada tras ", intento * 0.5, "s")
				return
	# Aún no materializado (o terrain sin voxel tool): reintentar
	intento += 1
	if intento > 120:
		# 60s: liberar igual (evitar softlock) — el jugador caerá y podrá
		# al menos moverse/nadar; el streaming seguirá cargando.
		push_warning("[M09] Chunk del spawn no materializó tras 60s — liberando física igualmente")
		player.set_physics_process(true)
		return
	var timer := get_tree().create_timer(0.5)
	timer.timeout.connect(_verificar_chunk_y_liberar.bind(player, sx, altura, sz, intento))

var _spawn_ajustado: bool = false
var _spawn_intentos: int = 0

func _reintentar_spawn() -> void:
	_spawn_intentos += 1
	if _spawn_intentos > 6:
		_spawn_ajustado = true
		return
	var timer := get_tree().create_timer(0.5)
	timer.timeout.connect(_ajustar_spawn_superficie)

## M163: spawn del Chaman del Monte en la Isla Raiz (montaña remota).
func _crear_shaman() -> void:
	var shaman_script = load("res://scripts/enchantment/shaman_npc.gd")
	if not shaman_script:
		push_warning("[M163] ShamanNPC script no encontrado")
		return
	var shaman = shaman_script.new()
	shaman.name = "ShamanMonte"
	add_child(shaman)
	# M09 iter.: el chamán vive en las montañas del interior real
	var mundo = get_node_or_null("/root/MundoRaiz")
	var sh_x: float = mundo.CENTRO.x - 240.0 if mundo else 320.0
	var sh_z: float = mundo.CENTRO.y - 260.0 if mundo else 300.0
	var locator = get_node_or_null("/root/TerrainLocator")
	if locator and locator.has_method("get_height"):
		var h: int = locator.get_height(sh_x, sh_z)
		if h >= 0:
			shaman.global_position = Vector3(sh_x, h + 1, sh_z)
		else:
			shaman.global_position = Vector3(sh_x, 35, sh_z)
	else:
		shaman.global_position = Vector3(320, 35, 300)
	print("[M163] Chaman del Monte spawneado en ", shaman.global_position)
