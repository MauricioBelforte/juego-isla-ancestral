# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M108: Escena de preview visual de una muestra de assets (RF9 review manual).
# Carga 3 GLB de la variante media y los presenta en una vista con luz.
# Uso: escena res://scenes/preview_assets.tscn

extends Node3D

func _ready() -> void:
	var luz := DirectionalLight3D.new()
	luz.rotation_degrees = Vector3(-50, 30, 0)
	luz.light_energy = 1.8
	luz.shadow_enabled = true
	add_child(luz)

	var suelo := MeshInstance3D.new()
	var plano := PlaneMesh.new()
	plano.size = Vector2(30, 30)
	suelo.mesh = plano
	var mat_suelo := StandardMaterial3D.new()
	mat_suelo.albedo_color = Color(0.35, 0.5, 0.3)
	suelo.material_override = mat_suelo
	suelo.rotation_degrees = Vector3(-90, 0, 0)
	add_child(suelo)

	var cam := Camera3D.new()
	cam.position = Vector3(0, 6, 10)
	cam.rotation_degrees = Vector3(-18, 0, 0)
	add_child(cam)

	_cargar("res://assets/3d/media/18-Casas_casa_completa_ejemplo.glb", Vector3(-4, 0, 0))
	_cargar("res://assets/3d/media/45-Arte3D_totem_isla.glb", Vector3(0, 0, 0))
	_cargar("res://assets/3d/media/50-Vegetacion_palmera.glb", Vector3(4, 0, 0))
	print("=== M108: PREVIEW DE ASSETS (RF9) ===")

func _cargar(ruta: String, pos: Vector3) -> void:
	var res: PackedScene = load(ruta)
	if res == null:
		print("[ERROR] no se pudo cargar " + ruta)
		return
	var inst: Node3D = res.instantiate()
	inst.position = pos
	add_child(inst)
	print("[OK] " + ruta)
