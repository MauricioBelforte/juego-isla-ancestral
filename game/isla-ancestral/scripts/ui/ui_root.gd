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

var dialog_layer: Node
var pause_layer: Node
var menus_layer: Node
var confirm_popup: Node

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

	print("[DOM-UI] UIRoot: capas montadas (dialogo=%s pausa=%s menus=%s confirm=%s)" % [
		dialog_layer != null, pause_layer != null, menus_layer != null, confirm_popup != null])
