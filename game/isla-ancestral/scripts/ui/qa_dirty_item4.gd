# -*- coding: utf-8 -*-
# QA item 4 v3 (M59): dirty-check via SaveManager oficial (mark_dirty/clear_dirty)
#
# BUG-152 (GO del director, msg 463 punto 6): la v2 llamaba `_actualizar_dirty()`,
# que NO existe en PauseLayer -> SCRIPT ERROR -> `_correr()` abortaba -> el `quit()`
# del final nunca corria -> la suite COLGABA (EXIT 124) en vez de fallar. El metodo
# real es `_refrescar_guardar_dirty()` (pause_layer.gd:161).
#
# Guardian de 3 capas (protocolo 21.8 / trampas 45 y 51):
#   1. contador de checks + piso CHECKS_MINIMOS MEDIDO en verde;
#   2. `_fin()` por bloque, para que el resumen NOMBRE cual no se ejecuto;
#   3. `_arrancar -> await _correr -> _summary` + watchdog de 30 s: cualquier
#      aborto publica RESUMEN INCOMPLETO y sale 1 en vez de colgarse.
extends SceneTree

const CHECKS_MINIMOS: int = 6
const BLOQUES := ["A", "B", "C", "D"]

var _checks: int = 0
var _fallos: int = 0
var _cerrado: bool = false
var _bloque_actual: String = "-"
var _bloques_ok: Array[String] = []


func _initialize() -> void:
	call_deferred("_arrancar")


func _arrancar() -> void:
	create_timer(30.0).timeout.connect(_por_timeout)
	await _correr()
	_summary()


func _por_timeout() -> void:
	if _cerrado:
		return
	_cerrado = true
	printerr("[QA-DIRTY] WATCHDOG 30s: la suite no termino. Bloque en curso: ", _bloque_actual)
	print("[QA-DIRTY] checks=%d fallos=%d bloques=%d/%d" % [_checks, _fallos, _bloques_ok.size(), BLOQUES.size()])
	print("[QA-DIRTY] RESULTADO=FAIL(TIMEOUT)")
	quit(1)


func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if cond:
		print("[QA-DIRTY] ok: ", msg)
	else:
		_fallos += 1
		print("[QA-DIRTY] FALLO: ", msg)


func _fin(b: String) -> void:
	_bloques_ok.append(b)
	print("[QA-DIRTY] bloque %s cerrado" % b)


func _summary() -> void:
	if _cerrado:
		return
	_cerrado = true
	var faltan: Array[String] = []
	for b in BLOQUES:
		if not _bloques_ok.has(b):
			faltan.append(b)
	if not faltan.is_empty():
		_fallos += 1
		print("[QA-DIRTY] FALLO: bloques NO ejecutados: ", faltan)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[QA-DIRTY] FALLO: solo %d checks ejecutados (minimo medido %d)" % [_checks, CHECKS_MINIMOS])
	print("[QA-DIRTY] checks=%d fallos=%d bloques=%d/%d" % [_checks, _fallos, _bloques_ok.size(), BLOQUES.size()])
	print("[QA-DIRTY] RESULTADO=", "OK" if _fallos == 0 else "FAIL(%d)" % _fallos)
	quit(0 if _fallos == 0 else 1)


func _correr() -> void:
	await process_frame
	await process_frame

	var player := Node3D.new()
	player.name = "Player"
	root.add_child(player)

	var sm := root.get_node_or_null("/root/SaveManager")
	_check(sm != null, "SaveManager disponible como autoload")
	if sm == null:
		return

	var pausita = load("res://scripts/ui/layers/pause_layer.gd").new()
	root.add_child(pausita)
	await process_frame

	# A) dirty marcado -> boton habilitado
	_bloque_actual = "A"
	sm.mark_dirty()
	pausita.open()
	await process_frame
	_check(not pausita._boton_guardar.disabled, "A: boton habilitado con dirty=true")
	_fin("A")

	# B) dirty limpio -> boton deshabilitado (BUG-152: el metodo REAL, no el viejo)
	_bloque_actual = "B"
	sm.clear_dirty()
	pausita._refrescar_guardar_dirty()
	_check(pausita._boton_guardar.disabled, "B: boton deshabilitado con dirty=false")
	_fin("B")

	# C) bloqueo: SaveManager bloqueado -> toggle consistente
	_bloque_actual = "C"
	sm.set_save_blocked(true)
	var antes: bool = sm.is_save_blocked()
	sm.set_save_blocked(false)
	_check(antes and not sm.is_save_blocked(), "C: toggle de bloqueo antes/despues")
	_fin("C")

	# D) anti-regresion de BUG-152: el metodo real existe y el viejo NO
	_bloque_actual = "D"
	_check(pausita.has_method("_refrescar_guardar_dirty"),
		"D: PauseLayer expone _refrescar_guardar_dirty")
	_check(not pausita.has_method("_actualizar_dirty"),
		"D: _actualizar_dirty NO existe (era el nombre inexistente del bug)")
	_fin("D")

	player.queue_free()
	pausita.queue_free()
