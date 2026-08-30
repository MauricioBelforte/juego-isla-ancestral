# Modelo: Hy3
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M167/M168: TerrainLocator — servicio CENTRAL de posicionamiento sobre el terreno.
# Estrategia anti-flotamiento: TODOS los objetos (NPCs, ruinas, spawn, estructuras)
# usan ESTE autoload para obtener la altura del suelo y posicionarse, usando el
# generador REAL del VoxelTerrain (nunca clones con radio hardcodeado — esa era la
# causa de que los NPCs flotaran).

extends Node

## VoxelTerrain activo (buscado con reintento)
var _terrain: VoxelTerrain = null

func _ready() -> void:
	# Búsqueda inicial (el terrain puede no estar listo al arranque)
	_buscar_terreno()

func _process(_delta: float) -> void:
	# Reintento: si el terrain aún no existe, buscar de nuevo
	if _terrain == null or not is_instance_valid(_terrain):
		_buscar_terreno()

func _buscar_terreno() -> void:
	var root = get_tree().current_scene
	if root:
		_terrain = root.get_node_or_null("VoxelTerrain") as VoxelTerrain
		if _terrain:
			return
	# Fallback: buscar en el árbol completo
	_terrain = _find_in_tree(get_tree().root)

func _find_in_tree(node: Node) -> VoxelTerrain:
	for child in node.get_children():
		if child is VoxelTerrain:
			return child as VoxelTerrain
		var r = _find_in_tree(child)
		if r:
			return r
	return null

## Devuelve la altura del suelo en (x, z) usando el generador REAL del mundo.
## Retorna -1 si no hay terreno/generador disponible.
func get_height(x: int, z: int) -> int:
	if _terrain == null or _terrain.generator == null:
		return -1
	var gen = _terrain.generator
	if gen != null and gen.has_method("_get_island_gen"):
		var h := int(gen._get_island_gen().get_height(x, z))
		return h
	return -1

## Posiciona un nodo SOBRE la superficie del terreno (1 bloque arriba).
## El nodo queda a (x, altura+1, z). Si no hay terreno, no mueve el nodo.
func posicionar_sobre_terreno(nodo: Node3D, x: float, z: float) -> bool:
	var h := get_height(int(x), int(z))
	if h < 0:
		return false
	nodo.global_position = Vector3(x, float(h) + 1.0, z)
	return true

## Verifica que el nodo esté sobre el terreno (para debug/test).
func esta_sobre_superficie(nodo: Node3D) -> bool:
	if _terrain == null:
		return false
	var px := int(nodo.global_position.x)
	var pz := int(nodo.global_position.z)
	var h := get_height(px, pz)
	if h < 0:
		return false
	var suelo := float(h) + 1.0
	return absf(nodo.global_position.y - suelo) < 2.0
