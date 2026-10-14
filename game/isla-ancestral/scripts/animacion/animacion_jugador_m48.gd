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
# Modelo: step-5-kilocode | Plataforma: Kilo Code | Fecha: 2026-10-10
# Modificado 2026-10-11 por atria-dawn: referencia al autoload AnimationService
# reemplazada por Engine.get_singleton (fix CI M118, BUG-129).

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

## Singleton AnimationService resuelto en runtime. Se usa Engine.get_singleton en
## vez de la referencia directa al autoload para que el script compile con
## --check-only en CI (M118): el compilador headless no resuelve autoloads sin el
## class cache del editor, y este script nuevo no esta precompilado en el cache.
var _anim: Node = null


func _ready() -> void:
	# Singleton del servicio de animacion (autoload M48).
	_anim = Engine.get_singleton("AnimationService")
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
	if _fsm == null or _anim == null:
		return
	var nombre := String(_fsm.nombre_actual())
	if nombre == _ultimo_estado:
		return
	_ultimo_estado = nombre
	var estado := StringName(MAPEO.get(nombre, nombre))
	if not MAPEO.has(nombre):
		# Estado sin clip: el servicio emite animation_missing y usa fallback idle.
		_anim.play(get_parent(), estado)
		return
	_anim.play(get_parent(), estado)
