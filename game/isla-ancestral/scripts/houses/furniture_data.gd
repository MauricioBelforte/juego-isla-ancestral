# Modelo: agnes-3-flash
# Plataforma: Kilo Code
# Fecha: 2026-10-09
# M18: FurnitureData — recurso de configuración de muebles.
extends Resource
class_name FurnitureData

@export var nombre: String = ""
@export var categoria: String = "decorativo"  # decorativo, almacenamiento, funcional
@export var capacidad_slots: int = 0  # 0 = no es contenedor
@export var ancho: float = 1.0
@export var profundo: float = 1.0
@export var alto: float = 1.0
@export var requiere_superficie: bool = true
@export var requiere_pared: bool = false

func es_contenedor() -> bool:
	return capacidad_slots > 0

func obtener_volumen() -> float:
	return ancho * profundo * alto
