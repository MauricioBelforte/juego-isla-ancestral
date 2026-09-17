# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-09
#
# ESCENA DE TEST: anillo plano de arena (la "arandela" que pide el usuario).
# Aislada de la isla real para no romper nada. Varias cámaras para verlo
# desde distintos planos: cenital, rasante y tercera persona.
#
# El anillo: disco de arena con AGUJERO en el centro (r 800-1600), a y=4.3
# (encima del agua azul), construido con quads PLANOS (superficie superior
# únicamente — el winding antihorario visto desde arriba).

extends Node3D

const COLOR_ARENA := Color(0.95, 0.93, 0.82)
const COLOR_AGUA := Color(0.35, 0.55, 0.62)
const Y_ANILLO := 4.3

func _ready() -> void:
	_construir_escena()

func _construir_escena() -> void:
	# ── Agua azul (plano grande debajo del anillo — para contrastar) ──
	var agua := MeshInstance3D.new()
	var pm_agua := PlaneMesh.new()
	pm_agua.size = Vector2(6000, 6000)
	agua.mesh = pm_agua
	var mat_agua := StandardMaterial3D.new()
	mat_agua.albedo_color = COLOR_AGUA
	mat_agua.roughness = 0.3
	agua.material_override = mat_agua
	agua.position = Vector3(0, 4.05, 0)
	add_child(agua)

	# ── SOLO el anillo de arena (r 800-1600, a y=4.3) — SIN disco interior ──
	# El usuario pidió ver ÚNICAMENTE la arandela de arena para validarla.
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var r_min := 200.0
	var r_max := 400.0
	var segs := 96
	for i in range(segs):
		var a0 := TAU * float(i) / float(segs)
		var a1 := TAU * float(i + 1) / float(segs)
		var q00 := Vector3(cos(a0) * r_min, Y_ANILLO, sin(a0) * r_min)
		var q01 := Vector3(cos(a1) * r_min, Y_ANILLO, sin(a1) * r_min)
		var q10 := Vector3(cos(a0) * r_max, Y_ANILLO, sin(a0) * r_max)
		var q11 := Vector3(cos(a1) * r_max, Y_ANILLO, sin(a1) * r_max)
		# ORDEN ANTIHORARIO visto desde arriba → normal hacia ARRIBA
		_tri(st, q00, COLOR_ARENA, q11, COLOR_ARENA, q01, COLOR_ARENA)
		_tri(st, q00, COLOR_ARENA, q10, COLOR_ARENA, q11, COLOR_ARENA)
	var anillo := MeshInstance3D.new()
	anillo.mesh = st.commit()
	var mat_anillo := StandardMaterial3D.new()
	mat_anillo.albedo_color = COLOR_ARENA
	mat_anillo.roughness = 1.0
	# Doble cara como seguro (el winding correcto hace que no haga falta)
	mat_anillo.cull_mode = BaseMaterial3D.CULL_DISABLED
	anillo.material_override = mat_anillo
	add_child(anillo)

	# ── Luz direccional ──
	var luz := DirectionalLight3D.new()
	luz.rotation_degrees = Vector3(-45, 30, 0)
	luz.light_color = Color(1, 0.96, 0.88)
	luz.light_energy = 1.2
	add_child(luz)

	# ── Cámaras de test (se alternan con teclas 1/2/3) ──
	# Cam 1: cenital (desde arriba, mirando abajo)
	var cam1 := Camera3D.new()
	cam1.name = "CamCenital"
	cam1.position = Vector3(0, 300, 0)
	cam1.rotation_degrees = Vector3(-90, 0, 0)
	add_child(cam1)
	# Cam 2: rasante (a nivel del anillo, de lejos)
	var cam2 := Camera3D.new()
	cam2.name = "CamRasante"
	cam2.position = Vector3(0, 60, 4000)
	cam2.rotation_degrees = Vector3(-8, 0, 0)
	add_child(cam2)
	# Cam 3: oblicua (vista 45°)
	var cam3 := Camera3D.new()
	cam3.name = "CamOblicua"
	cam3.position = Vector3(1800, 500, 2800)
	cam3.look_at(Vector3.ZERO, Vector3.UP)
	add_child(cam3)
	# Activa la cenital por defecto
	cam1.current = true
	# Capturas internas automatizadas
	for i in range(3):
		get_tree().create_timer(3.0 + 2.0 * float(i)).timeout.connect(_capturar_interna.bind(i))

	# Botón de cámara: alterna entre las 3 con teclas
	set_process_unhandled_key_input(true)

func _capturar_interna(i: int) -> void:
	var img := get_viewport().get_texture().get_image()
	if img != null:
		var dir := "user://capturas_m51"
		DirAccess.make_dir_recursive_absolute(dir)
		img.save_png("%s/cenital_%d.png" % [dir, i])
		print("[TEST] captura cenital %d" % i)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var camaras: Array[Camera3D] = []
		for c in get_children():
			if c is Camera3D:
				camaras.append(c)
		if event.keycode == KEY_1 and camaras.size() > 0:
			camaras[0].current = true
			print("[TEST] Cámara CENITAL (desde arriba)")
		elif event.keycode == KEY_2 and camaras.size() > 1:
			camaras[1].current = true
			print("[TEST] Cámara RASANTE (a nivel del anillo, de lejos)")
		elif event.keycode == KEY_3 and camaras.size() > 2:
			camaras[2].current = true
			print("[TEST] Cámara OBLICUA (45°)")

func _tri(st: SurfaceTool, a: Vector3, ca: Color, b: Vector3, cb: Color, c: Vector3, cc: Color) -> void:
	st.set_color(ca)
	st.add_vertex(a)
	st.set_color(cb)
	st.add_vertex(b)
	st.set_color(cc)
	st.add_vertex(c)
