extends Node

signal enchantment_applied(tool_id: String, enchantment_id: String)
signal enchantment_removed(tool_id: String)
signal incense_changed(amount: int)

var _enchantments: Dictionary = {}
var _incense: int = 0
var _catalog: Dictionary = {}

func _ready() -> void:
	_load_catalog()

func _load_catalog() -> void:
	var dir = DirAccess.open("res://data/enchantments/")
	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
		while file != "":
			if file.ends_with(".tres"):
				var path = "res://data/enchantments/" + file
				var data = load(path)
				if data and data.get_script():
					_catalog[data.id] = data
			file = dir.get_next()

func get_enchantment(id: String) -> Resource:
	return _catalog.get(id, null)

func get_all_enchantments() -> Array[Resource]:
	var result: Array[Resource] = []
	for key in _catalog:
		result.append(_catalog[key])
	return result

func is_enchanted(tool_id: String) -> bool:
	return _enchantments.has(tool_id)

func get_tool_enchantment(tool_id: String) -> Resource:
	return _enchantments.get(tool_id, null)

func has_incense(amount: int) -> bool:
	return _incense >= amount

func get_incense() -> int:
	return _incense

func set_incense(amount: int) -> void:
	_incense = max(0, amount)
	incense_changed.emit(_incense)

func add_incense(amount: int) -> void:
	set_incense(_incense + amount)

func enchant_tool(tool_id: String, enchantment_id: String) -> bool:
	if is_enchanted(tool_id):
		return false
	var enchantment = get_enchantment(enchantment_id)
	if not enchantment:
		return false
	if not has_incense(enchantment.incense_cost):
		return false
	_incense -= enchantment.incense_cost
	_enchantments[tool_id] = enchantment
	incense_changed.emit(_incense)
	enchantment_applied.emit(tool_id, enchantment_id)
	return true

func remove_enchantment(tool_id: String) -> void:
	if _enchantments.has(tool_id):
		var ench = _enchantments[tool_id]
		_incense += ench.incense_cost
		_enchantments.erase(tool_id)
		incense_changed.emit(_incense)
		enchantment_removed.emit(tool_id)

func get_sell_bonus(tool_id: String) -> float:
	var ench = get_tool_enchantment(tool_id)
	if not ench:
		return 0.0
	return ench.ability_value

func get_active_ability(tool_id: String) -> Dictionary:
	var ench = get_tool_enchantment(tool_id)
	if not ench:
		return {}
	return {
		"type": ench.ability_type,
		"value": ench.ability_value,
		"tier": ench.tool_tier
	}

func to_dict() -> Dictionary:
	return {
		"enchantments": _enchantments.keys(),
		"incense": _incense
	}

func from_dict(data: Dictionary) -> void:
	_incense = data.get("incense", 0)
	_enchantments.clear()
	var ench_ids = data.get("enchantments", [])
	for tool_id in ench_ids:
		var ench_id = data.get("enchantment_" + tool_id, "")
		var ench = get_enchantment(ench_id)
		if ench:
			_enchantments[tool_id] = ench
