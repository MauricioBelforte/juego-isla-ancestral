# Modelo: Hy3
# Plataforma: Kilo
# Fecha: 2026-08-29
#
# M21: DialogueUI — capa de presentacion minima (CanvasLayer autocontenido, no toca scripts/ui de M53).
# Escucha las senales del DialogueManager (autoload) y muestra el dialogo.
# El jugador puede avanzar con Enter/E y elegir opciones con click o numero.

## UI de dialogo: caja de texto con opciones ramificadas, desacoplada del manager.
class_name DialogueUI
extends CanvasLayer

var _panel: Panel = null
var _label: Label = null
var _options_container: VBoxContainer = null
var _opciones_activas: Array = []

func _ready() -> void:
	layer = 15
	_crear_ui()
	var dm = get_node_or_null("/root/DialogueManager")
	if dm:
		dm.node_entered.connect(_on_node_entered)
		dm.dialogue_ended.connect(_on_dialogue_ended)
	hide()

func _crear_ui() -> void:
	_panel = Panel.new()
	_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_panel.offset_top = -200
	_panel.offset_bottom = -20
	_panel.offset_left = 40
	_panel.offset_right = -40
	add_child(_panel)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.05, 0.05, 0.08, 0.88)
	sb.set_corner_radius_all(8)
	_panel.add_theme_stylebox_override("panel", sb)
	_label = Label.new()
	_label.name = "Texto"
	_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_label.offset_top = 8
	_label.offset_bottom = -60
	_label.offset_left = 12
	_label.offset_right = -12
	_label.add_theme_font_size_override("font_size", 14)
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_panel.add_child(_label)
	_options_container = VBoxContainer.new()
	_options_container.name = "Opciones"
	_options_container.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_options_container.offset_top = -70
	_options_container.offset_bottom = -8
	_options_container.offset_left = 12
	_options_container.offset_right = -12
	_options_container.alignment = BoxContainer.ALIGNMENT_END
	_panel.add_child(_options_container)

func _on_node_entered(_node_id: String, speaker_key: String, texto: String, tipo: int, options: Array) -> void:
	show()
	_label.text = texto
	_limpiar_opciones()
	if tipo == DialogueNode.TIPO_OPCIONES and options.size() > 0:
		_options_container.show()
		_opciones_activas = options.duplicate()
		for i in options.size():
			var op = options[i]
			var btn := Button.new()
			btn.text = "[" + str(i + 1) + "] " + str(op.text_key)
			btn.pressed.connect(_on_opt_pressed.bind(i))
			_options_container.add_child(btn)
	else:
		_options_container.hide()

func _on_dialogue_ended(_id: String, _ultimo: String) -> void:
	hide()
	_limpiar_opciones()

func _limpiar_opciones() -> void:
	for child in _options_container.get_children():
		child.queue_free()
	_opciones_activas = []

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var dm = get_node_or_null("/root/DialogueManager")
		if dm == null:
			return
		match event.keycode:
			KEY_ENTER, KEY_SPACE:
				dm.advance()
				get_viewport().set_input_as_handled()
		if _opciones_activas.size() > 0:
			var idx := -1
			match event.keycode:
				KEY_1: idx = 0
				KEY_2: idx = 1
				KEY_3: idx = 2
				KEY_4: idx = 3
			if idx >= 0 and idx < _opciones_activas.size():
				dm.choose_option(idx)
				get_viewport().set_input_as_handled()

func _on_opt_pressed(idx: int) -> void:
	var dm = get_node_or_null("/root/DialogueManager")
	if dm:
		dm.choose_option(idx)