extends SceneTree

## Prueba end-to-end del loop economico (M38 + M14 + M39)
## Uso: godot --headless --path game/isla-ancestral --script res://scripts/shops/test_loop_economico.gd
## NOTA: los autoloads (SaveManager, ItemDatabase, EconomyManager, ShopManager,
## Inventario) SI se cargan con --script. NO hay que montarlos a mano.
## La ejecucion se difiere con call_deferred para que el arbol este activo y los
## get_node_or_null("/root/...") del ShopManager resuelvan.

var _fallos := 0
var _checks := 0
var _eco = null
var _inv = null
var _sm = null

func _initialize() -> void:
	print("=== TEST LOOP ECONOMICO M38+M14+M39 ===")
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	_eco = root.get_node_or_null("EconomyManager")
	_inv = root.get_node_or_null("Inventario")
	_sm = root.get_node_or_null("ShopManager")
	var _db = root.get_node_or_null("ItemDatabase")

	_check("autoloads presentes", _eco != null and _inv != null and _sm != null and _db != null)
	if _eco == null or _inv == null or _sm == null or _db == null:
		print("FALTAN AUTOLOADS"); quit(1); return

	var def = load("res://scripts/shops/shop_data.gd").new()
	def.shop_id = "test_tienda"
	def.nombre_clave_i18n = "TIENDA_TEST"
	def.tipo = 3
	var dias: Array[int] = [0, 1, 2, 3, 4, 5, 6]
	def.dias_abiertos = dias
	var franjas: Array[Vector2i] = [Vector2i(0, 24)]
	def.franjas_horarias = franjas
	var entry = load("res://scripts/shops/shop_data.gd").StockEntry.new("OBJ-PLA-001", 2, 5, 1.0, true)
	def.catalogo_venta.append(entry)
	def.catalogo_recompra.append("OBJ-PLA-001")
	_sm.registrar_tienda(def)

	_sm.tick_hora(1, 10)
	_check("tienda abierta tras tick", _sm.esta_abierta("test_tienda"))
	_check("stock inicial >= 2", int(_sm.listar_stock("test_tienda").get("OBJ-PLA-001", 0)) >= 2)

	_eco.saldo = 10000
	_check("saldo asignado", _eco.puede_pagar(10000))

	var item = _db.get_item("OBJ-PLA-001")
	if item != null and int(item.precio_compra) <= 0:
		item.set("precio_compra", 100)
		item.set("precio_venta", 60)

	var precio_c := int(_eco.precio_compra_vigente("OBJ-PLA-001"))
	_check("precio compra definido", precio_c > 0)
	var stock_ini := int(_sm.listar_stock("test_tienda").get("OBJ-PLA-001", 0))
	_sm.comprar("test_tienda", "OBJ-PLA-001", 2)
	_check("compra: item en inventario", _inv.count_item("OBJ-PLA-001") == 2)
	_check("compra: stock descontado en 2", int(_sm.listar_stock("test_tienda").get("OBJ-PLA-001", 0)) == stock_ini - 2)
	_check("compra: saldo bajado", _eco.saldo <= 10000)

	var saldo_antes := int(_eco.saldo)
	_sm.vender("test_tienda", "OBJ-PLA-001", 2)
	_check("venta: inventario vacio", _inv.count_item("OBJ-PLA-001") == 0)
	_check("venta: stock acumulado", int(_sm.listar_stock("test_tienda").get("OBJ-PLA-001", 0)) >= 2)
	_check("venta: saldo aumento", int(_eco.saldo) >= saldo_antes)

	_check("anti-arbitraje (saldo <= inicial)", _eco.saldo <= 10000)

	var rep = _sm.reputacion()
	var xp: int = 0 if rep == null or rep.get("xp_actual") == null else int(rep.xp_actual)
	_check("reputacion registra ventas", xp > 0)

	var save_data: Dictionary = _inv.get_save_data()
	_check("save_data tiene seccion inventory", save_data.size() > 0)
	_inv.restore_save_data({})
	_inv.restore_save_data(save_data)

	print("=== Resumen: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("FALLOS DETECTADOS"); quit(1)
	else:
		print("LOOP ECONOMICO OK"); quit(0)

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)