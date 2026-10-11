# Modelo: agnes-3-flash
# Plataforma: Kilo Code
# Fecha: 2026-10-09
# M18: InteriorTransition — fundido de entrada/salida de habitación.
# Controla un ColorRect fullscreen que hace fade in/out.
extends Control
class_name InteriorTransition

const DURATION := 0.3  # segundos
var _progreso := 0.0  # 0.0 = transparente, 1.0 = opaco
var _activo := false
var _direccion := 1  # 1 = fade in, -1 = fade out
var _modulo_color: Color = Color(0, 0, 0, 0.0)

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	visible = false

## Inicia transición de entrada (fade in).
func iniciar_entrada() -> void:
	_activo = true
	_direccion = 1
	_progreso = 0.0
	visible = true

## Inicia transición de salida (fade out).
func iniciar_salida() -> void:
	_activo = true
	_direccion = -1
	_progreso = 1.0
	visible = true

## Devuelve si hay una transición en curso.
func esta_activa() -> bool:
	return _activo

## Devuelve el progreso actual (0-1).
func obtener_progreso() -> float:
	return _progreso

## Devuelve si está en modo "completado" (progreso=0 o 1 y no activo).
func esta_completado() -> bool:
	return not _activo and (_progreso <= 0.0 or _progreso >= 1.0)

func _process(delta: float) -> void:
	if not _activo:
		return
	_progreso += delta / DURATION * _direccion
	if _direccion == 1 and _progreso >= 1.0:
		_progreso = 1.0
		_activo = false
	elif _direccion == -1 and _progreso <= 0.0:
		_progreso = 0.0
		_activo = false
		visible = false

## Setea progreso manualmente (para tests).
func set_progreso(valor: float) -> void:
	_progreso = clampf(valor, 0.0, 1.0)
	_activo = false
	visible = _progreso > 0.0
