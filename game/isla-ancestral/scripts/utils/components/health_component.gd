class_name HealthComponent
extends Node

## Componente reutilizable de salud (M111 - Código de Calidad).
## Composición sobre herencia: añadir como hijo de cualquier entidad.

signal health_changed(current: float, max_value: float)
signal died

@export var max_health: float = 100.0

var current_health: float:
	get:
		return _current
	set(v):
		_current = clamp(v, 0.0, max_health)
		health_changed.emit(_current, max_health)
		if _current <= 0.0:
			died.emit()

var _current: float = 100.0

func _ready() -> void:
	_current = max_health

func damage(amount: float) -> void:
	current_health -= amount

func heal(amount: float) -> void:
	current_health += amount
