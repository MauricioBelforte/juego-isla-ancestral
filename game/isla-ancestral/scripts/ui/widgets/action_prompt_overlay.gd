extends Control
class_name ActionPromptOverlay
## Overlay de prompts dinámicos por dispositivo (M53 - HUD)
##
## Muestra prompts contextuales que cambian según el dispositivo
## de entrada activo (teclado, gamepad genérico, Xbox, PlayStation).
## Se actualiza desde M57 (Interfaz de Control).

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

## ── Ciclo de vida ──────────────────────────────────────

func _ready() -> void:
	anchors_preset = Control.PRESET_FULL_RECT
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_detect_device()


## ── API pública ─────────────────────────────────────────

## Muestra un prompt en una posición específica
func show_prompt(action: String, at_position: Vector2) -> void:
	var device_map: Dictionary = DEVICE_MAP.get(_current_device, DEVICE_MAP.keyboard)
	var key_text: String = device_map.get(action, "?")

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
	# Re-crear todos los prompts con el nuevo dispositivo
	var saved_actions: Array[String] = []
	for p in _visible_prompts:
		if is_instance_valid(p) and p.has_meta("action"):
			saved_actions.append(p.get_meta("action"))
	hide_all()
	for action in saved_actions:
		show_prompt(action, Vector2.ZERO)


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
