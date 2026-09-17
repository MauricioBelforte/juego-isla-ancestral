extends "res://scripts/ia_npc/states/base_state.gd"
## M64: Work State ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â trabaja durante duracion

const PRIORITY: int = 25

var _work_duration: float = 300.0
var _work_timer: float = 0.0



func enter(data: Dictionary = {}) -> void:
	_work_duration = float(data.get("duration", 300.0))
	_work_timer = 0.0
	print("[Work] Entrando (dur=%.0fs)" % _work_duration)
	if controller != null and controller.has_method("set_ocupado"):
		controller.set_ocupado(true)


func update(delta: float) -> void:
	if controller != null and controller.has_method("stop_movement"):
		controller.stop_movement()
	_work_timer += delta


func tick(delta: float) -> void:
	if _work_timer >= _work_duration:
		if controller != null and controller.has_method("set_ocupado"):
			controller.set_ocupado(false)
		print("[Work] Completado")
		controller.get_state_machine().transition_to(&"Idle")
		return
	if controller != null:
		var bb = controller.get_blackboard()
		if bb != null:
			var urgent: StringName = bb.get_value("needs_urgent", &"")
			if urgent == &"energy" and bb.get_value("energy", 100.0) < 10.0:
				controller.get_state_machine().transition_to(&"Sleep")
				return
			if bb.get_value("is_storming", false):
				controller.get_state_machine().transition_to(&"React")
				return


func exit() -> void:
	if controller != null and controller.has_method("set_ocupado"):
		controller.set_ocupado(false)
	print("[Work] Saliendo (timer=%.0f/%.0f)" % [_work_timer, _work_duration])
