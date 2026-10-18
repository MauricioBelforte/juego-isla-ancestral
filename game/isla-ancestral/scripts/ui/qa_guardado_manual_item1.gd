# -*- coding: utf-8 -*-
# QA item 2 (M59): guardado manual + lectura de guardado_iso del meta
extends SceneTree

func _initialize() -> void:
	call_deferred("_correr")

func _correr() -> void:
	await process_frame
	await process_frame
	var ds := root.get_node_or_null("/root/DataStore")
	if ds == null:
		print("[QA-GUARDADO2] FAIL: DataStore ausente")
		quit(1)
		return
	var payload := {"player": {}}
	var prov = load("res://scripts/saving/player_save_provider.gd").new()
	payload["player"] = prov.get_save_data()
	var res: Dictionary = ds.guardar_partida(1, payload)
	var ok1 := bool(res.get("ok", false))
	var gestor := load("res://scripts/datos/gestor_slot.gd")
	var meta: Dictionary = gestor.leer_meta(1)
	var iso := str(meta.get("guardado_iso", ""))
	var ok2 := iso != ""
	print("[QA-GUARDADO2] guardado ok=", ok1, " | guardado_iso presente=", ok2, " | iso=", iso)
	var exito := ok1 and ok2
	print("[QA-GUARDADO2] RESULTADO=", "OK" if exito else "FAIL")
	quit(0 if exito else 1)
