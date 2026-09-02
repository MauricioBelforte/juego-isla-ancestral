# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M95: Monetización — EdicionCatalogo
# Catálogo de ediciones del juego (Standard/Deluxe/Coleccionista) con
# contenido y precio de referencia. Data-driven desde JSON (RF5).
# Diseño original (04-Codigo.md §1.1, EdicionesDelJuego.cs).

class_name EdicionCatalogo
extends RefCounted

const RUTA := "res://data/monetizacion/ediciones.json"

var _ediciones: Dictionary = {}   # id -> Dictionary

func cargar() -> void:
	if not FileAccess.file_exists(RUTA):
		push_warning("[M95] Ediciones no encontradas: %s" % RUTA)
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA))
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("ediciones"):
		push_warning("[M95] ediciones.json inválido")
		return
	for edicion in parsed["ediciones"]:
		if typeof(edicion) == TYPE_DICTIONARY:
			var id: String = String(edicion.get("id", ""))
			if not id.is_empty():
				_ediciones[id] = edicion

func obtener(id: String) -> Dictionary:
	return _ediciones.get(id, {})

## RF/03: TODAS las ediciones contienen la historia completa (6 sellos + actos).
## Verifica contra el catálogo: el campo historia_completa debe ser true.
func contiene_historia_completa(id: String) -> bool:
	var e := obtener(id)
	return bool(e.get("historia_completa", false))

func ids() -> Array:
	return _ediciones.keys()

func cantidad() -> int:
	return _ediciones.size()