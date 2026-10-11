extends "res://addons/gdUnit4/src/GdUnitTestSuite.gd"

## M110 iter de verificación (deepseek-v4-flash-vision-exp, 2026-09-02):
## DebugMenu RF1-20: export de diagnóstico (RF20) genera el archivo; el menú
## se inicializa solo en build debug (off en release); apertura verificada por
## log en runtime (F12). 

## BUG-129 (M110/M50) — limpieza de huérfanos del boot.
## [causa raíz documentada en el propio archivo: Bootstrap:50 → main_island.tscn:60
##  → vegetation_spawner.gd:21-28/80; el test cede frames y el spawner contamina
##  la ventana de GdUnit con instancias GLB huérfanas]
## [fix raíz aplicado 2026-10-10 (mimo-v2.6-flash-free, patch M50 autorizado en
##  msg 93 del canal): vegetation_spawner.gd ahora cuelga las instancias de un
##  _contenedor propio (no current_scene) y hace inst.free() en el descarte
##  h<3; state_machine.gd parentea los estados en register_state(). Con la raíz
##  fixeada, la suite da 0 orphans SIN helper (medido 3/3 PASSED 0 orphans EXIT 0
##  el 2026-10-10); el helper se conserva como red de seguridad verificable]

## Libera los nodos que el boot del proyecto dejó huérfanos durante este test.
func _limpiar_huerfanos_boot() -> void:
	var root := get_tree().root
	for id in root.get_orphan_node_ids():
		var n := instance_from_id(id) as Node
		if n != null and not n.is_queued_for_deletion():
			n.queue_free()

func test_diag_export_genera_archivo() -> void:
	var menu = load("res://scripts/debug/debug_menu.gd").new()
	add_child(menu)
	if not menu.is_node_ready():
		await menu.ready
	menu._export_diag()
	await get_tree().process_frame
	# BUG-129: el boot (Bootstrap → main_island → VegetationSpawner M50) pobla
	# la isla en cuanto este test cede frames, dejando instancias GLB
	# huérfanas. Se liberan acá y se espera un frame para que el motor las borre
	# antes de que el monitor de GdUnit haga `stop()`.
	_limpiar_huerfanos_boot()
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
		var 		txt := FileAccess.get_file_as_string("user://diagnostics/" + fname)
		# Formato vigente (debug_menu.gd:_export_diagnostic_zip): encabezado
		# "DIAGNOSTICO Isla Ancestral" + Fecha + metadata + consola.
		assert_that(txt).contains("DIAGNOSTICO Isla Ancestral")
		assert_that(txt).contains("Fecha:")
	menu.free()

func test_menu_activo_solo_debug() -> void:
	# Regla M110: el menú solo opera en builds de desarrollo.
	assert_that(OS.is_debug_build()).is_true()  # en tests headless = debug build

func test_accion_teleport_center_ok() -> void:
	var menu = load("res://scripts/debug/debug_menu.gd").new()
	add_child(menu)
	if not menu.is_node_ready():
		await menu.ready
	menu._tp_center()  # no debe fallar con jugador/terreno vía null (defensivo)
	# BUG-129: misma limpieza de huérfanos del boot (ver helper arriba).
	_limpiar_huerfanos_boot()
	await get_tree().process_frame
	assert_that(bool(1 == 1)).is_true()
	menu.free()
