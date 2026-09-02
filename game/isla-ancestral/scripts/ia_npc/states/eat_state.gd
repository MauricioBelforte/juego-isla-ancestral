extends "res://scripts/ia_npc/states/base_state.gd"
## M64: Eat State ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â va a comer, come, regresa

const PRIORITY: int = 35
const EAT_DUR: float = 30.0

enum Phase { GO, EATING, LEAVE }
var _phase: int = 0
var _eat_timer: float = 0.0



func enter(_data: Dictionary = {}) -> void:
	_phase = 0
	_eat_timer = 0.0
	print("[Eat] Entrando")
	if controller != null:
		var bb = controller.get_blackboard()
		if bb != null:
			bb.set_value("current_destination", &"eat")


func update(delta: float) -> void:
	if _phase == 0:
		if controller != null and controller.has_method("get_location_position"):
			var loc = controller.get_location_position("comedor")
			if loc != null:
				controller.navigate_to(loc)
		if controller != null and controller.has_method("is_at_destination"):
			if controller.is_at_destination():
				_phase = 1
				_eat_timer = 0.0
				print("[Eat] LlegÃƒÆ’Ã‚Â³ al comedor")
	elif _phase == 1:
		if controller != null and controller.has_method("stop_movement"):
			controller.stop_movement()
		_eat_timer += delta
		if _eat_timer >= EAT_DUR:
			var needs = controller.get_needs() if controller.has_method("get_needs") else null
			if needs != null:
				needs.eat(40.0)
			var bb = controller.get_blackboard()
			if bb != null:
				bb.set_value("needs_urgent", &"")
			_phase = 2
			print("[Eat] TerminÃƒÆ’Ã‚Â³ de comer")
	elif _phase == 2:
		if controller != null and controller.has_method("get_location_position"):
			var home = controller.get_location_position("casa")
			if home != null:
				controller.navigate_to(home)
		if controller != null and controller.has_method("is_at_destination"):
			if controller.is_at_destination():
				controller.get_state_machine().transition_to(&"Idle")


func tick(_delta: float) -> void:
	if controller != null:
		var needs = controller.get_needs()
		if needs != null and needs.hunger > 80.0 and _phase == 1:
			_phase = 2
			print("[Eat] Hambre satisfecha, saliendo")


func exit() -> void:
	_phase = 0
	_eat_timer = 0.0
	if controller != null:
		var bb = controller.get_blackboard()
		if bb != null:
			bb.set_value("current_destination", &"")
	print("[Eat] Saliendo")
