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

## L184/L232/L25/L26 (iter. glm, Log 1004): validación DURA de las tiendas
## oficiales (boot/editor). Devuelve la lista de ERRORES (bloquean el registro).
## El mercader viajero es la excepción legítima: no tiene dueño fijo, pero DEBE
## tener calendario de aparición. La existencia en M15 (ItemDatabase) se valida
## como AVISO (push_warning): el orden de autoloads no garantiza el DB en el boot.
func _validar_tienda(def: Resource) -> Array[String]:
	var errores: Array[String] = []
	if def == null:
		return ["definición nula"]
	if String(def.shop_id) == "":
		errores.append("sin shop_id")
	var es_mercader := int(def.tipo) == int(SHOP_SCRIPT.Tipo.MERCADER_VIAJERO)
	if String(def.npc_duenio_id) == "" and not es_mercader:
		errores.append("sin npc_duenio_id (tienda fija requiere dueño M19)")
	if es_mercader and int(def.dias_aparicion_mercader) <= 0:
		errores.append("mercader sin calendario de aparición (dias_aparicion_mercader <= 0)")
	if def.catalogo_venta.is_empty():
		errores.append("catálogo de venta vacío")
	if def.franjas_horarias.is_empty() or def.dias_abiertos.is_empty():
		errores.append("horario incompleto (días o franjas vacías)")
	# L26: sin ítems duplicados dentro del mismo catálogo
	var vistos := {}
	for entrada in def.catalogo_venta:
		var eid := String(entrada.item_id)
		if vistos.has(eid):
			errores.append("ítem duplicado en catálogo: %s" % eid)
		vistos[eid] = true
	# L25: cada item_id debe existir en M15 — AVISO (no bloquea el boot)
	var db = get_node_or_null("/root/ItemDatabase")
	if db != null and db.has_method("get_item"):
		for entrada2 in def.catalogo_venta:
			if db.get_item(String(entrada2.item_id)) == null:
				push_warning("[M39] '%s': item_id inexistente en M15: %s" % [String(def.shop_id), String(entrada2.item_id)])
	return errores

## Registro con validación dura: una tienda oficial inválida NO se registra.
func _registrar_validada(sm, def: Resource) -> void:
	var problemas := _validar_tienda(def)
	if not problemas.is_empty():
		for p in problemas:
			push_error("[M39] Catálogo '%s': %s" % [String(def.shop_id), p])
		return
	sm.registrar_tienda(def)

func _nueva_tienda(id: String, nombre_clave: String, tipo: int, npc_id: String) -> Resource:
	var def = SHOP_SCRIPT.new()
	def.shop_id = id
	def.nombre_clave_i18n = nombre_clave
	def.tipo = tipo
	def.npc_duenio_id = npc_id
	# Fix iter. glm (Log 1004): la convención M29/shop.gd es 0=domingo..6=sábado;
	# el viejo [1..7] incluía el día 7, que NUNCA existe (día muerto en consulta).
	var dias: Array[int] = [0, 1, 2, 3, 4, 5, 6]
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
		# M16 RF14 (glm-5.3-flash): pergaminos de receta (origen "compra" en
		# balance/crafting.json) — usar_item → Crafting.usar_pergamino aprende
		# la receta. Stock limitado 1 por día (recompensa de progresión cozy).
		_entry("pergamino_rec_tela_lino", 1, 1, 2.0, false),
	]
	var recompra_g: Array[String] = [
		"madera_roble", "piedra_caliza", "baya_roja", "fibra_algodon",
		"mineral_cobre", "fragmento_ancestral",
	]
	def.catalogo_recompra = recompra_g
	def.restock_diario = 8
	_registrar_validada(sm, def)

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
	_registrar_validada(sm, def)

## ── Tienda 3: Mercader viajero (rodante, rara, con recargo) ──

func _registrar_mercader_viajero(sm) -> void:
	var def = _nueva_tienda("mercader_viajero", "TIENDAS.VIAJERO", SHOP_SCRIPT.Tipo.MERCADER_VIAJERO, "")
	def.dias_abiertos = ([0, 1, 2, 3, 4, 5, 6] as Array[int])
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
	_registrar_validada(sm, def)
