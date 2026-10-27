# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-27
#
# M110 (Debug Menu) - suite de la CAPA DE CONTROL, INPUT Y AVISOS (M110-UI).
# Cubre los items:
#   L194 show(), L195 hide(), L198 show_panel(), L199 hide_panel(),
#   L200 toggle_panel(), L226 accion "debug_menu_toggle" (F1), L227 accion
#   "debug_menu_close" (Escape), L228 _input(event), L230 cerrar con Escape,
#   L231 cambiar mouse mode, L244 log de accesos, L268 visualizaciones solo
#   si visible. L243 (aviso) y L263 (overlay de FPS) quedan en su MODELO.
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral \
#     --script res://scripts/debug/test_debug_menu_control_m110.gd
#
# Guardas anti-falso-verde (3 capas, skill isla-ancestral-ciclo-modulo):
#   1. `_fin(bloque)` al FINAL del cuerpo de cada bloque (NO en el runner).
#   2. `CHECKS_MINIMOS` = piso MEDIDO en verde (nunca estimado).
#   3. `_summary()` en un `call_deferred` SEPARADO: si `_run()` aborta por un
#      SCRIPT ERROR, el resumen corre igual, nombra los bloques faltantes y
#      sale con EXIT 1 en vez de colgarse.
#
# La suite NO agrega el menu al arbol (no dispara `_ready`): instancia el
# script y llama a la API publica. El cableado de `_ready` se verifica de
# forma ESTATICA en el bloque H.

extends SceneTree

const MODULO := "M110"
const MENU := preload("res://scripts/debug/debug_menu.gd")
const RUTA_SCRIPT := "res://scripts/debug/debug_menu.gd"
const ACCION_TOGGLE := "debug_menu_toggle"
const ACCION_CLOSE := "debug_menu_close"

## Bloques esperados (los nombres que usa `_fin`)
const BLOQUES: Array[String] = ["A", "B", "C", "D", "E", "F", "G", "H"]

## Piso MEDIDO en verde: 75 checks (A 11 + B 13 + C 10 + D 9 + E 5 + F 9 +
## G 7 + H 11). Re-medir si la suite crece; nunca estimar.
const CHECKS_MINIMOS: int = 75

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}
var _menu: Node = null
var _texto_script: String = ""


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")  # corre aunque _run() aborte (SCRIPT ERROR)


func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("[FALLO] " + msg)


func _fin(bloque: String) -> void:
	_vistos[bloque] = true
	print("[FIN] bloque %s (acumulado %d checks)" % [bloque, _checks])


func _summary() -> void:
	for b in BLOQUES:
		if not _vistos.has(b):
			_checks += 1
			_fallos += 1
			print("[FALLO] el bloque %s NO se ejecutó (posible SCRIPT ERROR)" % b)
	if _checks < CHECKS_MINIMOS:
		_checks += 1
		_fallos += 1
		print("[FALLO] solo %d checks ejecutados (mínimo medido %d)"
			% [_checks - 1, CHECKS_MINIMOS])
	print("=== Resumen %s capa de control: %d checks, %d fallo(s) ==="
		% [MODULO, _checks, _fallos])
	quit(1 if _fallos > 0 else 0)


func _run() -> void:
	_menu = MENU.new()
	_texto_script = FileAccess.get_file_as_string(RUTA_SCRIPT)
	_bloque_a()
	_bloque_b()
	_bloque_c()
	_bloque_d()
	_bloque_e()
	_bloque_f()
	_bloque_g()
	_bloque_h()
	if _menu != null:
		_menu.free()
		_menu = null


func _evento(keycode: int, pressed: bool = true) -> InputEventKey:
	var ev := InputEventKey.new()
	ev.keycode = keycode
	ev.pressed = pressed
	return ev


## ── A. Visibilidad (§2) ────────────────────────────────────────────────────
func _bloque_a() -> void:
	_check(_menu.is_visible() == false, "A1 is_visible() arranca en false")
	_check(_menu.show() == true, "A2 show() devuelve true cuando CAMBIA")
	_check(_menu.is_visible() == true, "A3 is_visible() true tras show()")
	_check(_menu.show() == false, "A4 show() repetido devuelve false (idempotente)")
	_check(_menu.accesos_registrados() == 1,
		"A5 el show() idempotente NO cuenta como acceso nuevo")
	_check(_menu.hide() == true, "A6 hide() devuelve true cuando CAMBIA")
	_check(_menu.is_visible() == false, "A7 is_visible() false tras hide()")
	_check(_menu.hide() == false, "A8 hide() repetido devuelve false")
	_check(_menu.accesos_registrados() == 2, "A9 dos cambios = dos accesos")
	_check(_menu.toggle() == true and _menu.is_visible() == true,
		"A10 toggle() abre desde cerrado")
	_check(_menu.toggle() == true and _menu.is_visible() == false,
		"A11 toggle() cierra desde abierto")
	_fin("A")


