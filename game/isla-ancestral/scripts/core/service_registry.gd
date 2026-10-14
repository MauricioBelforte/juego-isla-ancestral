# Modelo: agnes-3-flash
# Plataforma: Kilo Code
# Fecha: 2026-10-04
#
# M40: ServiceRegistry — registro central de servicios (autoload).
# Los dominios de juego se registran aquí por contrato (string).
# BUG-091 fix: la clase no existía pero era referenciada por ~15 archivos.

extends Node

var _registry: Dictionary = {}
## Contratos sobre los que ya se emitió DOM-INF-ACCESO-TEMPRANO (evita spam).
var _avisados_tempranos: Dictionary = {}
## Contador de registros duplicados rechazados (diagnostico).
var _duplicados_rechazados: int = 0

## Registra un servicio por contrato (string).
## Devuelve false y emite DOM-INF-REGISTRO si el contrato YA estaba registrado
## (M40 RF3: el segundo registro se rechaza, no se sobrescribe).
## Cambio de firma void -> bool (2026-10-12, step-5-kilocode): los
## llamadores que ignoran el retorno no se ven afectados.
func register(contract: String, instance: Object) -> bool:
	if _registry.has(contract):
		push_warning("[M40] DOM-INF-REGISTRO: contrato duplicado '%s' — segundo registro rechazado" % contract)
		_duplicados_rechazados += 1
		return false
	_registry[contract] = instance
	return true

## Devuelve la instancia registrada para un contrato, o null.
## M40 RF12: si el contrato no está registrado, emite DOM-INF-ACCESO-TEMPRANO
## (una sola vez por contrato, para no llenar el log).
func get_service(contract: String) -> Variant:
	var svc: Variant = _registry.get(contract, null)
	if svc == null and not _avisados_tempranos.has(contract):
		_avisados_tempranos[contract] = true
		push_warning("[M40] DOM-INF-ACCESO-TEMPRANO: consulta de '%s' antes de registrarse (devuelve null)" % contract)
	return svc

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

## Diagnostico: cuantos registros duplicados se rechazaron.
func duplicados_rechazados() -> int:
	return _duplicados_rechazados

func _ready() -> void:
	print("[M40] ServiceRegistry listo (%d servicios registrados)" % _registry.size())
