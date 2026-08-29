class_name MenuNavigator
## Navegación por foco con wrap-around para pantallas de UI
##
## Proporciona utilidades estáticas para gestionar el foco
## en pantallas con grids, listas y pestañas. Soporta:
## - Focus first/last
## - Wrap-around circular
## - Navegación direccional (4D con gamepad)
## - Tab entre pestañas
## - Tooltip por foco

## ── Focus management ────────────────────────────────────

## Devuelve el primer Control enfocable en una capa
static func focus_first(layer: UILayer, preferred: Control = null) -> Control:
	if preferred and is_instance_valid(preferred) and preferred.visible:
		preferred.grab_focus()
		return preferred
	return _find_first_focusable(layer)


## Devuelve el último Control enfocable en una capa
static func focus_last(layer: UILayer) -> Control:
	var focusables: Array[Control] = []
	_find_all_focusable(layer, focusables)
	if focusables.is_empty():
		return null
	return focusables[focusables.size() - 1]


## Mueve el foco en una dirección (wrap-around)
static func wrap_focus(layer: UILayer, direction: Vector2i) -> void:
	var current := layer.get_viewport().gui_get_focus_owner()
	if not current:
		focus_first(layer)
		return

	# Recopilar todos los enfocables
	var focusables: Array[Control] = []
	_find_all_focusable(layer, focusables)

	if focusables.is_empty():
		return

	# Encontrar el índice actual
	var current_idx := focusables.find(current)
	if current_idx == -1:
		focus_first(layer)
		return

	# Calcular siguiente índice según dirección
	var next_idx := current_idx
	if direction.x != 0:
		# Horizontal: mover en la dirección indicada
		next_idx = current_idx + direction.x
	elif direction.y != 0:
		# Vertical: buscar en la misma columna
		var current_rect := current.get_global_rect()
		for i in range(focusables.size()):
			if i == current_idx:
				continue
			var other_rect := focusables[i].get_global_rect()
			var same_column := absf(current_rect.position.x - other_rect.position.x) < 10.0
			if direction.y < 0 and other_rect.position.y < current_rect.position.y and same_column:
				next_idx = i
				break
			elif direction.y > 0 and other_rect.position.y > current_rect.position.y and same_column:
				next_idx = i
				break

	# Wrap-around
	next_idx = wrapi(next_idx, 0, focusables.size() - 1)

	if next_idx >= 0 and next_idx < focusables.size():
		focusables[next_idx].grab_focus()


## Mueve al siguiente/anterior tab (tab_next/tab_prev)
static func move_tab(layer: UILayer, next: bool = true) -> void:
	var tabs := _find_tabs(layer)
	if tabs.is_empty():
		return

	var current := layer.get_viewport().gui_get_focus_owner()
	var current_tab_idx := -1

	for i in range(tabs.size()):
		if tabs[i] == current or _is_descendant_of(current, tabs[i]):
			current_tab_idx = i
			break

	var next_idx: int
	if next:
		next_idx = (current_tab_idx + 1) % tabs.size()
	else:
		next_idx = (current_tab_idx - 1 + tabs.size()) % tabs.size()

	if next_idx >= 0 and next_idx < tabs.size():
		_activate_tab(tabs[next_idx])


## Muestra tooltip para el nodo enfocado actual
static func show_tooltip_for_focused(layer: UILayer) -> void:
	var focused := layer.get_viewport().gui_get_focus_owner()
	if focused and focused.has_method("get_tooltip_text"):
		var tooltip_svc := layer.get_node_or_null("/root/TooltipService")
		if tooltip_svc and tooltip_svc.has_method("show_tooltip"):
			tooltip_svc.show_tooltip(focused.get_tooltip_text(), focused)


## ── Métodos auxiliares privados ─────────────────────────

## Busca el primer enfocable en el subárbol
static func _find_first_focusable(node: Node) -> Control:
	if node is Control and node.visible and node.focus_mode != Control.FOCUS_NONE:
		return node as Control
	for child in node.get_children():
		if child is Control and child.visible and child.focus_mode != Control.FOCUS_NONE:
			return child as Control
		var result := _find_first_focusable(child)
		if result:
			return result
	return null


## Recopila todos los enfocables en el subárbol (append al array)
static func _find_all_focusable(node: Node, result: Array) -> void:
	if node is Control and node.visible and node.focus_mode != Control.FOCUS_NONE:
		result.append(node)
	for child in node.get_children():
		_find_all_focusable(child, result)


## Recopila todos los tabs (TabContainer, TabBar) en el subárbol
static func _find_tabs(node: Node) -> Array[Node]:
	var tabs: Array[Node] = []
	_find_tabs_recursive(node, tabs)
	return tabs


static func _find_tabs_recursive(node: Node, result: Array) -> void:
	if node is TabContainer or node is TabBar:
		result.append(node)
	for child in node.get_children():
		_find_tabs_recursive(child, result)


## Activa un tab específico
static func _activate_tab(tab: Node) -> void:
	if tab is TabContainer:
		# Seleccionar el siguiente tab no deshabilitado
		var current: int = tab.current_tab
		var next: int = (current + 1) % tab.get_tab_count()
		tab.current_tab = next
		# Enfocar el primer control del tab activo
		if tab.get_child(next) is Control:
			var first := _find_first_focusable(tab.get_child(next))
			if first:
				first.grab_focus()
	elif tab is TabBar:
		var current: int = tab.current_tab
		var next: int = (current + 1) % tab.get_tab_count()
		tab.current_tab = next


## Verifica si un nodo es descendiente de otro
static func _is_descendant_of(node: Node, parent: Node) -> bool:
	if not node:
		return false
	var current := node.get_parent()
	while current:
		if current == parent:
			return true
		current = current.get_parent()
	return false
