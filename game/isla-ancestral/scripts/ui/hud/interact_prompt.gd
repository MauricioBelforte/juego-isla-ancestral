extends Control
## M53 HUD — InteractPrompt: prompt de interacción contextual (M70).

var _visible := false
var _texto := ""

func show_prompt(text: String) -> void:
	_texto = text
	_visible = true
	_modificar_visibilidad()

func hide_prompt() -> void:
	_texto = ""
	_visible = false
	_modificar_visibilidad()

func get_texto() -> String:
	return _texto

func _modificar_visibilidad() -> void:
	visible = _visible
