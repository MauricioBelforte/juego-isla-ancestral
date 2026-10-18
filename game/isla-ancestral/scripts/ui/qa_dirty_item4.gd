# -*- coding: utf-8 -*-
# QA item 4 (M59): dirty-check del botón Guardar en pausa (Player dummy inyectado)
extends SceneTree

func _initialize() -> void:
	call_deferred("_correr")

func _correr() -> void:
	await process_frame
	await process_frame
	var fallos := 0

	# 1) Player dummy inyectado (posición A)
	var player := Node3D.new()
	player.name = "Player"
	player.position = Vector3(1, 2, 3)
	root.add_child(player)

	# 2) Guardado inicial (estado A)
	var ds := root.get_node_or_null("/root/DataStore")
	var prov = load("res://scripts/saving/player_save_provider.gd").new()
	var res: Dictionary = ds.guardar_partida(1, {"player": prov.get_save_data()})
	if not bool(res.get("ok", false)):
		print("[QA-DIRTY] FAIL guardado inicial")
		quit(1)
		return

	# 3) PauseLayer standalone + open() → dirty debe ser FALSE (sin cambios)
	var pausita = load("res://scripts/ui/layers/pause_layer.gd").new()
	root.add_child(pausita)
	await process_frame
	pausita.open()
	await process_frame
	if not pausita._boton_guardar.disabled:
		print("[QA-DIRTY] FALLO: botón habilitado sin cambios (dirty=false esperado)")
		fallos += 1
	else:
		print("[QA-DIRTY] OK: botón deshabilitado sin cambios")

	# 4) Mover el jugador → dirty debe ser TRUE
	player.position = Vector3(9, 8, 7)
	pausita._actualizar_dirty()
	if pausita._boton_guardar.disabled:
		print("[QA-DIRTY] FALLO: botón deshabilitado tras cambio de posición (dirty=true esperado)")
		fallos += 1
	else:
		print("[QA-DIRTY] OK: botón habilitado tras cambio de posición")

	# 5) Guardar de nuevo → dirty vuelve a FALSE
	var res2: Dictionary = ds.guardar_partida(1, {"player": prov.get_save_data()})
	pausita._actualizar_dirty()
	if not pausita._boton_guardar.disabled:
		print("[QA-DIRTY] FALLO: botón habilitado tras re-guardar")
		fallos += 1
	else:
		print("[QA-DIRTY] OK: botón deshabilitado tras re-guardar")

	player.queue_free()
	pausita.queue_free()
	print("[QA-DIRTY] RESULTADO=", "OK" if fallos == 0 else "FAIL(%d)" % fallos)
	quit(0 if fallos == 0 else 1)
