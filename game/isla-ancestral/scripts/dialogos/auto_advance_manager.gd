# Modelo: agnes-2.5-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-04
#
# M21: Dialogos — AutoAdvanceManager
# Gestiona el avance automático de diálogos con temporizador y pausa en opciones.

extends Node

## Tiempo en segundos antes de avanzar automáticamente
@export var auto_advance_delay: float = 3.0
## Si true, pausa el auto-advance cuando hay opciones visibles
@export var pause_on_options: bool = true
## Temporizador acumulado
var _timer: float = 0.0
## Estado activo
var _active: bool = false
## Estado con opciones visibles
var _has_options: bool = false

## Señales
signal auto_advancing(delay: float)
signal auto_advance_skipped()
signal auto_advance_complete()


## Inicia el auto-advance
func start_auto_advance(delay: float = -1.0) -> void:
	_active = true
	_timer = 0.0
	_has_options = false
	if delay >= 0:
		auto_advance_delay = delay
	auto_advancing.emit(auto_advance_delay)


## Actualiza cada frame
func update(delta: float) -> void:
	if not _active:
		return
	
	# Pausar si hay opciones
	if _has_options and pause_on_options:
		return
	
	_timer += delta
	if _timer >= auto_advance_delay:
		_complete()


## Indica que hay opciones visibles (pausa auto-advance)
func set_has_options(has: bool) -> void:
	_has_options = has


## Salta el auto-advance (click del usuario)
func skip() -> void:
	if _active:
		_timer = auto_advance_delay
		auto_advance_skipped.emit()
		_complete()


## Detiene el auto-advance
func stop() -> void:
	_active = false
	_timer = 0.0
	_has_options = false


## Completa el avance
func _complete() -> void:
	_active = false
	_timer = 0.0
	auto_advance_complete.emit()


## Valida la configuración
static func validate_config(config: Dictionary) -> Array[String]:
	"""Retorna errores de configuración."""
	var errors: Array[String] = Array()
	var delay: float = float(config.get("auto_advance_delay", 3.0))
	if delay < 0.5:
		errors.append("auto_advance_delay demasiado bajo (<0.5s)")
	if delay > 30.0:
		errors.append("auto_advance_delay muy alto (>30s)")
	return errors


## Crea una instancia predeterminada
static func create_default() -> AutoAdvanceManager:
	var mgr := AutoAdvanceManager.new()
	mgr.auto_advance_delay = 3.0
	mgr.pause_on_options = true
	return mgr
