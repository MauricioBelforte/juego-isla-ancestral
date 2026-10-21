# preview_inventario_s5.gd - PRUEBA VISUAL temporal (Step-5-WorkBuddy, 2026-10-21)
# Monta el UIRoot REAL (tema cozy dark D102 via ThemeService/ThemeUx) y abre
# InventoryLayer con el inventario POBLADO (lista larga) para la captura de
# verificacion visual propia: BACKLOG Bloque W items 4/10 (M76).
# Uso: godot --path . res://scripts/ui/preview_inventario_s5.tscn
# Temporal: se borra al cerrar la verificacion.
extends Node

const ESPERA_BOOT := 1.5
const MAX_ITEMS := 32
const CONTENEDOR_BOLSILLO := 0
const CATEGORIAS := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]

func _ready() -> void:
	var ui_root_script: Variant = load("res://scripts/ui/ui_root.gd")
	if ui_root_script == null:
		push_error("[PREVIEW-INV-S5] no se pudo cargar ui_root.gd")
		_salir(2)
		return
	var ui_root: Node = ui_root_script.new()
	ui_root.name = "UIRoot"
	add_child(ui_root)

	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(ESPERA_BOOT).timeout

	var inv := get_node_or_null("/root/Inventario")
	if inv == null:
		push_error("[PREVIEW-INV-S5] autoload Inventario ausente")
		_salir(2)
		return

	var agregados := _poblar_inventario(inv)
	print("[PREVIEW-INV-S5] items agregados=%d bolsillo %d/%d slots" % [
		agregados, inv.used_slots(CONTENEDOR_BOLSILLO), inv.total_slots(CONTENEDOR_BOLSILLO),
	])

	var capa := _capa_inventario()
	if capa == null:
		push_error("[PREVIEW-INV-S5] InventoryLayer no encontrada en UIRoot/UIManager")
		_salir(2)
		return
	capa.toggle()
	print("[PREVIEW-INV-S5] capa visible=%s slots_grid=%d" % [
		capa.visible, capa.get("_slots").size(),
	])

	# Esperar el render y capturar el viewport real (tema dark aplicado).
	await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout
	_capturar("inventario_dark_lista_larga")

	# Segunda toma: pestana de una categoria con stock (filtro activo).
	if capa.has_method("_on_category_pressed"):
		capa._on_category_pressed(0)
		await get_tree().process_frame
		await get_tree().create_timer(0.5).timeout
		_capturar("inventario_dark_pestania_mobiliario")

	_salir(0)

func _poblar_inventario(inv: Node) -> int:
	# Reparte los items entre categorias variadas (2 por categoria) para que la
	# vista "Todos" sea una lista larga mixta y el filtro por pestana se note.
	var agregados := 0
	var db := get_node_or_null("/root/ItemDatabase")
	if db == null or not db.has_method("get_items_by_category"):
		print("[PREVIEW-INV-S5] ItemDatabase sin get_items_by_category; sin items")
		return 0
	for vueltas in range(2):
		for cat in CATEGORIAS:
			if agregados >= MAX_ITEMS:
				break
			var items: Array = db.get_items_by_category(cat)
			var tomados := 0
			for it in items:
				if tomados >= 2 or agregados >= MAX_ITEMS:
					break
				var id := ""
				if it != null and it.get("id"):
					id = str(it.id)
				if id != "":
					inv.add_item(id, 1 + (agregados % 5), CONTENEDOR_BOLSILLO)
					agregados += 1
					tomados += 1
		if agregados >= MAX_ITEMS:
			break
	return agregados

func _capa_inventario() -> Node:
	var um := get_node_or_null("/root/UIManager")
	if um != null and um.has_method("_buscar_capa"):
		return um._buscar_capa("InventoryLayer")
	var root := get_node_or_null("UIRoot")
	if root != null:
		return root.get_node_or_null("InventoryLayer")
	return null

func _capturar(nombre: String) -> void:
	var img := get_viewport().get_texture().get_image()
	if img == null:
		print("[PREVIEW-INV-S5] CAPTURA FALLIDA (%s): viewport sin textura (headless?)" % nombre)
		return
	var dir := "user://capturas_s5_inventario"
	DirAccess.make_dir_recursive_absolute(dir)
	var ruta := "%s/%s.png" % [dir, nombre]
	var err := img.save_png(ruta)
	print("[PREVIEW-INV-S5] captura %s -> %s (err=%d, %dx%d)" % [
		nombre, ruta, err, img.get_width(), img.get_height(),
	])

func _salir(codigo: int) -> void:
	print("[PREVIEW-INV-S5] fin de la prueba (codigo=%d)" % codigo)
	get_tree().quit(codigo)
