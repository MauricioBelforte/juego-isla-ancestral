@tool
extends RefCounted

##
# Helpers comunes para tests GdUnit4
# Incluye utilidades de espera, carga de escenas, simulación de tiempo, etc.
#
# NOTA: Los métodos que requieren SceneTree (get_tree()) deben llamarse desde
# un contexto donde exista el árbol (ej. dentro de un test GdUnit que corre en una escena).
# El LSP reporta errores porque parsea el archivo en aislamiento sin SceneTree.

class_name TestHelpers

## Espera un número de frames (útil para procesos asíncronos)
## Requiere que se ejecute dentro de un contexto con SceneTree
static func await_frames(tree: SceneTree, n: int = 1) -> void:
	for i in n:
		await tree.process_frame

## Espera un número de physics frames
## Requiere que se ejecute dentro de un contexto con SceneTree
static func await_physics_frames(tree: SceneTree, n: int = 1) -> void:
	for i in n:
		await tree.physics_frame

## Avanza el tiempo del juego (mock para tests de tiempo/calendario)
static func advance_days(days: int) -> void:
	# Requiere TimeCalendar en autoload
	var root = Engine.get_main_loop()
	if root == null:
		push_warning("No hay main loop para advance_days")
		return
	var calendar = root.root.get_node_or_null("/root/TimeCalendar")
	if calendar != null and calendar.has_method("avanzar_hasta"):
		var current_day = calendar.get_dia()
		calendar.avanzar_hasta(current_day + days, 8, 0)
	else:
		push_warning("TimeCalendar no disponible para advance_days")

## Carga una escena con limpieza automática
## Requiere SceneTree válido
static func load_scene(tree: SceneTree, path: String) -> Node:
	var scene = load(path)
	if scene == null:
		push_error("No se pudo cargar la escena: ", path)
		return null
	var instance = scene.instantiate()
	tree.root.add_child(instance)
	# Limpiar al salir del scope del test (usar con defer en tearDown)
	return instance

## Ejecuta el game loop por N segundos con reloj mockeado
## Requiere que se ejecute dentro de un contexto con SceneTree
static func run_game_loop(tree: SceneTree, seconds: float) -> void:
	var start_time = Time.get_ticks_msec()
	while Time.get_ticks_msec() - start_time < seconds * 1000:
		await tree.process_frame

## Crea un autoload mock para tests
## Requiere SceneTree válido
static func create_mock_autoload(tree: SceneTree, script_path: String, name: String) -> Object:
	var script = load(script_path)
	if script == null:
		push_error("No se pudo cargar script para mock: ", script_path)
		return null
	var instance = script.new()
	# Agregar al árbol como autoload temporal
	tree.root.add_child(instance)
	instance.name = name
	return instance

## Limpia un mock autoload
## Requiere SceneTree válido
static func cleanup_mock_autoload(tree: SceneTree, name: String) -> void:
	var node = tree.root.get_node_or_null(name)
	if node != null:
		node.queue_free()

## Genera datos sintéticos de save para tests
static func generate_save_data() -> Dictionary:
	return {
		"meta": {
			"version": 1,
			"timestamp": 0,  # timestamp placeholder, set in tests if needed
			"game_version": "0.1.0"
		},
		"economy": {
			"saldo": 100
		},
		"inventory": {
			"BOLSILLO": [],
			"MOCHILA": [],
			"CASA": []
		},
		"time": {
			"hora": 8,
			"minuto": 0,
			"dia": 1,
			"mes": 1,
			"anio": 1,
			"estacion": 0
		}
	}

## Compara dos diccionarios recursivamente (para validar saves)
static func dicts_equal(a: Dictionary, b: Dictionary, ignore_keys: Array[String] = []) -> bool:
	if a.size() != b.size():
		return false
	for key in a.keys():
		if key in ignore_keys:
			continue
		if not b.has(key):
			return false
		var val_a = a[key]
		var val_b = b[key]
		if typeof(val_a) == TYPE_DICTIONARY and typeof(val_b) == TYPE_DICTIONARY:
			if not dicts_equal(val_a, val_b, ignore_keys):
				return false
		elif typeof(val_a) == TYPE_ARRAY and typeof(val_b) == TYPE_ARRAY:
			if not arrays_equal(val_a, val_b):
				return false
		elif val_a != val_b:
			return false
	return true

## Compara dos arrays recursivamente
static func arrays_equal(a: Array, b: Array) -> bool:
	if a.size() != b.size():
		return false
	for i in a.size():
		var val_a = a[i]
		var val_b = b[i]
		if typeof(val_a) == TYPE_DICTIONARY and typeof(val_b) == TYPE_DICTIONARY:
			if not dicts_equal(val_a, val_b):
				return false
		elif typeof(val_a) == TYPE_ARRAY and typeof(val_b) == TYPE_ARRAY:
			if not arrays_equal(val_a, val_b):
				return false
		elif val_a != val_b:
			return false
	return true

## Verifica que un objeto implementa una interfaz (duck typing)
static func implements_interface(obj: Object, interface_methods: Array[String]) -> bool:
	for method in interface_methods:
		if not obj.has_method(method):
			return false
	return true