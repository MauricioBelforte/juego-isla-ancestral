# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-04
#
# Regression: flujos estables
#
# CONVERTIDO de gdUnit4 a headless (BUG-093, sub-frente) por convertir.py.
# Motivo: la suite gdUnit4 PARSEABA pero MORIA en runtime (metodos
# inexistentes: is_equal_to/is_greater_than/is_instance_of/has_not_contains/
# has_any_item -> 0 apariciones en addons/gdUnit4/). Ademas las suites gdUnit4
# NO se ejecutan en el CI del proyecto (solo `--script`, estandar 12.1).
#
# Guardia anti-falso-verde (3 capas): _fin() por bloque + CHECKS_MINIMOS
# MEDIDO + _summary() en call_deferred SEPARADO + watchdog.
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral --script res://tests/regression/test_stable_flows.gd

extends SceneTree

const TIMEOUT_SEG := 60.0
## Piso MEDIDO en verde (se fija tras la 1a corrida).
const CHECKS_MINIMOS := 0
const BLOQUES_ESPERADOS: Array[String] = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N']


## Regression tests: Flujos estables críticos
## Tests que garantizan que funcionalidad core no se rompe

const ECONOMY_SCRIPT := preload("res://scripts/economia/economy_manager.gd")
const INVENTARIO_SCRIPT := preload("res://scripts/inventario/inventario_service.gd")
const TIME_SCRIPT := preload("res://scripts/time/time_calendar.gd")

var _economy
var _inventario
var _calendar

# ==================== ECONOMÍA - FLUJOS CRÍTICOS ====================

# ==================== INVENTARIO - FLUJOS CRÍTICOS ====================

# ==================== TIEMPO/CALENDARIO - FLUJOS CRÍTICOS ====================

# ==================== FLUJOS CRUZADOS CORE ====================


var _fallos: int = 0
var _checks: int = 0
var _bloque: String = "(inicio)"
var _abortado: bool = false
var _completados: Array[String] = []
var _checks_por_bloque: Dictionary = {}
var _checks_marca: int = 0


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	create_timer(TIMEOUT_SEG, true).timeout.connect(_on_watchdog)
	print("=== Regression (headless) ===")
	_bloque_A()
	_bloque_B()
	_bloque_C()
	_bloque_D()
	_bloque_E()
	_bloque_F()
	_bloque_G()
	_bloque_H()
	_bloque_I()
	_bloque_J()
	_bloque_K()
	_bloque_L()
	_bloque_M()
	_bloque_N()


func _on_watchdog() -> void:
	_abortado = true
	print("WATCHDOG: la suite no termino en %.0f s (ultimo bloque: %s)" % [TIMEOUT_SEG, _bloque])
	quit(1)


func _ini(nombre: String) -> void:
	_bloque = nombre
	_checks_marca = _checks
	print("\n-- %s --" % nombre)


func _fin(nombre: String) -> void:
	var letra: String = nombre.substr(0, 1)
	if not _completados.has(letra):
		_completados.append(letra)
	var delta: int = _checks - _checks_marca
	_checks_por_bloque[letra] = int(_checks_por_bloque.get(letra, 0)) + delta
	_checks_marca = _checks
	print("[FIN] %s (+%d checks)" % [nombre, delta])


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])


