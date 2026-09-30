# Modelo: mimo-v2.5
# Plataforma: OpenCode
# Fecha: 2026-09-18
#
# M64: IA de NPC — Test headless iter. N
# Cubre: PlanStack, Watchdog, Needs, Blackboard, FSM, integración.
#
# DOS redes de seguridad contra el falso verde / el cuelgue:
#   1. Marcador `_fin("X")` al final de cada bloque.
#   2. Watchdog en `_process`: si `_run()` no terminó en FRAMES_MAX, exit 1.

extends SceneTree

const FRAMES_MAX := 300

const _SC_PLAN_STACK := preload("res://scripts/ia_npc/plan_stack.gd")
const _SC_WATCHDOG := preload("res://scripts/ia_npc/npc_watchdog.gd")
const _SC_NEEDS := preload("res://scripts/ia_npc/npc_needs.gd")
const _SC_BLACKBOARD := preload("res://scripts/ia_npc/npc_blackboard.gd")
const _SC_STATE_MACHINE := preload("res://scripts/ia_npc/state_machine.gd")
const _SC_BASE_STATE := preload("res://scripts/ia_npc/states/base_state.gd")

const BLOQUES := ["A", "B", "C", "D", "E", "F"]
var _fallos: int = 0
var _checks: int = 0
var _vistos: Dictionary = {}
var _frames: int = 0
var _terminado: bool = false
var _urgent_fired_flag: bool = false
var _stuck_fired_flag: bool = false
var _recovery_fired_flag: bool = false


func _init() -> void:
	call_deferred("_run")


func _process(_delta: float) -> bool:
	_frames += 1
	if not _terminado and _frames > FRAMES_MAX:
		_checks += 1
		_fallos += 1
		_terminado = true
		print("!! WATCHDOG: _run() no terminó en %d frames (posible SCRIPT ERROR)" % FRAMES_MAX)
		print("=== Resumen M64: %d checks, %d fallos ===" % [_checks, _fallos])
		quit(1)
	return false


func _run() -> void:
	print("=== [M64] Test de IA de NPC (iter. N) ===")
	_bloque_a_plan_stack()
	_bloque_b_watchdog()
	_bloque_c_needs()
	_bloque_d_blackboard()
	_bloque_e_fsm()
	_bloque_f_integracion()
	_verificar_marcadores()
	_terminado = true
	_summary()


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])


func _fin(nombre: String) -> void:
	_vistos[nombre] = true


# ════════════════════════════════════════════════════════════
# A — PlanStack
# ════════════════════════════════════════════════════════════

func _bloque_a_plan_stack() -> void:
	print("\n--- Bloque A: PlanStack ---")
	var ps = _SC_PLAN_STACK.new()

	_check("A1: stack inicia vacío", ps.is_empty())
	_check("A2: size inicial es 0", ps.size() == 0)
	_check("A3: peek_current vacío", ps.peek_current().is_empty())

	# Push
	ps.push_plan(&"Work", {"duration": 300.0}, &"routine")
	_check("A4: después de push, size=1", ps.size() == 1)
	_check("A5: peek_current retorna Work", ps.peek_current().get("state") == &"Work")
	_check("A6: peek_previous vacío (solo 1 elemento)", ps.peek_previous().is_empty())

	# Push segundo plan
	ps.push_plan(&"Eat", {}, &"need_hunger")
	_check("A7: después de 2do push, size=2", ps.size() == 2)
	_check("A8: peek_current retorna Eat", ps.peek_current().get("state") == &"Eat")
	_check("A9: peek_previous retorna Work", ps.peek_previous().get("state") == &"Work")

	# Pop
	var popped: Dictionary = ps.pop_plan()
	_check("A10: pop retorna Eat", popped.get("state") == &"Eat")
	_check("A11: después de pop, size=1", ps.size() == 1)
	_check("A12: peek_current recuperó Work", ps.peek_current().get("state") == &"Work")

	# Clear
	ps.push_plan(&"Social", {}, &"test")
	ps.push_plan(&"Sleep", {}, &"test")
	ps.clear()
	_check("A13: después de clear, vacío", ps.is_empty())
	_check("A14: peek tras clear vacío", ps.peek_current().is_empty())

	# Serialización
	ps.push_plan(&"Work", {"d": 1}, &"s1")
	ps.push_plan(&"Eat", {"d": 2}, &"s2")
	var data: Dictionary = ps.to_dict()
	var ps2 = _SC_PLAN_STACK.new()
	ps2.from_dict(data)
	_check("A15: deserialización preserva size", ps2.size() == 2)
	_check("A16: deserializa Work en fondo", ps2.get_at(0).get("state") == &"Work")
	_check("A17: deserializa Eat en tope", ps2.get_at(1).get("state") == &"Eat")

	# has_state
	_check("A18: has_state Work true", ps.has_state(&"Work"))
	_check("A19: has_state React false", not ps.has_state(&"React"))

	# Profundidad máxima
	for i in range(10):
		ps.push_plan(&"Test", {"i": i}, &"overflow")
	_check("A20: profundidad manejada (<=8)", ps.size() <= 8)

	_fin("A")


