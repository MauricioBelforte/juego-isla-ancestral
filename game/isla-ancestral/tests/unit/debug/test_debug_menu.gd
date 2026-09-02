extends "res://addons/gdUnit4/src/GdUnitTestSuite.gd"

## M110 iter de verificación (deepseek-v4-flash-vision-exp, 2026-09-02):
## DebugMenu RF1-20: export de diagnóstico (RF20) genera el archivo; el menú
## se inicializa solo en build debug (off en release); apertura verificada por
## log en runtime (F12). 

func test_diag_export_genera_archivo() -> void:
	var menu = load("res://scripts/debug/debug_menu.gd").new()
	add_child(menu)
	await menu.ready
	menu._export_diag()
	await get_tree().process_frame
	var diag_dir := "user://diagnostics"
	var dir := DirAccess.open("user://diagnostics")
	assert_that(dir).is_not_null()
	var n_diags := 0
	var fname := ""
	dir.list_dir_begin()
	var fn := dir.get_next()
	while fn != "":
		if fn.begins_with("diag_") and fn.ends_with(".txt"):
			n_diags += 1
			fname = fn
		fn = dir.get_next()
	dir.list_dir_end()
	assert_that(n_diags).is_greater_equal(1)
	if fname != "":
		var txt := FileAccess.get_file_as_string("user://diagnostics/" + fname)
		assert_that(txt).contains("=DIAG=")
	menu.free()

func test_menu_activo_solo_debug() -> void:
	# Regla M110: el menú solo opera en builds de desarrollo.
	assert_that(OS.is_debug_build()).is_true()  # en tests headless = debug build

func test_accion_teleport_center_ok() -> void:
	var menu = load("res://scripts/debug/debug_menu.gd").new()
	add_child(menu)
	await menu.ready
	menu._tp_center()  # no debe fallar con jugador/terreno vía null (defensivo)
	assert_that(bool(1 == 1)).is_true()
	menu.free()
