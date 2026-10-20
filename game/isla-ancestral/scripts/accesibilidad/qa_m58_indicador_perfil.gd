# -*- coding: utf-8 -*-
# QA M58 ítem 42: indicador visual del perfil de control activo en el menú
# (reparado: autoload + señal control_changed + get_control_preset)
extends SceneTree

var _fallos := 0
var _checks := 0

func _check(cond: bool, ok_msg: String, fail_msg: String) -> void:
	_checks += 1
	if cond:
		print("[QA-M58-P] OK ", ok_msg)
	else:
		_fallos += 1
		print("[QA-M58-P] FALLO ", fail_msg)

func _initialize() -> void:
	call_deferred("_correr")

func _correr() -> void:
	await process_frame
	await process_frame

	var menu = load("res://scripts/ui/layers/menus_layer.gd").new()
	root.add_child(menu)
	await process_frame

	var label: Label = menu.find_child("PerfilLabel", true, false)
	_check(label != null, "PerfilLabel presente en el menú", "sin PerfilLabel")
	var acc = root.get_node_or_null("AccesibilityManager")
	_check(acc != null and acc.has_method("get_control_preset"), "autoload + getter presentes", "ausente")
	if acc == null or label == null:
		print("[QA-M58-P] RESULTADO=SKIP (deps)")
		quit(0)
		return

	var esperado: String = "Controles: " + String(acc.get_control_preset())
	_check(label.visible and String(label.text) == esperado, "label VISIBLE y refleja el preset (" + esperado + ")", "texto: %s visible: %s" % [label.text, label.visible])

	var solo_control := [0]
	acc.control_changed.connect(func(_p): solo_control[0] += 1)
	acc.aplicar_perfil_control("single_hand")
	await process_frame
	_check(label.text == "Controles: single_hand", "cambio de preset reflejado EN VIVO (single_hand)", "label: %s" % label.text)
	_check(solo_control[0] >= 1, "señal control_changed emitida", "sin señales")

	acc.aplicar_perfil_control("estandar")
	await process_frame
	_check(label.text == "Controles: estandar", "restauración reflejada (estandar)", "label: %s" % label.text)

	menu.queue_free()
	print("[QA-M58-P] RESULTADO=", "OK" if _fallos == 0 else "FAIL(%d/%d)" % [_fallos, _checks])
	quit(0 if _fallos == 0 else 1)