# ════════════════════════════════════════════════════════════
# B — Watchdog
# ════════════════════════════════════════════════════════════

func _bloque_b_watchdog() -> void:
	print("\n--- Bloque B: Watchdog ---")
	var wd = _SC_WATCHDOG.new()

	_check("B1: register crea entrada", not wd.is_npc_registered(&"npc_test"))
	wd.register_npc(&"npc_test")
	_check("B2: register funciona", wd.is_npc_registered(&"npc_test"))

	# State change
	wd.on_state_changed(&"npc_test", &"Idle")
	var info: Dictionary = wd.get_npc_state_info(&"npc_test")
	_check("B3: estado inicial es Idle", info.get("state") == &"Idle")
	_check("B4: timer reiniciado", info.get("timer", -1.0) < 0.1)

	# Transiciones múltiples
	wd.on_state_changed(&"npc_test", &"Movement")
	wd.on_state_changed(&"npc_test", &"Work")
	info = wd.get_npc_state_info(&"npc_test")
	_check("B5: último estado es Work", info.get("state") == &"Work")

	# Bucle de transiciones
	for i in range(12):
		wd.on_state_changed(&"npc_test", &"Idle" if i % 2 == 0 else &"Movement")
	_check("B6: sin crash por bucle de transiciones", true)

	# Unregister
	wd.unregister_npc(&"npc_test")
	_check("B7: unregister elimina", not wd.is_npc_registered(&"npc_test"))

	# Señales
	_stuck_fired_flag = false
	_recovery_fired_flag = false
	wd.stuck_detected.connect(_on_stuck)
	wd.recovery_forced.connect(_on_recovery)
	wd.register_npc(&"npc_sig")
	wd.on_state_changed(&"npc_sig", &"Movement")
	# Simular timeout (forzar timer manualmente y llamar check directamente)
	var ns = wd.get_npc_state_info(&"npc_sig")
	ns["timer"] = 35.0  # Mayor que TIMEOUTS.Movement (30s)
	wd._check_npc(&"npc_sig", 0.0)
	_check("B8: stuck_detected emitido", _stuck_fired_flag)
	_check("B9: recovery_forced emitido", _recovery_fired_flag)

	wd.unregister_npc(&"npc_sig")
	_fin("B")


# ════════════════════════════════════════════════════════════
# C — Needs
# ════════════════════════════════════════════════════════════

func _bloque_c_needs() -> void:
	print("\n--- Bloque C: NPCNeeds ---")
	var n = _SC_NEEDS.new()

	_check("C1: hunger inicial 100", n.hunger == 100.0)
	_check("C2: energy inicial 100", n.energy == 100.0)
	_check("C3: social inicial 50", n.social == 50.0)
	_check("C4: mood inicial 75", n.mood == 75.0)

	# Update decrementa
	n.update(10.0)
	_check("C5: hunger decrementa (95)", n.hunger < 100.0)
	_check("C6: energy decrementa (97)", n.energy < 100.0)
	_check("C7: social decrementa (49)", n.social < 50.0)

	# Urgencia
	n.hunger = 15.0
	var urgent: StringName = n.get_urgent_need()
	_check("C8: hunger urgente", urgent == &"hunger")

	n.hunger = 100.0
	n.energy = 10.0
	urgent = n.get_urgent_need()
	_check("C9: energy urgente", urgent == &"energy")

	n.energy = 100.0
	n.social = 10.0
	urgent = n.get_urgent_need()
	_check("C10: social urgente", urgent == &"social")

	# Eat/sleep/socialize
	n.hunger = 50.0
	n.eat(30.0)
	_check("C11: eat incrementa hunger", n.hunger == 80.0)

	n.energy = 50.0
	n.sleep(40.0)
	_check("C12: sleep incrementa energy", n.energy == 90.0)

	n.social = 30.0
	n.socialize(20.0)
	_check("C13: socialize incrementa social", n.social == 50.0)

	# Serialización
	var data: Dictionary = n.to_dict()
	var n2 = _SC_NEEDS.new()
	n2.from_dict(data)
	_check("C14: serialización preserva hunger", n2.hunger == n.hunger)
	_check("C15: serialización preserva energy", n2.energy == n.energy)

	# duplicate
	var n3: = n.duplicate_needs()
	_check("C16: duplicate crea copia independiente", n3.hunger == n.hunger)
	n3.hunger = 0.0
	_check("C17: copia no afecta original", n.hunger != 0.0)

	# Señal need_urgent
	_urgent_fired_flag = false
	n.hunger = 100.0
	n.need_urgent.connect(_on_need_urgent)
	n.hunger = 5.0
	n._check_urgent()
	_check("C18: need_urgent emitido", _urgent_fired_flag)

	_fin("C")


