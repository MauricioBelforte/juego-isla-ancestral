# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M28: Viajes — Harbor (Node3D). Puerto de cada isla (M27).
# Contiene una lista de HarborDock; find_free_dock devuelve el primero libre.
# Los docks se bloquean al zarpar (origen) y al atracar (destino).
# Si todos los docks están ocupados, devuelve null (el servicio espera).
#
# Sin class_name: es nodo de escena instanciado por isla (pitfall §9.17).

extends Node3D

## ID de la isla que gestiona este puerto (vinculado a M27).
@export var island_id: String = ""

## Lista de docks (se completa desde el editor arrastrando HarborDock hijos).
var _docks: Array = []

## Señales
## emitida cuando se encuentra un dock libre (para TravelService).
signal free_dock_found(dock: Node)
## emitida cuando NO hay docks libres (para manejo de espera).
signal no_free_dock

const ESPERA_MAX_SEGUNDOS: float = 10.0


func _ready() -> void:
	_docks.clear()
	# Recolecta hijos que sean HarborDock (o tengan el método lock).
	for child in get_children():
		if child.has_method("lock") and child.has_method("release"):
			_docks.append(child)
	print("[M28/Harbor] Puerto '%s' cargado: %d docks" % [island_id, _docks.size()])


## Devuelve el primer dock libre, o null si no hay.
func find_free_dock() -> Node:
	for dock in _docks:
		if not dock.is_locked():
			return dock
	no_free_dock.emit()
	return null


## Bloquea el dock para el barco (se llama al zarpar).
func lock_dock(boat: Node) -> bool:
	var dock := find_free_dock()
	if dock == null:
		return false
	return bool(dock.lock(boat))


## Libera el dock del barco (se llama al atracar).
func release_dock(boat: Node) -> void:
	for dock in _docks:
		if dock.is_locked() and dock.get_boat() == boat:
			dock.release()
			return


## Devuelve true si hay al menos un dock disponible.
func is_dock_available() -> bool:
	return find_free_dock() != null


## Cantidad de docks totales.
func dock_count() -> int:
	return _docks.size()


## Cantidad de docks ocupados.
func occupied_dock_count() -> int:
	var count := 0
	for dock in _docks:
		if dock.is_locked():
			count += 1
	return count


## Posición del primer dock libre (para spawn del jugador al desembarcar).
func get_embark_position() -> Vector3:
	for dock in _docks:
		if not dock.is_locked():
			return dock.global_position
	# Fallback: primer dock (aunque ocupado).
	if _docks.size() > 0:
		return _docks[0].global_position
	return global_position
