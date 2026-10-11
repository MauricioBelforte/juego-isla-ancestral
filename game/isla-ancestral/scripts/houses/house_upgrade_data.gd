# Modelo: Atria-Dawn-Preview (atria-dawn-s2)
# Plataforma: Kilo Code
# Fecha: 2026-10-11
# M18: HouseUpgradeData — recurso de configuración de una etapa de mejora.
extends Resource
class_name HouseUpgradeData

@export var etapa: int = 1
@export var display_name: String = ""
@export var costo: Dictionary = {}  # item_id -> cantidad (M14)
@export var requisito_mision: String = ""
@export var requisito_amistad: int = 0
@export var dias_obra: int = 1
@export var habitaciones: Array = []
@export var slots_decor_extra: int = 0
@export var slots_storage_extra: int = 0

## ¿Esta etapa requiere misión previa (M21)?
func requiere_mision() -> bool:
	return requisito_mision != ""

## ¿Requiere un nivel de amistad mínimo con algún vecino (M19)?
func requiere_amistad() -> bool:
	return requisito_amistad > 0

## Suma total de materiales del costo de la etapa.
func costo_total() -> int:
	var total := 0
	for cantidad in costo.values():
		total += int(cantidad)
	return total

## ¿Añade habitaciones nuevas al interior?
func anade_habitaciones() -> bool:
	return habitaciones.size() > 0
