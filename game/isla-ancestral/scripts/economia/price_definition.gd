# Modelo: ox-alpha (Cline)
# Plataforma: Cline
# Fecha: 2026-08-26
#
# M38: PriceDefinition — definición de precio para el catálogo central econ_prices.tres.
# Cada entrada sobreescribe (o inicializa) los precios base que ItemData (M159) expone
# para un item_id. Si el catálogo no tiene una entrada para un ítem, PriceManager
# cae al precio base de ItemData.precio_compra/precio_venta.

class_name PriceDefinition
extends Resource

## ID del objeto (debe coincidir con ItemData.id, M159)
@export var item_id: String = ""

## Precio de compra al NPC (lo que paga el jugador al vender). 0 = no comprable.
@export var precio_compra: int = 0

## Precio de venta al jugador (lo que paga el jugador por comprar). 0 = no vendible.
@export var precio_venta: int = 0

## Banda de rareza usada por el catálogo de rareza M15. String para evitar acoplamiento
## de enum (el catálogo se carga antes que los enums de ItemData pueden no estar).
@export var rareza: String = "comun"

## El ítem puede revenirse (se puede vender de vuelta al jugador). Si false, solo compra.
@export var revendible: bool = true
