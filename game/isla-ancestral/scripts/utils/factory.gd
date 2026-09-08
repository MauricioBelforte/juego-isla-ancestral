class_name Factory
extends RefCounted

## Patrón Factory genérico (M111 - Código de Calidad).
## Registra builders por id y crea instancias bajo demanda.

var _builders: Dictionary = {}

func register(id: String, builder: Callable) -> void:
	_builders[id] = builder

func create(id: String, context: Variant = null) -> Object:
	if not _builders.has(id):
		push_error("Factory: id no registrado '%s'" % id)
		return null
	return _builders[id].call(context)
