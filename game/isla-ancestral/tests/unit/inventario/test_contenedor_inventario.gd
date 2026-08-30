extends "res://addons/gdUnit4/src/GdUnitTestSuite.gd"

## Unit tests para ContenedorInventario (M14)
## Verifica la funcionalidad del contenedor genérico de slots
##
## NOTA: Sin ItemDatabase, stack_max fallback = 99. Tests usan items únicos
## para llenar slots y apilamiento directo para verificar stack logic.

var _contenedor

func before_test() -> void:
	_contenedor = ContenedorInventario.new(ContainerType.Id.BOLSILLO, 10)

func after_test() -> void:
	if _contenedor != null:
		_contenedor.free()
		_contenedor = null

func test_total_slots() -> void:
	assert_that(_contenedor.total_slots()).is_equal_to(10)
	assert_that(_contenedor.slots_usados()).is_equal_to(0)
	assert_that(_contenedor.tiene_slot_libre()).is_true()

func test_add_item_success() -> void:
	var restante = _contenedor.add_item("madera", 5)
	assert_that(restante).is_equal_to(0)
	assert_that(_contenedor.count_item("madera")).is_equal_to(5)
	assert_that(_contenedor.slots_usados()).is_equal_to(1)

func test_add_item_stacking() -> void:
	_contenedor.add_item("madera", 5)
	var restante = _contenedor.add_item("madera", 3)
	assert_that(restante).is_equal_to(0)
	assert_that(_contenedor.count_item("madera")).is_equal_to(8)
	assert_that(_contenedor.slots_usados()).is_equal_to(1)

func test_add_item_fills_slots_when_no_db() -> void:
	# Sin ItemDatabase, fallback stack_max = 99. Un solo item apilable siempre cabe.
	_contenedor.add_item("madera", 10)
	var restante = _contenedor.add_item("madera", 5)
	# Con stack_max=99, todo cabe en un slot
	assert_that(restante).is_equal_to(0)
	assert_that(_contenedor.count_item("madera")).is_equal_to(15)
	assert_that(_contenedor.slots_usados()).is_equal_to(1)

func test_add_item_uses_second_slot_for_unique_items() -> void:
	# Items únicos (no apilables) llenan slots individuales
	for i in range(10):
		_contenedor.add_item("item_" + str(i), 1)
	var restante = _contenedor.add_item("nuevo", 1)
	assert_that(restante).is_equal_to(1)  # No hay slots libres
	assert_that(_contenedor.slots_usados()).is_equal_to(10)

func test_add_item_no_free_slots() -> void:
	for i in range(10):
		_contenedor.add_item("item_" + str(i), 1)
	var restante = _contenedor.add_item("nuevo", 5)
	assert_that(restante).is_equal_to(5)

func test_remove_item_success() -> void:
	_contenedor.add_item("madera", 10)
	var ok = _contenedor.remove_item("madera", 3)
	assert_that(ok).is_true()
	assert_that(_contenedor.count_item("madera")).is_equal_to(7)

func test_remove_item_all() -> void:
	_contenedor.add_item("madera", 5)
	var ok = _contenedor.remove_item("madera", 5)
	assert_that(ok).is_true()
	assert_that(_contenedor.count_item("madera")).is_equal_to(0)
	assert_that(_contenedor.slots_usados()).is_equal_to(0)

func test_remove_item_insufficient() -> void:
	_contenedor.add_item("madera", 3)
	var ok = _contenedor.remove_item("madera", 5)
	assert_that(ok).is_false()
	assert_that(_contenedor.count_item("madera")).is_equal_to(3)

func test_remove_item_not_exists() -> void:
	var ok = _contenedor.remove_item("inexistente", 1)
	assert_that(ok).is_false()

func test_count_item_multiple_slots() -> void:
	_contenedor.add_item("madera", 10)
	_contenedor.add_item("piedra", 3)
	# count_item suma de todos los slots
	assert_that(_contenedor.count_item("madera")).is_equal_to(10)
	assert_that(_contenedor.count_item("piedra")).is_equal_to(3)
	assert_that(_contenedor.count_item("inexistente")).is_equal_to(0)

func test_serializar_only_occupied() -> void:
	_contenedor.add_item("madera", 5)
	_contenedor.add_item("piedra", 3)
	var data = _contenedor.serializar()
	# serializar() retorna Array de slots ocupados
	assert_that(data.size()).is_equal_to(2)

func test_deserializar() -> void:
	_contenedor.add_item("madera", 5)
	_contenedor.add_item("piedra", 3)
	var data = _contenedor.serializar()

	var nuevo = ContenedorInventario.new(ContainerType.Id.BOLSILLO, 10)
	nuevo.deserializar(data)
	assert_that(nuevo.count_item("madera")).is_equal_to(5)
	assert_that(nuevo.count_item("piedra")).is_equal_to(3)
	assert_that(nuevo.slots_usados()).is_equal_to(2)
	nuevo.free()

func test_slot_changed_on_add() -> void:
	var signal_count = 0
	_contenedor.slot_changed.connect(func(idx: int) -> void:
		signal_count += 1
	)
	_contenedor.add_item("madera", 5)
	assert_that(signal_count).is_equal_to(1)

func test_slot_changed_on_remove() -> void:
	_contenedor.add_item("madera", 5)
	var signal_count = 0
	_contenedor.slot_changed.connect(func(idx: int) -> void:
		signal_count += 1
	)
	_contenedor.remove_item("madera", 5)
	assert_that(signal_count).is_equal_to(1)
