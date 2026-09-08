class_name PlayerDataStruct
extends RefCounted

## Struct de datos del jugador (M111 - Código de Calidad).
## Nota: evita colisión con class_name ItemData existente usando sufijo Struct.

var id: String = ""
var display_name: String = ""
var position: Vector3 = Vector3.ZERO
var health: float = 100.0
var level: int = 1
var inventory: Dictionary = {}
