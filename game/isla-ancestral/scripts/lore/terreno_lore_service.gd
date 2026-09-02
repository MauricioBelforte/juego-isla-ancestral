# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M148: Lore Ambiental — TerrenoLoreService
# Activa secretos de lore por temporada (RF6): cuando cambia la temporada
# (M74), revisa la configuración de secretos por temporada y activa los
# triggers de lore correspondientes en el mundo. Diseño original
# (04-Codigo.md §1.1, TerrenoLoreService.cs).

class_name TerrenoLoreService
extends RefCounted

const RUTA_SECRETOS := "res://data/lore/secretos_temporada.json"

var _secretos: Dictionary = {}  # temporada -> Array[ubicacion_id]

func cargar() -> void:
	if not FileAccess.file_exists(RUTA_SECRETOS):
		push_warning("[M148] Secretos de temporada no encontrados: %s" % RUTA_SECRETOS)
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_SECRETOS))
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	_secretos = parsed

## Activa secretos de la temporada dada. Devuelve Array de ubicaciones activadas.
func activar_temporada(temporada: String) -> Array:
	var ubicaciones: Array = _secretos.get(temporada, [])
	if not ubicaciones.is_empty():
		print("[M148] TerrenoLore: %d secretos activados para %s" % [ubicaciones.size(), temporada])
	return ubicaciones.duplicate()

func a_diccionario() -> Dictionary:
	return _secretos.duplicate(true)