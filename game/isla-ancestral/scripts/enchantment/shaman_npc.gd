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
	# M163 B: dialogo contextual local segun progresion (L47/L56/L57/L58).
	#  - 0 encantos -> shaman_intro (primera visita)
	#  - 1+ encantos -> shaman_regreso (recuerda {encantos} encantos)
	#  - todas encantadas -> shaman_todas (frase especial)
	var system = get_node_or_null("/root/EnchantmentSystem")
	var encantos := 0
	if system and system.has_method("get_encantos_totales"):
		encantos = system.get_encantos_totales()
	var inventario = get_node_or_null("/root/Inventario")
	var item_db = get_node_or_null("/root/ItemDatabase")
	var ui_script = load("res://scripts/enchantment/shaman_ui.gd")
	var ids: Array = []
	if ui_script and ui_script.has_method("ids_herramientas"):
		ids = ui_script.ids_herramientas(inventario, item_db)
	var todas := bool(system and system.has_method("todas_encantadas")
			and system.todas_encantadas(ids))
	var id_dialogo := dialogue_id
	if todas:
		id_dialogo = "shaman_todas"
	elif encantos > 0:
		id_dialogo = "shaman_regreso"
	var dialogue_manager = get_node_or_null("/root/DialogueManager")
	if dialogue_manager and dialogue_manager.has_method("start_dialogue"):
		# start_dialogue valida el grafo; si falla, la UI se abre igual (degrada
		# a sin dialogo en vez de bloquear el flujo — RF cozy).
		dialogue_manager.start_dialogue(id_dialogo, {"npc_id": name, "encantos": encantos})
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
