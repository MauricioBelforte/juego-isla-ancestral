extends "res://scripts/ia_npc/states/base_state.gd"
## M64: Idle State ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â espera, mira,idget

const PRIORITY: int = 10
const SUB_MIN: float = 2.0
const SUB_MAX: float = 8.0
const SUB_STATES: Array[String] = ["Wait", "Look", "Fidget"]

var _sub_timer: float = 0.0
var _sub_state: String = "Wait"
var _next_sub: float = 0.0



func enter(_data: Dictionary = {}) -> void:
	_sub_timer = 0.0
	_next_sub = randf_range(SUB_MIN, SUB_MAX)
	_sub_state = "Wait"
	print("[Idle] Entrando en Idle")


func update(delta: float) -> void:
	if controller != null and controller.has_method("stop_movement"):
		controller.stop_movement()
	_sub_timer += delta


func tick(delta: float) -> void:
	_next_sub -= delta
	if _next_sub <= 0:
		_sub_state = SUB_STATES[randi() % SUB_STATES.size()]
		_next_sub = randf_range(SUB_MIN, SUB_MAX)
		print("[Idle] Sub-estado: %s" % _sub_state)
	if controller == null:
		return
	var bb = controller.get_blackboard() if controller.has_method("get_blackboard") else null
	if bb == null:
		return
	var urgent: StringName = bb.get_value("needs_urgent", &"")
	if urgent == &"hunger":
		controller.get_state_machine().transition_to(&"Eat")
		return
	if urgent == &"energy":
		controller.get_state_machine().transition_to(&"Sleep")
		return
	if urgent == &"social":
		var nearby = bb.get_value("nearby_npcs", [])
		if nearby is Array and nearby.size() > 0:
			controller.get_state_machine().transition_to(&"Social", {"partner": nearby[0]})
			return
	if bb.get_value("event_active", false):
		controller.get_state_machine().transition_to(&"React")
		return
	if bb.get_value("is_night", false) and bb.get_value("energy", 100.0) < 40.0:
		controller.get_state_machine().transition_to(&"Sleep")
		return
	if bb.get_value("is_storming", false):
		controller.get_state_machine().transition_to(&"React")
		return
	if controller.has_method("check_routine_transition"):
		var rt = controller.check_routine_transition()
		if rt is Dictionary and rt.has("target"):
			controller.get_state_machine().transition_to(rt.target, rt.get("data", {}))
			return


func exit() -> void:
	print("[Idle] Saliendo de Idle")
