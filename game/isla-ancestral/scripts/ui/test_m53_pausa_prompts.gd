# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy AI
# Fecha: 2026-10-26
#
# M53 — G1-002 (Esc no abría la pausa) + L187 (prompts por dispositivo).
#
#   A. API nueva de UIManager: `abrir_pausa()` y `hay_capa_visible()` existen y
#      `_capa_visible()` devuelve null cuando no hay capa visible.
#   B. `abrir_pausa()` abre la PauseLayer, la deja en la pila, marca
#      `is_modal_open()` y CONGELA el mundo (`get_tree().paused`).
#   C. REGRESIÓN G1-002: con la pausa abierta, Esc CIERRA (close_top) y no
#      reabre; el mundo se reanuda.
#   D. REGRESIÓN G1-002 (el bug exacto): tras cerrar, la capa quedó FUERA de la
#      pila; un segundo Esc debe REABRIRLA y re-registrarla. Antes, el tope
#      calculado era la última capa registrada y OCULTA y `close_top()` la
#      des-registraba: Esc no abría nada.
#   E. `abrir_pausa()` dos veces no duplica (la segunda devuelve false).
#   F. L187: el texto del prompt depende del DISPOSITIVO. Con el InputMap real
#      (un solo evento, de teclado) antes salía siempre la tecla; ahora teclado
#      -> tecla, gamepad_xbox -> botón de pad, gamepad_ps -> botón de pad,
#      gamepad_generic -> botón de pad.
#   G. L187: fallback al DEVICE_MAP por CLAVE DE PROMPT (antes usaba la acción
#      cruda y devolvía "?") + `_on_device_changed` mapea "generico"/"raton".
#
# Guardián de 3 capas: `_fin("X")` al final del cuerpo de cada bloque,
# `CHECKS_MINIMOS` medido en verde y `_summary()` en un call_deferred APARTE
# (si `_run()` aborta por SCRIPT ERROR, la cola diferida sigue y el resumen
# nombra los bloques que no cerraron).
#
# Ejecutar: Godot --headless --path game/isla-ancestral \
#             --script res://scripts/ui/test_m53_pausa_prompts.gd

extends SceneTree

const _PAUSE := preload("res://scripts/ui/layers/pause_layer.gd")
const _OVERLAY := preload("res://scripts/ui/widgets/action_prompt_overlay.gd")

## Piso MEDIDO en verde (35 en la corrida del 2026-10-26). No estimado.
const CHECKS_MINIMOS := 35

const BLOQUES := ["A", "B", "C", "D", "E", "F", "G", "H"]

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}
var _ui = null
var _pausa = null
var _overlay = null


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	_ui = root.get_node_or_null("UIManager")
	_check(_ui != null, "UIManager autoload presente")
	if _ui == null:
		_fin("A")
		_fin("B")
		_fin("C")
		_fin("D")
		_fin("E")
		_fin("F")
		_fin("G")
		return
	_montar_pausa()
	_bloque_a_api()
	_bloque_b_abrir()
	_bloque_c_esc_cierra()
	_bloque_d_esc_reabre()
	_bloque_e_sin_duplicar()
	_bloque_h_continuar_desde_boton()
	_bloque_f_prompt_por_dispositivo()
	_bloque_g_fallback_y_modos()


# ── Montaje ─────────────────────────────────────────────

## Instancia la PauseLayer como hace ui_root.gd (nombre exacto "PauseLayer"):
## `_buscar_capa()` la resuelve por nombre y `_enter_tree` la registra.
func _montar_pausa() -> void:
	_pausa = _PAUSE.new()
	_pausa.name = "PauseLayer"
	root.add_child(_pausa)
	_overlay = _OVERLAY.new()
	_overlay.name = "ActionPromptOverlay"
	root.add_child(_overlay)


# ── Bloques ─────────────────────────────────────────────

func _bloque_a_api() -> void:
	_check(_ui.has_method("abrir_pausa"), "A1 UIManager expone abrir_pausa()")
	_check(_ui.has_method("hay_capa_visible"), "A2 UIManager expone hay_capa_visible()")
	_check(_ui.has_method("_capa_visible"), "A3 UIManager tiene _capa_visible()")
	# La pausa existe pero esta OCULTA: no cuenta como capa visible.
	_check(_pausa.visible == false, "A4 PauseLayer arranca oculta")
	_check(_ui.hay_capa_visible() == false, "A5 sin capa visible -> hay_capa_visible() false")
	_check(_ui.call("_capa_visible") == null, "A6 _capa_visible() null sin capas visibles")
	_check(_pausa in _ui._stack, "A7 PauseLayer registrada en la pila de UIManager")
	_fin("A")


func _bloque_b_abrir() -> void:
	var abierto: bool = _ui.abrir_pausa()
	_check(abierto, "B1 abrir_pausa() devuelve true")
	_check(_pausa.visible, "B2 PauseLayer visible tras abrir_pausa()")
	_check(_ui.hay_capa_visible(), "B3 hay_capa_visible() true con la pausa abierta")
	_check(_ui.is_modal_open(), "B4 is_modal_open() true (open() no tocaba _current_modal_full)")
	_check(paused, "B5 el mundo queda CONGELADO (get_tree().paused)")
	_fin("B")


func _bloque_c_esc_cierra() -> void:
	_ui._unhandled_input(_evento_pausa())
	_check(_pausa.visible == false, "C1 Esc CIERRA la pausa abierta")
	_check(not paused, "C2 el mundo se REANUDA al cerrar")
	_fin("C")


