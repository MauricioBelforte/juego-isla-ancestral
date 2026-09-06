# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-06
#
# M47 iter. 1: test de materiales/formas por tipo de recurso.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/arte3d/test_materiales_m47.gd

extends SceneTree

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FALLO] %s" % nombre)

func _run() -> void:
	print("=== [M47] Test materiales de recursos ===")
	var m47 := root.get_node_or_null("MaterialesRecursos")
	_check("MaterialesRecursos autoload presente", m47 != null)
	if m47 == null:
		quit(1)
		return
	# Colores distintivos por tipo
	var cobre: Color = m47.color_para("mineral_cobre")
	var hierro: Color = m47.color_para("veta_hierro")
	var oro: Color = m47.color_para("mineral_oro")
	_check("cobre=naranja (R>G>B)", cobre.r > cobre.g and cobre.g > cobre.b)
	_check("hierro=gris (canales cercanos)", absf(hierro.r - hierro.b) < 0.15)
	_check("oro=amarillo (R~1, G alta, B bajo)", oro.r > 0.9 and oro.g > 0.7 and oro.b < 0.4)
	_check("cobre ≠ hierro ≠ oro", not cobre.is_equal_approx(hierro) and not cobre.is_equal_approx(oro))
	# Formas por tipo
	_check("veta_cobre -> roca_mineral", String(m47.forma_para("veta_cobre")) == "roca_mineral")
	_check("madera_roble -> tronco", String(m47.forma_para("madera_roble")) == "tronco")
	_check("fibra_algodon -> mata", String(m47.forma_para("fibra_algodon")) == "mata")
	_check("baya_roja -> esfera_baya", String(m47.forma_para("baya_roja")) == "esfera_baya")
	_check("fragmento_ancestral -> cristal", String(m47.forma_para("fragmento_ancestral")) == "cristal")
	_check("tipo desconocido -> roca default", String(m47.forma_para("recurso_inexistente")) == "roca")
	# Visuales se construyen con meshes y material correcto
	var vis: Node3D = m47.crear_visual("veta_oro")
	_check("visual veta_oro construido", vis != null and vis.get_child_count() >= 4)
	var mi := vis.get_child(0) as MeshInstance3D
	_check("mesh 0 de veta_oro es PrismMesh", mi != null and mi.mesh is PrismMesh)
	var mat := mi.material_override as StandardMaterial3D
	_check("material de veta_oro dorado", mat != null and mat.albedo_color.r > 0.9)
	# Emisión para el fragmento ancestral
	var vis_frag: Node3D = m47.crear_visual("fragmento_ancestral")
	var mi_frag := vis_frag.get_child(0) as MeshInstance3D
	var mat_frag := mi_frag.material_override as StandardMaterial3D
	_check("fragmento_ancestral emisivo", mat_frag != null and mat_frag.emission_enabled)
	# Visuales de todos los tipos del catálogo M15 construyen sin error
	var ids: Array[StringName] = [&"madera_roble", &"piedra_caliza", &"fibra_algodon", &"baya_roja",
		&"mineral_cobre", &"veta_cobre", &"veta_hierro", &"veta_oro", &"fragmento_ancestral",
		&"grass", &"clay", &"mud", &"sand"]
	var todos_ok := true
	for id in ids:
		var v: Node3D = m47.crear_visual(id)
		if v == null or v.get_child_count() == 0:
			todos_ok = false
	_check("13 visuales del catálogo construyen", todos_ok)
	# Integración con ResourceNode: patrón del spawner real (add_child → configurar)
	var rd := ResourceDefinition.new()
	rd.def_id = &"veta_oro"
	rd.display_name = "Veta de Oro"
	rd.categoria = ResourceDefinition.Categoria.MINERAL
	var rn := ResourceNode.new()
	root.add_child(rn)
	rn.configurar(rd)
	var hijo := rn.get_node_or_null("VisualM47_veta_oro") as Node3D
	_check("ResourceNode instancia VisualM47 (orden add_child->configurar)", hijo != null)
	print("=== Resumen M47: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)
