extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var t: int = 0
	for a in OS.get_cmdline_args():
		if String(a).begins_with("T="):
			t = int(String(a).substr(2))
	print("PROBE t=", t)
	match t:
		1:
			var n = null
			n.get_name()
			print("AFTER1")
		2:
			var y: int = 0
			var x: float = 1.0 / float(y)
			print("AFTER2=", x)
		3:
			var o := Object.new()
			o.no_existe()
			print("AFTER3")
		4:
			OS.crash("red probe")
			print("AFTER4")
		_:
			print("unknown")
	print("REACHED_END")
	quit(0)
