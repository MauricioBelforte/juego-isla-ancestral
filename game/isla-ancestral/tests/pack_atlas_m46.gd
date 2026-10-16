# pack_atlas_m46.gd — M46 Arte 2D (lote final, director N673).
# Test headless del pack_atlas.gd: empaca por superficie con límites M46
# (2048², padding 2, sin rotación) y escribe manifiesto JSON.
#
# Usa texturas sintéticas en user:// (resizable; res:// es solo lectura en -s).
#
# **Modelo:** agnes-3-flash (Sapiens AI)
# **Plataforma:** Kilo Code
# **Fecha:** 2026-10-16
#
# Uso: godot --headless -s res://tests/pack_atlas_m46.gd
# Exit 0 = OK, 1 = fallo.

extends SceneTree

const _PACK := preload("res://scripts/arte2d/pack_atlas.gd")

const RAIZ := "user://m46_pack_test"

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _texto(raiz: String, nombre: String, w: int, h: int) -> void:
	var f := FileAccess.open(raiz.path_join(nombre), FileAccess.WRITE)
	if f == null:
		return
	f.close()
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1, 1))
	img.save_png(raiz.path_join(nombre))

func _limpiar() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(RAIZ))

func _run() -> void:
	print("=== [M46] Test pack_atlas.gd (lote final) ===")
	_limpiar()
	_dir_raiz()
	_test_superficie()
	_test_todas_y_manifiesto()
	_test_vacio_graceful()
	_summary()

func _dir_raiz() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(RAIZ))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(RAIZ).path_join("icons"))
	_texto(RAIZ.path_join("icons"), "ico_a.png", 32, 32)
	_texto(RAIZ.path_join("icons"), "ico_b.png", 64, 64)

func _test_superficie() -> void:
	print("--- packear_superficie (icons_atlas) ---")
	var p := _PACK.new()
	var r = p.packear_superficie("icons_atlas", RAIZ)
	_check("2 piezas empacadas", r.piezas_empacadas == 2, "got %d" % r.piezas_empacadas)
	_check("manifiesto 2 regiones", r.manifiesto.size() == 2, "got %d" % r.manifiesto.size())
	if r.manifiesto.size() == 2:
		var m0: Dictionary = r.manifiesto[0]
		var m1: Dictionary = r.manifiesto[1]
		# Orden alfabético: ico_a (32x32) primero, ico_b (64x64) después
		_check("sin rotación", m0["rotacion"] == false and m1["rotacion"] == false)
		_check("padding inicial 2", m0["x"] == 2 and m0["y"] == 2, "m0 @ (%d,%d)" % [m0["x"], m0["y"]])
		_check("fila 2da tras pieza 1 (x=2+32+2=36)", m1["x"] == 36, "m1.x=%d" % m1["x"])
	_check("atlas en disco", FileAccess.file_exists(RAIZ.path_join("icons_atlas.png")))

func _test_todas_y_manifiesto() -> void:
	print("--- pack_todas + manifiesto ---")
	var p := _PACK.new()
	var rs = p.pack_todas(RAIZ)
	_check("5 superficies", rs.size() == 5, "got %d" % rs.size())
	_check("manifest JSON en disco", FileAccess.file_exists(RAIZ.path_join("atlas_manifest.json")))
	# Resumen legible no lanza
	var resumen: String = p.resumen(rs)
	_check("resumen contiene 'pack_atlas'", resumen.contains("pack_atlas"))

func _test_vacio_graceful() -> void:
	print("--- superficie vacía (0 assets, #esperando) ---")
	var p := _PACK.new()
	# "badges" no tiene carpeta creada -> se crea vacía -> error VACIO, sin crash
	var r = p.packear_superficie("badges_atlas", RAIZ)
	_check("superficie vacía reportada (no crash)", r.piezas_empacadas == 0)
	_check("mensaje #esperando:assets-2d", " ".join(r.errores).contains("esperando:assets-2d") or " ".join(r.errores).contains("VACIO"), "errores: %s" % " ".join(r.errores))

func _summary() -> void:
	print("=== [M46] pack_atlas: %d/%d checks, %d fallos ===" % [_checks - _fallos, _checks, _fallos])
	if _fallos > 0:
		quit(1)
	else:
		quit(0)
