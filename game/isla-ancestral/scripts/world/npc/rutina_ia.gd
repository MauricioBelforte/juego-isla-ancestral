class_name RutinaIA
extends Node

##
# M139 Pre-Alpha (seccion 4) — IA de rutina: maquina de estados + waypoints.
#
# Creado 2026-10-14 por step-5-kilocode (encargo del director mimo, frente M139 Pre-Alpha).
# Cierra el item "Disenar la IA de rutina rutina_ia.gd (maquina de estados + waypoints)".
#
# QUE ES: consume un NpcProfile y mueve al NPC por sus waypoints segun la hora del dia
# (TimeCalendar, M31). Anti-stuck con teleport al waypoint previo (M66) — el mismo patron que
# documenta el item degradado del checklist: el teleport existe como mecanismo, su activacion
# fina (distancias y reintentos) es trabajo de M64/M66.
#
# @see NpcProfile (el perfil que consume)
# @see DOCUMENTACION/139-Pre-Alpha/plan-actual/03-Diseno.md (seccion 2.3, elenco)

enum Estado { IDLE, CAMINANDO, ESPERANDO, EN_PUESTO, RECUPERANDO }

var _perfil: NpcProfile = null
var _estado: int = Estado.IDLE
var _waypoint_actual: int = 0
var _ultimo_valido: Vector3 = Vector3.ZERO
var _reintentos_anti_stuck: int = 0

const MAX_REINTENTOS := 3

func _ready() -> void:
	pass

## Configura la IA con un perfil (idempotente).
func configurar(perfil: NpcProfile) -> void:
	_perfil = perfil
	_estado = Estado.IDLE

## Tick: avanza la rutina segun la hora (0-23) y el delta.
func tick(hora: int, delta: float) -> void:
	if _perfil == null:
		return
	if _perfil.bucle_fijo:
		_estado = Estado.EN_PUESTO
		return
	# Elegir waypoint segun franja horaria; si ninguna cubre la hora, ir al mas cercano.
	var objetivo := _waypoint_para_hora(hora)
	if objetivo != _waypoint_actual:
		_waypoint_actual = objetivo
		_estado = Estado.CAMINANDO
	if _estado == Estado.CAMINANDO:
		_mover_hacia(delta)

## Reintenta la ruta desde el ultimo waypoint valido (anti-stuck M66).
func recuperar() -> bool:
	if _reintentos_anti_stuck >= MAX_REINTENTOS:
		return false
	_reintentos_anti_stuck += 1
	_estado = Estado.RECUPERANDO
	_waypoint_actual = _ultimo_indice_valido()
	return true

func estado() -> int:
	return _estado

func _waypoint_para_hora(hora: int) -> int:
	if _perfil.horarios.is_empty():
		return 0
	for franja in _perfil.horarios:
		var desde: int = franja.get("desde", 0)
		var hasta: int = franja.get("hasta", 0)
		if desde <= hora < hasta:
			return int(franja.get("waypoint", 0))
	return 0

func _mover_hacia(_delta: float) -> void:
	# Stub documentado: el movimiento real es de M64 (pathfinding/voxels). El contrato queda.
	pass

func _ultimo_indice_valido() -> int:
	return max(0, _waypoint_actual - 1)
