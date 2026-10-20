# -*- coding: utf-8 -*-
# QA M59 ítems 60/62: feedback visible/legible + diálogo con opciones claras
extends SceneTree

var _fallos := 0
var _checks := 0

func _check(cond: bool, ok_msg: String, fail_msg: String) -> void:
	_checks += 1
	if cond:
		print("[QA-M59-P] OK ", ok_msg)
	else:
		_fallos += 1
		print("[QA-M59-P] FALLO ", fail_msg)

func _initialize() -> void:
	call_deferred("_correr")

func _correr() -> void:
	await process_frame
	await process_frame

	var loc = root.get_node_or_null("Localization")
	var t_ok: String = loc.traducir_clave("SETTINGS.CONFIRMAR")
	var t_cancel: String = loc.traducir_clave("SETTINGS.CANCELAR")

	var popup = load("res://scripts/ui/layers/confirm_popup.gd").new()
	root.add_child(popup)
	await process_frame

	# Ítem 62: diálogo con OPCIONES CLARAS → botón OK y Cancelar localizados.
	var ok_llamados := [0]
	var cancel_llamados := [0]
	popup.configurar_texto("Guardar partida", "¿Guardar la partida en el slot 1?",
		func(): ok_llamados[0] += 1,
		func(): cancel_llamados[0] += 1)
	_check(String(popup._ok_button.text) == t_ok, "botón OK localizado (opción clara)", "texto ok: %s" % t_ok)
	_check(String(popup._cancel_button.text) == t_cancel, "botón Cancelar localizado (opción clara)", "texto cancel: %s" % t_cancel)

	# Cancelar → ejecuta on_cancel, NO on_ok.
	popup._cancel_button.pressed.emit()
	_check(cancel_llamados[0] == 1 and ok_llamados[0] == 0, "cancelar ejecuta la rama de cancelación", "ramas rotas")

	# Aceptar (reconfigurado): ejecuta on_ok.
	popup.configurar_texto("Borrar partida", "¿Borrar?", func(): ok_llamados[0] += 1)
	popup._ok_button.pressed.emit()
	_check(ok_llamados[0] == 1, "aceptar ejecuta on_ok (reconfigurado)", "ok no ejecutó")

	# Sin on_cancel definido: cancelar es no-op seguro (cozy).
	popup.configurar_texto("Aviso", "Solo aceptar", func(): ok_llamados[0] += 1)
	popup._cancel_button.pressed.emit()
	_check(ok_llamados[0] == 1, "cancel sin on_cancel definido es no-op seguro", "crasheó")

	popup.queue_free()
	print("[QA-M59-P] RESULTADO=", "OK" if _fallos == 0 else "FAIL(%d/%d)" % [_fallos, _checks])
	quit(0 if _fallos == 0 else 1)
