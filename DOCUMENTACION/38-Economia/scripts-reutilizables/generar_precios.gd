# Generador M38: crea econ_prices.tres con ResourceSaver (formato canonico).
extends SceneTree

const DEF := preload("res://scripts/economia/price_definition.gd")
const CAT := preload("res://scripts/economia/economy_price_catalog.gd")

# Precios base por item (venta ~40-60% de compra, cozy anti-grind)
const TABLA := [
	["wood", 80, 30, "comun"],
	["stone", 90, 35, "comun"],
	["copper_ore", 150, 60, "poco_comun"],
	["copper_bar", 260, 110, "poco_comun"],
	["iron_ore", 220, 90, "poco_comun"],
	["iron_bar", 380, 160, "raro"],
	["fiber", 30, 12, "comun"],
	["berry", 25, 10, "comun"],
	["herb", 45, 18, "comun"],
	["crystal", 400, 180, "raro"],
	["relic", 700, 320, "epico"],
	["fish_common", 40, 16, "comun"],
	["fish_rare", 120, 55, "poco_comun"],
	["seed_basic", 20, 8, "comun"],
	["tool_kit", 150, 0, "raro"],
	["gem", 550, 240, "raro"],
	["shell", 35, 14, "comun"],
	["amber", 300, 130, "raro"],
]

func _initialize() -> void:
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	var cat := CAT.new()
	var arr: Array = []
	for fila in TABLA:
		var d := DEF.new()
		d.item_id = fila[0]
		d.precio_compra = fila[1]
		d.precio_venta = fila[2]
		d.rareza = fila[3]
		d.revendible = fila[2] > 0
		arr.append(d)
	cat.price_overrides = arr
	var err := ResourceSaver.save(cat, "res://data/economy/econ_prices.tres")
	print("M38: save err=", err)
	# verificacion inmediata
	var back := load("res://data/economy/econ_prices.tres")
	if back == null:
		printerr("M38: recarga FALLO")
	else:
		print("M38: recarga OK, entries=", back.price_overrides.size())
	quit()
