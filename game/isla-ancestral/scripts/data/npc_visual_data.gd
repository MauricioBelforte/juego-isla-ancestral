## Datos visuales de un NPC (M161).
class_name NPCVisualData
extends Resource

## ID del NPC (coincide con M19).
@export var npc_id: String = ""

## Nombre del NPC.
@export var nombre: String = ""

## Isla donde vive.
@export var isla: String = "RIZ"

## Rasgos físicos.
@export var piel: String = "SK-01"  # SK-01 a SK-05
@export var cabello: String = "HR-01"  # HR-01 a HR-08
@export var ojos: String = "EY-01"  # EY-01 a EY-05
@export var complexion: String = "MEDIA"  # MEDIA, MUSCULOSA, DELGADA, REDONDA, ALTA, PEQUENA

## Ropa.
@export var sombrero: RopaData = null
@export var torso: RopaData = null
@export var piernas: RopaData = null
@export var pies: RopaData = null

## Accesorios.
@export var accesorios: Array[Resource] = []

## Herramienta en mano (ID de M159 o vacío).
@export var herramienta_derecha: String = ""
@export var herramienta_izquierda: String = ""

## Variantes estacionales (EstacionType -> NPCVisualData).
@export var variantes_estacionales: Dictionary = {}

## Retrato 2D (path a textura).
@export var retrato_path: String = ""

## Obtiene la variante estacional si existe, o el diseño base.
func get_seasonal_variant(estacion: String) -> NPCVisualData:
	if variantes_estacionales.has(estacion):
		return variantes_estacionales[estacion]
	return self
