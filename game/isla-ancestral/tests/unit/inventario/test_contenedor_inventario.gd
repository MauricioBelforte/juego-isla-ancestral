# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-04
#
# Inventario: Unit tests ContenedorInventario
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
#   godot --headless --path game/isla-ancestral --script res://tests/unit/inventario/test_contenedor_inventario.gd

extends SceneTree

const TIMEOUT_SEG := 60.0
## Piso MEDIDO en verde (se fija tras la 1a corrida).
const CHECKS_MINIMOS := 33
const BLOQUES_ESPERADOS: Array[String] = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O']


## Unit tests para ContenedorInventario (M14)
## Verifica la funcionalidad del contenedor genérico de slots
##
## NOTA: Sin ItemDatabase, stack_max fallback = 99. Tests usan items únicos
## para llenar slots y apilamiento directo para verificar stack logic.
##
## FIX agnes-3-flash (Log 1127, 2026-09-20): (1) `is_equal_to`→`is_equal`
## (API real del gdUnit4 instalado); (2) `free()` sobre RefCounted → null;
## (3) contadores de señales: las lambdas GDScript capturan locales POR VALOR
## → se movieron a variables de instancia (mutables desde el lambda);
## (4) ids "madera"/"piedra" → "wood"/"stone" (ids reales M15): la
## deserializar valida contra el ItemDatabase VIVO y filtraba los ids falsos.

var _contenedor


var _auto_ItemDatabase = null
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
	_auto_ItemDatabase = root.get_node_or_null("ItemDatabase")
	print("=== Inventario (headless) ===")
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
	print("\n=== Resumen Inventario: %d checks, %d fallos ===" % [_checks, _fallos])
	if _abortado:
		quit(1)
	elif _fallos == 0:
		print("TEST OK — todos los checks pasaron")
		quit(0)
	else:
		print("TEST FALLO — %d checks fallaron" % _fallos)
		quit(1)


func before_test() -> void:
	_contenedor = ContenedorInventario.new(ContainerType.Id.BOLSILLO, 10)


func after_test() -> void:
	# ContenedorInventario es RefCounted: se libera por GC (free() es solo para Node)
	_contenedor = null


func _bloque_A() -> void:
	_ini("A. test_total_slots")
	before_test()
	_check("_contenedor.total_slots() .is_equal(10)", (_contenedor.total_slots()) == (10))
	_check("_contenedor.slots_usados() .is_equal(0)", (_contenedor.slots_usados()) == (0))
	_check("_contenedor.tiene_slot_libre() .is_true()", (_contenedor.tiene_slot_libre()) == true)

	after_test()
	_fin("A. test_total_slots")


func _bloque_B() -> void:
	_ini("B. test_add_item_success")
	before_test()
	var restante = _contenedor.add_item("madera", 5)
	_check("restante .is_equal(0)", (restante) == (0))
	_check("_contenedor.count_item(\"madera\") .is_equal(5)", (_contenedor.count_item("madera")) == (5))
	_check("_contenedor.slots_usados() .is_equal(1)", (_contenedor.slots_usados()) == (1))

	after_test()
	_fin("B. test_add_item_success")


func _bloque_C() -> void:
	_ini("C. test_add_item_stacking")
	before_test()
	_contenedor.add_item("madera", 5)
	var restante = _contenedor.add_item("madera", 3)
	_check("restante .is_equal(0)", (restante) == (0))
	_check("_contenedor.count_item(\"madera\") .is_equal(8)", (_contenedor.count_item("madera")) == (8))
	_check("_contenedor.slots_usados() .is_equal(1)", (_contenedor.slots_usados()) == (1))

	after_test()
	_fin("C. test_add_item_stacking")


func _bloque_D() -> void:
	_ini("D. test_add_item_fills_slots_when_no_db")
	before_test()
	# Sin _auto_ItemDatabase, fallback stack_max = 99. Un solo item apilable siempre cabe.
	_contenedor.add_item("madera", 10)
	var restante = _contenedor.add_item("madera", 5)
	# Con stack_max=99, todo cabe en un slot
	_check("restante .is_equal(0)", (restante) == (0))
	_check("_contenedor.count_item(\"madera\") .is_equal(15)", (_contenedor.count_item("madera")) == (15))
	_check("_contenedor.slots_usados() .is_equal(1)", (_contenedor.slots_usados()) == (1))

	after_test()
	_fin("D. test_add_item_fills_slots_when_no_db")


func _bloque_E() -> void:
	_ini("E. test_add_item_uses_second_slot_for_unique_items")
	before_test()
	# Items únicos (no apilables) llenan slots individuales
	for i in range(10):
		_contenedor.add_item("item_" + str(i), 1)
	var restante = _contenedor.add_item("nuevo", 1)
	_check("restante .is_equal(1)", (restante) == (1))
	_check("_contenedor.slots_usados() .is_equal(10)", (_contenedor.slots_usados()) == (10))

	after_test()
	_fin("E. test_add_item_uses_second_slot_for_unique_items")


