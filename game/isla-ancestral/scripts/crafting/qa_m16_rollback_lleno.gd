# -*- coding: utf-8 -*-
# QA M16 item 11: rollback exacto ante inventario lleno en ambos destinos (BOLSILLO+CASA)
# G-5.3-Flash-Agente / Kilo Code — 2026-10-19
extends SceneTree

var _fallos := 0
var _checks := 0

func _check(cond: bool, ok_msg: String, fail_msg: String) -> void:
	_checks += 1
	if cond:
		print("[QA-M16-RB] OK ", ok_msg)
	else:
		_fallos += 1
		print("[QA-M16-RB] FALLO ", fail_msg)

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
	_check(inv != null, "Inventario presente", "ausente")

	var rec = svc.obtener_receta("rec_ensalada_bayas")
	svc._conocidas.append("rec_ensalada_bayas")
	_check(rec != null, "receta ensalada presente", "sin receta")

	# Llenar BOLSILLO, MOCHILA y CASA con ids únicos hasta ocupar TODOS los
	# slots; los materiales de la ensalada (baya_roja) ocupan su propio slot.
	var baya_id := ""
	for item_id in rec.materiales:
		baya_id = String(item_id)
		break
	_check(baya_id != "", "material de la receta identificado (%s)" % baya_id, "receta sin materiales")

	var contenedores := [0, 2, 3]  # BOLSILLO, CASA y MOCHILA (ids CONTAINER_TYPE)
	var junks := 0
	for c_app in [0, 1, 3]:
		var total: int = inv.total_slots(c_app)
		while inv.used_slots(c_app) < total:
			junks += 1
			inv.add_item("junk_%03d" % junks, 1, c_app)
	# Reponer los materiales por si algún fill de junk los pisara (capacidad exacta).
	inv.agregar_items(rec.materiales)
	var llenos := true
	for c_app in [0, 1, 3]:
		if inv.used_slots(c_app) != inv.total_slots(c_app):
			llenos = false
	_check(llenos, "los 3 contenedores quedaron llenos", "no quedaron llenos")

	# Snapshot exacto de TODO el estado (counts desde el servicio).
	var estado_antes := {}
	for item_id in rec.materiales:
		estado_antes[String(item_id)] = inv.count_item(String(item_id), true)

	var fallos_r := [0]
	var motivos := []
	svc.crafting_failed.connect(func(_r, m): fallos_r[0] += 1; motivos.append(String(m)))
	var ok := [0]
	svc.crafting_completed.connect(func(_r, _c): ok[0] += 1)

	var r1: bool = svc.craft("rec_ensalada_bayas", 1)
	_check(r1 == false, "craft con inventario lleno falla", "craft aceptó lleno")
	_check(fallos_r[0] == 1 and motivos[0] == "inventario_lleno", "motivo 'inventario_lleno'", "motivo: %s" % str(motivos))
	_check(ok[0] == 0, "sin señal de completed", "completed emitido")

	# ROLLBACK EXACTO: cada material conservó su cantidad (aún estando llenos).
	var exacto := true
	for item_id in rec.materiales:
		if inv.count_item(String(item_id), true) != int(estado_antes[String(item_id)]):
			exacto = false
	_check(exacto, "rollback exacto: cada material conserva su cantidad", "materiales desbalanceados")
	_check(inv.count_item(String(rec.resultado_id), true) == estado_antes.get(String(rec.resultado_id), 0), "sin resultado fabricado", "resultado apareció")

	svc.queue_free()
	print("[QA-M16-RB] RESULTADO=", "OK" if _fallos == 0 else "FAIL(%d/%d)" % [_fallos, _checks])
	quit(0 if _fallos == 0 else 1)
