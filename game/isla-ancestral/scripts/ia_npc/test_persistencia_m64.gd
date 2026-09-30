# M64: Test de persistencia — guardar/cargar estado de IA
# Verifica: serialización de NPCNeeds, NPCBlackboard, PlanStack

extends SceneTree

var _passed := 0
var _failed := 0
var _total := 0

func _init() -> void:
	print("=== [M64] Test de Persistencia ===")
	_bloque_a_needs_persist()
	_bloque_b_blackboard_persist()
	_bloque_c_plan_stack_persist()
	_bloque_d_full_roundtrip()
	_resumen()

func _check(desc: String, condition: bool, detail: String = "") -> void:
	_total += 1
	if condition:
		_passed += 1
		print("  [OK] %s" % desc)
	else:
		_failed += 1
		print("  [FAIL] %s %s" % [desc, "(%s)" % detail if detail != "" else ""])

func _fin(bloque: String) -> void:
	print("  --- Fin bloque %s ---\n" % bloque)

func _resumen() -> void:
	print("═══════════════════════════")
	print("=== Resumen Persistencia M64: %d checks, %d fallos ===" % [_total, _failed])
	if _failed == 0:
		print("✅ TODOS LOS TESTS PASARON")
	else:
		print("❌ %d TEST(S) FALLARON" % _failed)
	quit(_failed)


func _bloque_a_needs_persist() -> void:
	print("--- Bloque A: NPCNeeds serialización ---")
	var NeedsScript = preload("res://scripts/ia_npc/npc_needs.gd")
	var needs = NeedsScript.new()
	needs.hunger = 42.0
	needs.energy = 67.0
	needs.social = 33.0
	needs.mood = 88.0

	var data = needs.to_dict()
	_check("A1: to_dict retorna dict", data is Dictionary)
	_check("A2: serializa hunger", data.get("hunger") == 42.0)
	_check("A3: serializa energy", data.get("energy") == 67.0)
	_check("A4: serializa social", data.get("social") == 33.0)
	_check("A5: serializa mood", data.get("mood") == 88.0)

	var needs2 = NeedsScript.new()
	needs2.from_dict(data)
	_check("A6: from_dict crea instancia", needs2 != null)
	_check("A7: hunger restaurado", needs2.hunger == 42.0)
	_check("A8: energy restaurada", needs2.energy == 67.0)
	_check("A9: social restaurada", needs2.social == 33.0)
	_check("A10: mood restaurado", needs2.mood == 88.0)

	_fin("A")


func _bloque_b_blackboard_persist() -> void:
	print("--- Bloque B: NPCBlackboard serialización ---")
	var BBScript = preload("res://scripts/ia_npc/npc_blackboard.gd")
	var bb = BBScript.new()
	bb.set_value("player_pos", Vector3(10, 20, 30))
	bb.set_value("is_raining", true)
	bb.set_value("custom_key", "hello")

	var data = bb.to_dict()
	_check("B1: to_dict retorna dict", data is Dictionary)
	_check("B2: serializa player_pos", data.get("player_pos") == Vector3(10, 20, 30))
	_check("B3: serializa is_raining", data.get("is_raining") == true)
	_check("B4: serializa custom_key", data.get("custom_key") == "hello")

	var bb2 = NPCBlackboard.from_dict(data)
	_check("B5: from_dict crea instancia", bb2 != null)
	_check("B6: player_pos restaurado", bb2.get_value("player_pos") == Vector3(10, 20, 30))
	_check("B7: is_raining restaurado", bb2.get_value("is_raining") == true)
	_check("B8: custom_key restaurado", bb2.get_value("custom_key") == "hello")

	_fin("B")


func _bloque_c_plan_stack_persist() -> void:
	print("--- Bloque C: PlanStack serialización ---")
	var PlanScript = preload("res://scripts/ia_npc/plan_stack.gd")
	var plan = PlanScript.new()
	plan.push_plan(&"Work", {"tool": "axe"}, &"routine")
	plan.push_plan(&"Eat", {"location": "casa"}, &"need")

	var data = plan.to_dict()
	_check("C1: to_dict retorna dict", data is Dictionary)
	_check("C2: serializa plans", data.get("stack", []) is Array)
	_check("C3: serializa 2 planes", data.get("stack", []).size() == 2)

	var plan2 = PlanScript.new()
	plan2.from_dict(data)
	_check("C4: from_dict crea instancia", plan2 != null)
	_check("C5: restaura 2 planes", plan2.size() == 2)
	var top = plan2.peek_current()
	_check("C6: tope es Eat", top.get("state") == &"Eat")
	_check("C7: fondo es Work", plan2.peek_previous().get("state") == &"Work")

	_fin("C")


func _bloque_d_full_roundtrip() -> void:
	print("--- Bloque D: Roundtrip completo ---")
	var SMScript = preload("res://scripts/ia_npc/state_machine.gd")
	var NeedsScript = preload("res://scripts/ia_npc/npc_needs.gd")
	var BBScript = preload("res://scripts/ia_npc/npc_blackboard.gd")
	var PlanScript = preload("res://scripts/ia_npc/plan_stack.gd")

	# Estado original
	var needs = NeedsScript.new()
	needs.hunger = 55.0
	var bb = BBScript.new()
	bb.set_value("mood", "happy")
	var plan = PlanScript.new()
	plan.push_plan(&"Work", {}, &"routine")

	# Serializar todo
	var save_data = {
		"needs": needs.to_dict(),
		"blackboard": bb.to_dict(),
		"plan_stack": plan.to_dict(),
	}

	# Restaurar
	var needs2 = NeedsScript.new()
	needs2.from_dict(save_data.needs)
	var bb2 = BBScript.from_dict(save_data.blackboard)
	var plan2 = PlanScript.new()
	plan2.from_dict(save_data.plan_stack)

	_check("D1: needs roundtrip", needs2.hunger == 55.0)
	_check("D2: blackboard roundtrip", bb2.get_value("mood") == "happy")
	_check("D3: plan_stack roundtrip", plan2.peek_current().get("state") == &"Work")

	# Verificar independencia
	needs2.hunger = 10.0
	_check("D4: copia no afecta original", needs.hunger == 55.0)

	_fin("D")
