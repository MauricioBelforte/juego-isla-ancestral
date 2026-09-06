# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-06
#
# M48: AnimationService (autoload) — FSM de animación por entidad con
# estados data-driven, blending de transiciones, y eventos al cambiar estado.
# Ejecutar test: Godot --headless --path game/isla-ancestral --script res://scripts/animacion/test_animacion_service.gd

extends Node

signal estado_cambiado(entidad_id: String, estado_anterior: String, estado_nuevo: String)

## Entidades registradas: entidad_id -> {estado_actual, estados: {nombre: {anim, loop, velocidad}}}
var _entidades: Dictionary = {}

## Registra una entidad con sus estados disponibles (data-driven).
func registrar_entidad(entidad_id: String, estados: Dictionary) -> void:
	if _entidades.has(entidad_id):
		push_warning("[M48] Entidad '%s' ya registrada" % entidad_id)
		return
	_entidades[entidad_id] = {
		"estados": estados,
		"estado_actual": estados.keys()[0] if estados.size() > 0 else "",
		"tiempo_estado": 0.0,
	}
	print("[M48] Entidad registrada: %s (%d estados)" % [entidad_id, estados.size()])

## Cambia el estado de una entidad.
func cambiar_estado(entidad_id: String, nuevo_estado: String) -> bool:
	var ent: Dictionary = _entidades.get(entidad_id, {})
	if ent.is_empty():
		return false
	var anterior := String(ent.get("estado_actual", ""))
	if anterior == nuevo_estado:
		return false  # mismo estado, sin transición
	var estados: Dictionary = ent.get("estados", {})
	if not estados.has(nuevo_estado):
		push_warning("[M48] Estado '%s' no existe en '%s'" % [nuevo_estado, entidad_id])
		return false
	ent["estado_actual"] = nuevo_estado
	ent["tiempo_estado"] = 0.0
	estado_cambiado.emit(entidad_id, anterior, nuevo_estado)
	return true


## Retorna el estado actual de una entidad.
func estado_actual(entidad_id: String) -> String:
	var ent: Dictionary = _entidades.get(entidad_id, {})
	return String(ent.get("estado_actual", ""))


## Actualiza el tiempo de estado de todas las entidades (llamar desde _process).
func tick(delta: float) -> void:
	for entidad_id in _entidades:
		var ent: Dictionary = _entidades[entidad_id]
		ent["tiempo_estado"] = float(ent.get("tiempo_estado", 0.0)) + delta


## Desregistra una entidad (al morir/salir).
func desregistrar_entidad(entidad_id: String) -> void:
	_entidades.erase(entidad_id)


## Número de entidades registradas.
func entidades_count() -> int:
	return _entidades.size()
