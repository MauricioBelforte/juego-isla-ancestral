extends Control
class_name InteractPrompt
## Indicador contextual de interacción (M53 - HUD)
##
## Muestra "[F] Hablar" o "[E] Recolectar" cuando el jugador
## está cerca de un objeto interactuable. Se activa/desactiva
## desde el gameplay (player.gd o VillagerManager).

## ── Configuración ───────────────────────────────────────
const COLOR_TEXT := Color(0.25, 0.18, 0.12)
const COLOR_BG := Color(0.95, 0.90, 0.82, 0.85)
const COLOR_KEY := Color(0.72, 0.55, 0.30)

## ── Nodos ──────────────────────────────────────────────
var _panel: PanelContainer
var _label: Label
var _visible: bool = false

## ── Ciclo de vida ──────────────────────────────────────

func _ready() -> void:
	_build_ui()
	visible = false


## ── API pública ─────────────────────────────────────────

## Muestra el prompt con un mensaje (ej: "[F] Hablar")
func show_prompt(message: String) -> void:
	if _label:
		_label.text = message
	visible = true
	_visible = true

	# Fade in suave
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.15)


## Oculta el prompt
func hide_prompt() -> void:
	if not _visible:
		return

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.1)
	tween.tween_callback(func() -> void:
		visible = false
		_visible = false
	)


## ── Métodos privados ────────────────────────────────────

func _build_ui() -> void:
	# Centrar abajo en la pantalla
	anchors_preset = Control.PRESET_CENTER_BOTTOM
	offset_bottom = -80

	_panel = PanelContainer.new()
	_panel.name = "PromptPanel"
	add_child(_panel)

	# Estilo del panel
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_BG
	style.border_color = COLOR_KEY
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.set_content_margin_all(10)
	_panel.add_theme_stylebox_override("panel", style)

	# Layout horizontal
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 6)
	_panel.add_child(hbox)

	# Tecla
	var key_label := Label.new()
	key_label.name = "KeyLabel"
	key_label.text = "[F]"
	key_label.add_theme_font_size_override("font_size", 16)
	key_label.add_theme_color_override("font_color", COLOR_KEY)
	hbox.add_child(key_label)

	# Texto descriptivo
	_label = Label.new()
	_label.name = "ActionLabel"
	_label.text = "Interactuar"
	_label.add_theme_font_size_override("font_size", 14)
	_label.add_theme_color_override("font_color", COLOR_TEXT)
	hbox.add_child(_label)
