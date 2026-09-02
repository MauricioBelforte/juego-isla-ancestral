# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M54: Mapa — MapaMarkers (servicio de marcadores avanzado)
# Clusterización de marcadores por cercanía, búsqueda de POIs por nombre/tipo,
# capas de exploración. Data-driven desde map_config.json.
# Diseño original (04-Codigo.md §2, markers_catalog.gd).

class_name MapaMarkers
extends RefCounted

const RUTA_CONFIG := "res://data/mapa/map_config.json"
const RADIO_CLUSTER := 40.0

var _marcadores: Array = []

func cargar() -> void:
	if not FileAccess.file_exists(RUTA_CONFIG):
		push_warning("[M54] map_config.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_CONFIG))
	if typeof(parsed) == TYPE_DICTIONARY:
		_marcadores = parsed.get("marcadores", []).duplicate(true)

func marcadores() -> Array:
	return _marcadores.duplicate(true)

## Busca POIs por término (nombre/id/coincidencia parcial en id).
func buscar_poi(termino: String) -> Array:
	var resultado: Array = []
	var t := termino.to_lower()
	for m in _marcadores:
		var id: String = String(m.get("id", "")).to_lower()
		var tipo: String = String(m.get("tipo", "")).to_lower()
		if t in id or t in tipo:
			resultado.append(m)
	return resultado

## Clusterización: agrupa marcadores cercanos (distancia euclidiana 3D < RADIO).
## Devuelve Array de {centro: Vector3, ids: Array, count: int}.
func clusterizar() -> Array:
	var clusters: Array = []
	var usados: Dictionary = {}
	for i in range(_marcadores.size()):
		if usados.get(i, false):
			continue
		var grupo: Array = [i]
		usados[i] = true
		for j in range(i + 1, _marcadores.size()):
			if usados.get(j, false):
				continue
			if _cercanos(_marcadores[i], _marcadores[j]):
				grupo.append(j)
				usados[j] = true
		if grupo.size() > 1:
			clusters.append(_crear_cluster(grupo))
		else:
			clusters.append({"centro": _coord3d(_marcadores[i]), "ids": [String(_marcadores[i].get("id", ""))], "count": 1})
	return clusters

func _cercanos(a: Dictionary, b: Dictionary) -> bool:
	var ca := _coord3d(a)
	var cb := _coord3d(b)
	return ca.distance_to(cb) < RADIO_CLUSTER

func _coord3d(m: Dictionary) -> Vector3:
	var c: Array = m.get("coords", [0, 0, 0])
	return Vector3(float(c[0]), float(c[1]), float(c[2]))

func _crear_cluster(indices: Array) -> Dictionary:
	var ids: Array = []
	var total := Vector3.ZERO
	for i in indices:
		var m: Dictionary = _marcadores[i]
		ids.append(String(m.get("id", "")))
		total += _coord3d(m)
	var centro := total / float(indices.size())
	return {"centro": centro, "ids": ids, "count": indices.size()}

## Capas de exploración: separa marcadores visibles vs ocultos (por flag).
func separar_por_exploracion(explorados: Dictionary) -> Dictionary:
	var visibles: Array = []
	var ocultos: Array = []
	for m in _marcadores:
		var id: String = String(m.get("id", ""))
		if explorados.get(id, false):
			visibles.append(m)
		else:
			ocultos.append(m)
	return {"visibles": visibles, "ocultos": ocultos}