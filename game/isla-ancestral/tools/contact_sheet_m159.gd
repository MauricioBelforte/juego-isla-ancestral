# contact_sheet_m159.gd — genera una hoja de contacto de los íconos de una tanda M159
# (composita los 48×48 sobre fondo dark D102) para el QA visual. Headless.
#
# **Modelo:** agnes-3-flash (Sapiens AI)
# **Plataforma:** Kilo Code
# **Fecha:** 2026-10-17

extends SceneTree

const OUT := "res://tools/mcp/godot-mcp/capturas/159-Catalogo-De-Objetos/"

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var d := DirAccess.open("res://")
	if d:
		d.make_dir_recursive("tools/mcp/godot-mcp/capturas/159-Catalogo-De-Objetos")
	var ids: Array[String] = ["item_obj_her_001", "item_obj_her_002", "item_obj_her_003", "item_obj_her_004", "item_obj_her_005", "gemstone", "glass", "ice", "mud", "moss"]
	var celda := 64
	var margen := 8
	var w := ids.size() * celda + margen * 2
	var h := celda + margen * 2
	var hoja := Image.create(w, h, false, Image.FORMAT_RGBA8)
	hoja.fill(Color.from_string("#1E1A24", Color.BLACK))  # dark D102
	for i in range(ids.size()):
		var p := "res://assets/2d/items_m159/ico_" + ids[i] + ".png"
		var im := Image.new()
		if im.load(ProjectSettings.globalize_path(p)) != OK:
			continue
		var dest := Vector2(margen + i * celda, (celda - im.get_height()) / 2.0)
		hoja.blit_rect(im, Rect2(Vector2.ZERO, Vector2(im.get_width(), im.get_height())), dest)
	var abs := ProjectSettings.globalize_path(OUT + "cap_159_tanda2_contact_sheet.png")
	var r := hoja.save_png(abs)
	print("=== [M159 b2] contact sheet: %d celdas, save=%s ===" % [ids.size(), ("OK" if r == OK else "FAIL")])
	quit(0 if r == OK else 1)
