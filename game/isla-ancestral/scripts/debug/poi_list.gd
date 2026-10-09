# Modelo: agnes-3-flash
# Plataforma: Kilo Code
# Fecha: 2026-10-09
# M110-UI: Recurso de puntos de interés (POI) para el dropdown de teletransporte.
extends Resource
class_name POIList

@export var pois: Array = []

func obtener_nombres() -> Array:
	var nombres := []
	for poi in pois:
		if typeof(poi) == TYPE_DICTIONARY:
			nombres.append(String(poi.get("nombre", "")))
		else:
			nombres.append(str(poi))
	return nombres

func obtener_pos(nombre: String) -> Vector2:
	for poi in pois:
		if typeof(poi) == TYPE_DICTIONARY and String(poi.get("nombre", "")) == nombre:
			return poi.get("pos", Vector2.ZERO)
	return Vector2.ZERO

func tamano() -> int:
	return pois.size()
