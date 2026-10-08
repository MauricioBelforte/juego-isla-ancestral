# M163 - Test de Encantamientos por Tier (iter. 3, seccion D)
# Cubre: datos de los 4 tiers (costos T1-T4, duraciones, habilidades, brillo,
# nombres/descripciones), reglas de equipamiento (1 por herramienta, no
# re-encantar, sin incienso, no-desactivable, remove devuelve incienso) y
# persistencia M59 (contrato ISaveProvider + registro en SaveManager).
# La UI de cobro de monedas (shaman_ui.gd) no se ejercita aqui: se verifico
# en revision de codigo y se cita en el 05-Checklist.
# Ejecutar:
#   godot --headless --path game/isla-ancestral --script res://scripts/enchantment/test_enchant_tiers.gd
extends SceneTree

## Piso de checks MEDIDO (45 checks en la corrida verde del 2026-10-07).
const CHECKS_MINIMOS := 45

var passed: int = 0
var failed: int = 0

func _init() -> void:
	call_deferred("_run")

func _check(cond: bool, msg: String) -> void:
	if cond:
		passed += 1
		print("[OK] " + msg)
	else:
		failed += 1
		print("[FAIL] " + msg)

func _fin() -> void:
	var total: int = passed + failed
	if total < CHECKS_MINIMOS:
		failed += 1
		print("[FAIL] CHECKS_MINIMOS: total %d < piso %d" % [total, CHECKS_MINIMOS])
	print("Resumen M163 encantamientos por tier: %d checks, %d fallos" % [passed, failed])
	quit(1 if failed > 0 else 0)

