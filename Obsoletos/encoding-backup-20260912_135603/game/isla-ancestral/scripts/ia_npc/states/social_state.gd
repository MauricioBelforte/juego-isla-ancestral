extends "res://scripts/ia_npc/states/base_state.gd"
## M64: Social State ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â charla con otro NPC

const PRIORITY: int = 20
const GREET_DUR: float = 3.0
const CHAT_DUR: float = 45.0

var _social_partner: StringName = &""
var _social_duration: float = 0.0



func enter(data: Dictionary = {}) -> void:
	var partner_count: int = int(data.get("partner_count", 1))
	_social_duration = GREET_DUR if partner_count == 1 else CHAT_DUR
	_social_partner = data.get("partner", &"") as StringName
	print("[Social] Entrando (partner=%s, count=%d)" % [_social_partner, partner_count])
	if controller != null and controller.has_method("stop_movement"):
		controller.stop_movement()


func update(_delta: float) -> void:
	if _social_partner != &"" and controller != null:
		var vm = get_node_or_null("/root/VillagerManager")
		if vm != null:
			var partner = vm.obtener_vecino(str(_social_partner))
			if partner != null and is_instance_valid(partner):
				var dist = controller.global_position.distance_to(partner.global_position)
				if dist > 2.5:
					var dir = (partner.global_position - controller.global_position).normalized()
					controller.velocity = dir * 2.0
					controller.move_and_slide()


func tick(delta: float) -> void:
	_social_duration -= delta
	if _social_duration <= 0:
		print("[Social] Terminada")
		controller.get_state_machine().transition_to(&"Idle")
		return
	if _social_partner != &"":
		var vm = get_node_or_null("/root/VillagerManager")
		if vm != null:
			var partner = vm.obtener_vecino(str(_social_partner))
			if partner == null or not is_instance_valid(partner):
				print("[Social] Partner desapareciÃƒÆ’Ã‚Â³")
				controller.get_state_machine().transition_to(&"Idle")
				return
	if controller != null:
		var bb = controller.get_blackboard()
		if bb != null and bb.get_value("needs_urgent", &"") != &"":
			controller.get_state_machine().transition_to(&"Idle")
			return


func exit() -> void:
	if _social_partner != &"":
		print("[Social] TerminÃƒÆ’Ã‚Â³ con %s" % _social_partner)
	_social_partner = &""
	print("[Social] Saliendo")
