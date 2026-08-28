# Script: generate_econ_prices.gd (temporal)
# Genera data/economy/econ_prices.tres con entries usando items reales de M159.
extends Node

# Nota: no usamos tipos Resource exportados porque al lanzar con --script el
# motor no resuelve class_name externo → usamos Dictionary para construir y salvar.

func _ready() -> void:
	var catalog := Resource.new()
	# Usamos el script del Resource como base, cargando el Resource genérico con su script
	catalog.set_script(load("res://scripts/economia/economy_price_catalog.gd"))
	var overrides: Array = []

	overrides.append(_entry("wood", 80, 30, "comun"))
	overrides.append(_entry("stone", 90, 35, "comun"))
	overrides.append(_entry("copper_ore", 150, 60, "poco_comun"))
	overrides.append(_entry("iron_ore", 240, 95, "poco_comun"))
	overrides.append(_entry("clay", 50, 20, "comun"))
	overrides.append(_entry("sand", 40, 15, "comun"))
	overrides.append(_entry("grass", 25, 10, "comun"))
	overrides.append(_entry("dirt", 20, 8, "comun"))
	overrides.append(_entry("moss", 35, 14, "comun"))
	overrides.append(_entry("crystal", 320, 130, "raro"))
	overrides.append(_entry("gemstone", 450, 180, "raro"))
	overrides.append(_entry("ancient_crystal", 600, 240, "legendario"))

	# Cada entry como sub-Resource PriceDefinition
	var defs: Array[Resource] = []
	for e in overrides:
		var d := Resource.new()
		d.set_script(load("res://scripts/economia/price_definition.gd"))
		d.set("resource_name", e.item_id)
		d.set("item_id", e.item_id)
		d.set("precio_compra", e.precio_compra)
		d.set("precio_venta", e.precio_venta)
		d.set("rareza", e.rareza)
		d.set("revendible", e.revendible)
		defs.append(d)
	catalog.set("price_overrides", defs)

	var dir := DirAccess.open("res://data/economy")
	if dir == null:
		DirAccess.make_dir_absolute("res://data/economy")

	var err := ResourceSaver.save("res://data/economy/econ_prices.tres", catalog)
	if err == OK:
		print("M38: econ_prices.tres generado con ", defs.size(), " entries.")
	else:
		push_error("M38: no se pudo guardar econ_prices.tres: ", err)
	get_tree().quit()

func _entry(id: String, compra: int, venta: int, rareza: String) -> Dictionary:
	return {"item_id": id, "precio_compra": compra, "precio_venta": venta, "rareza": rareza, "revendible": true}

