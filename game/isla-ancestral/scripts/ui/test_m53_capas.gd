# Modelo: Ling 3.1 Flash
# Plataforma: Kilo Code
# Fecha: 2026-10-12
#
# M53 L.1/L.2: Edge cases de apilamiento de capas.
#   L.1: Inventario abierto + evento de diálogo → el diálogo se
#        apila y espera; al cerrarlo el inventario sigue operativo.
#   L.2: Diálogo (MODAL_FULL) abierto + request de inventario
#        (MODAL_SIMPLE) → el simple se apila sin competir ni
#        cerrar el diálogo.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/ui/test_m53_capas.gd
#
# E-30: en --script headless los class_name globales no resuelven
# en el scope del script SceneTree → preload explícito (GUIA-GODOT/06).

extends SceneTree

const _UI_LAYER := preload("res://scripts/ui/core/ui_layer.gd")
const _UI_LAYER_TYPE := preload("res://scripts/ui/core/ui_layer_type.gd")

var _fallos: int = 0
var _checks: int = 0
var _ui = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_ui = root.get_node_or_null("UIManager")
	_check(_ui != null, "UIManager autoload presente")
	if _ui == null:
		print("=== TEST M53 CAPAS (L.1/L.2): 1 fallo(s) ===")
		quit(1)
		return
	_test_l1_inventario_mas_dialogo()
	_test_l2_dialogo_mas_inventario()
	print("=== TEST M53 CAPAS (L.1/L.2): %d checks, %d fallo(s) ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

## Capa de prueba: UILayer con tipo configurable y un control enfocable
func _crear_capa(nombre: String, tipo: int) -> Node:
	var capa = _UI_LAYER.new()
	capa.name = nombre
	capa.layer_type = tipo
	# Las capas reales nacen ocultas (visible=false en _ready):
	# open() cambia la visibilidad y dispara
	# NOTIFICATION_VISIBILITY_CHANGED → _actualizar_pausa_mundo.
	capa.visible = false
	var btn := Button.new()
	btn.name = "Btn"
	btn.text = nombre
	capa.add_child(btn)
	root.add_child(capa)  # _enter_tree registra en UIManager
	return capa

func _test_l1_inventario_mas_dialogo() -> void:
	var inventario := _crear_capa("InvTestL1", _UI_LAYER_TYPE.Type.MODAL_SIMPLE)
	var dialogo := _crear_capa("DlgTestL1", _UI_LAYER_TYPE.Type.MODAL_FULL)
	# Inventario abierto
	inventario.open()
	_check(inventario.visible, "L1: inventario visible tras open()")
	# Evento de diálogo mientras el inventario está abierto:
	# el diálogo se apila y espera; no destruye el inventario
	dialogo.open()
	_check(dialogo.visible, "L1: diálogo visible (se apila sobre el inventario)")
	_check(inventario.visible, "L1: inventario sigue visible bajo el diálogo")
	_check(_ui.top() == dialogo, "L1: el diálogo queda en el tope de la pila")
	_check(paused, "L1: mundo pausado (MODAL_FULL visible)")
	# Cerrar el diálogo: el inventario (que esperaba) queda operativo
	dialogo.close()
	_check(not dialogo.visible, "L1: diálogo cerrado")
	_check(inventario.visible, "L1: inventario sigue abierto tras cerrar el diálogo")
	_check(not paused, "L1: mundo reanudado al cerrar el MODAL_FULL")
	inventario.close()
	inventario.queue_free()
	dialogo.queue_free()

func _test_l2_dialogo_mas_inventario() -> void:
	var dialogo := _crear_capa("DlgTestL2", _UI_LAYER_TYPE.Type.MODAL_FULL)
	var inventario := _crear_capa("InvTestL2", _UI_LAYER_TYPE.Type.MODAL_SIMPLE)
	dialogo.open()
	# Request de inventario mientras el diálogo (modal full) está abierto:
	# el modal simple se apila encima sin competir ni cerrar el diálogo
	inventario.open()
	_check(inventario.visible, "L2: inventario (modal simple) visible sobre el diálogo")
	_check(dialogo.visible, "L2: el diálogo no compite: sigue visible bajo el inventario")
	_check(_ui.top() == inventario, "L2: el inventario queda en el tope")
	# Cerrar el inventario (close_top purga la capa visible más reciente, T-M1)
	_ui.close_top()
	_check(not inventario.visible, "L2: inventario cerrado por close_top")
	_check(dialogo.visible, "L2: el diálogo sigue abierto")
	dialogo.close()
	dialogo.queue_free()
	inventario.queue_free()
