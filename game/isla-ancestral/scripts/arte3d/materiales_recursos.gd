# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-06
#
# M47 iter. 1: materiales/formas distintivas por TIPO de recurso (M15/M35).
# Data-driven: data/arte3d/materiales_recursos.json (match por substring).
# Los nodos M15 (resource_node.gd) consultan visual_para(def_id) y obtienen
# un Node3D lowpoly listo para instanciar, en vez de la caja naranja genérica.

extends Node

const RUTA_TABLA := "res://data/arte3d/materiales_recursos.json"

var _tipos: Array = []
var _default: Dictionary = {}
var _cache_materiales: Dictionary = {}


func _ready() -> void:
	_cargar_tabla()


func _cargar_tabla() -> void:
	if not FileAccess.file_exists(RUTA_TABLA):
		push_warning("[M47] tabla de materiales no encontrada: %s" % RUTA_TABLA)
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_TABLA))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("[M47] tabla de materiales inválida")
		return
	_tipos = parsed.get("tipos", [])
	_default = parsed.get("default", {})
	print("[M47] Tabla de materiales cargada: %d tipos" % _tipos.size())


## Entrada de tabla que matchea un def_id (o default).
func entrada_para(def_id: StringName) -> Dictionary:
	var id := String(def_id)
	for t in _tipos:
		if id.contains(String(t.get("match", ""))):
			return t
	return _default


## Color albedo para un def_id.
func color_para(def_id: StringName) -> Color:
	var c: Array = entrada_para(def_id).get("color", [0.8, 0.8, 0.8])
	return Color(float(c[0]), float(c[1]), float(c[2]))


## Forma lowpoly para un def_id: "roca_mineral", "tronco", "mata",
## "esfera_baya", "cristal", "roca".
func forma_para(def_id: StringName) -> String:
	return String(entrada_para(def_id).get("forma", "roca"))


## Material cacheado por entrada (albedo + emisión opcional).
func material_para(def_id: StringName) -> StandardMaterial3D:
	var clave := String(def_id)
	if _cache_materiales.has(clave):
		return _cache_materiales[clave]
	var entrada := entrada_para(def_id)
	var mat := StandardMaterial3D.new()
	var c: Array = entrada.get("color", [0.8, 0.8, 0.8])
	mat.albedo_color = Color(float(c[0]), float(c[1]), float(c[2]))
	mat.roughness = 0.85
	var em: Array = entrada.get("emision", [])
	if em.size() == 3:
		mat.emission_enabled = true
		mat.emission = Color(float(em[0]), float(em[1]), float(em[2]))
		mat.emission_energy_multiplier = 1.2
	_cache_materiales[clave] = mat
	return mat


## Construye el Node3D visual lowpoly para un recurso. La base del visual
## queda en y=0 (asentado). El caller lo posiciona.
func crear_visual(def_id: StringName) -> Node3D:
	var raiz := Node3D.new()
	raiz.name = "VisualM47_" + String(def_id)
	var forma := forma_para(def_id)
	var mat := material_para(def_id)
	match forma:
		"roca_mineral":
			_roca_mineral(raiz, mat)
		"tronco":
			_tronco(raiz, mat)
		"mata":
			_mata(raiz, mat)
		"esfera_baya":
			_esfera_baya(raiz, mat)
		"cristal":
			_cristal(raiz, mat)
		_:
			_roca(raiz, mat)
	return raiz


func _agregar_mesh(padre: Node3D, mesh: Mesh, mat: StandardMaterial3D, pos: Vector3, rot_y_grados: float = 0.0) -> void:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	mi.rotation_degrees.y = rot_y_grados
	padre.add_child(mi)


## Prisma facetado con 2-3 cristales del mineral incrustados arriba.
func _roca_mineral(raiz: Node3D, mat: StandardMaterial3D) -> void:
	var cuerpo := PrismMesh.new()
	cuerpo.size = Vector3(1.0, 0.8, 0.9)
	_agregar_mesh(raiz, cuerpo, mat, Vector3(0, 0.4, 0))
	# pepitas: esferas pequeñas del mismo material, arriba
	for i in range(3):
		var pepita := SphereMesh.new()
		pepita.radius = 0.12
		pepita.height = 0.24
		_agregar_mesh(raiz, pepita, mat, Vector3(-0.25 + 0.25 * i, 0.75 + (0.06 if i == 1 else 0.0), 0.15 - 0.2 * i))


## Tronco hexagonal con 2-3 anillos de madera.
func _tronco(raiz: Node3D, mat: StandardMaterial3D) -> void:
	var cil := CylinderMesh.new()
	cil.top_radius = 0.32
	cil.bottom_radius = 0.4
	cil.height = 1.6
	cil.radial_segments = 6
	cil.rings = 2
	_agregar_mesh(raiz, cil, mat, Vector3(0, 0.8, 0))


## 3 cajas bajas cruzadas (matorral bajo).
func _mata(raiz: Node3D, mat: StandardMaterial3D) -> void:
	for i in range(3):
		var caja := BoxMesh.new()
		caja.size = Vector3(0.55, 0.3, 0.22)
		_agregar_mesh(raiz, caja, mat, Vector3(0, 0.15, 0), 60.0 * float(i))


## Esfera de baya + tallito.
func _esfera_baya(raiz: Node3D, mat: StandardMaterial3D) -> void:
	var esfera := SphereMesh.new()
	esfera.radius = 0.3
	esfera.height = 0.6
	_agregar_mesh(raiz, esfera, mat, Vector3(0, 0.3, 0))
	var m_tallo := StandardMaterial3D.new()
	m_tallo.albedo_color = Color(0.35, 0.5, 0.25)
	var tallo := CylinderMesh.new()
	tallo.top_radius = 0.03
	tallo.bottom_radius = 0.04
	tallo.height = 0.25
	tallo.radial_segments = 5
	_agregar_mesh(raiz, tallo, m_tallo, Vector3(0.05, 0.68, 0))


## Prisma alto facetado (cristal) con emisión opcional; ligera inclinación.
func _cristal(raiz: Node3D, mat: StandardMaterial3D) -> void:
	var prisma := PrismMesh.new()
	prisma.size = Vector3(0.55, 1.5, 0.55)
	var mi := MeshInstance3D.new()
	mi.mesh = prisma
	mi.material_override = mat
	mi.position = Vector3(0, 0.75, 0)
	mi.rotation_degrees = Vector3(0, 0, -6)
	raiz.add_child(mi)
	var chico := PrismMesh.new()
	chico.size = Vector3(0.3, 0.9, 0.3)
	var mi2 := MeshInstance3D.new()
	mi2.mesh = chico
	mi2.material_override = mat
	mi2.position = Vector3(0.3, 0.45, -0.1)
	mi2.rotation_degrees = Vector3(0, 30, 8)
	raiz.add_child(mi2)


## Roca gris facetada (2 prismas superpuestos).
func _roca(raiz: Node3D, mat: StandardMaterial3D) -> void:
	var grande := PrismMesh.new()
	grande.size = Vector3(0.9, 0.7, 0.8)
	_agregar_mesh(raiz, grande, mat, Vector3(0, 0.35, 0))
	var chico := PrismMesh.new()
	chico.size = Vector3(0.5, 0.4, 0.45)
	_agregar_mesh(raiz, chico, mat, Vector3(0.2, 0.8, 0.1), 25.0)
