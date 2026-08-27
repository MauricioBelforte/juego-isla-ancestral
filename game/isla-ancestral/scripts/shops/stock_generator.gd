# Modelo: ox-alpha
# Plataforma: Cline
# Fecha: 2026-08-25
#
# M39: Tiendas — StockGenerator (canalización determinista)
# base → estación → eventos → aforo → PRNG (03-Diseno §1/§8).
# Corre SOLO en cambios de día/estación/evento, jamás por frame.
extends RefCounted

const SHOP_DATA_SCRIPT := preload("res://scripts/shops/shop_data.gd")

## Contexto de canalización (lo provee ShopManager en cada restock)
class Contexto:
	var estacion: int = -1          # M29 (-1 = sin calendario aún)
	var eventos_activos: Array[String] = []  # M73
	var dia_laborable: int = 0

## Genera stock inicial para una tienda según su catálogo
func generar_stock_inicial(definicion: Resource, prng: RandomNumberGenerator) -> Dictionary:
	return _generar(definicion, prng, Contexto.new(), true)

## Reabastecimiento diario: suma restock_diario repartido, sin exceder stock_max
func reabastecer_diario(shop: RefCounted, prng: RandomNumberGenerator, ctx: Contexto) -> void:
	if shop == null or shop.definicion == null:
		return
	var def: Resource = shop.definicion
	var presupuesto: int = def.restock_diario
	# Reparte el presupuesto entre ítems del catálogo con stock bajo primero
	var ordenados := _catalogo_ordenado_por_falta(def, shop.stock_actual)
	for entrada in ordenados:
		if presupuesto <= 0:
			break
		var falta: int = int(entrada.stock_max) - int(shop.stock_actual.get(entrada.item_id, 0))
		if falta <= 0:
			continue
		var cantidad: int = mini(falta, presupuesto)
		# PRNG decide cuánto de ese tope entra hoy (determinista por semilla)
		cantidad = mini(cantidad, prng.randi_range(1, maxi(1, cantidad)))
		if entrada.es_basico and int(shop.stock_actual.get(entrada.item_id, 0)) < int(entrada.stock_min):
			cantidad = maxi(cantidad, mini(int(entrada.stock_min) - int(shop.stock_actual.get(entrada.item_id, 0)), falta))
		shop.stock_actual[entrada.item_id] = int(shop.stock_actual.get(entrada.item_id, 0)) + cantidad
		presupuesto -= cantidad
	shop.fecha_ultimo_restock = ctx.dia_laborable

## ¿Aparece el mercader viajero hoy? (determinista por PRNG de partida)
func aparece_mercader_hoy(definicion: Resource, prng: RandomNumberGenerator) -> bool:
	if definicion == null or definicion.dias_aparicion_mercader <= 0:
		return false
	return prng.randi() % definicion.dias_aparicion_mercader == 0

# ── Internos ──────────────────────────────────────────────

func _generar(definicion: Resource, prng: RandomNumberGenerator, ctx: Contexto, es_inicial: bool) -> Dictionary:
	var resultado: Dictionary = {}
	for entrada in definicion.catalogo_venta:
		var minimo := int(entrada.stock_min)
		var maximo := int(entrada.stock_max)
		# Canal 2: estación — rotación fuerte reduce ítems fuera de estación (placeholder M29)
		if def_es_rotacion_fuerte(definicion) and not entrada.es_basico:
			maximo = maxi(minimo, maximo / 2)
		# Canal 3: eventos — placeholder M73 (los eventos activos amplían max en futuro)
		# Canal 4: rareza — aforo por peso de rareza
		var techo_rareza := int(round(float(maximo) / maxf(1.0, entrada.peso_rareza)))
		techo_rareza = clampi(techo_rareza, minimo, maximo)
		# Canal 5: PRNG determinista de partida
		var cantidad := prng.randi_range(minimo, techo_rareza)
		if entrada.es_basico:
			cantidad = maxi(cantidad, minimo)  # básicos garantizan stock_min >= 1 (§8)
		resultado[entrada.item_id] = cantidad
	return resultado

func def_es_rotacion_fuerte(definicion: Resource) -> bool:
	return definicion.rotacion_estacional_fuerte

func _catalogo_ordenado_por_falta(def: Resource, stock: Dictionary) -> Array:
	var lista: Array = []
	for e in def.catalogo_venta:
		lista.append(e)
	lista.sort_custom(func(a, b):
		var fa := int(a.stock_max) - int(stock.get(a.item_id, 0))
		var fb := int(b.stock_max) - int(stock.get(b.item_id, 0))
		return fa > fb)
	return lista