func _bloque_F() -> void:
	_ini("F. test_add_item_no_free_slots")
	before_test()
	for i in range(10):
		_contenedor.add_item("item_" + str(i), 1)
	var restante = _contenedor.add_item("nuevo", 5)
	_check("restante .is_equal(5)", (restante) == (5))

	after_test()
	_fin("F. test_add_item_no_free_slots")


func _bloque_G() -> void:
	_ini("G. test_remove_item_success")
	before_test()
	_contenedor.add_item("madera", 10)
	var ok = _contenedor.remove_item("madera", 3)
	_check("ok .is_true()", (ok) == true)
	_check("_contenedor.count_item(\"madera\") .is_equal(7)", (_contenedor.count_item("madera")) == (7))

	after_test()
	_fin("G. test_remove_item_success")


func _bloque_H() -> void:
	_ini("H. test_remove_item_all")
	before_test()
	_contenedor.add_item("madera", 5)
	var ok = _contenedor.remove_item("madera", 5)
	_check("ok .is_true()", (ok) == true)
	_check("_contenedor.count_item(\"madera\") .is_equal(0)", (_contenedor.count_item("madera")) == (0))
	_check("_contenedor.slots_usados() .is_equal(0)", (_contenedor.slots_usados()) == (0))

	after_test()
	_fin("H. test_remove_item_all")


func _bloque_I() -> void:
	_ini("I. test_remove_item_insufficient")
	before_test()
	_contenedor.add_item("madera", 3)
	var ok = _contenedor.remove_item("madera", 5)
	_check("ok .is_false()", (ok) == false)
	_check("_contenedor.count_item(\"madera\") .is_equal(3)", (_contenedor.count_item("madera")) == (3))

	after_test()
	_fin("I. test_remove_item_insufficient")


func _bloque_J() -> void:
	_ini("J. test_remove_item_not_exists")
	before_test()
	var ok = _contenedor.remove_item("inexistente", 1)
	_check("ok .is_false()", (ok) == false)

	after_test()
	_fin("J. test_remove_item_not_exists")


func _bloque_K() -> void:
	_ini("K. test_count_item_multiple_slots")
	before_test()
	_contenedor.add_item("madera", 10)
	_contenedor.add_item("piedra", 3)
	# count_item suma de todos los slots
	_check("_contenedor.count_item(\"madera\") .is_equal(10)", (_contenedor.count_item("madera")) == (10))
	_check("_contenedor.count_item(\"piedra\") .is_equal(3)", (_contenedor.count_item("piedra")) == (3))
	_check("_contenedor.count_item(\"inexistente\") .is_equal(0)", (_contenedor.count_item("inexistente")) == (0))

	after_test()
	_fin("K. test_count_item_multiple_slots")


func _bloque_L() -> void:
	_ini("L. test_serializar_only_occupied")
	before_test()
	_contenedor.add_item("madera", 5)
	_contenedor.add_item("piedra", 3)
	var data = _contenedor.serializar()
	# serializar() retorna Array de slots ocupados
	_check("data.size() .is_equal(2)", (data.size()) == (2))

	after_test()
	_fin("L. test_serializar_only_occupied")


func _bloque_M() -> void:
	_ini("M. test_deserializar")
	before_test()
	# FIX agnes (Log 1127): usar ids reales de M15 — deserializar() valida contra
	# el catálogo _auto_ItemDatabase VIVO (que arranca en el runner gdUnit4); los ids
	# falsos "madera"/"piedra" se filtraban y el conteo quedaba en 0.
	_contenedor.add_item("wood", 5)
	_contenedor.add_item("stone", 3)
	var data = _contenedor.serializar()

	var nuevo = ContenedorInventario.new(ContainerType.Id.BOLSILLO, 10)
	nuevo.deserializar(data)
	_check("nuevo.count_item(\"wood\") .is_equal(5)", (nuevo.count_item("wood")) == (5))
	_check("nuevo.count_item(\"stone\") .is_equal(3)", (nuevo.count_item("stone")) == (3))
	_check("nuevo.slots_usados() .is_equal(2)", (nuevo.slots_usados()) == (2))
	# `nuevo` es RefCounted y local: se libera por GC al terminar la función (sin free())

	after_test()
	_fin("M. test_deserializar")


func _bloque_N() -> void:
	_ini("N. test_slot_changed_on_add")
	before_test()
	# FIX agnes (Log 1127): las lambdas GDScript capturan locales POR VALOR; se
	# usa un holder Array (referencia) para que el contador se muté.
	var holder := [0]
	_contenedor.slot_changed.connect(func(idx: int) -> void:
		holder[0] += 1
	)
	_contenedor.add_item("madera", 5)
	_check("holder[0] .is_equal(1)", (holder[0]) == (1))

	after_test()
	_fin("N. test_slot_changed_on_add")


func _bloque_O() -> void:
	_ini("O. test_slot_changed_on_remove")
	before_test()
	_contenedor.add_item("madera", 5)
	var holder := [0]
	_contenedor.slot_changed.connect(func(idx: int) -> void:
		holder[0] += 1
	)
	_contenedor.remove_item("madera", 5)
	_check("holder[0] .is_equal(1)", (holder[0]) == (1))

	after_test()
	_fin("O. test_slot_changed_on_remove")
