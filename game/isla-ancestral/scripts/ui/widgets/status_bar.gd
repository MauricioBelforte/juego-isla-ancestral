extends Control
class_name StatusBar
## Barra de estado del jugador (M53 - HUD)
##
## Muestra vitales del jugador: vida, energía y stamina.
## Lee datos por Callable o señales, sin acoplar a gameplay.
## Estilo cozy con barra redondeada y colores suaves.

## ── Colores ──────────────────────────────────────────────
const COLOR_HEALTH_BG := Color(0.35, 0.25, 0.20, 0.6)
const COLOR_HEALTH_FILL := Color(0.75, 0.35, 0.30)
const COLOR_STAMINA_BG := Color(0.30, 0.30, 0.20, 0.6)
const COLOR_STAMINA_FILL := Color(0.55, 0.65, 0.35)
const COLOR_ENERGY_BG := Color(0.25, 0.30, 0.35, 0.6)
const COLOR_ENERGY_FILL := Color(0.40, 0.55, 0.70)

const BAR_HEIGHT := 12
const BAR_WIDTH := 140
const BAR_RADIUS := 6

## ── Estado ──────────────────────────────────────────────
var _health: float = 1.0
var _stamina: float = 1.0
var _energy: float = 1.0
var _source: Callable = Callable()

## ── Nodos ──────────────────────────────────────────────
var _health_bar: ProgressBar
var _stamina_bar: ProgressBar
var _energy_bar: ProgressBar

## ── Ciclo de vida ──────────────────────────────────────

func _ready() -> void:
	_build_ui()


## ── API pública ─────────────────────────────────────────

## Vincula una Callable que retorna un diccionario con los datos
func bind(source: Callable) -> void:
	_source = source


## Actualiza los valores y repinta
func refresh() -> void:
	if _source.is_valid():
		var data: Variant = _source.call()
		if data is Dictionary:
			_health = float(data.get("health", 1.0))
			_stamina = float(data.get("stamina", 1.0))
			_energy = float(data.get("energy", 1.0))

	_apply_values()


## Establece valores directamente (sin Callable)
func set_values(health: float, stamina: float, energy: float) -> void:
	_health = clampf(health, 0.0, 1.0)
	_stamina = clampf(stamina, 0.0, 1.0)
	_energy = clampf(energy, 0.0, 1.0)
	_apply_values()


## ── Métodos privados ────────────────────────────────────

func _build_ui() -> void:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	add_child(vbox)

	_health_bar = _create_bar(COLOR_HEALTH_BG, COLOR_HEALTH_FILL)
	vbox.add_child(_health_bar)

	_stamina_bar = _create_bar(COLOR_STAMINA_BG, COLOR_STAMINA_FILL)
	vbox.add_child(_stamina_bar)

	_energy_bar = _create_bar(COLOR_ENERGY_BG, COLOR_ENERGY_FILL)
	vbox.add_child(_energy_bar)


func _create_bar(bg_color: Color, fill_color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(BAR_WIDTH, BAR_HEIGHT)
	bar.max_value = 1.0
	bar.value = 1.0
	bar.show_percentage = false

	# Estilo de fondo
	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = bg_color
	bg_style.set_corner_radius_all(BAR_RADIUS)
	bar.add_theme_stylebox_override("background", bg_style)

	# Estilo de relleno
	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = fill_color
	fill_style.set_corner_radius_all(BAR_RADIUS)
	bar.add_theme_stylebox_override("fill", fill_style)

	return bar


func _apply_values() -> void:
	if _health_bar:
		_health_bar.value = _health
	if _stamina_bar:
		_stamina_bar.value = _stamina
	if _energy_bar:
		_energy_bar.value = _energy
