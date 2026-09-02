# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M57: Test iter. 2 — migración gameplay a ControlInput (RF2 capa única).
# Complementa test_control_input.gd (núcleo Deepseek, Log 254) — no lo reemplaza.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/controls/test_migracion_m57.gd

extends SceneTree

var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_inputmap_acciones()
	_test_vector_ejes_corregidos()
	_test_player_migrado()
	_test_simple_walk_migrado()
	print("=== TEST M57 MIGRACION: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_inputmap_acciones() -> void:
	# RF2: las acciones de gameplay existen en el InputMap (M04)
	for accion in ["mover_norte", "mover_sur", "mover_este", "mover_oeste",
			"interactuar", "inventario", "pausa", "colocar", "favorito", "saltar"]:
		_check(InputMap.has_action(accion), "acción '%s' en InputMap" % accion)

func _test_vector_ejes_corregidos() -> void:
	# M57 iter. 2: vector_movimiento con ejes corregidos — sin input real,
	# devuelve ZERO (dead zone), pero verifica que el método existe y no crashea
	var ci := root.get_node_or_null("ControlInput")
	_check(ci != null, "ControlInput autoload presente")
	if ci == null:
		return
	var v: Vector2 = ci.vector_movimiento()
	_check(v == Vector2.ZERO, "sin input real: vector = ZERO (dead zone)")
	_check(ci.has_method("accion_justa") and ci.has_method("accion_presionada"),
		"API de acciones presente (RF2)")

func _test_player_migrado() -> void:
	# RF2: player.gd migrado — tiene el helper _accion_justa_m57 y ya NO usa
	# Input directo para el cierre del inventario (usa el helper).
	var script := load("res://scripts/player/player.gd")
	_check(script != null, "player.gd carga")
	if script == null:
		return
	var source: String = script.source_code
	_check(source.contains("_accion_justa_m57"), "player.gd usa helper _accion_justa_m57")
	_check(not source.contains('Input.is_action_just_pressed("ui_cancel")'),
		"player.gd sin Input directo para ui_cancel (migrado)")

func _test_simple_walk_migrado() -> void:
	# RF2: simple_walk.gd migrado — ControlInput con fallback; salto via "saltar"
	var script := load("res://scripts/simple_walk.gd")
	_check(script != null, "simple_walk.gd carga")
	if script == null:
		return
	var source: String = script.source_code
	_check(source.contains("ControlInput"), "simple_walk usa ControlInput")
	_check(source.contains('"saltar"'), "simple_walk salta via acción 'saltar' (no ui_accept)")
	# El Input directo solo queda como FALLBACK explícito cuando ControlInput
	# no está disponible (headless); el camino de gameplay es ControlInput.
	var usa_controlinput_primero: bool = source.find("ci != null and ci.accion_justa") != -1
	_check(usa_controlinput_primero, "camino principal de gameplay via ControlInput (fallback solo headless)")
	_check(source.contains("vector_movimiento"), "simple_walk mueve via vector_movimiento (dead zone RF4)")
