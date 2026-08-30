extends Control
class_name ClockWidget
## Widget de reloj cozy (M53 - HUD)
##
## Muestra la hora del juego en formato "Otoño 3, 14:30".
## Lee de TimeCalendar autoload (M29) de forma defensiva.
## Se actualiza a 2 Hz desde HUDScreen.

## ── Colores ──────────────────────────────────────────────
const COLOR_TEXT := Color(0.25, 0.18, 0.12)
const COLOR_BG := Color(0.95, 0.90, 0.82, 0.7)

## ── Nodos ──────────────────────────────────────────────
var _time_label: Label
var _period_icon: Label

## ── Estaciones (emojis cozy) ──────────────────────────
const SEASON_ICONS := {
	"primavera": "🌸",
	"verano": "☀",
	"otoño": "🍂",
	"invierno": "❄",
}

## ── Ciclo de vida ──────────────────────────────────────

func _ready() -> void:
	_build_ui()
	refresh()


## ── API pública ─────────────────────────────────────────

## Actualiza el reloj desde TimeCalendar
func refresh() -> void:
	var cal := _get_calendar()
	if not cal:
		_set_display("--:--", "")
		return

	var hora: int = 0
	var minuto: int = 0

	if cal.has_method("get_hora"):
		hora = cal.get_hora()
	if cal.has_method("get_minuto"):
		minuto = cal.get_minuto()

	var hora_str := "%02d:%02d" % [hora, minuto]

	var estacion := ""
	if cal.has_method("get_estacion"):
		var est_idx: int = cal.get_estacion()
		var season_names := ["primavera", "verano", "otoño", "invierno"]
		if est_idx >= 0 and est_idx < season_names.size():
			estacion = season_names[est_idx]

	_set_display(hora_str, estacion)


## ── Métodos privados ────────────────────────────────────

func _build_ui() -> void:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 6)
	add_child(hbox)

	# Icono de período del día
	_period_icon = Label.new()
	_period_icon.name = "PeriodIcon"
	hbox.add_child(_period_icon)

	# Hora
	_time_label = Label.new()
	_time_label.name = "TimeLabel"
	_time_label.add_theme_font_size_override("font_size", 16)
	_time_label.add_theme_color_override("font_color", COLOR_TEXT)
	hbox.add_child(_time_label)


func _set_display(time_text: String, season: String) -> void:
	if _time_label:
		_time_label.text = time_text

	if _period_icon:
		var icon: String = SEASON_ICONS.get(season, "")
		_period_icon.text = icon


func _get_calendar() -> Node:
	return get_node_or_null("/root/TimeCalendar")
