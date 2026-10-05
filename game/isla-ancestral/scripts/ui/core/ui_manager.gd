extends Node
## Orquestador de capas UI, foco y pausa
##
## Gestiona la pila de capas modales, el foco del usuario y la
## coordinación de pausa con GameTime. Singleton autoload.
##
## Reglas:
## - Solo una capa MODAL_FULL a la vez
## - Las demás se encolan y se restauran al cerrar
## - HUD siempre visible (process_mode = ALWAYS)
## - Popups no compiten por foco principal

## ── Constantes de tipo de capa (uplica UILayerType.Type) ──
## Usadas con duck-typing para evitar dependencia circular con UILayer
const LAYER_HUD := 0
const LAYER_MODAL_SIMPLE := 1
const LAYER_MODAL_FULL := 2
const LAYER_POPUP := 3

## ── Señales ─────────────────────────────────────────────
## Se emite cuando cambia la pila de capas
signal ui_layers_changed
## Se emite cuando el foco se mueve a un nuevo Control
signal ui_focus_moved(node: Node)

## ── Estado interno ──────────────────────────────────────
## Pila de capas abiertas (última = tope)
var _stack: Array[Node] = []
## Backup de foco por capa (layer -> Control con foco previo)
var _focus_backup: Dictionary = {}
## Referencia al HUD (CanvasLayer del HUD)
var _hud: Node = null
## Capa modal completa actual (solo una a la vez)
var _current_modal_full: Node = null
## M53 L: Guard para cierre rápido (previene doble pulsación)
var _closing: bool = false

## ── Ciclo de vida ──────────────────────────────────────

## Señal emitida cuando cambia el dispositivo de entrada (M57 → M53)
signal device_changed(mode: String)

func _ready() -> void:
	# Suscribir eventos de UI del EventBus
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus and bus.has_method("get"):
			var ui_events: Variant = bus.get("ui")
			if ui_events != null and ui_events.has_signal("hud_request"):
				ui_events.hud_request.connect(_on_hud_request)
			if ui_events != null and ui_events.has_signal("dialog_requested"):
				ui_events.dialog_requested.connect(_on_dialog_requested)
	# T-053-058: suscribirse a ControlInput (M57) para prompts dinámicos
	var ctrl = get_node_or_null("/root/ControlInput")
	if ctrl and ctrl.has_signal("dispositivo_cambiado"):
		ctrl.dispositivo_cambiado.connect(_on_device_changed)
	# T-053-061: suscribirse a GameSettings para reaplicar tema
	var gs = get_node_or_null("/root/GameSettings")
	if gs and gs.has_signal("settings_changed"):
		gs.settings_changed.connect(_on_settings_changed)
	# M53 RF6: tooltip por foco (accesible por teclado/gamepad)
	ui_focus_moved.connect(_on_focus_moved_tooltip)
	# M53 H: conectar señales de foco para hover sounds
	ui_focus_moved.connect(_on_focus_hover_sound)
	# M53 L: al volver de alt-tab, restaurar foco de la capa visible
	var win := get_window()
	if win and win.has_signal("focus_entered"):
		win.focus_entered.connect(_on_window_focus_restored)
	# M58 RF18 (Log 1118): pausa instantánea de M58 -> overlay de pausa M53
	_conectar_m58()
	# M87 (Log 1118): re-traducción en vivo de capas montadas al cambiar de
	# idioma (M53 adopta la convención de metadatos text_key/tooltip_text_key
	# de RetraductorUI; los textos dinámicos los re-generan las propias capas
	# vía locale_changed)
	_conectar_m87()

