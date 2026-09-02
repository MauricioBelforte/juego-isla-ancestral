# Modelo: agnes-2.5-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M64: IA de NPC â€” Controlador principal por NPC (NPCAgent)
# Se adjunta a cada Villager como componente. Usa NPCStateMachine monolÃ­tico.

class_name NPCAgent
extends CharacterBody3D

const StateMachineScript = preload("res://scripts/ia_npc/state_machine.gd")
const IdleStateScript = preload("res://scripts/ia_npc/states/idle_state.gd")
const MovementStateScript = preload("res://scripts/ia_npc/states/movement_state.gd")
const WorkStateScript = preload("res://scripts/ia_npc/states/work_state.gd")
const SocialStateScript = preload("res://scripts/ia_npc/states/social_state.gd")
const EatStateScript = preload("res://scripts/ia_npc/states/eat_state.gd")
const SleepStateScript = preload("res://scripts/ia_npc/states/sleep_state.gd")
const ReactStateScript = preload("res://scripts/ia_npc/states/react_state.gd")
const InteractStateScript = preload("res://scripts/ia_npc/states/interact_state.gd")

## Referencias a componentes
var _state_machine: Object = null
var _routine_player: RoutinePlayer = null
var _needs: NPCNeeds = null
var _blackboard: NPCBlackboard = null
var _nav_agent: NavigationAgent3D = null

## SeÃ±ales pÃºblicas
signal npc_state_changed(old_state: StringName, new_state: StringName)
signal npc_arrived(location: StringName)
signal npc_stuck(duration: float)

## Timer para tick discreto
var _tick_timer: float = 0.0
const TICK_INTERVAL_FULL: float = 0.5
const TICK_INTERVAL_MEDIUM: float = 1.0
const TICK_INTERVAL_LIGHT: float = 5.0

var _sim_level: String = "full"
var _npc_id: String = ""


func _ready() -> void:
	_npc_id = name
	_setup_components()
	_setup_navigation()
	_load_routine_from_profile()
	print("[NPCAgent] %s inicializado (perfil=%s)" % [_npc_id, _get_profile_id()])


func _setup_components() -> void:
	_state_machine = StateMachineScript.new()
	_state_machine.name = "StateMachine"
	add_child(_state_machine)
	_state_machine.state_changed.connect(_on_state_changed)
	_state_machine.stuck_detected.connect(func(id, dur): npc_stuck.emit(dur))

	# Registrar estados desde archivos separados
	var idle := IdleStateScript.new()
	var movement := MovementStateScript.new()
	var work := WorkStateScript.new()
	var social := SocialStateScript.new()
	var eat := EatStateScript.new()
	var sleep := SleepStateScript.new()
	var react := ReactStateScript.new()
	var interact := InteractStateScript.new()

	_state_machine.register_state(idle, &"Idle", 10)
	_state_machine.register_state(movement, &"Movement", 30)
	_state_machine.register_state(work, &"Work", 25)
	_state_machine.register_state(social, &"Social", 20)
	_state_machine.register_state(eat, &"Eat", 35)
	_state_machine.register_state(sleep, &"Sleep", 40)
	_state_machine.register_state(react, &"React", 50)
	_state_machine.register_state(interact, &"Interact", 45)

	_needs = NPCNeeds.new()
	_needs.need_urgent.connect(_on_need_urgent)

	_blackboard = NPCBlackboard.new()

	_routine_player = RoutinePlayer.new()
	_routine_player.npc_profile = _get_profile()
	add_child(_routine_player)

	_state_machine.transition_to(&"Idle")


func _setup_navigation() -> void:
	_nav_agent = NavigationAgent3D.new()
	_nav_agent.name = "NavigationAgent"
	_nav_agent.path_desired_distance = 1.0
	_nav_agent.target_desired_distance = 0.5
	_nav_agent.radius = 0.4
	add_child(_nav_agent)


