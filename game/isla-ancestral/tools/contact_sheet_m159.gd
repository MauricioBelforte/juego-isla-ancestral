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
	var ids: Array[String] = ["item_obj_ite_050", "item_obj_ite_051", "item_obj_ite_052", "item_obj_ite_053", "item_obj_ite_054", "item_obj_ite_055", "item_obj_ite_056", "item_obj_ite_057", "item_obj_rel_001", "item_obj_rel_002", "item_obj_rel_003", "item_obj_rel_004", "item_obj_sec_001", "item_obj_sec_002", "item_obj_sec_003", "item_obj_sec_004", "item_obj_sec_005", "ancient_crystal", "copper_ore", "crystal", "dirt", "fragmento_ancestral", "gravel", "herramienta_basica", "incense", "incense_rare", "pergamino_rec_tela_lino", "planks", "sand", "snow"]
	var celda := 64
	var margen := 8
	var cols := 10
	var filas := int(ceil(float(ids.size()) / float(cols)))
	var w := cols * celda + margen * 2
	var h := filas * celda + margen * 2
	var hoja := Image.create(w, h, false, Image.FORMAT_RGBA8)
	hoja.fill(Color.from_string("#1E1A24", Color.BLACK))  # dark D102
	for i in range(ids.size()):
		var p := "res://assets/2d/items_m159/ico_" + ids[i] + ".png"
		var fila := int(i / cols)
		var col := int(i % cols)
		var im := Image.new()
		if im.load(ProjectSettings.globalize_path(p)) != OK:
			continue
		var dest := Vector2(margen + col * celda, margen + fila * celda + (celda - im.get_height()) / 2.0)
		hoja.blit_rect(im, Rect2(Vector2.ZERO, Vector2(im.get_width(), im.get_height())), dest)
	var abs := ProjectSettings.globalize_path(OUT + "cap_159_tanda17_final_contact_sheet.png")
	var r := hoja.save_png(abs)
	print("=== [M159 b2] contact sheet: %d celdas, save=%s ===" % [ids.size(), ("OK" if r == OK else "FAIL")])
	quit(0 if r == OK else 1)
