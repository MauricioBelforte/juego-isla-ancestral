class_name Command
extends RefCounted

## Patrón Command genérico (M111 - Código de Calidad).
## Encapsula una acción ejecutable con guarda opcional.

var _execute: Callable
var _can_execute: Callable

func _init(execute: Callable, can_execute: Callable = Callable()) -> void:
	_execute = execute
	_can_execute = can_execute

func can_execute(context: Variant = null) -> bool:
	if _can_execute.is_valid():
		return _can_execute.call(context)
	return true

func execute(context: Variant = null) -> void:
	if can_execute(context):
		_execute.call(context)
