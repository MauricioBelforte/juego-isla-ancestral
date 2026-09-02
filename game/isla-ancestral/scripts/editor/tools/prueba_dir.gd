extends SceneTree
func _init() -> void:
	call_deferred("_run")
func _run() -> void:
	var dir := DirAccess.open("res://data/dialogues/")
	print("dir null? ", dir == null)
	if dir:
		dir.list_dir_begin()
		var n := dir.get_next()
		while n != "":
			print("entry: \"%s\" is_dir=%s" % [n, dir.current_is_dir()])
			n = dir.get_next()
		dir.list_dir_end()
	quit(0)
