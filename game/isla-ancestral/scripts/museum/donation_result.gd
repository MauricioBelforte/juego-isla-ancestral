# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M37: DonationResult — resultado estructurado de una donación (03-Diseno §5).
# reason: "" (aceptada) | "duplicate" | "not_owned" | "wrong_exhibition" | "invalid_item"
class_name DonationResult
extends RefCounted

var accepted: bool = false
var reason: String = ""
var item_id: String = ""
var exhibition_id: String = ""


func _init(p_exhibition: String, p_item: String, p_ok: bool, p_reason: String = "") -> void:
	exhibition_id = p_exhibition
	item_id = p_item
	accepted = p_ok
	reason = p_reason