## §9.50 — Congela el mundo mientras haya una capa MODAL_FULL visible.
## Las capas UI van en PROCESS_MODE_ALWAYS (siguen recibiendo input); el resto
## del árbol se pausa vía get_tree().paused. SIN esto, las capas en
## PROCESS_MODE_WHEN_PAUSED quedan congeladas con el juego corriendo y no
## reciben input (bug: Enter no avanzaba el diálogo).
func _actualizar_pausa_mundo() -> void:
	var hay_modal := false
	for capa in _stack:
		if is_instance_valid(capa) and capa.visible and capa is UILayer:
			if capa.layer_type == UILayerType.Type.MODAL_FULL:
				hay_modal = true
				break
	var tree := get_tree()
	if tree and tree.paused != hay_modal:
		tree.paused = hay_modal
		_log("mundo %s (MODAL_FULL visible)" % ["PAUSADO" if hay_modal else "REANUDADO"])

## Muestra el tooltip del control enfocado si define tooltip_text
## (o el metadato M87 `tooltip_text_key` si está presente — Log 1118)
func _on_focus_moved_tooltip(node: Node) -> void:
	var ts = get_node_or_null("/root/TooltipService")
	if ts == null:
		ts = _buscar_nodo(get_tree().root, "TooltipService")
	if ts == null or not (node is Control):
		return
	if node.has_meta("tooltip_text_key"):
		# M87 (Log 1118): tooltip por clave de catálogo — se re-traduce en vivo
		if ts.has_method("show_tooltip_key"):
			ts.show_tooltip_key(str(node.get_meta("tooltip_text_key")), node)
		return
	if str(node.tooltip_text) != "":
		if ts.has_method("show_tooltip"):
			ts.show_tooltip(str(node.tooltip_text), node)

## ── Acciones transversales (M57) ─────────────────────────
## Navegación por teclado/gamepad: usa el InputMap del proyecto (M57) para
## mover el foco entre controles de la capa visible, y abrir/cerrar capas.

func _unhandled_input(event: InputEvent) -> void:
	if _stack.is_empty():
		return
	# T-M1 (M55): "tope" = la capa VISIBLE más reciente. La pila guarda todas
	# las capas montadas (registradas al entrar al árbol), no solo las abiertas:
	# con el diario abierto, stack[-1] era SettingsAudioLayer (oculta) y el
	# input se evaluaba contra la capa equivocada.
	var top_layer := _stack[_stack.size() - 1]
	for i in range(_stack.size() - 1, -1, -1):
		if _stack[i].visible:
			top_layer = _stack[i]
			break
	if event.is_action_pressed("pausa") and top_layer is UILayer:
		close_top()
		get_viewport().set_input_as_handled()
		return
	# M53 sección E: toggle del panel de inventario con acción `inventario` (I)
	if event.is_action_pressed("inventario"):
		var inv_layer = _buscar_capa("InventoryLayer")
		if inv_layer and inv_layer.has_method("toggle"):
			inv_layer.toggle()
			get_viewport().set_input_as_handled()
			return
	# M155: toggle del panel de equipamiento con acción `equipamiento` (E)
	if event.is_action_pressed("equipamiento"):
		var eq_layer = _buscar_capa("EquipmentLayer")
		if eq_layer and eq_layer.has_method("toggle"):
			eq_layer.toggle()
			get_viewport().set_input_as_handled()
			return
	# T-053-067 M56: toggle de visibilidad del HUD con acción `ocultar_hud` (H)
	if event.is_action_pressed("ocultar_hud"):
		set_hud_visible(not (_hud != null and _hud.visible))
		get_viewport().set_input_as_handled()
		return
	# T-M1 M55: toggle del diario con acción `diario` (J)
	if event.is_action_pressed("diario"):
		var dia_layer = _buscar_capa("DiaryLayer")
		if dia_layer and dia_layer.has_method("toggle"):
			dia_layer.toggle()
			get_viewport().set_input_as_handled()
			return
	# T-M1 M55: `favorito` alterna la entrada seleccionada del diario (si está visible)
	if event.is_action_pressed("favorito"):
		var dia_fav = _buscar_capa("DiaryLayer")
		if dia_fav and dia_fav.visible and dia_fav.has_method("alternar_favorito_seleccionado"):
			dia_fav.alternar_favorito_seleccionado()
			get_viewport().set_input_as_handled()
			return
	# Navegación direccional con acciones del InputMap (M57)
	var nav: Vector2i = Vector2i.ZERO
	if event.is_action_pressed("mover_norte"):
		nav = Vector2i(0, -1)
	elif event.is_action_pressed("mover_sur"):
		nav = Vector2i(0, 1)
	elif event.is_action_pressed("mover_este"):
		nav = Vector2i(1, 0)
	elif event.is_action_pressed("mover_oeste"):
		nav = Vector2i(-1, 0)
	# Si la capa es un UILayer y el input es parte del InputMap, navegar
	if nav != Vector2i.ZERO and top_layer is UILayer:
		MenuNavigator.wrap_focus(top_layer, nav)
		get_viewport().set_input_as_handled()


