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
# Modificado 2026-10-29 por DeepSeek-V4.1-Flash: `Engine.get_singleton` NO
# resuelve un autoload -> `_anim` quedaba null y el jugador no animaba en
# runtime (BUG-151). Ahora se resuelve por ruta de nodo (`/root/...`), que sigue
# compilando en CI sin el class cache (el motivo original del cambio de M118).

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

## Singleton AnimationService resuelto en runtime por RUTA de nodo (`/root/...`):
## `Engine.get_singleton()` NO resuelve un autoload (devuelve null + ERROR de
## engine) y dejaba `_anim` en null -> `_process()` salia por el guard y el
## jugador NO animaba nada en runtime (BUG-151, fix 2026-10-29).
## Se usa la ruta de nodo (no el identificador del autoload) para que el script
## siga compilando con --check-only en CI (M118): el compilador headless no
## resuelve autoloads sin el class cache del editor.
var _anim: Node = null


func _ready() -> void:
	# Autoload del servicio de animacion (M48): se resuelve por ruta de nodo.
	_anim = get_node_or_null("/root/AnimationService")
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
