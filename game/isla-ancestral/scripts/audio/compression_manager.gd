# Modelo: mimo-v2.6-flash-free
# Plataforma: opencode
# Fecha: 2026-10-02
#
# M91 — Compresión de picos (limiter) sobre un bus.
#
# Protege contra clipping: limita los picos de volumen a un techo (ceiling)
# con soft clipping en vez de recorte duro.
#
# STATELESS: el estado se DERIVA de AudioServer (presencia de un
# AudioEffectLimiter en el bus). Sin nodos, sin coste por frame.
#
# API real Godot 4.7.2 — SONDEADA por reflexión, no adivinada (T-107):
#   AudioEffectLimiter -> ceiling_db, threshold_db, soft_clip_db, soft_clip_ratio
#   ⚠ El 04-Codigo §10 de este módulo usa `ceil_db` y `soft_clip`, que NO
#     existen en Godot 4.7. Deben corregirse (ver GUIA-GODOT/06 T-107).
class_name CompressionManager
extends RefCounted

const BUS_DEFECTO := "Master"

## Límites por defecto del diseño (dB)
const THRESHOLD_DB_DEFECTO := -3.0   ## por debajo de esto no se comprime
const CEILING_DB_DEFECTO := 0.0      ## techo máximo de picos
const SOFT_CLIP_DB_DEFECTO := -6.0   ## zona donde empieza el suavizado
const SOFT_CLIP_RATIO_DEFECTO := 2.0 ## pendiente del suavizado


## Activa la limitación de picos en el bus.
static func activar(bus: String = BUS_DEFECTO) -> bool:
	return _configurar(bus, THRESHOLD_DB_DEFECTO, CEILING_DB_DEFECTO, \
			SOFT_CLIP_DB_DEFECTO, SOFT_CLIP_RATIO_DEFECTO)


## Desactiva la limitación (remueve el efecto del bus).
static func desactivar(bus: String = BUS_DEFECTO) -> bool:
	var bidx := AudioServer.get_bus_index(bus)
	if bidx == -1:
		return false
	for i in AudioServer.get_bus_effect_count(bidx):
		if AudioServer.get_bus_effect(bidx, i) is AudioEffectLimiter:
			AudioServer.remove_bus_effect(bidx, i)
			return true
	return false


## ¿Está la compresión activa en el bus?
static func activa(bus: String = BUS_DEFECTO) -> bool:
	return _limiter_de(bus) != null


## Configura el limiter (crea el efecto si no existe).
## threshold_db < ceiling_db; soft_clip_db define el inicio del suavizado.
static func configurar(threshold_db: float, ceiling_db: float, \
		soft_clip_db: float, soft_clip_ratio: float, \
		bus: String = BUS_DEFECTO) -> bool:
	return _configurar(bus, threshold_db, ceiling_db, soft_clip_db, soft_clip_ratio)


## Valores actuales; {} si no hay limiter en el bus.
static func parametros(bus: String = BUS_DEFECTO) -> Dictionary:
	var l := _limiter_de(bus)
	if l == null:
		return {}
	return {
		"threshold_db": l.threshold_db,
		"ceiling_db": l.ceiling_db,
		"soft_clip_db": l.soft_clip_db,
		"soft_clip_ratio": l.soft_clip_ratio,
	}


## ── internos ────────────────────────────────────────────

static func _limiter_de(bus: String) -> AudioEffectLimiter:
	var bidx := AudioServer.get_bus_index(bus)
	if bidx == -1:
		return null
	for i in AudioServer.get_bus_effect_count(bidx):
		var e := AudioServer.get_bus_effect(bidx, i)
		if e is AudioEffectLimiter:
			return e as AudioEffectLimiter
	return null


static func _configurar(bus: String, threshold_db: float, ceiling_db: float, \
		soft_clip_db: float, soft_clip_ratio: float) -> bool:
	var bidx := AudioServer.get_bus_index(bus)
	if bidx == -1:
		return false
	var l := _limiter_de(bus)
	if l == null:
		l = AudioEffectLimiter.new()
		AudioServer.add_bus_effect(bidx, l)
		l = _limiter_de(bus)
		if l == null:
			return false
	l.threshold_db = threshold_db
	l.ceiling_db = ceiling_db
	l.soft_clip_db = soft_clip_db
	l.soft_clip_ratio = soft_clip_ratio
	return true