## ── API pública: pila de capas ──────────────────────────

## Registro automático desde UILayer._enter_tree.
## Las capas modales se apilan al entrar al árbol y quedan ocultas hasta open().
func register_layer(layer: Node) -> void:
	if layer in _stack:
		return
	_stack.append(layer)
	_apply_process_mode(layer)
	_restore_focus_for_layer(layer)  # guarda/restaura sin foco forzado
	_log("capa registrada: %s (tipo=%s, pila=%d)" % [layer.name, _get_layer_type_name(layer), _stack.size()])

## Des-registro automático desde UILayer._exit_tree
func unregister_layer(layer: Node) -> void:
	var idx := _stack.find(layer)
	if idx == -1:
		return
	_stack.remove_at(idx)
	if _current_modal_full == layer:
		_current_modal_full = null
	_log("capa des-registrada: %s (pila=%d)" % [layer.name, _stack.size()])

## Registra una capa en la pila y la abre
func push_layer(layer: Node) -> void:
	if layer in _stack:
		push_warning("[UIManager] push_layer: capa ya en pila: %s" % layer.name)
		return

	# Si es MODAL_FULL, verificar que no haya otro
	if _is_modal_full(layer):
		if _current_modal_full != null:
			push_warning("[UIManager] push_layer: ya hay modal completo abierto: %s" % _current_modal_full.name)
			pop_layer(_current_modal_full)
		_current_modal_full = layer

	_stack.append(layer)

	# Aplicar process_mode si tiene layer_type
	_apply_process_mode(layer)

	# Guardar foco actual antes de cambiar
	_save_focus_for_new_layer(layer)

	# Abrir la capa
	if layer.has_method("open"):
		layer.open()

	# Emitir cambio
	ui_layers_changed.emit()
	_log("capa abierta: %s (tipo=%s, pila=%d)" % [layer.name, _get_layer_type_name(layer), _stack.size()])


## Cierra una capa específica de la pila
func pop_layer(layer: Node) -> void:
	var idx := _stack.find(layer)
	if idx == -1:
		push_warning("[UIManager] pop_layer: capa no encontrada: %s" % layer.name)
		return

	# Cerrar la capa
	if layer.has_method("close"):
		layer.close()

	_stack.remove_at(idx)

	# Restaurar foco
	_restore_focus_for_layer(layer)

	# Si era MODAL_FULL, limpiar referencia
	if _current_modal_full == layer:
		_current_modal_full = null

	# Restaurar process_mode de la capa anterior
	if _stack.size() > 0:
		var prev := _stack[_stack.size() - 1]
		_apply_process_mode(prev)

	ui_layers_changed.emit()
	_log("capa cerrada: %s (pila=%d)" % [layer.name, _stack.size()])


## Cierra la capa en el tope de la pila
func close_top() -> void:
	if _stack.is_empty():
		return
	# M53 L: guard contra cierre rápido (doble pulsación)
	if _closing:
		return
	_closing = true
	# T-M1 (M55): purgar la capa VISIBLE más reciente. Antes se poppaba
	# siempre stack[-1]: con el diario abierto, Esc des-registraba a
	# SettingsAudioLayer (oculta, montada después) y el diario quedaba abierto.
	# Fallback: si nada está visible, se mantiene el comportamiento original.
	var objetivo := _stack[_stack.size() - 1]
	for i in range(_stack.size() - 1, -1, -1):
		if _stack[i].visible:
			objetivo = _stack[i]
			break
	pop_layer(objetivo)
	_closing = false


