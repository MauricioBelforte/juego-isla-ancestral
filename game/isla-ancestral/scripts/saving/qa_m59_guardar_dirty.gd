# -*- coding: utf-8 -*-
# QA M59 ítem 4: botón Guardar deshabilitado si no hay cambios (is_dirty)
extends SceneTree

var _fallos := 0
var _checks := 0

func _check(cond: bool, ok_msg: String, fail_msg: String) -> void:
	_checks += 1
	if cond:
		print("[QA-M59-DT] OK ", ok_msg)
	else:
		_fallos += 1
		print("[QA-M59-DT] FALLO ", fail_msg)

func _initialize() -> void:
	call_deferred("_correr")

func _correr() -> void:
	await process_frame
	await process_frame

	var pause = load("res://scripts/ui/layers/pause_layer.gd").new()
	root.add_child(pause)
	await process_frame
	var sm = root.get_node_or_null("SaveManager")
	_check(pause != null and sm != null and sm.has_method("is_dirty"), "pause + SaveManager (is_dirty)", "deps ausentes")
	if sm == null:
		print("[QA-M59-DT] RESULTADO=SKIP")
		quit(0)
		return

	# (a) Sin cambios → botón deshabilitado (no dirty).
	sm.clear_dirty()
	if pause.has_method("_refrescar_guardar_dirty"):
		pause._refrescar_guardar_dirty()
	await process_frame
	_check(sm.is_dirty() == false and pause._boton_guardar.disabled == true,
		"a) no dirty → Guardar deshabilitado", "habilitado sin cambios")

	# (b) Cambios (marcar dirty) → botón habilitado.
	sm.mark_dirty()
	pause._refrescar_guardar_dirty()
	await process_frame
	_check(sm.is_dirty() == true and pause._boton_guardar.disabled == false,
		"b) dirty → Guardar habilitado", "sigue deshabilitado")

	# (c) Tras guardar (clear) → deshabilitado de nuevo.
	sm.clear_dirty()
	pause._refrescar_guardar_dirty()
	await process_frame
	_check(pause._boton_guardar.disabled == true, "c) tras guardar → deshabilitado", "sigue habilitado")

	print("[QA-M59-DT] RESULTADO=", "OK" if _fallos == 0 else "FAIL(%d/%d)" % [_fallos, _checks])
	quit(0 if _fallos == 0 else 1)
