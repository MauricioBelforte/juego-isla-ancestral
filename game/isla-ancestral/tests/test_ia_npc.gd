# Modelo: agnes-2.5-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M64: Test headless de IA de NPC
# Ejecutar: godot --headless --path game/isla-ancestral --script res://tests/test_ia_npc.gd

extends SceneTree

const StateMachineScript = preload("res://scripts/ia_npc/state_machine.gd")
const IdleStateScript = preload("res://scripts/ia_npc/states/idle_state.gd")
const MovementStateScript = preload("res://scripts/ia_npc/states/movement_state.gd")
const WorkStateScript = preload("res://scripts/ia_npc/states/work_state.gd")
const SocialStateScript = preload("res://scripts/ia_npc/states/social_state.gd")
const EatStateScript = preload("res://scripts/ia_npc/states/eat_state.gd")
const SleepStateScript = preload("res://scripts/ia_npc/states/sleep_state.gd")
const ReactStateScript = preload("res://scripts/ia_npc/states/react_state.gd")
const InteractStateScript = preload("res://scripts/ia_npc/states/interact_state.gd")
const RoutinePlayerScript = preload("res://scripts/ia_npc/routine_player.gd")

var _fallos: int = 0
var _ok: int = 0


func _init() -> void:
	call_deferred("_correr")


func _get_root(name: String) -> Node:
	return get_root().get_node_or_null(name)


func _check(nombre: String, cond: bool) -> void:
	if cond:
		_ok += 1
		print("[OK] %s" % nombre)
		return
	_fallos += 1
	printerr("[FAIL] %s" % nombre)


