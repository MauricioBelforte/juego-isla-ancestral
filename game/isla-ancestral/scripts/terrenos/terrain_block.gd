extends StaticBody3D

## Bloque de terreno base (M156). Hereda de StaticBody3D para colision fisica.

@export var terrain_type: String = "ceped"
@export var friction: float = 0.8

func _ready() -> void:
	# Asignar layer segun tipo de terreno (M156)
	collision_layer = _layer_for_type(terrain_type)

func _layer_for_type(t: String) -> int:
	match t:
		"ceped": return 1
		"barro": return 2
		"pavimento": return 4
		"arena": return 8
		"agua": return 16
		"nieve": return 32
		"rocas": return 64
		_: return 1