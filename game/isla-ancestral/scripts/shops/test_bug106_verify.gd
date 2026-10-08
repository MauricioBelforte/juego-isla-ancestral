# Verificación BUG-106: contra el ItemDatabase M15 real (el check de _validar_tienda).
extends SceneTree

var checked := false

func _initialize() -> void:
	# Los autoloads están listos tras el primer frame.
	process_frame.connect(_checar_once)

func _checar_once() -> void:
	if checked:
		return
	checked = true
	var db = root.get_node_or_null("ItemDatabase")
	if db == null:
		print("[BUG-106-verify] ItemDatabase no disponible; no pude verificar en el DB")
		quit(0)
		return
	var orig = ["baya_roja", "fibra_algodon", "madera_roble", "mineral_cobre",
			"pergamino_rec_tela_lino", "herramienta_basica", "fragmento_ancestral", "piedra_caliza"]
	var mapped = ["grass", "wood", "copper_ore", "copper_ore", "OBJ-ART-002", "OBJ-HER-001", "OBJ-ART-003", "stone"]
	var miss_o = 0
	for o in orig:
		if not db.has_method("get_item") or db.get_item(o) == null:
			miss_o += 1
	var miss_m = 0
	for m in mapped:
		if not db.has_method("get_item") or db.get_item(m) == null:
			miss_m += 1
	print("[BUG-106-verify] ItemDatabase.get_item: originales ausentes=%d/8, mapeados ausentes=%d/8" % [miss_o, miss_m])
	# lista los que si/ no existen
	for o in orig:
		print("  orig %-24s -> %s" % [o, "existe" if db.get_item(o) else "AUSENTE"])
	quit(0)
