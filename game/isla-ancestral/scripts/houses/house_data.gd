# Modelo: Atria-Dawn-Preview (atria-dawn-s2)
# Plataforma: Kilo Code
# Fecha: 2026-10-11
# M18: HouseData — recurso de configuración de la planta de una casa.
extends Resource
class_name HouseData

@export var display_name: String = "Choza"
@export var huella_voxel: Vector2i = Vector2i(4, 4)
@export var etapa_inicial: int = 1
@export var costo_inicial: Dictionary = {"wood": 20, "stone": 10}

## La huella debe ser positiva en ambos ejes (M17 valida el terreno).
func huella_valida() -> bool:
	return huella_voxel.x > 0 and huella_voxel.y > 0

## Suma total de materiales del costo inicial (M14).
func costo_total() -> int:
	var total := 0
	for cantidad in costo_inicial.values():
		total += int(cantidad)
	return total

## Superficie en celdas voxel de la huella.
func superficie_celdas() -> int:
	return int(huella_voxel.x) * int(huella_voxel.y)
