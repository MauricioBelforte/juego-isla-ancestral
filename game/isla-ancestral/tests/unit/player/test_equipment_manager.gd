# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-04
#
# Unit tests EquipmentManager
#
# CONVERTIDO de gdUnit4 a headless (BUG-093, sub-frente) por convertir.py.
# Motivo: la suite gdUnit4 PARSEABA pero MORIA en runtime (metodos
# inexistentes: is_equal_to/is_greater_than/is_instance_of/has_not_contains/
# has_any_item -> 0 apariciones en addons/gdUnit4/). Ademas las suites gdUnit4
# NO se ejecutan en el CI del proyecto (solo `--script`, estandar 12.1).
#
# Guardia anti-falso-verde (3 capas): _fin() por bloque + CHECKS_MINIMOS
# MEDIDO + _summary() en call_deferred SEPARADO + watchdog.
#
# Fix 2026-10-08 (DeepSeek-V4.1-Flash, Log 1484): `await <nodo>.ready` tras
# `root.add_child()` COLGABA la suite. Causa medida: add_child ya deja el nodo
# listo de forma SINCRONA (is_node_ready()==true), asi que el await posterior
# esperaba una re-emision que nunca llega. Reemplazado por `await process_frame`
# (idioma del proyecto). Antes la suite corria 0 checks y el watchdog la abortaba.
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral --script res://tests/unit/player/test_equipment_manager.gd

extends SceneTree

const TIMEOUT_SEG := 60.0
## Piso MEDIDO (corrida 2026-10-08, Log 1484: 35 checks, 13 fallos). La suite esta
## ROJA: los bloques B/C/L/U abortan por un SCRIPT ERROR del SUT de M155
## (get_equipped_item devuelve Nil/Dictionary y el test espera un EquipmentSlot).
## El piso es un LIMITE INFERIOR: al arreglar el SUT el conteo SUBE, no baja.
const CHECKS_MINIMOS := 35
const EQ_SCRIPT := preload("res://scripts/player/equipment_manager.gd")
const BLOQUES_ESPERADOS: Array[String] = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U']


## Unit tests para EquipmentManager (M155)
## Verifica la funcionalidad del sistema de vestimenta y accesorios


var _fallos: int = 0
var _checks: int = 0
var _bloque: String = "(inicio)"
var _abortado: bool = false
var _completados: Array[String] = []
var _checks_por_bloque: Dictionary = {}
var _checks_marca: int = 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	create_timer(TIMEOUT_SEG, true).timeout.connect(_on_watchdog)
	print("=== Unit tests EquipmentManager (headless) ===")
	await _bloque_A()
	await _bloque_B()
	await _bloque_C()
	await _bloque_D()
	await _bloque_E()
	await _bloque_F()
	await _bloque_G()
	await _bloque_H()
	await _bloque_I()
	await _bloque_J()
	await _bloque_K()
	await _bloque_L()
	await _bloque_M()
	_bloque_N()
	_bloque_O()
	await _bloque_P()
	await _bloque_Q()
	await _bloque_R()
	await _bloque_S()
	await _bloque_T()
	await _bloque_U()
	_summary()


func _on_watchdog() -> void:
	_abortado = true
	print("WATCHDOG: la suite no termino en %.0f s (ultimo bloque: %s)" % [TIMEOUT_SEG, _bloque])
	quit(1)


func _ini(nombre: String) -> void:
	_bloque = nombre
	_checks_marca = _checks
	print("\n-- %s --" % nombre)


func _fin(nombre: String) -> void:
	var letra: String = nombre.substr(0, 1)
	if not _completados.has(letra):
		_completados.append(letra)
	var delta: int = _checks - _checks_marca
	_checks_por_bloque[letra] = int(_checks_por_bloque.get(letra, 0)) + delta
	_checks_marca = _checks
	print("[FIN] %s (+%d checks)" % [nombre, delta])


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])


