extends "res://addons/gdUnit4/src/GdUnitTestSuite.gd"

## Unit tests para EquipmentManager (M155)
## Verifica la funcionalidad del sistema de vestimenta y accesorios

func test_equipment_manager_ready() -> void:
	var manager = EquipmentManager.new()
	add_child(manager)
	await manager.ready
	assert_that(manager.player_equipment).is_not_null()
	assert_that(manager.catalog).is_not_empty()
	print("[TEST] EquipmentManager inicializado con %d prendas" % manager.catalog.size())

func test_equip_item_head_slot() -> void:
	var manager = EquipmentManager.new()
	add_child(manager)
	await manager.ready

	var result: bool = manager.equip_item("head_hat_fisher", EquipmentSlot.SlotType.HEAD)
	assert_that(result).is_true()
	var slot: EquipmentSlot = manager.get_equipped_item(EquipmentSlot.SlotType.HEAD)
	assert_that(slot).is_not_null()
	assert_that(slot.item_id).is_equal_to("head_hat_fisher")
	assert_that(slot.item_name).is_equal_to("Sombrero de pescador")

func test_equip_item_feet_slot() -> void:
	var manager = EquipmentManager.new()
	add_child(manager)
	await manager.ready

	var result: bool = manager.equip_item("feet_boots_mud", EquipmentSlot.SlotType.FEET)
	assert_that(result).is_true()
	var slot: EquipmentSlot = manager.get_equipped_item(EquipmentSlot.SlotType.FEET)
	assert_that(slot).is_not_null()
	assert_that(slot.item_id).is_equal_to("feet_boots_mud")

func test_equip_wrong_slot_fails() -> void:
	var manager = EquipmentManager.new()
	add_child(manager)
	await manager.ready

	var result: bool = manager.equip_item("head_hat_fisher", EquipmentSlot.SlotType.FEET)
	assert_that(result).is_false()

func test_unequip_slot_returns_item_id() -> void:
	var manager = EquipmentManager.new()
	add_child(manager)
	await manager.ready

	manager.equip_item("head_hat_fisher", EquipmentSlot.SlotType.HEAD)
	var previous_id: String = manager.unequip_slot(EquipmentSlot.SlotType.HEAD)
	assert_that(previous_id).is_equal_to("head_hat_fisher")
	var slot: EquipmentSlot = manager.get_equipped_item(EquipmentSlot.SlotType.HEAD)
	assert_that(slot).is_null()

func test_is_item_equipped_true() -> void:
	var manager = EquipmentManager.new()
	add_child(manager)
	await manager.ready

	manager.equip_item("feet_boots_mud", EquipmentSlot.SlotType.FEET)
	assert_that(manager.is_item_equipped("feet_boots_mud")).is_true()

func test_is_item_equipped_false() -> void:
	var manager = EquipmentManager.new()
	add_child(manager)
	await manager.ready

	assert_that(manager.is_item_equipped("feet_boots_mud")).is_false()

func test_terrain_bonus_grass() -> void:
	var manager = EquipmentManager.new()
	add_child(manager)
	await manager.ready

	manager.equip_item("feet_skates", EquipmentSlot.SlotType.FEET)
	var bonus: float = manager.get_terrain_bonus("grass")
	assert_that(bonus).is_equal(0.90)

func test_terrain_bonus_mud_with_boots() -> void:
	var manager = EquipmentManager.new()
	add_child(manager)
	await manager.ready

	manager.equip_item("feet_boots_mud", EquipmentSlot.SlotType.FEET)
	var bonus: float = manager.get_terrain_bonus("mud")
	assert_that(bonus).is_equal(0.95)

func test_terrain_bonus_mud_with_skates_penalty() -> void:
	var manager = EquipmentManager.new()
	add_child(manager)
	await manager.ready

	manager.equip_item("feet_skates", EquipmentSlot.SlotType.FEET)
	var bonus: float = manager.get_terrain_bonus("mud")
	assert_that(bonus).is_equal(-0.60)

func test_comfort_penalty_head_rain() -> void:
	var manager = EquipmentManager.new()
	add_child(manager)
	await manager.ready

	manager.equip_item("head_hat_fisher", EquipmentSlot.SlotType.HEAD)
	var penalty: float = manager.get_comfort_penalty("rain")
	assert_that(penalty).is_equal(-0.10)

func test_serialize_deserialize() -> void:
	var manager = EquipmentManager.new()
	add_child(manager)
	await manager.ready

	manager.equip_item("feet_boots_mud", EquipmentSlot.SlotType.FEET)
	manager.equip_item("head_hat_fisher", EquipmentSlot.SlotType.HEAD)
	manager.equip_item("body_coat_rain", EquipmentSlot.SlotType.BODY)
	manager.equip_item("acc_backpack", EquipmentSlot.SlotType.ACCESSORY)

	var data: Dictionary = manager.to_dict()
	assert_that(data).is_not_empty()
	assert_that(data.has("feet")).is_true()
	assert_that(data["feet"]["item_id"]).is_equal_to("feet_boots_mud")

	var manager2 = EquipmentManager.new()
	add_child(manager2)
	await manager2.ready
	manager2.from_dict(data)

	assert_that(manager2.is_item_equipped("feet_boots_mud")).is_true()
	assert_that(manager2.is_item_equipped("head_hat_fisher")).is_true()
	assert_that(manager2.is_item_equipped("body_coat_rain")).is_true()
	assert_that(manager2.is_item_equipped("acc_backpack")).is_true()

