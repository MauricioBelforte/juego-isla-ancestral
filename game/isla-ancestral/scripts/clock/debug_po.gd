extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var loc := root.get_node_or_null("Localization")
	if loc == null:
		print("sin loc")
		quit(1)
		return
	loc.set_locale("en")
	var en: Dictionary = loc._catalogs.get("en", {})
	print("en catalogo tiene CLOCK? ", en.has("CLOCK.ESTACIONES.0"))
	if en.has("CLOCK.ESTACIONES.0"):
		print("valor en: ", en.get("CLOCK.ESTACIONES.0"))
	print("tr_key(CLOCK.ESTACIONES.0): ", loc.traducir_clave("CLOCK.ESTACIONES.0"))
	quit(0)
