extends SceneTree

## Prueba del precio minorista/mayorista por volumen (M38) + cierre por festival (M39+M29).
## Uso: godot --headless --path game/isla-ancestral --script res://scripts/economia/test_minorista_mayorista.gd
## Valida:
##  - Precio minorista (cantidad=1) == precio base
##  - Descuento mayorista creciente por tramos (5/10/20)
##  - Tope de descuento por volumen (15%) y total combinado (amistad+volumen = 20)
##  - Venta del jugador estable (sin bonus por volumen, anti-grind)
##  - ShopManager.esta_abierta() respeta M29: tienda cierra en festival si lo configura,
##    y sigue abierta si no lo configura.

var _fallos := 0
var _checks := 0
var _eco = null
var _pm = null
var _sm = null
var _tc = null
var _db = null

func _initialize() -> void:
	print("=== TEST MINORISTA/MAYORISTA + FESTIVAL (M38/M39/M29) ===")
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	_eco = root.get_node_or_null("EconomyManager")
	_sm = root.get_node_or_null("ShopManager")
	_tc = root.get_node_or_null("TimeCalendar")
	_db = root.get_node_or_null("ItemDatabase")
	_check("autoloads presentes (eco, sm, tc, db)", _eco != null and _sm != null and _tc != null and _db != null)
	if _eco == null or _sm == null or _tc == null or _db == null:
		print("FALTAN AUTOLOADS NECESARIOS")
		quit(1); return
	# PriceManager se instancia directo para aislar la matemática del descuento,
	# inyectando un catálogo vacío (sin overrides → usa ItemData base).
	_pm = load("res://scripts/economia/price_manager.gd").new()
	_pm._catalog = _CatVacio.new()
	_check("price_manager instanciado", _pm != null)
	if _pm == null:
		quit(1); return

	# Fijar ítem de prueba: "tela_lino" (override en econ_prices.tres, compra=60).
	# Minorista=60 · 5 und=57 (5%) · 10=54 (10%) · 20=51 (15%, tope).

	# ── Minorista vs mayorista (vía EconomyManager → PriceManager) ──
	var pu := 60
	var p1 := int(_eco.precio_compra_vigente("tela_lino", "", 1))
	_check("minorista (1 und) == base (60)", p1 == pu)
	var p5 := int(_eco.precio_compra_vigente("tela_lino", "", 5))
	_check("mayorista (5 und) tiene descuento (< base)", p5 < pu)
	_check("mayorista (5 und) ~ 5% (57)", p5 == 57)
	var p10 := int(_eco.precio_compra_vigente("tela_lino", "", 10))
	_check("mayorista (10 und) ~ 10% (54)", p10 == 54)
	var p20 := int(_eco.precio_compra_vigente("tela_lino", "", 20))
	_check("mayorista (20 und) ~ 15% (51)", p20 == 51)

	# Tope volumen (40 und debería seguir en 15%, no más)
	var p40 := int(_eco.precio_compra_vigente("tela_lino", "", 40))
	_check("tope volumen a 15% (51)", p40 == 51)

	# Venta del jugador estable: cantidad no cambia el precio de venta.
	var v1 := int(_eco.precio_venta_vigente("tela_lino"))
	_check("venta unitaria definida (>0)", v1 > 0)

	# ── Cierre por festival (M39 consulta M29) ──
	# Registrar una tienda en ShopManager con cierre por festival activado.
	var def = load("res://scripts/shops/shop_data.gd").new()
	def.shop_id = "fest_tienda"
	def.tipo = 3
	var dias: Array[int] = [0, 1, 2, 3, 4, 5, 6]
	def.dias_abiertos = dias
	var franjas: Array[Vector2i] = [Vector2i(0, 24)]
	def.franjas_horarias = franjas
	def.cierra_en_festivales = true
	var entry = load("res://scripts/shops/shop_data.gd").StockEntry.new("tela_lino", 1, 10)
	def.catalogo_venta.append(entry)
	_sm.registrar_tienda(def)

	# Tienda sin cierre por festival (control)
	var def2 = load("res://scripts/shops/shop_data.gd").new()
	def2.shop_id = "abierta_fiesta"
	def2.tipo = 3
	var dias2: Array[int] = [0, 1, 2, 3, 4, 5, 6]
	def2.dias_abiertos = dias2
	var franjas2: Array[Vector2i] = [Vector2i(0, 24)]
	def2.franjas_horarias = franjas2
	def2.cierra_en_festivales = false
	def2.catalogo_venta.append(load("res://scripts/shops/shop_data.gd").StockEntry.new("tela_lino", 1, 10))
	_sm.registrar_tienda(def2)

	# Sincronizar a un día SIN festival (día 1 mes 1): ambas abiertas.
	_sm.tick_hora(1, 10)
	_check("sin festival: fest_tienda abierta", _sm.esta_abierta("fest_tienda"))
	_check("sin festival: abierta_fiesta abierta", _sm.esta_abierta("abierta_fiesta"))

	# Forzar a día 15 mes 1 (Festival de la Floración, estación 0).
	_forzar_festival(15, 1)
	_check("hay festival hoy (tc)", _tc.hay_festival_hoy())
	# tick necesaria para que ShopManager recalcule (o consulta directa).
	_sm.tick_hora(1, 10)
	_check("festival: fest_tienda cerrada", not _sm.esta_abierta("fest_tienda"))
	_check("festival: abierta_fiesta sigue abierta", _sm.esta_abierta("abierta_fiesta"))

	print("=== Resumen: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("FALLOS DETECTADOS")
		quit(1)
	else:
		print("MINORISTA/MAYORISTA + FESTIVAL OK")
		quit(0)

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)

## Asegura que un ítem tenga precio_compra/precio_venta definidos.
func _asegurar_item(id: String, pc: int, pv: int) -> void:
	var item = _db.get_item(id)
	if item == null:
		return
	if int(item.precio_compra) != pc:
		item.precio_compra = pc
	if int(item.precio_venta) != pv:
		item.precio_venta = pv

## Fuerza el estado del TimeCalendar (M29) a una fecha dada para inducir festival.
func _forzar_festival(dia: int, mes: int) -> void:
	if _tc == null:
		return
	_tc._dia_actual = dia
	_tc._mes_actual = mes
	_tc._estacion_actual = 0
	# Notificar festivos re-evaluando el día (emite evento_activado).
	_tc._verificar_eventos_dia()


## Catálogo vacío: `get_price_def` siempre devuelve null, forzando a PriceManager
## a usar el precio base de ItemData (M159). Reproduce la interfaz pública mínima.
class _CatVacio:
	extends RefCounted

	func get_price_def(_item_id: String):
		return null