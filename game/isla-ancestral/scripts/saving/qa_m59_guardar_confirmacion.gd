# -*- coding: utf-8 -*-
# QA M59 item 1: botón Guardar en pausa — confirmación popup + guardado real + toast
# G-5.3-Flash-Agente / Kilo Code — 2026-10-19
extends SceneTree

var _fallos := 0
var _checks := 0

class StubPopup extends Control:
	var capturado: Array = []
	func configurar_texto(titulo: String, mensaje: String, on_ok: Callable) -> void:
		capturado = [titulo, mensaje, on_ok]

func _check(cond: bool, ok_msg: String, fail_msg: String) -> void:
	_checks += 1
	if cond:
		print("[QA-M59-G] OK ", ok_msg)
	else:
		_fallos += 1
		print("[QA-M59-G] FALLO ", fail_msg)

func _initialize() -> void:
	call_deferred("_correr")

func _correr() -> void:
	await process_frame
	await process_frame

	var pl = load("res://scripts/ui/layers/pause_layer.gd").new()
	root.add_child(pl)
	await process_frame

	var loc = root.get_node_or_null("Localization")
	var t_titulo: String = loc.traducir_clave("SETTINGS.GUARDAR_TITULO")
	var t_conf: String = loc.traducir_clave("SETTINGS.GUARDAR_CONFIRMA")
	var t_exito: String = loc.traducir_clave("SETTINGS.GUARDAR_EXITO")

	var toasts := []
	var bus = root.get_node_or_null("EventBus")
	if bus != null and "ui" in bus and bus.ui != null and "notify" in bus.ui:
		bus.ui.notify.connect(func(d): toasts.append(d))

	# (a) Sin popup montado: fallback → guardado directo real (SaveManager).
	pl._pedir_confirmacion_guardado()
	var guardado := false
	for i in 90:
		await process_frame
		for t in toasts:
			if String(t.get("id", "")) == "guardado_manual" and String(t.get("texto", "")) == t_exito:
				guardado = true
		if guardado:
			break
	_check(guardado, "fallback sin popup: guardado real + toast GUARDAR_EXITO", "no llegó el toast de éxito")

	# (b) Con popup (stub duck): captura título/mensaje/callback y solo硬 guarda al aceptar.
	var stub := StubPopup.new()
	stub.name = "ConfirmPopup"
	root.add_child(stub)
	await process_frame
	pl._pedir_confirmacion_guardado()
	_check(stub.capturado.size() == 3, "popup captura (título, mensaje, callback)", "popup no capturado")
	if stub.capturado.size() == 3:
		_check(String(stub.capturado[0]) == t_titulo and String(stub.capturado[1]) == t_conf,
			"textos de confirmación localizados", "textos incorrectos")
		var antes: int = toasts.size()
		stub.capturado[2].call()
		var aceptado := false
		for i in 90:
			await process_frame
			for t in toasts:
				if String(t.get("id", "")) == "guardado_manual" and String(t.get("texto", "")) == t_exito:
					aceptado = true
			if aceptado and toasts.size() > antes:
				break
		_check(aceptado, "al aceptar el popup guarda y notifica", "aceptar no guardó")

	pl.queue_free()
	stub.queue_free()
	print("[QA-M59-G] RESULTADO=", "OK" if _fallos == 0 else "FAIL(%d/%d)" % [_fallos, _checks])
	quit(0 if _fallos == 0 else 1)
