# Modelo: agnes-2.5-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M64: IA de NPC — FSM State Machine (orquestador)
# Los estados son nodos separados en scripts/ia_npc/states/*.gd

extends Node
class_name NPCStateMachine

## ── Señales públicas ─────────────────────────────────────
signal state_changed(old_state: StringName, new_state: StringName)
signal stuck_detected(npc_id: StringName, duration: float)

## ── Estado actual ────────────────────────────────────────
var current_state: Node = null
var _states: Dictionary = {}
var _history: Array[StringName] = []
var _stuck_timer: float = 0.0
const STUCK_THRESHOLD: float = 2.0
const STUCK_RESPAWN_THRESHOLD: float = 10.0
var _last_position: Vector3 = Vector3.ZERO
var simulation_level: String = "full"


func _ready() -> void:
	pass


## ── Registro de estados ──────────────────────────────────

func register_state(state: Node, name: StringName, priority: int = 0) -> void:
	state.set("state_name", name)
	state.set("priority", priority)
	state.set("controller", get_parent())
	_states[name] = state
	print("[StateMachine] Estado registrado: %s (prioridad=%d)" % [name, priority])


## ── Transición ───────────────────────────────────────────

func transition_to(target: StringName, data: Dictionary = {}) -> void:
	# Grab old state name BEFORE changing current_state
	var old_sn: String = ""
	if current_state != null and current_state.has_method("get_state_name_raw"):
		old_sn = str(current_state.get_state_name_raw())
	# Exit old state
	if current_state != null and current_state.has_method("exit"):
		current_state.exit()
	# Add to history only if there was a real previous state
	if current_state != null:
		_history.append(StringName(old_sn))
		if _history.size() > 10:
			_history.resize(10)
	# Find next state
	var next = _states.get(target)
	if next == null:
		push_warning("[StateMachine] Estado '%s' no existe, fallback a Idle" % target)
		next = _states.get(&"Idle")
		if next == null:
			push_error("[StateMachine] No hay Idle fallback!")
			return
	current_state = next
	if current_state.has_method("enter"):
		current_state.enter(data)
	var new_sn: String = ""
	if current_state.has_method("get_state_name_raw"):
		new_sn = str(current_state.get_state_name_raw())
	state_changed.emit(StringName(old_sn), StringName(new_sn))
	print("[StateMachine] Transición: %s -> %s" % [old_sn, new_sn])


## ── Update principal (cada frame) ───────────────────────

func update(delta: float) -> void:
	if current_state == null or simulation_level == "sleep":
		return
	_update_stuck_detection(delta)
	if current_state.has_method("update"):
		current_state.update(delta)
	if current_state.has_method("check_transitions"):
		var result = current_state.check_transitions()
		if result is Dictionary and result.has("target"):
			transition_to(result.target, result.get("data") if result.has("data") else {})


## ── Tick discreto ────────────────────────────────────────

func tick(delta: float) -> void:
	if current_state == null or simulation_level == "sleep":
		return
	if current_state.has_method("tick"):
		current_state.tick(delta)


## ── Nivel de simulación ─────────────────────────────────

func set_simulation_level(level: String) -> void:
	if simulation_level == level:
		return
	var previous = simulation_level
	simulation_level = level
	var parent = get_parent()
	if parent != null:
		var pname: String = "unknown"
		if parent.has_method("get_name"):
			pname = parent.get_name()
		print("[StateMachine] %s: %s -> %s" % [pname, previous, level])
	if level == "sleep" and current_state != null:
		var sn = ""
		if current_state.has_method("get_state_name_raw"):
			sn = str(current_state.get_state_name_raw())
		if sn in ["Movement", "Work", "Social", "Eat"]:
			transition_to(&"Sleep")


## ── Anti-atascos ─────────────────────────────────────────

func reset_stuck_timer() -> void:
	_stuck_timer = 0.0
	var p = get_parent()
	_last_position = p.global_position if p != null else Vector3.ZERO


func _update_stuck_detection(delta: float) -> void:
	var p = get_parent()
	if p == null:
		return
	var pos = p.global_position
	var dist = pos.distance_to(_last_position)
	if dist < 0.05:
		_stuck_timer += delta
		if _stuck_timer >= STUCK_THRESHOLD and _stuck_timer < STUCK_THRESHOLD + delta:
			var np: String = "unknown"
			if p.has_method("get_name"):
				np = p.get_name()
			print("[StateMachine] NPC atascado %s por %.1fs" % [np, _stuck_timer])
			stuck_detected.emit(np, _stuck_timer)
			_force_new_target()
		if _stuck_timer >= STUCK_RESPAWN_THRESHOLD:
			var np2: String = "unknown"
			if p.has_method("get_name"):
				np2 = p.get_name()
			print("[StateMachine] NPC %s respawn emergencia (%.1fs)" % [np2, _stuck_timer])
			_respawn_emergency()
	else:
		if _stuck_timer > 0:
			var np3: String = "unknown"
			if p.has_method("get_name"):
				np3 = p.get_name()
			print("[StateMachine] NPC %s liberado de atasco" % np3)
		_stuck_timer = 0.0
		_last_position = pos


func _force_new_target() -> void:
	var ctrl = get_parent()
	if ctrl == null:
		return
	if ctrl.has_method("get_routine"):
		var routine = ctrl.get_routine()
		if routine != null and routine.has_method("get_next_action"):
			var action = routine.get_next_action(ctrl)
			if action is Dictionary and not action.is_empty() and action.has("location"):
				if ctrl.has_method("get_location_position"):
					var loc = ctrl.get_location_position(action.location)
					if loc != null:
						ctrl.navigate_to(loc)
						reset_stuck_timer()
						return
	var base = ctrl.global_position
	var offset = Vector3(randf_range(-5.0, 5.0), 0.0, randf_range(-5.0, 5.0))
	ctrl.navigate_to(base + offset)
	reset_stuck_timer()


func _respawn_emergency() -> void:
	var ctrl = get_parent()
	if ctrl == null:
		return
	var vm = get_node_or_null("/root/VillagerManager")
	if vm != null:
		if vm.has_method("get_hogares"):
			var homes = vm.get_hogares()
			if homes is Dictionary and homes.has(ctrl.name):
				var hp: Vector3 = homes[ctrl.name]
				ctrl.global_position = hp
				print("[StateMachine] Respawn %s a hogar (%.1f, %.1f, %.1f)" % [ctrl.name, hp.x, hp.y, hp.z])
	_reset_stuck_internal()


func _reset_stuck_internal() -> void:
	_stuck_timer = 0.0
	var p = get_parent()
	_last_position = p.global_position if p != null else Vector3.ZERO


func get_current_state_name() -> StringName:
	if current_state != null and current_state.get("state_name") != null:
		return StringName(str(current_state.get("state_name")))
	return &"None"


func get_history() -> Array[StringName]:
	return _history.duplicate()
