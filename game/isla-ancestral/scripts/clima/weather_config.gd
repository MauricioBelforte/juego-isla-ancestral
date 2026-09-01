# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-08-31
#
# M32: Clima — Configuración data-driven (WeatherConfig, clima_config.tres).
# Todo valor tunable vive acá (checklist C: "sin valores duros en scripts").
# Probabilidades por estación normalizadas (suma 1.0) según 03-Diseno §2.
class_name WeatherConfig
extends Resource

## Semilla maestra del clima (7919 en dev; determinista por partida)
@export var semilla_clima: int = 7919

## Ventana de transición de intensidad en minutos de juego (1 s real = 1 min juego)
@export var transicion_min_minutos: int = 60
@export var transicion_max_minutos: int = 90

## estacion (0-3) -> Array de {clima: int, prob: float} (suma 1.0 por estación)
@export var probabilidades_por_estacion: Dictionary = {}

## clima (0-8) -> atenuación de sol (1.0 = sin cambio; nieve 1.10 por reflejo)
@export var atenuacion_sol: Dictionary = {}

## clima (0-8) -> {min: float, max: float} horas de juego por episodio (uso M29/UI)
@export var duraciones_horas: Dictionary = {}

## clima (0-8) -> volumen lineal 0..1 del bus de audio climático (M42)
@export var volumenes_audio: Dictionary = {}

## Climas "profundos" que nunca ocurren dos días seguidos (regla cozy, 03-Diseno §2)
@export var climas_profundos: Array[int] = []
