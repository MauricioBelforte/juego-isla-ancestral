# Modelo: MiMo V2.5
# Plataforma: OpenCode
# Fecha: 2026-08-27
#
# M13: Herramientas — ToolController (integrado con VoxelTerrain)
# Raycast via VoxelTool.do_ray() + extracción/colocación de bloques reales.
# Contrato try_extract/try_place (M08) conectado al mundo voxel.

## Controlador de herramienta equipada: raycast voxel, extracción y colocación.
class_name ToolController
extends Node3D

## Herramienta actualmente equipada
var herramienta: ToolData = null

## Alcance del rayo (RF7: 4 m)
const ALCANCE: float = 4.0

## Referencia al terreno voxel
var _terrain: VoxelTerrain = null

## Resultado del último raycast voxel
var _last_hit: Dictionary = {}

## Señales para feedback
signal bloque_extraido(pos: Vector3i, block_id: int, drops: Array)
signal bloque_colocado(pos: Vector3i, block_id: int)
signal herramienta_agotada(tool_name: String)

func _ready() -> void:
	_terrain = _find_terrain()

func _find_terrain() -> VoxelTerrain:
	var root := get_tree().current_scene
	if root == null:
		return null
	for child in root.get_children():
		if child is VoxelTerrain:
			return child as VoxelTerrain
	return null

## Equipa una herramienta y actualiza el feedback.
func equipar(tool_data: ToolData) -> void:
	herramienta = tool_data
	print("[M13] Equipada: %s (dur %d/%d)" % [tool_data.nombre, tool_data.durabilidad_actual, tool_data.durabilidad_max])

## Lanza un rayo voxel desde la cámara. Devuelve diccionario con hit info o vacío.
## Clave de la skill godot-raycasting-queries: usar VoxelTool.do_ray() en _physics_process,
## NO PhysicsRayQueryParameters3D que no detecta voxels.
func _raycast_voxel() -> Dictionary:
	if _terrain == null:
		_terrain = _find_terrain()
	if _terrain == null:
		return {}

	var vt := _terrain.get_voxel_tool()
	if vt == null:
		return {}

	# Origen: posición del controller (cámara/jugador)
	var origin := global_position
	# Dirección: -Z local (hacia adelante desde la cámara)
	var direction := -global_transform.basis.z.normalized()

	# VoxelTool.do_ray(origin, direction, max_distance) → Dictionary con:
	# "position": Vector3i (coordenadas voxel del bloque golpeado)
	# "normal": Vector3i (cara golpeada)
	# "value": int (ID del bloque)
	# "distance": float
	var result = vt.do_ray(origin, direction, ALCANCE)

	if result == null or result.is_empty():
		_last_hit = {}
		return {}

	_last_hit = {
		"position": result.get("position", Vector3i.ZERO),
		"normal": result.get("normal", Vector3i.ZERO),
		"value": result.get("value", 0),
		"distance": result.get("distance", 0.0),
	}
	return _last_hit

## Devuelve la posición del bloque apuntado (o Vector3i(-999,-999,-999) si nada).
func get_target_block() -> Vector3i:
	if _last_hit.is_empty():
		return Vector3i(-999, -999, -999)
	return _last_hit.get("position", Vector3i(-999, -999, -999))

## Devuelve la normal de la cara golpeada.
func get_target_normal() -> Vector3i:
	if _last_hit.is_empty():
		return Vector3i.ZERO
	return _last_hit.get("normal", Vector3i.ZERO)

## Devuelve el ID del bloque apuntado.
func get_target_block_id() -> int:
	if _last_hit.is_empty():
		return -1
	return _last_hit.get("value", -1)

## CONTRATO M08: intenta extraer el bloque apuntado.
## Devuelve { ok: bool, block_id: int, pos: Vector3i } o {} si no hay target.
func try_extract() -> Dictionary:
	if herramienta == null or herramienta.inutilizada():
		return {}
	if not herramienta.permite(ToolData.Accion.EXTRACT):
		return {}

	_raycast_voxel()
	if _last_hit.is_empty():
		return {}

	var pos: Vector3i = _last_hit.get("position", Vector3i.ZERO)
	var block_id: int = _last_hit.get("value", 0)

	# No extraer aire
	if block_id == 0:
		return {}

	# No extraer roca madre (bedrock, ID 4)
	if block_id == 4:
		print("[M13] Roca madre — no extraíble")
		return {}

	# Extraer: setting voxel a AIR (0)
	var vt := _terrain.get_voxel_tool()
	if vt == null:
		return {}

	vt.value = 0  # AIR
	vt.do_point(pos)

	herramienta.gastar_uso()

	var drops := _get_drops(block_id)
	bloque_extraido.emit(pos, block_id, drops)

	print("[M13] Extraído bloque %d en %s → drops: %s" % [block_id, pos, drops])
	return {"ok": true, "block_id": block_id, "pos": pos, "drops": drops}

## CONTRATO M08/M17: intenta colocar un bloque en la cara adyacente al apuntado.
## Devuelve true si colocó exitosamente.
func try_place(block_id: int, _metadata: Dictionary = {}) -> bool:
	if herramienta == null or herramienta.inutilizada():
		return false
	if not herramienta.permite(ToolData.Accion.BUILD):
		return false

	_raycast_voxel()
	if _last_hit.is_empty():
		return false

	var pos: Vector3i = _last_hit.get("position", Vector3i.ZERO)
	var normal: Vector3i = _last_hit.get("normal", Vector3i.ZERO)

	# Posición adyacente = posición golpeada + normal de la cara
	var place_pos: Vector3i = pos + normal

	# Verificar que la posición destino esté vacía (AIR)
	var vt := _terrain.get_voxel_tool()
	if vt == null:
		return false

	var current_value = int(_terrain.get_voxel(place_pos, VoxelBuffer.CHANNEL_TYPE))
	if current_value != 0:
		print("[M13] Posición %s ocupada (bloque %d)" % [place_pos, current_value])
		return false

	# Colocar bloque
	vt.value = block_id
	vt.do_point(place_pos)

	herramienta.gastar_uso()
	bloque_colocado.emit(place_pos, block_id)

	print("[M13] Colocado bloque %d en %s" % [block_id, place_pos])
	return true

## Obtiene los drops de un bloque (simplificado: drop = el mismo bloque como string id).
## M15/M35 refinarán con ItemData real.
func _get_drops(block_id: int) -> Array:
	var item_id := _block_to_item_id(block_id)
	return [{"item_id": item_id, "amount": 1}]

## Mapea block_id (int) a item_id (string) para Inventario.
## Temporal: luego M15 definirá el catálogo definitivo.
static func _block_to_item_id(block_id: int) -> String:
	match block_id:
		1: return "dirt"
		2: return "grass"
		3: return "stone"
		5: return "sand"
		6: return "clay"
		7: return "wood"
		8: return "planks"
		9: return "copper_ore"
		10: return "iron_ore"
		11: return "crystal"
		12: return "gemstone"
		13: return "glass"
		14: return "ancient_crystal"
		16: return "ice"
		26: return "snow"
		27: return "gravel"
		28: return "moss"
		29: return "mud"
		_: return "unknown_%d" % block_id

## Devuelve info del último raycast para debug/HUD.
func get_debug_info() -> String:
	if _last_hit.is_empty():
		return "[M13] Sin target"
	var pos: Vector3i = _last_hit.get("position", Vector3i.ZERO)
	var bid: int = _last_hit.get("value", 0)
	var dist: float = _last_hit.get("distance", 0.0)
	return "[M13] Target: bloque %d en %s (%.1fm)" % [bid, pos, dist]
