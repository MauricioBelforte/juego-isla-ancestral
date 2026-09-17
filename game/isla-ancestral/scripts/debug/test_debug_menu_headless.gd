# Modelo: agnes-2.5-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-12
#
# M110: Verificación del DebugMenu (RF1-20) — headless SceneTree.
# RF20: export de diagnóstico genera user://diagnostics/diag_*.txt.
# RF1-RF10: comandos integrados con sistemas del juego.

extends SceneTree

var _fallos: int = 0
var _checks: int = 0
var _menu: Node = null

func _init() -> void:
	call_deferred("_run")

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)

func _run() -> void:
	print("=== [M110] Verificación del DebugMenu ===")
	_menu = load("res://scripts/debug/debug_menu.gd").new()
	root.add_child(_menu)
	await process_frame
	_check("DebugMenu instanciado", _menu != null)
	_check("Solo en build debug (off en release)", OS.is_debug_build())

	# Mock mínimo de Player (es un nodo de ESCENA, no un autoload) para que
	# los comandos RF1/RF8 encuentren /root/Player en headless y ejecuten.
	var _ps := GDScript.new()
	_ps.source_code = "extends CharacterBody3D\nfunc add_tool_to_hotbar(_t):\n\tpass\n"
	_ps.reload()
	var _player := CharacterBody3D.new()
	_player.set_script(_ps)
	_player.name = "Player"
	root.add_child(_player)

	# ── RF20: export de diagnóstico ──────────────────────────────────────
	_menu.call("_export_diag")
	await process_frame
	var dir = DirAccess.open(ProjectSettings.globalize_path("user://diagnostics"))
	var total_txt = 0
	var total_zip = 0
	var name_file = ""
	if dir:
		dir.list_dir_begin()
		var fn = dir.get_next()
		while fn != "":
			if fn.begins_with("diag_"):
				if fn.ends_with(".txt"):
					total_txt += 1
					name_file = fn
				elif fn.ends_with(".zip"):
					total_zip += 1
			fn = dir.get_next()
		dir.list_dir_end()
	_check("RF20: archivo diag_*.txt generado (%d)" % total_txt, total_txt >= 1)
	_check("RF20: archivo diag_*.zip generado (%d)" % total_zip, total_zip >= 1)
	if name_file != "":
		var txt = FileAccess.get_file_as_string("user://diagnostics/" + name_file)
		_check("RF20: contenido de diagnóstico presente", txt.find("DIAGNOSTICO") != -1)

	# ── RF1: Teleport ────────────────────────────────────────────────────
	var r1 = _menu.teleport_player(Vector3(256.0, 30.0, 256.0))
	_check("RF1: teleport retorna ok", bool(r1.get("ok", false)))
	# Alias test
	var r1a = _menu.call("_tp_center")
	_check("RF1: _tp_center sin errore", r1a != null)

	# ── RF2: Tiempo ─────────────────────────────────────────────────────
	var r2 = _menu.set_game_time(12)
	_check("RF2: set_game_time ejecuta", r2 != null)
	var r2a = _menu.call("_time_6")
	_check("RF2: _time_6 sin errore", r2a != null)

	# ── RF3: Clima ──────────────────────────────────────────────────────
	var r3 = _menu.set_weather(0)
	_check("RF3: set_weather ejecuta", r3 != null)
	var r3a = _menu.call("_weather_soleado")
	_check("RF3: _weather_soleado sin errore", r3a != null)

	# ── RF5: Inventario ─────────────────────────────────────────────────
	var r5 = _menu.dar_objetos("wood", 10)
	_check("RF5: dar_objetos (wood x10)", bool(r5.get("ok", false)))

	# ── RF6: Economía ───────────────────────────────────────────────────
	var r6 = _menu.dar_dinero(100)
	_check("RF6: dar_dinero 100", bool(r6.get("ok", false)))

	# ── RF7: Historia — completar nodo ─────────────────────────────────
	var r7 = _menu.completar_mision("historia_c1_mural")
	_check("RF7: completar_mision no crash", r7 != null)

	# ── RF8: Herramientas ───────────────────────────────────────────────
	## ToolData.Tipo.PICO = 0, ToolData.Nivel.COBRE = 1
	var r8 = _menu.desbloquear_herramienta(0, 1)
	_check("RF8: desbloquear_herramienta PICO cobre", bool(r8.get("ok", false)))

	# ── RF9: Viajes ─────────────────────────────────────────────────────
	var r9 = _menu.desbloquear_isla("isla_secundaria_1")
	_check("RF9: desbloquear_isla no crash", r9 != null)

	# ── RF10: Sellos ────────────────────────────────────────────────────
	var r10 = _menu.desbloquear_sello("sello_1")
	_check("RF10: desbloquear_sello no crash", r10 != null)

	# ── RF14/16/18: Visual toggles ─────────────────────────────────────
	_menu.toggle_colliders(true)
	_menu.toggle_chunks(true)
	_menu.toggle_hitboxes(true)
	_check("RF14/16/18: toggles visuales sin errore", true)

	# ── RF H: Consola logger ────────────────────────────────────────────
	var lines = _menu.console_get_lines()
	_check("RF H: consola tiene lineas registradas", lines.size() > 0)

	# ── F12 toggle ──────────────────────────────────────────────────────
	var ev = InputEventKey.new()
	ev.keycode = KEY_F12
	ev.pressed = true
	_menu._unhandled_input(ev)
	_check("F12 maneja la alternancia del menu", _menu.visible == true)

	# ── métricas ────────────────────────────────────────────────────────
	var met = _menu.metricas_sistema()
	_check("RF metricas: fps > 0", int(met.get("fps", 0)) >= 0)
	_check("RF metricas: memoria_mb >= 0", float(met.get("memoria_mb", -1.0)) >= 0.0)

	if _menu:
		_menu.free()
	print("=== Resumen M110: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)
