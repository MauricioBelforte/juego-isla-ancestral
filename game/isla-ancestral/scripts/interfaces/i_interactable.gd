@tool
extends Resource
class_name IInteractable

##
# Interfaz para objetos con los que el jugador puede interactuar.
# Implementar en recursos o nodos que expongan interacción (NPCs, cofres, puertas, estaciones de craft, etc.).
#
# v2 (M70, minimax-m3-free / Kilo Code, 2026-09-01): ampliada con métodos opcionales para que el
# InteractionManager pueda operar sin que cada consumidor tenga que reimplementar todo.
# Todos los métodos nuevos tienen default que preserva el comportamiento de v1 (prompt "", no_state, etc.).
# Por eso **no rompe consumidores existentes** — solo agrega superficie opcional.
#
# @see IDamageable, ISaveable
# @see DOCUMENTACION/70-Interacciones/plan-actual/04-Codigo.md

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

## Prioridad de interacción (M70 v2, español). Default delega a get_interaction_priority()
## para mantener compatibilidad con consumidores v1. Sobrescribir en subclases para
## evitar el doble dispatch.
func obtener_prioridad() -> int:
	return get_interaction_priority()

## Distancia máxima de interacción en metros/unidades.
# @return Distancia (default 2.0)
func get_interaction_range() -> float:
	return 2.0

## Distancia máxima de interacción (M70 v2, español). Default delega a v1.
func obtener_rango() -> float:
	return get_interaction_range()

## ── M70: métodos opcionales ampliados (non-breaking) ────────────

## Estado del interactuable para que el gestor module el prompt.
# @return uno de DISPONIBLE, INTERACTUANDO, NO_DISPONIBLE, OCULTO
func obtener_estado() -> int:
	return 0  # DISPONIBLE

## Categoría semántica (npc, cofre, puerta, cosecha, animal, objeto, evento, decorativo).
# @return StringName de la categoría (default "")
func obtener_categoria() -> StringName:
	return &""

## Posición mundial donde el indicador debe colocarse (normalmente global_position).
# @return Vector3
func obtener_posicion_interaccion() -> Vector3:
	return Vector3.ZERO

## Radio de hitbox para el filtro de distancia (puede diferir de get_interaction_range si
# la hitbox es un volumen, no una esfera). Default = get_interaction_range().
func obtener_radio() -> float:
	return get_interaction_range()

## Nombre localizable para la línea de contexto del HUD (ej: "Hablar con Catalina").
# @return String (pasar por tr() si viene de un catálogo)
func obtener_nombre_prompt() -> String:
	return get_interaction_prompt(null)

## Razón localizable de NO_DISPONIBLE ("" = sin razón).
# @return String
func obtener_razon_no_disponible() -> String:
	return ""

## Validación de requisitos previos a la interacción.
# @param jugador nodo Player (M11) o null si no hay
# @return true si cumple requisitos (herramienta M13, item M14, hora M29, amistad M20, etc.)
func requisitos_cumplidos(jugador) -> bool:
	return is_interactable(jugador)

## Despacho de la interacción. El gestor llama esto al presionar E.
# @param datos Dict con claves: jugador (Node), tool (ToolData|null), timestamp (int)
func interactuar(datos: Dictionary) -> void:
	# Default v1: delega al a.interact() legacy para no romper consumidores existentes.
	if datos.has("jugador"):
		interact(datos.jugador)

## Notificación de cancelación al consumidor (cuando el jugador se aleja o cambia de objetivo).
func cancelar_interaccion() -> void:
	pass

## Duración esperada de la interacción en segundos. 0 = instantánea (default).
func obtener_duracion_esperada() -> float:
	return 0.0