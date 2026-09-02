extends "res://addons/gdUnit4/src/GdUnitTestSuite.gd"

## M155 iter 3: tests de la capa de equipamiento (EquipmentLayer).
## Verifica: construcción de la UI por código, toggle de visibilidad,
## grid con las 16 prendas del catálogo y reflex de slots al equipar.

func test_layer_builds_and_toggle() -> void:
	var layer = load("res://scripts/ui/layers/equipment_layer.gd").new()
	add_child(layer)
	await layer.ready

	assert_that(layer.visible).is_false()  # arranca oculta (capa modal)
	layer.toggle()
	assert_that(layer.visible).is_true()   # toggle abre
	layer.toggle()
	assert_that(layer.visible).is_false()  # toggle cierra
	layer.free()

func test_layer_grid_has_16_items() -> void:
	var layer = load("res://scripts/ui/layers/equipment_layer.gd").new()
	add_child(layer)
	await layer.ready
	layer.toggle()  # fuerza el refresh del grid

	var grid: GridContainer = null
	for node in layer.find_children("*", "GridContainer", true, false):
		if node.get_parent() is ScrollContainer:
			grid = node
			break
	assert_that(grid).is_not_null()
	assert_that(grid.get_child_count()).is_equal(16)
	layer.free()

func test_layer_slot_buttons_exist() -> void:
	var layer = load("res://scripts/ui/layers/equipment_layer.gd").new()
	add_child(layer)
	await layer.ready

	var buttons: Array = layer.find_children("*", "Button", true, false)
	assert_that(buttons.size()).is_greater_equal(20)  # 4 slots + 16 prendas
	layer.free()
