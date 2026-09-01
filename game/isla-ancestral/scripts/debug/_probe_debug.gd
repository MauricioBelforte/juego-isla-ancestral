# Modelo: Deepseek V4 Flash - prueba headless del DebugMenu (temporal, se elimina)
extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var dm = root.get_node_or_null("DebugMenu")
	print("DebugMenu presente: ", dm != null)
	print("activo: ", dm._activo if dm != null else "?")
	# Probar acciones directamente
	if dm != null:
		var inv = root.get_node_or_null("Inventario")
		var antes: int = inv.count_item("madera_roble") if inv else 0
		dm._accion_dar_madera()
		var despues: int = inv.count_item("madera_roble") if inv else 0
		print("madera antes/despues: ", antes, "/", despues)
		var eco = root.get_node_or_null("EconomyManager")
		var saldo_antes: int = int(eco.saldo) if eco else -1
		dm._accion_dar_ao()
		print("AO antes/despues: ", saldo_antes, "/", int(eco.saldo) if eco else -1)
		dm._accion_hora_noche()
		var cal = root.get_node_or_null("TimeCalendar")
		print("hora tras noche: ", cal.get_hora() if cal else "?")
	quit(0)
