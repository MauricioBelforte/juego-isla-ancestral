# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-04
#
# M38+M19: Integration Economia + NPC/Shop
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
#   godot --headless --path game/isla-ancestral --script res://tests/integration/test_economy_npc_shop.gd

extends SceneTree

const TIMEOUT_SEG := 60.0
## Piso MEDIDO en verde (se fija tras la 1a corrida).
const CHECKS_MINIMOS := 19
const BLOQUES_ESPERADOS: Array[String] = ['A', 'B', 'C', 'D', 'E', 'F', 'G']


## Integration tests: Economía + NPC/Shop (M38 + M19)
## Verifica la interacción entre economía y sistema de compra/venta con NPCs
##
## EconomyManager es un autoload sin class_name (Node).
## Se instancia vía preload() del script.

const ECONOMY_SCRIPT := preload("res://scripts/economia/economy_manager.gd")

var _economy


var _sig_count := 0
var _sig_saldo := 100
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
	print("=== M38+M19 (headless) ===")
	_bloque_A()
	_bloque_B()
	_bloque_C()
	_bloque_D()
	_bloque_E()
	_bloque_F()
	_bloque_G()


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
	print("\n=== Resumen M38+M19: %d checks, %d fallos ===" % [_checks, _fallos])
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
	_ini("A. test_comprar_a_npc")
	before_test()
	var precio = 25
	var cantidad = 3
	var total = precio * cantidad

	_check("_economy.puede_pagar(total) .is_true()", (_economy.puede_pagar(total)) == true)

	var ok = _economy.retirar_monedas(total)
	_check("ok .is_true()", (ok) == true)
	_check("_economy.saldo .is_equal_to(100 - total)", (_economy.saldo) == (100 - total))

	after_test()
	_fin("A. test_comprar_a_npc")


func _bloque_B() -> void:
	_ini("B. test_vender_a_npc")
	before_test()
	var precio = 8
	var cantidad = 10
	var total = precio * cantidad

	var ok = _economy.depositar_monedas(total)
	_check("ok .is_true()", (ok) == true)
	_check("_economy.saldo .is_equal_to(100 + total)", (_economy.saldo) == (100 + total))

	after_test()
	_fin("B. test_vender_a_npc")


func _bloque_C() -> void:
	_ini("C. test_compra_sin_saldo")
	before_test()
	_economy.retirar_monedas(100)
	_check("_economy.saldo .is_equal_to(0)", (_economy.saldo) == (0))

	var ok = _economy.retirar_monedas(50)
	_check("ok .is_false()", (ok) == false)
	_check("_economy.saldo .is_equal_to(0)", (_economy.saldo) == (0))

	after_test()
	_fin("C. test_compra_sin_saldo")


func _bloque_D() -> void:
	_ini("D. test_transacciones_mixtas")
	before_test()
	_economy.retirar_monedas(20)
	_economy.depositar_monedas(30)
	_economy.retirar_monedas(10)
	_economy.depositar_monedas(15)

	_check("_economy.saldo .is_equal_to(100 - 20 + 30 - 10 + 15)", (_economy.saldo) == (100 - 20 + 30 - 10 + 15))

	after_test()
	_fin("D. test_transacciones_mixtas")


func _bloque_E() -> void:
	_ini("E. test_signal_saldo_cambiado")
	before_test()
	_sig_count = 0
	_sig_saldo = 100

	_economy.saldo_cambiado.connect(func(nuevo_saldo: int) -> void:
		_sig_count += 1
		_sig_saldo = nuevo_saldo
	)

	_economy.retirar_monedas(10)
	_check("_sig_count .is_equal_to(1)", (_sig_count) == (1))
	_check("_sig_saldo .is_equal_to(90)", (_sig_saldo) == (90))

	_economy.depositar_monedas(25)
	_check("_sig_count .is_equal_to(2)", (_sig_count) == (2))
	_check("_sig_saldo .is_equal_to(115)", (_sig_saldo) == (115))

	_economy.retirar_monedas(5)
	_check("_sig_count .is_equal_to(3)", (_sig_count) == (3))
	_check("_sig_saldo .is_equal_to(110)", (_sig_saldo) == (110))

	after_test()
	_fin("E. test_signal_saldo_cambiado")


func _bloque_F() -> void:
	_ini("F. test_signal_transaccion_registrada")
	before_test()
	_sig_count = 0
	_economy.transaccion_registrada.connect(func(tx: Dictionary) -> void:
		_sig_count += 1
	)
	_economy.retirar_monedas(10)
	_economy.depositar_monedas(20)
	_check("_sig_count .is_equal_to(2)", (_sig_count) == (2))

	after_test()
	_fin("F. test_signal_transaccion_registrada")


func _bloque_G() -> void:
	_ini("G. test_save_restore_economia")
	before_test()
	_economy.retirar_monedas(20)
	_economy.depositar_monedas(50)
	_economy.retirar_monedas(15)

	var data = _economy.get_save_data()
	_check("data.has(\"saldo\") .is_true()", (data.has("saldo")) == true)

	var new_economy = ECONOMY_SCRIPT.new()
	new_economy._asegurar_precios()
	new_economy.restore_save_data(data)

	_check("new_economy.saldo .is_equal_to(_economy.saldo)", (new_economy.saldo) == (_economy.saldo))

	new_economy.free()

	after_test()
	_fin("G. test_save_restore_economia")
