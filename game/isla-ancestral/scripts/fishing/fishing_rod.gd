# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-31
#
# M34: FishingRod — stats de la cana equipada (§2.3).
# Reglas §6: ventana de éxito mínima 0.35 s (cana vieja) — clamp defensivo.

class_name FishingRod
extends Resource

@export var id: String = "cana_vieja"
@export var rango_lanzamiento: float = 8.0
@export var ventana_exito: float = 0.5   # s (fase A y B)
@export var multiplicador_espera: float = 1.0
@export var multiplicador_rareza: float = 1.0

func ventana_clamp() -> float:
	return maxf(0.35, ventana_exito)
