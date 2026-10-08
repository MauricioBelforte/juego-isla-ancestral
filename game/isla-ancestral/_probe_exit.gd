extends SceneTree

func _probe_exit(exit: int) -> void:
	print("parametro exit = ", exit)
	print("exit != 0 = ", exit != 0)

func _initialize() -> void:
	print("=== PROBE parametro exit ===")
	_probe_exit(3)
	print("=== FIN ===")
	quit(0)
