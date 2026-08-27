extends Node
## Bootstrap de Isla Ancestral
##
## Responsabilidades:
## 1. Registrar servicios core en ServiceRegistry
## 2. Cargar configuración
## 3. Cargar o crear GameState (M59)
## 4. Arrancar la escena Main
##
## Reglas:
##   - Solo registro, NO lógica de dominio
##   - Orden de registro = orden de dependencias
##   - Idempotente: poder llamar multiples veces sin efectos secundarios

## Servicios obligatorios que DEBEN estar registrados
const REQUIRED_SERVICES: Array[String] = [
	"event_bus",
]

## Escena principal a cargar después del bootstrap
const MAIN_SCENE_PATH: String = "res://scenes/main_island.tscn"


func _ready() -> void:
	print("=== Bootstrap Iniciando ===")
	
	_register_core_services()
	_validate_services()
	
	# Deferred para evitar conflictos con otros autoloads en _ready
	_load_main_scene.call_deferred()
	
	print("=== Bootstrap Completado ===")


## Registra los servicios core del juego
func _register_core_services() -> void:
	print("[Bootstrap] Registrando servicios core...")
	
	# 1. EventBus (ya existe como autoload, solo lo referenciamos)
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus:
		ServiceRegistry.register("event_bus", event_bus)
	else:
		push_warning("Bootstrap: EventBus no encontrado como autoload")
	
	# 2. ServiceRegistry (este mismo script)
	ServiceRegistry.register("service_registry", self)
	
	# 3. GameState placeholder (M59 implementará la versión real)
	# Por ahora no registramos nada — se creará cuando M59 se implemente
	
	var registered = ServiceRegistry.list_registered()
	print("[Bootstrap] Servicios core registrados (%d): %s" % [registered.size(), str(registered)])


## Valida que todos los servicios obligatorios estén presentes
func _validate_services() -> void:
	var missing = ServiceRegistry.validate_required(REQUIRED_SERVICES)
	if missing.size() > 0:
		push_error("Bootstrap: servicios obligatorios faltantes: %s" % str(missing))
	else:
		print("[Bootstrap] Todos los servicios obligatorios están registrados")


## Carga la escena principal del juego (deferred)
func _load_main_scene() -> void:
	print("[Bootstrap] Cargando escena principal: %s" % MAIN_SCENE_PATH)
	
	# Verificar que la escena existe
	if not ResourceLoader.exists(MAIN_SCENE_PATH):
		push_error("Bootstrap: escena principal no encontrada: %s" % MAIN_SCENE_PATH)
		return
	
	# Cambiar a la escena principal (deferred para evitar conflictos)
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)


## ── API para otros sistemas ──────────────────────────────

## Registra un servicio adicional (llamado por módulos que se inicializan después)
func register_service(interface_name: String, service: Node) -> void:
	ServiceRegistry.register(interface_name, service)


## Obtiene un servicio (atajo)
func get_service(interface_name: String) -> Node:
	return ServiceRegistry.get_service(interface_name)
