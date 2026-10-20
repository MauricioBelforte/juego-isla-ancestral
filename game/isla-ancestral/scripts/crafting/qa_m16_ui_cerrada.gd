# -*- coding: utf-8 -*-
# QA M16 item 3: cero cómputo de crafting con la UI cerrada — G-5.3-Flash-Agente
extends SceneTree

var _fallos := 0
var _checks := 0

func _check(cond: bool, ok_msg: String, fail_msg: String) -> void:
	_checks += 1
	if cond:
		print("[QA-M16-U] OK ", ok_msg)
	else:
		_fallos += 1
		print("[QA-M16-U] FALLO ", fail_msg)

func _initialize() -> void:
	call_deferred("_correr")

func _correr() -> void:
	await process_frame
	await process_frame

	var ui = load("res://scripts/crafting/crafting_ui.gd").new()
	root.add_child(ui)
	await process_frame

	# 1. Nace cerrado y sin loops de proceso (grep por fuente = sin _process).
	_check(ui.visible == false, "UI nace cerrada", "nace visible")
	var src_ui: String = String(ui.get_script().source_code)
	_check(src_ui.find("func _process") == -1, "UI sin _process (cero cámara por frame)", "tiene _process")
	var src_srv: String = String(load("res://scripts/crafting/crafting_service.gd").source_code)
	_check(src_srv.find("func _process") == -1, "service sin _process", "service tiene _process")
	var src_fb: String = String(load("res://scripts/crafting/crafting_feedback.gd").source_code)
	_check(src_fb.find("func _process") == -1, "feedback sin _process (solo señales)", "feedback tiene _process")

	# 2. Señal de craft result con la UI cerrada: guard visible corta ANTES de
	# escribir mensaje o refrescar (cero cómputo de listas/detalle/max_craftable).
	ui._on_craft_result(null, 1)
	_check(String(ui._mensaje_label.text) == "", "guard visible: sin refresh al estar cerrada", "refrescó cerrada")

	# 3. Abierta, el flujo resumed normalmente (no rompimos nada).
	ui.abrir(0)
	await process_frame
	_check(ui.visible == true, "abrir() sigue funcionando (regresión)", "abrir roto")
	ui.on_layer_closed()
	_check(ui.visible == false, "cierre por capa ok", "cierre roto")

	ui.queue_free()
	print("[QA-M16-U] RESULTADO=", "OK" if _fallos == 0 else "FAIL(%d/%d)" % [_fallos, _checks])
	quit(0 if _fallos == 0 else 1)
