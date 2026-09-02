class_name LocationObject
extends Resource

## Objeto dentro de una ubicación.
## ID del objeto en M159 (ej: OBJ-CAM-001)
@export var item_id: String

## Nombre del objeto
@export var nombre: String

## Posición en la ubicación (coordenadas locales)
@export var posicion: Vector3

## Rotación en grados (0, 90, 180, 270)
@export var rotacion: float

## Variante del objeto (si aplica)
@export var variante: String

## Si el objeto es interactuable
@export var interactuable: bool

## Tipo de interacción (si interactuable)
@export var tipo_interaccion: String

## Si el objeto es de recolección (se puede recoger)
@export var recolectable: bool

## Recurso que drops (si recolectable)
@export var drop_recurso: String

## Cantidad de drops
@export var drop_cantidad: int

## Tiempo de regeneración en segundos (0 = no regenera)
@export var tiempo_regeneracion: float

## Notas para artistas/programadores
@export var notas: String
