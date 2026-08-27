class_name SaveSnapshot
extends RefCounted

## Módulo 59: Guardado — Recolecta y restaura el estado de los sistemas
##
## Centraliza la lista de proveedores (ISaveProvider) registrados y es el
## puente entre el payload del save y cada sistema del juego. Los sistemas
## se registran vía SaveManager.register_provider() para no acoplarse aquí.

## Diccionario de proveedores registrados: sección -> ISaveProvider
var _providers: Dictionary = {}

## Slots de sistema aún no reclamados por un proveedor (usuarios del schema)
var _reserved_sections: Array[String] = [
	"world", "player", "inventory", "buildings", "npc",
	"quests", "friendship", "economy", "time", "events",
	"collections", "diary", "photos",
]

func _init() -> void:
	pass

## Registra un proveedor para una sección del save.
## Devuelve false si la sección ya está registrada (no se duplica).
## Sin tipo estricto: acepta cualquier objeto con el contrato
## get_section_name/get_save_data/restore_save_data (ej: autoload Inventario M14).
func register_provider(provider) -> bool:
	var section: String = provider.get_section_name()
	if _providers.has(section):
		push_warning("[SAVE] Sección '%s' ya registrada, se ignora el duplicado" % section)
		return false
	_providers[section] = provider
	return true

## Recolecta el estado actual de todos los sistemas registrados y lo
## devuelve como un Dictionary listo para guardar (sobre defaults del schema).
func collect(profile_id: String = "") -> Dictionary:
	var payload := SaveSchema.default_payload(profile_id)
	for section in _providers:
		var provider: ISaveProvider = _providers[section]
		var data: Dictionary = provider.get_save_data()
		payload[section] = data
	return payload

## Restaura el estado de cada sistema desde el payload cargado.
## Es tolerante: si una sección no tiene proveedor registrado, se ignora
## (se restaura en un momento posterior cuando el sistema exista).
func restore(payload: Dictionary) -> void:
	for section in _providers:
		var provider: ISaveProvider = _providers[section]
		if payload.has(section) and typeof(payload[section]) == TYPE_DICTIONARY:
			provider.restore_save_data(payload[section])

## Lista de secciones que aún no tienen proveedor (para diagnóstico).
func unclaimed_sections() -> Array[String]:
	var result: Array[String] = []
	for s in _reserved_sections:
		if not _providers.has(s):
			result.append(s)
	return result
