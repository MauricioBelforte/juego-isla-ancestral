# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-04
#
# Unit tests ItemData + ItemDatabase
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
#   godot --headless --path game/isla-ancestral --script res://tests/unit/data/test_item_data.gd

extends SceneTree

const TIMEOUT_SEG := 60.0
## Piso MEDIDO en verde (se fija tras la 1a corrida).
const CHECKS_MINIMOS := 0
const BLOQUES_ESPERADOS: Array[String] = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R']


## Unit tests para ItemData (M159)
## Verifica la funcionalidad del catálogo de objetos

## --- ItemDatabase (M159) --- ##


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
	print("=== Unit tests ItemData + ItemDatabase (headless) ===")
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
	_bloque_P()
	_bloque_Q()
	_bloque_R()


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
	print("\n=== Resumen Unit tests ItemData + ItemDatabase: %d checks, %d fallos ===" % [_checks, _fallos])
	if _abortado:
		quit(1)
	elif _fallos == 0:
		print("TEST OK — todos los checks pasaron")
		quit(0)
	else:
		print("TEST FALLO — %d checks fallaron" % _fallos)
		quit(1)


func _bloque_A() -> void:
	_ini("A. test_instantiation")
	var item = ItemData.new()
	_check("item .is_not_null()", (item) != null)
	_check("item.id .is_equal_to(\"\")", (item.id) == (""))
	_check("item.nombre .is_equal_to(\"\")", (item.nombre) == (""))
	_check("item.categoria .is_equal_to(ItemData.Categoria.ITEMS)", (item.categoria) == (ItemData.Categoria.ITEMS))
	_check("item.rareza .is_equal_to(ItemData.Rareza.COMUN)", (item.rareza) == (ItemData.Rareza.COMUN))
	_check("item.apilable .is_true()", (item.apilable) == true)
	_check("item.stack_max .is_equal_to(10)", (item.stack_max) == (10))

	_fin("A. test_instantiation")


func _bloque_B() -> void:
	_ini("B. test_categoria_enum_values")
	_check("int(ItemData.Categoria.MOBILIARIO_INTERIOR) .is_equal_to(0)", (int(ItemData.Categoria.MOBILIARIO_INTERIOR)) == (0))
	_check("int(ItemData.Categoria.DECORACION_PARED) .is_equal_to(1)", (int(ItemData.Categoria.DECORACION_PARED)) == (1))
	_check("int(ItemData.Categoria.ILUMINACION) .is_equal_to(2)", (int(ItemData.Categoria.ILUMINACION)) == (2))
	_check("int(ItemData.Categoria.PLANTAS_INTERIOR) .is_equal_to(3)", (int(ItemData.Categoria.PLANTAS_INTERIOR)) == (3))
	_check("int(ItemData.Categoria.ALFOMBRAS) .is_equal_to(4)", (int(ItemData.Categoria.ALFOMBRAS)) == (4))
	_check("int(ItemData.Categoria.COCINA) .is_equal_to(5)", (int(ItemData.Categoria.COCINA)) == (5))
	_check("int(ItemData.Categoria.TRABAJO) .is_equal_to(6)", (int(ItemData.Categoria.TRABAJO)) == (6))
	_check("int(ItemData.Categoria.EXTERIORES) .is_equal_to(7)", (int(ItemData.Categoria.EXTERIORES)) == (7))
	_check("int(ItemData.Categoria.NATURALEZA) .is_equal_to(8)", (int(ItemData.Categoria.NATURALEZA)) == (8))
	_check("int(ItemData.Categoria.CONSTRUCCION) .is_equal_to(9)", (int(ItemData.Categoria.CONSTRUCCION)) == (9))
	_check("int(ItemData.Categoria.HERRAMIENTAS) .is_equal_to(10)", (int(ItemData.Categoria.HERRAMIENTAS)) == (10))
	_check("int(ItemData.Categoria.ITEMS) .is_equal_to(11)", (int(ItemData.Categoria.ITEMS)) == (11))
	_check("int(ItemData.Categoria.ROPA) .is_equal_to(12)", (int(ItemData.Categoria.ROPA)) == (12))
	_check("int(ItemData.Categoria.ARTE_ANCESTRAL) .is_equal_to(13)", (int(ItemData.Categoria.ARTE_ANCESTRAL)) == (13))
	_check("int(ItemData.Categoria.EVENTO) .is_equal_to(14)", (int(ItemData.Categoria.EVENTO)) == (14))
	_check("int(ItemData.Categoria.SECRETO) .is_equal_to(15)", (int(ItemData.Categoria.SECRETO)) == (15))

	_fin("B. test_categoria_enum_values")


