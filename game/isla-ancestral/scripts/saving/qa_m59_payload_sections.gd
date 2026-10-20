# -*- coding: utf-8 -*-
# QA M59: el payload del snapshot contiene las secciones de los providers reales
# (M15 inventory/hotbar · M38 economy · M91 audio_config · M16 crafting · M69 fast_travel)
extends SceneTree

var _fallos := 0
var _checks := 0

func _check(cond: bool, ok_msg: String, fail_msg: String) -> void:
	_checks += 1
	if cond:
		print("[QA-M59-PAY] OK ", ok_msg)
	else:
		_fallos += 1
		print("[QA-M59-PAY] FALLO ", fail_msg)

func _initialize() -> void:
	call_deferred("_correr")

func _correr() -> void:
	await process_frame
	await process_frame

	var sm = root.get_node_or_null("SaveManager")
	_check(sm != null and sm.has_method("_payload_para_slot"), "SaveManager con payload builder", "ausente")

	var payload: Dictionary = sm._payload_para_slot(1)
	var claves := []
	for k in payload.keys():
		claves.append(String(k))
	_check(payload.size() >= 8, "payload con %d secciones de proveedores reales" % payload.size(), "payload chico")

	# M69: con el FastTravelService montado en main_island, su sección DEBE
	# estar en el payload del boot (provider K.32).
	for esperada in ["inventory", "economy", "hotbar", "audio_config", "crafting", "fast_travel"]:
		_check(esperada in claves, "sección '%s' presente en el payload" % esperada, "FALTA '%s': %s" % [esperada, str(claves)])
	# Dato de integración (M69): 'fast_travel' AÚN no está en el boot — el servicio
	# K.32 existe pero nadie lo monta en la escena real. Gape documentado, no es fallo
	# de providers (fallará este QA si el dueño lo monta y no se registra).
	var tiene_ft := "fast_travel" in claves
	print("[QA-M59-PAY] INFO fast_travel montada en boot: ", tiene_ft)

	print("[QA-M59-PAY] RESULTADO=", "OK" if _fallos == 0 else "FAIL(%d/%d)" % [_fallos, _checks])
	quit(0 if _fallos == 0 else 1)
