extends Control
## M53 HUD — StatusBar: vida, hambre, sed del jugador.

signal estado_cambiado

var vida := 100
var hambre := 100
var sed := 100

func _ready() -> void:
	_set_proportion()

func set_estado(v: int, h: int, s: int) -> void:
	vida = v
	hambre = h
	sed = s
	estado_cambiado.emit()

func _set_proportion() -> void:
	pass
