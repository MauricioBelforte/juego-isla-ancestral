# Modelo: ox-alpha
# Plataforma: Cline
# Fecha: 2026-08-25
#
# M13: Herramientas — Preview visual (validación V2/V4)
# Escena generada por código para VERIFICAR CON CAPTURA el feedback visual:
# - Recurso apuntado por la herramienta aplicable → highlight emissive ("late" 60%)
# - Recursos no aplicables → sin highlight
# - Rotación lenta de cámara para inspección

extends Node3D

## Controller bajo prueba
var controller: ToolController = null

func _ready() -> void:
	_construir_escena()

func _construir_escena() -> void:
	# Luz direccional
	var luz := DirectionalLight3D.new()
	luz.rotation_degrees = Vector3(-45, 30, 0)
	add_child(luz)

	# Suelo
	var suelo := MeshInstance3D.new()
	var plano := PlaneMesh.new()
	plano.size = Vector2(12, 12)
	suelo.mesh = plano
	var mat_suelo := StandardMaterial3D.new()
	mat_suelo.albedo_color = Color(0.35, 0.55, 0.3)
	suelo.material_override = mat_suelo
	suelo.position.y = -0.5
	add_child(suelo)

	# Recursos mock con acciones válidas:
	# Piedra (EXTRACT) — el PICO aplica
	var piedra := _crear_recurso(BoxMesh.new(), Color(0.5, 0.5, 0.55), Vector3(-2, 0.5, 0), [ToolData.Accion.EXTRACT])
	add_child(piedra)
	# Árbol (EXTRACT/SHEAR) — el HACHA aplica
	var arbol := _crear_recurso(CylinderMesh.new(), Color(0.45, 0.3, 0.15), Vector3(0, 1.0, 0), [ToolData.Accion.EXTRACT, ToolData.Accion.SHEAR])
	arbol.scale = Vector3(0.6, 2.0, 0.6)
	add_child(arbol)
	# Parcela (TILL/WATER) — ni pico ni hacha aplican (control negativo)
	var parcela := _crear_recurso(BoxMesh.new(), Color(0.4, 0.25, 0.1), Vector3(2, 0.25, 0), [ToolData.Accion.TILL, ToolData.Accion.WATER])
	parcela.scale = Vector3(1.0, 0.5, 1.0)
	add_child(parcela)

	# Cámara encuadrando los 3 recursos (piedra izq, árbol centro, parcela der)
	var cam := Camera3D.new()
	cam.position = Vector3(0, 2.0, 5.0)
	add_child(cam)
	cam.look_at(Vector3(0, 0.8, 0))
	cam.current = true

	# ToolController cerca (~2,3 m) para que el raycast de 4 m llegue a la piedra
	controller = ToolController.new()
	controller.position = Vector3(-1.2, 1.6, 2.2)
	add_child(controller)
	controller.look_at(Vector3(-2, 0.5, 0))

	# Equipar PICO de Cobre (T1) — debe iluminar la piedra, NO el árbol/parcela
	controller.equipar(ToolData.crear(ToolData.Tipo.PICO, ToolData.Nivel.COBRE))

	# Pico visible en primer plano (hijo de la cámara): mango madera + cabeza cobre
	var pico := Node3D.new()
	cam.add_child(pico)
	pico.position = Vector3(0.55, -0.35, -1.0)
	pico.rotation_degrees = Vector3(-20, 8, 35)
	# Mango
	var mango := MeshInstance3D.new()
	mango.mesh = CylinderMesh.new()
	mango.mesh.top_radius = 0.035
	mango.mesh.bottom_radius = 0.045
	mango.mesh.height = 1.1
	_matarial(mango, Color(0.42, 0.28, 0.14))
	pico.add_child(mango)
	# Cabeza de pico (cobre): caja atravesada con puntas afiladas (dos prismas)
	var cabeza := MeshInstance3D.new()
	cabeza.mesh = BoxMesh.new()
	cabeza.mesh.size = Vector3(0.65, 0.09, 0.09)
	_matarial(cabeza, Color(0.72, 0.45, 0.2))
	cabeza.position.y = 0.5
	cabeza.rotation_degrees = Vector3(0, 0, 90)
	pico.add_child(cabeza)

func _matarial(mi: MeshInstance3D, color: Color) -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.7
	mi.material_override = mat

func _crear_recurso(mesh: Mesh, color: Color, pos: Vector3, acciones: Array) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mi.material_override = mat
	mi.set_script(preload("res://scripts/tools/recurso_mock.gd"))
	mi.setup(acciones)
	return mi
