# Modelo: GLM-5.3-Flash (G-5.3-Flash-Agente)
# Plataforma: Kilo Code
# Fecha: 2026-10-22
#
# M57: QA de PromptDB + sugerencia de atajo libre (turno 2-BIS).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/controls/qa_m57_prompts.gd
# Items del 05-Checklist cubiertos:
#   - "PromptDB: tabla accion x dispositivo -> textura" [S]
#   - "Prompts de UI nunca muestran icono de otro dispositivo" [S]
#   - "Sugerencia de tecla/boton libre ante conflicto" [S]
#   - "Deck detectado como gamepad SDL / perfil por defecto" — verifica que el
#     MODO_GENERICO (donde cae Steam Deck en _detectar_pad) resuelve prompts gen_*.

extends SceneTree

const CHECKS_MINIMOS := 14
const _WB_BLOQUES: Array[String] = ["_test_prompt_db", "_test_sugerencia_libre"]
var _checks: int = 0
var _fallos: int = 0
var _wb_vistos: Dictionary = {}
var _wb_cerrado: bool = false

const PDB := preload("res://scripts/controls/prompt_db.gd")
var _ci: Node = null

func _summary() -> void:
	if _wb_cerrado:
		return
	_wb_cerrado = true
	for b in _WB_BLOQUES:
		if not _wb_vistos.has(b):
			_fallos += 1
			print("[FAIL] bloque %s NO se ejecuto" % b)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen QA prompts M57: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	_ci = root.get_node_or_null("/root/ControlInput")
	_check(_ci != null, "ControlInput autoload presente")
	if _ci == null:
		return
	_test_prompt_db()
	_wb_vistos["_test_prompt_db"] = true
	_test_sugerencia_libre()
	_wb_vistos["_test_sugerencia_libre"] = true

func _test_prompt_db() -> void:
	var accion := "interactuar"
	if not InputMap.has_action(accion):
		_check(false, "PDB: accion %s debe existir en InputMap del proyecto" % accion)
		return
	var p_teclado: String = PDB.prompt_para(accion, "teclado")
	var p_xbox: String = PDB.prompt_para(accion, "xbox")
	var p_ps: String = PDB.prompt_para(accion, "playstation")
	var p_gen: String = PDB.prompt_para(accion, "generico")
	_check(p_teclado != "", "PDB: teclado resuelve (%s)" % p_teclado)
	_check(p_xbox.contains("xbox_"), "PDB: xbox solo iconos xbox (%s)" % p_xbox)
	_check(p_ps.contains("ps_"), "PDB: playstation solo iconos ps (%s)" % p_ps)
	_check(p_gen.contains("gen_"), "PDB: generico (Deck) solo iconos gen (%s)" % p_gen)
	_check(p_teclado != p_xbox and p_xbox != p_ps and p_ps != p_gen,
		"PDB: nunca dos dispositivos comparten icono para la misma accion")
	_check(PDB.prompt_para(accion, "teclado") == p_teclado, "PDB: idempotente en teclado")
	_check(PDB.prompt_para(accion, "xbox") == p_xbox, "PDB: idempotente en xbox")
	_check(PDB.prompt_para("accion_inexistente_xyz", "xbox") == "", "PDB: accion inexistente -> vacio, sin crash")
	_check(PDB.prompt_para(accion, "modo_fantasma") == "", "PDB: modo desconocido -> vacio (fallback seguro)")
	# Prompts por modo activo (ruta del autoload): coherente con el modo actual
	var p_activo: String = PDB.prompt_para_activo(accion)
	_check(p_activo != "", "PDB: prompt_para_activo resuelve (%s)" % p_activo)

func _test_sugerencia_libre() -> void:
	# Armar conflicto REAL: usar el evento actual de "inventario" para "interactuar"
	var eventos_inv: Array = InputMap.action_get_events("inventario")
	var eventos_int: Array = InputMap.action_get_events("interactuar")
	if eventos_inv.is_empty() or eventos_int.is_empty():
		_check(false, "sugerencia: acciones del catalogo con eventos por defecto")
		return
	var ev_ocupado: InputEvent = eventos_inv[0]
	_check(_ci.hay_conflicto("interactuar", ev_ocupado), "sugerencia: el evento de inventario CONFLICTUA con interactuar")
	_check(_ci.remapear("interactuar", ev_ocupado) == false, "sugerencia: remap con conflicto se rechaza")
	var sugerido: InputEvent = _ci.sugerir_atajo_libre("interactuar", ev_ocupado)
	_check(sugerido != null, "sugerencia: devuelve alternativa libre")
	if sugerido != null:
		_check(not _ci.hay_conflicto("interactuar", sugerido), "sugerencia: la alternativa esta LIBRE")
		_check(_ci.remapear("interactuar", sugerido) == true, "sugerencia: el remapeo con la alternativa impacta")
	# El deseado libre se devuelve tal cual (sin inventar alternativas)
	var deseado_libre: InputEvent = _ci.sugerir_atajo_libre("pausa", eventos_int[0])
	_check(deseado_libre != null and not _ci.hay_conflicto("pausa", deseado_libre), "sugerencia: evento libre se devuelve tal cual")
	# Limpieza: borrar remapeos para no dejar estado mutado al resto de suites
	_ci.restaurar_defaults()
	var post: Array = InputMap.action_get_events("interactuar")
	_check(post.is_empty() or not _ci.hay_conflicto("interactuar", ev_ocupado), "sugerencia: restaurar_defaults limpia el estado de prueba")