## Devuelve la capa en el tope de la pila
func top() -> Node:
	if _stack.is_empty():
		return null
	return _stack[_stack.size() - 1]


## Indica si hay alguna capa modal abierta
func is_modal_open() -> bool:
	return _current_modal_full != null


## ── API pública: foco ───────────────────────────────────

## Restaura el foco a un nodo preferido o al primero de la capa visible
func request_focus_restore(preferred: Node = null) -> void:
	if preferred and is_instance_valid(preferred) and preferred is Control:
		preferred.grab_focus()
		ui_focus_moved.emit(preferred)
		return

	# Buscar la capa visible actual y enfocar su primer control
	for i in range(_stack.size() - 1, -1, -1):
		var layer := _stack[i]
		if layer.visible and layer.has_method("focus_first"):
			var first: Node = layer.focus_first()
			if first and first is Control:
				first.grab_focus()
				ui_focus_moved.emit(first)
			return


## ── API pública: HUD ────────────────────────────────────

## Establece la referencia al HUD
func register_hud(hud: Node) -> void:
	_hud = hud


## Muestra u oculta el HUD
func set_hud_visible(is_visible: bool) -> void:
	if _hud and _hud.has_method("set_hud_visible"):
		_hud.set_hud_visible(is_visible)
	elif _hud:
		_hud.visible = is_visible


## ── API pública: popup de confirmación ──────────────────

## Abre un popup de confirmación genérico (ConfirmaPopup si está montado).
func open_confirm(title: StringName, message: String, on_ok: Callable, on_cancel: Callable = Callable()) -> void:
	var popup = _buscar_capa("ConfirmPopup")
	if popup and popup.has_method("configurar"):
		popup.configurar(str(title), str(message), on_ok, on_cancel)
	else:
		_log("open_confirm solicitado: %s (sin ConfirmPopup montado)" % title)
		if on_ok.is_valid():
			on_ok.call()


## ── API pública: utilidades ─────────────────────────────

## Devuelve el número de capas abiertas
func stack_size() -> int:
	return _stack.size()


## Verifica integridad de la pila (debug)
func assert_stack_integrity() -> bool:
	for layer in _stack:
		if not layer.visible:
			_log("INCONSISTENCIA: capa invisible en pila: %s" % layer.name)
			return false
	return true


## ── Métodos privados ────────────────────────────────────

## Verifica si una capa tiene layer_type == MODAL_FULL (duck-typing)
func _is_modal_full(layer: Node) -> bool:
	if layer.get("layer_type") != null:
		return layer.layer_type == LAYER_MODAL_FULL
	return false


## Aplica el process_mode adecuado según el tipo de capa
func _apply_process_mode(layer: Node) -> void:
	var lt = layer.get("layer_type")
	if lt == null:
		return

	match lt:
		LAYER_HUD:
			layer.process_mode = Node.PROCESS_MODE_ALWAYS
		LAYER_MODAL_SIMPLE:
			layer.process_mode = Node.PROCESS_MODE_ALWAYS
		LAYER_MODAL_FULL:
			layer.process_mode = Node.PROCESS_MODE_ALWAYS
		LAYER_POPUP:
			layer.process_mode = Node.PROCESS_MODE_ALWAYS
	# §9.50: las capas UI SIEMPRE procesan input; el mundo se congela vía
	# get_tree().paused cuando hay una capa MODAL_FULL visible (ver abajo).


## Guarda el foco actual antes de abrir una nueva capa
func _save_focus_for_new_layer(_layer: Node) -> void:
	var focused := get_viewport().gui_get_focus_owner()
	if focused:
		_focus_backup[_layer] = focused


