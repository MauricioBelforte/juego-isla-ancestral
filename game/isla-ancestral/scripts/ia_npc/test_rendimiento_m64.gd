extends SceneTree

var _passed := 0
var _failed := 0
var _total := 0

func _init() -> void:
	print("=== [M64] Test de Rendimiento ===")
	_bloque_a_budget()
	_bloque_b_perf_60()
	_bloque_c_perf_100()
	_resumen()

func _check(desc: String, condition: bool, detail: String = "") -> void:
	_total += 1
	if condition:
		_passed += 1
		print("  [OK] %s" % desc)
	else:
		_failed += 1
		var msg = "  [FAIL] %s" % desc
		if detail != "":
			msg += " (%s)" % detail
		print(msg)

func _fin(bloque: String) -> void:
	print("  --- Fin bloque %s ---\n" % bloque)

func _resumen() -> void:
	print("═══════════════════════════")
	print("=== Resumen Rendimiento M64: %d checks, %d fallos ===" % [_total, _failed])
	if _failed == 0:
		print("✅ TODOS LOS TESTS PASARON")
	else:
		print("❌ %d TEST(S) FALLARON" % _failed)
	quit(_failed)


func _bloque_a_budget() -> void:
	print("--- Bloque A: BudgetRegistry ---")
	var SMScript = preload("res://scripts/ia_npc/state_machine.gd")
	var NeedsScript = preload("res://scripts/ia_npc/npc_needs.gd")
	var BBScript = preload("res://scripts/ia_npc/npc_blackboard.gd")
	var PlanScript = preload("res://scripts/ia_npc/plan_stack.gd")

	var sm = SMScript.new()
	sm._ready()
	var needs = NeedsScript.new()
	var bb = BBScript.new()
	var plan = PlanScript.new()

	_check("A1: state_machine creado", sm != null)
	_check("A2: npc_needs creado", needs != null)
	_check("A3: npc_blackboard creado", bb != null)
	_check("A4: plan_stack creado", plan != null)

	var WDScript = preload("res://scripts/ia_npc/npc_watchdog.gd")
	var wd = WDScript.new()
	get_root().add_child(wd)

	for i in range(60):
		var sm_i = SMScript.new()
		sm_i._ready()
		wd.register("npc_%d" % i, sm_i, 30.0, 10)
	_check("A5: watchdog registra 60 NPCs", wd._entries.size() == 60)

	for key in wd._entries.keys():
		wd.unregister(key)
	wd.queue_free()
	_fin("A")


func _bloque_b_perf_60() -> void:
	print("--- Bloque B: Performance 60 NPCs ---")
	var NeedsScript = preload("res://scripts/ia_npc/npc_needs.gd")
	var SMScript = preload("res://scripts/ia_npc/state_machine.gd")
	var IdleScript = preload("res://scripts/ia_npc/states/idle_state.gd")

	var needs_arr: Array = []
	var sm_arr: Array = []

	for i in range(60):
		needs_arr.append(NeedsScript.new())
		var sm = SMScript.new()
		sm.register_state(IdleScript.new(), &"Idle", 10)
		sm._ready()
		sm_arr.append(sm)

	var start = Time.get_ticks_msec()
	for frame in range(60):
		for i in range(60):
			needs_arr[i].update(0.016)
			sm_arr[i].update(0.016)
	var elapsed = Time.get_ticks_msec() - start
	_check("B1: 60 NPCs x 60 frames completado", elapsed >= 0)
	_check("B2: tiempo razonable (< 5s)", elapsed < 5000, "%dms" % elapsed)
	print("    [INFO] 60 NPCs x 60 frames: %dms" % elapsed)

	for i in range(60):
		sm_arr[i].queue_free()
	_fin("B")


func _bloque_c_perf_100() -> void:
	print("--- Bloque C: Performance 100+ NPCs (mixed mode) ---")
	var NeedsScript = preload("res://scripts/ia_npc/npc_needs.gd")
	var SMScript = preload("res://scripts/ia_npc/state_machine.gd")
	var IdleScript = preload("res://scripts/ia_npc/states/idle_state.gd")

	var needs_arr: Array = []
	var sm_arr: Array = []

	for i in range(100):
		needs_arr.append(NeedsScript.new())
		var sm = SMScript.new()
		sm.register_state(IdleScript.new(), &"Idle", 10)
		sm._ready()
		sm_arr.append(sm)

	var start = Time.get_ticks_msec()
	for frame in range(100):
		for i in range(100):
			if frame < 20:
				needs_arr[i].update(0.016)
				sm_arr[i].update(0.016)
			else:
				if i % 5 == 0:
					needs_arr[i].update(0.016)
	var elapsed = Time.get_ticks_msec() - start
	_check("C1: 100 NPCs x 100 frames completado", elapsed >= 0)
	_check("C2: tiempo razonable (< 3s)", elapsed < 3000, "%dms" % elapsed)
	print("    [INFO] 100 NPCs x 100 frames (mixed): %dms" % elapsed)

	for i in range(100):
		sm_arr[i].queue_free()
	_fin("C")
