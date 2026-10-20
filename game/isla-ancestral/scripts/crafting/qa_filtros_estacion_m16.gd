# -*- coding: utf-8 -*-
# QA M16 item 4: filtros de temporada recalculados SOLO ante season_changed.
# Corre headless: godot --headless --path game/isla-ancestral --script res://scripts/crafting/qa_filtros_estacion_m16.gd
# G-5.3-Flash-Agente / Kilo Code — 2026-10-19
extends SceneTree

var _fallos := 0
var _checks := 0

class FakeGT extends Node:
	signal estacion_cambio(est)
	var _est: int = 2
	var contador: int = 0

	func get_estacion() -> int:
		contador += 1
		return _est

func _check(cond: bool, ok_msg: String, fail_msg: String, extra: Variant = null) -> void:
	_checks += 1
	if cond:
		print("[QA-M16-F] OK ", ok_msg)
	else:
		_fallos += 1
		if extra == null:
			print("[QA-M16-F] FALLO ", fail_msg)
		else:
			print("[QA-M16-F] FALLO ", fail_msg, extra)

func _initialize() -> void:
	call_deferred("_correr")

func _correr() -> void:
	await process_frame
	await process_frame

	var svc = load("res://scripts/crafting/crafting_service.gd").new()
	svc.registra_en_save = false
	root.add_child(svc)
	await process_frame

	# Reemplazamos el reloj real por uno contable (duck: mismas 2 interfaces usadas).
	var fake := FakeGT.new()
	root.add_child(fake)
	svc._gt = fake
	fake.estacion_cambio.connect(svc._on_estacion_cambio)
	svc._refrescar_estacion_actual()
	var cuenta0: int = fake.contador
	_check(cuenta0 >= 1, "arranque refresca una vez (contador=", "contador en 0: ", fake.contador)

	# 7 consultas del FILTRO: cero re-lecturas de GameTime.
	for i in 7:
		svc.recetas_por_estacion(2)
	_check(fake.contador == cuenta0, "7 consultas del filtro -> 0 re-lecturas", "re-leyó: ", fake.contador - cuenta0)

	# La señal estacion_cambio RECALCULA (cambia la season sin tocar get_estacion).
	fake.estacion_cambio.emit(3)
	_check(svc._estacion_actual == 3, "señal estacion_cambio recalcula la cache", "cache no siguió señal: ", svc._estacion_actual)
	svc.recetas_por_estacion(3)
	_check(fake.contador == cuenta0, "consulta tras señal sigue sin re-lectura", "re-leyó tras señal: ", fake.contador - cuenta0)

	# Los paths de ENFORCEMENT conservan su re-lectura (correctness).
	var rec_id0: String = String(svc._recetas.keys()[0])
	svc.max_craftable(rec_id0)
	_check(fake.contador == cuenta0 + 1, "path de enforcement (max_craftable) sigue re-leyendo", "enforcement no releyó")

	svc.queue_free()
	fake.queue_free()
	print("[QA-M16-F] RESULTADO=", "OK" if _fallos == 0 else "FAIL(%d/%d)" % [_fallos, _checks])
	quit(0 if _fallos == 0 else 1)
