# Modelo: agnes-2.5-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M64: IA de NPC â€” Reproductor de Rutinas diarias
#
# Lee el perfil del NPC y determina la prÃ³xima acciÃ³n segÃºn la hora actual.
# Cada NPC tiene una rutina diaria en su VillagerProfile.rutina_diaria.
# IntegraciÃ³n con M29 (GameClock) para hora/minuto.

extends Node
class_name RoutinePlayer

## Perfil del NPC
@export var npc_profile: Resource = null

## Hora actual de despertar (desde la rutina o default 6)
var wake_hour: int = 6
## Ãšltimo slot ejecutado
var _last_slot_index: int = -1
## Ãndice del slot actual
var _current_slot_index: int = 0


func _ready() -> void:
	pass


## Obtener la prÃ³xima acciÃ³n basada en la hora actual
func get_next_action(controller: Node) -> Dictionary:
	if npc_profile == null:
		return {}
	var gt = get_node_or_null("/root/GameTime")
	if gt == null:
		return {}
	var hora = gt.get_hora()
	var minuta = gt.get_minuto()
	var rutina = npc_profile.rutina_diaria if npc_profile != null else {}
	if rutina.is_empty():
		return {"action": &"idle", "location": &"casa"}
	# Buscar el slot correspondiente a la hora actual
	for key in rutina.keys():
		var parts = key.split(":")
		if parts.size() < 2:
			continue
		var slot_hour = int(parts[0])
		var slot_min = int(parts[1]) if parts.size() > 1 else 0
		if hora == slot_hour and minuta >= slot_min:
			var action = rutina[key]
			return {"action": action, "location": _action_to_location(action), "hour": slot_hour}
	# Si no hay slot activo, devolver el siguiente
	return _get_next_slot(rutina, hora, minuta)


func _get_next_slot(rutina: Dictionary, hora: int, minuto: int) -> Dictionary:
	"""Buscar el prÃ³ximo slot en el futuro."""
	var best_key = ""
	var best_diff = 999
	for key in rutina.keys():
		var parts = key.split(":")
		if parts.size() < 2:
			continue
		var slot_hour = int(parts[0])
		var slot_min = int(parts[1])
		var diff = (slot_hour - hora) * 60 + (slot_min - minuto)
		if diff > 0 and diff < best_diff:
			best_diff = diff
			best_key = key
	if best_key != "":
		var action = rutina[best_key]
		return {"action": action, "location": _action_to_location(action), "hour": int(best_key.split(":")[0])}
	return {"action": &"idle", "location": &"casa"}


func _action_to_location(action: StringName) -> StringName:
	match action:
		&"trabajar", &"work":
			return &"trabajo"
		&"comer", &"eat":
			return &"comedor"
		&"dormir", &"sleep":
			return &"casa"
		&"ir_a_casa", &"go_home":
			return &"casa"
		&"ir_a_trabajar", &"go_to_work":
			return &"trabajo"
		&"socializar", &"social":
			return &"plaza"
		&"libre", &"free":
			return &"pueblo"
		_:
			return &"casa"


## Retorna la hora de despertar del NPC
func get_wake_hour() -> int:
	return wake_hour


## Verificar si es hora de una acciÃ³n especÃ­fica
func is_action_due(action: StringName, current_hour: int, current_minute: int) -> bool:
	if npc_profile == null:
		return false
	var rutina = npc_profile.rutina_diaria if npc_profile != null else {}
	var key = "%02d:00" % current_hour
	if rutina.has(key):
		return rutina[key] == action
	return false


## Resetear al cambio de dÃ­a
func reset_daily() -> void:
	_last_slot_index = -1
	_current_slot_index = 0
	print("[RoutinePlayer] Rutina reseteada para %s" % ((npc_profile.id if npc_profile != null else "unknown")))
