extends Control
class_name SeasonWidget
## Widget de estación (M53 - HUD)
##
## Muestra la estación actual con icono y texto.
## Lee de TimeCalendar autoload (M29) de forma defensiva.

## ── Colores ──────────────────────────────────────────────
const COLOR_TEXT := Color(0.25, 0.18, 0.12)
const COLOR_BG := Color(0.95, 0.90, 0.82, 0.7)

## ── Nodos ──────────────────────────────────────────────
var _icon_label: Label
var _name_label: Label

## ── Estaciones ─────────────────────────────────────────
const SEASON_DATA := {
	0: {"name": "Primavera", "icon": "🌸"},
	1: {"name": "Verano", "icon": "☀"},
	2: {"name": "Otoño", "icon": "🍂"},
	3: {"name": "Invierno", "icon": "❄"},
}

## ── Ciclo de vida ──────────────────────────────────────

func _ready() -> void:
	_build_ui()
	refresh()


## ── API pública ─────────────────────────────────────────

func refresh() -> void:
	var cal := _get_calendar()
	if not cal:
		_set_display("?", "")
		return

	var estacion := 0
	if cal.has_method("get_estacion"):
		estacion = cal.get_estacion()

	var data: Dictionary = SEASON_DATA.get(estacion, {"name": "??", "icon": "?"})
	_set_display(data.icon, data.name)


## ── Métodos privados ────────────────────────────────────

func _build_ui() -> void:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	add_child(hbox)

	_icon_label = Label.new()
	_icon_label.name = "IconLabel"
	_icon_label.add_theme_font_size_override("font_size", 18)
	hbox.add_child(_icon_label)

	_name_label = Label.new()
	_name_label.name = "NameLabel"
	_name_label.add_theme_font_size_override("font_size", 14)
	_name_label.add_theme_color_override("font_color", COLOR_TEXT)
	hbox.add_child(_name_label)


func _set_display(icon: String, display_name: String) -> void:
	if _icon_label:
		_icon_label.text = icon
	if _name_label:
		_name_label.text = display_name


func _get_calendar() -> Node:
	return get_node_or_null("/root/TimeCalendar")