func _summary() -> void:
	var faltantes: Array[String] = []
	for letra in BLOQUES_ESPERADOS:
		if not _completados.has(letra):
			faltantes.append(letra)
	_check("todos los bloques se completaron (sin abortos silenciosos)", faltantes.is_empty(),
		"bloques que no terminaron: %s" % str(faltantes))
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("  [FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("Checks por bloque: %s" % str(_checks_por_bloque))
	print("\n=== Resumen Unit tests EquipmentManager: %d checks, %d fallos ===" % [_checks, _fallos])
	if _abortado:
		quit(1)
	elif _fallos == 0:
		print("TEST OK — todos los checks pasaron")
		quit(0)
	else:
		print("TEST FALLO — %d checks fallaron" % _fallos)
		quit(1)


func _bloque_A() -> void:
	_ini("A. test_equipment_manager_ready")
	var manager = EQ_SCRIPT.new()
	root.add_child(manager)
	await process_frame
	_check("manager.player_equipment .is_not_null()", (manager.player_equipment) != null)
	_check("manager.catalog .is_not_empty()", not (manager.catalog).is_empty())
	print("[TEST] EquipmentManager inicializado con %d prendas" % manager.catalog.size())

	_fin("A. test_equipment_manager_ready")


func _bloque_B() -> void:
	_ini("B. test_equip_item_head_slot")
	var manager = EQ_SCRIPT.new()
	root.add_child(manager)
	await process_frame

	var result: bool = manager.equip_item("head_hat_fisher", EquipmentSlot.SlotType.HEAD)
	_check("result .is_true()", (result) == true)
	var slot: EquipmentSlot = manager.get_equipped_item(EquipmentSlot.SlotType.HEAD)
	_check("slot .is_not_null()", (slot) != null)
	_check("slot.item_id .is_equal_to(\"head_hat_fisher\")", (slot.item_id) == ("head_hat_fisher"))
	_check("slot.item_name .is_equal_to(\"Sombrero de pescador\")", (slot.item_name) == ("Sombrero de pescador"))

	_fin("B. test_equip_item_head_slot")


func _bloque_C() -> void:
	_ini("C. test_equip_item_feet_slot")
	var manager = EQ_SCRIPT.new()
	root.add_child(manager)
	await process_frame

	var result: bool = manager.equip_item("feet_boots_mud", EquipmentSlot.SlotType.FEET)
	_check("result .is_true()", (result) == true)
	var slot: EquipmentSlot = manager.get_equipped_item(EquipmentSlot.SlotType.FEET)
	_check("slot .is_not_null()", (slot) != null)
	_check("slot.item_id .is_equal_to(\"feet_boots_mud\")", (slot.item_id) == ("feet_boots_mud"))

	_fin("C. test_equip_item_feet_slot")


func _bloque_D() -> void:
	_ini("D. test_equip_wrong_slot_fails")
	var manager = EQ_SCRIPT.new()
	root.add_child(manager)
	await process_frame

	var result: bool = manager.equip_item("head_hat_fisher", EquipmentSlot.SlotType.FEET)
	_check("result .is_false()", (result) == false)

	_fin("D. test_equip_wrong_slot_fails")


func _bloque_E() -> void:
	_ini("E. test_unequip_slot_returns_item_id")
	var manager = EQ_SCRIPT.new()
	root.add_child(manager)
	await process_frame

	manager.equip_item("head_hat_fisher", EquipmentSlot.SlotType.HEAD)
	var previous_id: String = manager.unequip_slot(EquipmentSlot.SlotType.HEAD)
	_check("previous_id .is_equal_to(\"head_hat_fisher\")", (previous_id) == ("head_hat_fisher"))
	var slot: EquipmentSlot = manager.get_equipped_item(EquipmentSlot.SlotType.HEAD)
	_check("slot .is_null()", (slot) == null)

	_fin("E. test_unequip_slot_returns_item_id")


func _bloque_F() -> void:
	_ini("F. test_is_item_equipped_true")
	var manager = EQ_SCRIPT.new()
	root.add_child(manager)
	await process_frame

	manager.equip_item("feet_boots_mud", EquipmentSlot.SlotType.FEET)
	_check("manager.is_item_equipped(\"feet_boots_mud\") .is_true()", (manager.is_item_equipped("feet_boots_mud")) == true)

	_fin("F. test_is_item_equipped_true")


func _bloque_G() -> void:
	_ini("G. test_is_item_equipped_false")
	var manager = EQ_SCRIPT.new()
	root.add_child(manager)
	await process_frame

	_check("manager.is_item_equipped(\"feet_boots_mud\") .is_false()", (manager.is_item_equipped("feet_boots_mud")) == false)

	_fin("G. test_is_item_equipped_false")


func _bloque_H() -> void:
	_ini("H. test_terrain_bonus_grass")
	var manager = EQ_SCRIPT.new()
	root.add_child(manager)
	await process_frame

	manager.equip_item("feet_skates", EquipmentSlot.SlotType.FEET)
	var bonus: float = manager.get_terrain_bonus("grass")
	_check("bonus .is_equal(0.90)", (bonus) == (0.90))

	_fin("H. test_terrain_bonus_grass")


func _bloque_I() -> void:
	_ini("I. test_terrain_bonus_mud_with_boots")
	var manager = EQ_SCRIPT.new()
	root.add_child(manager)
	await process_frame

	manager.equip_item("feet_boots_mud", EquipmentSlot.SlotType.FEET)
	var bonus: float = manager.get_terrain_bonus("mud")
	_check("bonus .is_equal(0.95)", (bonus) == (0.95))

	_fin("I. test_terrain_bonus_mud_with_boots")


func _bloque_J() -> void:
	_ini("J. test_terrain_bonus_mud_with_skates_penalty")
	var manager = EQ_SCRIPT.new()
	root.add_child(manager)
	await process_frame

	manager.equip_item("feet_skates", EquipmentSlot.SlotType.FEET)
	var bonus: float = manager.get_terrain_bonus("mud")
	_check("bonus .is_equal(-0.60)", (bonus) == (-0.60))

	_fin("J. test_terrain_bonus_mud_with_skates_penalty")


func _bloque_K() -> void:
	_ini("K. test_comfort_penalty_head_rain")
	var manager = EQ_SCRIPT.new()
	root.add_child(manager)
	await process_frame

	manager.equip_item("head_hat_fisher", EquipmentSlot.SlotType.HEAD)
	var penalty: float = manager.get_comfort_penalty("rain")
	_check("penalty .is_equal(-0.10)", (penalty) == (-0.10))

	_fin("K. test_comfort_penalty_head_rain")


func _bloque_L() -> void:
	_ini("L. test_serialize_deserialize")
	var manager = EQ_SCRIPT.new()
	root.add_child(manager)
	await process_frame

	manager.equip_item("feet_boots_mud", EquipmentSlot.SlotType.FEET)
	manager.equip_item("head_hat_fisher", EquipmentSlot.SlotType.HEAD)
	manager.equip_item("body_coat_rain", EquipmentSlot.SlotType.BODY)
	manager.equip_item("acc_backpack", EquipmentSlot.SlotType.ACCESSORY)

	var data: Dictionary = manager.to_dict()
	_check("data .is_not_empty()", not (data).is_empty())
	_check("data.has(\"feet\") .is_true()", (data.has("feet")) == true)
	_check("data[\"feet\"][\"item_id\"] .is_equal_to(\"feet_boots_mud\")", (data["feet"]["item_id"]) == ("feet_boots_mud"))

	var manager2 = EQ_SCRIPT.new()
	root.add_child(manager2)
	await process_frame
	manager2.from_dict(data)

	_check("manager2.is_item_equipped(\"feet_boots_mud\") .is_true()", (manager2.is_item_equipped("feet_boots_mud")) == true)
	_check("manager2.is_item_equipped(\"head_hat_fisher\") .is_true()", (manager2.is_item_equipped("head_hat_fisher")) == true)
	_check("manager2.is_item_equipped(\"body_coat_rain\") .is_true()", (manager2.is_item_equipped("body_coat_rain")) == true)
	_check("manager2.is_item_equipped(\"acc_backpack\") .is_true()", (manager2.is_item_equipped("acc_backpack")) == true)

	_fin("L. test_serialize_deserialize")


func _bloque_M() -> void:
	_ini("M. test_clear_all_slots")
	var manager = EQ_SCRIPT.new()
	root.add_child(manager)
	await process_frame

	manager.equip_item("feet_boots_mud", EquipmentSlot.SlotType.FEET)
	manager.equip_item("head_hat_fisher", EquipmentSlot.SlotType.HEAD)
	manager.player_equipment.clear_all()

	_check("manager.is_item_equipped(\"feet_boots_mud\") .is_false()", (manager.is_item_equipped("feet_boots_mud")) == false)
	_check("manager.is_item_equipped(\"head_hat_fisher\") .is_false()", (manager.is_item_equipped("head_hat_fisher")) == false)

	_fin("M. test_clear_all_slots")


func _bloque_N() -> void:
	_ini("N. test_unlock_condition_none_always_true")
	var condition = UnlockCondition.new()
	condition.tipo = "none"
	condition.valor = ""
	var player_state: Dictionary = {}
	_check("condition.is_unlocked(player_state) .is_true()", (condition.is_unlocked(player_state)) == true)

	_fin("N. test_unlock_condition_none_always_true")


func _bloque_O() -> void:
	_ini("O. test_unlock_condition_chapter")
	var condition = UnlockCondition.new()
	condition.tipo = "chapter"
	condition.valor = "3"
	var player_state: Dictionary = {"capitulo_actual": 2}
	_check("condition.is_unlocked(player_state) .is_false()", (condition.is_unlocked(player_state)) == false)
	player_state["capitulo_actual"] = 3
	_check("condition.is_unlocked(player_state) .is_true()", (condition.is_unlocked(player_state)) == true)

	_fin("O. test_unlock_condition_chapter")


func _bloque_P() -> void:
	_ini("P. test_is_item_unlocked_without_unlock")
	var manager = EQ_SCRIPT.new()
	root.add_child(manager)
	await process_frame

	var player_state: Dictionary = {}
	_check("manager.is_item_unlocked(\"head_hat_fisher\", player_state) .is_true()", (manager.is_item_unlocked("head_hat_fisher", player_state)) == true)

	_fin("P. test_is_item_unlocked_without_unlock")


func _bloque_Q() -> void:
	_ini("Q. test_is_item_unlocked_with_chapter_requirement")
	var manager = EQ_SCRIPT.new()
	root.add_child(manager)
	await process_frame

	var player_state: Dictionary = {"capitulo_actual": 2}
	_check("manager.is_item_unlocked(\"acc_amulet_ancestral\", player_state) .is_false()", (manager.is_item_unlocked("acc_amulet_ancestral", player_state)) == false)
	player_state["capitulo_actual"] = 3
	_check("manager.is_item_unlocked(\"acc_amulet_ancestral\", player_state) .is_true()", (manager.is_item_unlocked("acc_amulet_ancestral", player_state)) == true)

	_fin("Q. test_is_item_unlocked_with_chapter_requirement")


func _bloque_R() -> void:
	_ini("R. test_get_unlocked_items_filters_locked")
	var manager = EQ_SCRIPT.new()
	root.add_child(manager)
	await process_frame

	var player_state: Dictionary = {"capitulo_actual": 1}
	var unlocked: Array = manager.get_unlocked_items(player_state)
	_check("unlocked .has_not_contains(\"acc_amulet_ancestral\")", not (("acc_amulet_ancestral") in (unlocked)))

	_fin("R. test_get_unlocked_items_filters_locked")


func _bloque_S() -> void:
	_ini("S. test_flag_unlock_vest_explorer")
	# Regresión 2026-09-01 (deepseek-v4-flash-vision-exp): el chaleco explorador
	# tiene unlock por flag "mochila_mejorada" — sin el flag NO se desbloquea.
	var manager = EQ_SCRIPT.new()
	root.add_child(manager)
	await process_frame

	var sin_flag: Dictionary = {}
	_check("manager.is_item_unlocked(\"body_vest_explorer\", sin_flag) .is_false()", (manager.is_item_unlocked("body_vest_explorer", sin_flag)) == false)

	var con_flag: Dictionary = {"flags": {"mochila_mejorada": true}}
	_check("manager.is_item_unlocked(\"body_vest_explorer\", con_flag) .is_true()", (manager.is_item_unlocked("body_vest_explorer", con_flag)) == true)

	_fin("S. test_flag_unlock_vest_explorer")


func _bloque_T() -> void:
	_ini("T. test_catalog_no_duplicates")
	# Regresión 2026-09-01: el catálogo tenía body_vest_explorer y acc_backpack
	# duplicados (Parse Error: Key already used) → se eliminaron las entradas
	# viejas sin unlock. El catálogo debe tener 16 prendas ÚNICAS.
	var manager = EQ_SCRIPT.new()
	root.add_child(manager)
	await process_frame

	_check("manager.catalog.size() .is_equal(16)", (manager.catalog.size()) == (16))
	_check("manager.catalog.has(\"body_vest_explorer\") .is_true()", (manager.catalog.has("body_vest_explorer")) == true)
	_check("manager.catalog.has(\"acc_backpack\") .is_true()", (manager.catalog.has("acc_backpack")) == true)
	_check("manager.catalog[\"body_vest_explorer\"].has(\"unlock\") .is_true()", (manager.catalog["body_vest_explorer"].has("unlock")) == true)

	_fin("T. test_catalog_no_duplicates")


func _bloque_U() -> void:
	_ini("U. test_equip_replaces_same_slot")
	# Al equipar otra prenda del MISMO slot, el slot queda con la última.
	var manager = EQ_SCRIPT.new()
	root.add_child(manager)
	await process_frame

	manager.equip_item("body_coat_rain", EquipmentSlot.SlotType.BODY)
	var result: bool = manager.equip_item("body_shirt_casual", EquipmentSlot.SlotType.BODY)
	_check("result .is_true()", (result) == true)
	var slot: EquipmentSlot = manager.get_equipped_item(EquipmentSlot.SlotType.BODY)
	_check("slot .is_not_null()", (slot) != null)
	_check("slot.item_id .is_equal_to(\"body_shirt_casual\")", (slot.item_id) == ("body_shirt_casual"))


	_fin("U. test_equip_replaces_same_slot")
