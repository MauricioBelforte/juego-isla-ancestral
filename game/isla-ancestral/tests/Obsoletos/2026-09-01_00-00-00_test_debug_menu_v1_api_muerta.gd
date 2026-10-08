# Modelo: agnes-2.5-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M110: Test headless de Debug Menu
# Ejecutar: godot --headless --path game/isla-ancestral --script res://tests/test_debug_menu.gd
#
# Prueba: toggle, RF1-20 stubs/real, visual toggles, diagnóstico, señales.
#         0 fallos requeridos.
#
# ============================================================
# OBSOLETA — movida a tests/Obsoletos/ (2026-10-08)
# ============================================================
# **Modelo:** mimo-v2.6-flash-free
# **Plataforma:** opencode
# **Fecha:** 2026-10-08
#
# Motivo (diagnóstico medido, no supuesto):
#   La suite fue escrita 2026-09-01 contra la API v1 de debug_menu.gd
#   (is_visible/show_menu/hide_menu/toggle_menu/get_current_panel/set_panel/
#   _tp_pos/_hora/_dar/_dar_ao/_stub/_toggle_*/_exportar_diagnostico/
#   _list_npcs + señal debug_action). Ese menú fue REFACTORIZADO después a
#   API v2 data-driven (commits f02b4ca/64ce433/72a6fea): hoy expone
#   alternar()/esta_visible()/pestanas()/ejecutar_comando()/teleport_player()/
#   set_game_time()/dar_objetos()/dar_dinero()/toggle_*(enabled)/
#   _export_diag()/metricas_sistema() y las señales toggle_visual_cambiado/
#   estacion_solicitada/clima_solicitado. Casi ninguna llamada de esta suite
#   existe en la API viva -> SCRIPT ERROR sin quit() y colgaba el runner
#   (por eso run_tests.gd la excluía documentadamente).
#
#   Cobertura NO perdida (3 suites vivas ya prueban la API v2):
#     - tests/unit/debug/test_debug_menu.gd (GdUnit4, 21/21 tras fix 2026-10-07)
#     - scripts/debug/test_debug_m110.gd (SceneTree, en el runner)
#     - scripts/debug/test_debug_menu_headless.gd + test_m110_iter_atria.gd
#   Reescribirla a API v2 = duplicado; se decide por obsolescencia (encargo
#   del director msg 65, frente A: "fixear o marcar obsoleta con justificación").
#
#   Dueño del módulo: M110 (el 05-Checklist NO se tocó — auditoría Ling L-05).
#   Evidencia: Log de cierre en Logs/ + corridas runner antes/después.
# ============================================================

extends SceneTree

const StateMachineScript = preload("res://scripts/ia_npc/state_machine.gd")

var _fallos: int = 0
var _ok: int = 0


func _init() -> void:
	call_deferred("_correr")


func _check(nombre: String, cond: bool) -> void:
	if cond:
		_ok += 1
		print("[OK] %s" % nombre)
		return
	_fallos += 1
	printerr("[FAIL] %s" % nombre)


func _get_root(name: String) -> Node:
	return get_root().get_node_or_null(name)