func _bloque_C() -> void:
	_ini("C. test_rareza_enum_values")
	_check("int(ItemData.Rareza.COMUN) .is_equal_to(0)", (int(ItemData.Rareza.COMUN)) == (0))
	_check("int(ItemData.Rareza.POCHO_COMUN) .is_equal_to(1)", (int(ItemData.Rareza.POCHO_COMUN)) == (1))
	_check("int(ItemData.Rareza.RARO) .is_equal_to(2)", (int(ItemData.Rareza.RARO)) == (2))
	_check("int(ItemData.Rareza.LEGENDARIO) .is_equal_to(3)", (int(ItemData.Rareza.LEGENDARIO)) == (3))

	_fin("C. test_rareza_enum_values")


func _bloque_D() -> void:
	_ini("D. test_interaccion_enum_values")
	_check("int(ItemData.Interaccion.NINGUNA) .is_equal_to(0)", (int(ItemData.Interaccion.NINGUNA)) == (0))
	_check("int(ItemData.Interaccion.SENTARSE) .is_equal_to(1)", (int(ItemData.Interaccion.SENTARSE)) == (1))
	_check("int(ItemData.Interaccion.DORMIR) .is_equal_to(2)", (int(ItemData.Interaccion.DORMIR)) == (2))
	_check("int(ItemData.Interaccion.ALMACENAR) .is_equal_to(3)", (int(ItemData.Interaccion.ALMACENAR)) == (3))
	_check("int(ItemData.Interaccion.COCINAR) .is_equal_to(4)", (int(ItemData.Interaccion.COCINAR)) == (4))
	_check("int(ItemData.Interaccion.FABRICAR) .is_equal_to(5)", (int(ItemData.Interaccion.FABRICAR)) == (5))
	_check("int(ItemData.Interaccion.ENCENDER) .is_equal_to(6)", (int(ItemData.Interaccion.ENCENDER)) == (6))
	_check("int(ItemData.Interaccion.REGAR) .is_equal_to(7)", (int(ItemData.Interaccion.REGAR)) == (7))
	_check("int(ItemData.Interaccion.COLOCAR_ITEM) .is_equal_to(8)", (int(ItemData.Interaccion.COLOCAR_ITEM)) == (8))
	_check("int(ItemData.Interaccion.MIRAR) .is_equal_to(9)", (int(ItemData.Interaccion.MIRAR)) == (9))
	_check("int(ItemData.Interaccion.ESCULAR) .is_equal_to(10)", (int(ItemData.Interaccion.ESCULAR)) == (10))
	_check("int(ItemData.Interaccion.RECOGER) .is_equal_to(11)", (int(ItemData.Interaccion.RECOGER)) == (11))
	_check("int(ItemData.Interaccion.ROMPER) .is_equal_to(12)", (int(ItemData.Interaccion.ROMPER)) == (12))
	_check("int(ItemData.Interaccion.ABRIR_CERRAR) .is_equal_to(13)", (int(ItemData.Interaccion.ABRIR_CERRAR)) == (13))

	_fin("D. test_interaccion_enum_values")


func _bloque_E() -> void:
	_ini("E. test_se_puede_apilar_true")
	var item = ItemData.new()
	item.apilable = true
	item.stack_max = 10
	_check("item.se_puede_apilar(5) .is_true()", (item.se_puede_apilar(5)) == true)
	_check("item.se_puede_apilar(9) .is_true()", (item.se_puede_apilar(9)) == true)

	_fin("E. test_se_puede_apilar_true")


func _bloque_F() -> void:
	_ini("F. test_se_puede_apilar_false_not_stackable")
	var item = ItemData.new()
	item.apilable = false
	item.stack_max = 10
	_check("item.se_puede_apilar(1) .is_false()", (item.se_puede_apilar(1)) == false)

	_fin("F. test_se_puede_apilar_false_not_stackable")