# ════════════════════════════════════════════════════════════
# D — Blackboard
# ════════════════════════════════════════════════════════════

func _bloque_d_blackboard() -> void:
	print("\n--- Bloque D: NPCBlackboard ---")
	var bb = _SC_BLACKBOARD.new()

	_check("D1: inicia vacío", bb.data.is_empty())

	# Set/get
	bb.set_value("test_key", 42)
	_check("D2: set/get funciona", bb.get_value("test_key") == 42)
	_check("D3: has_value funciona", bb.has_value(&"test_key"))
	_check("D4: get default", bb.get_value(&"missing", "default") == "default")

	# Helpers
	bb.set_value("is_raining", true)
	bb.set_value("is_storming", false)
	bb.set_value("is_night", true)
	bb.set_value("player_position", Vector3(1, 2, 3))
	bb.set_value("current_event", &"festival")
	bb.set_value("event_active", true)
	bb.set_value("needs_urgent", &"hunger")

	_check("D5: is_raining()", bb.is_raining())
	_check("D6: is_storming() false", not bb.is_storming())
	_check("D7: is_night()", bb.is_night())
	_check("D8: get_player_position", bb.get_player_position() == Vector3(1, 2, 3))
	_check("D9: get_current_event", bb.get_current_event() == &"festival")
	_check("D10: has_active_event", bb.has_active_event())
	_check("D11: get_urgent_need", bb.get_urgent_need() == &"hunger")

	# Clear
	bb.clear()
	_check("D12: clear funciona", bb.data.is_empty())

	# Serialización
	bb.set_value("key1", "val1")
	bb.set_value("key2", 100)
	var data: Dictionary = bb.to_dict()
	var bb2 = _SC_BLACKBOARD.from_dict(data)
	_check("D13: from_dict crea blackboard", bb2 != null)
	_check("D14: serializa key1", bb2.get_value("key1") == "val1")
	_check("D15: serializa key2", bb2.get_value("key2") == 100)

	_fin("D")


# ════════════════════════════════════════════════════════════
# E — FSM (State Machine)
# ════════════════════════════════════════════════════════════

func _bloque_e_fsm() -> void:
	print("\n--- Bloque E: FSM ---")
	var sm = NPCStateMachine.new()
	sm.plan_stack = preload("res://scripts/ia_npc/plan_stack.gd").new()

	# Crear estados mock (base_state.gd no tiene class_name, usar Node+set_script)
	var idle_node := Node.new()
	idle_node.set_script(_SC_BASE_STATE)
	idle_node.state_name = &"Idle"
	var work_node := Node.new()
	work_node.set_script(_SC_BASE_STATE)
	work_node.state_name = &"Work"

	sm.register_state(idle_node, &"Idle", 10)
	sm.register_state(work_node, &"Work", 20)

	_check("E1: plan_stack no null", sm.plan_stack != null)
	_check("E2: plan_stack inicia vacío", sm.plan_stack.is_empty())

	# Transición a Work
	sm.transition_to(&"Work", {"test": true})
	_check("E3: estado actual es Work", sm.get_current_state_name() == &"Work")
	_check("E4: plan_stack tiene 1 plan", sm.plan_stack.size() == 1)

	# Transición a Idle (fallback) → pop plan
	sm.transition_to(&"Idle")
	_check("E5: fallback a Idle", sm.get_current_state_name() == &"Idle")

	# Historial
	var hist: Array = sm.get_history()
	_check("E6: historial tiene entradas", hist.size() > 0)

	# Recovery
	sm.transition_to(&"Work", {"test": 2})
	sm.transition_to(&"Eat", {"test": 3})  # Eat no existe → fallback → pop Work
	_check("E7: tras Eat (fallback), stack vacío", sm.plan_stack.is_empty())
	sm.transition_to(&"Idle")  # Idle es actual → push Idle (no es fallback)
	_check("E8: tras Idle sobre Idle, stack tiene 1 plan", sm.plan_stack.size() == 1)

	# clear_plans
	sm.clear_plans()
	_check("E9: clear_plans funciona", sm.plan_stack.is_empty())

	# set_simulation_level
	sm.transition_to(&"Work")
	sm.set_simulation_level("sleep")
	_check("E10: sleep fuerza transición a Idle", sm.get_current_state_name() == &"Idle")

	# Fallback a Idle inexistente no crashea
	var sm2 = _SC_STATE_MACHINE.new()
	sm2.transition_to(&"NonExistent")
	_check("E11: fallback seguro con estado inexistente", sm2.get_current_state_name() == &"Idle" or sm2.get_current_state_name() == &"None")

	_fin("E")


