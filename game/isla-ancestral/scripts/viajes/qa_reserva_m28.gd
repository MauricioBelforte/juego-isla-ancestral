# -*- coding: utf-8 -*-
# QA del TravelReserva (item [30] M28 RF1: boleto/reserva con capacidad)
extends SceneTree

func _initialize() -> void:
	call_deferred("_correr")

func _correr() -> void:
	var fallos := 0
	var R = load("res://scripts/viajes/travel_reserva.gd")
	var r = R.new()

	r.configurar_capacidad(&"isla_test", 2)  # capacidad 2

	# 1) libres iniciales = capacidad
	var libres0: int = r.asientos_libres(&"isla_test")
	if libres0 != 2:
		fallos += 1
		print("[QA-RESERVA] FALLO libres iniciales:", libres0)
	else:
		print("[QA-RESERVA] OK libres=2")

	# 2) dos reservas OK
	var r1: Dictionary = r.reservar(&"isla_test", "pass_a", 10)
	var r2: Dictionary = r.reservar(&"isla_test", "pass_b", 10)
	if not (bool(r1.get("ok")) and bool(r2.get("ok"))):
		fallos += 1
		print("[QA-RESERVA] FALLO reservas A/B:", r1, r2)
	else:
		print("[QA-RESERVA] OK reservas A y B")

	# 3) tercera → capacidad agotada
	var r3: Dictionary = r.reservar(&"isla_test", "pass_c", 10)
	if bool(r3.get("ok")) or r3.get("motivo") != "capacidad_agotada":
		fallos += 1
		print("[QA-RESERVA] FALLO tercera reserva debería agotar:", r3)
	else:
		print("[QA-RESERVA] OK capacidad_agotada en la 3a")

	# 4) mismo pasajero re-reserva → ya_reservado
	var r4: Dictionary = r.reservar(&"isla_test", "pass_a", 10)
	if bool(r4.get("ok")) or r4.get("motivo") != "ya_reservado":
		fallos += 1
		print("[QA-RESERVA] FALLO re-reserva mismo pasajero:", r4)
	else:
		print("[QA-RESERVA] OK ya_reservado")

	# 5) cancelar libera asiento
	var ok_cancel: bool = r.cancelar_reserva(&"isla_test", "pass_b")
	if not ok_cancel or r.asientos_libres(&"isla_test") != 1:
		fallos += 1
		print("[QA-RESERVA] FALLO liberación al cancelar")
	else:
		print("[QA-RESERVA] OK cancelación libera asiento")

	# 6) ruta distinta sin capacidad configurada → default 6
	var rl: int = r.asientos_libres(&"isla_otra")
	if rl != 6:
		fallos += 1
		print("[QA-RESERVA] FALLO default capacité:", rl)
	else:
		print("[QA-RESERVA] OK default=6 en ruta nueva")

	# 7) liberar_ruta limpia
	r.liberar_ruta(&"isla_test")
	if r.asientos_libres(&"isla_test") != 2:
		fallos += 1
		print("[QA-RESERVA] FALLO liberar_ruta")
	else:
		print("[QA-RESERVA] OK liberar_ruta")

	print("[QA-RESERVA] RESULTADO=", "OK" if fallos == 0 else "FAIL(%d)" % fallos)
	quit(0 if fallos == 0 else 1)
