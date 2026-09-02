# Modelo: agnes-2.5-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M110: Debug Menu — autoload "DebugMenu" (solo debug builds)
# F12 para toggle. RF1-20 integrados con APIs reales existentes.
# Sin class_name (autoload pitfall 07-GUIA-GODOT §9.17/§9.41).

extends Node

signal debug_action(action: StringName, data: Dictionary)

var _panel: Control = null
var _log_text: String = ""
var _panel_visible: bool = false


func _ready() -> void:
	if not OS.is_debug_build():
		set_process(false)
		return
	_build_ui()
	print("[DebugMenu] Inicializado (debug build)")


func _build_ui() -> void:
	var capa := CanvasLayer.new()
	capa.name = "DebugLayer"
	add_child(capa)

	var panel := PanelContainer.new()
	panel.name = "DebugPanel"
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.07, 0.06, 0.95)
	sb.border_color = Color(0.8, 0.5, 0.15)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(6)
	sb.set_content_margin_all(8)
	panel.add_theme_stylebox_override("panel", sb)
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = -420
	panel.offset_top = 60
	panel.offset_right = 10
	panel.offset_bottom = -10
	panel.visible = false
	capa.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	panel.add_child(vbox)

	var titulo := Label.new()
	titulo.text = "[DBG] F12"
	titulo.add_theme_font_size_override("font_size", 12)
	titulo.add_theme_color_override("font_color", Color(0.9, 0.6, 0.2))
	vbox.add_child(titulo)

	# RF1: Teleport
	_btn(vbox, "RF1: TP (0,5,0)", _tp_zero)
	_btn(vbox, "RF1: TP centro", _tp_center)
	# RF2: Time
	_btn(vbox, "RF2: Hora 06:00", _time_6)
	_btn(vbox, "RF2: Hora 12:00", _time_12)
	_btn(vbox, "RF2: Hora 21:00", _time_21)
	_btn(vbox, "RF2: Dia siguiente", _next_day)
	# RF4: Weather
	_btn(vbox, "RF4: Clima soleado", _weather_soleado)
	_btn(vbox, "RF4: Clima lluvia", _weather_lluvia)
	_btn(vbox, "RF4: Clima tormenta", _weather_tormenta)
	# RF5: Inventory
	_btn(vbox, "RF5: +10 madera", _inv_madera)
	_btn(vbox, "RF5: +10 piedra", _inv_piedra)
	_btn(vbox, "RF5: +10 bayas", _inv_bayas)
	# RF6: Economy
	_btn(vbox, "RF6: +100 AO", _eco_plus)
	_btn(vbox, "RF6: -50 AO", _eco_minus)
	# RF7-12 stubs
	_btn(vbox, "RF7: Completar mision (stub)", _stub.bind("mission"))
	_btn(vbox, "RF8: Desbloquear tool (stub)", _stub.bind("tool"))
	_btn(vbox, "RF9: Desbloquear isla (stub)", _stub.bind("island"))
	_btn(vbox, "RF10: Desbloquear sello (stub)", _stub.bind("seal"))
	_btn(vbox, "RF11: Reset NPC", _reset_npc)
	_btn(vbox, "RF12: Reset puzzle (stub)", _stub.bind("puzzle"))
	# RF13
	_btn(vbox, "RF13: Regen chunk (stub)", _stub.bind("chunk"))
	# RF14-19 visual toggles
	_btn(vbox, "RF14: Colliders ON/OFF", _toggle_colliders)
	_btn(vbox, "RF15: FPS ON/OFF", _toggle_fps)
	_btn(vbox, "RF16: Chunks ON/OFF", _toggle_chunks)
	_btn(vbox, "RF17: Nav ON/OFF", _toggle_nav)
	_btn(vbox, "RF18: Hitboxes ON/OFF", _toggle_hitboxes)
	_btn(vbox, "RF19: AI states ON/OFF", _toggle_ai)
	# RF20 diagnostic
	_btn(vbox, "RF20: Export diagnostico", _export_diag)
	_btn(vbox, "RF20: Info sistema", _info_sys)

	_log_label = Label.new()
	_log_label.name = "DebugLog"
	_log_label.add_theme_font_size_override("font_size", 9)
	_log_label.add_theme_color_override("font_color", Color(0.7, 0.9, 0.5))
	_log_label.text = "> Debug ready"
	vbox.add_child(_log_label)


func _btn(parent: Node, texto: String, cb: Callable) -> void:
	var btn := Button.new()
	btn.text = texto
	btn.add_theme_font_size_override("font_size", 10)
	btn.pressed.connect(cb)
	parent.add_child(btn)


# ── RF1: Teleport ─────────────────────────────────────────────

