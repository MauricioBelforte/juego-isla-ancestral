extends Control
## M53 HUD — ResourceCounter: muestra recursos seleccionados.

var _label: Label

func _ready() -> void:
	_label = Label.new()
	add_child(_label)

func set_recursos(items: Dictionary) -> void:
	var partes: Array[String] = []
	for key in items:
		partes.append("%s: %d" % [key, items[key]])
	_label.text = "  ".join(partes)
