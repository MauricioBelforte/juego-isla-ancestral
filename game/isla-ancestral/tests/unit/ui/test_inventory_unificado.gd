extends SceneTree

## Test BUG-001 (2026-09-02): unificación del inventario.
## Verifica que el InventoryLayer (M53) es el ÚNICO sistema de inventario:
##  - toggle() abre/cierra la capa (el overlay FondoDim viaja con ella).
##  - Al cerrar, ningún hijo queda visible (overlay no pegado).
##  - player.gd ya no maneja KEY_B (legacy desactivado).
##
## Ejecutar: godot --headless --path game/isla-ancestral
##            --script res://tests/unit/ui/test_inventory_unificado.gd

var _fallos: int = 0

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	await process_frame  # dejar que el árbol esté activo y los autoloads listos
	_test_toggle()
	_test_overlay()
	_test_legacy()
	if _fallos == 0:
		print("[OK] Test inventario unificado: 0 fallos")
	else:
		print("[FAIL] Test inventario unificado: %d fallo(s)" % _fallos)
	quit(_fallos)

func _check(desc: String, cond: bool) -> void:
	if cond:
		print("  [x] %s" % desc)
	else:
		_fallos += 1
		print("  [FALLO] %s" % desc)

func _test_toggle() -> void:
	print("--- toggle() abre/cierra")
	var layer = load("res://scripts/ui/layers/inventory_layer.gd").new()
	layer.name = "InventoryLayer"
	root.add_child(layer)
	await process_frame
	_check("arranca oculta", layer.visible == false)
	layer.toggle()
	await process_frame
	_check("toggle() abre", layer.visible == true)
	layer.toggle()
	await process_frame
	_check("toggle() cierra (overlay viaja con la capa)", layer.visible == false)
	layer.free()

func _test_overlay() -> void:
	print("--- Sin overlays pegados tras cerrar")
	var layer = load("res://scripts/ui/layers/inventory_layer.gd").new()
	layer.name = "InventoryLayer"
	root.add_child(layer)
	await process_frame
	layer.toggle()
	await process_frame
	var dims: Array = layer.find_children("FondoDim", "ColorRect", true, false)
	_check("existe FondoDim dentro de la capa", dims.size() == 1)
	layer.visible = false
	await process_frame
	_check("al cerrar no queda ningún hijo visible", not _tiene_hijo_visible(layer))
	_check("no existe nodo Backdrop (legacy de player.gd) en el árbol", _buscar_nombre(root, "Backdrop") == null)
	layer.free()

func _test_legacy() -> void:
	print("--- legacy de player.gd")
	var f := FileAccess.open("res://scripts/player/player.gd", FileAccess.READ)
	var content := ""
	if f:
		content = f.get_as_text()
		f.close()
	_check("player.gd ya no contiene KEY_B", not content.contains("KEY_B"))
	_check("player.gd marca la sección M14 como legacy inerte", content.contains("LEGACY INERTE"))

func _tiene_hijo_visible(node: Node) -> bool:
	for child in node.get_children():
		if child is Control and child.is_visible_in_tree():
			return true
	return false

func _buscar_nombre(node: Node, nombre: String) -> Node:
	for child in node.get_children():
		if child.name == nombre:
			return child
		var r := _buscar_nombre(child, nombre)
		if r:
			return r
	return null