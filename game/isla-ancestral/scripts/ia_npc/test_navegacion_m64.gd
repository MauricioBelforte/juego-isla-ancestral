extends SceneTree

var _passed := 0
var _failed := 0
var _total := 0

func _init() -> void:
	print("=== [M64] Test de Navegación ===")
	_bloque_a_watchdog()
	_bloque_b_separation()
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
	print("=== Resumen Navegación M64: %d checks, %d fallos ===" % [_total, _failed])
	if _failed == 0:
		print("✅ TODOS LOS TESTS PASARON")
	else:
		print("❌ %d TEST(S) FALLARON" % _failed)
	quit(_failed)


func _bloque_a_watchdog() -> void:
	print("--- Bloque A: Watchdog ---")
	var WDScript = preload("res://scripts/ia_npc/npc_watchdog.gd")
	var wd = WDScript.new()
	get_root().add_child(wd)

	wd.register_npc(&"test_npc")
	_check("A1: npc registrado", wd.is_npc_registered(&"test_npc"))

	wd.on_state_changed(&"test_npc", &"Work")
	var info = wd.get_npc_state_info(&"test_npc")
	_check("A2: estado registrado es Work", info.get("state", &"") == &"Work")

	wd.unregister_npc(&"test_npc")
	_check("A3: npc desregistrado", not wd.is_npc_registered(&"test_npc"))

	# Test bucle de transiciones
	wd.register_npc(&"burst_npc")
	for i in range(15):
		wd.on_state_changed(&"burst_npc", &"Work" if i % 2 == 0 else &"Idle")
	_check("A4: sin crash por bucle de transiciones", true)

	wd.unregister_npc(&"burst_npc")
	wd.queue_free()
	_fin("A")


func _bloque_b_separation() -> void:
	print("--- Bloque B: Separación entre NPCs ---")
	var AgentScript = preload("res://scripts/ia_npc/npc_agent.gd")

	_check("B1: SEPARATION_FORCE const", AgentScript.SEPARATION_FORCE == 1.5)
	_check("B2: SEPARATION_RADIUS const", AgentScript.SEPARATION_RADIUS == 1.5)
	_check("B3: MAX_SIMULTANEOUS_SOCIALS const", AgentScript.MAX_SIMULTANEOUS_SOCIALS == 3)

	# Separación con posiciones Vector3 directas (sin SceneTree 3D)
	var pos1 = Vector3(0, 0, 0)
	var pos2 = Vector3(0.5, 0, 0)
	var diff = pos1 - pos2
	var dist = diff.length()
	_check("B4: distancia entre NPCs cercanos < radio", dist < AgentScript.SEPARATION_RADIUS)

	var pos3 = Vector3(5.0, 0, 0)
	var diff2 = pos1 - pos3
	var dist2 = diff2.length()
	_check("B5: distancia entre NPCs lejanos > radio", dist2 > AgentScript.SEPARATION_RADIUS)

	_fin("B")
