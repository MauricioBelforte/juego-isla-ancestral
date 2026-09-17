# Modelo: ox-alpha (Cline)
# Plataforma: Cline
# Fecha: 2026-08-26
#
# M38: EconomyPriceCatalog — catálogo central de precios (econ_prices.tres).
# Resource cargado bajo demanda y cacheado. PriceManager consulta los overrides
# de aquí antes de caer al ItemData base (M159). Diseñado para no acoplarse a autoloads.

class_name EconomyPriceCatalog
extends Resource

## Ruta canónica del recurso de datos (ver plan-actual/04-Codigo.md §1.2)
const CATALOG_PATH: String = "res://data/economy/econ_prices.tres"

## Entradas del catálogo (Array de PriceDefinition). Tipado como Array genérico
## para evitar "Could not resolve external class" en runtime headless (class_name
## externo no se registra fuera del árbol de escenas activo).
@export var price_overrides: Array = []

# Cache estático de la instancia cargada (ResourceLoader ya cachea, pero reforzamos).
static var _instance: EconomyPriceCatalog = null

# L.1 (iter 5, GLM-5.3 / Kilo Code — Log 822): índice O(1) item_id → PriceDefinition.
# Se construye UNA vez al resolver el catálogo; get_price_def pasa de O(n) por
# consulta a O(1) — cada cálculo de precio consulta 2-3 veces (base, rareza,
# temporada, variabilidad) y el catálogo crece con el contenido real.
var _indice: Dictionary = {}

## Cachea y devuelve la instancia única del catálogo.
static func get_catalog() -> EconomyPriceCatalog:
	if _instance == null:
		_instance = load(CATALOG_PATH) as EconomyPriceCatalog
		if _instance == null:
			push_warning("M38: econ_prices.tres no existe o no cargó; sin overrides, precios base de ItemData.")
	if _instance != null and _instance._indice.is_empty() and not _instance.price_overrides.is_empty():
		_instance._construir_indice()
	return _instance

## Reconstruye el índice item_id → definición (idempotente).
func _construir_indice() -> void:
	_indice.clear()
	for e in price_overrides:
		if e != null and str(e.item_id) != "":
			_indice[str(e.item_id)] = e

## Validación en carga: la venta nunca debe superar o igualar la compra.
func _validate() -> bool:
	for e in price_overrides:
		if e.precio_venta >= e.precio_compra and e.precio_compra > 0:
			push_error("M38: override '%s' -> venta (%d) >= compra (%d). Revise econ_prices.tres." % [e.item_id, e.precio_venta, e.precio_compra])
	return true

## Lookup por item_id. Devuelve la PriceDefinition o null si no hay override.
## L.1 (iter 5): O(1) vía _indice; fallback lineal solo si el índice está vacío
## (defensivo ante asignaciones externas de price_overrides sin reconstruir).
func get_price_def(item_id: String) -> PriceDefinition:
	if item_id == "":
		return null
	if _indice.has(item_id):
		return _indice[item_id]
	if _indice.is_empty() and not price_overrides.is_empty():
		_construir_indice()
		return _indice.get(item_id, null)
	return null
