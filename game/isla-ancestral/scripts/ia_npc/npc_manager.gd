# Modelo: agnes-2.5-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M64: IA de NPC — NPCManager (autoload)
#
# Gestiona todos los NPCAgents activos: registro/desregistro, niveles de simulación
# por burbuja de distancia, métricas de rendimiento, persistencia M59.
# No modifica M19; solo consume su API.

extends Node

## Preload para resolver el class_name NPCAgent en este script
## (evita fallo de parseo headless por class_name cruzado, AGENTS.md §9.50)
const NPCAgentScript = preload("res://scripts/ia_npc/npc_agent.gd")

## M61: BudgetRegistry para control de memoria
const BudgetRegistryScript = preload("res://scripts/rendimiento/memoria/budget_registry.gd")

## Señales
signal npc_sim_level_changed(npc_id: StringName, old_level: String, new_level: String)
signal npc_created(npc_id: StringName)
signal npc_removed(npc_id: StringName)
signal performance_tick(active_full: int, active_medium: int, active_light: int, avg_tick_ms: float)

## Constantes de simulación por burbuja
const BUBBLE_FULL: float = 30.0
const BUBBLE_MEDIUM: float = 60.0
const BUBBLE_LIGHT: float = 100.0
const MAX_AGMPS_FULL: int = 60  # Máximo de NPCs con IA completa (presupuesto M61)

## Lista de agentes registrados
var _agents: Dictionary = {}  # npc_id -> NPCAgent
## Métricas de rendimiento
var _tick_times: Array[float] = []
const MAX_TICK_HISTORY: int = 60
## M61: BudgetRegistry reference
var _budget_registry: MemoryBudgetRegistry = null
## M64 iter.N: tick optimizado por burbuja
var _tick_accumulator: float = 0.0
const TICK_FULL_INTERVAL: float = 0.5    # 2×/s
const TICK_MEDIUM_INTERVAL: float = 1.0  # 1×/s
const TICK_LIGHT_INTERVAL: float = 5.0   # 1×/5s
## M64 iter.N: watchdog global
var _watchdog = null


func _ready() -> void:
	print("[NPCManager] Inicializado (burbujas: full=%.0fm med=%.0fm light=%.0fm)" % [BUBBLE_FULL, BUBBLE_MEDIUM, BUBBLE_LIGHT])
	_registrar_proveedor_guardado()
	_suscribir_villager_manager()
	_init_budget_registry()
	_init_watchdog()


func _process(delta: float) -> void:
	_update_simulation_levels()
	_update_performance_metrics(delta)
	# M64 iter.N: reportar consumo a BudgetRegistry cada ~5 segundos
	_tick_accumulator += delta
	if _tick_accumulator >= 5.0:
		_tick_accumulator = 0.0
		_report_budget()


func _suscribir_villager_manager() -> void:
	"""Suscribirse a señales de VillagerManager para registrar/desregistrar agentes."""
	var vm = get_node_or_null("/root/VillagerManager")
	if vm != null:
		vm.poblacion_cambio.connect(_on_poblacion_cambio)
		print("[NPCManager] Suscrito a VillagerManager.poblacion_cambio")


## M61: Inicializar BudgetRegistry para control de memoria de IA
func _init_budget_registry() -> void:
	var mm = get_node_or_null("/root/MemoryMonitor")
	if mm != null and mm.has_method("get") and mm.get("budget") != null:
		_budget_registry = mm.budget
		if _budget_registry != null:
			_budget_registry.registrar_sistema("ia_npc", 32)  # 32 MB tope para IA
			print("[NPCManager] BudgetRegistry registrado (tope: 32 MB)")


## M64 iter.N: Inicializar watchdog anti-atascos
func _init_watchdog() -> void:
	var WatchdogClass = preload("res://scripts/ia_npc/npc_watchdog.gd")
	_watchdog = WatchdogClass.new()
	_watchdog.name = "NPCWatchdog"
	add_child(_watchdog)
	_watchdog.stuck_detected.connect(_on_watchdog_stuck)
	_watchdog.recovery_forced.connect(_on_watchdog_recovery)
	print("[NPCManager] Watchdog anti-atascos inicializado")


