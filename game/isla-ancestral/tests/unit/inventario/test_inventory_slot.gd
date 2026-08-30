extends "res://addons/gdUnit4/src/GdUnitTestSuite.gd"

## Unit tests para InventorySlot (M14)
## Verifica la funcionalidad del slot individual de inventario

func test_slot_empty_by_default() -> void:
	var slot = InventorySlot.new()
	assert_that(slot.esta_libre()).is_true()
	assert_that(slot.item_id).is_equal_to("")
	assert_that(slot.cantidad).is_equal_to(0)
	assert_that(slot.favorito).is_false()
	assert_that(slot.bloqueado).is_false()

func test_ocupar() -> void:
	var slot = InventorySlot.new()
	var instancia = {"durability": 80, "level": 2}
	slot.ocupar("pico_hierro", 1, instancia)
	assert_that(slot.item_id).is_equal_to("pico_hierro")
	assert_that(slot.cantidad).is_equal_to(1)
	assert_that(slot.instancia).is_equal_to(instancia)
	assert_that(slot.esta_libre()).is_false()

func test_vaciar() -> void:
	var slot = InventorySlot.new()
	slot.ocupar("madera", 50)
	slot.vaciar()
	assert_that(slot.esta_libre()).is_true()
	assert_that(slot.item_id).is_equal_to("")
	assert_that(slot.cantidad).is_equal_to(0)
	assert_that(slot.instancia).is_empty()

func test_puede_apilar_true() -> void:
	var slot = InventorySlot.new()
	slot.ocupar("piedra", 10)
	assert_that(slot.puede_apilar(5, 99)).is_true()
	assert_that(slot.puede_apilar(89, 99)).is_true()

func test_puede_apilar_false_different_item() -> void:
	var slot = InventorySlot.new()
	slot.ocupar("madera", 10)
	assert_that(slot.puede_apilar(5, 99)).is_false()

func test_puede_apilar_false_exceeds_max() -> void:
	var slot = InventorySlot.new()
	slot.ocupar("piedra", 10)
	assert_that(slot.puede_apilar(90, 99)).is_false()

func test_serializar_empty_slot() -> void:
	var slot = InventorySlot.new()
	var data = slot.serializar()
	assert_that(data.is_empty()).is_true()

func test_serializar_full_slot() -> void:
	var slot = InventorySlot.new()
	slot.ocupar("pico_hierro", 1, {"durability": 80})
	slot.favorito = true
	slot.bloqueado = true
	var data = slot.serializar()
	assert_that(data.id).is_equal_to("pico_hierro")
	assert_that(data.n).is_equal_to(1)
	assert_that(data.fav).is_true()
	assert_that(data.lock).is_true()
	assert_that(data.inst.durability).is_equal_to(80)

func test_deserializar() -> void:
	var data = {
		"id": "espada_madera",
		"n": 1,
		"fav": true,
		"lock": false,
		"inst": {"level": 3}
	}
	var slot = InventorySlot.deserializar(data)
	assert_that(slot.item_id).is_equal_to("espada_madera")
	assert_that(slot.cantidad).is_equal_to(1)
	assert_that(slot.favorito).is_true()
	assert_that(slot.bloqueado).is_false()
	assert_that(slot.instancia.level).is_equal_to(3)

func test_deserializar_defaults() -> void:
	var data = {"id": "test"}
	var slot = InventorySlot.deserializar(data)
	assert_that(slot.item_id).is_equal_to("test")
	assert_that(slot.cantidad).is_equal_to(0)
	assert_that(slot.favorito).is_false()
	assert_that(slot.bloqueado).is_false()
	assert_that(slot.instancia).is_empty()
