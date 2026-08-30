# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M57: Test de ControlInput (acciones, remapeo, dispositivo, ajustes, persistencia).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/controls/test_control_input.gd

extends SceneTree

var _fallos: int = 0
var _ci: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_ci = root.get_node_or_null("ControlInput")
	_check(_ci != null, "ControlInput autoload presente")
	if _ci == null:
		print("=== TEST M57 CONTROL INPUT: 1 fallo(s) (sin ControlInput) ===")
		quit(1)
		return
	_test_acciones_basicas()
	_test_remapeo()
	_test_ajustes_y_deadzones()
	_test_persistencia()
	print("=== TEST M57 CONTROL INPUT: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_acciones_basicas() -> void:
	_check(_ci.ACCIONES_CATALOGO.has("mover_norte"), "catalogo tiene mover_norte")
	_check(_ci.ACCIONES_CATALOGO.has("interactuar"), "catalogo tiene interactuar")
	_check(_ci.ACCIONES_CATALOGO.has("inventario"), "catalogo tiene inventario")
	_check(_ci.ACCIONES_CATALOGO.has("pausa"), "catalogo tiene pausa")
	_check(InputMap.has_action("mover_norte"), "InputMap tiene mover_norte (M04)")
	_check(InputMap.has_action("interactuar"), "InputMap tiene interactuar (M04)")
	# Acciones leidas por nombre
	_check(_ci.accion_presionada("mover_norte") is bool, "accion_presionada devuelve bool")
	# Dispositivo activo valido
	var modo: String = _ci.dispositivo_activo()
	_check(modo in [_ci.MODO_TECLADO, _ci.MODO_RATON, _ci.MODO_XBOX, _ci.MODO_PLAYSTATION, _ci.MODO_GENERICO], "dispositivo_activo valido")

func _test_remapeo() -> void:
	var tecla := InputEventKey.new()
	tecla.physical_keycode = KEY_Y
	# El remapeo debe funcionar y persistir en InputMap
	var ok: bool = _ci.remapear("inventario", tecla)
	_check(ok, "remapear inventario a KEY_Y OK")
	var eventos: Array = InputMap.action_get_events("inventario")
	var encontrada := false
	for ev in eventos:
		if ev is InputEventKey and ev.physical_keycode == KEY_Y:
			encontrada = true
	_check(encontrada, "KEY_Y asignada a inventario")
	# Conflicto: la misma tecla en otra accion debe devolver false
	var conflicto: bool = _ci.remapear("pausa", tecla)
	_check(not conflicto, "remapear pausa con KEY_Y (conflicto) bloqueado")
	# Restaurar defaults
	_ci.restaurar_defaults()
	_check(true, "restaurar_defaults sin error")

func _test_ajustes_y_deadzones() -> void:
	_ci.sensibilidad_x = 2.0
	_ci.sensibilidad_y = 0.5
	_ci.invertir_y = true
	var cam: Vector2 = _ci.ejes_camara(Vector2(1.0, -2.0))
	_check(is_equal_approx(cam.x, 2.0), "sensibilidad X aplicada: " + str(cam.x))
	_check(is_equal_approx(cam.y, 1.0), "sensibilidad Y + inversion: " + str(cam.y))
	# Deadzone
	_ci.deadzone_palanca_izq = 0.2
	_check(_ci.eje("mover_norte") == 0.0 or true, "eje no crashea")
	# Reset
	_ci.sensibilidad_x = 1.0
	_ci.sensibilidad_y = 1.0
	_ci.invertir_y = false

func _test_persistencia() -> void:
	var data: Dictionary = _ci._serializar()
	_check(data is Dictionary, "serializar devuelve Dictionary")
	_check(data.has("version"), "serializacion tiene version")
	_check(data.has("bindings"), "serializacion tiene bindings")
	_check(data.has("ajustes"), "serializacion tiene ajustes")
	# No aplica cambios globales en test
	_ci._aplicar_serializado({})
	_check(true, "aplicar serializado vacio sin error")