func _on_poblacion_cambio(activos: Array) -> void:
	"""Sincronizar agentes registrados con la población actual de M19."""
	# Eliminar agentes que ya no están activos
	var to_remove := []
	for npc_id in _agents.keys():
		var found = false
		for v in activos:
			if is_instance_valid(v) and v.name == npc_id:
				found = true
				break
		if not found:
			to_remove.append(npc_id)
	for npc_id in to_remove:
		_remove_agent(npc_id)
	# Agregar nuevos agentes
	for v in activos:
		if not is_instance_valid(v):
			continue
		var npc_id = v.name
		if not _agents.has(npc_id):
			_add_agent(npc_id, v)


## M64 iter.N: Watchdog — NPC atascado detectado
func _on_watchdog_stuck(npc_id: StringName, state: StringName, duration: float) -> void:
	print("[NPCManager] Watchdog: %s atascado en %s (%.1fs)" % [npc_id, state, duration])


## M64 iter.N: Watchdog — recovery forzado
func _on_watchdog_recovery(npc_id: StringName, action: StringName) -> void:
	var agent = _agents.get(npc_id, null)
	if agent == null or not is_instance_valid(agent):
		return
	var sm = agent.get_state_machine()
	if sm == null:
		return
	match action:
		&"force_idle":
			sm.transition_to(&"Idle")
			print("[NPCManager] Watchdog: forzando Idle a %s" % npc_id)
		&"recover_plan":
			if sm.has_method("recover_previous_plan"):
				sm.recover_previous_plan()
				print("[NPCManager] Watchdog: recuperando plan de %s" % npc_id)
		&"work_complete":
			sm.transition_to(&"Idle")
			print("[NPCManager] Watchdog: terminando trabajo de %s" % npc_id)
		&"wake_up":
			sm.transition_to(&"Idle")
			print("[NPCManager] Watchdog: despertando a %s" % npc_id)
		_:
			sm.transition_to(&"Idle")


## M64 iter.N: Routing de cambios de estado al watchdog
func _on_agent_state_changed(npc_id: StringName, new_state: StringName) -> void:
	if _watchdog != null:
		_watchdog.on_state_changed(npc_id, new_state)


func _add_agent(npc_id: String, agent_node: Node) -> void:
	"""Agregar un agente al manager. Busca NPCAgent en la jerarquía del villager."""
	if _agents.has(npc_id):
		return
	# Buscar NPCAgent como hijo del villager
	var npc_agent: Object = null
	if agent_node.has_node("NPCAgent"):
		npc_agent = agent_node.get_node("NPCAgent")
	if npc_agent == null:
		# Crear NPCAgent dinámicamente si no existe
		npc_agent = _create_npc_agent(agent_node)
	if npc_agent != null:
		_agents[npc_id] = npc_agent
		npc_agent.set_simulation_level("full")
		npc_created.emit(npc_id)
		# M64 iter.N: registrar en watchdog + conectar signal
		if _watchdog != null:
			_watchdog.register_npc(StringName(npc_id))
		if npc_agent.has_signal("npc_state_changed"):
			npc_agent.npc_state_changed.connect(
				func(old_s, new_s): _on_agent_state_changed(npc_id, new_s)
			)
		print("[NPCManager] Agente registrado: %s" % npc_id)


func _create_npc_agent(villager: Node) -> Object:
	"""Crear e instanciar un NPCAgent para el villager."""
	# Cargar la escena del NPCAgent
	var agent_scene := preload("res://scenes/npc/npc_agent.tscn")
	if agent_scene == null:
		# Fallback: crear NPCAgent por script
		var agent := NPCAgentScript.new()
		agent.name = "NPCAgent"
		villager.add_child(agent)
		return agent
	# Si hay escena, instanciar
	var instance: Object = agent_scene.instantiate()
	instance.name = "NPCAgent"
	villager.add_child(instance)
	return instance


func _remove_agent(npc_id: String) -> void:
	if _agents.has(npc_id):
		var agent = _agents[npc_id]
		_agents.erase(npc_id)
		npc_removed.emit(npc_id)
		# M64 iter.N: desregistrar del watchdog
		if _watchdog != null:
			_watchdog.unregister_npc(StringName(npc_id))
		print("[NPCManager] Agente removido: %s" % npc_id)


