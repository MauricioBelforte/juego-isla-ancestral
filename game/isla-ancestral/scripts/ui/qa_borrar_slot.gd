# -*- coding: utf-8 -*-
# QA item [7] M59: borrar slot con confirmación (DataStore.borrar_slot sobre slot real)
extends SceneTree

func _initialize() -> void:
	call_deferred("_correr")

func _correr() -> void:
	await process_frame
	await process_frame
	var fallos := 0

	var ds := root.get_node_or_null("/root/DataStore")
	if ds == null:
		print("[QA-BORRAR] FAIL: DataStore ausente")
		quit(1)
		return

	# 0) preparar: asegurar slot 1 existente (guardado mínimo)
	var prov = load("res://scripts/saving/player_save_provider.gd").new()
	var res: Dictionary = ds.guardar_partida(1, {"player": prov.get_save_data()})
	if not bool(res.get("ok", false)):
		print("[QA-BORRAR] FAIL: el guardado de preparación no funcionó")
		quit(1)
		return
	print("[QA-BORRAR] OK slot 1 preparado")

	# 1) borrar_slot sobre slot existente → true
	var ok: bool = ds.borrar_slot(1)
	if not ok:
		fallos += 1
		print("[QA-BORRAR] FALLO: borrar_slot devolvió false con slot existente")
	else:
		print("[QA-BORRAR] OK borrado del slot 1 (true)")

	# 2) tras el borrado, el slot ya no existe
	var existe: bool = load("res://scripts/datos/gestor_slot.gd").existe_slot(1)
	if existe:
		fallos += 1
		print("[QA-BORRAY] FALLO: el slot sigue existiendo tras el borrado")
	else:
		print("[QA-BORRAR] OK slot inexistente tras borrado")

	# 3) borrar un slot inexistente → false (sin crash)
	var ok2: bool = ds.borrar_slot(1)
	if ok2:
		fallos += 1
		print("[QA-BORRAR] FALLO: borrar sobre slot inexistente devolvió true")
	else:
		print("[QA-BORRAR] OK borrar slot inexistente = false")

	var pausita = load("res://scripts/ui/layers/pause_layer.gd").new()
	root.add_child(pausita)
	await process_frame
	if pausita._boton_borrar == null:
		fallos += 1
		print("[QA-BORRAR] FALLO: botón borrar no creado en la pausa")
	else:
		print("[QA-BORRAR] OK botón borrar creado (texto: ", pausita._boton_borrar.text, ")")

	pausita.queue_free()
	print("[QA-BORRAR] RESULTADO=", "OK" if fallos == 0 else "FAIL(%d)" % fallos)
	quit(0 if fallos == 0 else 1)
