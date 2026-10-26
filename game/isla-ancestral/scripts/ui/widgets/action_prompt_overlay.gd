extends Control
class_name ActionPromptOverlay
## Overlay de prompts dinámicos por dispositivo (M53 - HUD)
##
## Muestra prompts contextuales que cambian según el dispositivo
## de entrada activo (teclado, gamepad genérico, Xbox, PlayStation).
## Se actualiza desde M57 (Interfaz de Control).
## T-053-060: re-lee etiquetas de prompts automáticamente al remapear.

## ── Configuración ───────────────────────────────────────
## M53 L159 (tanda 4, 2026-10-25): literal de la paleta CLARA pre-D102 (1.12:1 sobre
## el panel noche, texto invisible). Token del tema via preload explicito (E-30).
const ThemeUxRef := preload("res://scripts/ui/theme/theme_ux.gd")
const COLOR_TEXT := ThemeUxRef.COLOR_TEXT_DARK
const COLOR_KEY_BG := Color(ThemeUx.COLOR_BG_ARENA, 0.85)  # M53 L159: token, no literal

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
	## M53 L187 (DeepSeek-V4.1-Flash, 2026-10-26): ControlInput (M57) emite
	## "generico" para Nintendo/Switch/Steam Deck y para cualquier pad no
	## reconocido. Antes caia al `_` -> "keyboard" y el jugador veia teclas.
	"gamepad_generic": {
		"interact": "A",
		"attack": "RT",
		"inventory": "X",
		"map": "Minus",
		"pause": "Plus",
	},
}

## Mapeo de acciones de gameplay a acciones de prompt
const ACTION_TO_PROMPT := {
	"interactuar": "interact",
	"inventario": "inventory",
	"pausa": "pause",
}

## Nombres legibles de botones de gamepad.
## Godot 4.7.2 NO expone `Input.get_joy_button_string()` (verificado con
## `Input.get_method_list()`: no existe) -> se mapea a mano el enum JoyButton.
const JOY_BUTTON_NAMES := {
	JOY_BUTTON_A: "A",
	JOY_BUTTON_B: "B",
	JOY_BUTTON_X: "X",
	JOY_BUTTON_Y: "Y",
	JOY_BUTTON_BACK: "View",
	JOY_BUTTON_GUIDE: "Guide",
	JOY_BUTTON_START: "Start",
	JOY_BUTTON_LEFT_STICK: "L3",
	JOY_BUTTON_RIGHT_STICK: "R3",
	JOY_BUTTON_LEFT_SHOULDER: "LB",
	JOY_BUTTON_RIGHT_SHOULDER: "RB",
	JOY_BUTTON_DPAD_UP: "D-Pad Up",
	JOY_BUTTON_DPAD_DOWN: "D-Pad Down",
	JOY_BUTTON_DPAD_LEFT: "D-Pad Left",
	JOY_BUTTON_DPAD_RIGHT: "D-Pad Right",
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
## M53 L187 (DeepSeek-V4.1-Flash, 2026-10-26): el prompt era de TECLADO en la
## practica. El InputMap del proyecto declara UN solo evento por accion y es de
## teclado, asi que `action_get_events(...)[0]` devolvia "E"/"B"/"Escape" aunque
## hubiera gamepad conectado (el DEVICE_MAP por dispositivo era inalcanzable).
## Ahora se elige el evento SEGUN EL DISPOSITIVO; si el InputMap no tiene un
## evento del tipo pedido, se cae al DEVICE_MAP. Y el fallback usa la clave de
## prompt (`interact`), no la accion cruda (`interactuar`): antes devolvia "?"
## porque `DEVICE_MAP["keyboard"]` no tiene la clave "interactuar".
func _get_key_text_for_action(action: String) -> String:
	var prompt_key: String = ACTION_TO_PROMPT.get(action, action)
	var es_gamepad := _current_device.begins_with("gamepad")
	# El InputMap indexa por la ACCION REAL ("interactuar"), no por la clave de
	# prompt ("interact"): consultar la clave daba [] siempre y el DEVICE_MAP
	# quedaba de unico origen (por eso el prompt no seguia el remapeo de M57).
	if InputMap.has_action(action):
		for ev in InputMap.action_get_events(action):
			if es_gamepad and (ev is InputEventJoypadButton or ev is InputEventJoypadMotion):
				return _event_to_display_text(ev)
			if not es_gamepad and (ev is InputEventKey or ev is InputEventMouseButton):
				return _event_to_display_text(ev)
	var device_map: Dictionary = DEVICE_MAP.get(_current_device, DEVICE_MAP.keyboard)
	return String(device_map.get(prompt_key, "?"))


## Convierte un InputEvent a texto legible para el prompt
func _event_to_display_text(evento: InputEvent) -> String:
	if evento is InputEventKey:
		# El InputMap del proyecto declara las teclas por `physical_keycode`
		# (keycode queda en 0): sin este fallback el prompt salia VACIO.
		var code: int = int(evento.keycode)
		if code == 0:
			code = int(evento.physical_keycode)
		return OS.get_keycode_string(code)
	elif evento is InputEventJoypadButton:
		var btn: int = int(evento.button_index)
		return String(JOY_BUTTON_NAMES.get(btn, "Btn %d" % btn))
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
## M53 L187: los modos REALES que emite ControlInput (M57) son "teclado",
## "raton", "xbox", "playstation" y "generico" (ver control_input.gd L22-26).
## "generico" y "raton" caian al `_` -> keyboard.
func _on_device_changed(mode: String) -> void:
	var device: String
	match mode:
		"teclado", "raton": device = "keyboard"
		"xbox": device = "gamepad_xbox"
		"playstation": device = "gamepad_ps"
		"generico": device = "gamepad_generic"
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
			## M53 L187: un pad no identificado es GENERICO, no "xbox".
			_current_device = "gamepad_generic"
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
