# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M93: Balance — BalanceService (autoload "Balance").
# Acceso central de lectura a data/balance/*.json (RF1-RF17).
# Los valores se cargan UNA vez en _ready(); nunca se guardan en GameState (M59).
# Consumidores: M38 (economía), M20 (amistad), M16 (crafting), M17 (construcción),
# M33/M34/M35, M22/M23, M153 (sellos), M71 (desbloqueos).
# ⚠️ Sin class_name: es autoload (pitfall 07-GUIA-GODOT §9.17/§9.41).

extends Node

const RUTA_BASE := "res://data/balance/"

var _prices: Dictionary = {}
var _rewards: Dictionary = {}
var _timing: Dictionary = {}
var _progression: Dictionary = {}
var _friendship: Dictionary = {}
var _meta: Dictionary = {}

func _ready() -> void:
	_cargar_todo()

func _cargar_todo() -> void:
	_prices = _cargar_json("prices.json")
	_rewards = _cargar_json("rewards.json")
	_timing = _cargar_json("timing.json")
	_progression = _cargar_json("progression.json")
	_friendship = _cargar_json("friendship.json")
	_meta = _cargar_json("meta.json")

func _cargar_json(nombre: String) -> Dictionary:
	var f := FileAccess.open(RUTA_BASE + nombre, FileAccess.READ)
	if f == null:
		push_warning("[M93] No se pudo abrir balance: " + nombre)
		return {}
	var parsed = JSON.parse_string(f.get_as_text())
	if not (parsed is Dictionary):
		push_warning("[M93] JSON invalido: " + nombre)
		return {}
	return parsed

## ── RF1: Precios ─────────────────────────────────────────

func get_price(item_id: String) -> int:
	var item = _prices.get("items", {}).get(item_id, null)
	if item == null:
		return 0
	return int(item.get("compra", 0))

func get_sell_price(item_id: String) -> int:
	var item = _prices.get("items", {}).get(item_id, null)
	if item == null:
		return 0
	return int(item.get("venta", 0))

func es_item_historia(item_id: String) -> bool:
	var item = _prices.get("items", {}).get(item_id, null)
	if item == null:
		return false
	return bool(item.get("historia", false))

## ── RF2: Recompensas ─────────────────────────────────────

func get_reward(activity_id: String) -> Dictionary:
	return _rewards.get("rewards", {}).get(activity_id, {})

## ── RF16: Timing ─────────────────────────────────────────

func get_timing() -> Dictionary:
	return _timing.get("timing", {})

func sesion_rutina_total_min() -> int:
	return int(_timing.get("timing", {}).get("sesion_rutina_total_min", 30))

## ── RF17: Progresión ─────────────────────────────────────

func get_progression() -> Dictionary:
	return _progression.get("curvas", {})

## ── RF12: Amistad ────────────────────────────────────────

func get_friendship() -> Dictionary:
	return _friendship

func get_friendship_thresholds() -> Dictionary:
	return _friendship.get("umbrales", {})

func get_friendship_points() -> Dictionary:
	return _friendship.get("puntos", {})

## ── Meta / versión ───────────────────────────────────────

func get_balance_version() -> String:
	return str(_meta.get("balance_version", ""))

## Devuelve la tabla meta (evita colisionar con Node.get_meta builtin).
func obtener_meta() -> Dictionary:
	return _meta

## ── API genérica para M38/M16/M33 ────────────────────────

## Expone una tabla completa por nombre (prices, rewards, timing, ...).
func get_tabla(nombre: String) -> Dictionary:
	match nombre:
		"prices":
			return _prices
		"rewards":
			return _rewards
		"timing":
			return _timing
		"progression":
			return _progression
		"friendship":
			return _friendship
		"meta":
			return _meta
	return {}