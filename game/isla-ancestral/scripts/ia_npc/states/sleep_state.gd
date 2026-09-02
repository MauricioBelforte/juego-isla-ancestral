extends "res://scripts/ia_npc/states/base_state.gd"
## M64: Sleep State ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â va a dormir, duerme, despierta

const PRIORITY: int = 40
const MIN_SLEEP: float = 180.0

enum Phase { GO, SLEEPING, WAKE }
var _phase: int = 0
var _sleep_timer: float = 0.0



func enter(_data: Dictionary = {}) -> void:
	_phase = 0
	_sleep_timer = 0.0
	print("[Sleep] Entrando")
	if controller != null:
		var bb = controller.get_blackboard()
		if bb != null:
			bb.set_value("current_destination", &"sleep")


func update(delta: float) -> void:
	if _phase == 0:
		if controller != null and controller.has_method("get_location_position"):
			var loc = controller.get_location_position("casa")
			if loc != null:
				controller.navigate_to(loc)
		if controller != null and controller.has_method("is_at_destination"):
			if controller.is_at_destination():
				_phase = 1
				_sleep_timer = 0.0
				print("[Sleep] LlegÃƒÆ’Ã‚Â³ a casa")
	elif _phase == 1:
		if controller != null and controller.has_method("set_ocupado"):
			controller.set_ocupado(true)
		_sleep_timer += delta
		var should_wake = false
		if _sleep_timer >= MIN_SLEEP:
			var gt = get_node_or_null("/root/GameTime")
			if gt != null:
				if controller.has_method("get_routine"):
					var routine = controller.get_routine()
					if routine != null and routine.has_method("get_wake_hour"):
						should_wake = gt.get_hora() >= routine.get_wake_hour()
					else:
						should_wake = true
			else:
				should_wake = true
		if should_wake:
			_phase = 2
			print("[Sleep] Hora de despertar")
	elif _phase == 2:
		if controller != null and controller.has_method("set_ocupado"):
			controller.set_ocupado(false)
		var needs = controller.get_needs() if controller.has_method("get_needs") else null
		if needs != null:
			needs.sleep(minf(60.0, _sleep_timer * 0.2))
		var bb = controller.get_blackboard()
		if bb != null:
			bb.set_value("needs_urgent", &"")
		controller.get_state_machine().transition_to(&"Idle")
		print("[Sleep] DespertÃƒÆ’Ã‚Â³, energÃƒÆ’Ã‚Â­a restaurada")


func tick(delta: float) -> void:
	if controller != null:
		var needs = controller.get_needs()
		if needs != null and needs.energy < 5.0 and _phase == 0:
			_phase = 1
			_sleep_timer = 0.0
			print("[Sleep] Urgencia de energÃƒÆ’Ã‚Â­a, durmiendo inmediatamente")


func exit() -> void:
	_phase = 0
	_sleep_timer = 0.0
	if controller != null:
		var bb = controller.get_blackboard()
		if bb != null:
			bb.set_value("current_destination", &"")
	print("[Sleep] Saliendo")
