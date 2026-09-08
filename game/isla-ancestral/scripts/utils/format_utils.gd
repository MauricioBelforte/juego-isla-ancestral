class_name FormatUtils
extends RefCounted

## Formateo de valores para UI y logs (M111 - Código de Calidad).

static func format_time(total_seconds: float) -> String:
	var s := int(total_seconds) % 60
	var m := (int(total_seconds) / 60) % 60
	var h := int(total_seconds) / 3600
	if h > 0:
		return "%02d:%02d:%02d" % [h, m, s]
	return "%02d:%02d" % [m, s]

static func format_money(amount: int) -> String:
	return "%d monedas" % amount
