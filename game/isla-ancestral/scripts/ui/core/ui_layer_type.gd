class_name UILayerType
## Tipos de capa de UI para el sistema de pila de UIManager
##
## Cada tipo define el comportamiento de pausa y prioridad de input:
## - HUD: siempre visible, no pausa el mundo, sin modalidad
## - MODAL_SIMPLE: pausa el reloj pero el mundo sigue visible (diálogos)
## - MODAL_FULL: pausa total, bloquea input del mundo (inventario, pausa)
## - POPUP: no competidor de foco, superpuesto (confirm, tooltip, notificación)

enum Type {
	## HUD siempre visible, sin modalidad
	HUD,
	## Modal sencillo: pausa parcial (reloj), mundo visible congelado
	MODAL_SIMPLE,
	## Modal completo: pausa total, bloquea input del mundo
	MODAL_FULL,
	## Popup: superpuesto, no compite por foco principal
	POPUP,
}
