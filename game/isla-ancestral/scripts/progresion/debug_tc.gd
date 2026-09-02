extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var n := 0
	for autoload in ["ToolController", "ToolControllerSingleton", "Tools", "Herramientas"]:
		var node := root.get_node_or_null("/root/" + autoload)
		if node != null:
			print("autoload ", autoload, " → ", node.get_script().resource_path)
			n += 1
	if n == 0:
		print("ningún autoload de herramientas — el ToolController es de escena (no autoload)")
	quit(0)