# ════════════════════════════════════════════════════════════
# F — Integración (rutinas, perfiles)
# ════════════════════════════════════════════════════════════

func _bloque_f_integracion() -> void:
	print("\n--- Bloque F: Integración ---")

	# Verificar que los 6 perfiles existen y tienen rutina
	var perfiles := [
		"res://data/villagers/catalina_oso.tres",
		"res://data/villagers/finneas_zorro.tres",
		"res://data/villagers/mateo_mapache.tres",
		"res://data/villagers/luna_zorra.tres",
		"res://data/villagers/bruno_sapo.tres",
		"res://data/villagers/mercedes_lince.tres",
	]
	var perfiles_con_rutina := 0
	for ruta in perfiles:
		if ResourceLoader.exists(ruta):
			var res = load(ruta)
			if res != null and res.get("rutina_diaria") != null:
				var rutina: Dictionary = res.rutina_diaria
				if rutina.size() > 0:
					perfiles_con_rutina += 1
					var perfil_id: String = str(res.get("id")) if res.get("id") != null else "?"
					_check("F%d: %s tiene rutina (%d slots)" % [
						perfiles_con_rutina, perfil_id, rutina.size()
					], true)
	_check("F7: 6 perfiles con rutina", perfiles_con_rutina == 6)

	# Verificar scripts IA NPC existen
	var scripts := [
		"res://scripts/ia_npc/npc_agent.gd",
		"res://scripts/ia_npc/npc_manager.gd",
		"res://scripts/ia_npc/npc_needs.gd",
		"res://scripts/ia_npc/npc_blackboard.gd",
		"res://scripts/ia_npc/state_machine.gd",
		"res://scripts/ia_npc/plan_stack.gd",
		"res://scripts/ia_npc/npc_watchdog.gd",
	]
	var scripts_ok := 0
	for s in scripts:
		if ResourceLoader.exists(s):
			scripts_ok += 1
	_check("F8: todos los scripts IA existen (%d/%d)" % [scripts_ok, scripts.size()], scripts_ok == scripts.size())

	# Verificar estados existen
	var states := [
		"res://scripts/ia_npc/states/base_state.gd",
		"res://scripts/ia_npc/states/idle_state.gd",
		"res://scripts/ia_npc/states/movement_state.gd",
		"res://scripts/ia_npc/states/work_state.gd",
		"res://scripts/ia_npc/states/social_state.gd",
		"res://scripts/ia_npc/states/eat_state.gd",
		"res://scripts/ia_npc/states/sleep_state.gd",
		"res://scripts/ia_npc/states/react_state.gd",
		"res://scripts/ia_npc/states/interact_state.gd",
	]
	var states_ok := 0
	for s in states:
		if ResourceLoader.exists(s):
			states_ok += 1
	_check("F9: todos los estados existen (%d/%d)" % [states_ok, states.size()], states_ok == states.size())

	_fin("F")


# ════════════════════════════════════════════════════════════
# Resumen
# ════════════════════════════════════════════════════════════

func _verificar_marcadores() -> void:
	var faltantes: Array[String] = []
	for b in BLOQUES:
		if not _vistos.has(b):
			faltantes.append(b)
	if faltantes.size() > 0:
		_fallos += 1
		print("!! MARCADORES FALTANTES: %s (bloque(s) abortado(s) por SCRIPT ERROR)" % str(faltantes))


func _summary() -> void:
	print("\n═══════════════════════════════════════════")
	print("=== Resumen M64: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos == 0:
		print("✅ TODOS LOS TESTS PASARON")
	else:
		print("❌ %d TEST(S) FALLARON" % _fallos)
	quit(_fallos)


func _on_need_urgent(_need: StringName) -> void:
	_urgent_fired_flag = true


func _on_stuck(_id: StringName, _state: StringName, _time: float) -> void:
	_stuck_fired_flag = true


func _on_recovery(_id: StringName, _action: StringName) -> void:
	_recovery_fired_flag = true
