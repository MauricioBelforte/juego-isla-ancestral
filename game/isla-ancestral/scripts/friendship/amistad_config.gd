extends Resource
class_name AmistadConfig

## M20: config data-driven de niveles de amistad y recompensas por nivel.
## Fuente de verdad editable en el inspector (sin tocar codigo). FriendshipService
## la carga en _ready y la inyecta en cada VecinoAmistad; si falta el .tres,
## se usa el fallback const UMBRALES / RECOMPENSAS_NIVEL.

## Puntos acumulados para alcanzar cada nivel (nivel 1 = 0, nivel 11 = 500).
@export var umbrales: Array[int] = [0, 20, 40, 70, 100, 140, 190, 250, 320, 400, 500]

## reward_id por nivel al que se sube (se encolan como pendientes de reclamar).
@export var recompensas_nivel: Dictionary = {
	2: ["receta_herramienta_basica"],
	3: ["decorativo_estatua"],
	5: ["receta_comida_gourmet"],
	8: ["decorativo_fuente"],
}
