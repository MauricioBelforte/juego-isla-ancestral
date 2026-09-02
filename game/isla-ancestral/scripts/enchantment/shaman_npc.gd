extends InteractableBase

@export var dialogue_id: String = "shaman_intro"
@export var spawn_position: Vector3 = Vector3(320, 35, 300)

var _ui: Control = null

func _ready() -> void:
	super._ready()
	categoria = &"npc"
	prioridad = 10
	radio = 2.5
	global_position = spawn_position

func interactuar(_datos: Dictionary) -> void:
	var dialogue_manager = get_node_or_null("/root/DialogueManager")
	if dialogue_manager and dialogue_manager.has_method("start_dialogue"):
		dialogue_manager.start_dialogue(dialogue_id, {"npc_id": name})
	_abrir_ui_encantamiento()

func _abrir_ui_encantamiento() -> void:
	if _ui:
		_ui.cerrar()
		_ui = null
		return

	var ui_script = preload("res://scripts/enchantment/shaman_ui.gd")
	if not ui_script:
		push_warning("[ShamanNPC] ShamanUI no disponible")
		return

	_ui = ui_script.new()
	_ui.npc_node = self
	var ui_root = get_node_or_null("/root/UIRoot")
	if ui_root:
		ui_root.add_child(_ui)
	_ui.abrir()
