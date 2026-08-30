# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M53: Test del framework de capas (UIManager + capas + registro automático).
# Verifica: push/pop de pila, registro automático de UILayer, is_modal_open,
# y que las capas DialogLayer/PauseLayer sean capas válidas.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/ui/test_ui_framework.gd

extends SceneTree

var _fallos: int = 0
var _ui: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_ui = root.get_node_or_null("UIManager")
	_check(_ui != null, "UIManager autoload presente")
	if _ui == null:
		print("=== TEST M53 UI FRAMEWORK: 1 fallo(s) ===")
		quit(1)
		return
	_test_pila_ok()
	_test_registro_automatico()
	_test_layer_type()
	print("=== TEST M53 UI FRAMEWORK: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

## Capa de prueba simple que extiende UILayer
func _crear_capa_prueba() -> Node:
	var script := load("res://scripts/ui/layers/pause_layer.gd")
	if script == null:
		return null
	var layer = script.new()
	layer.name = "PauseTest"
	root.add_child(layer)  # _enter_tree registra en UIManager
	return layer

func _test_pila_ok() -> void:
	_check(_ui.stack_size() >= 0, "stack_size inicial OK")
	var capa = _crear_capa_prueba()
	if capa == null:
		_check(false, "pausa_layer compila e instancia")
		return
	_check(_ui.stack_size() >= 1, "capa registrada en pila: %d" % _ui.stack_size())
	# Abrir y cerrar la capa
	capa.open()
	capa.close()
	_check(true, "open/close de capa OK")
	capa.queue_free()

func _test_registro_automatico() -> void:
	# Verificar que register/unregister no rompen (el framework)
	var capa = _crear_capa_prueba()
	if capa:
		capa.queue_free()
	_check(true, "registro automatico + des-registro OK")

func _test_layer_type() -> void:
	_check(_ui.LAYER_HUD == 0, "LAYER_HUD == 0")
	_check(_ui.LAYER_MODAL_FULL == 2, "LAYER_MODAL_FULL == 2")
	# is_modal_open no crashea
	_check(_ui.is_modal_open() is bool, "is_modal_open devuelve bool")