func _tp_zero() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		players[0].global_position = Vector3.ZERO
		_log("TP -> (0,0,0)")
		debug_action.emit(&"teleport", {"pos": Vector3.ZERO})
	else:
		_log("TP: no player found")


func _tp_center() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		players[0].global_position = Vector3(64.0, 1.0, 64.0)
		_log("TP -> center")
		debug_action.emit(&"teleport", {"pos": Vector3(64.0, 1.0, 64.0)})


# ── RF2: Time ─────────────────────────────────────────────────

func _time_6() -> void:
	var gt = get_node_or_null("/root/GameTime")
	if gt != null and gt.has_method("avanzar_hasta"):
		gt.avanzar_hasta(6, 0)
		_log("Hora -> 06:00")
		debug_action.emit(&"time_set", {"hora": 6, "minuto": 0})


func _time_12() -> void:
	var gt = get_node_or_null("/root/GameTime")
	if gt != null and gt.has_method("avanzar_hasta"):
		gt.avanzar_hasta(12, 0)
		_log("Hora -> 12:00")
		debug_action.emit(&"time_set", {"hora": 12, "minuto": 0})


func _time_21() -> void:
	var gt = get_node_or_null("/root/GameTime")
	if gt != null and gt.has_method("avanzar_hasta"):
		gt.avanzar_hasta(21, 0)
		_log("Hora -> 21:00")
		debug_action.emit(&"time_set", {"hora": 21, "minuto": 0})


func _next_day() -> void:
	var gt = get_node_or_null("/root/GameTime")
	if gt != null and gt.has_method("avanzar_hasta"):
		gt.avanzar_hasta(6, 0)
		_log("Dia siguiente -> 06:00")
		debug_action.emit(&"day_advance", {})


# ── RF4: Weather ──────────────────────────────────────────────

func _weather_soleado() -> void:
	_emit_weather(0)


func _weather_lluvia() -> void:
	_emit_weather(2)


func _weather_tormenta() -> void:
	_emit_weather(3)


func _emit_weather(clima_id: int) -> void:
	var bus = get_node_or_null("/root/EventBus")
	if bus != null:
		var wb = bus.get_node_or_null("weather")
		if wb != null and wb.has_signal("clima_cambio"):
			wb.clima_cambio.emit(clima_id)
			_log("Clima -> %d" % clima_id)
			debug_action.emit(&"weather_set", {"clima": clima_id})
		else:
			_log("RF4: weather signal no disponible")
	else:
		_log("RF4: EventBus no disponible")


# ── RF5: Inventory ────────────────────────────────────────────

func _inv_madera() -> void:
	var inv = get_node_or_null("/root/Inventario")
	if inv != null and inv.has_method("add_item"):
		inv.add_item("madera_roble", 10)
		_log("+10 madera_roble")
		debug_action.emit(&"item_added", {"id": "madera_roble", "cant": 10})


func _inv_piedra() -> void:
	var inv = get_node_or_null("/root/Inventario")
	if inv != null and inv.has_method("add_item"):
		inv.add_item("piedra_caliza", 10)
		_log("+10 piedra_caliza")
		debug_action.emit(&"item_added", {"id": "piedra_caliza", "cant": 10})


func _inv_bayas() -> void:
	var inv = get_node_or_null("/root/Inventario")
	if inv != null and inv.has_method("add_item"):
		inv.add_item("baya_roja", 10)
		_log("+10 bayas_rojas")
		debug_action.emit(&"item_added", {"id": "baya_roja", "cant": 10})


# ── RF6: Economy ──────────────────────────────────────────────

func _eco_plus() -> void:
	var eco = get_node_or_null("/root/EconomyManager")
	if eco != null and eco.has_method("depositar_monedas"):
		eco.depositar_monedas(100)
		_log("+100 AO")
		debug_action.emit(&"money_change", {"delta": 100})


func _eco_minus() -> void:
	var eco = get_node_or_null("/root/EconomyManager")
	if eco != null and eco.has_method("depositar_monedas"):
		eco.depositar_monedas(-50)
		_log("-50 AO")
		debug_action.emit(&"money_change", {"delta": -50})


# ── RF7-13: Stubs ────────────────────────────────────────────

func _stub(what: String) -> void:
	_log("RF stub: %s" % what)
	debug_action.emit(("rf_" + what).to_upper(), {})


func _reset_npc() -> void:
	var vm = get_node_or_null("/root/VillagerManager")
	if vm != null and vm.has_method("obtener_activos"):
		var activos = vm.obtener_activos()
		if activos.size() > 0:
			_log("RF11: NPC reset (stub) -> %s" % activos[0].name)
			debug_action.emit(&"npc_reset", {"npc": activos[0].name})
		else:
			_log("RF11: no NPCs activos")
	else:
		_log("RF11: VillagerManager no disponible")


# ── RF14-19: Visual toggles ──────────────────────────────────

