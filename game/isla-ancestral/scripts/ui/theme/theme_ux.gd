class_name ThemeUx
## Constructor de tema cozy para Isla Ancestral
##
## Construye un Theme de Godot en runtime con la paleta pastel:
## fondo arena, acento ocre, texto marrón oscuro, highlight dorado suave.
## Fuentes: Nunito (cuerpo) y Fredoka One (títulos) de M88.

## ── Constantes de diseño ─────────────────────────────────
## Resolución base para cálculos de escala
const BASE_SIZE := Vector2i(1920, 1080)

## Paleta pastel
const COLOR_BG_ARENA := Color(0.95, 0.90, 0.82)       # Fondo arena
const COLOR_ACCENT_OCRE := Color(0.72, 0.55, 0.30)    # Acento ocre
const COLOR_TEXT_DARK := Color(0.25, 0.18, 0.12)       # Texto marrón oscuro
const COLOR_HIGHLIGHT_GOLD := Color(0.85, 0.72, 0.35)  # Highlight dorado suave
const COLOR_HOVER := Color(0.88, 0.82, 0.70)           # Hover suave
const COLOR_PRESSED := Color(0.78, 0.72, 0.60)         # Presionado
const COLOR_DISABLED := Color(0.65, 0.60, 0.55)        # Deshabilitado
const COLOR_FOCUS_RING := Color(0.85, 0.72, 0.35, 0.8) # Anillo de foco

## Jerarquía tipográfica
const FONT_SIZE_H1 := 32
const FONT_SIZE_H2 := 24
const FONT_SIZE_H3 := 20
const FONT_SIZE_BODY := 16
const FONT_SIZE_SMALL := 12
const FONT_SIZE_MICRO := 10

## ── Tema construido ─────────────────────────────────────
var base: Theme = null

## ── API pública ─────────────────────────────────────────

## Construye el tema desde cero
func build() -> Theme:
	base = Theme.new()

	# Colores base
	_set_default_colors()

	# Estilos de panel
	_setup_panel_styles()

	# Estilos de botón
	_setup_button_styles()

	# Estilos de Label
	_setup_label_styles()

	# Estilos de LineEdit
	_setup_line_edit_styles()

	# Estilos de OptionButton
	_setup_option_button_styles()

	# Estilos de ProgressBar
	_setup_progress_bar_styles()

	# Estilos de ScrollContainer
	_setup_scroll_container_styles()

	# Estilos de TabContainer
	_setup_tab_container_styles()

	# Focus
	_setup_focus_styles()

	return base


## Aplica el tema con un ratio de escala
func apply(scale_ratio: float) -> void:
	if not base:
		build()

	# Aplicar escala de fuente
	var scaled_h1 := int(FONT_SIZE_H1 * scale_ratio)
	var scaled_h2 := int(FONT_SIZE_H2 * scale_ratio)
	var scaled_h3 := int(FONT_SIZE_H3 * scale_ratio)
	var scaled_body := int(FONT_SIZE_BODY * scale_ratio)
	var scaled_small := int(FONT_SIZE_SMALL * scale_ratio)
	var scaled_micro := int(FONT_SIZE_MICRO * scale_ratio)

	base.set_font_size("font_size", "H1", scaled_h1)
	base.set_font_size("font_size", "H2", scaled_h2)
	base.set_font_size("font_size", "H3", scaled_h3)
	base.set_font_size("font_size", "Body", scaled_body)
	base.set_font_size("font_size", "Small", scaled_small)
	base.set_font_size("font_size", "Micro", scaled_micro)


## Recarga fuentes después de cambio de idioma (M87/M88)
func reload_after_font_change() -> void:
	# TODO: recargar fuentes desde M88 cuando esté disponible
	pass


## Ajusta contraste para accesibilidad (M58)
func ensure_contrast(_min_ratio: float) -> void:
	# TODO: implementar cuando M58 esté disponible
	pass


## Indica si reduce_motion está activo (M58)
func reduce_motion_active() -> bool:
	# TODO: leer de M58 cuando esté disponible
	return false


## ── Métodos privados: setup de estilos ──────────────────

func _set_default_colors() -> void:
	base.set_color("font_color", "Label", COLOR_TEXT_DARK)
	base.set_color("font_color", "Button", COLOR_TEXT_DARK)
	base.set_color("font_color", "LineEdit", COLOR_TEXT_DARK)
	base.set_color("font_placeholder_color", "LineEdit", COLOR_DISABLED)


func _setup_panel_styles() -> void:
	# Panel redondeado base
	var panel_rounded := StyleBoxFlat.new()
	panel_rounded.bg_color = COLOR_BG_ARENA
	panel_rounded.border_color = COLOR_ACCENT_OCRE
	panel_rounded.set_border_width_all(2)
	panel_rounded.set_corner_radius_all(12)
	panel_rounded.set_content_margin_all(12)
	base.set_stylebox("panel", "PanelContainer", panel_rounded)


