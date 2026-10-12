extends SceneTree
## M166 heroes PlacementRule: valida que los 12 heroes mapeados cargan y resuelven mesh.
## Cubre: 10 recetas nuevas + totem (preexistente) + antorcha_mano (ya cubierto por antorcha_ancestral).

const _HEROES: Array[Dictionary] = [
	{"id": "totem", "glb": "45-Arte3D_totem_isla.glb"},
	{"id": "antorcha_ancestral", "glb": "13-Herramientas_antorcha_mano.glb"},
	{"id": "monolito_glifos", "glb": "45-Arte3D_monolito_glifos.glb"},
	{"id": "altar_ritual", "glb": "25-Ruinas-Templos_altar_ritual.glb"},
	{"id": "cofre_ancestral", "glb": "25-Ruinas-Templos_cofre_ancestral.glb"},
	{"id": "concha_mar", "glb": "45-Arte3D_concha_mar.glb"},
	{"id": "bote_pesca", "glb": "40-Infraestructura_bote_pesca.glb"},
	{"id": "muelle_madera", "glb": "40-Infraestructura_muelle_madera.glb"},
	{"id": "palanca_madera", "glb": "70-Interacciones_palanca_madera.glb"},
	{"id": "pico_piedra", "glb": "13-Herramientas_pico_piedra.glb"},
	{"id": "hacha_piedra", "glb": "16-Crafting_hacha_piedra.glb"},
	{"id": "lingote_metal", "glb": "16-Crafting_lingote_metal.glb"},
]

var _fails: int = 0
var _checks: int = 0


func _check(cond: bool, nombre: String, detalle: String = "") -> void:
	_checks += 1
	if not cond:
		_fails += 1
		print("  FAIL: %s %s" % [nombre, detalle])


func _initialize() -> void:
	print("=== M166 heroes PlacementRule ===")
	var dir := "res://data/construccion/piezas/"
	var ok := 0
	for h: Dictionary in _HEROES:
		var rid: String = h["id"]
		var glb: String = h["glb"]
		var ruta := dir + rid + ".tres"
		var res := load(ruta)
		_check(res != null, "carga receta %s" % rid, "-> %s" % ruta)
		if res == null:
			continue
		_check(res.id == rid, "id coincide %s" % rid, "-> got %s" % res.id)
		_check(res.mesh_path.ends_with(glb), "mesh_path %s" % rid, "-> got %s" % res.mesh_path)
		_check(res.mesh_path.begins_with("res://assets/3d/alta/"), "perfil alta %s" % rid, "-> %s" % res.mesh_path)
		_check(res.nombre != "", "nombre no vacio %s" % rid)
		_check(res.familia != &"", "familia set %s" % rid, "-> got %s" % res.familia)
		_check(res.es_mueble, "es_mueble %s" % rid)
		_check(res.altura > 0.0, "altura > 0 %s" % rid, "-> got %f" % res.altura)
		var mesh: PackedScene = load(res.mesh_path)
		_check(mesh != null, "GLB existe %s" % rid, "-> %s" % res.mesh_path)
		if mesh != null:
			ok += 1
	print("heroes con mesh resuelto: %d/%d" % [ok, _HEROES.size()])
	print("=== RESULTADO: %d checks / %d fallos ===" % [_checks, _fails])
	quit(1 if _fails > 0 else 0)
