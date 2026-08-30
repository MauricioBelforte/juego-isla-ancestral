# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M15: Recursos — ResourceDropEntry (entrada de drop de un ResourceDefinition).
# Data-driven: cada definicion declara sus entregas (item_id, min/max, probabilidad,
# requiere herramienta mejorada).

class_name ResourceDropEntry
extends Resource

@export var item_id: String = ""
@export var cantidad_min: int = 1
@export var cantidad_max: int = 1
@export var probabilidad: float = 1.0  # 0..1
@export var requiere_herramienta_mejorada: bool = false

func cantidad(rng: RandomNumberGenerator) -> int:
	var n := rng.randi_range(cantidad_min, cantidad_max)
	return maxi(1, n)