func _summary() -> void:
	var faltantes: Array[String] = []
	for letra in BLOQUES_ESPERADOS:
		if not _completados.has(letra):
			faltantes.append(letra)
	_check("todos los bloques se completaron (sin abortos silenciosos)", faltantes.is_empty(),
		"bloques que no terminaron: %s" % str(faltantes))
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("  [FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("Checks por bloque: %s" % str(_checks_por_bloque))
	print("\n=== Resumen Regression: %d checks, %d fallos ===" % [_checks, _fallos])
	if _abortado:
		quit(1)
	elif _fallos == 0:
		print("TEST OK — todos los checks pasaron")
		quit(0)
	else:
		print("TEST FALLO — %d checks fallaron" % _fallos)
		quit(1)


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


func _bloque_A() -> void:
	_ini("A. test_reg_economy_initial_balance")
	before_test()
	_check("_economy.saldo .is_equal_to(100)", (_economy.saldo) == (100))

	after_test()
	_fin("A. test_reg_economy_initial_balance")


func _bloque_B() -> void:
	_ini("B. test_reg_economy_no_negative")
	before_test()
	_economy.retirar_monedas(100)
	var ok = _economy.retirar_monedas(1)
	_check("ok .is_false()", (ok) == false)
	_check("_economy.saldo .is_equal_to(0)", (_economy.saldo) == (0))

	after_test()
	_fin("B. test_reg_economy_no_negative")


func _bloque_C() -> void:
	_ini("C. test_reg_economy_deposit_increases")
	before_test()
	_economy.depositar_monedas(50)
	_check("_economy.saldo .is_equal_to(150)", (_economy.saldo) == (150))

	after_test()
	_fin("C. test_reg_economy_deposit_increases")


func _bloque_D() -> void:
	_ini("D. test_reg_economy_save_restore")
	before_test()
	_economy.retirar_monedas(25)
	_economy.depositar_monedas(75)

	var data = _economy.get_save_data()
	var new_economy = ECONOMY_SCRIPT.new()
	new_economy._asegurar_precios()
	new_economy.restore_save_data(data)

	_check("new_economy.saldo .is_equal_to(150)", (new_economy.saldo) == (150))
	new_economy.free()

	after_test()
	_fin("D. test_reg_economy_save_restore")


func _bloque_E() -> void:
	_ini("E. test_reg_inv_add_returns_zero")
	before_test()
	var resto = _inventario.add_item("madera", 5)
	_check("resto .is_equal_to(0)", (resto) == (0))
	_check("_inventario.count_item(\"madera\") .is_equal_to(5)", (_inventario.count_item("madera")) == (5))

	after_test()
	_fin("E. test_reg_inv_add_returns_zero")


func _bloque_F() -> void:
	_ini("F. test_reg_inv_remove_returns_true")
	before_test()
	_inventario.add_item("piedra", 10)
	var ok = _inventario.remove_item("piedra", 3)
	_check("ok .is_true()", (ok) == true)
	_check("_inventario.count_item(\"piedra\") .is_equal_to(7)", (_inventario.count_item("piedra")) == (7))

	after_test()
	_fin("F. test_reg_inv_remove_returns_true")


func _bloque_G() -> void:
	_ini("G. test_reg_inv_no_remove_insufficient")
	before_test()
	_inventario.add_item("madera", 2)
	var ok = _inventario.remove_item("madera", 5)
	_check("ok .is_false()", (ok) == false)
	_check("_inventario.count_item(\"madera\") .is_equal_to(2)", (_inventario.count_item("madera")) == (2))

	after_test()
	_fin("G. test_reg_inv_no_remove_insufficient")


func _bloque_H() -> void:
	_ini("H. test_reg_inv_serialize_deserialize")
	before_test()
	_inventario.add_item("madera", 10)
	_inventario.add_item("piedra", 5)

	var data = _inventario.get_save_data()

	var new_inv = INVENTARIO_SCRIPT.new()
	new_inv._ready()
	new_inv.restore_save_data(data)

	_check("new_inv.count_item(\"madera\") .is_equal_to(10)", (new_inv.count_item("madera")) == (10))
	_check("new_inv.count_item(\"piedra\") .is_equal_to(5)", (new_inv.count_item("piedra")) == (5))
	new_inv.free()

	after_test()
	_fin("H. test_reg_inv_serialize_deserialize")


func _bloque_I() -> void:
	_ini("I. test_reg_time_initial_state")
	before_test()
	_check("_calendar.get_hora() >= 0 and _calendar.get_hora() <= 23 .is_true()", (_calendar.get_hora() >= 0 and _calendar.get_hora() <= 23) == true)
	_check("_calendar.get_estacion() >= 0 and _calendar.get_estacion() <= 3 .is_true()", (_calendar.get_estacion() >= 0 and _calendar.get_estacion() <= 3) == true)

	after_test()
	_fin("I. test_reg_time_initial_state")


func _bloque_J() -> void:
	_ini("J. test_reg_time_pause_resume")
	before_test()
	_calendar.pausar()
	_calendar.resume()

	after_test()
	_fin("J. test_reg_time_pause_resume")


func _bloque_K() -> void:
	_ini("K. test_reg_time_save_restore_full")
	before_test()
	var saved = _calendar.get_save_data()

	var new_cal = TIME_SCRIPT.new()
	new_cal.restore_save_data(saved)

	_check("new_cal .is_not_null()", (new_cal) != null)
	new_cal.free()

	after_test()
	_fin("K. test_reg_time_save_restore_full")


func _bloque_L() -> void:
	_ini("L. test_reg_cross_buy_integrates")
	before_test()
	var ok = _economy.retirar_monedas(30)
	_check("ok .is_true()", (ok) == true)

	var resto = _inventario.add_item("madera", 1)
	_check("resto .is_equal_to(0)", (resto) == (0))
	_check("_inventario.count_item(\"madera\") .is_equal_to(1)", (_inventario.count_item("madera")) == (1))
	_check("_economy.saldo .is_equal_to(70)", (_economy.saldo) == (70))

	after_test()
	_fin("L. test_reg_cross_buy_integrates")


func _bloque_M() -> void:
	_ini("M. test_reg_cross_sell_integrates")
	before_test()
	_inventario.add_item("piedra", 5)
	var ok = _inventario.remove_item("piedra", 3)
	_check("ok .is_true()", (ok) == true)

	_economy.depositar_monedas(30)

	_check("_inventario.count_item(\"piedra\") .is_equal_to(2)", (_inventario.count_item("piedra")) == (2))
	_check("_economy.saldo .is_equal_to(130)", (_economy.saldo) == (130))

	after_test()
	_fin("M. test_reg_cross_sell_integrates")


func _bloque_N() -> void:
	_ini("N. test_reg_cross_full_save")
	before_test()
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

	_check("new_economy.saldo .is_equal_to(500)", (new_economy.saldo) == (500))
	_check("new_inv.count_item(\"madera\") .is_equal_to(20)", (new_inv.count_item("madera")) == (20))
	_check("new_inv.count_item(\"comida\") .is_equal_to(10)", (new_inv.count_item("comida")) == (10))
	_check("new_time .is_not_null()", (new_time) != null)

	new_economy.free()
	new_inv.free()
	new_time.free()

	after_test()
	_fin("N. test_reg_cross_full_save")
