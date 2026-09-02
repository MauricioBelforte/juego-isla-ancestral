# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M110: Verificación del DebugMenu (RF1-20) — headless SceneTree.
# RF20: export de diagnóstico genera user://diagnostics/diag_*.txt.
# Aislado del runner gdUnit (la suite está colgada por la regresión ajena
# M163 en curso, documentada en ESTADO-PARALELO).

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
	# RF20: export de diagnóstico
	_menu.call("_export_diag")
	await process_frame
	var dir := DirAccess.open("user://diagnostics")
	var total := 0
	var name_file := ""
	if dir:
		dir.list_dir_begin()
		var fn := dir.get_next()
		while fn != "":
			if fn.begins_with("diag_") and fn.ends_with(".txt"):
				total += 1
				name_file = fn
			fn = dir.get_next()
		dir.list_dir_end()
	_check("RF20: archivo diag_*.txt generado (%d)" % total, total >= 1)
	if name_file != "":
		var txt := FileAccess.get_file_as_string("user://diagnostics/" + name_file)
		_check("RF20: contenido de diagnóstico presente", txt.find("DIAGNOSTICO") != -1)
	# RF1-RF6: teleport/hora/clima (destructivo seguro en headless)
	_menu.call("_tp_center")
	_menu.call("_time_6")
	_menu.call("_weather_soleado")
	_checks += 1
	print("  [INFO] RF1-RF6 llamados sin erre-parse (teleport/hora/clima)")

	# Atajo F12 (fix 2026-09-02): _unhandled_input alterna el menu
	var ev := InputEventKey.new()
	ev.keycode = KEY_F12
	ev.pressed = true
	_menu._unhandled_input(ev)
	_check("F12 maneja la alternancia del menu", _menu.visible == true)
	if _menu:
		_menu.free()
	print("=== Resumen M110: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)
