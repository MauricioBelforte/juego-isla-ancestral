# Modelo: agnes-3-flash
# Plataforma: Kilo Code
# Fecha: 2026-10-04
#
# M40: ServiceRegistry — registro central de servicios (autoload).
# Los dominios de juego se registran aquí por contrato (string).
# BUG-091 fix: la clase no existía pero era referenciada por ~15 archivos.

extends Node

var _registry: Dictionary = {}

## Registra un servicio por contrato (string).
func register(contract: String, instance: Object) -> void:
	_registry[contract] = instance

## Devuelve la instancia registrada para un contrato, o null.
func get_service(contract: String) -> Variant:
	return _registry.get(contract, null)

## Devuelve si existe un servicio registrado para el contrato.
func has(contract: String) -> bool:
	return _registry.has(contract)

## Elimina un servicio del registro.
func unregister(contract: String) -> void:
	_registry.erase(contract)

## Devuelve todos los contratos registrados.
func contracts() -> Array:
	return _registry.keys()

## BUG-097: lista de nombres de servicios registrados (Array[String]).
## Usado por bootstrap.gd:109 y M62/M110 debug menu.
func list_registered() -> Array[String]:
	var result: Array[String] = []
	for key in _registry:
		result.append(String(key))
	return result

## BUG-097: valida que todos los servicios en `required` estén registrados.
## Devuelve Array[String] de faltantes (vacío = todo OK).
## No aborta el juego: el caller (bootstrap) decide push_error o log.
func validate_required(required: Array) -> Array[String]:
	var missing: Array[String] = []
	for svc in required:
		if not _registry.has(String(svc)):
			missing.append(String(svc))
	return missing

func _ready() -> void:
	print("[M40] ServiceRegistry listo (%d servicios registrados)" % _registry.size())
