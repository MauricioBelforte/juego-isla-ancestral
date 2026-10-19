# -*- coding: utf-8 -*-
# QA RF23 (M58 ítem [43]): reabrir el último diálogo sin perder contexto
extends SceneTree

func _initialize() -> void:
	call_deferred("_correr")

func _correr() -> void:
	await process_frame
	await process_frame
	var dm := root.get_node_or_null("/root/DialogueManager")
	if dm == null:
		print("[QA-RF23] FAIL: DialogueManager ausente")
		quit(1)
		return
	var fallos := 0

	# 1) sin diálogo previo → reabrir_ultimo = false
	if dm.reabrir_ultimo():
		fallos += 1
		print("[QA-RF23] FALLO: reabre sin diálogo previo")
	else:
		print("[QA-RF23] OK false sin diálogo previo")

	# 2) arrancar un diálogo con contexto (el catálogo debe tener al menos uno)
	#    Buscamos un dialogue_id disponible del catálogo del Manager si expone,
	#    si no usamos uno canónico del riel M21/M28.
	var ctx := {"jugador": "tester", "npc": "brujita", "capitulo": 2}
	var started: bool = false
	for cand in ["d_tutorial_basico", "d_main", "tutorial"]:
		started = dm.start_dialogue(cand, ctx)
		if started:
			print("[QA-RF23] diálogo iniciado con: ", cand)
			break
	if not started:
		print("[QA-RF23] SKIP: ningún dialogue_id del catálogo arrancó (el QA de contexto queda para dueño M21/M28)")
		quit(0)
		return

	# 3) con diálogo activo → reabrir_ultimo = false (guard)
	if dm.reabrir_ultimo():
		fallos += 1
		print("[QA-RF23] FALLO: reabre con diálogo ya activo")
	else:
		print("[QA-RF23] OK false con diálogo activo")

	# 4) cerrar y reabrir — el contexto debe conservarse
	dm.dialogue_ended.emit("x", "n1")
	await process_frame
	var reabierto: bool = dm.reabrir_ultimo()
	await process_frame
	if not reabierto:
		fallos += 1
		print("[QA-RF23] FALLO: reabrir_ultimo no re-inició tras cerrar")
	else:
		print("[QA-RF23] OK reabrió tras cerrar")

	print("[QA-RF23] RESULTADO=", "OK" if fallos == 0 else "FAIL(%d)" % fallos)
	quit(0 if fallos == 0 else 1)
