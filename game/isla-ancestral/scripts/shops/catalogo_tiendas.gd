# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-31
#
# M39: Tiendas — CatalogoTiendas (catálogos DEFINITIVOS del prototipo).
# Construye las ShopData oficiales y las registra en el ShopManager al arrancar.
# Diseño M39 §1: tienda general (aldea), herrería, mercader viajero (rodante).
# Los precios los calcula M38 (PriceManager) en runtime; aquí solo catálogo + stock.
# NOTA: data-driven en código (consistente con M93/M15/M16); migración a .tres
# opcional cuando exista el editor de catálogos (M108).

extends Node

const SHOP_SCRIPT := preload("res://scripts/shops/shop_data.gd")

func _ready() -> void:
	# Registro sincrónico: los autoloads previos (ShopManager M39, Balance M93,
	# EconomyManager M38) ya inicializaron (orden de project.godot).
	_registrar_tiendas_oficiales()

func _registrar_tiendas_oficiales() -> void:
	var sm = get_node_or_null("/root/ShopManager")
	if sm == null or not sm.has_method("registrar_tienda"):
		push_warning("[M39] ShopManager no disponible")
		return
	_registrar_tienda_general(sm)
	_registrar_herreria(sm)
	_registrar_mercader_viajero(sm)
	print("[M39] Catálogos definitivos registrados: tienda_general, herreria, mercader_viajero")

func _nueva_tienda(id: String, nombre_clave: String, tipo: int, npc_id: String) -> Resource:
	var def = SHOP_SCRIPT.new()
	def.shop_id = id
	def.nombre_clave_i18n = nombre_clave
	def.tipo = tipo
	def.npc_duenio_id = npc_id
	var dias: Array[int] = [1, 2, 3, 4, 5, 6, 7]
	def.dias_abiertos = dias
	var franjas: Array[Vector2i] = [Vector2i(8, 18)]
	def.franjas_horarias = franjas
	return def

func _entry(item_id: String, cant_min: int, cant_max: int, rareza: float, basico: bool):
	return SHOP_SCRIPT.StockEntry.new(item_id, cant_min, cant_max, rareza, basico)

## ── Tienda 1: General de la aldea (básicos de supervivencia) ──

func _registrar_tienda_general(sm) -> void:
	var def = _nueva_tienda("tienda_general", "TIENDAS.GENERAL", SHOP_SCRIPT.Tipo.TIENDA_GENERAL, "catalina")
	def.dias_abiertos = ([1, 2, 3, 4, 5, 6] as Array[int])
	var franja_g: Array[Vector2i] = [Vector2i(8, 20)]
	def.franjas_horarias = franja_g
	def.catalogo_venta = [
		_entry("madera_roble", 5, 15, 1.0, true),
		_entry("piedra_caliza", 5, 12, 1.0, true),
		_entry("baya_roja", 3, 10, 1.0, true),
		_entry("fibra_algodon", 3, 8, 1.2, false),
		_entry("mineral_cobre", 1, 4, 2.0, false),
	]
	var recompra_g: Array[String] = [
		"madera_roble", "piedra_caliza", "baya_roja", "fibra_algodon",
		"mineral_cobre", "fragmento_ancestral",
	]
	def.catalogo_recompra = recompra_g
	def.restock_diario = 8
	sm.registrar_tienda(def)

## ── Tienda 2: Herrería (herramientas y metal) ────────────

func _registrar_herreria(sm) -> void:
	var def = _nueva_tienda("herreria", "TIENDAS.HERRERIA", SHOP_SCRIPT.Tipo.FERRETERIA, "catalina")
	def.dias_abiertos = ([1, 2, 3, 4, 5] as Array[int])
	var franja_h: Array[Vector2i] = [Vector2i(9, 17)]
	def.franjas_horarias = franja_h
	def.dias_descanso = [] as Array[int]  # descanso semanal: día 6/7 según calendario M29
	def.catalogo_venta = [
		_entry("herramienta_basica", 1, 3, 1.0, true),
		_entry("mineral_cobre", 2, 6, 1.5, true),
	]
	var recompra_h: Array[String] = ["mineral_cobre", "piedra_caliza"]
	def.catalogo_recompra = recompra_h
	def.restock_diario = 4
	sm.registrar_tienda(def)

## ── Tienda 3: Mercader viajero (rodante, rara, con recargo) ──

func _registrar_mercader_viajero(sm) -> void:
	var def = _nueva_tienda("mercader_viajero", "TIENDAS.VIAJERO", SHOP_SCRIPT.Tipo.MERCADER_VIAJERO, "")
	def.dias_abiertos = ([1, 2, 3, 4, 5, 6, 7] as Array[int])
	var franja_m: Array[Vector2i] = [Vector2i(0, 24)]
	def.franjas_horarias = franja_m  # mientras está activo, siempre
	def.dias_aparicion_mercader = 3           # aparece 1 de cada 3 días (PRNG)
	def.recargo_mercader_pct = 12.0
	def.catalogo_venta = [
		_entry("fragmento_ancestral", 1, 2, 3.0, false),
		_entry("baya_roja", 5, 12, 1.0, true),
		_entry("mineral_cobre", 2, 5, 1.5, false),
	]
	var recompra_m: Array[String] = [
		"fragmento_ancestral", "mineral_cobre", "madera_roble", "baya_roja",
	]
	def.catalogo_recompra = recompra_m
	def.restock_diario = 3
	def.rotacion_estacional_fuerte = false
	sm.registrar_tienda(def)
