class_name ValidationUtils
extends RefCounted

## Validadores de invariantes del juego (M111 - Código de Calidad).
## Heurísticas defensivas: no acoplan contra registros concretos para no crear
## dependencias circulares con M14/M19/M22.

const WORLD_HALF := 2560.0  # medio mundo (isla 10x, M09/M167). Ajustar si cambia.

static func is_valid_position(p: Variant) -> bool:
	if not (p is Vector3):
		return false
	var v := p as Vector3
	if not is_finite(v.x) or not is_finite(v.y) or not is_finite(v.z):
		return false
	if abs(v.x) > WORLD_HALF or abs(v.z) > WORLD_HALF:
		return false
	return true

static func is_valid_item_id(id: String) -> bool:
	if id == "" or id.contains(" "):
		return false
	return id.begins_with("item_") or (id.length() <= 64 and id.is_valid_identifier())

static func is_valid_npc_id(id: String) -> bool:
	if id == "" or id.contains(" "):
		return false
	return id.begins_with("npc_") or (id.length() <= 64 and id.is_valid_identifier())

static func is_valid_mission_id(id: String) -> bool:
	if id == "" or id.contains(" "):
		return false
	return id.begins_with("mission_") or id.begins_with("quest_") or (id.length() <= 64 and id.is_valid_identifier())
