extends SceneTree

func _init() -> void:
	var system = load("res://game/isla-ancestral/scripts/enchantment/enchantment_system.gd").new()
	add_child(system)
	_await_frame()

	var passed := 0
	var failed := 0

	# Test 1: catalog loaded
	if system.get_all_enchantments().size() == 4:
		passed += 1
	else:
		failed += 1
		print("FAIL: expected 4 enchantments, got %d" % system.get_all_enchantments().size())

	# Test 2: is_enchanted false initially
	if not system.is_enchanted("pickaxe_1"):
		passed += 1
	else:
		failed += 1
		print("FAIL: tool should not be enchanted initially")

	# Test 3: enchant_tool success
	if system.enchant_tool("pickaxe_1", "ancestral_cobre"):
		passed += 1
	else:
		failed += 1
		print("FAIL: enchant_tool should succeed")

	# Test 4: is_enchanted true after enchant
	if system.is_enchanted("pickaxe_1"):
		passed += 1
	else:
		failed += 1
		print("FAIL: tool should be enchanted after enchant_tool")

	# Test 5: cannot enchant twice
	if not system.enchant_tool("pickaxe_1", "prospero_hierro"):
		passed += 1
	else:
		failed += 1
		print("FAIL: should not enchant already enchanted tool")

	# Test 6: get_active_ability returns data
	var ability = system.get_active_ability("pickaxe_1")
	if ability.has("type") and ability.has("value"):
		passed += 1
	else:
		failed += 1
		print("FAIL: get_active_ability should return data")

	# Test 7: get_sell_bonus returns 0 for non-enchanted
	if system.get_sell_bonus("pickaxe_2") == 0.0:
		passed += 1
	else:
		failed += 1
		print("FAIL: sell bonus should be 0 for non-enchanted tool")

	# Test 8: remove enchantment
	system.remove_enchantment("pickaxe_1")
	if not system.is_enchanted("pickaxe_1"):
		passed += 1
	else:
		failed += 1
		print("FAIL: tool should not be enchanted after remove")

	# Test 9: to_dict/from_dict roundtrip
	var dict = system.to_dict()
	system.from_dict(dict)
	if system.is_enchanted("pickaxe_1"):
		passed += 1
	else:
		failed += 1
		print("FAIL: from_dict should restore enchantment")

	# Test 10: insufficient incense
	system.set_incense(0)
	if not system.enchant_tool("pickaxe_2", "ancestral_cobre"):
		passed += 1
	else:
		failed += 1
		print("FAIL: should not enchant without incense")

	print("PASS: %d / FAIL: %d" % [passed, failed])
	quit(failed)

func _await_frame() -> void:
	await process_frame
