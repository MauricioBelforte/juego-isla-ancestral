# -*- coding: utf-8 -*-
# QA item [8] M59: perfil_id en el archivo + validación al cargar (sin cruzamiento)
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

	var prov = load("res://scripts/saving/player_save_provider.gd").new()

	# 1) guardar con perfil_default → cargar OK
	var res: Dictionary = ds.guardar_partida(1, {"player": prov.get_save_data()})
	if not bool(res.get("ok", false)):
		fallos += 1
		print("[QA-PERFIL] FALLO: guardado base falló (", res.get("error"), ")")
	else:
		print("[QA-PERFIL] OK guardado base")
	var carga: Dictionary = ds.cargar_partida(1)
	if bool(carga.get("ok", false)):
		print("[QA-PERFIL] OK carga con mismo perfil")
	else:
		fallos += 1
		print("[QA-PERFIL] FALLO carga mismo perfil: ", carga.get("error"))

	# 2) cambiar perfil activo → cargar → RECHAZADO como cruzado
	ds.set_perfil_activo("perfil_otro")
	carga = ds.cargar_partida(1)
	if not bool(carga.get("ok", false)) and "Perfil cruzado" in str(carga.get("error", "")):
		print("[QA-PERFIL] OK rechazo por cruzamiento de perfil")
	else:
		fallos += 1
		print("[QA-PERFIL] FALLO: el cruzamiento no se rechazó (", carga, ")")

	# 3) volver a perfil_default → carga OK de nuevo
	ds.set_perfil_activo("")
	carga = ds.cargar_partida(1)
	if bool(carga.get("ok", false)):
		print("[QA-PERFIL] OK re-carga con perfil original")
	else:
		fallos += 1
		print("[QA-PERFIL] FALLO re-carga perfil original: ", carga.get("error"))

	# 4) el meta.json registra el perfil_id
	var meta: Dictionary = load("res://scripts/datos/gestor_slot.gd").leer_meta(1)
	if str(meta.get("perfil_id", "")) == "perfil_default":
		print("[QA-PERFIL] OK meta registra perfil_id")
	else:
		fallos += 1
		print("[QA-PERFIL] FALLO meta sin perfil_id: ", meta)

	print("[QA-PERFIL] RESULTADO=", "OK" if fallos == 0 else "FAIL(%d)" % fallos)
	quit(0 if fallos == 0 else 1)
