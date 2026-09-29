extends "res://addons/gdUnit4/src/GdUnitTestSuite.gd"

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

func before_test() -> void:
	_contenedor = ContenedorInventario.new(ContainerType.Id.BOLSILLO, 10)

func after_test() -> void:
	# ContenedorInventario es RefCounted: se libera por GC (free() es solo para Node)
	_contenedor = null

func test_total_slots() -> void:
	assert_that(_contenedor.total_slots()).is_equal(10)
	assert_that(_contenedor.slots_usados()).is_equal(0)
	assert_that(_contenedor.tiene_slot_libre()).is_true()

func test_add_item_success() -> void:
	var restante = _contenedor.add_item("madera", 5)
	assert_that(restante).is_equal(0)
	assert_that(_contenedor.count_item("madera")).is_equal(5)
	assert_that(_contenedor.slots_usados()).is_equal(1)

func test_add_item_stacking() -> void:
	_contenedor.add_item("madera", 5)
	var restante = _contenedor.add_item("madera", 3)
	assert_that(restante).is_equal(0)
	assert_that(_contenedor.count_item("madera")).is_equal(8)
	assert_that(_contenedor.slots_usados()).is_equal(1)

func test_add_item_fills_slots_when_no_db() -> void:
	# Sin ItemDatabase, fallback stack_max = 99. Un solo item apilable siempre cabe.
	_contenedor.add_item("madera", 10)
	var restante = _contenedor.add_item("madera", 5)
	# Con stack_max=99, todo cabe en un slot
	assert_that(restante).is_equal(0)
	assert_that(_contenedor.count_item("madera")).is_equal(15)
	assert_that(_contenedor.slots_usados()).is_equal(1)

func test_add_item_uses_second_slot_for_unique_items() -> void:
	# Items únicos (no apilables) llenan slots individuales
	for i in range(10):
		_contenedor.add_item("item_" + str(i), 1)
	var restante = _contenedor.add_item("nuevo", 1)
	assert_that(restante).is_equal(1)  # No hay slots libres
	assert_that(_contenedor.slots_usados()).is_equal(10)

func test_add_item_no_free_slots() -> void:
	for i in range(10):
		_contenedor.add_item("item_" + str(i), 1)
	var restante = _contenedor.add_item("nuevo", 5)
	assert_that(restante).is_equal(5)

func test_remove_item_success() -> void:
	_contenedor.add_item("madera", 10)
	var ok = _contenedor.remove_item("madera", 3)
	assert_that(ok).is_true()
	assert_that(_contenedor.count_item("madera")).is_equal(7)

func test_remove_item_all() -> void:
	_contenedor.add_item("madera", 5)
	var ok = _contenedor.remove_item("madera", 5)
	assert_that(ok).is_true()
	assert_that(_contenedor.count_item("madera")).is_equal(0)
	assert_that(_contenedor.slots_usados()).is_equal(0)

func test_remove_item_insufficient() -> void:
	_contenedor.add_item("madera", 3)
	var ok = _contenedor.remove_item("madera", 5)
	assert_that(ok).is_false()
	assert_that(_contenedor.count_item("madera")).is_equal(3)

func test_remove_item_not_exists() -> void:
	var ok = _contenedor.remove_item("inexistente", 1)
	assert_that(ok).is_false()

func test_count_item_multiple_slots() -> void:
	_contenedor.add_item("madera", 10)
	_contenedor.add_item("piedra", 3)
	# count_item suma de todos los slots
	assert_that(_contenedor.count_item("madera")).is_equal(10)
	assert_that(_contenedor.count_item("piedra")).is_equal(3)
	assert_that(_contenedor.count_item("inexistente")).is_equal(0)

func test_serializar_only_occupied() -> void:
	_contenedor.add_item("madera", 5)
	_contenedor.add_item("piedra", 3)
	var data = _contenedor.serializar()
	# serializar() retorna Array de slots ocupados
	assert_that(data.size()).is_equal(2)

func test_deserializar() -> void:
	# FIX agnes (Log 1127): usar ids reales de M15 — deserializar() valida contra
	# el catálogo ItemDatabase VIVO (que arranca en el runner gdUnit4); los ids
	# falsos "madera"/"piedra" se filtraban y el conteo quedaba en 0.
	_contenedor.add_item("wood", 5)
	_contenedor.add_item("stone", 3)
	var data = _contenedor.serializar()

	var nuevo = ContenedorInventario.new(ContainerType.Id.BOLSILLO, 10)
	nuevo.deserializar(data)
	assert_that(nuevo.count_item("wood")).is_equal(5)
	assert_that(nuevo.count_item("stone")).is_equal(3)
	assert_that(nuevo.slots_usados()).is_equal(2)
	# `nuevo` es RefCounted y local: se libera por GC al terminar la función (sin free())

func test_slot_changed_on_add() -> void:
	# FIX agnes (Log 1127): las lambdas GDScript capturan locales POR VALOR; se
	# usa un holder Array (referencia) para que el contador se muté.
	var holder := [0]
	_contenedor.slot_changed.connect(func(idx: int) -> void:
		holder[0] += 1
	)
	_contenedor.add_item("madera", 5)
	assert_that(holder[0]).is_equal(1)

func test_slot_changed_on_remove() -> void:
	_contenedor.add_item("madera", 5)
	var holder := [0]
	_contenedor.slot_changed.connect(func(idx: int) -> void:
		holder[0] += 1
	)
	_contenedor.remove_item("madera", 5)
	assert_that(holder[0]).is_equal(1)
