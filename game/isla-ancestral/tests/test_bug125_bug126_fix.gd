# Modelo: mimo-v2.6-flash-free
# Plataforma: opencode
# Fecha: 2026-10-09
#
# Suite de regresion de los fixes del encargo msg 80 (atria-dawn, 2026-10-09):
#   BUG-126 — InputMap "ocultar_hud" (tecla H, ticket T-053-067 M56) ausente
#             -> ERROR del motor en ui_manager.gd:146 y toggle HUD muerto.
#   BUG-125 — doble add_child de InventoryPanel en player.gd
#             (L554 a Backdrop + L700 a InventoryCanvas -> "already has a parent").
# Ejecutar:
#   godot --headless --path game/isla-ancestral --script res://tests/test_bug125_bug126_fix.gd

extends SceneTree

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


func _correr() -> void:
	print("=== Fix BUG-126 + BUG-125 (encargo msg 80) ===")
	_test_bug126_inputmap()
	await _test_bug126_toggle()
	await _test_bug125_inventario()
	print("\n%d checks, %d fallos" % [_ok + _fallos, _fallos])
	quit(1 if _fallos > 0 else 0)


## ── BUG-126: la accion existe y esta binded a H ────────────────

func _test_bug126_inputmap() -> void:
	print("\n--- BUG-126: InputMap ocultar_hud ---")
	_check("InputMap tiene la accion ocultar_hud", InputMap.has_action("ocultar_hud"))
	if InputMap.has_action("ocultar_hud"):
		var evs: Array = InputMap.action_get_events("ocultar_hud")
		_check("ocultar_hud tiene al menos 1 evento", evs.size() > 0)
		if evs.size() > 0:
			_check("el evento es InputEventKey", evs[0] is InputEventKey)
			if evs[0] is InputEventKey:
				_check("tecla fisica H (physical_keycode=72)", evs[0].physical_keycode == KEY_H)
	var ev := InputEventKey.new()
	ev.physical_keycode = KEY_H
	ev.pressed = true
	_check("evento H responde is_action_pressed(ocultar_hud)", ev.is_action_pressed("ocultar_hud"))
	_check("evento H NO dispara inventario (B)", not ev.is_action_pressed("inventario"))
	_check("evento H NO dispara diario (J)", not ev.is_action_pressed("diario"))


## ── BUG-126: ui_manager._unhandled_input alterna el HUD ────────

func _test_bug126_toggle() -> void:
	print("\n--- BUG-126: toggle del HUD con ui_manager._unhandled_input ---")
	var um = root.get_node_or_null("/root/UIManager")
	var creado_local := false
	if um == null:
		um = load("res://scripts/ui/core/ui_manager.gd").new()
		um.name = "UIManager"
		get_root().add_child(um)
		creado_local = true
		print("  (UIManager autoload no disponible en --script: instancia local)")
	_check("UIManager disponible", um != null)
	if um == null:
		return

	var capa := Control.new()
	capa.name = "CapaTest126"
	um.call("register_layer", capa)
	_check("pila de capas no vacia (precondicion del toggle)", not um.get("_stack").is_empty())

	var hud := Control.new()
	hud.name = "HudTest126"
	hud.visible = true
	um.call("register_hud", hud)

	var ev := InputEventKey.new()
	ev.physical_keycode = KEY_H
	ev.pressed = true
	um._unhandled_input(ev)
	_check("1ra pulsacion H: HUD oculto", hud.visible == false)
	um._unhandled_input(ev)
	_check("2da pulsacion H: HUD visible de nuevo", hud.visible == true)

	um.call("unregister_layer", capa)
	um.call("register_hud", null)
	if creado_local:
		um.queue_free()


## ── BUG-125: InventoryPanel cuelga de UN solo padre ────────────
## Ejercita el camino legacy de player.gd (_toggle_inventory -> _create_inventory_panel),
## unico lugar donde se construye ese panel. Precondicion: current_scene no nulo
## (player.gd:535 lo usa) y servicios basicos presentes.

func _test_bug125_inventario() -> void:
	print("\n--- BUG-125: panel de inventario con un solo padre ---")
	if root.get_node_or_null("/root/Inventario") == null:
		var inv = load("res://scripts/inventario/inventario_service.gd").new()
		inv.name = "Inventario"
		get_root().add_child(inv)
		print("  (autoload Inventario no disponible: instancia local)")
	if root.get_node_or_null("/root/ItemDatabase") == null:
		var db = load("res://scripts/data/item_database.gd").new()
		db.name = "ItemDatabase"
		get_root().add_child(db)
		print("  (autoload ItemDatabase no disponible: instancia local)")

	# Escena CLI (scene_file_path custom) como current_scene: (a) player.gd:535
	# necesita current_scene, y (b) bootstrap._load_main_scene NO redirige a
	# main_island si scene_file_path es custom (su ejemplo canonico: preview_reloj).
	var escena = load("res://scenes/preview_reloj.tscn").instantiate()
	escena.name = "EscenaNeutraTest125"
	get_root().add_child(escena)
	current_scene = escena
	_check("current_scene seteado para player.gd:535", current_scene == escena)
	_check("scene_file_path custom (anti-redirect bootstrap)",
			escena.scene_file_path != "" and escena.scene_file_path != "res://scenes/main_island.tscn")

	var player = load("res://scenes/player/Player.tscn").instantiate()
	escena.add_child(player)
	await process_frame

	_check("player instanciado", player != null)
	if player == null:
		return

	player._toggle_inventory()
	await process_frame

	var panel = player.get("_inventory_panel")
	var bg = player.get("_inventory_backdrop")
	_check("InventoryPanel creado", panel != null)
	_check("Backdrop creado", bg != null)
	if panel != null and bg != null:
		_check("InventoryPanel cuelga de Backdrop (unico padre)", panel.get_parent() == bg)
		_check("Backdrop cuelga de InventoryCanvas", bg.get_parent() != null and bg.get_parent().name == "InventoryCanvas")
		_check("InventoryCanvas montado en current_scene", bg.get_parent().get_parent() == escena)
		_check("panel visible al abrir", panel.visible == true)
		player._toggle_inventory()
		await process_frame
		_check("panel oculto al cerrar", panel.visible == false)
		_check("backdrop oculto al cerrar", bg.visible == false)
		player._toggle_inventory()
		await process_frame
		_check("panel visible al reabrir (reutiliza, no recrea)", panel.visible == true)

	player.queue_free()
	await process_frame
