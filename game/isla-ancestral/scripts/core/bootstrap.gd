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

## Catálogo de dominios de juego esperados (RF11 M40): el Bootstrap es el único
## que conoce la lista COMPLETA. La integridad se verifica al final del arranque.
## Un dominio faltante = advertencia DOM-INF-FALTANTE (no error: builds parciales).
const DOMINIOS_ESPERADOS: Array[String] = [
	"economy_manager",
	"shop_manager",
	"inventario",
	"balance",
	"time_calendar",
	"farm",
	"fishing",
	"dialogue_manager",
	"crafting",
]

## Escena principal a cargar después del bootstrap
const MAIN_SCENE_PATH: String = "res://scenes/main_island.tscn"


func _ready() -> void:
	print("=== Bootstrap Iniciando ===")

	_register_core_services()
	_validate_services()

	# Deferred: GameFlowManager y dominios se montan DESPUÉS del Bootstrap
	# (orden de autoloads). El paso a MUNDO y el autorregistro corren al final.
	_verificar_game_flow.call_deferred()
	_autoregistrar_dominios.call_deferred()
	verificar_integridad_dominios.call_deferred()
	_load_main_scene.call_deferred()

	print("=== Bootstrap Completado ===")


## M40 §2: los dominios se auto-registran en el ServiceRegistry por contrato.
## Se hace DEFERIDO desde el Bootstrap (único registrador según M07) para no
## tocar los scripts de dominio (son de otros agentes) y respetar el orden real.
func _autoregistrar_dominios() -> void:
	var dominios := {
		"economy_manager": "EconomyManager",
		"shop_manager": "ShopManager",
		"inventario": "Inventario",
		"balance": "Balance",
		"time_calendar": "TimeCalendar",
		"farm": "Farm",
		"fishing": "Fishing",
		"dialogue_manager": "DialogueManager",
		"crafting": "Crafting",
		"game_flow": "GameFlowManager",
		"scene_manager": "SceneManager",
	}
	for contrato in dominios:
		var nodo = get_node_or_null("/root/" + dominios[contrato])
		if nodo != null and not ServiceRegistry.has(contrato):
			ServiceRegistry.register(contrato, nodo)


## M40: el GameFlowManager inicia en BOOT; esta escena es el mundo, así que
## pasamos a MUNDO (transición válida BOOT->MUNDO según las transiciones del M40).
func _verificar_game_flow() -> void:
	var gfm = get_node_or_null("/root/GameFlowManager")
	if gfm == null:
		print("[Bootstrap] GameFlowManager no montado (build parcial)")
		return
	if gfm.has_method("cambiar_estado"):
		# Estado.MUNDO = 3 en el enum del GameFlowManager (BOOT=0, MENU=1, ...)
		gfm.cambiar_estado(3)
		print("[Bootstrap] GameFlowManager -> MUNDO")


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


## RF11 (M40): verifica integridad del catálogo de dominios de juego.
## Se llama DEFERIDA (los dominios se auto-registran después del core).
## Faltantes = advertencia (builds parciales coexisten con la regla cozy).
func verificar_integridad_dominios() -> void:
	var faltantes: Array[String] = []
	for dominio in DOMINIOS_ESPERADOS:
		if not ServiceRegistry.has(dominio):
			faltantes.append(dominio)
	if faltantes.size() > 0:
		print("[Bootstrap] DOM-INF-FALTANTE dominios de juego no registrados: %s" % str(faltantes))
	else:
		print("[Bootstrap] DOM-INF integridad OK: %d dominios de juego verificados" % DOMINIOS_ESPERADOS.size())


## Carga la escena principal del juego (deferred)
func _load_main_scene() -> void:
	# Respetar una escena pedida explícitamente por CLI (previews de módulos,
	# ej: godot res://scenes/preview_reloj.tscn). Si el árbol ya tiene una
	# escena actual que NO es la principal, no la pisamos.
	var actual := get_tree().current_scene
	if actual != null and actual.scene_file_path != "" \
			and actual.scene_file_path != MAIN_SCENE_PATH:
		print("[Bootstrap] Escena personalizada por CLI detectada (%s): no se redirige a %s" % [actual.scene_file_path, MAIN_SCENE_PATH])
		return

	print("[Bootstrap] Cargando escena principal: %s" % MAIN_SCENE_PATH)

	# Verificar que la escena existe
	if not ResourceLoader.exists(MAIN_SCENE_PATH):
		push_error("Bootstrap: escena principal no encontrada: %s" % MAIN_SCENE_PATH)
		return

	# Cambiar a la escena principal (deferred para evitar conflictos).
	# Si el engine ya cargó la escena principal (run/main_scene), evitamos
	# la doble carga y solo registramos el hecho.
	if actual != null and actual.scene_file_path == MAIN_SCENE_PATH:
		print("[Bootstrap] Escena principal ya activa: se omite recarga")
		return

	get_tree().change_scene_to_file(MAIN_SCENE_PATH)


## ── API para otros sistemas ──────────────────────────────

## Registra un servicio adicional (llamado por módulos que se inicializan después)
func register_service(interface_name: String, service: Node) -> void:
	ServiceRegistry.register(interface_name, service)


## Obtiene un servicio (atajo)
func get_service(interface_name: String) -> Node:
	return ServiceRegistry.get_service(interface_name)
