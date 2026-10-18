class_name PausaContemplativa
extends Node

const MIN_INTERVALO_SEG: float = 30.0

extends Node
"""Observador de `pausa_contemplativa` (M153 ítem 178, telemetría M104).

El jugador pausa sin objetivo activo para mirar el paisaje. Ese momento es
deliberado y vale la pena medirlo: indica que el mundo invita a quedarse.

Vía de observación elegida (por qué NO se instrumentó en UIManager):
  * `UIManager` no tiene un único punto de pausa: pausan `tutorial_manager`,
    `stream_manager` y varios servicios de audio, y ninguno de ellos es "la"
    pausa del jugador.
  * Ensuciar esos módulos para teletría acoplaría M104 a M58/M63/M92/M41.

En su lugar, este observador escucha el bus (`pausa_cambiada`) o, si no existe,
expone `observar_pausa()` para que el adaptador de UI lo llame cuando sepa que el
jugador pausó. Siempre silencioso si no hay AnalyticsDirector.

Regla de anti-spam: sólo registra una pausa por `MIN_INTERVALO_SEG` para que
mantener la pausa no inunde el buffer.
"""


# -*- coding: utf-8 -*-





var _ultima_medicion: float = -1000.0

func _ready() -> void:
	var bus := get_node_or_null("/root/EventBus")
	if bus != null and bus.has_signal("pausa_cambiada"):
		bus.connect("pausa_cambiada", _on_pausa_cambiada)

## Llamado por el adaptador de UI cuando el jugador pausa el juego.
func observar_pausa(duracion_segundos: float = 0.0) -> bool:
	var ahora: float = float(Time.get_ticks_msec()) / 1000.0
	if ahora - _ultima_medicion < MIN_INTERVALO_SEG:
		return false
	_ultima_medicion = ahora
	var tm := load("res://scripts/analytics/telemetria_m104.gd")
	if tm != null and tm.has_method("pausa_contemplativa"):
		return bool(tm.pausa_contemplativa(duracion_segundos))
	return false

func _on_pausa_cambiada(pausado: bool) -> void:
	if pausado:
		observar_pausa(0.0)
