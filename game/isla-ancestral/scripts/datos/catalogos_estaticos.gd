# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M60: Datos y Serialización — CatalogosEstaticos
# Datos estáticos del juego (M15 items, M16 recetas, M33 cultivos) como
# Resources .tres en res://data/ (D2). Carga única al arranque (cache de
# Godot), acceso por ID estable (D8). Fallback limpio: si falta un catálogo
# o un .tres, log + tabla vacía, nunca crash (RN: build sin asssets).

class_name CatalogosEstaticos
extends RefCounted

## Directorio de catálogos de items (M159 ya genera .tres aquí).
const RUTA_ITEMS: String = "res://data/items"

## Catálogo de items: id -> ItemData.
static var items: Dictionary = {}

## true si ya se intentó cargar (evita recargas en cada llamada).
static var _cargado: bool = false

## Carga única de los catálogos al arranque. Idempotente.
static func cargar() -> void:
	if _cargado:
		return
	_cargado = true
	_cargar_items()

static func _cargar_items() -> void:
	var dir := DirAccess.open(RUTA_ITEMS)
	if dir == null:
		push_warning("[M60] Catálogo de items no encontrado: %s (tabla vacía)" % RUTA_ITEMS)
		return
	var count := 0
	for nombre in dir.get_files():
		if not nombre.ends_with(".tres"):
			continue
		var path := "%s/%s" % [RUTA_ITEMS, nombre]
		var res: Resource = load(path)
		if res == null:
			push_warning("[M60] No se pudo cargar item: %s (omitido)" % path)
			continue
		var item_id: Variant = res.get("id")
		if typeof(item_id) != TYPE_STRING or String(item_id) == "":
			push_warning("[M60] Item sin id: %s (omitido)" % path)
			continue
		items[item_id] = res
		count += 1
	if count > 0:
		print("[M60] Items estáticos cargados: %d" % count)

## Acceso por ID estable tipo "wood". null si no existe (validar en caller).
static func obtener_item(id: String) -> Resource:
	if not _cargado:
		cargar()
	return items.get(id, null)

## true si un id de item existe en el catálogo.
static func tiene_item(id: String) -> bool:
	if not _cargado:
		cargar()
	return items.has(id)

## Cantidad de items cargados (para debug/QA).
static func contar_items() -> int:
	if not _cargado:
		cargar()
	return items.size()