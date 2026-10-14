@tool
extends Resource
class_name IViajable

##
# Interfaz para servicios de viaje entre zonas/islas (contrato entre capas, M139 seccion 1).
# Implementar en el servicio de viajes (M28) y en destinos que puedan recibir viajeros.
#
# Creado 2026-10-14 por step-5-kilocode (encargo del director mimo, frente M139 Pre-Alpha):
# completaba el contrato de la seccion 1 del checklist. NO rompe consumidores: es
# superficie nueva y todos los metodos tienen default neutro.
#
# @see IInteractable, ITienda, ITemplo
# @see DOCUMENTACION/139-Pre-Alpha/plan-actual/05-Checklist.md (seccion 1)

## Solicita un viaje al destino indicado.
# @return Dictionary con el resultado (ok, motivo, ruta) listo para que la UI lo muestre
func solicitar_viaje(destino_id: String) -> Dictionary:
	return {}

## Cancela el viaje en curso.
# @return Dictionary con el resultado (ok, reembolso)
func cancelar_viaje() -> Dictionary:
	return {}

## True si hay un viaje en curso.
func en_viaje() -> bool:
	return false

## Progreso del viaje en curso, 0.0 a 1.0.
func progreso_viaje() -> float:
	return 0.0

## Destinos disponibles desde la posicion actual.
func destinos_disponibles() -> Array:
	return []

## Identificador estable del destino (isla/zona).
func id_destino() -> String:
	return ""
