extends "res://scripts/ia_npc/states/base_state.gd"
## M64: Movement State ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â navega a destino

const PRIORITY: int = 30

var move_speed: float = 3.0
var run_speed: float = 5.0
var _in_a_hurry: bool = false



func enter(data: Dictionary = {}) -> void:
	_in_a_hurry = data.get("hurry", false)
	print("[Movement] Entrando (hurry=%s)" % _in_a_hurry)
	if controller != null and controller.has_method("get_navigation_agent"):
		var nav = controller.get_navigation_agent()
		if nav != null:
			nav.path_desired_distance = 1.0
			nav.target_desired_distance = 0.5
			nav.radius = 0.4


func update(delta: float) -> void:
	if controller == null:
		return
	var nav = controller.get_navigation_agent()
	if nav != null and not nav.is_navigation_finished():
		var next_pos = nav.get_next_path_position()
		var cur = controller.global_position
		var dir = (next_pos - cur).normalized()
		var spd = run_speed if _in_a_hurry else move_speed
		controller.velocity = dir * spd
		controller.move_and_slide()
		controller.get_state_machine().reset_stuck_timer()
	else:
		if controller.has_method("on_arrived"):
			controller.on_arrived()
		var dest: StringName = &""
		if controller.get_blackboard() != null:
			dest = controller.get_blackboard().get_value("current_destination", &"")
		match dest:
			&"work": controller.get_state_machine().transition_to(&"Work")
			&"eat": controller.get_state_machine().transition_to(&"Eat")
			&"sleep": controller.get_state_machine().transition_to(&"Sleep")
			&"social": controller.get_state_machine().transition_to(&"Social")
			_: controller.get_state_machine().transition_to(&"Idle")


func tick(delta: float) -> void:
	if controller == null:
		return
	var bb = controller.get_blackboard()
	if bb == null:
		return
	var urgent: StringName = bb.get_value("needs_urgent", &"")
	if urgent == &"hunger":
		controller.get_state_machine().transition_to(&"Eat")
		return
	if urgent == &"energy":
		controller.get_state_machine().transition_to(&"Sleep")
		return
	if bb.get_value("is_storming", false):
		controller.get_state_machine().transition_to(&"React")
		return


func exit() -> void:
	if controller != null and controller.has_method("stop_movement"):
		controller.stop_movement()
	print("[Movement] Saliendo")
