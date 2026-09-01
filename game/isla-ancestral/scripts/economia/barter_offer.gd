# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-08-31
#
# M38: BarterOffer — propuesta de trueque (Resource, una por archivo .tres
# en data/economia/barter/ según 03-Diseno §3.5).
# Trueque objeto-por-objeto SIN moneda (RF7), con amistad mínima (M20/RF8),
# temporada (M29) y límite diario por NPC. El "salvavidas" (RF12) es una
# oferta siempre disponible para partir sin monedas.
class_name BarterOffer
extends Resource

## Identificador único de la oferta
@export var oferta_id: StringName = &""
## NPC que la ofrece (M20); "" = genérica
@export var npc_id: String = ""
## Items que entrega el jugador: {item_id: cantidad}
@export var pedido: Dictionary = {}
## Items que recibe el jugador: {item_id: cantidad}
@export var entregado: Dictionary = {}
## Nivel de amistad mínimo (M20); 0 = siempre disponible
@export var amistad_minima: int = 0
## Estaciones válidas (0-3, M29); vacío = todas
@export var estaciones: Array[int] = []
## Trueque de partida (RF12): siempre disponible, no consume límite diario
@export var es_salvavidas: bool = false
## Usos máximos por día del NPC (-1 = usa el límite por defecto del servicio)
@export var limite_diario: int = -1
