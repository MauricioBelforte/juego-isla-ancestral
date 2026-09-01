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
var _expresion: Label = null
## M20 -> M21: ultima reaccion de regalo/nivel recibida (expresion + contexto)
## para que el retrato (M53/M87) la muestre. La UI la expone via get_ultima_reaccion.
var _ultima_reaccion: Dictionary = {}
## M20 -> M21 (M53): retrato grafico del hablante; cambia de expresion con la reaccion.
## Sin anotacion de tipo: NpcPortraitUI (class_name) no se resuelve en parse-time headless.
## Se crea en runtime (load().new()) y se usa por duck-typing.
var _portrait = null

func _ready() -> void:
	layer = 15
	_crear_ui()
	var dm = get_node_or_null("/root/DialogueManager")
	if dm:
		dm.node_entered.connect(_on_node_entered)
		dm.dialogue_ended.connect(_on_dialogue_ended)
		# M20 -> M21: consumir la reaccion al regalo/nivel para expresion + texto.
		if dm.has_signal("gift_reaction") and not dm.gift_reaction.is_connected(_on_gift_reaction):
			dm.gift_reaction.connect(_on_gift_reaction)
		if dm.has_signal("level_up_reaction") and not dm.level_up_reaction.is_connected(_on_level_up_reaction):
			dm.level_up_reaction.connect(_on_level_up_reaction)
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
	# M20 -> M21: badge de expresion (feliz / neutral / feliz_intenso) mostrado
	# arriba de la caja mientras hay una reaccion activa.
	_expresion = Label.new()
	_expresion.name = "Expresion"
	_expresion.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_expresion.offset_top = 4
	_expresion.offset_bottom = 22
	_expresion.offset_left = 170
	_expresion.offset_right = -12
	_expresion.add_theme_font_size_override("font_size", 12)
	_expresion.text = ""
	_panel.add_child(_expresion)
	# M20 -> M21 (M53): retrato a la izquierda; el texto/opciones se corren a la derecha.
	_label.offset_left = 170
	_options_container.offset_left = 170
	_portrait = load("res://scripts/dialogos/ui/npc_portrait_ui.gd").new()
	_portrait.name = "RetratoNPC"
	_portrait.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_portrait.offset_left = 8
	_portrait.offset_top = 8
	_portrait.offset_right = 8 + 150
	_portrait.offset_bottom = 8 + 150
	_panel.add_child(_portrait)

func _on_node_entered(_node_id: String, speaker_key: String, texto: String, tipo: int, options: Array) -> void:
	show()
	_label.text = texto
	if _portrait != null:
		_portrait.set_speaker(speaker_key)
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
	_expresion.text = ""

## M20 -> M21: la UI consume la reaccion al regalo y guarda la expresion para el retrato.
func _on_gift_reaction(npc_id: String, reaccion_id: String, clase: int, item_id: String, expresion: String) -> void:
	_ultima_reaccion = {"id": reaccion_id, "expresion": expresion, "npc_id": npc_id, "item_id": item_id, "clase": clase}
	_expresion.text = expresion if expresion != "" else reaccion_id
	if _portrait != null:
		_portrait.set_expression(expresion)

## M20 -> M21: reaccion al subir de nivel de amistad.
func _on_level_up_reaction(npc_id: String, new_level: int) -> void:
	_ultima_reaccion = {"id": "R_NIVEL", "npc_id": npc_id, "new_level": new_level}
	_expresion.text = "nivel_subio_" + str(new_level)
	if _portrait != null:
		_portrait.set_expression("feliz")

## M20 -> M21: expone la ultima reaccion para el sistema de retrato (M53/M87).
func get_ultima_reaccion() -> Dictionary:
	return _ultima_reaccion

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
			KEY_ESCAPE:
				dm.skip_all()
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