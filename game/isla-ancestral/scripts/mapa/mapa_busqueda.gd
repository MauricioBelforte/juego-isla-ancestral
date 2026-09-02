# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M54: Mapa — MapaBusqueda (servicio de búsqueda de POIs)
# Búsqueda de marcadores por nombre, tipo, isla. Clusterización persistente.
# Data-driven desde map_config.json.

class_name MapaBusqueda
extends RefCounted

const RUTA_CONFIG := "res://data/mapa/map_config.json"

var _marcadores: Array = []

func cargar() -> void:
	if not FileAccess.file_exists(RUTA_CONFIG):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_CONFIG))
	if typeof(parsed) == TYPE_DICTIONARY:
		_marcadores = parsed.get("marcadores", []).duplicate(true)

func buscar_por_nombre(termino: String) -> Array:
	var t := termino.to_lower()
	var res: Array = []
	for m in _marcadores:
		var id: String = String(m.get("id", "")).to_lower()
		var tipo: String = String(m.get("tipo", "")).to_lower()
		if t in id or t in tipo:
			res.append(m)
	return res

func contar_por_tipo(tipo: String) -> int:
	var n := 0
	for m in _marcadores:
		if String(m.get("tipo", "")).to_lower() == tipo.to_lower():
			n += 1
	return n

func ids_por_isla(isla: String) -> Array:
	var res: Array = []
	for m in _marcadores:
		if String(m.get("isla", "")).to_lower() == isla.to_lower():
			res.append(m.get("id", ""))
	return res