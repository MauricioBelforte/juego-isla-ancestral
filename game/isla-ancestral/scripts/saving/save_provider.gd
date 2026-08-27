class_name ISaveProvider
extends RefCounted

## Módulo 59: Guardado — Contrato de snapshot por sistema
##
## Cada sistema persistente (inventario, mundo, construcciones, NPC,
## misiones, amistad, economía, tiempo, eventos, colecciones, diario,
## fotos) implementa este contrato para EXPORTAR su estado al save y
## RESTAURARLO al cargar. Así SaveSnapshot no conoce detalles internos.
##
## Uso:
##   class_.extends(ISaveProvider) en un autoload/servicio que represente
##   al sistema. Registrar la instancia en SaveManager.register_provider().
##
## Los proveedores son "opcionales por diseño": un sistema no implementado
## simplemente no se registra y su sección queda con defaults del schema.
## Esto permite que el guardado funcione desde el prototipo y se amplíe sin
## romperse (regla de modularización, AGENTS §15).

## Devuelve el Dictionary de la sección que este sistema persiste.
## Debe ser un snapshot COMPACTO serializable a JSON (sin referencias a nodos).
func get_save_data() -> Dictionary:
	assert(false, "ISaveProvider.get_save_data() debe implementarse")
	return {}

## Recibe el snapshot guardado (Dictionary) y restaura el estado del sistema.
## Debe ser tolerante a datos faltantes (usar defaults del sistema).
func restore_save_data(_data: Dictionary) -> void:
	assert(false, "ISaveProvider.restore_save_data() debe implementarse")

## Devuelve el nombre único de la sección (clave dentro del payload).
## Debe coincidir con las secciones del SaveSchema.
func get_section_name() -> String:
	assert(false, "ISaveProvider.get_section_name() debe implementarse")
	return ""
