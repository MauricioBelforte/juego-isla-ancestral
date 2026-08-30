extends "res://addons/gdUnit4/src/GdUnitTestSuite.gd"

## Integration tests: Inventario + Economía (M14 + M38)
## Verifica la interacción entre inventario y sistema económico
##
## InventarioService es un autoload sin class_name (Node).
## EconomyManager es un autoload sin class_name (Node).

const ECONOMY_SCRIPT := preload("res://scripts/economia/economy_manager.gd")
const INVENTARIO_SCRIPT := preload("res://scripts/inventario/inventario_service.gd")

var _inventario
var _economy

func before_test() -> void:
	_inventario = INVENTARIO_SCRIPT.new()
	_inventario._ready()
	_economy = ECONOMY_SCRIPT.new()
	_economy._asegurar_precios()

func after_test() -> void:
	if _inventario != null:
		_inventario.free()
		_inventario = null
	if _economy != null:
		_economy.free()
		_economy = null

func test_comprar_item() -> void:
	var precio = 50
	var item_id = "madera"

	assert_that(_economy.puede_pagar(precio)).is_true()

	var ok_retiro = _economy.retirar_monedas(precio)
	assert_that(ok_retiro).is_true()
	assert_that(_economy.saldo).is_equal_to(50)

	var restante = _inventario.add_item(item_id, 1)
	assert_that(restante).is_equal_to(0)
	assert_that(_inventario.count_item(item_id)).is_equal_to(1)

func test_vender_item() -> void:
	var item_id = "piedra"
	var precio_venta = 10

	_inventario.add_item(item_id, 5)
	assert_that(_inventario.count_item(item_id)).is_equal_to(5)

	var ok_remover = _inventario.remove_item(item_id, 3)
	assert_that(ok_remover).is_true()
	assert_that(_inventario.count_item(item_id)).is_equal_to(2)

	var total_venta = precio_venta * 3
	var ok_deposito = _economy.depositar_monedas(total_venta)
	assert_that(ok_deposito).is_true()
	assert_that(_economy.saldo).is_equal_to(100 + total_venta)

func test_comprar_sin_saldo() -> void:
	var precio = 200
	assert_that(_economy.puede_pagar(precio)).is_false()

	var ok_retiro = _economy.retirar_monedas(precio)
	assert_that(ok_retiro).is_false()
	assert_that(_economy.saldo).is_equal_to(100)

func test_vender_sin_items() -> void:
	var ok_remover = _inventario.remove_item("inexistente", 1)
	assert_that(ok_remover).is_false()

func test_signals_emitted() -> void:
	var saldo_changed_count = 0
	var tx_count = 0
	var item_added_count = 0
	var item_removed_count = 0

	_economy.saldo_cambiado.connect(func(s: int) -> void:
		saldo_changed_count += 1
	)
	_economy.transaccion_registrada.connect(func(tx: Dictionary) -> void:
		tx_count += 1
	)
	_inventario.item_added.connect(func(id: String, cant: int, cont: int) -> void:
		item_added_count += 1
	)
	_inventario.item_removed.connect(func(id: String, cant: int, cont: int) -> void:
		item_removed_count += 1
	)

	_economy.retirar_monedas(30)
	_inventario.add_item("madera", 1)

	_inventario.remove_item("madera", 1)
	_economy.depositar_monedas(15)

	assert_that(saldo_changed_count).is_equal_to(2)
	assert_that(tx_count).is_equal_to(2)
	assert_that(item_added_count).is_equal_to(1)
	assert_that(item_removed_count).is_equal_to(1)

func test_save_restore_roundtrip() -> void:
	_economy.saldo = 500
	_inventario.add_item("madera", 10)
	_inventario.add_item("piedra", 5)

	var economy_data = _economy.get_save_data()
	var inventario_data = _inventario.get_save_data()

	var new_economy = ECONOMY_SCRIPT.new()
	new_economy._asegurar_precios()
	var new_inventario = INVENTARIO_SCRIPT.new()
	new_inventario._ready()

	new_economy.restore_save_data(economy_data)
	new_inventario.restore_save_data(inventario_data)

	assert_that(new_economy.saldo).is_equal_to(500)
	assert_that(new_inventario.count_item("madera")).is_equal_to(10)
	assert_that(new_inventario.count_item("piedra")).is_equal_to(5)

	new_economy.free()
	new_inventario.free()

func test_inventario_capacidad() -> void:
	# Llenar bolsillo (24 slots por defecto) con items únicos
	for i in range(30):
		var resto = _inventario.add_item("item_unico_" + str(i), 1)
		if i < 24:
			assert_that(resto).is_equal_to(0)
		else:
			assert_that(resto).is_equal_to(1)
