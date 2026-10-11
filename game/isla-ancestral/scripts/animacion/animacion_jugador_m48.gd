# M48 — Cableado del jugador: player_fsm (M11) -> AnimationService (M48).
#
# Nodo SEPARADO (AnimacionM48), aditivo: NO toca NucleoM11 ni player_core_m11.gd
# (cableados por DeepSeek en el sprint M11, Log 1594). Se suscribe por polling al
# estado de la FSM y pide la animacion por ESTADO al AnimationService.
#
# Mapeo estado FSM (11) -> clips disponibles (3 placeholder):
#   IDLE -> idle | WALK -> walk | RUN -> run
#   El resto (JUMP, FALL, SWIM, DIVE, SURFACE, INTERACT, SLEEP, CRAFT) no tiene
#   clip: el servicio emite animation_missing y cae a idle (fallback documentado).
#
# Modelo: stepfun-step-5-preview | Plataforma: Kilo Code | Fecha: 2026-10-10

extends Node

## Nodo hermano que tiene la FSM de M11 (cableado por DeepSeek).
const NODO_FSM := "NucleoM11"

## Mapeo estado FSM -> nombre de clip en la biblioteca.
const MAPEO := {
	"IDLE": "idle",
	"WALK": "walk",
	"RUN": "run",
}

var _fsm: RefCounted = null
var _ultimo_estado: String = ""


func _ready() -> void:
	# La FSM vive en el nodo hermano NucleoM11 (campo `fsm`).
	var hermano := get_node_or_null("../" + NODO_FSM)
	if hermano != null:
		_fsm = hermano.get("fsm")
	if _fsm == null:
		push_warning("[M48] No se encontro la FSM en '%s'; cableado inactivo" % NODO_FSM)
		return
	# Estado inicial sin reproducir nada todavia.
	_ultimo_estado = ""
	print("[M48] Cableado jugador listo (FSM con %d estados)" % _fsm.cantidad_estados())


func _process(_delta: float) -> void:
	if _fsm == null:
		return
	var nombre := String(_fsm.nombre_actual())
	if nombre == _ultimo_estado:
		return
	_ultimo_estado = nombre
	var estado := StringName(MAPEO.get(nombre, nombre))
	if not MAPEO.has(nombre):
		# Estado sin clip: el servicio emite animation_missing y usa fallback idle.
		AnimationService.play(get_parent(), estado)
		return
	AnimationService.play(get_parent(), estado)
