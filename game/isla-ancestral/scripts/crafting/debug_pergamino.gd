extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var craft := root.get_node_or_null("Crafting")
	var bal := root.get_node_or_null("Balance")
	if craft == null or bal == null:
		print("crafting o balance nulos")
		quit(1)
		return
	print("recetas en Crafting: ", craft._recetas.size())
	print("rec_tela_lino en _recetas: ", craft._recetas.has("rec_tela_lino"))
	var recetas: Dictionary = bal.get_crafting().get("recetas", {})
	print("recetas en Balance: ", recetas.size())
	print("rec_tela_lino en Balance: ", recetas.has("rec_tela_lino"))
	quit(0)