func _process(delta: float) -> void:
	_update_blackboard(delta)
	if _sim_level == "full" or _sim_level == "medium":
		_state_machine.update(delta)
	_tick_timer += delta
	var interval: float = TICK_INTERVAL_FULL if _sim_level == "full" else (TICK_INTERVAL_MEDIUM if _sim_level == "medium" else TICK_INTERVAL_LIGHT)
	if _tick_timer >= interval:
		_tick_timer = 0.0
		_state_machine.tick(delta)
		if _needs != null:
			_needs.update(delta)


func _update_blackboard(_delta: float) -> void:
	if _blackboard == null:
		return
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_blackboard.set_value("player_position", players[0].global_position)
	var weather = get_node_or_null("/root/Weather")
	if weather != null:
		_blackboard.set_value("is_raining", (true if weather.has_method("is_raining") else false))
		_blackboard.set_value("is_storming", (true if weather.has_method("is_storming") else false))
	var gt = get_node_or_null("/root/GameTime")
	if gt != null:
		var hora: int = gt.get_hora()
		_blackboard.set_value("is_night", hora >= 20 or hora < 6)
	var eventos = get_node_or_null("/root/eventos")
	if eventos != null and eventos.has_method("get_evento_actual"):
		var ev = eventos.get_evento_actual()
		if ev != null:
			_blackboard.set_value("event_active", true)
			_blackboard.set_value("current_event", ev.id if ev is EventDefinition else &"")
		else:
			_blackboard.set_value("event_active", false)
			_blackboard.set_value("current_event", &"")
	_update_nearby_npcs()
	var urgent = _needs.get_urgent_need()
	_blackboard.set_value("needs_urgent", urgent)


func _update_nearby_npcs() -> void:
	if _blackboard == null:
		return
	var vm = get_node_or_null("/root/VillagerManager")
	if vm == null:
		return
	var activos = vm.obtener_activos()
	var nearby: Array[StringName] = []
	for v in activos:
		if v == self or not is_instance_valid(v):
			continue
		var dist: float = global_position.distance_to(v.global_position)
		if dist < 5.0:
			var npc_name: StringName = &""
			if v.has_method("name"):
				npc_name = v.name
			elif v.has_method("get_name"):
				npc_name = StringName(v.get_name())
			nearby.append(npc_name)
	_blackboard.set_value("nearby_npcs", nearby)


func _on_need_urgent(need: StringName) -> void:
	print("[NPCAgent] %s necesita urgente: %s" % [_npc_id, need])
	match need:
		&"hunger":
			_state_machine.transition_to(&"Eat")
		&"energy":
			_state_machine.transition_to(&"Sleep")
		&"social":
			var nearby = _blackboard.get_value("nearby_npcs", [])
			if nearby.size() > 0:
				_state_machine.transition_to(&"Social", {"partner": nearby[0], "partner_count": nearby.size()})
			else:
				_state_machine.transition_to(&"Idle")
		_:
			pass


func _on_state_changed(old: StringName, new: StringName) -> void:
	npc_state_changed.emit(old, new)
	print("[NPCAgent] %s: %s -> %s" % [_npc_id, old, new])


func _load_routine_from_profile() -> void:
	var profile = _get_profile()
	if profile != null:
		_routine_player.npc_profile = profile
		var rutina: Dictionary = profile.rutina_diaria
		for key in rutina.keys():
			if str(rutina[key]) in ["despertar", "wake_up", "wake"]:
				var parts = key.split(":")
				if parts.size() > 0:
					_routine_player.wake_hour = int(parts[0])
					break


func _get_profile() -> Resource:
	var vm = get_node_or_null("/root/VillagerManager")
	if vm != null:
		return null  # obtener_perfil not yet implemented in M19
	return null


func _get_profile_id() -> String:
	var p = _get_profile()
	if p != null:
		return str(p.id)
	return "unknown"


# â”€â”€ API pÃºblica â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

func get_state_machine() -> Node:
	return _state_machine


