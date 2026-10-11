# M11 - CABLEADO del nucleo aditivo (FSM + energia + seleccion) al nodo del jugador.
#
# Este nodo vive como HIJO de `Player` (CharacterBody3D) en `Player.tscn` y es
# ADITIVO: NO modifica `player.gd`. Cada frame de fisica:
#   1. lee un SNAPSHOT del padre por duck-typing (velocity, en_suelo, en_agua),
#   2. deriva el estado con `PlayerFSM.actualizar_desde(snapshot)`,
#   3. actualiza la energia con `PlayerEnergy.actualizar(delta, corriendo, en_mov)`.
# El estado y la energia quedan expuestos para el HUD (M53) y la seleccion de
# personaje para la persistencia (M59).
#
# Se usa `preload()` (no el nombre global de clase) para no depender de la cache
# de clases globales (trampa 123: un `class_name` nuevo no existe para `--script`
# hasta regenerar la cache). El propio adaptador NO declara `class_name`: el
# `.tscn` lo referencia por RUTA, asi no hay dependencia de la cache.
#
# ALCANCE HONESTO (medido, no aspiracional):
#   - La FSM SI esta cableada en vivo: se alimenta de la velocidad real del padre
#     (IDLE/WALK/RUN/JUMP/FALL/SWIM se derivan del runtime).
#   - SPRINT (iter. 2026-10-10, autorizado por el director, mensaje 141): el
#     adaptador LEE LShift (o la accion `correr` si existiera en el InputMap) y,
#     cuando el jugador se mueve EN SUELO con permiso de la FSM y energia
#     disponible, entra en RUN y EJERCE el costo de correr (1/min). Aplica la
#     velocidad de correr del diseno (6.5 m/s) ESCALANDO `move_speed` del padre
#     por FACTOR_SPRINT (duck-typing) y la RESTAURA al soltar. NO edita
#     `player.gd` ni su API publica: usa el @export existente como palanca.
#   - L70 (cozy: la energia NUNCA llega a cero por correr) queda ESTRUCTURAL:
#     costo 1/min + regen 1/min = balance NETO 0/min -> correr no baja la energia
#     (el gasto real solo viene de herramientas, M13, via `consumir_energia()`).
#   - El nodo OBSERVA al jugador; el UNICO campo que escribe es `move_speed` del
#     padre (para el sprint), y lo restaura al soltar. Sin autoloads.
#
# Convencion del repo: sin BOM, LF.

extends Node

const FSM := preload("res://scripts/player/player_fsm.gd")
const ENERGY := preload("res://scripts/player/player_energy.gd")
const SELECTOR := preload("res://scripts/player/character_selector.gd")

## Magnitud minima de velocidad horizontal para considerar desplazamiento.
## Alineado con `PlayerFSM.DIRECCION_MINIMA`.
const VELOCIDAD_MINIMA := 0.1

## Velocidad de diseno del personaje (`03-Diseno.md` seccion 1): caminar 4.2 m/s,
## correr 6.5 m/s (`05-Checklist` L35/L36). El runtime usa `move_speed` como base
## (hoy 25.0 en modo DEV), asi que el sprint se aplica como FACTOR proporcional
## (6.5/4.2), NO como valor absoluto: asi respeta el multiplicador por terreno y
## equipo que `player.gd` ya aplica en `_current_effective_speed`.
const VELOCIDAD_CAMINAR := 4.2
const VELOCIDAD_CORRER := 6.5
const FACTOR_SPRINT := VELOCIDAD_CORRER / VELOCIDAD_CAMINAR

## Entrada del sprint: accion `correr` del InputMap si existe; si no, LShift
## directo (convencion del proyecto: `player.gd` sondea teclas directas).
const ACCION_CORRER := "correr"
const TECLA_SPRINT := KEY_SHIFT

var fsm: RefCounted = null
var energia: RefCounted = null
var selector: RefCounted = null

