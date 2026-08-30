extends "res://addons/gdUnit4/src/GdUnitTestSuite.gd"

## Regression tests: Flujos estables críticos
## Tests que garantizan que funcionalidad core no se rompe

const ECONOMY_SCRIPT := preload("res://scripts/economia/economy_manager.gd")
const INVENTARIO_SCRIPT := preload("res://scripts/inventario/inventario_service.gd")
const TIME_SCRIPT := preload("res://scripts/time/time_calendar.gd")

var _economy
var _inventario
var _calendar

func before_test() -> void:
	_economy = ECONOMY_SCRIPT.new()
	_economy._asegurar_precios()
	_inventario = INVENTARIO_SCRIPT.new()
	_inventario._ready()
	_calendar = TIME_SCRIPT.new()

func after_test() -> void:
	if _economy != null:
		_economy.free()
		_economy = null
	if _inventario != null:
		_inventario.free()
		_inventario = null
	if _calendar != null:
		_calendar.free()
		_calendar = null

# ==================== ECONOMÍA - FLUJOS CRÍTICOS ====================

func test_reg_economy_initial_balance() -> void:
	assert_that(_economy.saldo).is_equal_to(100)

func test_reg_economy_no_negative() -> void:
	_economy.retirar_monedas(100)
	var ok = _economy.retirar_monedas(1)
	assert_that(ok).is_false()
	assert_that(_economy.saldo).is_equal_to(0)

func test_reg_economy_deposit_increases() -> void:
	_economy.depositar_monedas(50)
	assert_that(_economy.saldo).is_equal_to(150)

func test_reg_economy_save_restore() -> void:
	_economy.retirar_monedas(25)
	_economy.depositar_monedas(75)

	var data = _economy.get_save_data()
	var new_economy = ECONOMY_SCRIPT.new()
	new_economy._asegurar_precios()
	new_economy.restore_save_data(data)

	assert_that(new_economy.saldo).is_equal_to(150)
	new_economy.free()

# ==================== INVENTARIO - FLUJOS CRÍTICOS ====================

func test_reg_inv_add_returns_zero() -> void:
	var resto = _inventario.add_item("madera", 5)
	assert_that(resto).is_equal_to(0)
	assert_that(_inventario.count_item("madera")).is_equal_to(5)

func test_reg_inv_remove_returns_true() -> void:
	_inventario.add_item("piedra", 10)
	var ok = _inventario.remove_item("piedra", 3)
	assert_that(ok).is_true()
	assert_that(_inventario.count_item("piedra")).is_equal_to(7)

func test_reg_inv_no_remove_insufficient() -> void:
	_inventario.add_item("madera", 2)
	var ok = _inventario.remove_item("madera", 5)
	assert_that(ok).is_false()
	assert_that(_inventario.count_item("madera")).is_equal_to(2)

func test_reg_inv_serialize_deserialize() -> void:
	_inventario.add_item("madera", 10)
	_inventario.add_item("piedra", 5)

	var data = _inventario.get_save_data()

	var new_inv = INVENTARIO_SCRIPT.new()
	new_inv._ready()
	new_inv.restore_save_data(data)

	assert_that(new_inv.count_item("madera")).is_equal_to(10)
	assert_that(new_inv.count_item("piedra")).is_equal_to(5)
	new_inv.free()

# ==================== TIEMPO/CALENDARIO - FLUJOS CRÍTICOS ====================

func test_reg_time_initial_state() -> void:
	assert_that(_calendar.get_hora() >= 0 and _calendar.get_hora() <= 23).is_true()
	assert_that(_calendar.get_estacion() >= 0 and _calendar.get_estacion() <= 3).is_true()

func test_reg_time_pause_resume() -> void:
	_calendar.pausar()
	_calendar.resume()

func test_reg_time_save_restore_full() -> void:
	var saved = _calendar.get_save_data()

	var new_cal = TIME_SCRIPT.new()
	new_cal.restore_save_data(saved)

	assert_that(new_cal).is_not_null()
	new_cal.free()

# ==================== FLUJOS CRUZADOS CORE ====================

func test_reg_cross_buy_integrates() -> void:
	var ok = _economy.retirar_monedas(30)
	assert_that(ok).is_true()

	var resto = _inventario.add_item("madera", 1)
	assert_that(resto).is_equal_to(0)
	assert_that(_inventario.count_item("madera")).is_equal_to(1)
	assert_that(_economy.saldo).is_equal_to(70)

func test_reg_cross_sell_integrates() -> void:
	_inventario.add_item("piedra", 5)
	var ok = _inventario.remove_item("piedra", 3)
	assert_that(ok).is_true()

	_economy.depositar_monedas(30)

	assert_that(_inventario.count_item("piedra")).is_equal_to(2)
	assert_that(_economy.saldo).is_equal_to(130)

func test_reg_cross_full_save() -> void:
	_economy.saldo = 500
	_inventario.add_item("madera", 20)
	_inventario.add_item("comida", 10)

	var economy_data = _economy.get_save_data()
	var inv_data = _inventario.get_save_data()
	var time_data = _calendar.get_save_data()

	var new_economy = ECONOMY_SCRIPT.new()
	new_economy._asegurar_precios()
	new_economy.restore_save_data(economy_data)

	var new_inv = INVENTARIO_SCRIPT.new()
	new_inv._ready()
	new_inv.restore_save_data(inv_data)

	var new_time = TIME_SCRIPT.new()
	new_time.restore_save_data(time_data)

	assert_that(new_economy.saldo).is_equal_to(500)
	assert_that(new_inv.count_item("madera")).is_equal_to(20)
	assert_that(new_inv.count_item("comida")).is_equal_to(10)
	assert_that(new_time).is_not_null()

	new_economy.free()
	new_inv.free()
	new_time.free()