func _bloque_G() -> void:
	_ini("G. test_se_puede_apilar_false_full")
	var item = ItemData.new()
	item.apilable = true
	item.stack_max = 10
	_check("item.se_puede_apilar(10) .is_false()", (item.se_puede_apilar(10)) == false)
	_check("item.se_puede_apilar(11) .is_false()", (item.se_puede_apilar(11)) == false)

	_fin("G. test_se_puede_apilar_false_full")


func _bloque_H() -> void:
	_ini("H. test_es_valido_true")
	var item = ItemData.new()
	item.id = "test_item_001"
	item.nombre = "Test Item"
	item.tamano = Vector2i(1, 1)
	_check("item.es_valido() .is_true()", (item.es_valido()) == true)

	_fin("H. test_es_valido_true")


func _bloque_I() -> void:
	_ini("I. test_es_valido_false_no_id")
	var item = ItemData.new()
	item.nombre = "Test Item"
	item.tamano = Vector2i(1, 1)
	_check("item.es_valido() .is_false()", (item.es_valido()) == false)

	_fin("I. test_es_valido_false_no_id")


func _bloque_J() -> void:
	_ini("J. test_es_valido_false_no_nombre")
	var item = ItemData.new()
	item.id = "test_item_001"
	item.tamano = Vector2i(1, 1)
	_check("item.es_valido() .is_false()", (item.es_valido()) == false)

	_fin("J. test_es_valido_false_no_nombre")


func _bloque_K() -> void:
	_ini("K. test_es_valido_false_invalid_size")
	var item = ItemData.new()
	item.id = "test_item_001"
	item.nombre = "Test Item"
	item.tamano = Vector2i(0, 1)
	_check("item.es_valido() .is_false()", (item.es_valido()) == false)

	item.tamano = Vector2i(1, 0)
	_check("item.es_valido() .is_false()", (item.es_valido()) == false)

	item.tamano = Vector2i(-1, 1)
	_check("item.es_valido() .is_false()", (item.es_valido()) == false)

	_fin("K. test_es_valido_false_invalid_size")


func _bloque_L() -> void:
	_ini("L. test_item_database_autoload_disponible")
	_check("_auto_ItemDatabase .is_not_null()", (_auto_ItemDatabase) != null)

	_fin("L. test_item_database_autoload_disponible")


func _bloque_M() -> void:
	_ini("M. test_item_database_tiene_items_cargados")
	_check("_auto_ItemDatabase.count() .is_greater_than(0)", (_auto_ItemDatabase.count()) > (0))

	_fin("M. test_item_database_tiene_items_cargados")


func _bloque_N() -> void:
	_ini("N. test_get_item_por_id_existente")
	var item = _auto_ItemDatabase.get_item("OBJ-COC-001")
	_check("item .is_not_null()", (item) != null)
	_check("item.nombre .is_equal_to(\"Horno de leña\")", (item.nombre) == ("Horno de leña"))

	_fin("N. test_get_item_por_id_existente")


func _bloque_O() -> void:
	_ini("O. test_get_item_por_id_inexistente")
	var item = _auto_ItemDatabase.get_item("OBJ-INE-000")
	_check("item .is_null()", (item) == null)

	_fin("O. test_get_item_por_id_inexistente")


func _bloque_P() -> void:
	_ini("P. test_get_items_by_category_cocina")
	var items = _auto_ItemDatabase.get_items_by_category(ItemData.Categoria.COCINA)
	_check("items.size() .is_greater_than(0)", (items.size()) > (0))
	for it in items:
		_check("it.categoria .is_equal_to(ItemData.Categoria.COCINA)", (it.categoria) == (ItemData.Categoria.COCINA))

	_fin("P. test_get_items_by_category_cocina")


func _bloque_Q() -> void:
	_ini("Q. test_get_items_by_rarity_comun")
	var items = _auto_ItemDatabase.get_items_by_rarity(ItemData.Rareza.COMUN)
	_check("items.size() .is_greater_than(0)", (items.size()) > (0))
	for it in items:
		_check("it.rareza .is_equal_to(ItemData.Rareza.COMUN)", (it.rareza) == (ItemData.Rareza.COMUN))

	_fin("Q. test_get_items_by_rarity_comun")


func _bloque_R() -> void:
	_ini("R. test_validar_ids_unicos_true")
	_check("_auto_ItemDatabase.validar_ids_unicos() .is_true()", (_auto_ItemDatabase.validar_ids_unicos()) == true)


	_fin("R. test_validar_ids_unicos_true")
