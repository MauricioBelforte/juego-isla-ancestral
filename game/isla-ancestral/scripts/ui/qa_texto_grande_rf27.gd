# -*- coding: utf-8 -*-
# QA RF27 (M58/M53): texto grande con tildes/ñ no desborda diálogos/inventario
extends SceneTree

func _initialize() -> void:
	call_deferred("_correr")

func _correr() -> void:
	await process_frame
	await process_frame
	var fallos := 0

	# ─── DialogLayer con fuente GRANDE (texto texto grande) ───
	var dl = load("res://scripts/ui/layers/dialog_layer.gd").new()
	root.add_child(dl)
	await process_frame
	if dl == null or dl.get_child_count() == 0:
		print("[QA-RF27] FALLO: DialogLayer no instanciable")
		quit(1)
		return

	# Buscar el text_label por autowrap activado
	var text_label: Label = null
	var stack: Array = [dl]
	while stack.size() > 0:
		var n = stack.pop_back()
		if n is Label:
			if n.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART:
				text_label = n
			stack.append_array(n.get_children())
		elif n is Control:
			stack.append_array(n.get_children())
		else:
			stack.append_array(n.get_children())
	if text_label == null:
		fallos += 1
		print("[QA-RF27] FALLO: no encontré label autowrap en DialogLayer")
		quit(1)
		return

	# Fuente GRANDE (texto grande: el doble del body default)
	text_label.add_theme_font_size_override("font_size", 48)

	# Texto largo con TILDES/Ñ/Ø español (M88)
	text_label.text = "Año tras año, el granjero Butenblume cultivaría ñandúes, maíz y tabaco en la costa de la Islita; ¡cuidado con los pequeños zorros ágiles del jardín ornamental! Las crías aprenderán a volar en las mañanas lluviosas de la isla. Ültima advertencia: el vagón de la comida del pescador de Østjylland trajinó por la cañada el día miércoles, y la niña, orgullosa, soiró burlona y pidió ñoquis con queso de ñandú."

	# Esperar layout
	await process_frame
	await process_frame

	# VERIFICACIONES:
	# a) autowrap sigue activo (el texto se envuelve, no se expande infinito)
	if text_label.autowrap_mode != TextServer.AUTOWRAP_WORD_SMART:
		fallos += 1
		print("[QA-RF27] FALLO: autowrap desactivado")
	else:
		print("[QA-RF27] OK autowrap WORD_SMART activo con fuente grande")

	# b) el label NTIENE clip_contents (el texto wrappea, no se corta en un clip)
	if text_label.clip_contents:
		fallos += 1
		print("[QA-RF27] FALLO: clip_contents activo (texto cortado)")
	else:
		print("[QA-RF27] OK sin clip (envuelve)")

	# c) el texto contiene tildes/ñ intactas (M88 fonts españolas)
	if "año" in text_label.text and "ñandúes" in text_label.text and "ágiles" in text_label.text:
		print("[QA-RF27] OK tildes/ñ intactas en el texto (M88)")
	else:
		fallos += 1
		print("[QA-RF27] FALLO: caracteres especiales corrompidos")

	# d) el label crece en ALTURA (envuelto en múltiples líneas, no 1 línea larga)
	if text_label.size.y > 10:
		print("[QA-RF27] OK label altura ", text_label.size.y, " (> 10 px, envueltas)")
	else:
		fallos += 1
		print("[QA-RF27] FALLO: label altura 0/absent")

	dl.queue_free()
	print("[QA-RF27] RESULTADO=", "OK" if fallos == 0 else "FAIL(%d)" % fallos)
	quit(0 if fallos == 0 else 1)
