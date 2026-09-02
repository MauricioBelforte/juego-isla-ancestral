extends "res://addons/gdUnit4/src/GdUnitTestSuite.gd"

## Unit tests para ItemData (M159)
## Verifica la funcionalidad del catálogo de objetos

func test_instantiation() -> void:
	var item = ItemData.new()
	assert_that(item).is_not_null()
	assert_that(item.id).is_equal_to("")
	assert_that(item.nombre).is_equal_to("")
	assert_that(item.categoria).is_equal_to(ItemData.Categoria.ITEMS)
	assert_that(item.rareza).is_equal_to(ItemData.Rareza.COMUN)
	assert_that(item.apilable).is_true()
	assert_that(item.stack_max).is_equal_to(10)

func test_categoria_enum_values() -> void:
	assert_that(int(ItemData.Categoria.MOBILIARIO_INTERIOR)).is_equal_to(0)
	assert_that(int(ItemData.Categoria.DECORACION_PARED)).is_equal_to(1)
	assert_that(int(ItemData.Categoria.ILUMINACION)).is_equal_to(2)
	assert_that(int(ItemData.Categoria.PLANTAS_INTERIOR)).is_equal_to(3)
	assert_that(int(ItemData.Categoria.ALFOMBRAS)).is_equal_to(4)
	assert_that(int(ItemData.Categoria.COCINA)).is_equal_to(5)
	assert_that(int(ItemData.Categoria.TRABAJO)).is_equal_to(6)
	assert_that(int(ItemData.Categoria.EXTERIORES)).is_equal_to(7)
	assert_that(int(ItemData.Categoria.NATURALEZA)).is_equal_to(8)
	assert_that(int(ItemData.Categoria.CONSTRUCCION)).is_equal_to(9)
	assert_that(int(ItemData.Categoria.HERRAMIENTAS)).is_equal_to(10)
	assert_that(int(ItemData.Categoria.ITEMS)).is_equal_to(11)
	assert_that(int(ItemData.Categoria.ROPA)).is_equal_to(12)
	assert_that(int(ItemData.Categoria.ARTE_ANCESTRAL)).is_equal_to(13)
	assert_that(int(ItemData.Categoria.EVENTO)).is_equal_to(14)
	assert_that(int(ItemData.Categoria.SECRETO)).is_equal_to(15)

func test_rareza_enum_values() -> void:
	assert_that(int(ItemData.Rareza.COMUN)).is_equal_to(0)
	assert_that(int(ItemData.Rareza.POCHO_COMUN)).is_equal_to(1)
	assert_that(int(ItemData.Rareza.RARO)).is_equal_to(2)
	assert_that(int(ItemData.Rareza.LEGENDARIO)).is_equal_to(3)

func test_interaccion_enum_values() -> void:
	assert_that(int(ItemData.Interaccion.NINGUNA)).is_equal_to(0)
	assert_that(int(ItemData.Interaccion.SENTARSE)).is_equal_to(1)
	assert_that(int(ItemData.Interaccion.DORMIR)).is_equal_to(2)
	assert_that(int(ItemData.Interaccion.ALMACENAR)).is_equal_to(3)
	assert_that(int(ItemData.Interaccion.COCINAR)).is_equal_to(4)
	assert_that(int(ItemData.Interaccion.FABRICAR)).is_equal_to(5)
	assert_that(int(ItemData.Interaccion.ENCENDER)).is_equal_to(6)
	assert_that(int(ItemData.Interaccion.REGAR)).is_equal_to(7)
	assert_that(int(ItemData.Interaccion.COLOCAR_ITEM)).is_equal_to(8)
	assert_that(int(ItemData.Interaccion.MIRAR)).is_equal_to(9)
	assert_that(int(ItemData.Interaccion.ESCULAR)).is_equal_to(10)
	assert_that(int(ItemData.Interaccion.RECOGER)).is_equal_to(11)
	assert_that(int(ItemData.Interaccion.ROMPER)).is_equal_to(12)
	assert_that(int(ItemData.Interaccion.ABRIR_CERRAR)).is_equal_to(13)

func test_se_puede_apilar_true() -> void:
	var item = ItemData.new()
	item.apilable = true
	item.stack_max = 10
	assert_that(item.se_puede_apilar(5)).is_true()
	assert_that(item.se_puede_apilar(9)).is_true()

func test_se_puede_apilar_false_not_stackable() -> void:
	var item = ItemData.new()
	item.apilable = false
	item.stack_max = 10
	assert_that(item.se_puede_apilar(1)).is_false()

func test_se_puede_apilar_false_full() -> void:
	var item = ItemData.new()
	item.apilable = true
	item.stack_max = 10
	assert_that(item.se_puede_apilar(10)).is_false()
	assert_that(item.se_puede_apilar(11)).is_false()

func test_es_valido_true() -> void:
	var item = ItemData.new()
	item.id = "test_item_001"
	item.nombre = "Test Item"
	item.tamano = Vector2i(1, 1)
	assert_that(item.es_valido()).is_true()

func test_es_valido_false_no_id() -> void:
	var item = ItemData.new()
	item.nombre = "Test Item"
	item.tamano = Vector2i(1, 1)
	assert_that(item.es_valido()).is_false()

func test_es_valido_false_no_nombre() -> void:
	var item = ItemData.new()
	item.id = "test_item_001"
	item.tamano = Vector2i(1, 1)
	assert_that(item.es_valido()).is_false()

func test_es_valido_false_invalid_size() -> void:
	var item = ItemData.new()
	item.id = "test_item_001"
	item.nombre = "Test Item"
	item.tamano = Vector2i(0, 1)
	assert_that(item.es_valido()).is_false()

	item.tamano = Vector2i(1, 0)
	assert_that(item.es_valido()).is_false()

	item.tamano = Vector2i(-1, 1)
	assert_that(item.es_valido()).is_false()

## --- ItemDatabase (M159) --- ##

func test_item_database_autoload_disponible() -> void:
	assert_that(ItemDatabase).is_not_null()

func test_item_database_tiene_items_cargados() -> void:
	assert_that(ItemDatabase.count()).is_greater_than(0)

func test_get_item_por_id_existente() -> void:
	var item := ItemDatabase.get_item("OBJ-COC-001")
	assert_that(item).is_not_null()
	assert_that(item.nombre).is_equal_to("Horno de leña")

func test_get_item_por_id_inexistente() -> void:
	var item := ItemDatabase.get_item("OBJ-INE-000")
	assert_that(item).is_null()

func test_get_items_by_category_cocina() -> void:
	var items := ItemDatabase.get_items_by_category(ItemData.Categoria.COCINA)
	assert_that(items.size()).is_greater_than(0)
	for it in items:
		assert_that(it.categoria).is_equal_to(ItemData.Categoria.COCINA)

func test_get_items_by_rarity_comun() -> void:
	var items := ItemDatabase.get_items_by_rarity(ItemData.Rareza.COMUN)
	assert_that(items.size()).is_greater_than(0)
	for it in items:
		assert_that(it.rareza).is_equal_to(ItemData.Rareza.COMUN)

func test_validar_ids_unicos_true() -> void:
	assert_that(ItemDatabase.validar_ids_unicos()).is_true()

