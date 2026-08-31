# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M53: UIRoot — punto de montaje del framework de capas.
# Instancia las capas modales del M53 (DialogLayer, PauseLayer, MenusLayer,
# ConfirmPopup) bajo un CanvasLayer y las registra en el UIManager.
# El HUD (HUDScreen) se mantiene aparte y se registra como capa HUD.
#
# Se agrega como hijo de la escena principal. La DialogueUI de M21 (fallback
# simple) convive; DialogLayer es la capa formal del framework M53.

class_name UIRoot
extends CanvasLayer

## ⚠️ §9.47 (07-GUIA-GODOT): NO montar widgets HUD aquí.
## Los widgets oficiales viven en el CanvasLayer "UI" de la escena
## (RelojWidget w_reloj.gd, StatusBar, InteractPrompt) y en player.gd
## (hotbar dinámico). Este UIRoot SOLO monta las capas MODALES del M53
## (DialogLayer, PauseLayer, MenusLayer, ConfirmPopup) que no existían.

var dialog_layer: Node
var pause_layer: Node
var menus_layer: Node
var confirm_popup: Node
var crafting_ui: Node = null
var inventory_layer: Node = null
var shop_ui: Node = null

func _ready() -> void:
	layer = 100
	_build_layers()

func _build_layers() -> void:
	# Capa de diálogo (presentación formal del M21)
	var dl_load := load("res://scripts/ui/layers/dialog_layer.gd")
	if dl_load:
		dialog_layer = dl_load.new()
		dialog_layer.name = "DialogLayer"
		add_child(dialog_layer)

	# Capa de pausa
	var pl_load := load("res://scripts/ui/layers/pause_layer.gd")
	if pl_load:
		pause_layer = pl_load.new()
		pause_layer.name = "PauseLayer"
		add_child(pause_layer)

	# Menú principal
	var ml_load := load("res://scripts/ui/layers/menus_layer.gd")
	if ml_load:
		menus_layer = ml_load.new()
		menus_layer.name = "MenusLayer"
		add_child(menus_layer)

	# Popup de confirmación
	var cp_load := load("res://scripts/ui/layers/confirm_popup.gd")
	if cp_load:
		confirm_popup = cp_load.new()
		confirm_popup.name = "ConfirmPopup"
		add_child(confirm_popup)

	# Panel de crafting (M16) como capa MODAL_SIMPLE
	crafting_ui = null
	var cu_load := load("res://scripts/crafting/crafting_ui.gd")
	if cu_load:
		crafting_ui = cu_load.new()
		crafting_ui.name = "CraftingUI"
		add_child(crafting_ui)

	# Panel de inventario (M53 sección E, consume M14)
	var inv_load := load("res://scripts/ui/layers/inventory_layer.gd")
	if inv_load:
		inventory_layer = inv_load.new()
		inventory_layer.name = "InventoryLayer"
		add_child(inventory_layer)

	# Panel de tienda (M39, consume ShopManager/M38)
	var shop_load := load("res://scripts/shops/shop_ui.gd")
	if shop_load:
		shop_ui = shop_load.new()
		shop_ui.name = "ShopUI"
		add_child(shop_ui)

	print("[DOM-UI] UIRoot: capas montadas (dialogo=%s pausa=%s menus=%s confirm=%s crafting=%s inventario=%s tienda=%s)" % [
		dialog_layer != null, pause_layer != null, menus_layer != null,
		confirm_popup != null, crafting_ui != null, inventory_layer != null, shop_ui != null])

func _agregar_widget_hud(parent: Control, script: Script, nombre: String) -> void:
	if script == null:
		return
	var widget = script.new()
	widget.name = nombre
	widget.unique_name_in_owner = true
	if widget is Control:
		widget.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(widget)
