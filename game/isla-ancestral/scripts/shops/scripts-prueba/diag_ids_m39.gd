# Modelo: glm-5.3-flash
# Plataforma: Cline
# Fecha: 2026-09-18
#
# M39: Diagnostico de ids (BUG-028 / BUG-046).
# Lista los ids REALES de ItemDatabase y cruza el catalogo de tiendas M39.
# Uso: godot --headless --path game/isla-ancestral --script res://scripts/shops/scripts-prueba/diag_ids_m39.gd

extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var db = root.get_node_or_null("ItemDatabase")
	print("=== DIAG IDS M39 (BUG-028/046) ===")
	if db == null:
		print("FALLO: ItemDatabase ausente")
		quit(1)
		return

	var ids: Array = []
	for k in db._items.keys():
		ids.append(String(k))
	ids.sort()
	print("ItemDatabase count=%d" % ids.size())
	print("ids reales: %s" % ", ".join(ids))

	# Ids que usa el catalogo real de tiendas (M39)
	var catalogo: Array = [
		"madera_roble", "piedra_caliza", "baya_roja", "fibra_algodon",
		"fragmento_ancestral", "mineral_cobre", "wood", "stone"
	]
	print("--- cruce catalogo M39 ---")
	for cid in catalogo:
		var it = db.get_item(String(cid))
		print("  %s -> %s" % [cid, "EXISTE" if it != null else "NO EXISTE"])

	# Id del test fallido
	for tid in ["OBJ-PLA-001", "OBJ-CUA-007", "OBJ-COC-001"]:
		var it2 = db.get_item(String(tid))
		print("  [test] %s -> %s" % [tid, "EXISTE" if it2 != null else "NO EXISTE"])

	quit(0)