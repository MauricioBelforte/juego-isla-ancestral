@tool
extends Resource
class_name IDamageable

##
# Interfaz para entidades que pueden recibir daño y tener salud.
# Implementar en NPCs, enemigos, jugador, objetos destructibles, etc.
#
# @see IInteractable, ISaveable

## Aplica daño a la entidad.
# @param amount Cantidad de daño
# @param damage_type Tipo de daño (opcional, para resistencias)
# @param source Fuente del daño (opcional, para knockback, crédito de kill, etc.)
# @return Daño real aplicado (tras resistencias, armadura, etc.)
func take_damage(amount: float, damage_type: StringName = &"", source: Node = null) -> float:
	return 0.0

## Obtiene la salud actual.
# @return Salud actual (0 = muerto/destruido)
func get_health() -> float:
	return 0.0

## Obtiene la salud máxima.
# @return Salud máxima
func get_max_health() -> float:
	return 100.0

## Verifica si la entidad está viva.
# @return true si salud > 0
func is_alive() -> bool:
	return get_health() > 0.0

## Cura a la entidad.
# @param amount Cantidad a curar
# @return Salud real curada (no excede max_health)
func heal(amount: float) -> float:
	return 0.0

## Establece la salud directamente (para cargar saves, respawn, etc.).
# @param value Nueva salud (clamped a [0, max_health])
func set_health(value: float) -> void:
	pass

## Señal emitida cuando la salud cambia.
signal health_changed(new_health: float, max_health: float, damage_taken: float)

## Señal emitida cuando la entidad muere.
signal died(killer: Node)