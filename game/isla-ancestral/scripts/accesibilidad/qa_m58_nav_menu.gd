# -*- coding: utf-8 -*-
# QA M58: menú 100% navegable por teclado/mando (MenuNavigator sobre MenusLayer)
extends SceneTree

var _fallos := 0
var _checks := 0

func _check(cond: bool, ok_msg: String, fail_msg: String) -> void:
	_checks += 1
	if cond:
		print("[QA-M58-N] OK ", ok_msg)
	else:
		_fallos += 1
		print("[QA-M58-N] FALLO ", fail_msg)

func _initialize() -> void:
	call_deferred("_correr")

func _correr() -> void:
	await process_frame
	await process_frame

	var menu = load("res://scripts/ui/layers/menus_layer.gd").new()
	menu.visible = true
	root.add_child(menu)
	await process_frame
	await process_frame

	var nav = load("res://scripts/ui/core/menu_navigator.gd")
	_check(nav != null, "MenuNavigator disponible", "ausente")

	# El menú expone su cadena de botones (on_layer_opened hace grab_focus del 1º).
	var primero: Control = menu.focus_first()
	_check(primero != null and primero is Button, "focus_first() → Button (teclado/mando)", "sin foco inicial")
	if primero == null:
		print("[QA-M58-N] RESULTADO=FAIL(1)")
		quit(1)
		return
	primero.grab_focus()
	_check(root.gui_get_focus_owner() != null, "foco real del viewport en el botón", "sin foco real")

	# wrap_focus con dirección: movimiento + wrap-around (RF2).
	var nav_obj = nav.new()
	var total: int = menu._buttons.size()
	nav_obj.wrap_focus(menu, Vector2i(1, 0))
	var owner2: Control = root.gui_get_focus_owner()
	_check(owner2 != null and owner2 != primero, "wrap_focus mueve el foco al siguiente", "no movió")
	for i in total:
		nav_obj.wrap_focus(menu, Vector2i(1, 0))
	var owner_wrap: Control = root.gui_get_focus_owner()
	_check(owner_wrap != null and owner_wrap is Button, "wrap-around de %d botones sin perder foco" % total, "foco perdido en wrap")

	# vertical (gamepad eje Y) también navega.
	nav_obj.wrap_focus(menu, Vector2i(0, 1))
	_check(root.gui_get_focus_owner() != null, "navegación vertical ok", "vertical sin foco")

	menu.queue_free()
	nav_obj.free()
	print("[QA-M58-N] RESULTADO=", "OK" if _fallos == 0 else "FAIL(%d/%d)" % [_fallos, _checks])
	quit(0 if _fallos == 0 else 1)
