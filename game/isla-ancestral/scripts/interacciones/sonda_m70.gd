# -*- coding: utf-8 -*-
# Sonda de diagnostico: por que el fade no dispara (dif temp, NO flipa nada).
extends SceneTree

class StubInt extends Node:
	var prioridad: int = 1
	var posicion: Vector3 = Vector3.ZERO
	var _cambia: bool = false
	func set_pos(p: Vector3) -> void:
		posicion = p
	func obtener_prioridad() -> int:
		return prioridad
	func obtener_categoria() -> String:
		return "recolectar"
	func obtener_posicion_interaccion() -> Vector3:
		return posicion
	func obtener_duracion_esperada() -> float:
		return 0.0
	func requisitos_cumplidos(_jugador) -> bool:
		return true
	func interactuar(_datos: Dictionary) -> void:
		pass
	func obtener_estado() -> int:
		return 0
	func obtener_radio() -> float:
		return 0.5

var objetivo_visto = null
var n_eval = 0

func _summary_and_quit() -> void:
	quit(0)

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var mgr: Node = load("res://scripts/interacciones/interaction_manager.gd").new()
	var a: StubInt = StubInt.new()
	a.name = "A"
	a.prioridad = 2
	a.posicion = Vector3.ZERO
	mgr.registrar(a)
	var b: StubInt = StubInt.new()
	b.name = "B"
	b.prioridad = 5
	b.posicion = Vector3(3, 0, 3)
	mgr.registrar(b)
	var jugador := Node3D.new()
	root.add_child(jugador)
	mgr.configurar_jugador(jugador)
	mgr.objetivo_seleccionado.connect(func(obj, at): print("[SEL] ", obj, " atenuado=", at); objetivo_visto = obj)

	for i in range(4):
		mgr._process(0.016)
	print("despues de 4 frames: obj=", mgr.obtener_objetivo_actual(), " evals=", n_eval)

	# Mover A lejos (sale de rango); B cerca
	a.set_pos(Vector3(6, 0, 6))
	for i in range(6):
		mgr._process(0.016)
		print("frame %d: obj=%s fade=%s" % [i, str(mgr.obtener_objetivo_actual()), str(mgr.get("_fade_restante"))])
	_summary_and_quit()
