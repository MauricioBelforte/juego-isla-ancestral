# Modelo: agnes-2.5-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M64: IA de NPC — Clase base State (componente del HFSM)
#
# Cada estado hereda de esta clase y implementa enter/update/exit/check_transitions.
# El blackboard comparte datos entre estados (posición jugador, clima, etc.).

extends Node
class_name NPCState

## Referencia al controlador principal
var controller: Node = null

## Nombre identificador del estado (para logging/debug)
var state_name: StringName = &"State"

## Prioridad del estado (mayor = más urgente para transiciones)
var priority: int = 0

func _ready() -> void:
	pass

## Entrar en el estado. data puede contener información de la transición.
func enter(data: Dictionary = {}) -> void:
	pass

## Actualización por frame (delta segundos). Movimiento, lógica continua.
func update(delta: float) -> void:
	pass

## Actualización discreta cada N segundos (tick de decisión). Rutinas, necesidades.
func tick(delta: float) -> void:
	pass

## Salir del estado (limpieza).
func exit() -> void:
	pass

## Evaluar si debe transitarse a otro estado. Retorna Dictionary {target: StringName, data: Dictionary} o {}.
func check_transitions() -> Dictionary:
	return {}
