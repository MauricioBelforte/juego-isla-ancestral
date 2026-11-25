class_name CruceroPuerto
extends Area3D
## Puerto de embarque del Crucero Real (M169).
##
## Area3D que detecta al jugador al entrar/salir del punto de atraque y dispara el
## ciclo de embarque/desembarco en CruceroManager (M169). NO reimplementa el viaje:
## solo es el gatillo fisico. La logica de estado vive en CruceroManager.

signal jugador_embarco(cubierta: int)
signal jugador_desembarco(destino: String)

const PREFIJO_LOG := "[CRU-PUERTO]"

## Destino al desembarcar ("" = el que decida el manager).
@export var destino: String = ""
## Punto de aparicion al embarcar (opcional; si no, usa el del manager).
@export var punto_embarque: Marker3D = null

var _gl: Node = null

## Mapea el nombre de categoria (String) al enum Category de GameLogger (int).
const _CAT := {"BOOT": 0, "SYSTEM": 1, "GAMEPLAY": 2, "WORLD": 3, "NETWORKING": 4, "ANALYTICS": 5, "CRASH": 6}

func _cat(cat: String) -> int:
	return int(_CAT.get(cat, 1))

func _log_info(msg: String, cat: String = "", ctx: Dictionary = {}):
	if _gl: _gl.info(msg, _cat(cat), ctx)

func _log_warning(msg: String, cat: String = "", ctx: Dictionary = {}):
	if _gl: _gl.warning(msg, _cat(cat), ctx)


func _ready() -> void:
	_gl = get_node_or_null("/root/GameLogger")
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)


func _manager() -> Node:
	return get_node_or_null("/root/CruceroManager")


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	var cm := _manager()
	if cm == null or not cm.has_method("embarcar"):
		_log_warning("%s CruceroManager no disponible; embarque ignorado" % PREFIJO_LOG, "GAMEPLAY")
		return
	if bool(cm.embarcar()):
		jugador_embarco.emit(int(cm.cubierta_actual))
		_log_info("%s jugador embarco en cubierta %d" % [PREFIJO_LOG, int(cm.cubierta_actual)], "GAMEPLAY")


func _on_body_exited(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	var cm := _manager()
	if cm == null or not cm.has_method("desembarcar"):
		return
	var dst := destino
	if dst == "":
		dst = String(cm.route_id)
	cm.desembarcar(dst)
	jugador_desembarco.emit(dst)
	_log_info("%s jugador desembarco en %s" % [PREFIJO_LOG, dst], "GAMEPLAY")


## Punto de aparicion al embarcar (Vector3 global).
func punto_de_embarque() -> Vector3:
	if punto_embarque != null:
		return punto_embarque.global_position
	return global_position