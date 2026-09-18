extends SceneTree

## Diagnostico BUG-028 (atria-dawn, Log 982): por que precio_compra_vigente("OBJ-PLA-001") == 0
## Uso: godot --headless --path game/isla-ancestral --script res://scripts/economia/test_diag_m38_atria.gd

func _initialize() -> void:
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	print("=== DIAG BUG-028 (atria-dawn) ===")
	var db = root.get_node_or_null("ItemDatabase")
	var eco = root.get_node_or_null("EconomyManager")
	print("ItemDatabase: %s" % str(db != null))
	print("EconomyManager: %s" % str(eco != null))
	if db == null or eco == null:
		print("FALTAN AUTOLOADS"); quit(1); return

	var item = db.get_item("OBJ-PLA-001")
	print("get_item(OBJ-PLA-001) == null: %s" % str(item == null))
	if item != null:
		print("  precio_compra=%s precio_venta=%s" % [str(item.get("precio_compra")), str(item.get("precio_venta"))])
		print("  rareza=%s" % str(item.get("rareza")))

	var precio = eco.precio_compra_vigente("OBJ-PLA-001")
	print("precio_compra_vigente(OBJ-PLA-001) = %d" % int(precio))

	# ItemIds alternativos del catalogo para referencia
	for id in ["madera_roble", "piedra_caliza", "fragmento_ancestral"]:
		print("ref %s -> compra=%d venta=%d" % [id, int(eco.precio_compra_vigente(id)), int(eco.precio_venta_vigente(id))])

	# Como resuelve la base: catálogo override si/no
	var cat = null
	var cls = load("res://scripts/economia/economy_price_catalog.gd")
	if cls != null and cls.can_instantiate():
		cat = cls.get_catalog()
	print("catalogo cargado: %s" % str(cat != null))
	if cat != null and cat.has_method("get_price_def"):
		var def = cat.get_price_def("OBJ-PLA-001")
		print("catalogo.get_price_def(OBJ-PLA-001) == null: %s" % str(def == null))
		if def != null:
			print("  def.precio_compra=%s" % str(def.get("precio_compra")))
	print("=== FIN DIAG ===")
	quit(0)
