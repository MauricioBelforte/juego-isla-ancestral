# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M95: Monetización — DlcCatalogo
# Roadmap de DLC planificados (RF6): DLC-1 expansión (nueva isla) y DLC-2
# cosmético (decoración), sin fragmentar la historia principal. Data-driven
# desde JSON. Diseño original (04-Codigo.md §1.1, DlcCatalogo.cs).

class_name DlcCatalogo
extends RefCounted

const RUTA := "res://data/monetizacion/dlc.json"

var _dlcs: Dictionary = {}   # id -> Dictionary

func cargar() -> void:
	if not FileAccess.file_exists(RUTA):
		push_warning("[M95] DLC no encontrados: %s" % RUTA)
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA))
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("dlcs"):
		push_warning("[M95] dlc.json inválido")
		return
	for dlc in parsed["dlcs"]:
		if typeof(dlc) == TYPE_DICTIONARY:
			var id: String = String(dlc.get("id", ""))
			if not id.is_empty():
				_dlcs[id] = dlc

func obtener(id: String) -> Dictionary:
	return _dlcs.get(id, {})

## Roadmap ordenado por orden de lanzamiento.
func roadmap() -> Array:
	var lista: Array = []
	for id in _dlcs:
		lista.append(_dlcs[id])
	lista.sort_custom(func(a, b): return int(a.get("orden", 99)) < int(b.get("orden", 99)))
	return lista

## Un DLC es cosmético si tipo == "cosmetico" (no toca progresión M38/M71).
func es_cosmetico(id: String) -> bool:
	return String(obtener(id).get("tipo", "")) == "cosmetico"

func cantidad() -> int:
	return _dlcs.size()