func _run() -> void:
	# --- Autoloads ---
	var sys = root.get_node_or_null("EnchantmentSystem")
	var sm = root.get_node_or_null("SaveManager")
	_check(sys != null, "A0: autoload EnchantmentSystem presente")
	_check(sm != null, "A0: autoload SaveManager presente (M59)")
	if sys == null or sm == null:
		_fin()
		return

	# ================= A. Datos por tier (los 4 .tres) =================
	_check(sys.get_all_enchantments().size() >= 4, "A1: catalogo con 4 encantamientos")
	var ids := ["ancestral_cobre", "prospero_hierro", "brillante_oro", "caverna_cristal"]
	var e := []
	for id in ids:
		e.append(sys.get_enchantment(id))
		_check(e[e.size() - 1] != null, "A2: " + id + " en catalogo")
	if e[0] == null or e[1] == null or e[2] == null or e[3] == null:
		_fin()
		return

	# Costos (diseno 03-Diseno §4: 3/200, 5/500, 8/800, 12/1000)
	_check(e[0].incense_cost == 3 and e[0].coin_cost == 200, "A6: T1 costo 3 incienso + 200 monedas")
	_check(e[1].incense_cost == 5 and e[1].coin_cost == 500, "A7: T2 costo 5 incienso + 500 monedas")
	_check(e[2].incense_cost == 8 and e[2].coin_cost == 800, "A8: T3 costo 8 incienso + 800 monedas")
	_check(e[3].incense_cost == 12 and e[3].coin_cost == 1000, "A9: T4 costo 12 incienso + 1000 monedas")

	# Tier
	_check(e[0].tool_tier == 1, "A10: T1 ancestral_cobre tool_tier 1")
	_check(e[1].tool_tier == 2, "A11: T2 prospero_hierro tool_tier 2")
	_check(e[2].tool_tier == 3, "A12: T3 brillante_oro tool_tier 3")
	_check(e[3].tool_tier == 4, "A13: T4 caverna_cristal tool_tier 4")

	# Duraciones de animacion (2/3/4/5 s)
	_check(e[0].animation_duration == 2.0, "A14: T1 anim 2s")
	_check(e[1].animation_duration == 3.0, "A15: T2 anim 3s")
	_check(e[2].animation_duration == 4.0, "A16: T3 anim 4s")
	_check(e[3].animation_duration == 5.0, "A17: T4 anim 5s")

	# Habilidades
	_check(e[0].ability_type == "special_trade" and is_equal_approx(e[0].ability_value, 1.0),
			"A18: T1 special_trade x1")
	_check(e[1].ability_type == "double_coins" and is_equal_approx(e[1].ability_value, 2.0),
			"A19: T2 double_coins x2")
	_check(e[2].ability_type == "sell_bonus" and is_equal_approx(e[2].ability_value, 0.5),
			"A20: T3 sell_bonus +50%")
	_check(e[3].ability_type == "cave_bonus" and is_equal_approx(e[3].ability_value, 1.5),
			"A21: T4 cave_bonus x1.5")

	# Nombres/descripciones unicos + brillo con color
	var nombres := {}
	var desc_ok := true
	var color_ok := true
	for ench in e:
		if ench.display_name.is_empty():
			desc_ok = false
		nombres[ench.display_name] = true
		if ench.description.is_empty():
			desc_ok = false
		if ench.visual_color.a <= 0.0:
			color_ok = false
	_check(nombres.size() == 4, "A22: 4 display_name unicos y no vacios")
	_check(desc_ok, "A23: description no vacia en los 4 tiers")
	var descs := {}
	for ench in e:
		descs[ench.description] = true
	_check(descs.size() == 4, "A25: 4 description unicas")
	_check(color_ok, "A24: visual_color con alfa > 0 en los 4 (brillo con color asignado)")

	# ================= B. Reglas de equipamiento =================
	sys.set_incense(100)
	_check(sys.enchant_tool("pickaxe_1", "prospero_hierro"), "B1: encantar con incienso suficiente")
	_check(sys.is_enchanted("pickaxe_1"), "B2: is_enchanted true tras encantar")
	_check(not sys.enchant_tool("pickaxe_1", "brillante_oro"), "B3: NO re-encantar herramienta ya encantada")
	_check(sys.get_tool_enchantment("pickaxe_1").id == "prospero_hierro",
			"B4: el encantamiento original se conserva (1 por herramienta)")
	_check(sys.get_incense() == 95, "B5: cobro de incienso T2 (100 - 5 = 95)")

	# Limpieza de estado: pickaxe_1 queda libre para el bloque B6-B8.
	sys.remove_enchantment("pickaxe_1")

	sys.set_incense(0)
	_check(not sys.enchant_tool("pickaxe_2", "ancestral_cobre"), "B6: sin incienso -> false")

	sys.set_incense(100)
	sys.enchant_tool("pickaxe_1", "prospero_hierro")
	sys.remove_enchantment("pickaxe_1")
	_check(not sys.is_enchanted("pickaxe_1"), "B7: remove limpia el encantamiento")
	_check(sys.get_incense() == 100, "B8: remove devuelve el incienso cobrado")

	sys.enchant_tool("pickaxe_1", "brillante_oro")
	var ab: Dictionary = sys.get_active_ability("pickaxe_1")
	_check(ab.get("type", "") == "sell_bonus" and is_equal_approx(float(ab.get("value", 0.0)), 0.5),
			"B9: get_active_ability expone la habilidad equipada (activacion automatica)")
	_check(ab.get("tier", 0) == 3, "B10: get_active_ability expone el tier")
	_check(not sys.has_method("disable_enchantment") and not sys.has_method("desactivar_encantamiento"),
			"B11: NO existe API para desactivar habilidades")

	# ================= C. Persistencia M56/M59 =================
	_check(sys.get_section_name() == "enchantments", "C1: seccion ISaveProvider 'enchantments'")
	var d: Dictionary = sys.get_save_data()
	_check(d.has("enchantment_pickaxe_1") and d["enchantment_pickaxe_1"] == "brillante_oro",
			"C2: get_save_data incluye enchantment_<tool_id>")
	sys.from_dict({"enchantments": [], "incense": 7, "encantos_totales": 0})
	_check(not sys.is_enchanted("pickaxe_1"), "C3: from_dict limpia estado previo")
	sys.from_dict(d)
	_check(sys.is_enchanted("pickaxe_1") and sys.get_tool_enchantment("pickaxe_1").id == "brillante_oro",
			"C4: round-trip from_dict conserva encantamiento")
	sys.restore_save_data(d)
	_check(sys.is_enchanted("pickaxe_1"), "C5: restore_save_data round-trip")

	var registrado: bool = false
	if "snapshot" in sm and sm.snapshot != null:
		registrado = sm.snapshot._providers.has("enchantments")
	_check(registrado, "C6: provider registrado en SaveManager.snapshot (ready del juego)")

	if registrado:
		sm.snapshot.restore({"enchantments": d})
		_check(sys.is_enchanted("pickaxe_1"), "C7: snapshot.restore E2E restaura la seccion")
	else:
		_check(false, "C7: snapshot.restore E2E restaura la seccion")

	_fin()
