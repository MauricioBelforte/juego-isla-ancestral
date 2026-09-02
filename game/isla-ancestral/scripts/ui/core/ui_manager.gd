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

## ── Ciclo de vida ──────────────────────────────────────

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
	# M53 RF6: tooltip por foco (accesible por teclado/gamepad)
	ui_focus_moved.connect(_on_focus_moved_tooltip)

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
func _on_focus_moved_tooltip(node: Node) -> void:
	if node is Control and str(node.tooltip_text) != "":
		var ts = get_node_or_null("/root/TooltipService")
		if ts == null:
			ts = _buscar_nodo(get_tree().root, "TooltipService")
		if ts and ts.has_method("show_tooltip"):
			ts.show_tooltip(str(node.tooltip_text), node)

## ── Acciones transversales (M57) ─────────────────────────
## Navegación por teclado/gamepad: usa el InputMap del proyecto (M57) para
## mover el foco entre controles de la capa visible, y abrir/cerrar capas.

func _unhandled_input(event: InputEvent) -> void:
	if _stack.is_empty():
		return
	var top_layer := _stack[_stack.size() - 1]
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
	pop_layer(_stack[_stack.size() - 1])


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


## ── Logging ─────────────────────────────────────────────

func _log(msg: String) -> void:
	print("[DOM-UI] %s" % msg)
