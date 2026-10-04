# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-04
#
# M38: Unit tests EconomyManager
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
#   godot --headless --path game/isla-ancestral --script res://tests/unit/economia/test_economy_manager.gd

extends SceneTree

const TIMEOUT_SEG := 60.0
## Piso MEDIDO en verde (se fija tras la 1a corrida).
const CHECKS_MINIMOS := 31
const BLOQUES_ESPERADOS: Array[String] = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O']


## Unit tests para EconomyManager (M38)
## Verifica la gestión de saldo y transacciones monetarias
##
## EconomyManager es un autoload sin class_name (Node).
## Se instancia vía preload() del script.

const ECONOMY_SCRIPT := preload("res://scripts/economia/economy_manager.gd")

var _economy


var _sig_ok := false
var _sig_saldo := 0
var _sig_tx := {}
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
	print("=== M38 (headless) ===")
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
	_bloque_O()


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
	print("\n=== Resumen M38: %d checks, %d fallos ===" % [_checks, _fallos])
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


func after_test() -> void:
	if _economy != null:
		_economy.free()
		_economy = null


func _bloque_A() -> void:
	_ini("A. test_saldo_inicial")
	before_test()
	_check("_economy.saldo .is_equal_to(100)", (_economy.saldo) == (100))

	after_test()
	_fin("A. test_saldo_inicial")


func _bloque_B() -> void:
	_ini("B. test_puede_pagar_true")
	before_test()
	_check("_economy.puede_pagar(50) .is_true()", (_economy.puede_pagar(50)) == true)
	_check("_economy.puede_pagar(100) .is_true()", (_economy.puede_pagar(100)) == true)
	_check("_economy.puede_pagar(0) .is_true()", (_economy.puede_pagar(0)) == true)

	after_test()
	_fin("B. test_puede_pagar_true")


func _bloque_C() -> void:
	_ini("C. test_puede_pagar_false")
	before_test()
	_check("_economy.puede_pagar(101) .is_false()", (_economy.puede_pagar(101)) == false)
	_check("_economy.puede_pagar(200) .is_false()", (_economy.puede_pagar(200)) == false)

	after_test()
	_fin("C. test_puede_pagar_false")


func _bloque_D() -> void:
	_ini("D. test_retirar_monedas_success")
	before_test()
	var result = _economy.retirar_monedas(30)
	_check("result .is_true()", (result) == true)
	_check("_economy.saldo .is_equal_to(70)", (_economy.saldo) == (70))

	after_test()
	_fin("D. test_retirar_monedas_success")


func _bloque_E() -> void:
	_ini("E. test_retirar_monedas_insufficient")
	before_test()
	var result = _economy.retirar_monedas(200)
	_check("result .is_false()", (result) == false)
	_check("_economy.saldo .is_equal_to(100)", (_economy.saldo) == (100))

	after_test()
	_fin("E. test_retirar_monedas_insufficient")


func _bloque_F() -> void:
	_ini("F. test_depositar_monedas_success")
	before_test()
	var result = _economy.depositar_monedas(50)
	_check("result .is_true()", (result) == true)
	_check("_economy.saldo .is_equal_to(150)", (_economy.saldo) == (150))

	after_test()
	_fin("F. test_depositar_monedas_success")


func _bloque_G() -> void:
	_ini("G. test_depositar_monedas_max_saldo")
	before_test()
	_economy.saldo = 999900
	var result = _economy.depositar_monedas(200)
	_check("result .is_true()", (result) == true)
	_check("_economy.saldo .is_equal_to(999999)", (_economy.saldo) == (999999))

	after_test()
	_fin("G. test_depositar_monedas_max_saldo")


func _bloque_H() -> void:
	_ini("H. test_depositar_monedas_negative")
	before_test()
	var result = _economy.depositar_monedas(-50)
	_check("result .is_false()", (result) == false)
	_check("_economy.saldo .is_equal_to(100)", (_economy.saldo) == (100))

	after_test()
	_fin("H. test_depositar_monedas_negative")


func _bloque_I() -> void:
	_ini("I. test_saldo_cambiado_on_retirar")
	before_test()
	_sig_ok = false
	_sig_saldo = 0
	_economy.saldo_cambiado.connect(func(s: int) -> void:
		_sig_ok = true
		_sig_saldo = s
	)
	_economy.retirar_monedas(30)
	_check("_sig_ok .is_true()", (_sig_ok) == true)
	_check("_sig_saldo .is_equal_to(70)", (_sig_saldo) == (70))

	after_test()
	_fin("I. test_saldo_cambiado_on_retirar")


func _bloque_J() -> void:
	_ini("J. test_saldo_cambiado_on_depositar")
	before_test()
	_sig_ok = false
	_sig_saldo = 0
	_economy.saldo_cambiado.connect(func(s: int) -> void:
		_sig_ok = true
		_sig_saldo = s
	)
	_economy.depositar_monedas(50)
	_check("_sig_ok .is_true()", (_sig_ok) == true)
	_check("_sig_saldo .is_equal_to(150)", (_sig_saldo) == (150))

	after_test()
	_fin("J. test_saldo_cambiado_on_depositar")


func _bloque_K() -> void:
	_ini("K. test_transaccion_registrada")
	before_test()
	_sig_ok = false
	_sig_tx = {}
	_economy.transaccion_registrada.connect(func(tx: Dictionary) -> void:
		_sig_ok = true
		_sig_tx = tx
	)
	_economy.retirar_monedas(30)
	_check("_sig_ok .is_true()", (_sig_ok) == true)
	_check("_sig_tx.tipo .is_equal_to(\"retiro\")", (_sig_tx.tipo) == ("retiro"))
	_check("_sig_tx.monto .is_equal_to(30)", (_sig_tx.monto) == (30))
	_check("_sig_tx.saldo .is_equal_to(70)", (_sig_tx.saldo) == (70))

	after_test()
	_fin("K. test_transaccion_registrada")


func _bloque_L() -> void:
	_ini("L. test_get_section_name")
	before_test()
	_check("_economy.get_section_name() .is_equal_to(\"economy\")", (_economy.get_section_name()) == ("economy"))

	after_test()
	_fin("L. test_get_section_name")


func _bloque_M() -> void:
	_ini("M. test_get_save_data")
	before_test()
	_economy.saldo = 250
	var data = _economy.get_save_data()
	_check("data.has(\"saldo\") .is_true()", (data.has("saldo")) == true)
	_check("data.saldo .is_equal_to(250)", (data.saldo) == (250))

	after_test()
	_fin("M. test_get_save_data")


func _bloque_N() -> void:
	_ini("N. test_restore_save_data")
	before_test()
	var data = {"saldo": 500}
	_economy.restore_save_data(data)
	_check("_economy.saldo .is_equal_to(500)", (_economy.saldo) == (500))

	after_test()
	_fin("N. test_restore_save_data")


func _bloque_O() -> void:
	_ini("O. test_restore_save_data_clamp")
	before_test()
	_economy.restore_save_data({"saldo": -100})
	_check("_economy.saldo .is_equal_to(0)", (_economy.saldo) == (0))

	_economy.restore_save_data({"saldo": 9999999})
	_check("_economy.saldo .is_equal_to(999999)", (_economy.saldo) == (999999))

	after_test()
	_fin("O. test_restore_save_data_clamp")