## Hook de sprint explicito (`marcar_corriendo`): se OR-ea con el input real.
var _corriendo: bool = false
## Estado de sprint EFECTIVO del ultimo tic (todos los gates pasados).
var _corriendo_efectivo: bool = false
var _frames: int = 0
## -1 = leer input real; 0/1 = forzado por la suite (headless no tiene teclado).
var _sprint_test: int = -1
## Base de `move_speed` del padre, capturada la 1a vez (para restaurarla al soltar).
var _base_move_speed: float = -1.0

func _ready() -> void:
	fsm = FSM.new()
	energia = ENERGY.new()
	selector = SELECTOR.new()
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	actualizar(delta)

## Un tic del cableado: deriva el estado del padre, actualiza la energia y aplica
## la velocidad de sprint. Publico para poder ejercitarlo desde una suite headless
## (sin depender del bucle de fisica del motor).
func actualizar(delta: float) -> void:
	_frames += 1
	var snap: Dictionary = leer_snapshot()
	var en_mov: bool = float(snap.get("magnitud_direccion", 0.0)) >= VELOCIDAD_MINIMA
	# Quiere correr: hook explicito (`marcar_corriendo`) O input (LShift/accion).
	var quiere_correr: bool = _corriendo or leer_sprint()
	snap["correr"] = quiere_correr
	if fsm != null:
		fsm.actualizar_desde(snap)
	# Gate del sprint: moviendose + permiso del estado (no en JUMP/SWIM/...) +
	# energia disponible. Correr parado o en el aire no cuenta.
	var corriendo: bool = quiere_correr and en_mov
	if fsm != null:
		corriendo = corriendo and bool(fsm.permite("correr"))
	if energia != null:
		corriendo = corriendo and bool(energia.puede_correr())
		energia.actualizar(delta, corriendo, en_mov)
	_corriendo_efectivo = corriendo
	_aplicar_velocidad_sprint(corriendo)

## ── Sprint (input + velocidad) ─────────────────────────────────────────

## True si el sprint esta pedido por el input (LShift, o la accion `correr` si
## existiera en el InputMap). En la suite headless se fuerza con
## `forzar_sprint_test()` porque no hay teclado.
func leer_sprint() -> bool:
	if _sprint_test >= 0:
		return _sprint_test == 1
	if InputMap.has_action(ACCION_CORRER):
		return Input.is_action_pressed(ACCION_CORRER)
	return Input.is_key_pressed(TECLA_SPRINT)

## Hook de test: fuerza el input de sprint (-1 = volver al input real).
func forzar_sprint_test(valor: int) -> void:
	_sprint_test = valor

## True si el ultimo tic corrio de verdad (todos los gates pasados).
func corriendo() -> bool:
	return _corriendo_efectivo

## Factor de velocidad efectivo (1.0 caminando, FACTOR_SPRINT corriendo).
func factor_velocidad() -> float:
	return FACTOR_SPRINT if _corriendo_efectivo else 1.0

## Velocidad objetivo de correr segun el diseno (`03-Diseno.md` seccion 1).
func velocidad_sprint() -> float:
	return VELOCIDAD_CORRER

## Base de `move_speed` del padre capturada para el sprint (-1 = aun no leida).
func base_move_speed() -> float:
	return _base_move_speed

## Aplica la velocidad de sprint ESCALANDO `move_speed` del padre (duck-typing).
## Captura la base la 1a vez y la RESTAURA al soltar: el adaptador no deja el
## `move_speed` del jugador modificado. Si el padre no expone `move_speed`
## (p.ej. un Node3D), no hace nada.
func _aplicar_velocidad_sprint(corriendo: bool) -> void:
	var p: Node = get_parent()
	if p == null or not ("move_speed" in p):
		return
	var actual: float = float(p.get("move_speed"))
	if _base_move_speed < 0.0:
		_base_move_speed = actual
	var objetivo: float = _base_move_speed * (FACTOR_SPRINT if corriendo else 1.0)
	if absf(actual - objetivo) > 0.0001:
		p.set("move_speed", objetivo)


