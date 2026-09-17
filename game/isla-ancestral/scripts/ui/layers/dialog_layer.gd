# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M53: DialogLayer — presentación formal del diálogo M21.
# Capa MODAL_FULL registrada en UIManager. Escucha las señales del DialogueManager
# (M21 autoload) y dibuja ventana, texto, opciones y retroceso, con tema cozy (ThemeUx)
# y claves localizadas (M87). Es la presentación; la lógica de historia vive en M21.
#
# Requisitos: el CanvasLayer autocontenido dialogue_ui.gd (M21) queda como fallback/simple;
# esta capa es la integración con el framework M53 (pila de capas, foco, tema, i18n).

class_name DialogLayer
extends UILayer

var _panel: PanelContainer
var _speaker_label: Label
var _text_label: Label
var _options_box: VBoxContainer
var _hint_label: Label
var _clickable: bool = false

## M53 D: Velocidad de texto ajustable (M58)
var _text_speed: float = 0.03  ## segundos por carácter (0 = instantáneo)
var _typing: bool = false
var _full_text: String = ""
var _char_index: int = 0
var _typing_timer: Timer

func _ready() -> void:
	layer_type = UILayerType.Type.MODAL_FULL
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_crear_ui()
	_crear_typing_timer()
	visible = false
	# M53 D: suscribir a DialogueManager (M21) — dialog_requested y dialog_finished
	var dm = get_node_or_null("/root/DialogueManager")
	if dm:
		if not dm.node_entered.is_connected(_on_node_entered):
			dm.node_entered.connect(_on_node_entered)
		if not dm.dialogue_ended.is_connected(_on_dialogue_ended):
			dm.dialogue_ended.connect(_on_dialogue_ended)
		if not dm.option_selected.is_connected(_on_option_selected):
			dm.option_selected.connect(_on_option_selected)
	# M53 D: suscribir a EventBus para dialog_requested / dialog_finished
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		var ui_events: Variant = bus.get("ui") if bus.has_method("get") else null
		if ui_events != null:
			if ui_events.has_signal("dialog_requested") and not ui_events.dialog_requested.is_connected(_on_event_dialog_requested):
				ui_events.dialog_requested.connect(_on_event_dialog_requested)
			if ui_events.has_signal("dialog_finished") and not ui_events.dialog_finished.is_connected(_on_event_dialog_finished):
				ui_events.dialog_finished.connect(_on_event_dialog_finished)
	# M53 D: velocidad de texto desde GameSettings (M58)
	_aplicar_velocidad_texto()

## ── Construcción de la UI ────────────────────────────────

func _crear_ui() -> void:
	_crear_fondo_dim()
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 48)
	margin.add_theme_constant_override("margin_right", 48)
	margin.add_theme_constant_override("margin_top", 40)
	margin.add_theme_constant_override("margin_bottom", 40)
	add_child(margin)

	_panel = PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.96, 0.92, 0.86, 0.96)
	sb.border_color = Color(0.72, 0.55, 0.30)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(16)
	sb.set_content_margin_all(20)
	_panel.add_theme_stylebox_override("panel", sb)
	margin.add_child(_panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	_panel.add_child(vbox)

	_speaker_label = Label.new()
	_speaker_label.name = "Hablante"
	_speaker_label.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_H3)
	_speaker_label.add_theme_color_override("font_color", Color(0.72, 0.55, 0.30))
	vbox.add_child(_speaker_label)

	var sep := HSeparator.new()
	vbox.add_child(sep)

	_text_label = Label.new()
	_text_label.name = "Texto"
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text_label.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_BODY)
	vbox.add_child(_text_label)

	_options_box = VBoxContainer.new()
	_options_box.name = "Opciones"
	_options_box.add_theme_constant_override("separation", 6)
	vbox.add_child(_options_box)

	_hint_label = Label.new()
	_hint_label.name = "Hint"
	_hint_label.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_SMALL)
	_hint_label.add_theme_color_override("font_color", Color(0.55, 0.5, 0.45))
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vbox.add_child(_hint_label)

