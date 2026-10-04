# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-04
#
# M38+Inventario: Integration inventario/economia
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
#   godot --headless --path game/isla-ancestral --script res://tests/integration/test_inventory_economy.gd

extends SceneTree

const TIMEOUT_SEG := 60.0
## Piso MEDIDO en verde (se fija tras la 1a corrida).
const CHECKS_MINIMOS := 0
const BLOQUES_ESPERADOS: Array[String] = ['A', 'B', 'C', 'D', 'E', 'F', 'G']


## Integration tests: Inventario + Economía (M14 + M38)
## Verifica la interacción entre inventario y sistema económico
##
## InventarioService es un autoload sin class_name (Node).
## EconomyManager es un autoload sin class_name (Node).

const ECONOMY_SCRIPT := preload("res://scripts/economia/economy_manager.gd")
const INVENTARIO_SCRIPT := preload("res://scripts/inventario/inventario_service.gd")

var _inventario
var _economy

## FIX agnes-3-flash (Log 1127): (1) `is_equal_to`→`is_equal` (API gdUnit4 real);
## (2) contadores de señales: las lambdas capturan locales POR VALOR → holder
## Dictionary (referencia) para que muten; (3) roundtrip con ids reales de M15
## ("wood"/"stone"): restore_save_data → deserializar() valida contra el
## catálogo ItemDatabase vivo y filtraba los ids falsos.

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
	print("=== M38+Inventario (headless) ===")
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
	print("\n=== Resumen M38+Inventario: %d checks, %d fallos ===" % [_checks, _fallos])
	if _abortado:
		quit(1)
	elif _fallos == 0:
		print("TEST OK — todos los checks pasaron")
		quit(0)
	else:
		print("TEST FALLO — %d checks fallaron" % _fallos)
		quit(1)


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


func _bloque_A() -> void:
	_ini("A. test_comprar_item")
	before_test()
	var precio = 50
	var item_id = "madera"

	_check("_economy.puede_pagar(precio) .is_true()", (_economy.puede_pagar(precio)) == true)

	var ok_retiro = _economy.retirar_monedas(precio)
	_check("ok_retiro .is_true()", (ok_retiro) == true)
	_check("_economy.saldo .is_equal(50)", (_economy.saldo) == (50))

	var restante = _inventario.add_item(item_id, 1)
	_check("restante .is_equal(0)", (restante) == (0))
	_check("_inventario.count_item(item_id) .is_equal(1)", (_inventario.count_item(item_id)) == (1))

	after_test()
	_fin("A. test_comprar_item")


func _bloque_B() -> void:
	_ini("B. test_vender_item")
	before_test()
	var item_id = "piedra"
	var precio_venta = 10

	_inventario.add_item(item_id, 5)
	_check("_inventario.count_item(item_id) .is_equal(5)", (_inventario.count_item(item_id)) == (5))

	var ok_remover = _inventario.remove_item(item_id, 3)
	_check("ok_remover .is_true()", (ok_remover) == true)
	_check("_inventario.count_item(item_id) .is_equal(2)", (_inventario.count_item(item_id)) == (2))

	var total_venta = precio_venta * 3
	var ok_deposito = _economy.depositar_monedas(total_venta)
	_check("ok_deposito .is_true()", (ok_deposito) == true)
	_check("_economy.saldo .is_equal(100 + total_venta)", (_economy.saldo) == (100 + total_venta))

	after_test()
	_fin("B. test_vender_item")


func _bloque_C() -> void:
	_ini("C. test_comprar_sin_saldo")
	before_test()
	var precio = 200
	_check("_economy.puede_pagar(precio) .is_false()", (_economy.puede_pagar(precio)) == false)

	var ok_retiro = _economy.retirar_monedas(precio)
	_check("ok_retiro .is_false()", (ok_retiro) == false)
	_check("_economy.saldo .is_equal(100)", (_economy.saldo) == (100))

	after_test()
	_fin("C. test_comprar_sin_saldo")


func _bloque_D() -> void:
	_ini("D. test_vender_sin_items")
	before_test()
	var ok_remover = _inventario.remove_item("inexistente", 1)
	_check("ok_remover .is_false()", (ok_remover) == false)

	after_test()
	_fin("D. test_vender_sin_items")


func _bloque_E() -> void:
	_ini("E. test_signals_emitted")
	before_test()
	var c := {"saldo": 0, "tx": 0, "add": 0, "rem": 0}
	_economy.saldo_cambiado.connect(func(s: int) -> void:
		c["saldo"] += 1
	)
	_economy.transaccion_registrada.connect(func(tx: Dictionary) -> void:
		c["tx"] += 1
	)
	_inventario.item_added.connect(func(id: String, cant: int, cont: int) -> void:
		c["add"] += 1
	)
	_inventario.item_removed.connect(func(id: String, cant: int, cont: int) -> void:
		c["rem"] += 1
	)

	_economy.retirar_monedas(30)
	_inventario.add_item("madera", 1)

	_inventario.remove_item("madera", 1)
	_economy.depositar_monedas(15)

	_check("c[\"saldo\"] .is_equal(2)", (c["saldo"]) == (2))
	_check("c[\"tx\"] .is_equal(2)", (c["tx"]) == (2))
	_check("c[\"add\"] .is_equal(1)", (c["add"]) == (1))
	_check("c[\"rem\"] .is_equal(1)", (c["rem"]) == (1))

	after_test()
	_fin("E. test_signals_emitted")


func _bloque_F() -> void:
	_ini("F. test_save_restore_roundtrip")
	before_test()
	_economy.saldo = 500
	# FIX agnes (Log 1127): ids reales M15 (ver nota superior)
	_inventario.add_item("wood", 10)
	_inventario.add_item("stone", 5)

	var economy_data = _economy.get_save_data()
	var inventario_data = _inventario.get_save_data()

	var new_economy = ECONOMY_SCRIPT.new()
	new_economy._asegurar_precios()
	var new_inventario = INVENTARIO_SCRIPT.new()
	new_inventario._ready()

	new_economy.restore_save_data(economy_data)
	new_inventario.restore_save_data(inventario_data)

	_check("new_economy.saldo .is_equal(500)", (new_economy.saldo) == (500))
	_check("new_inventario.count_item(\"wood\") .is_equal(10)", (new_inventario.count_item("wood")) == (10))
	_check("new_inventario.count_item(\"stone\") .is_equal(5)", (new_inventario.count_item("stone")) == (5))

	new_economy.free()
	new_inventario.free()

	after_test()
	_fin("F. test_save_restore_roundtrip")


func _bloque_G() -> void:
	_ini("G. test_inventario_capacidad")
	before_test()
	# Llenar bolsillo (24 slots por defecto) con items únicos
	for i in range(30):
		var resto = _inventario.add_item("item_unico_" + str(i), 1)
		if i < 24:
			_check("resto .is_equal(0)", (resto) == (0))
		else:
			_check("resto .is_equal(1)", (resto) == (1))

	after_test()
	_fin("G. test_inventario_capacidad")