func _setup_button_styles() -> void:
	# Botón cozy normal
	var btn_normal := StyleBoxFlat.new()
	btn_normal.bg_color = COLOR_BG_ARENA
	btn_normal.border_color = COLOR_ACCENT_OCRE
	btn_normal.set_border_width_all(1)
	btn_normal.set_corner_radius_all(8)
	btn_normal.set_content_margin_all(8)
	base.set_stylebox("normal", "Button", btn_normal)

	# Hover
	var btn_hover := StyleBoxFlat.new()
	btn_hover.bg_color = COLOR_HOVER
	btn_hover.border_color = COLOR_ACCENT_OCRE
	btn_hover.set_border_width_all(2)
	btn_hover.set_corner_radius_all(8)
	btn_hover.set_content_margin_all(8)
	base.set_stylebox("hover", "Button", btn_hover)

	# Presionado
	var btn_pressed := StyleBoxFlat.new()
	btn_pressed.bg_color = COLOR_PRESSED
	btn_pressed.border_color = COLOR_ACCENT_OCRE
	btn_pressed.set_border_width_all(2)
	btn_pressed.set_corner_radius_all(8)
	btn_pressed.set_content_margin_all(8)
	base.set_stylebox("pressed", "Button", btn_pressed)

	# Deshabilitado
	var btn_disabled := StyleBoxFlat.new()
	btn_disabled.bg_color = COLOR_DISABLED
	btn_disabled.border_color = COLOR_DISABLED
	btn_disabled.set_border_width_all(1)
	btn_disabled.set_corner_radius_all(8)
	btn_disabled.set_content_margin_all(8)
	base.set_stylebox("disabled", "Button", btn_disabled)


func _setup_label_styles() -> void:
	# H1
	base.set_font_size("font_size", "H1", FONT_SIZE_H1)
	base.set_color("font_color", "H1", COLOR_TEXT_DARK)

	# H2
	base.set_font_size("font_size", "H2", FONT_SIZE_H2)
	base.set_color("font_color", "H2", COLOR_TEXT_DARK)

	# H3
	base.set_font_size("font_size", "H3", FONT_SIZE_H3)
	base.set_color("font_color", "H3", COLOR_TEXT_DARK)

	# Body
	base.set_font_size("font_size", "Body", FONT_SIZE_BODY)
	base.set_color("font_color", "Body", COLOR_TEXT_DARK)

	# Small
	base.set_font_size("font_size", "Small", FONT_SIZE_SMALL)
	base.set_color("font_color", "Small", COLOR_TEXT_DARK)


func _setup_line_edit_styles() -> void:
	var le_normal := StyleBoxFlat.new()
	le_normal.bg_color = COLOR_BG_ARENA
	le_normal.border_color = COLOR_ACCENT_OCRE
	le_normal.set_border_width_all(1)
	le_normal.set_corner_radius_all(6)
	le_normal.set_content_margin_all(6)
	base.set_stylebox("normal", "LineEdit", le_normal)

	var le_focus := StyleBoxFlat.new()
	le_focus.bg_color = COLOR_BG_ARENA
	le_focus.border_color = COLOR_HIGHLIGHT_GOLD
	le_focus.set_border_width_all(2)
	le_focus.set_corner_radius_all(6)
	le_focus.set_content_margin_all(6)
	base.set_stylebox("focus", "LineEdit", le_focus)


func _setup_option_button_styles() -> void:
	var ob_normal := StyleBoxFlat.new()
	ob_normal.bg_color = COLOR_BG_ARENA
	ob_normal.border_color = COLOR_ACCENT_OCRE
	ob_normal.set_border_width_all(1)
	ob_normal.set_corner_radius_all(6)
	ob_normal.set_content_margin_all(6)
	base.set_stylebox("normal", "OptionButton", ob_normal)

	var ob_hover := StyleBoxFlat.new()
	ob_hover.bg_color = COLOR_HOVER
	ob_hover.border_color = COLOR_ACCENT_OCRE
	ob_hover.set_border_width_all(2)
	ob_hover.set_corner_radius_all(6)
	ob_hover.set_content_margin_all(6)
	base.set_stylebox("hover", "OptionButton", ob_hover)


func _setup_progress_bar_styles() -> void:
	var bg := StyleBoxFlat.new()
	bg.bg_color = COLOR_DISABLED
	bg.set_corner_radius_all(4)
	base.set_stylebox("background", "ProgressBar", bg)

	var fill := StyleBoxFlat.new()
	fill.bg_color = COLOR_ACCENT_OCRE
	fill.set_corner_radius_all(4)
	base.set_stylebox("fill", "ProgressBar", fill)


func _setup_scroll_container_styles() -> void:
	var grabber := StyleBoxFlat.new()
	grabber.bg_color = COLOR_ACCENT_OCRE
	grabber.set_corner_radius_all(4)
	base.set_stylebox("grabber", "VScrollBar", grabber)

	var grabber_h := StyleBoxFlat.new()
	grabber_h.bg_color = COLOR_ACCENT_OCRE
	grabber_h.set_corner_radius_all(4)
	base.set_stylebox("grabber", "HScrollBar", grabber_h)


func _setup_tab_container_styles() -> void:
	var tab_selected := StyleBoxFlat.new()
	tab_selected.bg_color = COLOR_BG_ARENA
	tab_selected.border_color = COLOR_HIGHLIGHT_GOLD
	tab_selected.set_border_width_all(2)
	tab_selected.set_corner_radius_all(8)
	tab_selected.set_content_margin_all(8)
	base.set_stylebox("panel_selected", "TabContainer", tab_selected)


func _setup_focus_styles() -> void:
	# Anillo de foco dorado (visible con teclado/gamepad)
	var focus_style := StyleBoxFlat.new()
	focus_style.bg_color = Color.TRANSPARENT
	focus_style.border_color = COLOR_FOCUS_RING
	focus_style.set_border_width_all(3)
	focus_style.set_corner_radius_all(12)
	focus_style.set_content_margin_all(4)

	base.set_stylebox("focus", "Button", focus_style)
	base.set_stylebox("focus", "LineEdit", focus_style)
	base.set_stylebox("focus", "OptionButton", focus_style)
