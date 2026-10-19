# -*- coding: utf-8 -*-
# QA del TravelLayer (item [31] RF3: travesía visible) — flujo live headless
extends SceneTree

func _initialize() -> void:
	call_deferred("_correr")

func _correr() -> void:
	await process_frame
	await process_frame
	var fallos := 0

	var capa = load("res://scripts/viajes/travel_layer.gd").new()
	root.add_child(capa)
	await process_frame

	# 1) cerrada al inicio
	if capa.visible:
		fallos += 1
		print("[QA-TRAVEL] FALLO: capa visible al inicio")
	else:
		print("[QA-TRAVEL] OK cerrada al inicio")

	# 2) travel_started la abre
	capa._on_started(&"tmp_ruta")
	await process_frame
	if not capa.visible:
		fallos += 1
		print("[QA-TRAVEL] FALLO: no abrió con travel_started")
	else:
		print("[QA-TRAVEL] OK abre con started")

	# 3) progress 50% reflete barra y label
	capa._on_progress(0.5)
	await process_frame
	var val: float = float(capa._barra.value)
	if absf(val - 0.5) > 0.01 or capa._label_porcentaje.text != "50%":
		fallos += 1
		print("[QA-TRAVEL] FALLO progreso:", val, capa._label_porcentaje.text)
	else:
		print("[QA-TRAVEL] OK barra y % a 50")

	# 4) progress 100 → 100%
	capa._on_progress(1.0)
	if capa._label_porcentaje.text != "100%":
		fallos += 1
		print("[QA-TRAVEL] FALLO 100%:", capa._label_porcentaje.text)
	else:
		print("[QA-TRAVEL] OK 100%")

	# 5) arrived cierra
	capa._on_arrived("isla_test")
	if capa.visible:
		fallos += 1
		print("[QA-TRAVEL] FALLO: sigue visible tras arrived")
	else:
		print("[QA-TRAVEL] OK cierra con arrived")

	# 6) cancel cierra
	capa._on_started(&"tmp2")
	capa._on_cancelled(5)
	if capa.visible:
		fallos += 1
		print("[QA-TRAVEL] FALLO: sigue visible tras cancel")
	else:
		print("[QA-TRAVEL] OK cierra con cancel")

	capa.queue_free()
	print("[QA-TRAVEL] RESULTADO=", "OK" if fallos == 0 else "FAIL(%d)" % fallos)
	quit(0 if fallos == 0 else 1)
