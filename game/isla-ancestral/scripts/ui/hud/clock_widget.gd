extends Control
## M53 HUD — ClockWidget: formato cozy "Otoño 3, 14:30".

var _label: Label

func _ready() -> void:
	_label = Label.new()
	add_child(_label)

func set_hora(hour: int, minute: int, season: String, year: int) -> void:
	_label.text = "%s %d, %02d:%02d" % [season, year, hour, minute]
