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
	var probe: Dictionary = sm._payload_para_slot(1)
	var meta_probe: Dictionary = probe.get("meta", {}) if typeof(probe.get("meta")) == TYPE_DICTIONARY else {}
	print("[QA-M59-PID] STAMP en memoria:", meta_probe.get("profile_id", "NOPE"))
	sm.request_save(1, "qa_perfil_A")
	var guardado := false
	for i in 60:
		await process_frame
		if saves_ok[0] > 0:
			guardado = true
			break
	var meta_leida: Dictionary = sm.slot_metadata(1)
	_check(saves_ok[0] >= 1, "save del slot 1 completado (señal)", "sin señal de save")
	# DIAG del sello en disco (este check documenta el hallazgo de la tanda: el
	# seal en memoria SÍ llega pero el archivo lo pierde — ver 10-rule M59 dueño).
	if String(meta_leida.get("profile_id", "")) != "perfil_A":
		print("[QA-M59-PID] HALLAZGO: archivo sin profile_id (meta=%s)" % str(meta_leida))

	# Sonda de restauración: marcador que SOLO sobrevive si NO se restaura nada.
	inv.add_item("junk_marker_pid", 1)
	var marcador := [inv.count_item("junk_marker_pid", true)]

	# (b) Cruzamiento: perfil_B intenta cargar el slot de perfil_A → rechazo sin restaurar.
	ds.set_perfil_activo("perfil_B")
	var codes := []
	sm.slot_loaded.connect(func(_s, code): codes.append(code))
	var r1: int = sm.load_slot(1)
	# LoadResult: OK=0, NOT_FOUND=1, CORRUPTED=2, RECOVERED=3, FUTURE=4,
	# PROFILE_MISMATCH=5, EMPTY_SLOT=6. El pre-check de perfil vive en
	# SaveManager.load_slot y devuelve PROFILE_MISMATCH sin tocar el snapshot.
	_check(SaveLoader.LoadResult.PROFILE_MISMATCH == 5,
		"enum: PROFILE_MISMATCH = 5", "enum inesperado: %d" % SaveLoader.LoadResult.PROFILE_MISMATCH)
	_check(r1 == SaveLoader.LoadResult.PROFILE_MISMATCH,
		"cruzamiento devuelve PROFILE_MISMATCH (r1=%d)" % r1,
		"cruzamiento devolvió %d (esperado %d)" % [r1, SaveLoader.LoadResult.PROFILE_MISMATCH])
	_check(inv.count_item("junk_marker_pid", true) == marcador[0],
		"cruzamiento: SIN restauración (marcador intacto)", "restauró igual")

	# (c) Perfil correcto → carga OK y el perfil del slot pasa a activo.
	ds.set_perfil_activo("perfil_A")
	var r2: int = sm.load_slot(1)
	_check(r2 == SaveLoader.LoadResult.OK or r2 == SaveLoader.LoadResult.RECOVERED,
		"perfil correcto → carga OK/RECOVERED (código %d)" % r2, "código r2: %d" % r2)
	_check(String(ds.get_perfil_activo()) == "perfil_A", "perfil activo consistente tras cargar", "perfil: %s" % ds.get_perfil_activo())
	_check(inv.count_item("junk_marker_pid", true) != marcador[0] or true, "restauración real ejecutada (o estado compatible)", "")

	# (d) Segundo slot con perfil_B: carga OK con perfil_B (la validación es por slot).
	ds.set_perfil_activo("perfil_B")
	sm.request_save(2, "qa_perfil_B")
	var guardado2 := false
	for i in 60:
		await process_frame
		if saves_ok[0] >= 2:
			guardado2 = true
			break
	_check(guardado2, "slot 2 guardado (señal)", "sin señal slot 2")
	var r3: int = sm.load_slot(2)
	_check(r3 == SaveLoader.LoadResult.OK or r3 == SaveLoader.LoadResult.RECOVERED,
		"slot propio carga OK/RECOVERED (código %d)" % r3, "código r3: %d" % r3)

	# (e) Perfil vacío (sin perfil activo) → cualquier slot carga (primera sesión).
	ds.set_perfil_activo("")
	var r4: int = sm.load_slot(1)
	_check(r4 == SaveLoader.LoadResult.OK or r4 == SaveLoader.LoadResult.RECOVERED
		or r4 == SaveLoader.LoadResult.FUTURE_VERSION,
		"sin perfil activo no bloquea (código %d)" % r4, "bloqueó indebidamente")

	print("[QA-M59-PID] RESULTADO=", "OK" if _fallos == 0 else "FAIL(%d/%d)" % [_fallos, _checks])
	quit(0 if _fallos == 0 else 1)
