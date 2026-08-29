@tool
extends Resource
class_name IInteractable

##
# Interfaz para objetos con los que el jugador puede interactuar.
# Implementar en recursos o nodos que expongan interacción (NPCs, cofres, puertas, estaciones de craft, etc.).
#
# @see IDamageable, ISaveable

## Interactúa con el objeto.
# @param interactor Entidad que inicia la interacción (ej: Player)
# @return true si la interacción se completó, false si falló o no aplica
func interact(interactor: Node) -> bool:
	return false

## Obtiene el prompt de interacción para mostrar en UI.
# @param interactor Entidad que consulta (para contextualizar)
# @return Texto a mostrar (ej: "Hablar", "Abrir", "Comprar", "Usar")
func get_interaction_prompt(interactor: Node) -> String:
	return ""

## Verifica si el objeto es interactuable en este momento.
# @param interactor Entidad que consulta
# @return true si puede interactuarse ahora
func is_interactable(interactor: Node) -> bool:
	return true

## Prioridad de interacción (mayor = prioritario cuando hay solapamiento).
# @return Valor de prioridad (default 0)
func get_interaction_priority() -> int:
	return 0

## Distancia máxima de interacción en metros/unidades.
# @return Distancia (default 2.0)
func get_interaction_range() -> float:
	return 2.0