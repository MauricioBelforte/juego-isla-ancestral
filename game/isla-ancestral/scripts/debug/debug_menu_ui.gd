# Modelo: agnes-3-flash
# Plataforma: Kilo Code
# Fecha: 2026-10-09
# M110-UI slice 3: DebugMenuUI — controlador de la escena debug_menu.tscn.
# Consume el backend debug_menu.gd sin modificarlo.
extends CanvasLayer
class_name DebugMenuUI

var _debug_menu: Node = null
var _tab_bar: TabBar = null
var _content: Control = null
var _title: Label = null
var _close_btn: Button = null
var _console: Control = null
var _visible := false

func _ready() -> void:
	_debug_menu = get_node_or_null("/root/DebugMenu")
	_tab_bar = $RootPanel/TabBar
	_content = $RootPanel/ContentPanel
	_title = $RootPanel/TitleBar/TitleLabel
	_close_btn = $RootPanel/TitleBar/CloseButton
	_close_btn.pressed.connect(_on_close)
	
	# Crear consola en el ContentPanel
	_console = (load("res://scripts/debug/debug_console.gd") as Script).new()
	_content.add_child(_console)
	
	# Conectar señales del backend
	if _debug_menu != null:
		if _debug_menu.has_signal("estacion_solicitada"):
			_debug_menu.connect("estacion_solicitada", _on_estacion_solicitada)
		if _debug_menu.has_signal("clima_solicitado"):
			_debug_menu.connect("clima_solicitado", _on_clima_solicitado)
		if _debug_menu.has_method("esta_visible"):
			_visible = _debug_menu.esta_visible()
	
	# Configurar TabBar (5 pestañas del config JSON)
	_configurar_tabs()

func _configurar_tabs() -> void:
	var config_path := "res://data/debug/debug_menu_config.json"
	var tabs := ["Jugador", "Mundo", "Entidades", "Visualización", "Sistema"]
	if FileAccess.file_exists(config_path):
		var txt := FileAccess.get_file_as_string(config_path)
		var json: Variant = JSON.parse_string(txt)
		if json != null and json.has("pestanas"):
			tabs = json["pestanas"]
	_tab_bar.tab_changed.connect(_on_tab_changed)
	# TabBar no tiene set_titles() en Godot 4; usamos tooltip
	_tab_bar.tooltip_text = " | ".join(tabs)

func _on_tab_changed(tab: int) -> void:
	# Cambiar contenido del panel según pestaña
	if _console != null:
		match tab:
			0: _console.set_text("[b]Panel: Jugador[/b]\nTeletransporte, inventario, progreso")
			1: _console.set_text("[b]Panel: Mundo[/b]\nHora, estación, clima, chunks")
			2: _console.set_text("[b]Panel: Entidades[/b]\nNPC, puzzles")
			3: _console.set_text("[b]Panel: Visualización[/b]\nColliders, FPS, chunks, nav, hitbox, IA")
			4: _console.set_text("[b]Panel: Sistema[/b]\nDebug, UI, exportar, cache, help")

func _on_close() -> void:
	if _debug_menu != null and _debug_menu.has_method("alternar"):
		_debug_menu.alternar()

func _on_estacion_solicitada(estacion: String) -> void:
	if _console != null:
		_console.agregar_linea_publica("Estación solicitada: " + estacion)

func _on_clima_solicitado(clima: String) -> void:
	if _console != null:
		_console.agregar_linea_publica("Clima solicitado: " + clima)

## Devuelve si el UI está visible (para tests).
func esta_visible_ui() -> bool:
	return visible and _visible

## Devuelve el TabBar (para tests).
func obtener_tab_bar() -> TabBar:
	return _tab_bar

## Devuelve el ContentPanel (para tests).
func obtener_contenido() -> Control:
	return _content

## Devuelve la consola (para tests).
func obtener_consola() -> Control:
	return _console

## Devuelve si el backend está conectado.
func backend_conectado() -> bool:
	return _debug_menu != null
