@tool
extends Resource
class_name ITemplo

##
# Interfaz para templos y lugares de ofrenda (contrato entre capas, M139 seccion 1).
# Implementar en nodos/recursos que expongan ofrendas, bendiciones y puzzles de templo
# (M26 Templos, M24 Puzzles).
#
# Creado 2026-10-14 por step-5-kilocode (encargo del director mimo, frente M139 Pre-Alpha):
# completaba el contrato de la seccion 1 del checklist. NO rompe consumidores: es
# superficie nueva y todos los metodos tienen default neutro.
#
# @see IInteractable, ITienda, IViajable
# @see DOCUMENTACION/139-Pre-Alpha/plan-actual/05-Checklist.md (seccion 1)

## Ofrenda un item al templo.
# @return true si la ofrenda fue aceptada
func ofrendar(item_id: String, cantidad: int = 1) -> bool:
	return false

## True si el jugador cumplio los requisitos para la bendicion del templo.
func tiene_bendicion() -> bool:
	return false

## Consume la bendicion (una sola vez hasta la proxima condicion).
# @return true si estaba disponible y se consumo
func consumir_bendicion() -> bool:
	return false

## Puzzle asociado al templo, resuelto o no (M24).
func puzzle_resuelto() -> bool:
	return false

## Identificador estable del templo.
func id_templo() -> String:
	return ""
