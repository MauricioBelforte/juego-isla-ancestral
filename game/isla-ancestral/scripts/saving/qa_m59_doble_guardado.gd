# -*- coding: utf-8 -*-
# QA M59 item 58(59): doble guardado simultáneo — la cola serializa (orden FIFO)
extends SceneTree

var _fallos := 0
var _checks := 0

func _check(cond: bool, ok_msg: String, fail_msg: String) -> void:
	_checks += 1
	if cond:
		print("[QA-M59-DG] OK ", ok_msg)
	else:
		_fallos += 1
		print("[QA-M59-DG] FALLO ", fail_msg)

func _initialize() -> void:
	call_deferred("_correr")

func _correr() -> void:
	await process_frame
	await process_frame

	var sm = root.get_node_or_null("SaveManager")
	_check(sm != null and sm.has_method("request_save"), "SaveManager presente", "ausente")

	var orden: Array = []
	sm.save_completed.connect(func(slot, reason): orden.append(reason))

	# Dos request_save EN EL MISMO frame (ráfaga simultánea):
	sm.request_save(1, "rafaga_A")
	sm.request_save(1, "rafaga_B")
	var completados := 0
	for i in 180:
		await process_frame
		completados = orden.size()
		if completados >= 2:
			break
	_check(orden.size() >= 2, "ambos guardados completaron (cola los procesó en serie)", "completados insuficientes")
	_check(orden[0] == "rafaga_A", "orden FIFO: la primera solicitada termina primero", "orden roto: %s" % str(orden))
	# Ningún corrimientó destructivo: el segundo también llegó a EXITO.
	_check("rafaga_B" in orden, "la segunda petición no se perdió", "se perdió rafaga_B")

	print("[QA-M59-DG] RESULTADO=", "OK" if _fallos == 0 else "FAIL(%d/%d)" % [_fallos, _checks])
	quit(0 if _fallos == 0 else 1)
