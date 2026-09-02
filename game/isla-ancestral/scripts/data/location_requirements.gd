class_name LocationRequirements
extends Resource

## Requisitos para acceder a una ubicación.
## Herramienta mínima requerida (ej: "T1", "T2")
@export var herramienta_minima: String

## Monedas necesarias (0 = gratis)
@export var costo_entrada: int

## Items especiales requeridos
@export var items_requeridos: Array

## NPCs que deben estar presentes
@export var npcs_requeridos: Array

## Descripción legible de los requisitos
@export var descripcion_requisitos: String
