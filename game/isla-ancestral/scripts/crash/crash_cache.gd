# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-25
#
# M122: Crash Reporting — CrashCache (caché offline, helper reutilizable/headless).
# Implementa el servicio "CrashCache" del diseño (03-Diseno.md §5), que quedó `[ ]`:
#   save_crash          -> guardar
#   load_cached_crashes -> cargar
#   clear_cache         -> limpiar
#   MAX_CACHE_SIZE = 10 -> MAX_CACHE_SIZE (const, mismo valor)
# RefCounted sin `class_name` (preload).
#
# Desviaciones del diseño (04-Codigo.md §15):
#   - El diseño usaba `store_var`/`get_var` (formato binario opaco). Se usa JSON: es auditable,
#     portable y sobrevive a cambios de versión del motor.
#   - `save_crash` del diseño devolvía `void` y silenciaba el fallo de escritura -> acá `guardar`
#     devuelve bool (fail-closed: el llamador se entera si NO se pudo cachear).
#   - El diseño usaba `pop_front()` una vez (solo quitaba 1 si el límite ya estaba excedido) ->
#     acá es un `while` (defensivo si el archivo quedó por encima del límite).
#
# ⚠️ Usa `FileAccess`, NO `DirAccess`: `DirAccess.open("user://...")` devuelve null en headless
# (pitfall §9.6, medido). `FileAccess` funciona con `user://` sin problema.

extends RefCounted

const ARCHIVO := "user://crash_cache.json"
const MAX_CACHE_SIZE := 10


## Agrega un crash a la caché, respetando el límite (FIFO). Devuelve false si no pudo escribir.
func guardar(datos: Dictionary) -> bool:
	var cache := cargar()
	cache.append(datos)
	while cache.size() > MAX_CACHE_SIZE:
		cache.pop_front()
	return _escribir(cache)


## Crashes cacheados (Array de Dictionary). Array vacío si no hay archivo o está corrupto.
func cargar() -> Array:
	if not FileAccess.file_exists(ARCHIVO):
		return []
	var texto := FileAccess.get_file_as_string(ARCHIVO)
	if texto.strip_edges().is_empty():
		return []
	var parsed: Variant = JSON.parse_string(texto)
	if typeof(parsed) != TYPE_ARRAY:
		return []
	var out: Array = parsed
	return out


## Vacía la caché. Devuelve false si no pudo escribir.
func limpiar() -> bool:
	return _escribir([])


func cantidad() -> int:
	return cargar().size()


func archivo_existe() -> bool:
	return FileAccess.file_exists(ARCHIVO)


func _escribir(cache: Array) -> bool:
	var f := FileAccess.open(ARCHIVO, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(cache))
	f.close()
	return true
