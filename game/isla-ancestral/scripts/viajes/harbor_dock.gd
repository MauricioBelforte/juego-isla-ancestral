# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M28: Viajes — HarborDock (Marker3D). Punto de atraque con lock/release.
# Diseño §E: cada harbor tiene varios docks; uno se bloquea durante el viaje
# y se libera al atracar. Si todos están ocupados, el barco espera (hasta 10 s)
# o usa muelle secundario.
#
# Sin class_name: es nodo de escena, no autoload (pitfall §9.17).

extends Marker3D

## Dock libre (=true) u ocupado por un barco.
var _ocupado: bool = false
## Barco que ocupa este dock (null si libre).
var _barco: Node = null

## Señal: dock bloqueado (emite cuando se ocupa).
signal dock_locked(boat_id: String)
## Señal: dock liberado (emite cuando se desocupa).
signal dock_released

## ── Contratos API (§E, diseño) ─────────────────────────────

func lock(boat: Node) -> bool:
	"""Blockea el dock para el barco. Retorna true si tuvo espacio."""
	if _ocupado:
		return false
	_ocupado = true
	_barco = boat
	dock_locked.emit(_boat_id_from_node(boat))
	print("[M28/HarborDock] Dock %s bloqueado por %s" % [name, _boat_id_from_node(boat)])
	return true


func release() -> void:
	"""Libera el dock (llamado por TravelService al atracar)."""
	if not _ocupado:
		return
	var id := _boat_id_from_node(_barco)
	_ocupado = false
	_barco = null
	dock_released.emit()
	print("[M28/HarborDock] Dock %s liberado (%s)" % [name, id])


func is_locked() -> bool:
	return _ocupado


func get_boat() -> Node:
	return _barco


func _boat_id_from_node(boat: Node) -> String:
	if boat == null:
		return "none"
	if boat.has_method("get_route_id"):
		return str(boat.get_route_id())
	return boat.name if boat.name != "" else "unknown"
