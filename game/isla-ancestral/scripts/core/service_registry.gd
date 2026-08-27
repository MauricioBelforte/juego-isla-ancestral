extends Node
## Service Registry (Service Locator) para Isla Ancestral
##
## Patrón: los servicios se registran por INTERFAZ (no por nombre concreto).
## Esto permite intercambiar implementaciones (testing, debug, migraciones).
##
## Uso:
##   ServiceRegistry.register("inventory", InventoryService.new())
##   var inv = ServiceRegistry.get_service("inventory")
##
## Reglas:
##   - Solo Bootstrap registra servicios
##   - Los servicios se consultan por interfaz, no por nombre de clase
##   - Un servicio NO puede depender de otro de nivel superior

## Servicios registrados por nombre de interfaz
var _services: Dictionary = {}

## Orden de registro (para debugging y dependencias)
var _registration_order: Array[String] = []


## ── API pública ─────────────────────────────────────────

## Registra un servicio bajo un nombre de interfaz
func register(interface_name: String, service: Node) -> void:
	if _services.has(interface_name):
		push_warning("ServiceRegistry: '%s' ya está registrado, sobrescribiendo." % interface_name)
	_services[interface_name] = service
	_registration_order.append(interface_name)
	print("ServiceRegistry: registrado '%s' → %s" % [interface_name, service.get_class()])


## Obtiene un servicio por nombre de interfaz
func get_service(interface_name: String) -> Node:
	if not _services.has(interface_name):
		push_error("ServiceRegistry: servicio '%s' no encontrado." % interface_name)
		return null
	return _services[interface_name]


## Verifica si un servicio está registrado
func has(interface_name: String) -> bool:
	return _services.has(interface_name)


## Lista todos los servicios registrados
func list_registered() -> Array[String]:
	return _registration_order.duplicate()


## Verifica que todos los servicios obligatorios estén registrados
func validate_required(required: Array[String]) -> Array[String]:
	var missing: Array[String] = []
	for name in required:
		if not _services.has(name):
			missing.append(name)
	return missing


## ── Lifecycle ───────────────────────────────────────────

func _ready() -> void:
	print("ServiceRegistry: inicializado")


## Imprime el estado actual (para debug)
func debug_print() -> void:
	print("=== ServiceRegistry ===")
	print("Servicios registrados: %d" % _services.size())
	for name in _registration_order:
		var service = _services[name]
		print("  [%s] %s (%s)" % [name, service.get_class(), service.get_path()])
	print("========================")
