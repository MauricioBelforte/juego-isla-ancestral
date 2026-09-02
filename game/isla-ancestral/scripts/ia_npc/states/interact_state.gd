extends "res://scripts/ia_npc/states/base_state.gd"
## M64: Interact State ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â habla con jugador

const PRIORITY: int = 45
const TALK_DUR: float = 10.0

var _interact_type: int = 0
var _partner_id: StringName = &""
var _interact_timer: float = 0.0



func enter(data: Dictionary = {}) -> void:
	_interact_type = int(data.get("type", 0))
	_partner_id = data.get("partner_id", &"") as StringName
	_interact_timer = TALK_DUR
	print("[Interact] Tipo=%d partner=%s" % [_interact_type, _partner_id])
	if controller != null:
		controller.set_ocupado(true)
		var bb = controller.get_blackboard()
		if bb != null:
			bb.set_value("current_destination", &"")


func update(delta: float) -> void:
	if controller != null and controller.has_method("stop_movement"):
		controller.stop_movement()
	_interact_timer -= delta


func tick(_delta: float) -> void:
	if _interact_timer <= 0:
		print("[Interact] InteracciÃƒÆ’Ã‚Â³n terminada")
		if controller != null:
			controller.set_ocupado(false)
		controller.get_state_machine().transition_to(&"Idle")
		return
	if controller != null:
		var players: Array[Node] = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			var dist = controller.global_position.distance_to(players[0].global_position)
			if dist > 5.0:
				print("[Interact] Jugador se alejÃƒÆ’Ã‚Â³")
				if controller != null:
					controller.set_ocupado(false)
				controller.get_state_machine().transition_to(&"Idle")


func exit() -> void:
	_interact_timer = 0.0
	if controller != null:
		controller.set_ocupado(false)
	print("[Interact] Saliendo")
