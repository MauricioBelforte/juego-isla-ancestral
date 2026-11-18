class_name CruceroInterior
extends Node3D

_func _GL():
	var gl = get_node_or_null("/root/GameLogger")
	if gl != null:
		return gl
	return _FallbackLog.new()

class _FallbackLog:
	func debug(msg, cat="", ctx={}): pass
	func info(msg, cat="", ctx={}): pass
	func warning(msg, cat="", ctx={}): pass
	func error(msg, cat="", ctx={}): pass
	func critical(msg, cat="", ctx={}): pass
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
	if luces.is_empty():
		for hijo: Node in find_children("*", "OmniLight3D", true, false):
			luces.append(hijo as OmniLight3D)
	if puerta_cubierta != null and not puerta_cubierta.body_entered.is_connected(_on_body_entered):
		puerta_cubierta.body_entered.connect(_on_body_entered)
	_apagar_luces()


## El jugador cruzó la puerta de la cubierta.
func _on_body_entered(body: Node3D) -> void:
	if not _activa:
		return
	if not body.is_in_group("player"):
		return
	var destino := cubierta + 1
	if cubierta >= 4:
		destino = 1
	puerta_cruzada.emit(destino)
	_GL().info("[CRU] puerta cruzada en cubierta %d -> %d" % [cubierta, destino], _GL().Category.GAMEPLAY)


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