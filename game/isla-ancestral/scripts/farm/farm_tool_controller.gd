# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-31
#
# M33 (iter. 2): FarmToolController — hace usable la agricultura en el mundo.
# Raycast propio desde la cámara del jugador hacia el suelo (independiente del
# ToolController de M13, que es autocontenido). Al pulsar:
#   - bloque TIERRA (suelo)        -> till_tile (arar)
#   - tierra arada sin cultivo     -> plantar semilla (si hay en M14)
#   - cultivo                      -> water (regar) o harvest (si está LISTO)
# Herramienta contextual: se usa la acción "interactuar" (como el modelo cozy).
# V0/V1: la validación exacta de bloque voxel (M08) queda con la iter 3.

class_name FarmToolController
extends Node3D

@export var radio_interaccion: float = 4.0

var _camara: Camera3D = null
var _player: Node3D = null
var last_block_hint: String = ""

func _ready() -> void:
	call_deferred("_conectar")

func _conectar() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_player = players[0]
		_camara = _player.get_node_or_null("Camara") if _player.has_node("Camara") else null
		if _camara == null:
			# Cámara común por nombre en main_island
			_camara = _get_camara_del_mundo()

func _get_camara_del_mundo() -> Camera3D:
	for cam in get_tree().root.find_children("*", "Camera3D", true, false):
		if cam is Camera3D and cam.current:
			return cam
	return null

## Punto del suelo apuntado por la cámara (raycast simple, ignorando el jugador).
func _punto_mirado() -> Vector3i:
	if _camara == null:
		return Vector3i.ZERO
	var origen: Vector3 = _camara.global_position
	var dir: Vector3 = -_camara.global_transform.basis.z
	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(origen, origen + dir * radio_interaccion)
	query.exclude = [_player] if _player != null else []
	var hit := space.intersect_ray(query)
	if hit.is_empty() or not hit.has("position"):
		return Vector3i.ZERO
	var pos: Vector3 = hit["position"]
	return Vector3i(int(floor(pos.x)), int(floor(pos.y)), int(floor(pos.z)))

## Acción principal: arar / plantar / regar / cosechar según el estado.
func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interactuar"):
		return
	var farm = get_node_or_null("/root/Farm")
	if farm == null:
		return
	var voxel := _punto_mirado()
	if voxel == Vector3i.ZERO:
		return
	var tile: CropTile = farm.get_tile(voxel)
	if tile == null:
		# Sin cultivo: arar (till valida en el servicio; TODO voxel M08 en iter 3)
		farm.till_tile(voxel)
		return
	if tile.is_ready():
		farm.harvest(voxel)
		return
	# Con cultivo: regar (la cosecha requiere LISTA; el riego es siempre válido)
	farm.water(voxel)

func _semilla_disponible(def: CropDefinition) -> String:
	var inv = get_node_or_null("/root/Inventario")
	if inv == null:
		return ""
	var semilla := str(def.crop_id)
	if int(inv.count_item(semilla, true)) > 0:
		return semilla
	return ""

func _acl() -> void:
	pass  # placeholder: VFX/audio en iter con M52/M43

func plantar_demo(def: CropDefinition, voxel: Vector3i) -> bool:
	var farm = get_node_or_null("/root/Farm")
	if farm == null:
		return false
	var inv = get_node_or_null("/root/Inventario")
	if inv:
		inv.agregar_items({str(def.crop_id): 5})
	return farm.plant(def, voxel) if farm.puede_plantar_en(voxel) else false