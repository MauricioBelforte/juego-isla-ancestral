class_name LocationData
extends Resource

## Datos de una ubicación del mundo.
## ID de la ubicación (formato LOC-ISLA-TIPO-NÚMERO)
@export var location_id: String

## Nombre de la ubicación
@export var nombre: String

## Tipo de ubicación
@export var tipo: int

## Isla donde se encuentra
@export var isla: int

## Descripción breve
@export var descripcion: String

## Requisitos de acceso (herramientas, monedas, items)
@export var requisitos: Resource

## Lista de objetos en esta ubicación
@export var objetos: Array

## NPCs asociados a esta ubicación
@export var npcs: Array

## Conexiones con otras ubicaciones (IDs)
@export var conexiones: Array

## Si esta ubicación es ampliable por el jugador
@export var ampliable: bool

## Tags para filtrado (tutorial, puzzle, boss, etc.)
@export var tags: Array
