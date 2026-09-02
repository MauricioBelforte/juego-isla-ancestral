extends Control

@export var npc_node: Node3D = null

var _panel: Panel = null
var _tools_container: VBoxContainer = null
var _enchantments_container: VBoxContainer = null
var _info_label: Label = null
var _close_button: Button = null
var _enchant_button: Button = null
var _selected_tool_slot: Dictionary = {}
var _selected_enchantment_id: String = ""

func _ready() -> void:
	_crear_ui()
	hide()

func _crear_ui() -> void:
	_panel = Panel.new()
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.offset_left = -200
	_panel.offset_top = -150
	_panel.offset_right = 200
	_panel.offset_bottom = 150
	add_child(_panel)

	var vbox := VBoxContainer.new()
	_panel.add_child(vbox)

	var title := Label.new()
	title.text = "Encantamientos del Chaman"
	vbox.add_child(title)

	_info_label = Label.new()
	_info_label.text = "Selecciona una herramienta y un encantamiento"
	vbox.add_child(_info_label)

	_tools_container = VBoxContainer.new()
	vbox.add_child(_tools_container)

	var enc_label := Label.new()
	enc_label.text = "Encantamientos disponibles:"
	vbox.add_child(enc_label)

	_enchantments_container = VBoxContainer.new()
	vbox.add_child(_enchantments_container)

	var buttons := HBoxContainer.new()
	_enchant_button = Button.new()
	_enchant_button.text = "Encantar"
	_enchant_button.pressed.connect(_on_enchant_pressed)
	buttons.add_child(_enchant_button)

	_close_button = Button.new()
	_close_button.text = "Cerrar"
	_close_button.pressed.connect(hide)
	buttons.add_child(_close_button)

	vbox.add_child(buttons)

	_cargar_encantamientos()

func _cargar_encantamientos() -> void:
	for child in _enchantments_container.get_children():
		child.queue_free()

	var system = get_node_or_null("/root/EnchantmentSystem")
	if not system:
		return

	for ench in system.get_all_enchantments():
		var btn := Button.new()
		btn.text = ench.display_name + " (" + str(ench.incense_cost) + " incienso, " + str(ench.coin_cost) + " monedas)"
		btn.pressed.connect(func(): _seleccionar_encantamiento(ench.id))
		_enchantments_container.add_child(btn)

func abrir() -> void:
	_cargar_herramientas()
	show()

func cerrar() -> void:
	hide()

func _cargar_herramientas() -> void:
	for child in _tools_container.get_children():
		child.queue_free()

	var inventario = get_node_or_null("/root/Inventario")
	if not inventario:
		return

	var item_db = get_node_or_null("/root/ItemDatabase")
	if not item_db:
		return

	for container_id in [inventario.CONTAINER_TYPE_CLASS.Id.BOLSILLO, inventario.CONTAINER_TYPE_CLASS.Id.MOCHILA]:
		var slots = inventario.get_container_slots(container_id)
		for i in range(slots.size()):
			var slot_data = slots[i]
			var item = item_db.get_item(slot_data.item_id)
			if item and item.categoria == item_db.Categoria.HERRAMIENTAS:
				var btn := Button.new()
				btn.text = item.nombre + " (slot " + str(i) + ")"
				btn.pressed.connect(func(): _seleccionar_herramienta(container_id, i, slot_data.item_id))
				_tools_container.add_child(btn)

func _seleccionar_herramienta(container_id: int, slot_idx: int, item_id: String) -> void:
	_selected_tool_slot = {"container": container_id, "slot": slot_idx, "item_id": item_id}
	_actualizar_info()

func _seleccionar_encantamiento(enchantment_id: String) -> void:
	_selected_enchantment_id = enchantment_id
	_actualizar_info()

func _actualizar_info() -> void:
	if _selected_tool_slot.is_empty() or _selected_enchantment_id == "":
		_info_label.text = "Selecciona una herramienta y un encantamiento"
		return

	var system = get_node_or_null("/root/EnchantmentSystem")
	if not system:
		return

	var ench = system.get_enchantment(_selected_enchantment_id)
	if not ench:
		return

	var inventario = get_node_or_null("/root/Inventario")
	var tiene_incienso = system.has_incense(ench.incense_cost)
	var tiene_monedas = false
	if inventario:
		tiene_monedas = inventario.count_item("moneda", true) >= ench.coin_cost

	_info_label.text = "Encantar: " + _selected_tool_slot.item_id + " con " + ench.display_name + "\n"
	_info_label.text += "Costo: " + str(ench.incense_cost) + " incienso, " + str(ench.coin_cost) + " monedas\n"
	_info_label.text += "Incienso: " + str(system.get_incense()) + " (" + ("OK" if tiene_incienso else "FALTA") + ")\n"
	_info_label.text += "Monedas: " + ("OK" if tiene_monedas else "FALTA")

	_enchant_button.disabled = not (tiene_incienso and tiene_monedas)

func _on_enchant_pressed() -> void:
	if _selected_tool_slot.is_empty() or _selected_enchantment_id == "":
		return

	var system = get_node_or_null("/root/EnchantmentSystem")
	var inventario = get_node_or_null("/root/Inventario")
	if not system or not inventario:
		return

	var ench = system.get_enchantment(_selected_enchantment_id)
	if not ench:
		return

	if not system.has_incense(ench.incense_cost):
		_info_label.text = "No tienes suficiente incienso"
		return

	if inventario.count_item("moneda", true) < ench.coin_cost:
		_info_label.text = "No tienes suficientes monedas"
		return

	var tool_id = _selected_tool_slot.item_id
	if system.enchant_tool(tool_id, _selected_enchantment_id):
		inventario.remover_items({"moneda": ench.coin_cost})
		_info_label.text = "Encantamiento aplicado con exito!"
		_actualizar_info()
	else:
		_info_label.text = "No se pudo encantar la herramienta"
