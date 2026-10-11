extends Control
## M53 HUD — SeasonWidget: icono + texto de estación.

var _label: Label

func _ready() -> void:
	_label = Label.new()
	add_child(_label)

func set_estacion(nombre: String) -> void:
	_label.text = nombre