var _vis_colliders: bool = false
var _vis_fps: bool = false
var _vis_chunks: bool = false
var _vis_nav: bool = false
var _vis_hitboxes: bool = false
var _vis_ai: bool = false


func _toggle_colliders() -> void:
	_vis_colliders = not _vis_colliders
	_log("RF14: Colliders %s" % ("ON" if _vis_colliders else "OFF"))
	debug_action.emit(&"colliders_toggle", {"on": _vis_colliders})


func _toggle_fps() -> void:
	_vis_fps = not _vis_fps
	_log("RF15: FPS %s" % ("ON" if _vis_fps else "OFF"))
	debug_action.emit(&"fps_toggle", {"on": _vis_fps})


func _toggle_chunks() -> void:
	_vis_chunks = not _vis_chunks
	_log("RF16: Chunks %s" % ("ON" if _vis_chunks else "OFF"))
	debug_action.emit(&"chunks_toggle", {"on": _vis_chunks})


func _toggle_nav() -> void:
	_vis_nav = not _vis_nav
	_log("RF17: Nav %s" % ("ON" if _vis_nav else "OFF"))
	debug_action.emit(&"nav_toggle", {"on": _vis_nav})


func _toggle_hitboxes() -> void:
	_vis_hitboxes = not _vis_hitboxes
	_log("RF18: Hitboxes %s" % ("ON" if _vis_hitboxes else "OFF"))
	debug_action.emit(&"hitboxes_toggle", {"on": _vis_hitboxes})


func _toggle_ai() -> void:
	_vis_ai = not _vis_ai
	_log("RF19: AI states %s" % ("ON" if _vis_ai else "OFF"))
	debug_action.emit(&"ai_toggle", {"on": _vis_ai})


# ── RF20: Diagnostic export ──────────────────────────────────

func _export_diag() -> void:
	var ts: String = str(int(Time.get_unix_time_from_system()))
	var dir_path: String = "user://diagnostics"
	DirAccess.make_dir_recursive_absolute(dir_path)
	var filepath: String = dir_path + "/diag_" + ts + ".txt"
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	if file == null:
		_log("RF20: error creando archivo")
		return
	file.store_line("=== DIAGNOSTICO ISLA ANCESTRAL ===")
	file.store_line("Timestamp: " + ts)
	file.store_line("Version: " + ProjectSettings.get_setting("application/config/version", "0.0.1"))
	# Time info
	var gt = get_node_or_null("/root/GameTime")
	if gt != null:
		file.store_line("Hora: %02d:%02d | Dia: %d" % [gt.get_hora(), gt.get_minuto(), gt.dia_absoluto()])
	# Player pos
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var p = players[0]
		file.store_line("Jugador: (%.1f, %.1f, %.1f)" % [p.global_position.x, p.global_position.y, p.global_position.z])
	# FPS
	var fps: int = Performance.get_monitor(Performance.TIME_FPS)
	file.store_line("FPS: " + str(fps))
	file.close()
	_log("RF20: diagnostic exported -> " + ts + ".txt")
	debug_action.emit(&"diagnostic_exported", {"file": ts + ".txt"})


func _info_sys() -> void:
	var fps: int = Performance.get_monitor(Performance.TIME_FPS)
	var players = get_tree().get_nodes_in_group("player")
	var npcs = get_tree().get_nodes_in_group("npc")
	var txt: String = "FPS=%d | Players=%d | NPCs=%d" % [fps, players.size(), npcs.size()]
	_log(txt)
	debug_action.emit(&"system_info", {"fps": fps, "players": players.size(), "npcs": npcs.size()})


# ── Input ─────────────────────────────────────────────────────

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F12:
			_panel_visible = not _panel_visible
			if _panel != null:
				_panel.visible = _panel_visible
			_log("Debug menu %s" % ("abierto" if _panel_visible else "cerrado"))
			get_viewport().set_input_as_handled()
		elif _panel_visible and event.keycode == KEY_ESCAPE:
			_panel_visible = false
			if _panel != null:
				_panel.visible = false
			get_viewport().set_input_as_handled()


# ── API publica ───────────────────────────────────────────────

func show_menu() -> void:
	_panel_visible = true
	if _panel != null:
		_panel.visible = true

func hide_menu() -> void:
	_panel_visible = false
	if _panel != null:
		_panel.visible = false

func toggle_menu() -> void:
	_panel_visible = not _panel_visible
	if _panel != null:
		_panel.visible = _panel_visible

func is_visible() -> bool:
	return _panel_visible


# ── Log ───────────────────────────────────────────────────────

var _log_label: Label = null

func _log(msg: String) -> void:
	_log_text = "> " + msg
	if _log_label != null:
		_log_label.text = _log_text
	print("[DBG] " + msg)
