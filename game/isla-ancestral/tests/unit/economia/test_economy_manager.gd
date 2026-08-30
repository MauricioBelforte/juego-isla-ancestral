extends "res://addons/gdUnit4/src/GdUnitTestSuite.gd"

## Unit tests para EconomyManager (M38)
## Verifica la gestión de saldo y transacciones monetarias
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

func test_saldo_inicial() -> void:
	assert_that(_economy.saldo).is_equal_to(100)

func test_puede_pagar_true() -> void:
	assert_that(_economy.puede_pagar(50)).is_true()
	assert_that(_economy.puede_pagar(100)).is_true()
	assert_that(_economy.puede_pagar(0)).is_true()

func test_puede_pagar_false() -> void:
	assert_that(_economy.puede_pagar(101)).is_false()
	assert_that(_economy.puede_pagar(200)).is_false()

func test_retirar_monedas_success() -> void:
	var result = _economy.retirar_monedas(30)
	assert_that(result).is_true()
	assert_that(_economy.saldo).is_equal_to(70)

func test_retirar_monedas_insufficient() -> void:
	var result = _economy.retirar_monedas(200)
	assert_that(result).is_false()
	assert_that(_economy.saldo).is_equal_to(100)

func test_depositar_monedas_success() -> void:
	var result = _economy.depositar_monedas(50)
	assert_that(result).is_true()
	assert_that(_economy.saldo).is_equal_to(150)

func test_depositar_monedas_max_saldo() -> void:
	_economy.saldo = 999900
	var result = _economy.depositar_monedas(200)
	assert_that(result).is_true()
	assert_that(_economy.saldo).is_equal_to(999999)

func test_depositar_monedas_negative() -> void:
	var result = _economy.depositar_monedas(-50)
	assert_that(result).is_false()
	assert_that(_economy.saldo).is_equal_to(100)

func test_saldo_cambiado_on_retirar() -> void:
	var signal_received = false
	var received_saldo = 0
	_economy.saldo_cambiado.connect(func(s: int) -> void:
		signal_received = true
		received_saldo = s
	)
	_economy.retirar_monedas(30)
	assert_that(signal_received).is_true()
	assert_that(received_saldo).is_equal_to(70)

func test_saldo_cambiado_on_depositar() -> void:
	var signal_received = false
	var received_saldo = 0
	_economy.saldo_cambiado.connect(func(s: int) -> void:
		signal_received = true
		received_saldo = s
	)
	_economy.depositar_monedas(50)
	assert_that(signal_received).is_true()
	assert_that(received_saldo).is_equal_to(150)

func test_transaccion_registrada() -> void:
	var signal_received = false
	var received_tx = {}
	_economy.transaccion_registrada.connect(func(tx: Dictionary) -> void:
		signal_received = true
		received_tx = tx
	)
	_economy.retirar_monedas(30)
	assert_that(signal_received).is_true()
	assert_that(received_tx.tipo).is_equal_to("retiro")
	assert_that(received_tx.monto).is_equal_to(30)
	assert_that(received_tx.saldo).is_equal_to(70)

func test_get_section_name() -> void:
	assert_that(_economy.get_section_name()).is_equal_to("economy")

func test_get_save_data() -> void:
	_economy.saldo = 250
	var data = _economy.get_save_data()
	assert_that(data.has("saldo")).is_true()
	assert_that(data.saldo).is_equal_to(250)

func test_restore_save_data() -> void:
	var data = {"saldo": 500}
	_economy.restore_save_data(data)
	assert_that(_economy.saldo).is_equal_to(500)

func test_restore_save_data_clamp() -> void:
	_economy.restore_save_data({"saldo": -100})
	assert_that(_economy.saldo).is_equal_to(0)

	_economy.restore_save_data({"saldo": 9999999})
	assert_that(_economy.saldo).is_equal_to(999999)
