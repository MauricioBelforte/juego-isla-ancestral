extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var c := load("res://data/light/day_curve.tres") as Curve
	print("curve=", c)
	if c != null:
		print("point_count=", c.point_count)
		print("min=", c.min_value, " max=", c.max_value)
		for h in [0.0, 6.0, 12.0, 23.0]:
			print("sample(", h, ")=", c.sample(h))
		print("raw data[0..8]=", str(c._data.slice(0, 8)))
	quit(0)
