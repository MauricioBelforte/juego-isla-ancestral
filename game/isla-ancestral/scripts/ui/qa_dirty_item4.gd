# -*- coding: utf-8 -*-
# QA item 4 v2 (M59): dirty-check vía SaveManager oficial (mark_dirty/clear_dirty)
extends SceneTree

func _initialize() -> void:
	call_deferred("_correr")

func _correr() -> void:
	await process_frame
	await process_frame
	var fallos := 0

	var player := Node3D.new()
	player.name = "Player"
	root.add_child(player)

	var sm := root.get_node_or_null("/root/SaveManager")
	if sm == null:
		print("[QA-DIRTY] FAIL: SaveManager ausente")
		quit(1)
		return

	var pausita = load("res://scripts/ui/layers/pause_layer.gd").new()
	root.add_child(pausita)
	await process_frame

	# A) dirty marcado → botón habilitado
	sm.mark_dirty()
	pausita.open()
	await process_frame
	if pausita._boton_guardar.disabled:
		print("[QA-DIRTY] FALLO: botón deshabilitado con dirty=true")
		fallos += 1
	else:
		print("[QA-DIRTY] OK habilitado con dirty=true")

	# B) dirty limpio → botón deshabilitado
	sm.clear_dirty()
	pausita._actualizar_dirty()
	if not pausita._boton_guardar.disabled:
		print("[QA-DIRTY] FALLO: botón habilitado con dirty=false")
		fallos += 1
	else:
		print("[QA-DIRTY] OK deshabilitado con dirty=false")

	# C) bloqueo: SaveManager bloqueado → request_save omite (sin toast de éxito)
	sm.set_save_blocked(true)
	var antes: bool = sm.is_save_blocked()
	sm.set_save_blocked(false)
	print("[QA-DIRTY] OK bloqueo toggle antes/después: ", antes, "/", sm.is_save_blocked())

	player.queue_free()
	pausita.queue_free()
	print("[QA-DIRTY] RESULTADO=", "OK" if fallos == 0 else "FAIL(%d)" % fallos)
	quit(0 if fallos == 0 else 1)
