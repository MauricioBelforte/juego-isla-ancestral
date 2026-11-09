# Modelo: DeepSeek-V4.1-Flash (OpenCode)
# Plataforma: OpenCode
# Fecha: 2026-11-08
#
# M111 - Código de Calidad: componente reutilizable de salud (composición).
#
# ENDURECIDO EN 2026-11-08 (crítico de la evaluación Nemotron, Glyph Cluster):
#   1. `damage()` aceptaba cualquier float: un daño NEGATIVO curaba y un NaN se
#      propagaba a `current_health` (el clamp de Godot NO filtra NaN), dejando la
#      entidad en un estado imposible. Ahora se rechazan NaN/infinito y valores
#      <= 0 (daño 0 tampoco emite señales falsas).
#   2. La muerte era repetible: cada `damage` con salud ya en 0 volvía a emitir
#      `died`. Ahora hay `is_dead` y la señal se emite UNA sola vez.
#   3. La señal `died` estaba desalineada con `IDamageable` (0 args vs
#      `died(killer: Node)`). Ahora es `died(killer)` y `health_changed` lleva el
#      tercer argumento del contrato (`delta`).
#   4. Se agregó la API del contrato para que el componente pueda usarse como
#      `IDamageable` por duck-typing: `take_damage`, `get_health`,
#      `get_max_health`, `is_alive`, `set_health`, `revive`.
#
# Nota de integración (honesta): al día de hoy NINGÚN sistema del runtime
# instancia este componente (la búsqueda en `scripts/` solo lo encuentra a él
# mismo). El consumidor (jugador/NPCs, M64) sigue pendiente y NO se simula acá.

class_name HealthComponent
extends Node

## `current` = salud después del cambio; `max_value` = máximo vigente;
## `delta` = variación aplicada (negativa en daño, positiva en curación).
signal health_changed(current: float, max_value: float, delta: float)
## `killer` = quien causó la muerte (null si no se conoce).
signal died(killer: Node)
## Se emitió un daño/curación RECHAZADO (valor inválido, ya muerto, etc.).
signal cambio_ignorado(amount: float, motivo: String)

const MOTIVO_NO_NUMERICO := "no_numerico"
const MOTIVO_NO_POSITIVO := "no_positivo"
const MOTIVO_MUERTO := "ya_muerto"
const MOTIVO_YA_AL_MAXIMO := "ya_al_maximo"

@export var max_health: float = 100.0

var is_dead: bool = false

var current_health: float:
	get:
		return _current
	set(v):
		_aplicar(v, 0.0, null)

var _current: float = 100.0


func _ready() -> void:
	_sanear_maximo()
	_current = max_health
	is_dead = false


## Aplica daño. Devuelve true SOLO si se aplicó (valor finito y > 0, vivo).
## `killer` se propaga en la señal `died` (contrato IDamageable).
func damage(amount: float, killer: Node = null) -> bool:
	if is_dead:
		cambio_ignorado.emit(amount, MOTIVO_MUERTO)
		return false
	if not _valor_util(amount):
		cambio_ignorado.emit(amount, MOTIVO_NO_NUMERICO if not is_finite(amount) else MOTIVO_NO_POSITIVO)
		return false
	var nuevo := clampf(_current - amount, 0.0, max_health)
	_aplicar(nuevo, -amount, killer)
	return true


## Cura. Devuelve true SOLO si se aplicó (vivo, valor finito y > 0, no al tope).
func heal(amount: float) -> bool:
	if is_dead:
		cambio_ignorado.emit(amount, MOTIVO_MUERTO)
		return false
	if not _valor_util(amount):
		cambio_ignorado.emit(amount, MOTIVO_NO_NUMERICO if not is_finite(amount) else MOTIVO_NO_POSITIVO)
		return false
	if _current >= max_health:
		cambio_ignorado.emit(amount, MOTIVO_YA_AL_MAXIMO)
		return false
	var nuevo := clampf(_current + amount, 0.0, max_health)
	_aplicar(nuevo, nuevo - _current, null)
	return true


## Revive con una fracción del máximo (1.0 = salud completa). No revive a un
## vivo (devuelve false) para que no se use como curación encubierta.
func revive(fraccion: float = 1.0) -> bool:
	if not is_dead:
		return false
	var f: float = fraccion if is_finite(fraccion) else 1.0
	f = clampf(f, 0.01, 1.0)
	is_dead = false
	_aplicar(max_health * f, max_health * f, null)
	return true


# ── Contrato IDamageable (duck-typing) ──────────────────────────────

## `IDamageable.take_damage` devuelve el daño REAL aplicado (float).
func take_damage(amount: float, _damage_type: StringName = &"", source: Node = null) -> float:
	if not damage(amount, source):
		return 0.0
	return maxf(0.0, amount)


func get_health() -> float:
	return _current


func get_max_health() -> float:
	return max_health


func is_alive() -> bool:
	return not is_dead and _current > 0.0


## Fija la salud directamente (saves, respawn, debug). Sanea NaN/infinito y
## clampea a [0, max]. Si llega a 0 marca muerto y emite `died` una sola vez.
func set_health(value: float) -> void:
	if not is_finite(value):
		cambio_ignorado.emit(value, MOTIVO_NO_NUMERICO)
		return
	var nuevo := clampf(value, 0.0, max_health)
	_aplicar(nuevo, nuevo - _current, null)


# ── Núcleo ──────────────────────────────────────────────────────────

func _aplicar(nuevo: float, delta: float, killer: Node) -> void:
	# Blindaje: el setter es público (`current_health = x`), así que un NaN o
	# un infinito pueden llegar por ahí aunque `damage/heal` ya los filtren.
	if not is_finite(nuevo):
		cambio_ignorado.emit(nuevo, MOTIVO_NO_NUMERICO)
		return
	nuevo = clampf(nuevo, 0.0, max_health)
	var cambio := nuevo - _current
	_current = nuevo
	health_changed.emit(_current, max_health, cambio if is_finite(delta) else cambio)
	if _current <= 0.0 and not is_dead:
		is_dead = true
		died.emit(killer)


func _sanear_maximo() -> void:
	if not is_finite(max_health) or max_health <= 0.0:
		push_warning("[HealthComponent] max_health invalido (%s): se usa 100.0" % str(max_health))
		max_health = 100.0


static func _valor_util(amount: float) -> bool:
	return is_finite(amount) and amount > 0.0
