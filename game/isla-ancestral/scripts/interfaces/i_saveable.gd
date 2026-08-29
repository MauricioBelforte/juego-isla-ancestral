@tool
extends Resource
class_name ISaveable

##
# Interfaz para objetos que pueden guardar y cargar su estado.
# Implementar en sistemas, managers, NPCs, items, mundo, etc.
# Compatible con M59 SaveManager + SaveProvider pattern.
#
# @see SaveProvider, SaveManager, IInteractable, IDamageable

## Obtiene los datos serializables para guardar.
# @return Diccionario con todo el estado necesario para restaurar
func get_save_data() -> Dictionary:
	return {}

## Carga los datos desde un save.
# @param data Diccionario devuelto por get_save_data()
# @param version Versión del schema de save (para migraciones)
func load_save_data(data: Dictionary, version: int = 1) -> void:
	pass

## Obtiene el ID único de este saveable (para identificar en el save global).
# @return String único y estable entre sesiones
func get_save_id() -> String:
	return ""

## Obtiene la versión actual del formato de datos.
# @return Versión incremental (empezar en 1, incrementar en breaking changes)
func get_save_version() -> int:
	return 1

## Verifica si hay cambios sin guardar (para auto-save inteligente).
# @return true si el estado difiere del último guardado
func has_unsaved_changes() -> bool:
	return false

## Marca el estado como guardado (reset dirty flag).
func mark_saved() -> void:
	pass

## Validación opcional antes de guardar (para detectar corrupción temprano).
# @return true si los datos son válidos
func validate_save_data(data: Dictionary) -> bool:
	return true

## Señal emitida cuando el objeto se guarda exitosamente.
signal saved(save_id: String)

## Señal emitida cuando el objeto carga exitosamente.
signal loaded(save_id: String)