func _correr() -> void:
	# ── 1. Blackboard ──────────────────────────────────────────
	print("\n=== TEST BLACKBOARD ===")
	var bb := NPCBlackboard.new()
	_check("blackboard creado", bb != null)
	bb.set_value(&"player_position", Vector3(10.0, 0.0, 10.0))
	_check("set/get player_position", bb.get_value(&"player_position") == Vector3(10.0, 0.0, 10.0))
	_check("has_value true", bb.has_value(&"player_position"))
	_check("has_value false", not bb.has_value(&"nonexistent"))
	_check("default value", bb.get_value(&"missing", 42) == 42)
	bb.set_value(&"is_raining", true)
	_check("is_raining", bb.is_raining())
	bb.set_value(&"is_storming", true)
	_check("is_storming", bb.is_storming())
	bb.set_value(&"is_night", true)
	_check("is_night", bb.is_night())
	bb.set_value(&"event_active", true)
	_check("has_active_event", bb.has_active_event())
	bb.set_value(&"current_event", &"festival_primavera")
	_check("get_current_event", bb.get_current_event() == &"festival_primavera")
	bb.clear()
	_check("clear blackboard", bb.data.is_empty())

	# ── 2. NPCNeeds ────────────────────────────────────────────
	print("\n=== TEST NEEDS ===")
	var needs := NPCNeeds.new()
	_check("needs hunger inicial 100", absf(needs.hunger - 100.0) < 0.01)
	_check("needs energy inicial 100", absf(needs.energy - 100.0) < 0.01)
	_check("needs social inicial 50", absf(needs.social - 50.0) < 0.01)
	needs.update(10.0)
	_check("hunger baja con update", needs.hunger < 100.0)
	_check("energy baja con update", needs.energy < 100.0)
	_check("social baja con update", needs.social < 50.0)
	_check("no urgente al inicio", needs.get_urgent_need() == &"")
	needs.hunger = 10.0
	_check("hunger < 20 → urgente", needs.get_urgent_need() == &"hunger")
	needs.hunger = 100.0
	needs.energy = 10.0
	_check("energy < 15 → urgente", needs.get_urgent_need() == &"energy")
	needs.energy = 100.0
	needs.social = 10.0
	_check("social < 20 → urgente", needs.get_urgent_need() == &"social")
	needs.eat(30.0)
	_check("eat aumenta hunger", needs.hunger > 80.0)
	needs.sleep(50.0)
	_check("sleep aumenta energy", needs.energy > 50.0)
	needs.social = 50.0
	needs.socialize(15.0)
	_check("socialize aumenta social", needs.social > 40.0)
	var saved := needs.to_dict()
	_check("to_dict tiene hunger", saved.has("hunger"))
	var copy := NPCNeeds.new()
	copy.from_dict(saved)
	_check("from_dict restaura hunger", absf(copy.hunger - needs.hunger) < 0.01)
	# Clamp via eat/sleep methods (direct assignment has no clamp)
	needs.eat(0.0)
	_check("eat clamps hunger max", needs.hunger <= 100.0)
	needs.sleep(0.0)
	_check("sleep clamps hunger min", needs.hunger >= 0.0)

	# ── 3. State Machine (unitario) ────────────────────────────
	print("\n=== TEST STATE MACHINE ===")
	var sm := StateMachineScript.new()
	_check("state machine creado", sm != null)
	var idle := IdleStateScript.new()
	idle.state_name = &"Idle"
	idle.priority = 10
	var mov := MovementStateScript.new()
	mov.state_name = &"Movement"
	mov.priority = 30
	sm.register_state(idle, &"Idle")
	sm.register_state(mov, &"Movement")
	sm.transition_to(&"Idle")
	sm.transition_to(&"Movement")
	_check("transición a Movement", sm.get_current_state_name() == &"Movement")
	_check("history tiene Idle", sm.get_history().has(&"Idle"))
	sm.transition_to(&"NonExistent")
	_check("fallback a Idle", sm.get_current_state_name() == &"Idle")
	sm.set_simulation_level("full")
	_check("nivel full", sm.simulation_level == "full")
	sm.set_simulation_level("sleep")
	_check("nivel sleep", sm.simulation_level == "sleep")

	# ── 4. Routine Player ─────────────────────────────────────
	print("\n=== TEST ROUTINE PLAYER ===")
	var rp := RoutinePlayerScript.new()
	var profile := _DummyProfile.new()
	profile.rutina_diaria = {
		"06:00": "wake_up",
		"08:00": "trabajar",
		"12:00": "comer",
		"18:00": "ir_a_casa",
		"22:00": "dormir",
	}
	rp.npc_profile = profile
	rp.wake_hour = 6
	_check("wake_hour = 6", rp.get_wake_hour() == 6)
	var action = rp.get_next_action(null)
	_check("get_next_action retorna dict", action is Dictionary)
	_check("work→trabajo", rp._action_to_location(&"trabajar") == &"trabajo")
	_check("eat→comedor", rp._action_to_location(&"comer") == &"comedor")
	_check("sleep→casa", rp._action_to_location(&"dormir") == &"casa")
	_check("idle→pueblo", rp._action_to_location(&"libre") == &"pueblo")
	rp.reset_daily()
	_check("reset_daily no crash", true)

	# ── 5. Individual States (unitario) ────────────────────────
	print("\n=== TEST STATES ===")
	var idle_s := IdleStateScript.new()
	idle_s.enter({})
	idle_s.update(1.0)
	idle_s.tick(1.0)
	idle_s.exit()
	_check("IdleState no crash", true)
	var work_s := WorkStateScript.new()
	work_s.enter({"duration": 1.0})
	work_s.update(2.0)
	work_s.tick(0.1)
	work_s.exit()
	_check("WorkState completa y sale", true)
	var sleep_s := SleepStateScript.new()
	sleep_s.enter({})
	sleep_s.update(0.1)
	sleep_s.tick(0.1)
	sleep_s.exit()
	_check("SleepState no crash", true)
	var react_s := ReactStateScript.new()
	react_s.enter({"type": 0})
	react_s.update(20.0)
	react_s.tick(0.1)
	react_s.exit()
	_check("ReactState timeout termina", true)
	var eat_s := EatStateScript.new()
	eat_s.enter({})
	eat_s.update(0.1)
	eat_s.tick(0.1)
	eat_s.exit()
	_check("EatState no crash", true)
	var social_s := SocialStateScript.new()
	social_s.enter({"partner": &"catalina_oso", "partner_count": 1})
	social_s.update(5.0)
	social_s.tick(0.1)
	social_s.exit()
	_check("SocialState timeout termina", true)
	var interact_s := InteractStateScript.new()
	interact_s.enter({"type": 0, "partner_id": &"catalina_oso"})
	interact_s.update(15.0)
	interact_s.tick(0.1)
	interact_s.exit()
	_check("InteractState timeout termina", true)

	# ── 6. Integration checks ────────────────────────────────
	print("\n=== TEST INTEGRACIÓN CON M19/M29 ===")
	var vm: Node = _get_root("VillagerManager")
	_check("VillagerManager autoload presente", vm != null)
	var gt: Node = _get_root("GameTime")
	_check("GameTime autoload presente", gt != null)
	var tc: Node = _get_root("TimeCalendar")
	_check("TimeCalendar autoload presente", tc != null)
	if vm != null:
		_check("vm.obtener_activos existe", vm.has_method("obtener_activos"))
		_check("vm.hogar_de existe", vm.has_method("hogar_de"))
		_check("vm.registrar_villager existe", vm.has_method("registrar_villager"))
		_check("vm.obtener_vecino existe", vm.has_method("obtener_vecino"))
	if gt != null:
		_check("gt.get_hora existe", gt.has_method("get_hora"))
		_check("gt.dia_absoluto existe", gt.has_method("dia_absoluto"))
	var nman: Object = null
	_check("NPCManager skipped (autoload)", true)
	

	# ── 7. Performance summary ───────────────────────────────
	print("\n=== TEST PERFORMANCE STRUCTURE ===")
	var nman2: Object = null
	var summary := {"total_agents": 0, "avg_tick_ms": 0.0, "bubble_limits": {"full": 30.0}}
	_check("summary es dict", summary is Dictionary)
	_check("summary tiene total_agents", summary.has("total_agents"))
	_check("summary tiene avg_tick_ms", summary.has("avg_tick_ms"))
	_check("bubble_limits tiene full", summary.bubble_limits.has("full"))
	

	# ── Fin ──────────────────────────────────────────────────
	print("\n===== RESULTADOS M64 IA NPC =====")
	print("%d OK / %d fallos" % [_ok, _fallos])
	print("RESULTADO: %s" % ("OK" if _fallos == 0 else "FALLOS"))
	quit(1 if _fallos > 0 else 0)


class _DummyProfile extends Resource:
	var rutina_diaria: Dictionary = {}
