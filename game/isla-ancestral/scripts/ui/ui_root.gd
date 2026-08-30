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
var hud_screen: Node

func _ready() -> void:
	layer = 100
	_build_layers()
	_build_hud()

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

## Monta el HUDScreen formal (M53) con sus widgets como únicos (%Nombre)
func _build_hud() -> void:
	var hud_load := load("res://scripts/ui/hud/hud_screen.gd")
	if hud_load == null:
		return
	hud_screen = hud_load.new()
	hud_screen.name = "HUDScreen"
	add_child(hud_screen)

	# Widgets del HUD con unique_name_in_owner para %Nombre del HUDScreen
	var control := Control.new()
	control.name = "Root"
	control.set_anchors_preset(Control.PRESET_FULL_RECT)
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_screen.add_child(control)

	_agregar_widget_hud(control, load("res://scripts/ui/widgets/status_bar.gd"), "StatusBar")
	_agregar_widget_hud(control, load("res://scripts/ui/widgets/clock_widget.gd"), "ClockWidget")
	_agregar_widget_hud(control, load("res://scripts/ui/widgets/season_widget.gd"), "SeasonWidget")
	_agregar_widget_hud(control, load("res://scripts/ui/widgets/resource_counter.gd"), "ResourceCounter")
	_agregar_widget_hud(control, load("res://scripts/ui/widgets/interact_prompt.gd"), "InteractPrompt")
	_agregar_widget_hud(control, load("res://scripts/ui/widgets/action_prompt_overlay.gd"), "ActionPromptOverlay")

	# Layout del HUD (regla §9.47: sin superposiciones; el HUD dev viejo usa arriba-izq)
	_posicionar(control, "ClockWidget", Vector2(1, 0), Vector2(-260, 12))     # arriba-derecha
	_posicionar(control, "SeasonWidget", Vector2(1, 0), Vector2(-260, 70))    # bajo el reloj
	_posicionar(control, "ResourceCounter", Vector2(1, 0), Vector2(-260, 128)) # bajo la estación
	_posicionar(control, "StatusBar", Vector2(0.5, 1), Vector2(-120, -70))    # abajo-centro

	if hud_screen.has_method("force_refresh"):
		hud_screen.force_refresh()
	print("[DOM-UI] UIRoot: HUDScreen montado con widgets")

func _posicionar(parent: Control, nombre: String, anchor: Vector2, offset: Vector2) -> void:
	var widget = parent.get_node_or_null(nombre)
	if widget is Control:
		widget.anchor_left = anchor.x
		widget.anchor_right = anchor.x
		widget.anchor_top = anchor.y
		widget.anchor_bottom = anchor.y
		widget.offset_left = offset.x
		widget.offset_top = offset.y
		widget.offset_right = offset.x + 240
		widget.offset_bottom = offset.y + 52

func _agregar_widget_hud(parent: Control, script: Script, nombre: String) -> void:
	if script == null:
		return
	var widget = script.new()
	widget.name = nombre
	widget.unique_name_in_owner = true
	if widget is Control:
		widget.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(widget)
