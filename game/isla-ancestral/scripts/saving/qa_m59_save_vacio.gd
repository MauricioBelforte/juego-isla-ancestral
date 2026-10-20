# -*- coding: utf-8 -*-
# QA M59 item 45: guardar con estado de primer minuto (inventario sin añadir) — G-5.3-Flash-Agente
extends SceneTree

var _fallos := 0
var _checks := 0

func _check(cond: bool, ok_msg: String, fail_msg: String) -> void:
	_checks += 1
	if cond:
		print("[QA-M59-E] OK ", ok_msg)
	else:
		_fallos += 1
		print("[QA-M59-E] FALLO ", fail_msg)

func _initialize() -> void:
	call_deferred("_correr")

func _correr() -> void:
	await process_frame
	await process_frame

	var sm = root.get_node_or_null("SaveManager")
	var inv = root.get_node_or_null("Inventario")
	_check(sm != null and inv != null, "SaveManager e Inventario presentes", "faltan services")

	# Estado "primer minuto": nada agregado por el test (boot limpio).
	var completados := [0]
	var fallados := [0]
	sm.save_completed.connect(func(_s, _r): completados[0] += 1)
	sm.save_failed.connect(func(_s, _r): fallados[0] += 1)

	sm.request_save(1, "primer_minuto_qa")
	var listo := false
	for i in 120:
		await process_frame
		if completados[0] > 0:
			listo = true
			break
	_check(listo, "guardado del primer minuto completado (cola real)", "no completó")
	_check(fallados[0] == 0, "sin fallos de guardado con estado vacío", "fallos: %d" % fallados[0])
	_check(sm.has_method("is_dirty") and not sm.is_dirty(), "dirty limpiado tras guardar", "dirty quedó activo")

	print("[QA-M59-E] RESULTADO=", "OK" if _fallos == 0 else "FAIL(%d/%d)" % [_fallos, _checks])
	quit(0 if _fallos == 0 else 1)
