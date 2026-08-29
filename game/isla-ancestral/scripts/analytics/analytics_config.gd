# Modelo: ox-alpha (Cline)
# Plataforma: Cline
# Fecha: 2026-08-29
#
# M104: Analytics — AnalyticsConfig (Resource).
# Config por build del AnalyticsDirector (opt-out por defecto, frecuencia de
# batch y capacidad del buffer). El toggle del jugador (M91) persiste en
# user://analytics/opt_out.cfg y pisa este valor.

class_name AnalyticsConfig
extends Resource

## Opt-out por defecto para este build (privacidad por diseño: false = captura)
@export var opt_out: bool = false

## Minutos entre envíos de lote
@export var batch_interval_min: float = 30.0

## Máximo de eventos en el buffer en memoria
@export var max_buffer: int = 500

# ── Getters (usados por el director vía has_method) ──
func get_opt_out() -> bool:
	return opt_out

func get_batch_interval_min() -> float:
	return batch_interval_min

func get_max_buffer() -> int:
	return max_buffer