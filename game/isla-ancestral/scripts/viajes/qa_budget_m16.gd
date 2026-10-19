# -*- coding: utf-8 -*-
# QA item [22] M16 (M53/M61): presupuesto de apertura de la UI de crafting < 1 ms
extends SceneTree

func _initialize() -> void:
	call_deferred("_correr")

func _correr() -> void:
	await process_frame
	await process_frame
	var cs := root.get_node_or_null("/root/Crafting")
	if cs == null:
		print("[QA-BUDGET] FAIL: Crafting ausente")
		quit(1)
		return

	var t0 := Time.get_ticks_usec()
	var lista: Array = cs.recetas_por_estacion(0)
	for r in lista:
		pass
	var t1 := Time.get_ticks_usec()
	var dt: int = t1 - t0

	print("[QA-BUDGET] recetas estación 0: ", lista.size())
	print("[QA-BUDGET] tiempo apertura (recalc filtros): ", dt, " us")
	if dt < 1000:
		print("[QA-BUDGET] RESULTADO=OK (< 1 ms)")
	else:
		print("[QA-BUDGET] RESULTADO=FAIL (", dt, " us >= 1000)")
	quit(0 if dt < 1000 else 1)
