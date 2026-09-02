# Modelo: agnes-2.5-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M64: IA de NPC — Blackboard (datos compartidos entre estados)
#
# Almacena información contextual que todos los estados necesitan consultar:
# posición del jugador, clima actual, evento activo, estado de necesidades, etc.

extends RefCounted
class_name NPCBlackboard

## Datos del blackboard
var data: Dictionary = {}

## Keys comunes del proyecto:
## "target_position"     -> Vector3        Destino de navegación
## "current_destination" -> StringName     Nombre del destino (casa, trabajo, etc.)
## "is_raining"          -> bool           Clima lluvia (M32)
## "is_storming"         -> bool           Clima tormenta (M32)
## "player_position"     -> Vector3        Posición actual del jugador
## "nearby_npcs"         -> Array[StringName] NPCs cercanos
## "current_event"       -> StringName     Evento activo (M74)
## "event_active"        -> bool           ¿Hay evento en curso?
## "is_night"            -> bool           Es de noche (M31)
## "needs_urgent"        -> StringName     Necesidad urgente: "hunger"/"energy"/"social"/""

func set_value(key: StringName, value: Variant) -> void:
	data[key] = value


func get_value(key: StringName, default: Variant = null) -> Variant:
	return data.get(key, default)


func has_value(key: StringName) -> bool:
	return data.has(key)


func clear() -> void:
	data.clear()


func get_player_position() -> Vector3:
	return data.get("player_position", Vector3.ZERO)


func is_raining() -> bool:
	return data.get("is_raining", false)


func is_storming() -> bool:
	return data.get("is_storming", false)


func is_night() -> bool:
	return data.get("is_night", false)


func get_current_event() -> StringName:
	return data.get("current_event", &"")


func has_active_event() -> bool:
	return data.get("event_active", false)


func get_urgent_need() -> StringName:
	return data.get("needs_urgent", &"")


func to_dict() -> Dictionary:
	return data.duplicate()


static func from_dict(d: Dictionary) -> NPCBlackboard:
	var bb := NPCBlackboard.new()
	bb.data = d
	return bb