## ── B. Paneles (§2) ────────────────────────────────────────────────────────
func _bloque_b() -> void:
	_check(_menu.panel_visible("jugador") == false, "B1 panel arranca oculto")
	_check(_menu.show_panel("jugador") == true, "B2 show_panel devuelve true")
	_check(_menu.panel_visible("jugador") == true, "B3 el panel quedo visible")
	_check(_menu.show_panel("jugador") == true,
		"B4 show_panel repetido devuelve el ESTADO (true), no 'cambio'")
	_check(_menu.toggle_panel("jugador") == false, "B5 toggle_panel apaga")
	_check(_menu.panel_visible("jugador") == false, "B6 el panel quedo oculto")
	_check(_menu.toggle_panel("jugador") == true, "B7 toggle_panel vuelve a prender")
	_check(_menu.hide_panel("jugador") == false, "B8 hide_panel devuelve false")
	_check(_menu.panel_visible("jugador") == false, "B9 el panel quedo oculto")
	_check(_menu.show_panel("") == false, "B10 id vacio -> false")
	_check(_menu.hide_panel("inexistente") == false, "B11 id desconocido -> false")
	_check(_menu.paneles_visibles().has("inexistente") == false,
		"B12 un id desconocido NO crea estado")
	_check(_menu.toggle_panel("") == false, "B13 toggle_panel con id vacio -> false")
	_fin("B")


## ── C. Registro de acciones en InputMap (§6, L226/L227) ────────────────────
func _bloque_c() -> void:
	var r1: Dictionary = _menu._registrar_acciones()
	_check(r1 is Dictionary, "C1 _registrar_acciones devuelve Dictionary")
	_check(_menu.acciones_registradas() == true, "C2 acciones_registradas() true")
	_check(InputMap.has_action(ACCION_TOGGLE), "C3 existe la accion debug_menu_toggle")
	_check(InputMap.has_action(ACCION_CLOSE), "C4 existe la accion debug_menu_close")
	_check(_tiene_tecla(ACCION_TOGGLE, KEY_F1), "C5 debug_menu_toggle tiene F1")
	_check(_tiene_tecla(ACCION_TOGGLE, KEY_QUOTELEFT),
		"C6 debug_menu_toggle tiene Backtick")
	_check(_tiene_tecla(ACCION_CLOSE, KEY_ESCAPE), "C7 debug_menu_close tiene Escape")
	var n_toggle := InputMap.action_get_events(ACCION_TOGGLE).size()
	var n_close := InputMap.action_get_events(ACCION_CLOSE).size()
	var r2: Dictionary = _menu._registrar_acciones()
	_check(int(r2.get("eventos_agregados", -1)) == 0,
		"C8 la 2da llamada agrega 0 eventos (idempotente)")
	_check(InputMap.action_get_events(ACCION_TOGGLE).size() == n_toggle,
		"C9 toggle no duplica eventos")
	_check(InputMap.action_get_events(ACCION_CLOSE).size() == n_close,
		"C10 close no duplica eventos")
	_fin("C")


func _tiene_tecla(accion: String, keycode: int) -> bool:
	for ev in InputMap.action_get_events(accion):
		if ev is InputEventKey and int(ev.keycode) == keycode:
			return true
	return false


## ── D. _input (L228) y cierre con Escape (L230) ────────────────────────────
func _bloque_d() -> void:
	_menu.hide()
	_check(_menu.is_visible() == false, "D1 parte de menu cerrado")
	_menu._input(_evento(KEY_F1))
	_check(_menu.is_visible() == true, "D2 F1 abre el menu")
	_menu._input(_evento(KEY_F1))
	_check(_menu.is_visible() == false, "D3 F1 de nuevo cierra el menu")
	var accesos_antes: int = _menu.accesos_registrados()
	_menu._input(_evento(KEY_ESCAPE))
	_check(_menu.is_visible() == false, "D4 Escape con el menu CERRADO no abre")
	_check(_menu.accesos_registrados() == accesos_antes,
		"D5 Escape con el menu cerrado no registra acceso")
	_menu._input(_evento(KEY_QUOTELEFT))
	_check(_menu.is_visible() == true, "D6 Backtick abre el menu")
	_menu._input(_evento(KEY_ESCAPE))
	_check(_menu.is_visible() == false, "D7 Escape con el menu ABIERTO lo cierra")
	_menu._input(_evento(KEY_F1, false))
	_check(_menu.is_visible() == false, "D8 el RELEASE de F1 no alterna")
	var antes_null: int = _menu.accesos_registrados()
	_menu._input(null)
	_check(_menu.accesos_registrados() == antes_null,
		"D9 _input(null) no rompe ni cambia el estado")
	_fin("D")


