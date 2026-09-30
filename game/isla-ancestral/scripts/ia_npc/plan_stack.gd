# Modelo: mimo-v2.5
# Plataforma: OpenCode
# Fecha: 2026-09-18
#
# M64: IA de NPC — Plan Stack (memoria de planes con recovery)
#
# Pila jerárquica de planes. Cada plan es un Dictionary:
#   { "state": StringName, "data": Dictionary, "source": StringName, "timestamp": float }
#
# Cuando un plan falla, se hace pop y se retoma el plan anterior (recovery).
# Permite que un NPC que iba a trabajar se desvíe a comer (plan nuevo),
# y al terminar de comer retome el camino al trabajo (plan anterior).

extends RefCounted
class_name NPCPlanStack

## Señales
signal plan_pushed(plan: Dictionary)
signal plan_popped(plan: Dictionary)
signal plan_recovered(plan: Dictionary)
signal stack_cleared()

## Pila interna
var _stack: Array[Dictionary] = []
const MAX_DEPTH: int = 8

## Timestamp de referencia (se actualiza desde GameTime M29)
var _current_time: float = 0.0


func _init() -> void:
	pass


## ── API pública ────────────────────────────────────────────

## Push un nuevo plan. Si hay un plan activo, se apila (no se pierde).
func push_plan(state: StringName, data: Dictionary = {}, source: StringName = &"") -> void:
	if _stack.size() >= MAX_DEPTH:
		push_warning("[PlanStack] Profundidad máxima alcanzada (%d), descartando plan más viejo" % MAX_DEPTH)
		_stack.pop_front()
	var plan := {
		"state": state,
		"data": data.duplicate(),
		"source": source,
		"timestamp": _current_time,
	}
	_stack.append(plan)
	plan_pushed.emit(plan)
	print("[PlanStack] Push: %s (profundidad=%d)" % [state, _stack.size()])


## Pop el plan actual. Retorna el plan anterior (o vacío si la pila queda vacía).
func pop_plan() -> Dictionary:
	if _stack.is_empty():
		return {}
	var popped: Dictionary = _stack.pop_back()
	plan_popped.emit(popped)
	if not _stack.is_empty():
		var recovery: Dictionary = _stack.back()
		plan_recovered.emit(recovery)
		print("[PlanStack] Pop + recovery a: %s" % recovery.get("state", &""))
	else:
		print("[PlanStack] Pop: pila vacía")
	return popped


## Peek sin modificar — retorna el plan actual (o vacío).
func peek_current() -> Dictionary:
	if _stack.is_empty():
		return {}
	return _stack.back()


## Peek al plan anterior (sin pop).
func peek_previous() -> Dictionary:
	if _stack.size() < 2:
		return {}
	return _stack[_stack.size() - 2]


## Retorna el plan en un índice dado (0 = fondo, size-1 = tope).
func get_at(index: int) -> Dictionary:
	if index < 0 or index >= _stack.size():
		return {}
	return _stack[index]


## Clear completo (al terminar una rutina exitosamente).
func clear() -> void:
	if not _stack.is_empty():
		_stack.clear()
		stack_cleared.emit()
		print("[PlanStack] Stack cleared")


## ¿La pila está vacía?
func is_empty() -> bool:
	return _stack.is_empty()


## Tamaño actual.
func size() -> int:
	return _stack.size()


## Busca si hay un plan con un estado dado en la pila.
func has_state(state: StringName) -> bool:
	for plan in _stack:
		if plan.get("state") == state:
			return true
	return false


## ── Tiempo ─────────────────────────────────────────────────

func set_current_time(time: float) -> void:
	_current_time = time


## ── Serialización ──────────────────────────────────────────

func to_dict() -> Dictionary:
	return {"stack": _stack.duplicate(true), "time": _current_time}


func from_dict(d: Dictionary) -> void:
	_stack.clear()
	var arr: Array = d.get("stack", [])
	for item in arr:
		if item is Dictionary:
			_stack.append(item)
	_current_time = float(d.get("time", 0.0))


## ── Debug ──────────────────────────────────────────────────

func debug_print() -> void:
	print("[PlanStack] Profundidad: %d" % _stack.size())
	for i in range(_stack.size()):
		var p: Dictionary = _stack[i]
		print("  [%d] %s (src=%s, t=%.1f)" % [i, p.get("state", "?"), p.get("source", "?"), p.get("timestamp", 0.0)])
