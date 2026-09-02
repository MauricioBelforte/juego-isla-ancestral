extends Node
## M64: NPC State base - all states extend this
## Extends Node (not RefCounted) so states can use get_node_or_null() and get_tree()
## for world lookups (VillagerManager, GameTime, Weather, etc.)

var controller: Object = null
var state_name: StringName = &"State"
var priority: int = 0

func enter(_data: Dictionary = {}) -> void: pass
func update(_delta: float) -> void: pass
func tick(_delta: float) -> void: pass
func exit() -> void: pass
func check_transitions() -> Dictionary: return {}

## Helper for state_machine to read state_name without .get() ambiguity
func get_state_name_raw() -> StringName:
	return state_name
