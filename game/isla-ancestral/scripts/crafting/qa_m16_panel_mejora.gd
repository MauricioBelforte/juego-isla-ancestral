# -*- coding: utf-8 -*-
# QA M16 MR12/MR13: panel de mejora en crafting_ui (estados, techo, botón, click)
extends SceneTree

var _fallos := 0
var _checks := 0

func _check(cond: bool, ok_msg: String, fail_msg: String) -> void:
	_checks += 1
	if cond:
		print("[QA-M16-PM] OK ", ok_msg)
	else:
		_fallos += 1
		print("[QA-M16-PM] FALLO ", fail_msg)

func _initialize() -> void:
	call_deferred("_correr")

func _correr() -> void:
	await process_frame
	await process_frame

	var ui = load("res://scripts/crafting/crafting_ui.gd").new()
	root.add_child(ui)
	await process_frame
	var cs = root.get_node_or_null("Crafting")
	var inv = root.get_node_or_null("Inventario")
	_check(ui != null and cs != null and inv != null, "UI + servicio + inventario presentes", "deps ausentes")

	# (a) No-herramienta seleccionada → panel OCULTO.
	ui.abrir(0)
	ui._on_seleccionar(cs.obtener_receta("rec_ensalada_bayas"))
	await process_frame
	_check(ui._mejora_box.visible == false, "panel oculto para no-herramienta", "visible indebidamente")

	# (b) Herramienta → panel visible con nivel 0/3.
	cs._conocidas.append("rec_hacha_cobre")
	ui._on_seleccionar(cs.obtener_receta("rec_hacha_cobre"))
	await process_frame
	_check(ui._mejora_box.visible == true, "MR12 panel visible para herramienta", "oculto")
	_check(str(ui._mejora_label.text).contains("0/3"), "nivel 0/3 mostrado", "nivel: %s" % ui._mejora_label.text)

	# (c) Sin materiales → botón deshabilitado.
	inv.remover_items({"madera_roble": inv.count_item("madera_roble", true), "mineral_cobre": inv.count_item("mineral_cobre", true)})
	ui._refrescar_mejora()
	_check(ui._btn_mejorar.disabled == true, "botón deshabilitado sin materiales", "habilitado indebido")

	# (d) Con materiales → habilitado; click → mejora + panel refrescado + cozy.
	inv.agregar_items(cs._mejora_cfg["tipos"]["hacha"]["coste_nivel"][0])
	ui._refrescar_mejora()
	_check(ui._btn_mejorar.disabled == false, "botón habilitado con materiales", "sigue deshabilitado")
	var mejoras := [0]
	cs.herramienta_mejorada.connect(func(_i, _n): mejoras[0] += 1)
	ui._btn_mejorar.pressed.emit()
	_check(mejoras[0] == 1 and cs._nivel_de("hacha_cobre") == 1, "click mejora: nivel 1 + señal", "mejora falló")
	_check(str(ui._mensaje_label.text).contains("OK"), "feedback cozy en el panel", "sin mensaje")
	_check(str(ui._mejora_label.text).contains("1/3") and str(ui._mejora_label.text).contains(str(cs.durabilidad_maxima("hacha", 2))), "panel refrescado (1/3, durabilidad 200)", "sin refresh")

	# (e) Techo → deshabilitado + mensaje MEJORA_MAXIMA.
	cs._niveles_mejora["hacha_cobre"] = 3
	ui._refrescar_mejora()
	_check(ui._btn_mejorar.disabled == true, "techo deshabilita", "techo habilitado")
	_check(str(ui._mejora_label.text).contains("Mejora máxima"), "mensaje de techo visible", "sin techo")

	# (f) Limpieza del autoload.
	cs._niveles_mejora.erase("hacha_cobre")
	cs._conocidas.erase("rec_hacha_cobre")
	print("[QA-M16-PM] RESULTADO=", "OK" if _fallos == 0 else "FAIL(%d/%d)" % [_fallos, _checks])
	quit(0 if _fallos == 0 else 1)
