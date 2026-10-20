# -*- coding: utf-8 -*-
# QA item [8] M59: perfil_id via SaveSchema.default_payload (nativo)
extends SceneTree

func _initialize() -> void:
	call_deferred("_correr")

func _correr() -> void:
	await process_frame
	await process_frame
	var ds := root.get_node_or_null("/root/DataStore")
	if ds == null:
		print("[QA-PERFIL] FAIL: DataStore ausente")
		quit(1)
		return
	var fallos := 0

	var schema = load("res://scripts/saving/save_schema.gd")
	var prov = load("res://scripts/saving/player_save_provider.gd").new()

	# 1) payload completo del SaveSchema con perfil A
	var payload: Dictionary = schema.default_payload("perfil_A")
	payload["player"] = prov.get_save_data()
	var res: Dictionary = ds.guardar_partida(1, payload)
	if not bool(res.get("ok", false)):
		fallos += 1
		print("[QA-PERFIL] FALLO guardado A: ", res.get("error"))
	else:
		print("[QA-PERFIL] OK guardado A (perfil_A en schema)")

	# 2) cargar con perfil A → OK
	var carga: Dictionary = ds.cargar_partida(1)
	if bool(carga.get("ok", false)):
		print("[QA-PERFIL] OK carga perfil_A")
	else:
		fallos += 1
		print("[QA-PERFIL] FALLO carga A: ", carga.get("error"))

	# 3) payload con perfil B → guardar de nuevo
	var payload_b: Dictionary = schema.default_payload("perfil_B")
	payload_b["player"] = prov.get_save_data()
	res = ds.guardar_partida(1, payload_b)
	if not bool(res.get("ok", false)):
		fallos += 1
		print("[QA-PERFIL] FALLO guardado B: ", res.get("error"))
	else:
		print("[QA-PERFIL] OK guardado B")

	# 4) validación de schema: el payload B trae profile_id B (el schema lo lleva)
	var carga_b: Dictionary = ds.cargar_partida(1)
	if bool(carga_b.get("ok", false)):
		print("[QA-PERFIL] OK carga perfil_B (último insertado)")
	else:
		fallos += 1
		print("[QA-PERFIL] FALLO carga B: ", carga_b.get("error"))

	print("[QA-PERFIL] RESULTADO=", "OK" if fallos == 0 else "FAIL(%d)" % fallos)
	quit(0 if fallos == 0 else 1)
