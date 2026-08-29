extends Control
class_name UILayer
## Clase base para todas las capas de UI modales
##
## Cada capa modal (diálogo, inventario, pausa, menús) extiende
## esta clase y overridea on_layer_opened/on_layer_closed.
##
## Reglas:
## - Se registra automáticamente en UIManager al entrar al árbol
## - La pila de UIManager gestiona el foco y la pausa
## - open/close activan/desactivan la visibilidad

## ── Tipo de capa ────────────────────────────────────────
## Tipo de modalidad de esta capa (HUD, MODAL_SIMPLE, MODAL_FULL, POPUP)
@export var layer_type: UILayerType.Type = UILayerType.Type.MODAL_FULL

## ── Referencia a UIManager ──────────────────────────────
var _ui_manager: Node = null


## ── Ciclo de vida ──────────────────────────────────────

func _enter_tree() -> void:
	# Registrar en UIManager cuando entra al árbol
	_ui_manager = _get_ui_manager()
	if _ui_manager:
		_ui_manager.register_layer(self) if _ui_manager.has_method("register_layer") else null


func _exit_tree() -> void:
	# Des-registrar de UIManager cuando sale del árbol
	if _ui_manager and _ui_manager.has_method("unregister_layer"):
		_ui_manager.unregister_layer(self)


## ── API pública ─────────────────────────────────────────

## Abre la capa con foco inicial opcional
func open(initial_focus: Control = null) -> void:
	visible = true
	_apply_process_mode()
	on_layer_opened()
	# Enfocar el primer control o el especificado
	if initial_focus:
		initial_focus.grab_focus()
	elif has_method("focus_first"):
		focus_first()


## Cierra la capa
func close() -> void:
	on_layer_closed()
	visible = false


## Devuelve el primer control enfocable de la capa
func focus_first() -> Control:
	return _find_first_focusable(self)


## ── Métodos virtuales (override en subclases) ──────────

## Se llama al abrir la capa. Suscribirse a EventBus aquí.
func on_layer_opened() -> void:
	pass


## Se llama al cerrar la capa. Desuscribirse de EventBus aquí.
func on_layer_closed() -> void:
	pass


## ── Métodos privados ────────────────────────────────────

## Aplica el process_mode según el tipo de capa
func _apply_process_mode() -> void:
	match layer_type:
		UILayerType.Type.HUD:
			process_mode = Node.PROCESS_MODE_ALWAYS
		UILayerType.Type.MODAL_SIMPLE:
			process_mode = Node.PROCESS_MODE_ALWAYS
		UILayerType.Type.MODAL_FULL:
			process_mode = Node.PROCESS_MODE_DISABLED
		UILayerType.Type.POPUP:
			process_mode = Node.PROCESS_MODE_ALWAYS


## Busca el primer Control enfocable en el subárbol
func _find_first_focusable(node: Node) -> Control:
	if node is Control and node.visible and node.focus_mode != Control.FOCUS_NONE:
		return node as Control
	for child in node.get_children():
		if child is Control and child.visible and child.focus_mode != Control.FOCUS_NONE:
			return child as Control
		var result := _find_first_focusable(child)
		if result:
			return result
	return null


## Obtiene la referencia al UIManager autoload
func _get_ui_manager() -> Node:
	return get_node_or_null("/root/UIManager")
