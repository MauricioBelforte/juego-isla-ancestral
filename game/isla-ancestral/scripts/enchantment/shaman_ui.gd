extends Control

@export var npc_node: Node3D = null

var _panel: Panel = null
var _tools_container: VBoxContainer = null
var _enchantments_container: VBoxContainer = null
var _info_label: Label = null
var _close_button: Button = null
var _enchant_button: Button = null
var _particulas: CPUParticles2D = null
var _sonido: AudioStreamPlayer = null
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

	# M163 B: feedback placeholder (particulas + sonido) sin assets externos.
	_particulas = CPUParticles2D.new()
	_particulas.amount = 18
	_particulas.lifetime = 0.6
	_particulas.one_shot = true
	_particulas.explosiveness = 1.0
	_particulas.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_particulas.emission_rect_extents = Vector2(60, 8)
	_particulas.direction = Vector2(0, -1)
	_particulas.spread = 70.0
	_particulas.gravity = Vector2(0, 60)
	_particulas.initial_velocity_min = 40.0
	_particulas.initial_velocity_max = 90.0
	_particulas.scale_amount_min = 1.5
	_particulas.scale_amount_max = 3.0
	_panel.add_child(_particulas)
	_sonido = AudioStreamPlayer.new()
	_sonido.name = "SfxEncantar"
	add_child(_sonido)

func _cargar_encantamientos() -> void:
	for child in _enchantments_container.get_children():
		child.queue_free()

	var system = get_node_or_null("/root/EnchantmentSystem")
	if not system:
		return

	for ench in system.get_all_enchantments():
		var btn := Button.new()
		btn.text = "[T" + str(ench.tool_tier) + "] " + ench.display_name + " (" + str(ench.incense_cost) + " incienso, " + str(ench.coin_cost) + " monedas)"
		btn.pressed.connect(func(): _seleccionar_encantamiento(ench.id))
		_enchantments_container.add_child(btn)

## M163: lista de ids de herramientas del jugador (BOLSILLO+MOCHILA).
## Compartida con ShamanNPC (progresion de dialogo).
static func ids_herramientas(inventario: Node, item_db: Node) -> Array:
	var ids: Array = []
	if inventario == null or item_db == null:
		return ids
	for container_id in [inventario.CONTAINER_TYPE_CLASS.Id.BOLSILLO,
			inventario.CONTAINER_TYPE_CLASS.Id.MOCHILA]:
		var slots = inventario.get_container_slots(container_id)
		for slot_data in slots:
			var item = item_db.get_item(slot_data.item_id)
			if item and item.categoria == ItemData.Categoria.HERRAMIENTAS:
				ids.append(slot_data.item_id)
	return ids

## M163 B: pago de monedas via EconomyManager (M38), duck-typed como
## crafting_service (no dependemos de que el autoload exista en tests).
func _puede_pagar(total: int) -> bool:
	var eco = get_node_or_null("/root/EconomyManager")
	if eco and eco.has_method("puede_pagar"):
		return eco.puede_pagar(total)
	var inventario = get_node_or_null("/root/Inventario")
	return inventario != null and inventario.count_item("moneda", true) >= total

func _retirar(total: int) -> bool:
	if total <= 0:
		return true
	var eco = get_node_or_null("/root/EconomyManager")
	if eco and eco.has_method("retirar_monedas"):
		return eco.retirar_monedas(total)
	var inventario = get_node_or_null("/root/Inventario")
	if inventario == null or inventario.count_item("moneda", true) < total:
		return false
	return inventario.remover_items({"moneda": total})

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
			if item and item.categoria == ItemData.Categoria.HERRAMIENTAS:
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

	var tiene_incienso = system.has_incense(ench.incense_cost)
	var tiene_monedas = _puede_pagar(ench.coin_cost)

	_info_label.text = "Encantar: " + _selected_tool_slot.item_id + " con " + ench.display_name + "\n"
	_info_label.text += "Costo: " + str(ench.incense_cost) + " incienso, " + str(ench.coin_cost) + " monedas\n"
	_info_label.text += "Incienso: " + str(system.get_incense()) + " (" + ("OK" if tiene_incienso else "FALTA") + ")\n"
	_info_label.text += "Monedas: " + ("OK" if tiene_monedas else "FALTA")

	_enchant_button.disabled = not (tiene_incienso and tiene_monedas)

func _on_enchant_pressed() -> void:
	encantar_seleccion()

## M163 B: flujo completo de encantamiento con feedback (exitos y fallos).
## Devuelve true solo si el encantamiento se aplico. Testeable headless.
func encantar_seleccion() -> bool:
	if _selected_tool_slot.is_empty() or _selected_enchantment_id == "":
		return false

	var system = get_node_or_null("/root/EnchantmentSystem")
	if not system:
		return false

	var ench = system.get_enchantment(_selected_enchantment_id)
	if not ench:
		_fallo("Encantamiento desconocido")
		return false

	var tool_id = _selected_tool_slot.item_id

	if system.is_enchanted(tool_id):
		_fallo("La herramienta ya esta encantada")
		return false

	if not system.has_incense(ench.incense_cost):
		_fallo("No tienes suficiente incienso")
		return false

	if not _puede_pagar(ench.coin_cost):
		_fallo("No tienes suficientes monedas")
		return false

	if not system.enchant_tool(tool_id, _selected_enchantment_id):
		_fallo("No se pudo encantar la herramienta")
		return false

	if not _retirar(ench.coin_cost):
		# Nunca deberia pasar (puede_pagar arriba); rollback defensivo M163.
		system.remove_enchantment(tool_id)
		_fallo("Error al cobrar monedas")
		return false

	_actualizar_info()
	_exito(ench)
	return true

## Feedback de exito (M163 B): label verde + brillo (tween del panel) +
## particulas placeholder + beep procedural (sin assets externos).
func _exito(ench: Resource) -> void:
	_info_label.text = "Encantamiento aplicado con exito!"
	_info_label.add_theme_color_override("font_color", Color(0.35, 0.9, 0.45))
	if ench and ench is Resource and "visual_color" in ench:
		var c: Color = ench.visual_color
		if _panel:
			var tw := create_tween()
			tw.tween_property(_panel, "modulate", c, 0.12)
			tw.tween_property(_panel, "modulate", Color.WHITE, 0.30)
		if _particulas:
			_particulas.color = c
			_particulas.restart()
			_particulas.emitting = true
	_beep()

## Feedback de fallo (M163 B): label rojo, sin animacion agresiva (cozy).
func _fallo(msg: String) -> void:
	_info_label.text = msg
	_info_label.add_theme_color_override("font_color", Color(0.95, 0.4, 0.35))

## Beep procedural suave 660->880 Hz, 0.12 s (sin assets, estilo M44).
func _beep() -> void:
	if _sonido == null:
		return
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = 22050
	var n := int(22050 * 0.12)
	var bytes := PackedByteArray()
	bytes.resize(n * 2)
	for i in n:
		var tt := float(i) / 22050.0
		var env := 1.0 - tt / 0.12
		var frec := 660.0 + 220.0 * (tt / 0.12)
		var s := int(sin(TAU * frec * tt) * 0.2 * env * 32767.0)
		bytes.encode_s16(i * 2, s)
	wav.data = bytes
	_sonido.stream = wav
	_sonido.play()