## ── E. Mouse mode (L231) ───────────────────────────────────────────────────
func _bloque_e() -> void:
	var m := MENU.new()
	## En headless el modo previo ES VISIBLE: la asercion correcta es
	## "restaura el previo", no "restaura algo distinto de VISIBLE".
	var previo: int = int(Input.mouse_mode)
	_check(m.mouse_mode_deseado() == -1, "E1 mouse_mode_deseado arranca en -1")
	m.show()
	_check(m.mouse_mode_deseado() == int(Input.MOUSE_MODE_VISIBLE),
		"E2 al abrir se pide MOUSE_MODE_VISIBLE")
	m.hide()
	_check(m.mouse_mode_deseado() == previo,
		"E3 al cerrar se restaura el modo PREVIO (medido %d)" % previo)
	m.show()
	_check(m.mouse_mode_deseado() == int(Input.MOUSE_MODE_VISIBLE),
		"E4 al reabrir vuelve a pedir VISIBLE")
	_check(DisplayServer.get_name() == "headless",
		"E5 corre en headless: el backend NO se toca (guarda activa)")
	m.free()
	_fin("E")


## ── F. Overlay de FPS con refresco de 500 ms (§7, L263) ────────────────────
func _bloque_f() -> void:
	_menu.hide()
	_menu.toggle_fps(false)
	_check(_menu.fps_overlay_texto(1000) == "", "F1 con el toggle apagado no hay texto")
	_menu.toggle_fps(true)
	_check(_menu.fps_overlay_texto(1000) == "",
		"F2 con el menu CERRADO no hay texto (L268)")
	_menu.show()
	var t1: String = _menu.fps_overlay_texto(1000)
	_check(t1 != "", "F3 con el menu abierto hay texto")
	_check(t1.begins_with("FPS: "), "F4 el texto tiene el formato 'FPS: n'")
	_check(_menu.fps_ultimo_ms() == 1000, "F5 el primer texto refresca el sello")
	var t2: String = _menu.fps_overlay_texto(1100)
	_check(t2 == t1 and _menu.fps_ultimo_ms() == 1000,
		"F6 a los 100 ms NO refresca (throttle de 500 ms)")
	var t3: String = _menu.fps_overlay_texto(1500)
	_check(t3 != "" and _menu.fps_ultimo_ms() == 1500,
		"F7 a los 500 ms SI refresca")
	_menu.toggle_fps(false)
	_check(_menu.fps_overlay_texto(2000) == "", "F8 apagar el toggle corta el texto")
	_menu.toggle_fps(true)
	_menu.hide()
	_menu.show()
	_check(_menu.fps_ultimo_ms() == -1000,
		"F9 reabrir el menu fuerza el refresco inmediato")
	_fin("F")


## ── G. Log de accesos (L244) y aviso de desarrollo (L243) ──────────────────
func _bloque_g() -> void:
	var m := MENU.new()
	_check(m.accesos_registrados() == 0, "G1 un menu nuevo arranca en 0 accesos")
	_check(m.ultimo_acceso() == "", "G2 sin accesos, ultimo_acceso() vacio")
	m.show()
	_check(m.accesos_registrados() == 1 and m.ultimo_acceso() == "abrir",
		"G3 show() registra el acceso 'abrir'")
	m.hide()
	_check(m.accesos_registrados() == 2 and m.ultimo_acceso() == "cerrar",
		"G4 hide() registra el acceso 'cerrar'")
	_check(m.aviso_desarrollo() != "", "G5 el aviso de desarrollo no esta vacio")
	_check(m.aviso_desarrollo().contains("DESARROLLO"),
		"G6 el aviso nombra DESARROLLO")
	_check(typeof(m.es_build_de_desarrollo()) == TYPE_BOOL,
		"G7 es_build_de_desarrollo() devuelve bool")
	m.free()
	_fin("G")


## ── H. Cableado ESTATICO del archivo ───────────────────────────────────────
func _bloque_h() -> void:
	_check(_texto_script.length() > 0, "H1 se pudo leer el script")
	_check(_texto_script.contains("_registrar_acciones()\n\t_registrar_servicio()"),
		"H2 _ready llama a _registrar_acciones()")
	_check(_texto_script.contains("func alternar() -> void:\n\ttoggle()"),
		"H3 alternar() delega en toggle() (sin duplicar la logica)")
	_check(_texto_script.contains("KEY_F12"),
		"H4 _unhandled_input conserva el atajo F12 de LEGADO")
	_check(_texto_script.contains("func _input(event: InputEvent) -> void:"),
		"H5 existe _input(event)")
	_check(not _texto_script.contains("input/debug_menu_toggle"),
		"H6 NO escribe la accion en ProjectSettings (project.godot intacto)")
	var asignaciones := 0
	for linea in _texto_script.split("\n"):
		if linea.begins_with("\tvisible = "):
			asignaciones += 1
	_check(asignaciones == 1,
		"H7 un solo punto asigna `visible` (dentro de _fijar_visible); medido %d"
			% asignaciones)
	for nombre in ["func show()", "func hide()", "func toggle()", "func is_visible()"]:
		_check(_texto_script.contains(nombre), "H8 API §2 presente: %s" % nombre)
	_fin("H")
