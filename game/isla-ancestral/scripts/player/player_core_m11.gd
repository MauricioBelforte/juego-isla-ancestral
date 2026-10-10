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
#     (IDLE/WALK/JUMP/FALL/SWIM se derivan del runtime).
#   - El estado RUN y el DRENADO de energia NO se ejercitan hoy porque `player.gd`
#     NO tiene sprint (input `correr`). El adaptador expone `marcar_corriendo()`
#     como HOOK: el dia que aterrice el sprint (M11) o el desgaste por
#     herramientas (M13), lo llaman y el cable queda completo. NO se invento un
#     sprint aca (decision del director: coordinar los hooks, no reconstruirlos).
#   - El nodo NO escribe en el jugador: solo OBSERVA. Sin autoloads.
#
# Convencion del repo: sin BOM, LF.

extends Node

const FSM := preload("res://scripts/player/player_fsm.gd")
const ENERGY := preload("res://scripts/player/player_energy.gd")
const SELECTOR := preload("res://scripts/player/character_selector.gd")

## Magnitud minima de velocidad horizontal para considerar desplazamiento.
## Alineado con `PlayerFSM.DIRECCION_MINIMA`.
const VELOCIDAD_MINIMA := 0.1

var fsm: RefCounted = null
var energia: RefCounted = null
var selector: RefCounted = null

var _corriendo: bool = false
var _frames: int = 0

func _ready() -> void:
	fsm = FSM.new()
	energia = ENERGY.new()
	selector = SELECTOR.new()
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	actualizar(delta)

## Un tic del cableado: deriva el estado del padre y actualiza la energia.
## Publico para poder ejercitarlo desde una suite headless (sin depender del
## bucle de fisica del motor).
func actualizar(delta: float) -> void:
	_frames += 1
	var snap: Dictionary = leer_snapshot()
	if fsm != null:
		fsm.actualizar_desde(snap)
	var en_mov: bool = float(snap.get("magnitud_direccion", 0.0)) >= VELOCIDAD_MINIMA
	# Solo se "corre" si el estado actual lo permite (p.ej. no en JUMP/SWIM).
	var corriendo := _corriendo
	if fsm != null:
		corriendo = _corriendo and bool(fsm.permite("correr"))
	if energia != null:
		energia.actualizar(delta, corriendo, en_mov)

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

## Marca si el jugador esta corriendo este frame. Lo llamara el sprint cuando
## exista; hoy nadie lo llama (player.gd no tiene sprint), asi que la FSM nunca
## entra en RUN y la energia no drena. Hook listo, NO inventado.
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
