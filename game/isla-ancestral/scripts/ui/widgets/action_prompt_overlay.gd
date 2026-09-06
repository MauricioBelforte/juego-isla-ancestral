extends Control
class_name ActionPromptOverlay
## Overlay de prompts dinámicos por dispositivo (M53 - HUD)
##
## Muestra prompts contextuales que cambian según el dispositivo
## de entrada activo (teclado, gamepad genérico, Xbox, PlayStation).
## Se actualiza desde M57 (Interfaz de Control).
## T-053-060: re-lee etiquetas de prompts automáticamente al remapear.

## ── Configuración ───────────────────────────────────────
const COLOR_TEXT := Color(0.25, 0.18, 0.12)
const COLOR_KEY_BG := Color(0.95, 0.90, 0.82, 0.8)

## ── Estado ──────────────────────────────────────────────
var _current_device: String = "keyboard"
var _visible_prompts: Array[Control] = []

## ── Mapeo de teclas por dispositivo ───────────────────
const DEVICE_MAP := {
	"keyboard": {
		"interact": "F",
		"attack": "Click",
		"inventory": "B",
		"map": "M",
		"pause": "ESC",
	},
	"gamepad_xbox": {
		"interact": "A",
		"attack": "RT",
		"inventory": "Y",
		"map": "View",
		"pause": "Start",
	},
	"gamepad_ps": {
		"interact": "X",
		"attack": "R2",
		"inventory": "Triangle",
		"map": "Select",
		"pause": "Options",
	},
}

## Mapeo de acciones de gameplay a acciones de prompt
const ACTION_TO_PROMPT := {
	"interactuar": "interact",
	"inventario": "inventory",
	"pausa": "pause",
}

## ── Ciclo de vida ──────────────────────────────────────

func _ready() -> void:
	anchors_preset = Control.PRESET_FULL_RECT
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_detect_device()
	# T-053-060: conectarse a UIManager.device_changed para actualizar prompts
	var ui_mgr = get_node_or_null("/root/UIManager")
	if ui_mgr and ui_mgr.has_signal("device_changed"):
		ui_mgr.device_changed.connect(_on_device_changed)


## ── API pública ─────────────────────────────────────────

## Muestra un prompt en una posición específica
func show_prompt(action: String, at_position: Vector2) -> void:
	var key_text := _get_key_text_for_action(action)
	var prompt_node := _create_prompt_node(key_text, action)
	prompt_node.position = at_position
	add_child(prompt_node)
	_visible_prompts.append(prompt_node)


## Oculta todos los prompts visibles
func hide_all() -> void:
	for p in _visible_prompts:
		if is_instance_valid(p):
			p.queue_free()
	_visible_prompts.clear()


## Actualiza el dispositivo activo (llamar desde M57)
func set_device(device: String) -> void:
	_current_device = device
	_refresh_all_prompts()


## ── T-053-060: Métodos de actualización automática ─────

## Obtiene el texto de tecla para una acción, considerando remapeos de M57
func _get_key_text_for_action(action: String) -> String:
	# Primero intentar obtener del InputMap (M57 remapea ahí)
	var gameplay_action: String = ACTION_TO_PROMPT.get(action, action)
	var eventos: Array = InputMap.action_get_events(gameplay_action)
	if eventos.size() > 0:
		return _event_to_display_text(eventos[0])
	# Fallback al DEVICE_MAP estático
	var device_map: Dictionary = DEVICE_MAP.get(_current_device, DEVICE_MAP.keyboard)
	return device_map.get(action, "?")


## Convierte un InputEvent a texto legible para el prompt
func _event_to_display_text(evento: InputEvent) -> String:
	if evento is InputEventKey:
		return OS.get_keycode_string(evento.keycode)
	elif evento is InputEventJoypadButton:
		return Input.get_joy_button_string(evento.button_index)
	elif evento is InputEventJoypadMotion:
		var axis_name := ""
		if evento.axis == JOY_AXIS_LEFT_X or evento.axis == JOY_AXIS_RIGHT_X:
			axis_name = "Palanca" if evento.axis == JOY_AXIS_LEFT_X else "Palanca D"
		else:
			axis_name = "Gatillo" if evento.axis == JOY_AXIS_TRIGGER_LEFT or evento.axis == JOY_AXIS_TRIGGER_RIGHT else "Palanca"
		return axis_name
	elif evento is InputEventMouseButton:
		match evento.button_index:
			MOUSE_BUTTON_LEFT: return "Click"
			MOUSE_BUTTON_RIGHT: return "Derecho"
			MOUSE_BUTTON_MIDDLE: return "Medio"
	return "?"


## Refresca todos los prompts visibles con el dispositivo actual
func _refresh_all_prompts() -> void:
	var saved: Array[Dictionary] = []
	for p in _visible_prompts:
		if is_instance_valid(p) and p.has_meta("action"):
			saved.append({"action": p.get_meta("action"), "pos": p.position})
	hide_all()
	for item in saved:
		var key_text := _get_key_text_for_action(item["action"])
		var prompt_node := _create_prompt_node(key_text, item["action"])
		prompt_node.position = item["pos"]
		add_child(prompt_node)
		_visible_prompts.append(prompt_node)


## Callback de cambio de dispositivo desde UIManager
func _on_device_changed(mode: String) -> void:
	var device: String
	match mode:
		"teclado": device = "keyboard"
		"xbox": device = "gamepad_xbox"
		"playstation": device = "gamepad_ps"
		_: device = "keyboard"
	set_device(device)


## ── Métodos privados ────────────────────────────────────

func _detect_device() -> void:
	var joy_pads: Array[int] = Input.get_connected_joypads()
	if joy_pads.size() > 0:
		var joy_name := Input.get_joy_name(0).to_lower()
		if "xbox" in joy_name or "microsoft" in joy_name:
			_current_device = "gamepad_xbox"
		elif "playstation" in joy_name or "ps" in joy_name or "dualshock" in joy_name or "dualsense" in joy_name:
			_current_device = "gamepad_ps"
		else:
			_current_device = "gamepad_xbox"
	else:
		_current_device = "keyboard"


func _create_prompt_node(key_text: String, action: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.set_meta("action", action)

	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_KEY_BG
	style.set_corner_radius_all(6)
	style.set_content_margin_all(6)
	panel.add_theme_stylebox_override("panel", style)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	panel.add_child(hbox)

	var key_label := Label.new()
	key_label.text = "[%s]" % key_text
	key_label.add_theme_font_size_override("font_size", 14)
	key_label.add_theme_color_override("font_color", COLOR_TEXT)
	hbox.add_child(key_label)

	return panel