## ── Lectura del runtime (duck-typing sobre el padre) ────────────────────

## Construye el snapshot que consume `PlayerFSM.derivar()`. Sin padre (nodo
## suelto) devuelve defaults coherentes: en_suelo=true, sin movimiento.
func leer_snapshot() -> Dictionary:
	var snap: Dictionary = {
		"en_suelo": true,
		"velocidad_y": 0.0,
		"magnitud_direccion": 0.0,
		"en_agua": false,
		"sumergido": false,
		"aire_restante": 1.0,
		"correr": _corriendo,
	}
	var p: Node = get_parent()
	if p == null:
		return snap
	var vel: Vector3 = Vector3.ZERO
	var v: Variant = p.get("velocity")
	if v is Vector3:
		vel = v
	snap["velocidad_y"] = vel.y
	snap["magnitud_direccion"] = Vector2(vel.x, vel.z).length()
	snap["en_suelo"] = _leer_en_suelo(p)
	snap["en_agua"] = _leer_en_agua(p)
	return snap

## `_on_ground` (var de player.gd) si existe; si no, `is_on_floor()`.
func _leer_en_suelo(p: Node) -> bool:
	var v: Variant = p.get("_on_ground")
	if v != null:
		return bool(v)
	if p is CharacterBody3D:
		return (p as CharacterBody3D).is_on_floor()
	return true

## `_en_agua()` (metodo de player.gd) si existe; si no, false.
func _leer_en_agua(p: Node) -> bool:
	if p.has_method("_en_agua"):
		return bool(p.call("_en_agua"))
	return false

## ── Contrato para HUD (M53) ────────────────────────────────────────────

func estado_actual() -> int:
	if fsm == null:
		return -1
	return int(fsm.estado_actual())

func nombre_estado() -> String:
	if fsm == null:
		return "?"
	return str(fsm.nombre_actual())

func energia_actual() -> float:
	if energia == null:
		return -1.0
	return float(energia.energia())

func fraccion_energia() -> float:
	if energia == null:
		return -1.0
	return float(energia.fraccion())

func en_fatiga() -> bool:
	if energia == null:
		return false
	return bool(energia.en_fatiga())

func agotada() -> bool:
	if energia == null:
		return false
	return bool(energia.agotada())

func descansando() -> bool:
	if energia == null:
		return false
	return bool(energia.descansando())

func puede_correr() -> bool:
	if energia == null:
		return false
	return bool(energia.puede_correr())

func frames() -> int:
	return _frames

## ── Hooks de escritura (sprint M11 / herramientas M13) ──────────────────

## Fuerza el sprint sin depender del input (hook para el HUD/telemetria y para
## la suite headless). Se OR-ea con `leer_sprint()`; con `false` NO cancela el
## input real (LShift). El sprint EFECTIVO siempre pasa por el gate del tic.
func marcar_corriendo(v: bool) -> void:
	_corriendo = v

## Desgaste externo de energia (uso de herramientas, M13). Clampeado por el
## modelo (nunca negativo; a 0 -> auto-descanso cozy).
func consumir_energia(costo: float) -> void:
	if energia == null:
		return
	energia.restaurar(float(energia.energia()) - maxf(costo, 0.0))

func recargar_dormir() -> void:
	if energia != null:
		energia.recargar_dormir()

func recargar_descanso() -> void:
	if energia != null:
		energia.recargar_descanso()

## ── Persistencia de la seleccion (M59) ─────────────────────────────────

func personaje_actual() -> String:
	if selector == null:
		return ""
	return str(selector.personaje_actual())

func seleccionar_personaje(id: String) -> bool:
	if selector == null:
		return false
	return bool(selector.seleccionar(id))

func serializar_personaje() -> Dictionary:
	if selector == null:
		return {}
	return selector.serializar()

func deserializar_personaje(data: Dictionary) -> bool:
	if selector == null:
		return false
	return bool(selector.deserializar(data))
