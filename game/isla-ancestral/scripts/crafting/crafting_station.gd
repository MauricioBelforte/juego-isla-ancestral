# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M16: Crafting — CraftingStation (Node3D interactuable, RF1).
# Estación de crafting física en el mundo: mesa de trabajo, fogata, telar.
# Mesh placeholder por tipo + Area3D de interacción. La apertura de UI la
# gestiona el sistema de interacción (M11) + CraftingService.

class_name CraftingStation
extends Node3D

enum Tipo { MESA_TRABAJO, FOGATA, TELAR }

@export var tipo: int = Tipo.MESA_TRABAJO
@export var nombre_mostrado: String = "Mesa de trabajo"

var _mesh: MeshInstance3D
var _area: Area3D

func _ready() -> void:
	_crear_presentacion()

## Construye la presentación placeholder según el tipo de estación.
func _crear_presentacion() -> void:
	_mesh = MeshInstance3D.new()
	match tipo:
		Tipo.MESA_TRABAJO:
			var box := BoxMesh.new()
			box.size = Vector3(1.6, 0.9, 1.0)
			_mesh.mesh = box
			_mesh.material_override = _material(Color(0.55, 0.38, 0.20))
		Tipo.FOGATA:
			var cyl := CylinderMesh.new()
			cyl.top_radius = 0.5
			cyl.bottom_radius = 0.6
			cyl.height = 0.4
			_mesh.mesh = cyl
			_mesh.material_override = _material(Color(0.45, 0.3, 0.15))
		Tipo.TELAR:
			var box := BoxMesh.new()
			box.size = Vector3(1.2, 1.4, 0.4)
			_mesh.mesh = box
			_mesh.material_override = _material(Color(0.65, 0.5, 0.35))
	add_child(_mesh)

	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(2.0, 1.8, 1.6)
	col.shape = shape
	_area = Area3D.new()
	_area.add_child(col)
	add_child(_area)

func _material(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	return mat

## Nombre legible del tipo (para prompts/UI).
func nombre_estacion() -> String:
	match tipo:
		Tipo.MESA_TRABAJO: return "mesa_trabajo"
		Tipo.FOGATA: return "fogata"
		Tipo.TELAR: return "telar"
	return "mesa_trabajo"
