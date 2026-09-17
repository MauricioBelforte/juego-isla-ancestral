extends "res://scripts/ia_npc/states/base_state.gd"
## M64: React State ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â reacciona a clima/eventos

const PRIORITY: int = 50
const REACT_DUR: float = 15.0

enum Type { RAIN, EVENT, PLAYER, DANGER }
var _react_type: int = 0
var _react_timer: float = 0.0



func enter(data: Dictionary = {}) -> void:
	_react_type = int(data.get("type", 0))
	_react_timer = REACT_DUR
	print("[React] Tipo=%d entrando" % _react_type)
	if controller != null:
		var bb = controller.get_blackboard()
		if bb != null:
			match _react_type:
				0:
					bb.set_value("is_raining", true)
					bb.set_value("current_destination", &"refugio")
				1:
					bb.set_value("event_active", true)
				3:
					bb.set_value("current_destination", &"casa")


func update(delta: float) -> void:
	_react_timer -= delta
	match _react_type:
		0:
			if controller != null and controller.has_method("get_location_position"):
				var loc = controller.get_location_position("casa")
				if loc != null:
					controller.navigate_to(loc)
		1:
			if controller != null and controller.has_method("get_location_position"):
				var loc = controller.get_location_position("plaza")
				if loc != null:
					controller.navigate_to(loc)
		2:
			if controller != null and controller.has_method("stop_movement"):
				controller.stop_movement()
		3:
			if controller != null and controller.has_method("get_location_position"):
				var loc = controller.get_location_position("casa")
				if loc != null:
					controller.navigate_to(loc)


func tick(_delta: float) -> void:
	if controller != null:
		var bb = controller.get_blackboard()
		if bb != null:
			match _react_type:
				0:
					var weather = get_node_or_null("/root/Weather")
					if weather != null and not weather.is_raining():
						exit(); return
				1:
					if not bb.get_value("event_active", false):
						exit(); return
				3:
					exit(); return
	if _react_timer <= 0:
		exit()


func exit() -> void:
	print("[React] ReacciÃƒÆ’Ã‚Â³n terminada (tipo=%d)" % _react_type)
	if controller != null:
		var bb = controller.get_blackboard()
		if bb != null:
			bb.set_value("is_raining", false)
			bb.set_value("event_active", false)
			bb.set_value("current_destination", &"")
	controller.get_state_machine().transition_to(&"Idle")