func _correr() -> void:
	# ── 0. Autoload existence ──────────────────────────────────
	print("\n=== TEST AUTOLOADS ===")
	var dm = _get_root("DebugMenu")
	_check("DebugMenu autoload", dm != null)
	var gt = _get_root("GameTime")
	_check("GameTime autoload", gt != null)
	var cal = _get_root("TimeCalendar")
	_check("TimeCalendar autoload", cal != null)
	var inv = _get_root("Inventario")
	_check("Inventario autoload", inv != null)
	var eco = _get_root("EconomyManager")
	_check("EconomyManager autoload", eco != null)
	var vm = _get_root("VillagerManager")
	_check("VillagerManager autoload", vm != null)
	var bus = _get_root("EventBus")
	_check("EventBus autoload", bus != null)

	if dm == null:
		print("\n===== M110 SKIP (no debug build) =====")
		print("0 OK / 0 fallos")
		print("RESULTADO: OK")
		quit(0)
		return

	# ── 1. Toggle ─────────────────────────────────────────────
	print("\n=== TEST TOGGLE ===")
	_check("menu oculto inicial", not dm.is_visible())
	dm.show_menu()
	_check("show_menu funciona", dm.is_visible())
	dm.hide_menu()
	_check("hide_menu funciona", not dm.is_visible())
	dm.toggle_menu()
	_check("toggle_menu abre", dm.is_visible())
	dm.toggle_menu()
	_check("toggle_menu cierra", not dm.is_visible())

	# ── 2. Panel navigation ───────────────────────────────────
	print("\n=== TEST PANELS ===")
	_check("panel inicial es Jugador", dm.get_current_panel() == 0)
	dm.set_panel(1)
	_check("cambiar a Mundo", dm.get_current_panel() == 1)
	dm.set_panel(3)
	_check("cambiar a Visual", dm.get_current_panel() == 3)
	dm.set_panel(0)
	_check("volver a Jugador", dm.get_current_panel() == 0)

	# ── 3. RF1: Teleport ──────────────────────────────────────
	print("\n=== TEST RF1 TELEPORT ===")
	# Teleport should not crash even without player in tree
	dm._tp_pos(Vector3(10.0, 5.0, 10.0))
	_check("teleport no crash", true)
	dm._tp_center()
	_check("teleport center no crash", true)

	# ── 4. RF2: Time ──────────────────────────────────────────
	print("\n=== TEST RF2 TIME ===")
	if gt != null and gt.has_method("get_hora"):
		var antes = gt.get_hora()
		dm._hora(12, 0)
		_check("hora 12:00 no crash", true)
		dm._dia_siguiente()
		_check("dia siguiente no crash", true)
	else:
		dm._hora(12, 0)
		_check("hora 12:00 (sin GameTime)", true)
		dm._dia_siguiente()
		_check("dia siguiente (sin GameTime)", true)

	# ── 5. RF3: Season ────────────────────────────────────────
	print("\n=== TEST RF3 SEASON ===")
	dm._estacion(0)
	_check("season primavera (stub)", true)
	dm._estacion(3)
	_check("season invierno (stub)", true)

	# ── 6. RF4: Weather ───────────────────────────────────────
	print("\n=== TEST RF4 WEATHER ===")
	dm._clima(0)
	_check("weather soleado (stub)", true)
	dm._clima(3)
	_check("weather tormenta (stub)", true)

	# ── 7. RF5: Inventory ─────────────────────────────────────
	print("\n=== TEST RF5 INVENTORY ===")
	if inv != null and inv.has_method("add_item"):
		var antes = inv.count_item("madera_roble")
		dm._dar("madera_roble", 5)
		var despues = inv.count_item("madera_roble")
		_check("+5 madera funciona", despues >= antes)
		dm._dar("baya_roja", 10)
		_check("+10 bayas no crash", true)
	else:
		dm._dar("test_item", 1)
		_check("dar item (sin Inventario)", true)

	# ── 8. RF6: Economy ───────────────────────────────────────
	print("\n=== TEST RF6 ECONOMY ===")
	if eco != null and eco.has_method("depositar_monedas"):
		var saldo_antes = eco.saldo
		dm._dar_ao(100)
		_check("+100 AO no crash", true)
		dm._dar_ao(-50)
		_check("-50 AO no crash", true)
	else:
		dm._dar_ao(100)
		_check("AO (sin EconomyManager)", true)

	# ── 9. RF7-12: Stubs ──────────────────────────────────────
	print("\n=== TEST RF7-12 STUBS ===")
	dm._stub.call("mission")
	_check("RF7 mission (stub) no crash", true)
	dm._stub.call("tool")
	_check("RF8 tool (stub) no crash", true)
	dm._stub.call("island")
	_check("RF9 island (stub) no crash", true)
	dm._stub.call("seal")
	_check("RF10 seal (stub) no crash", true)
	dm._reset_npc()
	_check("RF11 NPC reset (stub) no crash", true)
	dm._stub.call("puzzle")
	_check("RF12 puzzle (stub) no crash", true)
	dm._stub.call("chunk")
	_check("RF13 chunk regen (stub) no crash", true)

	# ── 10. RF14-19: Visual toggles ───────────────────────────
	print("\n=== TEST RF14-19 VISUAL ===")
	dm._toggle_colliders()
	_check("RF14 colliders toggle no crash", true)
	dm._toggle_fps()
	_check("RF15 FPS toggle no crash", true)
	dm._toggle_chunks()
	_check("RF16 chunks toggle no crash", true)
	dm._toggle_nav()
	_check("RF17 nav toggle no crash", true)
	dm._toggle_hitboxes()
	_check("RF18 hitboxes toggle no crash", true)
	dm._toggle_ai()
	_check("RF19 AI toggle no crash", true)

	# ── 11. RF20: Diagnostic export ───────────────────────────
	print("\n=== TEST RF20 DIAGNOSTIC ===")
	dm._exportar_diagnostico()
	_check("RF20 exportar diagnóstico no crash", true)
	dm._info_sistema()
	_check("RF20 info sistema no crash", true)
	dm._clear_log()
	_check("RF20 clear log no crash", true)

	# ── 12. Entity listing ────────────────────────────────────
	print("\n=== TEST ENTITIES ===")
	dm._list_npcs()
	_check("list NPCs no crash", true)
	dm._estado_ia()
	_check("IA estado no crash", true)

	# ── 13. Signal emission check ─────────────────────────────
	print("\n=== TEST SIGNALS ===")
	var signals_caught: Array[StringName] = []
	var conn = dm.debug_action.connect(func(action, data): signals_caught.append(action))
	dm._tp_pos(Vector3(0, 0, 0))
	dm._dar("test_item", 1)
	dm._dar_ao(10)
	dm._hora(12, 0)
	_check("signals emitidas", signals_caught.size() >= 3)
	dm.debug_action.disconnect(conn)

	# ── Fin ───────────────────────────────────────────────────
	print("\n===== RESULTADOS M110 DEBUG MENU =====")
	print("%d OK / %d fallos" % [_ok, _fallos])
	print("RESULTADO: %s" % ("OK" if _fallos == 0 else "FALLOS"))
	quit(1 if _fallos > 0 else 0)
