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

## Entradas del catálogo (Array de PriceDefinition)
@export var price_overrides: Array[PriceDefinition] = []

# Cache estático de la instancia cargada (ResourceLoader ya cachea, pero reforzamos).
static var _instance: EconomyPriceCatalog = null

## Cachea y devuelve la instancia única del catálogo.
static func get_catalog() -> EconomyPriceCatalog:
	if _instance == null:
		_instance = load(CATALOG_PATH) as EconomyPriceCatalog
		if _instance == null:
			push_warning("M38: econ_prices.tres no existe o no cargó; sin overrides, precios base de ItemData.")
	return _instance

## Validación en carga: la venta nunca debe superar o igualar la compra.
func _validate() -> bool:
	for e in price_overrides:
		if e.precio_venta >= e.precio_compra and e.precio_compra > 0:
			push_error("M38: override '%s' -> venta (%d) >= compra (%d). Revise econ_prices.tres." % [e.item_id, e.precio_venta, e.precio_compra])
	return true

## Lookup por item_id. Devuelve la PriceDefinition o null si no hay override.
func get_price_def(item_id: String) -> PriceDefinition:
	if item_id == "":
		return null
	for e in price_overrides:
		if e.item_id == item_id:
			return e
	return null
