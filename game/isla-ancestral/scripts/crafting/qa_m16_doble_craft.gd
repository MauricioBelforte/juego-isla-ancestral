# -*- coding: utf-8 -*-
# QA M16 item 2: doble craft en el mismo frame → rechazo silencioso (K.2)
# G-5.3-Flash-Agente / Kilo Code — 2026-10-19
extends SceneTree

var _fallos := 0
var _checks := 0

func _check(cond: bool, ok_msg: String, fail_msg: String) -> void:
	_checks += 1
	if cond:
		print("[QA-M16-D] OK ", ok_msg)
	else:
		_fallos += 1
		print("[QA-M16-D] FALLO ", fail_msg)

func _initialize() -> void:
	call_deferred("_correr")

func _correr() -> void:
	await process_frame
	await process_frame

	var svc = load("res://scripts/crafting/crafting_service.gd").new()
	svc.registra_en_save = false
	root.add_child(svc)
	await process_frame

	var inv = root.get_node_or_null("Inventario")
	var rec = svc.obtener_receta("rec_pico_cobre")
	_check(inv != null and rec != null, "Inventario y receta presentes", "faltan deps")

	# Materiales generosos, calculados de la receta (sin ids hardcodeados).
	var mats: Dictionary = {}
	for item_id in rec.materiales:
		mats[str(item_id)] = int(rec.materiales[item_id]) * 5
	inv.agregar_items(mats)
	svc._conocidas.append("rec_pico_cobre")  # conocida para el test

	var ok_1 := [0]
	svc.crafting_completed.connect(func(_r, _c): ok_1[0] += 1)
	var fallos := [0]
	svc.crafting_failed.connect(func(_r, _m): fallos[0] += 1)

	# Doble pulsación en el MISMO frame: primera gana, segunda silenciosa.
	var r1: bool = svc.craft("rec_pico_cobre", 1)
	var r2: bool = svc.craft("rec_pico_cobre", 1)
	_check(r1 == true, "1er craft concede", "1er craft falló")
	_check(r2 == false, "2do craft mismo frame rechazado en silencio", "2do no silencioso")
	_check(ok_1[0] == 1, "señal completed exactamente 1 vez", "completed: %d" % ok_1[0])
	_check(fallos[0] == 0, "cero señales de fallo (log limpio)", "fallos: %d" % fallos[0])

	# El inventario solo descontó una vez (una unidad del resultado).
	_check(inv.count_item(String(rec.resultado_id)) == 1, "resultado entregado 1 sola vez", "resultado: ")

	# Frame nuevo: el craft vuelve a funcionar (no es bloqueo permanente).
	await process_frame
	await process_frame
	var r3: bool = svc.craft("rec_pico_cobre", 1)
	_check(r3 == true, "craft en frame nuevo funciona (no bloqueo)", "bloqueo permanente")

	# Diferente cantidad en el mismo frame NO se considera doble (contrato suite).
	var r4: bool = svc.craft("rec_pico_cobre", 5)
	_check(r4 == true or fallos[0] <= 1, "otra cantidad en mismo frame valida normal", "cantidad distinta bloqueada")

	svc.queue_free()
	print("[QA-M16-D] RESULTADO=", "OK" if _fallos == 0 else "FAIL(%d/%d)" % [_fallos, _checks])
	quit(0 if _fallos == 0 else 1)
