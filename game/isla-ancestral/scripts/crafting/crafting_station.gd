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

const RADIO_INTERACCION := 2.5

@export var tipo: int = Tipo.MESA_TRABAJO
@export var nombre_mostrado: String = "Mesa de trabajo"

var _mesh: MeshInstance3D
var _area: Area3D
var _jugador: Node3D = null
## M16 item 7: tope de reintentos de búsqueda del player (evita churn infinito
## de call_deferred cuando la estación vive poco o el player no aparece).
var _reintentos_jugador: int = 0

func _ready() -> void:
	_crear_presentacion()
	_buscar_jugador()

func _buscar_jugador() -> void:
	var tree := get_tree()
	if tree == null:
		return
	var players := tree.get_nodes_in_group("player")
	if players.size() > 0:
		_jugador = players[0]
	else:
		# Reintentar al próximo frame (el player se agrega después en algunos flujos)
		_buscar_jugador_deferred()

func _buscar_jugador_deferred() -> void:
	# Endurecido (item 7): corta si salió del árbol o agotó los reintentos —
	# el churn de call_deferred cada frame era trabajo extra por estación.
	if not is_inside_tree() or _reintentos_jugador >= 5:
		return
	_reintentos_jugador += 1
	call_deferred("_buscar_jugador")

## Interacción (RF1): el jugador cerca + acción interactuar abre el panel.
func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interactuar"):
		return
	if _jugador == null:
		return
	var dist: float = global_position.distance_to(_jugador.global_position)
	if dist > RADIO_INTERACCION:
		return
	# No abrir si ya está abierto (idempotente)
	var ui_root = _buscar_crafting_ui()
	if ui_root != null and ui_root.visible:
		return
	if ui_root != null and ui_root.has_method("abrir"):
		ui_root.abrir(tipo)
		get_viewport().set_input_as_handled()

func _buscar_crafting_ui() -> Node:
	var tree := get_tree()
	if tree == null:
		return null
	return _buscar_nodo(tree.root, "CraftingUI")

func _buscar_nodo(node: Node, nombre: String) -> Node:
	for child in node.get_children():
		if child.name == nombre:
			return child
		var resultado := _buscar_nodo(child, nombre)
		if resultado:
			return resultado
	return null

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
	# M16 item 7: sin steps de física extra en estaciones (efecto interactuable
	# básico). El Area es declarativo — M11 no lo consulta (grep en disco: 0
	# referencias) y la interacción es por distancia en _unhandled_input. Con
	# monitoring/monitorable en false y capa 0, el broadphase de física lo excluye
	# del pipeline: cero trabajo por physics step por estación instanciada.
	_area.monitoring = false
	_area.monitorable = false
	_area.collision_layer = 0
	_area.collision_mask = 0

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
