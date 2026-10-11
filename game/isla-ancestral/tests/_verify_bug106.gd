extends SceneTree

func _init():
	var ids := [
		"madera_roble",
		"baya_roja",
		"fibra_algodon",
		"mineral_cobre",
		"herramienta_basica",
		"fragmento_ancestral",
		"piedra_caliza",
		"pergamino_rec_tela_lino",
	]
	var db = get_root().get_node("/root/ItemDatabase")
	if db == null:
		print("VERIFY_BUG106: ItemDatabase NO encontrado como autoload")
		quit(2)
		return
	var faltantes := []
	for id in ids:
		var item = db.get_item(id)
		if item == null:
			faltantes.append(id)
		else:
			print("VERIFY_BUG106 OK: ", id, " -> ", item.nombre)
	print("VERIFY_BUG106 TOTAL_OK=", ids.size() - faltantes.size(), " FALTANTES=", faltantes)
	if faltantes.size() > 0:
		quit(1)
	else:
		quit(0)
