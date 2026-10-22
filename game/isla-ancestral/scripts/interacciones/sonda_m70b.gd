# -*- coding: utf-8 -*-
# Sonda 2: caso estable B (por que re-emite fade?)
extends SceneTree

class StubInt extends Node:
	var prioridad: int = 1
	var posicion: Vector3 = Vector3.ZERO
	func obtener_prioridad() -> int: return prioridad
	func obtener_categoria() -> String: return "recolectar"
	func obtener_posicion_interaccion() -> Vector3: return posicion
	func obtener_duracion_esperada() -> float: return 0.0
	func requisitos_cumplidos(_jugador) -> bool: return true
	func interactuar(_datos: Dictionary) -> void: pass
	func obtener_estado() -> int: return 0
	func obtener_radio() -> float: return 0.5

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
	b.posicion = Vector3.ZERO
	mgr.registrar(b)
	var jugador := Node3D.new()
	root.add_child(jugador)
	mgr.configurar_jugador(jugador)
	var fades: Array = []
	var sels: Array = []
	mgr.objetivo_seleccionado.connect(func(obj, at): sels.append(obj))
	mgr.objetivo_en_transicion.connect(func(d: float): fades.append(d))
	print("seccion1: 4 frames")
	for i in range(4):
		mgr._process(0.016)
		print("  f%d fades=%d sels=%d obj=%s" % [i, fades.size(), sels.size(), str(mgr.obtener_objetivo_actual()).left(12)])
	print("seccion2: A lejos, 6 frames")
	a.posicion = Vector3(6, 0, 6)
	for i in range(6):
		mgr._process(0.016)
		print("  f%d fades=%d sels=%d obj=%s" % [i, fades.size(), sels.size(), str(mgr.obtener_objetivo_actual()).left(12)])
	quit(0)
