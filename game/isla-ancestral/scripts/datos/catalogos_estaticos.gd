# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# ── iter. 3: carga perezosa de catálogos (T-201) ──────────────────
# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-11
# Antes, `cargar()` hacía `load()` de los 111 .tres al arrancar. Ahora arma un
# ÍNDICE barato (id -> ruta, leyendo nombres de archivo, sin tocar disco de
# assets) y solo carga el Resource cuando `obtener_item(id)` lo pide. El id del
# catálogo coincide con el nombre del archivo (verificado: wood.tres -> id
# "wood"), así que el índice no necesita abrir los .tres.
#
# ── iter. 4 ───────────────────────────────────────────────────────────────
# Modelo: DeepSeek-V4.1-Flash · Plataforma: WorkBuddy · Fecha: 2026-09-15
# Se agregó `validar_ids(ids)`: contrasta los ids referenciados (código, save,
# recetas) contra el catálogo y devuelve los que faltan, sin cargar Resources.
#
# M60: Datos y Serialización — CatalogosEstaticos
# Datos estáticos del juego (M15 items, M16 recetas, M33 cultivos) como
# Resources .tres en res://data/ (D2). Acceso por ID estable (D8). Fallback
# limpio: si falta un catálogo o un .tres, log + tabla vacía, nunca crash
# (RN: build sin assets).

class_name CatalogosEstaticos
extends RefCounted

## Directorio de catálogos de items (M159 ya genera .tres aquí).
const RUTA_ITEMS: String = "res://data/items"

## Caché de Resources ya cargados: id -> ItemData.
static var items: Dictionary = {}

## Índice id -> ruta de archivo (se arma sin cargar los Resources).
static var _indice: Dictionary = {}

## true si ya se armó el índice (evita re-escanear en cada llamada).
static var _cargado: bool = false

## Arma el ÍNDICE de catálogos (idempotente). NO carga los Resources:
## eso ocurre bajo demanda en `obtener_item()`. Conserva el nombre por
## compatibilidad con los consumidores existentes.
static func cargar() -> void:
	if _cargado:
		return
	_cargado = true
	_indexar_items()

static func _indexar_items() -> void:
	var dir := DirAccess.open(RUTA_ITEMS)
	if dir == null:
		push_warning("[M60] Catálogo de items no encontrado: %s (tabla vacía)" % RUTA_ITEMS)
		return
	var count := 0
	for nombre in dir.get_files():
		if not nombre.ends_with(".tres"):
			continue
		# El id del catálogo es el nombre del archivo sin extensión (D8).
		var id := nombre.get_basename()
		if id == "":
			continue
		_indice[id] = "%s/%s" % [RUTA_ITEMS, nombre]
		count += 1
	if count > 0:
		print("[M60] Índice de items armado: %d entradas (carga perezosa)" % count)

## Carga (y cachea) el Resource de un id. null si no existe o falla.
static func _cargar_item(id: String) -> Resource:
	if items.has(id):
		return items[id]
	if not _cargado:
		cargar()
	if not _indice.has(id):
		return null
	var ruta: String = _indice[id]
	var res: Resource = load(ruta)
	if res == null:
		push_warning("[M60] No se pudo cargar item: %s (omitido)" % ruta)
		return null
	# El id declarado dentro del .tres manda; el nombre de archivo es el índice.
	var declarado: Variant = res.get("id")
	if typeof(declarado) != TYPE_STRING or String(declarado) == "":
		push_warning("[M60] Item sin id declarado: %s (se usa el nombre de archivo)" % ruta)
	items[id] = res
	return res

## Acceso por ID estable tipo "wood". null si no existe (validar en caller).
## Carga el .tres la primera vez (carga perezosa, T-201).
static func obtener_item(id: String) -> Resource:
	if items.has(id):
		return items[id]
	return _cargar_item(id)

## true si un id de item existe en el catálogo (sin cargarlo).
static func tiene_item(id: String) -> bool:
	if items.has(id):
		return true
	if not _cargado:
		cargar()
	return _indice.has(id)

## Cantidad de items DISPONIBLES (índice). No fuerza la carga.
static func contar_items() -> int:
	if not _cargado:
		cargar()
	return _indice.size()

## Cantidad de items ya cargados en memoria (diagnóstico de la carga perezosa).
static func contar_cargados() -> int:
	return items.size()

## Fuerza la carga de TODO el catálogo (QA / precalentamiento opcional).
## Devuelve cuántos Resources quedaron en memoria.
static func cargar_todos() -> int:
	if not _cargado:
		cargar()
	for id in _indice.keys():
		_cargar_item(String(id))
	return items.size()

## Rutas del índice (diagnóstico; no carga nada).
static func rutas_indexadas() -> Array:
	if not _cargado:
		cargar()
	return _indice.values()

## iter. 4 (ítem 143): valida una lista de ids REFERENCIADOS (por código, por
## save o por recetas) contra el catálogo real. Devuelve los ids que NO existen
## en el orden recibido — vacío = todos válidos. No carga Resources (usa el
## índice), así que es barato llamarlo en QA o al arrancar.
static func validar_ids(ids: Array) -> Array[String]:
	var faltantes: Array[String] = []
	for id in ids:
		var sid := String(id)
		if sid != "" and not tiene_item(sid):
			faltantes.append(sid)
	return faltantes

## Resetea índice y caché (solo tests).
static func _reset_para_test() -> void:
	_indice.clear()
	items.clear()
	_cargado = false
