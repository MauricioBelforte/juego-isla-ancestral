# -*- coding: utf-8 -*-
# QA M58 ítem 42: indicador visual del perfil de control activo en el menú
# (comportamiento existente, verificado con QA según GO del director 166)
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

	# 1. Existe el PerfilLabel y scrapea el perfil REAL del boot.
	var label: Label = menu.find_child("PerfilLabel", true, false)
	_check(label != null, "PerfilLabel presente en el menú", "sin PerfilLabel")
	var acc = root.get_node_or_null("AccesibilidadManager")
	_check(acc != null and acc.has_method("get_perfil"), "AccesibilidadManager con get_perfil", "ausente")
	var esperado: String = "Controles: " + String((acc.get_perfil() as Dictionary).get("nombre", "custom"))
	_check(label.visible and String(label.text) == esperado, "label refleja el perfil activo (" + esperado + ")", "texto: %s" % label.text)

	# 2. Cambio de perfil -> label actualizado EN VIVO por la señal.
	var cambios := [0]
	acc.profile_changed.connect(func(_n): cambios[0] += 1)
	acc.aplicar_perfil_control("single_hand")
	await process_frame
	_check(label.text.ends_with("single_hand") or label.text.contains("single_hand"),
		"cambio de perfil reflejado en vivo (single_hand)", "label: %s" % label.text)
	_check(cambios[0] >= 1, "señal profile_changed emitida", "sin señales")

	# 3. Volver (restaurar) y verificar re-actualización.
	acc.aplicar_perfil_control("default")
	await process_frame
	_check(not label.text.contains("single_hand"), "restauración reflejada (default)", "label: %s" % label.text)

	menu.queue_free()
	print("[QA-M58-P] RESULTADO=", "OK" if _fallos == 0 else "FAIL(%d/%d)" % [_fallos, _checks])
	quit(0 if _fallos == 0 else 1)
