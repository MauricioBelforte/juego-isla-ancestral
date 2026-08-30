extends "res://addons/gdUnit4/src/GdUnitTestSuite.gd"

## Integration tests: Economía + NPC/Shop (M38 + M19)
## Verifica la interacción entre economía y sistema de compra/venta con NPCs
##
## EconomyManager es un autoload sin class_name (Node).
## Se instancia vía preload() del script.

const ECONOMY_SCRIPT := preload("res://scripts/economia/economy_manager.gd")

var _economy

func before_test() -> void:
	_economy = ECONOMY_SCRIPT.new()
	_economy._asegurar_precios()

func after_test() -> void:
	if _economy != null:
		_economy.free()
		_economy = null

func test_comprar_a_npc() -> void:
	var precio = 25
	var cantidad = 3
	var total = precio * cantidad

	assert_that(_economy.puede_pagar(total)).is_true()

	var ok = _economy.retirar_monedas(total)
	assert_that(ok).is_true()
	assert_that(_economy.saldo).is_equal_to(100 - total)

func test_vender_a_npc() -> void:
	var precio = 8
	var cantidad = 10
	var total = precio * cantidad

	var ok = _economy.depositar_monedas(total)
	assert_that(ok).is_true()
	assert_that(_economy.saldo).is_equal_to(100 + total)

func test_compra_sin_saldo() -> void:
	_economy.retirar_monedas(100)
	assert_that(_economy.saldo).is_equal_to(0)

	var ok = _economy.retirar_monedas(50)
	assert_that(ok).is_false()
	assert_that(_economy.saldo).is_equal_to(0)

func test_transacciones_mixtas() -> void:
	_economy.retirar_monedas(20)
	_economy.depositar_monedas(30)
	_economy.retirar_monedas(10)
	_economy.depositar_monedas(15)

	assert_that(_economy.saldo).is_equal_to(100 - 20 + 30 - 10 + 15)

func test_signal_saldo_cambiado() -> void:
	var signal_count = 0
	var last_saldo = 100

	_economy.saldo_cambiado.connect(func(nuevo_saldo: int) -> void:
		signal_count += 1
		last_saldo = nuevo_saldo
	)

	_economy.retirar_monedas(10)
	assert_that(signal_count).is_equal_to(1)
	assert_that(last_saldo).is_equal_to(90)

	_economy.depositar_monedas(25)
	assert_that(signal_count).is_equal_to(2)
	assert_that(last_saldo).is_equal_to(115)

	_economy.retirar_monedas(5)
	assert_that(signal_count).is_equal_to(3)
	assert_that(last_saldo).is_equal_to(110)

func test_signal_transaccion_registrada() -> void:
	var signal_count = 0
	_economy.transaccion_registrada.connect(func(tx: Dictionary) -> void:
		signal_count += 1
	)
	_economy.retirar_monedas(10)
	_economy.depositar_monedas(20)
	assert_that(signal_count).is_equal_to(2)

func test_save_restore_economia() -> void:
	_economy.retirar_monedas(20)
	_economy.depositar_monedas(50)
	_economy.retirar_monedas(15)

	var data = _economy.get_save_data()
	assert_that(data.has("saldo")).is_true()

	var new_economy = ECONOMY_SCRIPT.new()
	new_economy._asegurar_precios()
	new_economy.restore_save_data(data)

	assert_that(new_economy.saldo).is_equal_to(_economy.saldo)

	new_economy.free()
