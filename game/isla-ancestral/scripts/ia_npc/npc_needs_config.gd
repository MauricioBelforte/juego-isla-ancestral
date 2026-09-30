# M64: Config de necesidades de NPC — velocidades y umbrales ajustables.
# Creado para poder tunear valores desde el editor sin tocar código.

extends Resource
class_name NPCNeedsConfig

## Velocidades de decremento (por segundo de juego)
@export var hunger_rate: float = 0.5
@export var energy_rate: float = 0.3
@export var social_rate: float = 0.1

## Recuperación
@export var mood_recovery_rate: float = 0.05
@export var mood_decay_rate: float = 0.1
@export var mood_recovery_threshold: float = 50.0

## Umbrales de urgencia
@export var hunger_urgency: float = 20.0
@export var energy_urgency: float = 15.0
@export var social_urgency: float = 20.0

## Velocidades de recuperación (por interacción)
@export var eat_recovery: float = 30.0
@export var sleep_recovery: float = 40.0
@export var socialize_recovery: float = 20.0
