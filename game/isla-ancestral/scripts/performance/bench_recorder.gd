# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M61: Rendimiento — bench_recorder.gd (bench_scene_a) — iter 2 (V2, benchmark visual).
# Bench oficial del terreno voxel M08 (isla 42/256/40, paleta Maldivas):
#   1) recorre 6 waypoints por 15 s cada uno (90 s total) mirando al centro,
#   2) muestra overlay FPS + draw calls (evidencia visual/capturas),
#   3) muestrea cada 30 frames: fps, draw_calls, objects, process_ms,
#   4) al final escribe user://logs/bench/bench_AAAAMMDD.json + resumen con veredicto.
# Uso: godot_run_project scene bench_scene_a.tscn (o --path del proyecto).
# Metodología: etiquetas del Profiler via BudgetProfile (render/gameplay).

extends Node3D

const WAYPOINTS := [
	Vector3(256, 60, 90),    # vista norte: montana central
	Vector3(420, 40, 120),   # vista nordeste: playa + mar
	Vector3(470, 30, 256),   # vista este: costa turquesa
	Vector3(256, 55, 430),   # vista sur: playa delta
	Vector3(100, 45, 256),   # vista oeste: bosque
	Vector3(256, 100, 256),  # vista cenital de la isla
]
const DURACION_WAYPOINT_S := 15.0
const INTERVALO_MUESTREO := 30

var _bp
var _terrain: VoxelTerrain
var _cam: Camera3D
var _label: Label
var _t_desde_inicio := 0.0
var _idx_waypoint := 0
var _muestras: Array = []
var _frames_since_sample := 0
var _terminado := false

func _ready() -> void:
	_bp = preload("res://scripts/performance/budget_profile.gd").new()
	_bp.set_activo(true)
	add_child(_bp)
	_bp.reset_profile_run()

	_setup_terreno()
	_setup_overlay()
	print("=== M61 BENCH SCENE A — INICIO (90 s, 6 waypoints) ===")

func _setup_overlay() -> void:
	_label = Label.new()
	_label.position = Vector2(16, 12)
	_label.add_theme_font_size_override("font_size", 22)
	_label.add_theme_color_override("font_color", Color(1, 1, 0))
	_label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	_label.add_theme_constant_override("outline_size", 6)
	add_child(_label)
	_label.set_anchors_preset(Control.PRESET_TOP_LEFT)

func _add_block(library: VoxelBlockyLibrary, block_name: String, color: Color) -> void:
	var cube := VoxelBlockyModelCube.new()
	cube.set_name(block_name)
	cube.set_color(color)
	library.add_model(cube)

func _setup_terreno() -> void:
	_terrain = VoxelTerrain.new()
	_terrain.name = "VoxelTerrain"
	add_child(_terrain)

	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	_terrain.material_override = mat
	var mesher := VoxelMesherBlocky.new()
	var library := VoxelBlockyLibrary.new()
	var air := VoxelBlockyModelEmpty.new()
	air.set_name("air")
	library.add_model(air)
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
	_add_block(library, "shallow_water", Color(0.25, 0.82, 0.78))
	library.bake()
	mesher.library = library
	_terrain.mesher = mesher

	var generator = load("res://scripts/world/world_generator.gd").new()
	generator.world_seed = 42
	generator.island_radius = 256
	generator.max_height = 40
	_terrain.generator = generator

	var viewer := VoxelViewer.new()
	viewer.view_distance = 256.0
	add_child(viewer)
	viewer.global_position = Vector3(256, 30, 256)

	var cam := Camera3D.new()
	cam.position = WAYPOINTS[0]
	cam.rotation_degrees = Vector3(-25, 0, 0)
	add_child(cam)
	_cam = cam

	var luz := DirectionalLight3D.new()
	luz.rotation_degrees = Vector3(-45, 30, 0)
	luz.light_energy = 1.7
	luz.shadow_enabled = true
	add_child(luz)

func _process(delta: float) -> void:
	if _terminado:
		return
	_t_desde_inicio += delta
	var objetivo: Vector3 = WAYPOINTS[_idx_waypoint]
	_cam.global_position = _cam.global_position.lerp(objetivo, delta / DURACION_WAYPOINT_S * 4.0)
	_cam.look_at(Vector3(256, 12, 256), Vector3.UP)

	if _t_desde_inicio > DURACION_WAYPOINT_S * float(_idx_waypoint + 1):
		_idx_waypoint = min(_idx_waypoint + 1, WAYPOINTS.size() - 1)
	if _t_desde_inicio > DURACION_WAYPOINT_S * float(WAYPOINTS.size()):
		_terminado = true
		_finalizar()
		return

	_muestrear_cada_frame()

func _muestrear_cada_frame() -> void:
	_frames_since_sample += 1
	if _frames_since_sample % INTERVALO_MUESTREO != 0:
		return
	_frames_since_sample = 0
	var fps := Engine.get_frames_per_second()
	var draw := Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	var objs := Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)
	var proc := Performance.get_monitor(Performance.TIME_PROCESS)
	_muestras.append({"fps": fps, "draw_calls": draw, "objects": objs, "process_ms": proc})
	_label.text = "M61 BENCH — FPS: %d  |  Draw calls: %d  |  Objetos: %d  |  Waypoint %d/6" % [fps, draw, objs, _idx_waypoint + 1]

func _finalizar() -> void:
	var n := _muestras.size()
	var med := {}
	for clave in ["fps", "draw_calls", "objects", "process_ms"]:
		var v := 0.0
		for m in _muestras:
			v += float(m[clave])
		med[clave] = v / float(maxi(n, 1))
	var max_draw := 0
	for m in _muestras:
		max_draw = maxi(max_draw, int(m["draw_calls"]))
	med["draw_calls_max"] = max_draw
	med["muestras"] = n
	med["waypoints"] = WAYPOINTS.size()
	med["fecha"] = Time.get_date_string_from_system()
	med["hardware"] = _hardware_str()

	# Secciones del profiler con BudgetProfile
	_bp.begin_section("render")
	await RenderingServer.frame_post_draw
	_bp.end_section("render")
	med["profiler_render_ms"] = _bp.get_section_ms("render")

	# JSON en user://logs/bench/
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://logs/bench"))
	var ruta := "user://logs/bench/bench_%s.json" % Time.get_date_string_from_system()
	var f := FileAccess.open(ruta, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(med, "  "))
		f.close()

	var veredicto := "OK (>=60 FPS)" if float(med["fps"]) >= 60.0 else "WARN (<60 FPS)"
	print("=== M61 BENCH RESULTADO ===")
	print("fps_promedio=%.1f  draw_calls_promedio=%.1f  draw_calls_max=%d  objects_prom=%.1f  process_ms=%.1f" % [med["fps"], med["draw_calls"], max_draw, med["objects"], med["process_ms"]])
	print("profiler_render_ms=%.2f  veredicto=%s  json=%s" % [med["profiler_render_ms"], veredicto, ProjectSettings.globalize_path(ruta)])
	print("hardware=%s" % med["hardware"])
	_label.text += "\nVEREDICTO: %s (fps prom %.1f)" % [veredicto, med["fps"]]

func _hardware_str() -> String:
	var gl := RenderingServer.get_video_adapter_name()
	var gpu_info := RenderingServer.get_video_adapter_vendor()
	return gpu_info + " / " + gl