func get_needs() -> NPCNeeds:
	return _needs


func get_blackboard() -> NPCBlackboard:
	return _blackboard


func get_routine() -> RoutinePlayer:
	return _routine_player


func get_navigation_agent() -> NavigationAgent3D:
	return _nav_agent


func navigate_to(target: Vector3) -> void:
	if _nav_agent != null:
		_nav_agent.target_position = target
		_blackboard.set_value("target_position", target)


func stop_movement() -> void:
	velocity = Vector3.ZERO
	move_and_slide()


func get_location_position(location_name: StringName) -> Vector3:
	var vm = get_node_or_null("/root/VillagerManager")
	if vm == null:
		return global_position
	match location_name:
		&"casa":
			var home_idx: int = vm.hogar_de(_npc_id)
			if home_idx >= 0 and vm.has_method("get_spawn_for_parcela"):
				var spawn = vm.get_spawn_for_parcela(home_idx)
				if spawn != null:
					return spawn
			return global_position
		&"trabajo":
			return _get_work_location()
		&"comedor":
			return Vector3(30.0, 1.0, 64.0)
		&"plaza":
			return Vector3(64.0, 1.0, 64.0)
		&"refugio":
			return get_location_position(&"casa")
		_:
			return global_position
	return global_position


func _get_work_location() -> Vector3:
	var profile = _get_profile()
	if profile == null:
		return Vector3(30.0, 1.0, 64.0)
	match str(profile.profesion):
		"cocinera", "cocinero":
			return Vector3(25.0, 1.0, 60.0)
		"pescador", "pescadora":
			return Vector3(55.0, 1.0, 75.0)
		"granjero", "granjera":
			return Vector3(75.0, 1.0, 50.0)
		"artesano", "artesana":
			return Vector3(40.0, 1.0, 80.0)
		"carpintero":
			return Vector3(80.0, 1.0, 70.0)
		_:
			return Vector3(30.0, 1.0, 60.0)


func check_routine_transition() -> Dictionary:
	var action_data = _routine_player.get_next_action(self)
	if action_data.is_empty():
		return {}
	var action = action_data.get("action", &"")
	if action in [&"idle", &"libre", &"free"]:
		return {}
	match action:
		&"trabajar", &"work":
			return {"target": &"Work", "data": {"duration": 300.0}}
		&"comer", &"eat":
			return {"target": &"Eat"}
		&"dormir", &"sleep", &"ir_a_dormir":
			return {"target": &"Sleep"}
		&"socializar", &"social":
			return {"target": &"Social"}
		&"ir_a_casa", &"go_home":
			return {"target": &"Movement", "data": {"hurry": false}}
		&"ir_a_trabajar", &"go_to_work":
			return {"target": &"Movement", "data": {"hurry": false}}
		_:
			return {}
	return {}


func on_arrived() -> void:
	npc_arrived.emit(_blackboard.get_value("current_destination", &""))


func is_at_destination() -> bool:
	if _nav_agent == null:
		return true
	return _nav_agent.is_navigation_finished()


func set_simulation_level(level: String) -> void:
	if _sim_level == level:
		return
	_sim_level = level
	_state_machine.set_simulation_level(level)
	print("[NPCAgent] %s simulaciÃ³n: %s" % [_npc_id, level])


func get_simulation_level() -> String:
	return _sim_level


# â”€â”€ Persistencia (ISaveProvider M59) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

func get_save_data() -> Dictionary:
	return {
		"npc_id": _npc_id,
		"state": _state_machine.get_current_state_name(),
		"needs": _needs.to_dict(),
		"sim_level": _sim_level,
	}


func restore_save_data(data: Dictionary) -> void:
	_npc_id = str(data.get("npc_id", name))
	var needs_data = data.get("needs", {})
	if needs_data != null:
		_needs.from_dict(needs_data)
	_sim_level = str(data.get("sim_level", "full"))
	_state_machine.set_simulation_level(_sim_level)
