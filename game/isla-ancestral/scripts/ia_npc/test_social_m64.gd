extends SceneTree

var _passed := 0
var _failed := 0
var _total := 0

func _init() -> void:
	print("=== [M64] Test de Social ===")
	_bloque_a_needs()
	_bloque_b_social_select()
	_bloque_c_social_limit()
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
	print("=== Resumen Social M64: %d checks, %d fallos ===" % [_total, _failed])
	if _failed == 0:
		print("✅ TODOS LOS TESTS PASARON")
	else:
		print("❌ %d TEST(S) FALLARON" % _failed)
	quit(_failed)


func _bloque_a_needs() -> void:
	print("--- Bloque A: NPCNeeds ---")
	var NeedsScript = preload("res://scripts/ia_npc/npc_needs.gd")
	var needs = NeedsScript.new()

	_check("A1: hunger inicial 100", needs.hunger == 100.0)
	_check("A2: energy inicial 100", needs.energy == 100.0)
	_check("A3: social inicial 50", needs.social == 50.0)
	_check("A4: mood inicial 75", needs.mood == 75.0)

	needs.update(10.0)
	_check("A5: hunger decrementa (95)", needs.hunger == 95.0)
	_check("A6: energy decrementa (97)", needs.energy == 97.0)

	needs.eat()
	_check("A7: eat incrementa hunger", needs.hunger > 95.0)
	needs.sleep()
	_check("A8: sleep incrementa energy", needs.energy > 97.0)
	needs.socialize()
	_check("A9: socialize incrementa social", needs.social > 50.0)

	var ConfigScript = preload("res://scripts/ia_npc/npc_needs_config.gd")
	var cfg = ConfigScript.new()
	cfg.hunger_rate = 1.0
	var needs2 = NeedsScript.new()
	needs2.set_config(cfg)
	needs2.update(10.0)
	_check("A10: config sobreescribe hunger_rate", needs2.hunger == 90.0)

	_fin("A")


func _bloque_b_social_select() -> void:
	print("--- Bloque B: Selectividad Social ---")
	var AgentScript = preload("res://scripts/ia_npc/npc_agent.gd")
	var agent = AgentScript.new()
	agent.name = "TestSocialAgent"
	get_root().add_child(agent)

	var result = agent._select_social_partner([])
	_check("B1: partner vacío → empty", result == &"")

	result = agent._select_social_partner([&"NPC1"])
	_check("B2: un partner → NPC1", result == &"NPC1")

	agent.queue_free()
	_fin("B")


func _bloque_c_social_limit() -> void:
	print("--- Bloque C: Límite Social ---")
	var AgentScript = preload("res://scripts/ia_npc/npc_agent.gd")
	_check("C1: MAX_SIMULTANEOUS_SOCIALS es 3", AgentScript.MAX_SIMULTANEOUS_SOCIALS == 3)
	_check("C2: SEPARATION_RADIUS es 1.5", AgentScript.SEPARATION_RADIUS == 1.5)
	_fin("C")
