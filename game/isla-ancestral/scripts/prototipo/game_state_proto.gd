extends Node

var seed_actual: int = 20260819
var escena_actual: String = ''

func _ready() -> void:
	pass

func guardar_estado() -> Dictionary:
	return {"seed": seed_actual, "escena": escena_actual}

func cargar_estado(data: Dictionary) -> void:
	seed_actual = data.get("seed", 20260819)
	escena_actual = data.get("escena", "")