func _bloque_d_esc_reabre() -> void:
	# close_top() hace pop_layer -> la capa sale de la pila. Este es el estado
	# que antes dejaba a Esc sin efecto.
	_check(not (_pausa in _ui._stack), "D1 tras cerrar, la pausa quedo FUERA de la pila")
	_check(_ui.hay_capa_visible() == false, "D2 sin capa visible (estado de gameplay)")
	var reabierto: bool = false
	_ui._unhandled_input(_evento_pausa())
	reabierto = _pausa.visible
	_check(reabierto, "D3 Esc en gameplay ABRE la pausa (G1-002)")
	_check(_pausa in _ui._stack, "D4 al reabrir, la pausa vuelve a la pila")
	_check(paused, "D5 y el mundo se congela igual (estaba fuera de la pila)")
	_fin("D")


func _bloque_e_sin_duplicar() -> void:
	var otra: bool = _ui.abrir_pausa()
	_check(otra == false, "E1 abrir_pausa() con la pausa ya abierta devuelve false")
	var n := 0
	for l in _ui._stack:
		if l != null and l.name == "PauseLayer":
			n += 1
	_check(n == 1, "E2 PauseLayer aparece UNA sola vez en la pila (%d)" % n)
	_fin("E")


func _bloque_h_continuar_desde_boton() -> void:
	var botones: Array[Button] = _pausa._buttons
	_check(not botones.is_empty(), "H1 PauseLayer tiene botón Continuar")
	if botones.is_empty():
		_fin("H")
		return
	botones[0].emit_signal("pressed")
	_check(not _pausa.visible, "H2 el botón Continuar cierra PauseLayer")
	_check(not paused, "H3 el botón Continuar reanuda el mundo")
	_check(not (_pausa in _ui._stack), "H4 la pausa cerrada sale de la pila")
	_fin("H")


func _bloque_f_prompt_por_dispositivo() -> void:
	# El InputMap real de "interactuar" tiene UN evento y es de teclado (E).
	_overlay.set_device("keyboard")
	var kb: String = _overlay.call("_get_key_text_for_action", "interactuar")
	_check(kb != "?" and kb != "", "F1 keyboard: prompt resuelto (%s)" % kb)
	_check(kb.to_upper() == "E", "F2 keyboard: 'interactuar' muestra E (%s)" % kb)

	_overlay.set_device("gamepad_xbox")
	var xb: String = _overlay.call("_get_key_text_for_action", "interactuar")
	_check(xb == "A", "F3 gamepad_xbox: 'interactuar' muestra A (%s)" % xb)
	_check(xb != kb, "F4 el prompt CAMBIA con el dispositivo (antes era siempre la tecla)")

	_overlay.set_device("gamepad_ps")
	var ps: String = _overlay.call("_get_key_text_for_action", "interactuar")
	_check(ps == "X", "F5 gamepad_ps: 'interactuar' muestra X (%s)" % ps)

	_overlay.set_device("gamepad_generic")
	var gen: String = _overlay.call("_get_key_text_for_action", "interactuar")
	_check(gen == "A", "F6 gamepad_generic: 'interactuar' muestra A (%s)" % gen)

	# "inventario" y "pausa" tambien, no solo "interactuar".
	_overlay.set_device("gamepad_xbox")
	var inv: String = _overlay.call("_get_key_text_for_action", "inventario")
	var pau: String = _overlay.call("_get_key_text_for_action", "pausa")
	_check(inv == "Y", "F7 gamepad_xbox: 'inventario' muestra Y (%s)" % inv)
	_check(pau == "Start", "F8 gamepad_xbox: 'pausa' muestra Start (%s)" % pau)
	_fin("F")


func _bloque_g_fallback_y_modos() -> void:
	# Accion que NO esta en el InputMap: debe caer al DEVICE_MAP por CLAVE DE
	# PROMPT ("attack"), no por la accion cruda (que devolvia "?").
	_overlay.set_device("keyboard")
	var atk: String = _overlay.call("_get_key_text_for_action", "attack")
	_check(atk == "Click", "G1 fallback DEVICE_MAP por clave de prompt (%s)" % atk)
	_overlay.set_device("gamepad_ps")
	var atk_ps: String = _overlay.call("_get_key_text_for_action", "attack")
	_check(atk_ps == "R2", "G2 fallback por dispositivo (%s)" % atk_ps)

	# Modos REALES que emite ControlInput (M57): "generico" y "raton" caian a
	# keyboard.
	_overlay.call("_on_device_changed", "generico")
	_check(str(_overlay._current_device) == "gamepad_generic",
		"G3 'generico' -> gamepad_generic (%s)" % str(_overlay._current_device))
	_overlay.call("_on_device_changed", "raton")
	_check(str(_overlay._current_device) == "keyboard",
		"G4 'raton' -> keyboard (%s)" % str(_overlay._current_device))
	_overlay.call("_on_device_changed", "playstation")
	_check(str(_overlay._current_device) == "gamepad_ps",
		"G5 'playstation' -> gamepad_ps (%s)" % str(_overlay._current_device))
	_fin("G")


# ── Helpers ─────────────────────────────────────────────

## InputEventAction: `is_action_pressed("pausa")` lo resuelve sin depender del
## InputMap ni de un dispositivo real.
func _evento_pausa() -> InputEventAction:
	var ev := InputEventAction.new()
	ev.action = "pausa"
	ev.pressed = true
	return ev


func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("  [FALLO] " + msg)


func _fin(bloque: String) -> void:
	_vistos[bloque] = true


func _summary() -> void:
	for b in BLOQUES:
		if not _vistos.has(b):
			_checks += 1
			_fallos += 1
			print("  [FAIL] el bloque %s NO se ejecuto (posible SCRIPT ERROR)" % b)
	if CHECKS_MINIMOS > 0 and _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("  [FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== TEST M53 PAUSA+PROMPTS (G1-002/L187): %d checks, %d fallo(s) ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)
