class_name StateComponent
extends Node

## Componente reutilizable de estado finito simple (M111 - Código de Calidad).
## Para máquinas de estado más completas usar StateMachine (state_machine.gd).

signal state_changed(new_state: int, old_state: int)

var current_state: int = 0:
	get:
		return _state
	set(v):
		if v == _state:
			return
		var old := _state
		_state = v
		state_changed.emit(_state, old)

var _state: int = 0

func set_state(s: int) -> void:
	current_state = s
