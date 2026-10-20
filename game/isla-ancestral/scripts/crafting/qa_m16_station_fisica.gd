# -*- coding: utf-8 -*-
# QA M16 item 7: estación sin steps de física extra — G-5.3-Flash-Agente
extends SceneTree

var _fallos := 0
var _checks := 0

func _check(cond: bool, ok_msg: String, fail_msg: String) -> void:
	_checks += 1
	if cond:
		print("[QA-M16-S] OK ", ok_msg)
	else:
		_fallos += 1
		print("[QA-M16-S] FALLO ", fail_msg)

func _initialize() -> void:
	call_deferred("_correr")

func _correr() -> void:
	await process_frame

	var station = load("res://scripts/crafting/crafting_station.gd").new()
	station.tipo = 1  # FOGATA
	root.add_child(station)
	await process_frame
	await process_frame

	# Física apagada en el Area declarativo.
	_check(station._area.monitoring == false, "Area monitoring=false (sin overlaps por step)", "monitoring on")
	_check(station._area.monitorable == false, "Area monitorable=false", "monitorable on")
	_check(station._area.collision_layer == 0, "capa de colisión 0", "capa no 0")
	_check(station._area.collision_mask == 0, "máscara de colisión 0", "máscara no 0")

	# La estación sigue siendo interactuable básica: sin loops, mesh presente,
	# y el mapa de nombres intacto (RF1).
	var src: String = String(station.get_script().source_code)
	_check(src.find("func _physics_process") == -1, "sin _physics_process", "tiene _physics_process")
	_check(src.find("func _process") == -1, "sin _process", "tiene _process")
	_check(station._mesh != null and station._mesh.mesh != null, "mesh placeholder presente", "sin mesh")
	_check(station.nombre_estacion() == "fogata", "nombre_estacion() mapea FOGATA (regresión)", "mapeo roto")

	station.queue_free()
	print("[QA-M16-S] RESULTADO=", "OK" if _fallos == 0 else "FAIL(%d/%d)" % [_fallos, _checks])
	quit(0 if _fallos == 0 else 1)
