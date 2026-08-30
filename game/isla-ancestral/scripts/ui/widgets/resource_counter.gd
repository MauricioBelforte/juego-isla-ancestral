extends Control
class_name ResourceCounter
## Contador de recursos principales (M53 - HUD)
##
## Muestra monedas y recursos clave del inventario.
## Lee de EconomyManager (M38) y EventBus signals.
## Se actualiza a 2 Hz desde HUDScreen.

## ── Colores ──────────────────────────────────────────────
const COLOR_TEXT := Color(0.25, 0.18, 0.12)
const COLOR_COIN := Color(0.72, 0.55, 0.30)

## ── Nodos ──────────────────────────────────────────────
var _coin_label: Label
var _coin_value: Label

## ── Ciclo de vida ──────────────────────────────────────

func _ready() -> void:
	_build_ui()
	refresh()


## ── API pública ─────────────────────────────────────────

func refresh() -> void:
	var eco := _get_economy()
	if not eco:
		_set_coins(0)
		return

	var saldo: int = 0
	if eco.get("saldo") != null:
		saldo = int(eco.saldo)

	_set_coins(saldo)


## ── Métodos privados ────────────────────────────────────

func _build_ui() -> void:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	add_child(hbox)

	# Icono moneda
	_coin_label = Label.new()
	_coin_label.name = "CoinIcon"
	_coin_label.text = "🪙"
	_coin_label.add_theme_font_size_override("font_size", 16)
	hbox.add_child(_coin_label)

	# Valor monedas
	_coin_value = Label.new()
	_coin_value.name = "CoinValue"
	_coin_value.add_theme_font_size_override("font_size", 14)
	_coin_value.add_theme_color_override("font_color", COLOR_COIN)
	hbox.add_child(_coin_value)


func _set_coins(amount: int) -> void:
	if _coin_value:
		_coin_value.text = str(amount)


func _get_economy() -> Node:
	return get_node_or_null("/root/EconomyManager")
