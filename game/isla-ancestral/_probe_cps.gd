extends SceneTree
func _init() -> void:
	var AUD = load("res://scripts/fonts/auditar_glifos.gd")
	var rutas := ["res://locales/es.po", "res://locales/en.po"]
	var d: Dictionary = AUD.caracteres_de_po(rutas)
	var cps: Array = (d["chars"] as Dictionary).keys()
	cps.sort()
	var hex: Array = []
	for c in cps:
		hex.append("U+%04X" % int(c))
	print("GODOT codepoints=%d" % cps.size())
	print("SET:" + ",".join(hex))
	quit(0)
