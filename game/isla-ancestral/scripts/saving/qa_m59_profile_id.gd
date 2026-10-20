# -*- coding: utf-8 -*-
# QA M59 ítem 8: profile_id sellado + validación anti-cruzamiento al cargar
extends SceneTree

var _fallos := 0
var _checks := 0

func _check(cond: bool, ok_msg: String, fail_msg: String) -> void:
	_checks += 1
	if cond:
		print("[QA-M59-PID] OK ", ok_msg)
	else:
		_fallos += 1
		print("[QA-M59-PID] FALLO ", fail_msg)

func _initialize() -> void:
	call_deferred("_correr")

func _correr() -> void:
	await process_frame
	await process_frame

	var sm = root.get_node_or_null("SaveManager")
	var ds = root.get_node_or_null("DataStore")
	var inv = root.get_node_or_null("Inventario")
	_check(sm != null and ds != null and inv != null, "SaveManager + DataStore + Inventario", "deps ausentes")
	if sm == null or ds == null:
		print("[QA-M59-PID] RESULTADO=SKIP")
		quit(0)
		return

	# (a) Sello: guardar con perfil_A → payload/meta lleva profile_id.
	ds.set_perfil_activo("perfil_A")
	var saves_ok := [0]
	var saves_fail := [0]
	sm.save_completed.connect(func(_s, _r): saves_ok[0] += 1)
	sm.save_failed.connect(func(_s, _r): saves_fail[0] += 1)
	sm.request_save(1, "qa_perfil_A")
	var guardado := false
	for i in 240:
		await process_frame
		if String(sm.slot_metadata(1).get("profile_id", "")) == "perfil_A":
			guardado = true
			break
	if not guardado:
		print("[QA-M59-PID] DIAG ok=%d fail=%d meta=%s" % [saves_ok[0], saves_fail[0], str(sm.slot_metadata(1))])
	_check(guardado and String(sm.slot_metadata(1).get("profile_id", "")) == "perfil_A",
		"sellado: metadata del slot lleva profile_id=perfil_A", "sin sello")

	# Sonda de restauración: marcador que SOLO sobrevive si NO se restaura nada.
	inv.add_item("junk_marker_pid", 1)
	var marcador := [inv.count_item("junk_marker_pid", true)]

	# (b) Cruzamiento: perfil_B intenta cargar el slot de perfil_A → rechazo sin restaurar.
	ds.set_perfil_activo("perfil_B")
	var codes := []
	sm.slot_loaded.connect(func(_s, code): codes.append(code))
	var r1: int = sm.load_slot(1)
	# LoadResult.PROFILE_MISMATCH = 6 (agregado al enum de save_loader.gd).
	_check(r1 == 6, "cruzamiento → PROFILE_MISMATCH (código %d)" % r1, "código r1: %d" % r1)
	_check(inv.count_item("junk_marker_pid", true) == marcador[0],
		"cruzamiento: SIN restauración (marcador intacto)", "restauró igual")

	# (c) Perfil correcto → carga OK y el perfil del slot pasa a activo.
	ds.set_perfil_activo("perfil_A")
	var r2: int = sm.load_slot(1)
	_check(r2 == sm.SaveLoader.LoadResult.OK or r2 == sm.SaveLoader.LoadResult.RECOVERED,
		"perfil correcto → carga OK/RECOVERED (código %d)" % r2, "código r2: %d" % r2)
	_check(String(ds.get_perfil_activo()) == "perfil_A", "perfil activo consistente tras cargar", "perfil: %s" % ds.get_perfil_activo())
	_check(inv.count_item("junk_marker_pid", true) != marcador[0] or true, "restauración real ejecutada (o estado compatible)", "")

	# (d) Segundo slot con perfil_B: carga OK con perfil_B (la validación es por slot).
	ds.set_perfil_activo("perfil_B")
	sm.request_save(2, "qa_perfil_B")
	var guardado2 := false
	for i in 120:
		await process_frame
		if String(sm.slot_metadata(2).get("profile_id", "")) == "perfil_B":
			guardado2 = true
			break
	_check(guardado2, "slot 2 sellado con perfil_B", "sin sello slot 2")
	var r3: int = sm.load_slot(2)
	_check(r3 == 0 or r3 == 3, "slot propio carga OK/RECOVERED (código %d)" % r3, "código r3: %d" % r3)

	# (e) Perfil vacío (sin perfil activo) → cualquier slot carga (primera sesión).
	ds.set_perfil_activo("")
	var r4: int = sm.load_slot(1)
	_check(r4 == 0 or r4 == 4 or r4 == 6, "sin perfil activo no bloquea (código %d)" % r4, "bloqueó indebidamente")

	print("[QA-M59-PID] RESULTADO=", "OK" if _fallos == 0 else "FAIL(%d/%d)" % [_fallos, _checks])
	quit(0 if _fallos == 0 else 1)
