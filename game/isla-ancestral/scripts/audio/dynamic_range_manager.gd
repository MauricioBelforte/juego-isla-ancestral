# Modelo: mimo-v2.6-flash-free
# Plataforma: opencode
# Fecha: 2026-10-02
#
# M91 — Rango dinámico: perfiles quiet / medio / dinámico sobre un bus.
#
# quiet    -> compresión alta (threshold bajo, ratio alto): reduce picos
# medio    -> compresión media
# dinamico -> SIN compresión: se remueve el efecto del bus
#
# STATELESS a propósito: el estado se DERIVA de AudioServer consultando el
# AudioEffectCompressor presente en el bus. Así no hay dos fuentes de verdad
# que puedan desincronizarse (§9 modularidad / §21.4 optimización).
# Sin instancias, sin nodos, sin coste por frame.
#
# API real Godot 4.7.2 — SONDEADA por reflexión, no adivinada (T-107):
#   AudioEffectCompressor -> threshold, ratio, gain, attack_us, release_ms,
#                            mix, sidechain
#   AudioServer           -> add_bus_effect / remove_bus_effect /
#                            get_bus_effect_count / get_bus_effect
#   ⚠ NO existen `release_us` ni `output_gain` (los cita el 04-Codigo §9 por
#     error; ver GUIA-GODOT/06 T-107).
class_name DynamicRangeManager
extends RefCounted

const BUS_DEFECTO := "Master"

## Rangos soportados, en orden (el dropdown de M53 usa este orden)
const RANGOS: Array[String] = ["quiet", "medio", "dinamico"]

## Presets verificados contra la API real:
##   threshold -> dB (float) · ratio -> float
##   attack_us -> int (microsegundos) · release_ms -> float (milisegundos)
const PRESETS: Dictionary = {
	"quiet": {"threshold": -20.0, "ratio": 10.0, "attack_us": 5000, "release_ms": 250.0},
	"medio": {"threshold": -10.0, "ratio": 5.0, "attack_us": 5000, "release_ms": 250.0},
	"dinamico": {},
}


## Aplica un rango al bus. Devuelve false si el rango o el bus no existen.
static func aplicar(rango: String, bus: String = BUS_DEFECTO) -> bool:
	if not PRESETS.has(rango):
		return false
	var bidx := AudioServer.get_bus_index(bus)
	if bidx == -1:
		return false
	var preset: Dictionary = PRESETS[rango]
	if preset.is_empty():
		remover(bus)
		return true
	var comp := _asegurar_compressor(bus)
	if comp == null:
		return false
	comp.threshold = float(preset["threshold"])
	comp.ratio = float(preset["ratio"])
	comp.attack_us = int(preset["attack_us"])
	comp.release_ms = float(preset["release_ms"])
	return true


## Rango activo: "quiet" / "medio" / "dinamico" / "custom" (efecto no
## coincide con ningún preset).
static func actual(bus: String = BUS_DEFECTO) -> String:
	var comp := _compressor_de(bus)
	if comp == null:
		return "dinamico"
	for r in RANGOS:
		var p: Dictionary = PRESETS[r]
		if p.is_empty():
			continue
		if absf(comp.threshold - float(p["threshold"])) < 0.01 \
				and absf(comp.ratio - float(p["ratio"])) < 0.01:
			return r
	return "custom"


## Compresión manual (threshold/ratio/attack/release libres).
## El checklist exige estos cuatro parámetros como knobs independientes.
static func aplicar_compresion_manual(threshold: float, ratio: float, \
		attack_us: int, release_ms: float, bus: String = BUS_DEFECTO) -> bool:
	var comp := _asegurar_compressor(bus)
	if comp == null:
		return false
	comp.threshold = threshold
	comp.ratio = ratio
	comp.attack_us = attack_us
	comp.release_ms = release_ms
	return true


## Quita la compresión del bus (= rango "dinámico").
static func remover(bus: String = BUS_DEFECTO) -> bool:
	var bidx := AudioServer.get_bus_index(bus)
	if bidx == -1:
		return false
	for i in AudioServer.get_bus_effect_count(bidx):
		if AudioServer.get_bus_effect(bidx, i) is AudioEffectCompressor:
			AudioServer.remove_bus_effect(bidx, i)
			return true
	return false


## ¿Hay compresión activa en el bus?
static func compresion_activa(bus: String = BUS_DEFECTO) -> bool:
	return _compressor_de(bus) != null


## ── internos ────────────────────────────────────────────

static func _compressor_de(bus: String) -> AudioEffectCompressor:
	var bidx := AudioServer.get_bus_index(bus)
	if bidx == -1:
		return null
	for i in AudioServer.get_bus_effect_count(bidx):
		var e := AudioServer.get_bus_effect(bidx, i)
		if e is AudioEffectCompressor:
			return e as AudioEffectCompressor
	return null


## Devuelve el compressor existente o crea uno nuevo al final del bus.
static func _asegurar_compressor(bus: String) -> AudioEffectCompressor:
	var existente := _compressor_de(bus)
	if existente != null:
		return existente
	var bidx := AudioServer.get_bus_index(bus)
	if bidx == -1:
		return null
	var nuevo := AudioEffectCompressor.new()
	AudioServer.add_bus_effect(bidx, nuevo)
	return _compressor_de(bus)
