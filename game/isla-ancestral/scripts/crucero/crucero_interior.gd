class_name CruceroInterior
extends Node3D

var _gl: Node = null

## Mapea el nombre de categoria (String) al enum Category de GameLogger (int).
const _CAT := {"BOOT": 0, "SYSTEM": 1, "GAMEPLAY": 2, "WORLD": 3, "NETWORKING": 4, "ANALYTICS": 5, "CRASH": 6}

func _cat(cat: String) -> int:
	return int(_CAT.get(cat, 1))

func _log_debug(msg: String, cat: String = "", ctx: Dictionary = {}):
	if _gl: _gl.debug(msg, _cat(cat), ctx)

func _log_info(msg: String, cat: String = "", ctx: Dictionary = {}):
	if _gl: _gl.info(msg, _cat(cat), ctx)

func _log_warning(msg: String, cat: String = "", ctx: Dictionary = {}):
	if _gl: _gl.warning(msg, _cat(cat), ctx)

func _log_error(msg: String, cat: String = "", ctx: Dictionary = {}):
	if _gl: _gl.error(msg, _cat(cat), ctx)

func _log_critical(msg: String, cat: String = "", ctx: Dictionary = {}):
	if _gl: _gl.critical(msg, _cat(cat), ctx)

## Una cubierta del Crucero Real (M169).
##
## Regla del modulo: **una cubierta = una escena**. Este script solo controla
## esa escena (luces, puertas, aparicion del jugador); la geometria es de la .tscn.
##
## El streaming lo maneja M63 (CargasManager): este nodo no carga ni descarga nada,
# solo reacciona a que ya está cargado.

signal puerta_cruzada(cubierta_destino: int)

@export var cubierta: int = 1
@export var luces: Array[OmniLight3D] = []
@export var puerta_cubierta: Area3D = null
@export var punto_spawn: Marker3D = null
@export var ambientacion: AudioStreamPlayer = null

var _activa: bool = false


func _ready() -> void:
	_gl = get_node_or_null("/root/GameLogger")
	if luces.is_empty():
		for hijo: Node in find_children("*", "OmniLight3D", true, false):
			luces.append(hijo as OmniLight3D)
	if puerta_cubierta != null and not puerta_cubierta.body_entered.is_connected(_on_body_entered):
		puerta_cubierta.body_entered.connect(_on_body_entered)
	_apagar_luces()


## Configura la cubierta desde el manager o el tooling (sin tocar la .tscn).
func configurar(n_cubierta: int, p_luces: Array = [], p_puerta: Area3D = null, p_spawn: Marker3D = null) -> void:
	cubierta = n_cubierta
	if not p_luces.is_empty():
		luces = p_luces
	if p_puerta != null:
		puerta_cubierta = p_puerta
		if not puerta_cubierta.body_entered.is_connected(_on_body_entered):
			puerta_cubierta.body_entered.connect(_on_body_entered)
	if p_spawn != null:
		punto_spawn = p_spawn


## Cubierta destino al cruzar la puerta (4 -> 1, cerrando el ciclo).
func destino_siguiente() -> int:
	return 1 if cubierta >= 4 else cubierta + 1


## El jugador cruzó la puerta de la cubierta.
func _on_body_entered(body: Node3D) -> void:
	if not _activa:
		return
	if not body.is_in_group("player"):
		return
	var destino := destino_siguiente()
	puerta_cruzada.emit(destino)
	_log_info("[CRU] puerta cruzada en cubierta %d -> %d" % [cubierta, destino], "GAMEPLAY")


func activar() -> void:
	_activa = true
	_encender_luces()
	if ambientacion != null and not ambientacion.playing:
		ambientacion.play()


func desactivar() -> void:
	_activa = false
	_apagar_luces()
	if ambientacion != null and ambientacion.playing:
		ambientacion.stop()


func _encender_luces() -> void:
	for l: OmniLight3D in luces:
		l.visible = true


func _apagar_luces() -> void:
	for l: OmniLight3D in luces:
		l.visible = false


## Posicion de aparicion del jugador dentro de esta cubierta.
func punto_de_spawn() -> Vector3:
	if punto_spawn != null:
		return punto_spawn.global_position
	return global_position + Vector3(0, 0, 1.2)


## Resumen para el log / debug.
func descripcion() -> String:
	return "Cubierta %d · %d luces · %s" % [cubierta, luces.size(), "activa" if _activa else "en reposo"]