func test_clear_all_slots() -> void:
 	var manager = EquipmentManager.new()
 	add_child(manager)
 	await manager.ready
 
 	manager.equip_item("feet_boots_mud", EquipmentSlot.SlotType.FEET)
 	manager.equip_item("head_hat_fisher", EquipmentSlot.SlotType.HEAD)
 	manager.player_equipment.clear_all()
 
 	assert_that(manager.is_item_equipped("feet_boots_mud")).is_false()
 	assert_that(manager.is_item_equipped("head_hat_fisher")).is_false()

func test_unlock_condition_none_always_true() -> void:
 	var condition = UnlockCondition.new()
 	condition.tipo = "none"
 	condition.valor = ""
 	var player_state: Dictionary = {}
 	assert_that(condition.is_unlocked(player_state)).is_true()

func test_unlock_condition_chapter() -> void:
 	var condition = UnlockCondition.new()
 	condition.tipo = "chapter"
 	condition.valor = "3"
 	var player_state: Dictionary = {"capitulo_actual": 2}
 	assert_that(condition.is_unlocked(player_state)).is_false()
 	player_state["capitulo_actual"] = 3
 	assert_that(condition.is_unlocked(player_state)).is_true()

func test_is_item_unlocked_without_unlock() -> void:
 	var manager = EquipmentManager.new()
 	add_child(manager)
 	await manager.ready
 
 	var player_state: Dictionary = {}
 	assert_that(manager.is_item_unlocked("head_hat_fisher", player_state)).is_true()

func test_is_item_unlocked_with_chapter_requirement() -> void:
 	var manager = EquipmentManager.new()
 	add_child(manager)
 	await manager.ready
 
 	var player_state: Dictionary = {"capitulo_actual": 2}
 	assert_that(manager.is_item_unlocked("acc_amulet_ancestral", player_state)).is_false()
 	player_state["capitulo_actual"] = 3
 	assert_that(manager.is_item_unlocked("acc_amulet_ancestral", player_state)).is_true()

func test_get_unlocked_items_filters_locked() -> void:
 	var manager = EquipmentManager.new()
 	add_child(manager)
 	await manager.ready
 
 	var player_state: Dictionary = {"capitulo_actual": 1}
 	var unlocked: Array = manager.get_unlocked_items(player_state)
 	assert_that(unlocked).has_not_contains("acc_amulet_ancestral")

func test_flag_unlock_vest_explorer() -> void:
 	# Regresión 2026-09-01 (deepseek-v4-flash-vision-exp): el chaleco explorador
 	# tiene unlock por flag "mochila_mejorada" — sin el flag NO se desbloquea.
 	var manager = EquipmentManager.new()
 	add_child(manager)
 	await manager.ready
 
 	var sin_flag: Dictionary = {}
 	assert_that(manager.is_item_unlocked("body_vest_explorer", sin_flag)).is_false()
 
 	var con_flag: Dictionary = {"flags": {"mochila_mejorada": true}}
 	assert_that(manager.is_item_unlocked("body_vest_explorer", con_flag)).is_true()

func test_catalog_no_duplicates() -> void:
 	# Regresión 2026-09-01: el catálogo tenía body_vest_explorer y acc_backpack
 	# duplicados (Parse Error: Key already used) → se eliminaron las entradas
 	# viejas sin unlock. El catálogo debe tener 16 prendas ÚNICAS.
 	var manager = EquipmentManager.new()
 	add_child(manager)
 	await manager.ready
 
 	assert_that(manager.catalog.size()).is_equal(16)
 	assert_that(manager.catalog.has("body_vest_explorer")).is_true()
 	assert_that(manager.catalog.has("acc_backpack")).is_true()
 	assert_that(manager.catalog["body_vest_explorer"].has("unlock")).is_true()

func test_equip_replaces_same_slot() -> void:
 	# Al equipar otra prenda del MISMO slot, el slot queda con la última.
 	var manager = EquipmentManager.new()
 	add_child(manager)
 	await manager.ready
 
 	manager.equip_item("body_coat_rain", EquipmentSlot.SlotType.BODY)
 	var result: bool = manager.equip_item("body_shirt_casual", EquipmentSlot.SlotType.BODY)
 	assert_that(result).is_true()
 	var slot: EquipmentSlot = manager.get_equipped_item(EquipmentSlot.SlotType.BODY)
 	assert_that(slot).is_not_null()
 	assert_that(slot.item_id).is_equal_to("body_shirt_casual")
