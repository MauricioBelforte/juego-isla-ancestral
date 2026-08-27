# Modelo: ox-alpha
# Plataforma: Cline
# Fecha: 2026-08-25
#
# M39: Tiendas — Shop (estado runtime de UNA tienda)
# Contiene el stock actual mutable y las consultas puras (horario).
# Los precios NUNCA se calculan aquí: se delegan a M38 vía ShopManager.
extends RefCounted

const SHOP_DATA_SCRIPT := preload("res://scripts/shops/shop_data.gd")

var definicion: Resource = null                  # ShopData
var stock_actual: Dictionary = {}                # {item_id: int} — O(1)
var fecha_ultimo_restock: int = -1               # día laborable del último restock
var abierta_ahora: bool = false                  # cacheado por ShopManager en cada tick horario

func _init(p_def: Resource = null) -> void:
	definicion = p_def

## Genera el stock inicial desde el catálogo (delega cantidades al generador)
func inicializar_stock(generator: RefCounted, prng: RandomNumberGenerator) -> void:
	stock_actual.clear()
	if definicion == null or generator == null:
		return
	stock_actual = generator.generar_stock_inicial(definicion, prng)

## ¿Puede vender `cantidad` unidades de item_id?
func tiene_stock(item_id: String, cantidad: int = 1) -> bool:
	return int(stock_actual.get(item_id, 0)) >= cantidad

## Descuenta stock (llamar SOLO dentro de transacción validada)
func remover_stock(item_id: String, cantidad: int) -> void:
	var actual := int(stock_actual.get(item_id, 0))
	stock_actual[item_id] = maxi(0, actual - cantidad)

## La tienda acumula lo que le compra al jugador (D3)
func acumular_stock(item_id: String, cantidad: int, stock_max_cap: int = 999) -> void:
	if not definicion.catalogo_recompra.has(item_id):
		return
	var nuevo := int(stock_actual.get(item_id, 0)) + cantidad
	stock_actual[item_id] = mini(nuevo, stock_max_cap)

## Consulta pura de horario — aritmética sin alocación (Optimización §7)
## dia_semana: 0=domingo..6=sábado ; hora: 0..23
func esta_abierta(dia_semana: int, hora: int) -> bool:
	if definicion == null:
		return false
	if dia_semana in definicion.dias_descanso:
		return false
	if definicion.descanso_semanal >= 0 and dia_semana == definicion.descanso_semanal:
		return false
	if not (dia_semana in definicion.dias_abiertos):
		return false
	for franja in definicion.franjas_horarias:
		if hora >= franja.x and hora < franja.y:
			return true
	return false

func serializar() -> Dictionary:
	return {
		"shop_id": definicion.shop_id if definicion != null else "",
		"stock": stock_actual.duplicate(),
		"ultimo_restock": fecha_ultimo_restock,
	}

func deserializar(d: Dictionary) -> void:
	stock_actual = {}
	var stock_guardado: Dictionary = d.get("stock", {})
	for k in stock_guardado:
		stock_actual[str(k)] = int(stock_guardado[k])
	fecha_ultimo_restock = int(d.get("ultimo_restock", -1))
