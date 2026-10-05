# Modelo: mimo-v2.6-flash-free
# Plataforma: opencode
# Fecha: 2026-10-05
#
# M89 Diseño de Menús (frente T-M2): suite headless del shell de menús
# contra el estado REAL del disco (auditoría T-M2, 2026-10-05).
#
# Qué valida (evidencia detallada en plan-actual/07-Resultados-Testings.md):
#   A. MenusLayer: 5 señales, 5 botones, MODAL_FULL, arranca oculto.
#   B. PauseLayer: 4 opciones, MODAL_FULL, open/close.
#   C. MenuNavigator: focus_first/last + wrap_focus (movimiento real de foco).
#   D. CreditsLayer: controles de scroll/cerrar, constantes M131.
#   E. UIRoot: montaje de capas + wiring de señales del menú y de ajustes
#      (T-053-065/066) con GameFlowManager montado por Bootstrap.
#   F. Pausa del mundo: MODAL_FULL pausa el árbol y lo reanuda al cerrar.
#   G. SaveManager: API de slots (Continuar/Cargar) + SaveWriter.save_exists.
#
# Gaps documentados (NO son fallos: son hallazgos de la auditoría y la
# suite los imprime como GAP-AUDITORIA):
#   - RF1 pide 6 botones; hoy hay 5 (falta "Cargar").
#   - Nadie llama a menus_layer.open() → el título no se muestra al arrancar.
#   - salir_pedido va a get_tree().quit() sin confirmación (RF11).
#   - Esc/Start en juego solo cierra capas; abrir PauseLayer es solo vía
#     RF18 (pausa instantánea de M58).
#
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/ui/test_m89_menus.gd

extends SceneTree

