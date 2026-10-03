# Modelo: DeepSeek-V4.1-Flash (WorkBuddy)
# Fecha: 2026-10-03
#
# M17 Construccion iter. 1 — BuildHistory: pila undo/redo por DELTAS exactos.
#
# Decision de diseno (02-Analisis §2.5): undo por ACCIONES (pila de deltas), no
# por snapshot del mundo. Cada accion guarda lo justo para revertirse sola:
# tipo, receta, celdas afectadas, rotacion y los recursos movidos (costo
# descontado y/o devolucion entregada). Mas barato que guardar chunks y
# compatible con M58/M59.
#
# La pila NO conoce el mundo ni el inventario: solo guarda y devuelve deltas.
# Quien los interpreta es `BuildManager` (unico punto de aplicacion).
#
# NUCLEO PURO: testeable en headless.

class_name BuildHistory
extends RefCounted

## Tipos de accion registrables.
const TIPO_COLOCAR: String = "colocar"
const TIPO_DEMOLER: String = "demoler"
const TIPO_MOVER: String = "mover"

## Tope de la pila de undo (las acciones mas viejas se descartan). 0 = sin tope.
var limite: int = 200

var _undo: Array = []
var _redo: Array = []

## ── Registro ────────────────────────────────────────────────────────────

## Apila un delta. Registrar una accion NUEVA invalida el redo pendiente
## (semantica estandar de undo: no se puede rehacer una rama abandonada).
func registrar(delta: Dictionary) -> void:
	if delta.is_empty():
		return
	_undo.append(delta.duplicate(true))
	if limite > 0 and _undo.size() > limite:
		_undo.pop_front()
	_redo.clear()

## ── Consulta ────────────────────────────────────────────────────────────

func puede_undo() -> bool:
	return not _undo.is_empty()

func puede_redo() -> bool:
	return not _redo.is_empty()

## { "undo": n, "redo": n } para logs y tests.
func tamanos() -> Dictionary:
	return {"undo": _undo.size(), "redo": _redo.size()}

## ── Movimiento ──────────────────────────────────────────────────────────

## Desapila el ultimo delta para deshacerlo. Devuelve {} si no hay nada.
## El delta pasa a la pila de redo.
func undo_ultimo() -> Dictionary:
	if _undo.is_empty():
		return {}
	var d: Dictionary = _undo.pop_back()
	_redo.append(d)
	return d

## Desapila el ultimo delta deshecho para rehacerlo. Devuelve {} si no hay nada.
func redo_siguiente() -> Dictionary:
	if _redo.is_empty():
		return {}
	var d: Dictionary = _redo.pop_back()
	_undo.append(d)
	return d

## Vacia ambas pilas.
func limpiar() -> void:
	_undo.clear()
	_redo.clear()