func _crear_fondo_dim() -> void:
	# Fondo oscurecido sutil (el mundo queda visible pero atenuado)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.35)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dim.name = "FondoDim"
	add_child(dim)
	dim.move_to_front()

## ── Callbacks del DialogueManager (M21) ──────────────────

func _on_node_entered(_node_id: String, speaker_key: String, texto: String, tipo: int, options: Array) -> void:
	if not visible:
		visible = true
	_text_label.text = texto
	_speaker_label.text = _traducir_hablante(speaker_key)
	_limpiar_opciones()
	if tipo == DialogueNode.TIPO_OPCIONES and options.size() > 0:
		for i in options.size():
			var op = options[i]
			var btn := Button.new()
			btn.text = "[%d] %s" % [i + 1, _texto_opcion(op)]
			btn.pressed.connect(_on_opt_pressed.bind(i))
			_options_box.add_child(btn)
		_hint_label.text = _t("SETTINGS.ELEGIR_OPCION")
	else:
		_hint_label.text = _t("SETTINGS.ADVANCED")
	_clickable = tipo != DialogueNode.TIPO_FIN

func _on_dialogue_ended(_id: String, _ultimo: String) -> void:
	visible = false
	_limpiar_opciones()

func _on_option_selected(_idx: int) -> void:
	# Opción elegida por teclado en M21: refrescar la capa
	pass

## ── Input local (avanzar / elegir por teclado y gamepad) ──

func _input(event: InputEvent) -> void:
	if not visible:
		return
	var dm = get_node_or_null("/root/DialogueManager")
	if dm == null:
		return
	# M53 D: si está escribiendo, completar el texto con el primer toque
	if _typing and (event.is_action_pressed("interactuar") or event.is_action_pressed("ui_accept")):
		_completar_texto()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("interactuar"):
		_avanzar(dm)
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ENTER, KEY_SPACE:
				if _typing:
					_completar_texto()
				else:
					_avanzar(dm)
				get_viewport().set_input_as_handled()
			KEY_1, KEY_2, KEY_3, KEY_4:
				var idx: int = event.keycode - KEY_1
				_elegir(dm, idx)
				get_viewport().set_input_as_handled()

func _avanzar(dm: Node) -> void:
	if _options_box.get_child_count() > 0:
		return  # no avanzar si hay opciones
	dm.advance()

func _elegir(dm: Node, idx: int) -> void:
	if idx >= 0 and idx < _options_box.get_child_count():
		dm.choose_option(idx)

func _on_opt_pressed(idx: int) -> void:
	var dm = get_node_or_null("/root/DialogueManager")
	if dm:
		dm.choose_option(idx)

## ── Utilidades ───────────────────────────────────────────

func _texto_opcion(op) -> String:
	if op == null:
		return "?"
	# ⚠️ Object.has() NO existe en Godot 4 — usar el operador `in` (§9.48 de la guía)
	if "text_key" in op:
		var clave: String = str(op.text_key)
		return _traducir_texto(clave)
	return str(op)

func _traducir_hablante(speaker_key: String) -> String:
	if speaker_key == "":
		return ""
	return _traducir_texto(speaker_key)

## Traduce SOLO si el texto parece una clave (M87: MAYÚSCULAS/con puntos/guiones bajos,
## sin espacios ni minúsculas de frase). Textos libres se devuelven tal cual.
func _traducir_texto(texto: String) -> String:
	if texto == "" or texto.contains(" "):
		return texto
	if texto != texto.to_upper() and not texto.contains("."):
		return texto
	var loc = get_node_or_null("/root/Localization")
	if loc and loc.has_method("traducir_clave"):
		var res = loc.traducir_clave(texto)
		return res
	return texto

func _t(clave: String) -> String:
	var loc = get_node_or_null("/root/Localization")
	if loc and loc.has_method("traducir_clave"):
		var res = loc.traducir_clave(clave)
		if res != clave:
			return res
	return clave

