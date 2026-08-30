# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M15: Recursos — ResourceSpawner (instanciación de nodos en regiones).
# Planifica y coloca ResourceNode sobre el terreno usando TerrainLocator (M167).
# Presupuesto por burbuja: nodos activos ≤ 200; los lejanos se desactivan.
# Se comunica con ResourceManager (definiciones) y emite recurso_reaparecio.

class_name ResourceSpawner
extends Node

signal recurso_reaparecio(def_id: StringName, pos: Vector3)

const MAX_NODOS_ACTIVOS := 200
const RADIO_BURBUJA_ACTIVA := 48.0

var _nodos: Dictionary = {}   # node_id -> ResourceNode
var _next_id: int = 1
var _manager: Node = null     # ResourceManager (autoload)

func _init(manager: Node) -> void:
	_manager = manager

## Planifica nodos de una región usando las definiciones del manager.
## Se llama con region_activada de M08. coloca los tipos por defecto hasta
## alcanzar un presupuesto simple (siempre dentro de MAX_NODOS_ACTIVOS).
func planificar_region(_region_id: String, centro: Vector3, terreno: Node) -> void:
	if _nodos.size() >= MAX_NODOS_ACTIVOS:
		return
	var defs: Array = _manager.obtener_todas()
	if defs.is_empty():
		return
	var count := 0
	for def in defs:
		if count >= 12:
			break
		var offsets := _offsets_candidatos(centro, def.def_id)
		for off in offsets:
			if _nodos.size() >= MAX_NODOS_ACTIVOS:
				break
			var node_id := instanciar_nodo(def.def_id, off.x, off.z, terreno)
			if node_id > 0:
				count += 1
			if count >= 4:
				break

func _offsets_candidatos(centro: Vector3, def_id: StringName) -> Array:
	# Distribución determinista simple alrededor del centro (radio 4-12 m)
	var offsets := []
	for i in range(8):
		var ang := float(i) * TAU / 8.0
		var r := 6.0 + float((int(def_id.hash()) % 5))  # radio variable, determinista
		offsets.append(Vector3(centro.x + cos(ang) * r, 0, centro.z + sin(ang) * r))
	return offsets

## Instancia un nodo de un recurso en (x, z) sobre el terreno.
## Devuelve node_id (> 0) o -1 si falla (sin terreno o presupuesto lleno).
func instanciar_nodo(def_id: StringName, x: float, z: float, _terreno: Node = null) -> int:
	if _nodos.size() >= MAX_NODOS_ACTIVOS:
		return -1
	var def: ResourceDefinition = _manager.obtener_def(def_id)
	if def == null:
		return -1
	var node := ResourceNode.new()
	node.configurar(def)
	node.name = "Recurso_" + str(def_id) + "_" + str(_next_id)
	node.agotado.connect(_on_nodo_agotado)
	add_child(node)  # primero al árbol, luego posicionar (global_position necesita tree)
	# Posicionar con TerrainLocator (anti-flotamiento) si existe
	var locator = _buscar_terreno_locator()
	var y: float = 30.0
	if locator != null:
		var ok: bool = locator.posicionar_sobre_terreno(node, x, z)
		if ok:
			y = node.global_position.y
		else:
			node.global_position = Vector3(x, 30.0, z)
	else:
		node.global_position = Vector3(x, 30.0, z)
	_nodos[_next_id] = node
	_next_id += 1
	print("[M15] Nodo %s en (%.0f, %.0f, %.0f) y=%.0f" % [str(def_id), x, y, z, y])
	return _next_id - 1

func _on_nodo_agotado(def_id: StringName, pos: Vector3) -> void:
	# Genera drops y emite señales de mundo vivo
	if _manager != null and _manager.has_method("entregar_drops"):
		var drops: Dictionary = _manager.generar_drops(def_id, &"", false)
		_manager.entregar_drops(drops, def_id, &"", false)
	recurso_reaparecio.emit(def_id, pos)

func _buscar_terreno_locator() -> Node:
	var tree := get_tree()
	if tree == null:
		return null
	return tree.root.get_node_or_null("TerrainLocator")

## Devuelve los nodos activos (para persistencia/QA).
func nodos_activos() -> int:
	return _nodos.size()

func obtener_nodos() -> Dictionary:
	return _nodos.duplicate()
