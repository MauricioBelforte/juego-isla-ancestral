extends CanvasLayer
class_name HUDScreen
## CanvasLayer del HUD siempre visible
##
## Contiene todos los widgets del HUD: StatusBar, ClockWidget,
## SeasonWidget, ResourceCounter, HotbarWidget, InteractPrompt,
## MinimapWidget, ActionPromptOverlay y NotificationService.
##
## El HUD NO muta estado de gameplay; solo lee por señales.

## ── Referencias a widgets ────────────────────────────────
@onready var status_bar: Control = %StatusBar if has_node("%StatusBar") else null
@onready var clock_widget: Control = %ClockWidget if has_node("%ClockWidget") else null
@onready var season_widget: Control = %SeasonWidget if has_node("%SeasonWidget") else null
@onready var resource_counter: Control = %ResourceCounter if has_node("%ResourceCounter") else null
@onready var hotbar_widget: Control = %HotbarWidget if has_node("%HotbarWidget") else null
@onready var interact_prompt: Control = %InteractPrompt if has_node("%InteractPrompt") else null
@onready var minimap_widget: Control = %MinimapWidget if has_node("%MinimapWidget") else null
@onready var action_prompt_overlay: Control = %ActionPromptOverlay if has_node("%ActionPromptOverlay") else null

## ── Timer de refresh de baja frecuencia ─────────────────
## Refresca widgets de datos a 2 Hz (sin polling por frame)
var _refresh_timer: Timer = null

## ── Estado ──────────────────────────────────────────────
## Si el HUD está visible
var _hud_visible: bool = true

## ── Ciclo de vida ──────────────────────────────────────

func _ready() -> void:
	# Registrar en UIManager
	var ui_manager := _get_ui_manager()
	if ui_manager:
		ui_manager.register_hud(self)

	# Configurar timer de refresh a 2 Hz
	_refresh_timer = Timer.new()
	_refresh_timer.wait_time = 0.5
	_refresh_timer.one_shot = false
	_refresh_timer.timeout.connect(_on_refresh_timer)
	add_child(_refresh_timer)
	_refresh_timer.start()

	# Conectar señales de EventBus
	_connect_event_bus()

	# Refresh inicial
	force_refresh()


## ── API pública ─────────────────────────────────────────

## Muestra u oculta el HUD completo
func set_hud_visible(_visible: bool) -> void:
	_hud_visible = _visible
	visible = _visible
	if not _visible:
		_refresh_timer.stop()
	else:
		_refresh_timer.start()
		force_refresh()


## Fuerza un refresh inmediato de todos los widgets
func force_refresh() -> void:
	_refresh_status_bar()
	_refresh_clock()
	_refresh_season()
	_refresh_resources()
	_refresh_hotbar()


## Vincula el StatusBar a una Callable que provee los datos
## del jugador (sin tocar gameplay directamente)
func bind_status(source: Callable) -> void:
	if status_bar and status_bar.has_method("bind"):
		status_bar.bind(source)


## ── Métodos privados: refresh ───────────────────────────

func _refresh_status_bar() -> void:
	if status_bar and status_bar.has_method("refresh"):
		status_bar.refresh()


func _refresh_clock() -> void:
	if clock_widget and clock_widget.has_method("refresh"):
		clock_widget.refresh()


func _refresh_season() -> void:
	if season_widget and season_widget.has_method("refresh"):
		season_widget.refresh()


func _refresh_resources() -> void:
	if resource_counter and resource_counter.has_method("refresh"):
		resource_counter.refresh()


func _refresh_hotbar() -> void:
	if hotbar_widget and hotbar_widget.has_method("refresh"):
		hotbar_widget.refresh()


## ── Conexión a EventBus ─────────────────────────────────

func _connect_event_bus() -> void:
	var bus := _get_event_bus()
	if not bus:
		return

	# Eventos de inventario → refresh hotbar
	if bus.inventory:
		if bus.inventory.item_added.is_connected(_on_inventory_changed):
			return
		bus.inventory.item_added.connect(_on_inventory_changed)
		bus.inventory.item_removed.connect(_on_inventory_changed)
		bus.inventory.hotbar_selected.connect(_on_hotbar_selected)

	# Eventos de calendario → refresh reloj/estación
	if bus.calendar:
		if bus.calendar.day_started.is_connected(_on_day_started):
			return
		bus.calendar.day_started.connect(_on_day_started)
		bus.calendar.season_changed.connect(_on_season_changed)

	# Eventos de economía → refresh recursos
	if bus.economy:
		if bus.economy.currency_changed.is_connected(_on_currency_changed):
			return
		bus.economy.currency_changed.connect(_on_currency_changed)


## ── Callbacks de EventBus ───────────────────────────────

func _on_inventory_changed(_item_id: String, _quantity: int) -> void:
	_refresh_hotbar()
	_refresh_resources()


func _on_hotbar_selected(_slot_index: int) -> void:
	_refresh_hotbar()


func _on_day_started(_day: int, _season: String) -> void:
	_refresh_clock()
	_refresh_season()


func _on_season_changed(_old_season: String, _new_season: String) -> void:
	_refresh_season()


func _on_currency_changed(_old: int, _new: int) -> void:
	_refresh_resources()


## ── Timer callback ──────────────────────────────────────

func _on_refresh_timer() -> void:
	if _hud_visible:
		_refresh_clock()
		_refresh_season()


## ── Utilidades ──────────────────────────────────────────

func _get_ui_manager() -> Node:
	return get_node_or_null("/root/UIManager")


func _get_event_bus() -> EventBus_:
	var bus := get_node_or_null("/root/EventBus")
	return bus as EventBus_ if bus else null