## Restaura el foco al cerrar una capa
func _restore_focus_for_layer(layer: Node) -> void:
	if _focus_backup.has(layer):
		var prev_focus: Node = _focus_backup[layer]
		if is_instance_valid(prev_focus) and prev_focus is Control:
			prev_focus.grab_focus()
			ui_focus_moved.emit(prev_focus)
		_focus_backup.erase(layer)


## Convierte el tipo de capa a nombre legible
func _get_layer_type_name(layer: Node) -> String:
	var lt = layer.get("layer_type")
	if lt == null:
		return "UNKNOWN"
	match lt:
		LAYER_HUD: return "HUD"
		LAYER_MODAL_SIMPLE: return "MODAL_SIMPLE"
		LAYER_MODAL_FULL: return "MODAL_FULL"
		LAYER_POPUP: return "POPUP"
	return "UNKNOWN"


## ── Callbacks de EventBus ───────────────────────────────

func _on_hud_request(_visible: bool) -> void:
	set_hud_visible(_visible)


func _on_dialog_requested(_npc_id: String, _dialog_data: Dictionary) -> void:
	# M53: abre el DialogLayer formal si existe; si no, el manager M21 lo cubre.
	var layer = _buscar_capa("DialogLayer")
	if layer:
		push_layer(layer)
	else:
		_log("dialog_requested recibido (sin DialogLayer montado; M21 usa su fallback)")

## Busca una capa por nombre recorriendo el árbol (robusto a la estructura de montaje).
func _buscar_capa(nombre: String) -> Node:
	if _stack.size() > 0:
		for l in _stack:
			if l.name == nombre:
				return l
	return _buscar_nodo(get_tree().root, nombre)

func _buscar_nodo(node: Node, nombre: String) -> Node:
	for child in node.get_children():
		if child.name == nombre:
			return child
		var result := _buscar_nodo(child, nombre)
		if result:
			return result
	return null


## ── T-053-058 / T-053-059: Integración con M57 (input) ───────────────────────

## Cuando ControlInput detecta cambio de dispositivo, UIManager propaga la señal
## para que todos los widgets actualicen sus prompts (T-053-059).
func _on_device_changed(mode: String) -> void:
	device_changed.emit(mode)


## ── T-053-061: Integración con M58 (settings → tema) ─────────────────────────

## Cuando GameSettings emite settings_changed, ThemeService reaplica el tema.
func _on_settings_changed() -> void:
	var ts = get_node_or_null("/root/ThemeService")
	if ts and ts.has_method("aplicar_tema_global"):
		ts.aplicar_tema_global(ts.get_ui_scale() if ts.has_method("get_ui_scale") else 1.0)


## ── M58 RF18 (Log 1118): pausa instantánea → overlay de pausa M53 ───────────

## M58 (AccesibilityManager) puede pausar el juego sin menús intermedios; M53
## es la que muestra el overlay: se conecta a su señal y, al llegar, abre la
## PauseLayer si no hay ninguna capa modal visible. El reanudar se liga a la
## señal `continuar_pedido` de la PauseLayer (ver _conectar_m58).
## Si M58 no está montado, el hook no existe: NO se finge.
func _m58() -> Node:
	return get_node_or_null("/root/AccesibilityManager")

func _conectar_m58() -> void:
	var acc := _m58()
	if acc == null or not acc.has_signal("pausa_instantanea_activada"):
		return
	acc.pausa_instantanea_activada.connect(_on_pausa_instantanea)
	var pausa = _buscar_capa("PauseLayer")
	if pausa and pausa.has_signal("continuar_pedido"):
		pausa.continuar_pedido.connect(_on_pausa_continuar)

