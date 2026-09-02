# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M54: MapSchema — validación de POIs del mapa (map_data.json).
class_name MapSchema
extends RefCounted

const CATEGORIAS := ["punto", "hogar", "ruina", "taller", "hito", "templo", "playa", "pueblo", "montana"]

## Devuelve Array[String] con los problemas (vacía si es válido).
static func validar_pois(map_data: Dictionary) -> Array[String]:
	var errores: Array[String] = []
	var pois: Variant = map_data.get("pois", [])
	if typeof(pois) != TYPE_ARRAY or pois.is_empty():
		return ["pois vacío o inválido"]
	var ids := {}
	for poi in pois:
		if typeof(poi) != TYPE_DICTIONARY:
			errores.append("POI no es diccionario")
			continue
		var id: String = String(poi.get("id", ""))
		if id.is_empty():
			errores.append("POI sin id")
		elif ids.has(id):
			errores.append("POI id duplicado: %s" % id)
		else:
			ids[id] = true
		if not String(poi.get("nombre", "")).is_empty() == false and str(poi.get("nombre", "")).is_empty():
			errores.append("POI %s sin nombre" % id)
		if not CATEGORIAS.has(String(poi.get("categoria", ""))):
			errores.append("POI %s categoría inválida: %s" % [id, poi.get("categoria", "")])
		var x := float(poi.get("x", -1))
		var z := float(poi.get("z", -1))
		if x < 0 or x > 512 or z < 0 or z > 512:
			errores.append("POI %s coordenadas fuera de rango (x=%s z=%s)" % [id, x, z])
	return errores