const RUTA_MENUS := "res://scripts/ui/layers/menus_layer.gd"
const RUTA_PAUSE := "res://scripts/ui/layers/pause_layer.gd"
const RUTA_NAV := "res://scripts/ui/core/menu_navigator.gd"
const RUTA_CREDITS := "res://scripts/ui/layers/credits_layer.gd"
const RUTA_UIROOT := "res://scripts/ui/ui_root.gd"
const ESPERA_BOTONES_MENUS := 5  # Jugar/Continuar/Ajustes/Créditos/Salir (RF1 pide 6: falta "Cargar")
const ESPERA_BOTONES_PAUSE := 4  # Continuar/Ajustes/Guardar/Salir

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_a_menus_layer()
	var pausa = _crear(RUTA_PAUSE, "PausaM89")
	if pausa != null:
		_test_b_pause_layer(pausa)
		_test_c_menu_navigator(pausa)
		_test_f_pausa_mundo(pausa)
		pausa.free()
	_test_d_credits_layer()
	_test_e_uiroot_wiring()
	_test_g_save_slots()
	_imprimir_gaps()
	print("=== TEST M89 MENUS: %d checks, %d fallo(s) ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _info(msg: String) -> void:
	print("GAP-AUDITORIA: " + msg)

func _crear(ruta: String, nombre: String):
	var script = load(ruta)
	if script == null:
		_check(false, "carga de %s" % ruta)
		return null
	var nodo = script.new()
	nodo.name = nombre
	root.add_child(nodo)
	return nodo

func _contar_botones(nodo: Node, acc: Array) -> void:
	for hijo in nodo.get_children():
		if hijo is Button:
			acc.append(hijo)
		_contar_botones(hijo, acc)

## A — Menú principal (RF1/RF2): señales + botones + tipo de capa
func _test_a_menus_layer() -> void:
	var m = _crear(RUTA_MENUS, "MenusM89")
	if m == null:
		return
	_check(m is UILayer, "A1 MenusLayer extiende UILayer")
	_check(m.layer_type == UILayerType.Type.MODAL_FULL, "A2 es MODAL_FULL")
	_check(not m.visible, "A3 arranca oculto (dormante)")
	for sig in ["jugar_pedido", "continuar_pedido", "ajustes_pedido", "creditos_pedido", "salir_pedido"]:
		_check(m.has_signal(sig), "A4 señal %s" % sig)
	var botones: Array = []
	_contar_botones(m, botones)
	_check(botones.size() == ESPERA_BOTONES_MENUS,
		"A5 %d botones (esperados %d)" % [botones.size(), ESPERA_BOTONES_MENUS])
	var sin_texto := 0
	for b in botones:
		if str(b.text).strip_edges() == "":
			sin_texto += 1
	_check(sin_texto == 0, "A6 ningún botón sin texto")
	_check(m.has_method("focus_first"), "A7 focus_first del propio menú")
	m.free()

## B — Pausa (RF5/RF11): opciones + open/close
func _test_b_pause_layer(pausa: Node) -> void:
	_check(pausa is UILayer, "B1 PauseLayer extiende UILayer")
	_check(pausa.layer_type == UILayerType.Type.MODAL_FULL, "B2 es MODAL_FULL")
	for sig in ["continuar_pedido", "ajustes_pedido", "guardar_pedido", "salir_pedido"]:
		_check(pausa.has_signal(sig), "B3 señal %s" % sig)
	var botones: Array = []
	_contar_botones(pausa, botones)
	_check(botones.size() == ESPERA_BOTONES_PAUSE,
		"B4 %d botones (esperados %d)" % [botones.size(), ESPERA_BOTONES_PAUSE])
	pausa.open()
	_check(pausa.visible, "B5 open() hace visible")
	pausa.close()
	_check(not pausa.visible, "B6 close() oculta")

## C — Navegación (RF2): foco real con MenuNavigator
func _test_c_menu_navigator(pausa: Node) -> void:
	var nav = load(RUTA_NAV)
	_check(nav != null, "C1 menu_navigator.gd carga")
	if nav == null:
		return
	var botones: Array = []
	_contar_botones(pausa, botones)
	if botones.size() < 2:
		_check(false, "C2 pausa con focos suficientes para navegar")
		return
	var first = nav.focus_first(pausa)
	_check(first != null, "C3 focus_first devuelve control")
	if first == null:
		return
	_check(first is Button, "C4 focus_first → Button")
	first.grab_focus()
	var owner = root.gui_get_focus_owner()
	_check(owner != null, "C5 foco real tras focus_first")
	var last = nav.focus_last(pausa)
	_check(last != null and last.get_instance_id() != first.get_instance_id(),
		"C6 focus_last distinto de focus_first")
	# wrap_focus con dirección horizontal: siguiente índice con wrap-around
	nav.wrap_focus(pausa, Vector2i(1, 0))
	var owner2 = root.gui_get_focus_owner()
	_check(owner2 != null and owner2.get_instance_id() != first.get_instance_id(),
		"C7 wrap_focus mueve el foco")

## D — Créditos (RF10): scroll + cerrar + constantes M131
func _test_d_credits_layer() -> void:
	var script = load(RUTA_CREDITS)
	_check(script != null, "D1 credits_layer.gd carga")
	if script == null:
		return
	_check(int(script.MAX_SEGUNDOS) == 300, "D2 MAX_SEGUNDOS == 300 (D9)")
	_check(script.VELOCIDADES.size() == 3, "D3 3 velocidades de scroll (D5)")
	var c = _crear(RUTA_CREDITS, "CreditosM89")
	if c == null:
		return
	_check(c.has_method("open") and c.has_method("cerrar"), "D4 open() + cerrar()")
	var botones: Array = []
	_contar_botones(c, botones)
	_check(botones.size() >= 6, "D5 controles de créditos >= 6 (hay %d)" % botones.size())
	c.free()

## E — UIRoot: montaje del shell + wiring de señales (T-053-065/066)
func _test_e_uiroot_wiring() -> void:
	var ur = _crear(RUTA_UIROOT, "UIRootM89")
	if ur == null:
		return
	_check(ur.menus_layer != null, "E1 UIRoot monta MenusLayer")
	_check(ur.pause_layer != null, "E2 UIRoot monta PauseLayer")
	_check(ur.credits_layer != null, "E3 UIRoot monta CreditsLayer")
	_check(ur.settings_audio_layer != null, "E4 UIRoot monta SettingsAudioLayer")
	_check(ur.has_method("_conectar_menu_señales"), "E5 wiring del menú presente")
	_check(ur.has_method("_conectar_ajustes"), "E6 wiring de ajustes presente")
	var gfm = root.get_node_or_null("GameFlowManager")
	if gfm == null:
		_info("GameFlowManager no montado en este arranque → E7 se salta (bootstrap 'build parcial')")
	else:
		var conns = ur.menus_layer.get_signal_connection_list("jugar_pedido")
		_check(conns.size() > 0, "E7 jugar_pedido cableada a GameFlowManager (%d)" % conns.size())
		var conns2 = ur.menus_layer.get_signal_connection_list("ajustes_pedido")
		_check(conns2.size() > 0, "E8 ajustes_pedido cableada a SettingsAudioLayer (%d)" % conns2.size())
	ur.free()

## F — Pausa del mundo (RF5): MODAL_FULL congela el árbol y lo reanuda
func _test_f_pausa_mundo(pausa: Node) -> void:
	_check(paused == false, "F1 árbol despausado antes de abrir")
	pausa.open()
	_check(paused == true, "F2 MODAL_FULL pausa el árbol (mundo congelado)")
	pausa.close()
	_check(paused == false, "F3 cerrar reanuda el árbol (sin saltos)")

## G — Continuar/Cargar: API de slots de M59
func _test_g_save_slots() -> void:
	var sm = root.get_node_or_null("SaveManager")
	_check(sm != null, "G1 SaveManager autoload presente")
	if sm != null:
		_check(sm.has_method("slot_metadata"), "G2 slot_metadata()")
		_check(sm.has_method("load_slot"), "G3 load_slot()")
		_check(sm.has_method("slot_recoverable"), "G4 slot_recoverable()")
	var sw = load("res://scripts/saving/save_writer.gd")
	_check(sw != null, "G5 save_writer.gd carga")
	if sw != null:
		_check(sw.save_exists(0) is bool, "G6 save_exists(0) responde bool")

## Hallazgos de la auditoría contra disco (no son fallos)
func _imprimir_gaps() -> void:
	_info("RF1 incompleto: 5/6 botones del menú principal (falta 'Cargar')")
	_info("Nadie llama menus_layer.open(): el título no se muestra al arrancar")
	_info("RF11: salir_pedido → get_tree().quit() sin confirmación de salida")
	_info("RF11/RF5: Esc/Start en juego solo cierra capas; PauseLayer abre solo vía RF18 (M58)")
	_info("Ajustes: solo existe la sección Audio (SettingsAudioLayer); faltan pantallas de Controles/Accesibilidad/Gráfica")
	_info("Perfiles 1-3: no hay concepto de perfil en M59 (solo slots)")
