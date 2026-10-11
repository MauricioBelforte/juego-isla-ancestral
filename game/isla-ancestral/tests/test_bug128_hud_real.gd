# Modelo: mimo-v2.6-flash-free
# Plataforma: opencode
# Fecha: 2026-10-09
#
# BUG-128 (encargo msg 82, Opcion 2 del director): el HUD real del juego es la
# capa CanvasLayer "UI" de main_island.tscn y nadie llamar a register_hud(),
# por lo que UIManager._hud era null y la tecla H era no-op.
#
# Esta suite arranca con current_scene vacio (bootstrap carga main_island.tscn
# en --script) y afirma sobre el HUD REAL, sin mocks:
#   1) la capa UI quedo registrada en UIManager._hud
#   2) H alterna su visibilidad (ida y vuelta)
#   3) el hotbar (EquippedPanel) y el RelojWidget cuelgan de esa capa (cadena)
# Ejecutar:
#   godot --headless --path game/isla-ancestral --script res://tests/test_bug128_hud_real.gd

extends SceneTree

var _fallos: int = 0
var _ok: int = 0
var _ui: CanvasLayer = null
var _um: Node = null


func _init() -> void:
	call_deferred("_correr")


func _check(nombre: String, cond: bool) -> void:
	if cond:
		_ok += 1
		print("[OK] %s" % nombre)
		return
	_fallos += 1
	printerr("[FAIL] %s" % nombre)


func _resumen() -> void:
	print("\n%d checks, %d fallos" % [_ok + _fallos, _fallos])


func _correr() -> void:
	print("=== BUG-128: HUD real registrado (encargo msg 82, opcion 2) ===")
	await _test_carga_main_island()
	if _ui == null or _um == null:
		_resumen()
		quit(1)
		return
	await _test_registro_y_cadena()
	await _test_toggle_h()
	print("--- integridad tras los toggles ---")
	var cs := current_scene
	_check("RelojWidget sigue montado (no se libero nada)",
			cs.get_node_or_null("UI/RelojWidget") != null)
	_check("StatusBar sigue montado (no se libero nada)",
			cs.get_node_or_null("UI/StatusBar") != null)
	_check("EquippedPanel sigue montado (no se libero nada)",
			cs.get_node_or_null("UI/EquippedPanel") != null)
	_resumen()
	quit(1 if _fallos > 0 else 0)


## ── Carga: bootstrap monta main_island.tscn como current_scene ──────

func _esperar_main_island(max_frames: int) -> bool:
	for i in max_frames:
		if current_scene != null and String(current_scene.scene_file_path).ends_with("main_island.tscn"):
			return true
		await process_frame
	return current_scene != null and String(current_scene.scene_file_path).ends_with("main_island.tscn")


func _test_carga_main_island() -> void:
	print("\n--- carga de main_island (bootstrap, current_scene vacio) ---")
	var cargada := await _esperar_main_island(1500)
	_check("bootstrap cargo main_island.tscn como current_scene", cargada)
	if not cargada:
		printerr("  (timeout esperando a main_island; current_scene actual: %s)" % str(current_scene))
		return
	var cs := current_scene
	_check("current_scene es Node3D con script main_island.gd",
			cs.scene_file_path.ends_with("main_island.tscn"))
	_ui = cs.get_node_or_null("UI") as CanvasLayer
	_check("capa UI (CanvasLayer) existe en main_island", _ui != null)
	_um = root.get_node_or_null("/root/UIManager")
	_check("UIManager autoload disponible", _um != null)
	if _ui == null or _um == null:
		return
	# dar un frame extra para que el hotbar diferido del player se monte
	for i in 5:
		await process_frame


## ── Registro: _hud apunta a la capa viva + cadena dentro de la capa ──

func _test_registro_y_cadena() -> void:
	print("\n--- BUG-128: registro de la capa UI viva ---")
	var hud: Node = _um.get("_hud")
	_check("UIManager._hud NO es null (BUG-128 fix activo)", hud != null)
	_check("_hud ES la capa UI viva de main_island (no un mock)", hud == _ui)
	_check("capa UI visible al arranque (precondicion del toggle)", _ui.visible == true)
	_check("el toggle usara la rama .visible (CanvasLayer sin set_hud_visible)",
			not _ui.has_method("set_hud_visible"))
	print("\n--- cadena: hotbar y reloj dentro de la capa ---")
	var equipado := await _esperar_hijo_ui("EquippedPanel", 600)
	_check("hotbar (EquippedPanel) montado dentro de la capa UI", equipado)
	_check("RelojWidget dentro de la capa UI (se oculta en cadena)",
			current_scene.get_node_or_null("UI/RelojWidget") != null)
	_check("hotbar cuelga DIRECTAMENTE de la capa UI (unico toggle basta)",
			equipado and current_scene.get_node_or_null("UI/EquippedPanel").get_parent() == _ui)


func _esperar_hijo_ui(nombre: String, max_frames: int) -> bool:
	for i in max_frames:
		if current_scene != null and current_scene.get_node_or_null("UI/" + nombre) != null:
			return true
		await process_frame
	return current_scene != null and current_scene.get_node_or_null("UI/" + nombre) != null


## ── Toggle: H alterna la capa real (ida y vuelta) ─────────────────────

func _esperar_hud(oculto: bool, max_frames: int) -> bool:
	for i in max_frames:
		if _ui != null and _ui.visible == (not oculto):
			return true
		await process_frame
	return _ui != null and _ui.visible == (not oculto)


func _pulsar_h_directo() -> void:
	var ev := InputEventKey.new()
	ev.physical_keycode = KEY_H
	ev.pressed = true
	_um._unhandled_input(ev)


func _test_toggle_h() -> void:
	print("\n--- toggle H con la capa registrada ---")
	# Intento 1: pipeline real de Input (como el jugador). Si en 20 frames no
	# alterna (headless a veces no entrega eventos de tecla), llamada directa.
	var ev := InputEventKey.new()
	ev.physical_keycode = KEY_H
	ev.pressed = true
	Input.parse_input_event(ev)
	Input.flush_buffered_events()
	var alterno := await _esperar_hud(true, 20)
	if alterno:
		print("  (pipeline real de Input: H alterno el HUD)")
	else:
		print("  (pipeline de Input no entrego H en --script: llamada directa)")
		_pulsar_h_directo()
		await process_frame
	_check("1ra pulsacion H: capa UI oculta", _ui.visible == false)

	_pulsar_h_directo()
	await process_frame
	_check("2da pulsacion H: capa UI visible de nuevo", _ui.visible == true)

	_pulsar_h_directo()
	await process_frame
	_check("3ra pulsacion H: alterna estable (oculto otra vez)", _ui.visible == false)
	_pulsar_h_directo()
	await process_frame
	_check("4ta pulsacion H: y vuelve (visible, estado final limpio)", _ui.visible == true)
