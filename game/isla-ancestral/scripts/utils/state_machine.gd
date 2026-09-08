class_name StateMachine
extends Node

## Patrón State Machine genérico (M111 - Código de Calidad).
## Registra estados con callbacks enter/exit y transiciona entre ellos.

signal transitioned(from_state: String, to_state: String)

var states: Dictionary = {}
var current_state: String = ""
var _owner: Object = null

func register_state(name: String, enter: Callable, exit: Callable = Callable()) -> void:
	states[name] = { "enter": enter, "exit": exit }

func setup(owner_ref: Object) -> void:
	_owner = owner_ref

func change_state(name: String) -> void:
	if not states.has(name):
		push_warning("StateMachine: estado inexistente '%s'" % name)
		return
	if current_state != "":
		var old_exit: Callable = states[current_state].get("exit", Callable())
		if old_exit.is_valid():
			old_exit.call(_owner)
	var from := current_state
	current_state = name
	var enter: Callable = states[name]["enter"]
	if enter.is_valid():
		enter.call(_owner)
	transitioned.emit(from, name)
