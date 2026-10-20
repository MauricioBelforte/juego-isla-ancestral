# -*- coding: utf-8 -*-
# QA M16 item 9: registro de recetas — sin duplicados, carga idempotente
extends SceneTree

var _fallos := 0
var _checks := 0

func _check(cond: bool, ok_msg: String, fail_msg: String) -> void:
	_checks += 1
	if cond:
		print("[QA-M16-R] OK ", ok_msg)
	else:
		_fallos += 1
		print("[QA-M16-R] FALLO ", fail_msg)

func _initialize() -> void:
	call_deferred("_correr")

func _correr() -> void:
	await process_frame
	await process_frame

	var svc = load("res://scripts/crafting/crafting_service.gd").new()
	svc.registra_en_save = false
	root.add_child(svc)
	await process_frame

	# 1. No hay ids duplicados en el registro cargado del JSON (M93 via Balance).
	var ids := []
	for rec_id in svc._recetas.keys():
		ids.append(String(rec_id))
	var unicos := {}
	for i in ids:
		unicos[i] = true
	_check(ids.size() == unicos.size(), "0 ids duplicados en %d recetas" % ids.size(), "duplicados: %d vs %d" % [ids.size(), unicos.size()])
	_check(ids.size() > 0, "catálogo cargado no vacío", "vacío")

	# 2. Recarga idempotente: _cargar_recetas() dos veces no duplica ni pisa estados.
	var antes: int = svc._recetas.size()
	svc._cargar_recetas()
	_check(svc._recetas.size() == antes, "recarga idempotente (mismo tamaño)", "cargó de más: %d vs %d" % [antes, svc._recetas.size()])

	# 3. Conocimiento tampoco duplica al recargar (origen=inicial no vuelve a emitir/apilar).
	svc._cargar_recetas()
	var conocidas: Array = svc._conocidas.duplicate()
	var sin_dup := {}
	for c in conocidas:
		sin_dup[String(c)] = true
	_check(conocidas.size() == sin_dup.size(), "conocidas sin duplicados (%d)" % conocidas.size(), "dup en conocidas")

	# 4. La señal receta_aprendida NO se emite en la recarga (carga inicial sin emitir).
	var resonancias := [0]
	svc.receta_aprendida.connect(func(_r): resonancias[0] += 1)
	svc._cargar_recetas()
	_check(resonancias[0] == 0, "recarga no dispara señales de aprendizaje", "señales: %d" % resonancias[0])

	svc.queue_free()
	print("[QA-M16-R] RESULTADO=", "OK" if _fallos == 0 else "FAIL(%d/%d)" % [_fallos, _checks])
	quit(0 if _fallos == 0 else 1)