func _limpiar_opciones() -> void:
	for child in _options_box.get_children():
		child.queue_free()

## ── UILayer virtual ──────────────────────────────────────

func on_layer_opened() -> void:
	# M53 D: pausar GameClock (M29) al abrir diálogo
	_pausar_reloj(true)

func on_layer_closed() -> void:
	visible = false
	# M53 D: restaurar GameClock al cerrar diálogo
	_pausar_reloj(false)
	_detener_typing()

## ── M53 D: Suscripciones EventBus ───────────────────────

func _on_event_dialog_requested(_npc_id: String, _data: Dictionary) -> void:
	if not visible:
		visible = true

func _on_event_dialog_finished(_id: String) -> void:
	if visible:
		visible = false
		_limpiar_opciones()
		_pausar_reloj(false)
		_detener_typing()
		# Restaurar foco a la capa anterior
		var ui_mgr = get_node_or_null("/root/UIManager")
		if ui_mgr and ui_mgr.has_method("request_focus_restore"):
			ui_mgr.request_focus_restore()

## ── M53 D: Velocidad de texto (typing effect) ───────────

func _crear_typing_timer() -> void:
	_typing_timer = Timer.new()
	_typing_timer.one_shot = true
	_typing_timer.timeout.connect(_on_typing_tick)
	add_child(_typing_timer)

func _on_node_entered(_node_id: String, speaker_key: String, texto: String, tipo: int, options: Array) -> void:
	if not visible:
		visible = true
	# M53 D: pausar reloj al primer nodo
	_pausar_reloj(true)
	_speaker_label.text = _traducir_hablante(speaker_key)
	_limpiar_opciones()
	if tipo == DialogueNode.TIPO_OPCIONES and options.size() > 0:
		for i in options.size():
			var op = options[i]
			var btn := Button.new()
			btn.text = "[%d] %s" % [i + 1, _texto_opcion(op)]
			btn.pressed.connect(_on_opt_pressed.bind(i))
			_options_box.add_child(btn)
		_hint_label.text = _t("SETTINGS.ELEGIR_OPCION")
	else:
		_hint_label.text = _t("SETTINGS.ADVANCED")
	_clickable = tipo != DialogueNode.TIPO_FIN
	# M53 D: iniciar typing effect
	_iniciar_typing(texto)

func _iniciar_typing(texto: String) -> void:
	_detener_typing()
	if _text_speed <= 0.0 or texto == "":
		_text_label.text = texto
		return
	_full_text = texto
	_char_index = 0
	_text_label.text = ""
	_typing = true
	_typing_timer.wait_time = _text_speed
	_typing_timer.start()

func _on_typing_tick() -> void:
	if not _typing or _char_index >= _full_text.length():
		_detener_typing()
		return
	_char_index += 1
	_text_label.text = _full_text.substr(0, _char_index)
	_typing_timer.start()

func _detener_typing() -> void:
	_typing = false
	if _typing_timer and _typing_timer.time_left > 0:
		_typing_timer.stop()

func _completar_texto() -> void:
	_detener_typing()
	_text_label.text = _full_text

## ── M53 D: Pausa de GameClock (M29) ────────────────────

func _pausar_reloj(pausar: bool) -> void:
	var gt = get_node_or_null("/root/GameTime")
	if gt and gt.has_method("set_paused"):
		gt.set_paused(pausar)

## ── M53 D: Velocidad de texto configurable (M58) ────────

func _aplicar_velocidad_texto() -> void:
	var gs = get_node_or_null("/root/GameSettings")
	if gs:
		var speed_val = gs.get("dialog_text_speed") if gs.has_method("get") else null
		if speed_val != null:
			_text_speed = float(speed_val)
		elif gs.has_method("get_setting"):
			_text_speed = float(gs.get_setting("dialog_text_speed", 0.03))

func set_text_speed(speed: float) -> void:
	_text_speed = speed

func get_text_speed() -> float:
	return _text_speed
