# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-06
#
# M48: AnimationService (autoload) — FSM de animación por entidad con
# estados data-driven, blending de transiciones, y eventos al cambiar estado.
# Ejecutar test: Godot --headless --path game/isla-ancestral --script res://scripts/animacion/test_animacion_service.gd

extends Node

signal estado_cambiado(entidad_id: String, estado_anterior: String, estado_nuevo: String)

# --- Señales de la API de reproducción (Fase 1, M48) ---
signal animation_started(actor: Node, estado: StringName)
# animation_finished forma parte de la API de diseño (04-Codigo §3) pero se emite
# en la Fase 2, cuando los clips tengan duración real que escuchar vía
# AnimationPlayer.animation_finished. Declarada aquí para no romper el contrato.
signal animation_finished(actor: Node, estado: StringName)
signal animation_missing(actor: Node, estado: StringName)

## Duración de blend por defecto (segundos).
const BLEND_DEFAULT := 0.25

## Estado de fallback cuando un estado no tiene clip.
const ESTADO_FALLBACK := "idle"

## Entidades registradas: entidad_id -> {estado_actual, estados: {nombre: {anim, loop, velocidad}}}
var _entidades: Dictionary = {}

## Cache de AnimationPlayer por actor (ruta del nodo dentro del actor).
var _players: Dictionary = {}

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


# ---------------------------------------------------------------------------
# API de reproducción (Fase 1, M48)
# ---------------------------------------------------------------------------

## Obtiene (o cachea) el AnimationPlayer del actor.
## Busca en el actor, y si no está, en sus hijos.
func obtener_player(actor: Node) -> AnimationPlayer:
	if actor == null:
		return null
	var clave := actor.get_instance_id()
	if _players.has(clave):
		return _players[clave]
	var player := actor.get_node_or_null("AnimationPlayer") as AnimationPlayer
	if player == null:
		for hijo in actor.get_children():
			if hijo is AnimationPlayer:
				player = hijo as AnimationPlayer
				break
	if player != null:
		_players[clave] = player
	return player


## Única puerta de entrada: la lógica de gameplay NUNCA llama a AnimationPlayer
## directamente; pide por ESTADO.
## - Si el estado no tiene clip: emite animation_missing y cae a ESTADO_FALLBACK.
## - Si el actor no tiene AnimationPlayer: emite animation_missing y no hace nada.
func play(actor: Node, estado: StringName, blend_time: float = BLEND_DEFAULT) -> void:
	if actor == null:
		return
	var player := obtener_player(actor)
	if player == null:
		push_warning("[M48] ANIM-MISSING: actor '%s' sin AnimationPlayer" % actor.name)
		animation_missing.emit(actor, estado)
		return
	# Resuelve el nombre del clip: "_" + estado en minúsculas.
	var nombre_clip := "anim_jugador_%s" % String(estado).to_lower()
	var lib := player.get_animation_library("")
	if lib == null or not lib.has_animation(nombre_clip):
		push_warning("[M48] ANIM-MISSING: estado '%s' sin clip en '%s'" % [estado, actor.name])
		animation_missing.emit(actor, estado)
		# Fallback documentado: idle.
		var fallback := "anim_jugador_%s" % ESTADO_FALLBACK
		if lib != null and lib.has_animation(fallback):
			player.play(fallback, blend_time)
			animation_started.emit(actor, ESTADO_FALLBACK)
		return
	player.play(nombre_clip, blend_time)
	animation_started.emit(actor, estado)