func _on_pausa_instantanea() -> void:
	var pausa = _buscar_capa("PauseLayer")
	if pausa == null:
		return
	# Las capas montadas ya están registradas: se abren con open()
	# (push_layer es no-op para una capa ya en pila). La visibilidad de una
	# MODAL_FULL pausa el mundo vía UILayer._notification (§9.50), igual que RF18.
	if not pausa.visible and pausa.has_method("open"):
		pausa.open()
	_log("RF18: overlay de pausa abierto por pausa instantánea de M58")

## Al pulsar "Continuar" en el overlay, si M58 había pausado (RF18) se reanuda.
func _on_pausa_continuar() -> void:
	var acc := _m58()
	if acc and acc.has_method("esta_pausado") and acc.esta_pausado() and acc.has_method("reanudar"):
		acc.reanudar()


## ── M87 (Log 1118): re-traducción en vivo al cambiar de idioma ──────────────

## M53 adopta la convención de M87 (scripts/localization/retraductor_ui.gd):
## un control declara su clave con el metadato `text_key` (texto) o
## `tooltip_text_key` (tooltip). Al cambiar de idioma, M87 emite locale_changed
## y M53 re-traduce las capas montadas + el HUD con RetraductorUI (solo los
## nodos visibles; los dinámicos los re-genera cada capa con sus parámetros).
## Si M87 no está montado, no hay nada que hacer: NO se finge.
func _conectar_m87() -> void:
	var loc := get_node_or_null("/root/Localization")
	if loc == null or not loc.has_signal("locale_changed"):
		return
	if not loc.locale_changed.is_connected(_on_locale_changed_ui):
		loc.locale_changed.connect(_on_locale_changed_ui)

func _on_locale_changed_ui(_locale: String) -> void:
	var raices: Array[Node] = []
	for capa in _stack:
		if is_instance_valid(capa):
			raices.append(capa)
	if _hud != null and is_instance_valid(_hud):
		raices.append(_hud)
	for raiz in raices:
		var rep: Dictionary = UiI18n.retraducir(raiz)
		if int(rep.get("traducidos", 0)) > 0:
			_log("M87: %s re-traducido (%d props, %.2f ms)" % [
				raiz.name, int(rep.get("traducidos", 0)), float(rep.get("ms", 0.0))])


## ── Logging ─────────────────────────────────────────────

func _log(msg: String) -> void:
	print("[DOM-UI] %s" % msg)

## ── M53 H: Feedback sonoro (hover y click) ──────────────

## Reproduce sonido de hover cuando el foco se mueve a un botón
func _on_focus_hover_sound(node: Node) -> void:
	if node is Button:
		var fb = get_node_or_null("/root/UIFeedback")
		if fb and fb.has_method("play_hover"):
			fb.play_hover()

## Conectar click sounds a todos los botones de una capa
func _conectar_click_sounds(layer: Node) -> void:
	if layer == null:
		return
	for child in _get_all_buttons(layer):
		if child.pressed.is_connected(_on_button_click_sound):
			continue
		child.pressed.connect(_on_button_click_sound)

func _on_button_click_sound() -> void:
	var fb = get_node_or_null("/root/UIFeedback")
	if fb and fb.has_method("play_click"):
		fb.play_click()

func _get_all_buttons(node: Node) -> Array[Button]:
	var result: Array[Button] = []
	if node is Button:
		result.append(node)
	for child in node.get_children():
		result.append_array(_get_all_buttons(child))
	return result

## M53 L: al volver de alt-tab, restaurar foco de la capa visible
func _on_window_focus_restored() -> void:
	if _stack.is_empty():
		return
	# Verificar si hay un control con foco válido
	var focused := get_viewport().gui_get_focus_owner()
	if focused and focused.is_inside_tree():
		return  # ya hay foco válido
	# Restaurar foco a la capa visible del tope
	for i in range(_stack.size() - 1, -1, -1):
		var layer := _stack[i]
		if layer.visible and layer.has_method("focus_first"):
			var first: Node = layer.focus_first()
			if first and first is Control:
				first.grab_focus()
				ui_focus_moved.emit(first)
				_log("foco restaurado tras alt-tab: %s" % layer.name)
				return
