# Modelo: agnes-3-flash
# Plataforma: Kilo Code
# Fecha: 2026-10-09
# M110-UI: DebugVisualizer — capa visual de debug (colliders, chunks, navegación, hitboxes, estados IA).
# Consume las señales del backend debug_menu.gd. No modifica el backend; solo dibuja.
# Headless-compatible: crea MeshInstance3D hijos, no usa _draw() (es 2D).
extends Node3D
class_name DebugVisualizer

signal estado_visual_cambiado(tipo: String, activo: bool)

const MAX_CHUNKS_RADIO := 5.0
const MAX_NAVIGATION_RADIO := 50.0
const MAX_AI_STATES_RADIO := 50.0

var _debug_menu: Node = null
var _jugador: Node3D = null
var _instancias: Dictionary = {}  # tipo -> MeshInstance3D
var _activo: Dictionary = {
	"colliders": false,
	"chunks": false,
	"navigation": false,
	"hitboxes": false,
	"ai_states": false,
}

func _ready() -> void:
	_debug_menu = get_node_or_null("/root/DebugMenu")
	if _debug_menu != null:
		if _debug_menu.has_signal("toggle_visual_cambiado"):
			_debug_menu.connect("toggle_visual_cambiado", _on_toggle_visual.bind())
	# Buscar jugador
	var grupo := get_tree().get_nodes_in_group("player")
	_jugador = grupo[0] if grupo.size() > 0 else null
	# Crear instancias
	_inicializar_instancias()

func _inicializar_instancias() -> void:
	for tipo in _activo:
		var mi := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(1, 1, 1)
		mi.mesh = mesh
		mi.visible = false
		mi.set_name("debug_vis_" + tipo)
		add_child(mi)
		_instancias[tipo] = mi

func _on_toggle_visual(tipo: String, activo: bool) -> void:
	if tipo in _activo:
		_activo[tipo] = activo
		var mi: MeshInstance3D = _instancias.get(tipo)
		if mi != null:
			mi.visible = activo
		estado_visual_cambiado.emit(tipo, activo)

func _process(_delta: float) -> void:
	if _jugador == null:
		return
	for tipo in _instancias:
		var mi: MeshInstance3D = _instancias[tipo]
		if mi.visible:
			_posicionar(mi, tipo)

func _posicionar(mi: MeshInstance3D, tipo: String) -> void:
	var pos := Vector3.ZERO
	if _jugador != null:
		pos = _jugador.global_position
	match tipo:
		"colliders":
			mi.position = pos + Vector3(0, 0.5, 0)
			_mi_size(mi, Vector3(1.0, 1.5, 1.0))
		"chunks":
			mi.position = pos + Vector3(0, -0.5, 0)
			_mi_size(mi, Vector3(MAX_CHUNKS_RADIO * 8.0, 1.0, MAX_CHUNKS_RADIO * 8.0))
		"navigation":
			mi.position = pos
			_mi_size(mi, Vector3(MAX_NAVIGATION_RADIO * 2.0, 0.1, MAX_NAVIGATION_RADIO * 2.0))
		"hitboxes":
			mi.position = pos + Vector3(0, 0.5, 0)
			_mi_size(mi, Vector3(0.5, 1.0, 0.25))
		"ai_states":
			mi.position = pos
			_mi_size(mi, Vector3(MAX_AI_STATES_RADIO * 2.0, 0.1, MAX_AI_STATES_RADIO * 2.0))

static func _mi_size(mi: MeshInstance3D, tam: Vector3) -> void:
	if mi.mesh is BoxMesh:
		(mi.mesh as BoxMesh).size = tam

## Configura el visualizador manualmente (para tests).
func configurar_manual(tipo: String, activo: bool) -> void:
	if tipo in _activo:
		_activo[tipo] = activo
		var mi: MeshInstance3D = _instancias.get(tipo)
		if mi != null:
			mi.visible = activo
		estado_visual_cambiado.emit(tipo, activo)

## Devuelve el estado de todos los toggles (para tests).
func obtener_estado() -> Dictionary:
	return _activo.duplicate()

## Devuelve si una instancia existe y está visible.
func instancia_visible(tipo: String) -> bool:
	var mi: MeshInstance3D = _instancias.get(tipo)
	return mi != null and mi.visible

## Nodos de instancia (para tests).
func obtener_instancia(tipo: String) -> MeshInstance3D:
	return _instancias.get(tipo)
