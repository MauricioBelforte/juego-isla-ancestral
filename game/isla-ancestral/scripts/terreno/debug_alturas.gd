extends SceneTree
func _init() -> void:
	call_deferred("_run")
func _run() -> void:
	var g = load("res://scripts/world/island_generator.gd").new(null, 42)
	g.island_radius = 256
	g.max_height = 40
	for dx in [200, 210, 215, 220, 225, 230, 240, 247]:
		var h = g.get_height(256 + dx, 256)
		print("dx=%d dist=%.4f h=%d" % [dx, dx / 256.0, h])
	quit(0)