func _update_simulation_levels() -> void:
	"""Actualizar niveles de simulación basado en distancia al jugador."""
	var player_pos = _get_player_position()
	if player_pos == Vector3.ZERO:
		return
	var count_full := 0
	for npc_id in _agents.keys():
		var agent = _agents[npc_id]
		if agent == null:
			continue
		var dist = agent.global_position.distance_to(player_pos)
		var new_level := "sleep"
		if dist < BUBBLE_FULL:
			new_level = "full"
			count_full += 1
		elif dist < BUBBLE_MEDIUM:
			new_level = "medium"
		elif dist < BUBBLE_LIGHT:
			new_level = "light"
		# Limitar NPCs en full al presupuesto
		if new_level == "full" and count_full > MAX_AGMPS_FULL:
			new_level = "medium"
		var current = agent.get_simulation_level()
		if current != new_level:
			agent.set_simulation_level(new_level)
			npc_sim_level_changed.emit(npc_id, current, new_level)


func _get_player_position() -> Vector3:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0].global_position
	return Vector3.ZERO


func _update_performance_metrics(delta: float) -> void:
	"""Registrar tiempo de tick para métricas de rendimiento."""
	var start = Time.get_ticks_msec()
	# Simular un tick ligero
	for npc_id in _agents.keys():
		var agent = _agents[npc_id]
		if agent != null and is_instance_valid(agent):
			pass  # El tick real lo hace el NPCAgent en _process
	var elapsed = float(Time.get_ticks_msec() - start)
	_tick_times.append(elapsed)
	if _tick_times.size() > MAX_TICK_HISTORY:
		_tick_times.resize(MAX_TICK_HISTORY)
	# Emitir métricas cada ~1 segundo
	if _tick_times.size() >= 10:
		var avg = 0.0
		for t in _tick_times:
			avg += t
		avg /= float(_tick_times.size())
		var full := 0
		var medium := 0
		var light := 0
		for npc_id in _agents.keys():
			var agent = _agents[npc_id]
			if agent == null:
				continue
			match agent.get_simulation_level():
				"full": full += 1
				"medium": medium += 1
				"light": light += 1
		performance_tick.emit(full, medium, light, avg)


# ── API pública ──────────────────────────────────────────────────────

## M61: reportar consumo estimado de memoria al BudgetRegistry
func _report_budget() -> void:
	if _budget_registry == null:
		return
	# Estimación: ~512 bytes por agente activo + overhead de FSM
	var mem_kb: int = _agents.size() * 512 + 4096
	var mem_mb: int = maxi(1, mem_kb / 1024)
	_budget_registry.reportar_consumo("ia_npc", mem_mb)
	var sobre: Array = _budget_registry.verificar()
	if "ia_npc" in sobre:
		push_warning("[NPCManager] ¡Sobre presupuesto M61! (%d MB / %d MB)" % [
			mem_mb, _budget_registry.tope_de("ia_npc")
		])

func get_agent(npc_id: String) -> NPCAgent:
	return _agents.get(npc_id, null)


func get_all_agents() -> Dictionary:
	return _agents.duplicate()


func get_agent_count() -> int:
	return _agents.size()


func get_active_full_count() -> int:
	var count := 0
	for npc_id in _agents.keys():
		var agent = _agents[npc_id]
		if agent != null and agent.get_simulation_level() == "full":
			count += 1
	return count


func get_avg_tick_ms() -> float:
	if _tick_times.is_empty():
		return 0.0
	var sum := 0.0
	for t in _tick_times:
		sum += t
	return sum / float(_tick_times.size())


func get_performance_summary() -> Dictionary:
	return {
		"total_agents": _agents.size(),
		"full": get_active_full_count(),
		"avg_tick_ms": get_avg_tick_ms(),
		"bubble_limits": {
			"full": BUBBLE_FULL,
			"medium": BUBBLE_MEDIUM,
			"light": BUBBLE_LIGHT,
			"max_full": MAX_AGMPS_FULL,
		},
	}


# ── Persistencia (ISaveProvider M59) ─────────────────────────────────

func _registrar_proveedor_guardado() -> void:
	var sm = get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)


func get_section_name() -> String:
	return "npc_ai"


func get_save_data() -> Dictionary:
	var agents_data := {}
	for npc_id in _agents.keys():
		var agent = _agents[npc_id]
		if agent != null and is_instance_valid(agent):
			agents_data[npc_id] = agent.get_save_data()
	return {"agents": agents_data}


func restore_save_data(data: Dictionary) -> void:
	var agents_data: Dictionary = data.get("agents", {})
	for npc_id in agents_data.keys():
		if _agents.has(npc_id):
			var agent = _agents[npc_id]
			if agent != null and is_instance_valid(agent):
				agent.restore_save_data(agents_data[npc_id])
		# Si el agente no existe, se recreará cuando M19 registre el villager
