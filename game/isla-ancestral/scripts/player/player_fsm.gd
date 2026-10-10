class_name PlayerFSM
extends RefCounted

## M11 - FSM de estados del Personaje del Jugador (MODELO PURO).
##
## Implementa el diseno de `03-Diseno.md` seccion 2 (FSM por estados) y los
## items C.49-C.64 de `05-Checklist.md` como logica pura y testeable:
##   - 11 estados con nombre estable (los 10 clips + SURFACE de la seccion 2).
##   - Tabla de PERMISOS por estado (movimiento / salto / interaccion / sprint).
##   - Tabla de TRANSICIONES con validacion: `transicionar()` RECHAZA una
##     transicion que no este declarada -> no hay "estados imposibles" (C.64).
##   - `derivar(snapshot)` calcula el estado a partir de un snapshot de runtime
##     (en_suelo, velocidad_y, en_agua, aire_restante, ...). El snapshot lo
##     provee quien observe al jugador; esta clase NO toca la escena.
##
## Alcance honesto: este es el MODELO + el contrato publicable. NO esta cableado
## a `player.gd` (el nucleo de movimiento funciona y su archivo estaba siendo
## editado por otro modulo al momento de esta iteracion: ver 04-Codigo.md 9).
## Consumidores previstos: M12 (camara), M13, M14, M53 (HUD).
##
## Convencion del repo: sin BOM, LF. Sin `class_name` nuevo? -> hay que
## regenerar la cache con `godot --headless --path game/isla-ancestral --import`
## antes de correr una suite que lo use (trampa 123).

enum Estado {
	IDLE,
	WALK,
	RUN,
	JUMP,
	FALL,
	SWIM,
	DIVE,
	SURFACE,
	INTERACT,
	SLEEP,
	CRAFT,
}

## Nombre legible de cada estado (estable para HUD/telemetria).
const NOMBRES: Dictionary = {
	Estado.IDLE: "IDLE",
	Estado.WALK: "WALK",
	Estado.RUN: "RUN",
	Estado.JUMP: "JUMP",
	Estado.FALL: "FALL",
	Estado.SWIM: "SWIM",
	Estado.DIVE: "DIVE",
	Estado.SURFACE: "SURFACE",
	Estado.INTERACT: "INTERACT",
	Estado.SLEEP: "SLEEP",
	Estado.CRAFT: "CRAFT",
}

## Umbral de aire (fraccion de 1.0) por debajo del cual DIVE flota a SURFACE
## (cozy: nunca fatal; 03-Diseno seccion 2 "DIVE -> SURFACE al 20%").
const AIRE_UMBRAL_SURFACE := 0.20

## Magnitud minima de direccion para considerar que el jugador se mueve.
const DIRECCION_MINIMA := 0.1

## Permisos por estado: mov (desplazarse), saltar, interactuar, correr.
const PERMISOS: Dictionary = {
	Estado.IDLE: {"mov": true, "saltar": true, "interactuar": true, "correr": true},
	Estado.WALK: {"mov": true, "saltar": true, "interactuar": true, "correr": true},
	Estado.RUN: {"mov": true, "saltar": true, "interactuar": true, "correr": true},
	Estado.JUMP: {"mov": true, "saltar": false, "interactuar": true, "correr": false},
	Estado.FALL: {"mov": true, "saltar": false, "interactuar": true, "correr": false},
	Estado.SWIM: {"mov": true, "saltar": true, "interactuar": false, "correr": false},
	Estado.DIVE: {"mov": true, "saltar": false, "interactuar": false, "correr": false},
	Estado.SURFACE: {"mov": true, "saltar": false, "interactuar": false, "correr": false},
	Estado.INTERACT: {"mov": false, "saltar": false, "interactuar": false, "correr": false},
	Estado.SLEEP: {"mov": false, "saltar": false, "interactuar": false, "correr": false},
	Estado.CRAFT: {"mov": false, "saltar": false, "interactuar": false, "correr": false},
}

## Transiciones declaradas (dirigidas). Todo destino debe existir en NOMBRES.
const TRANSICIONES: Dictionary = {
	Estado.IDLE: [Estado.WALK, Estado.RUN, Estado.JUMP, Estado.SWIM, Estado.INTERACT, Estado.SLEEP, Estado.CRAFT],
	Estado.WALK: [Estado.IDLE, Estado.RUN, Estado.JUMP, Estado.SWIM, Estado.INTERACT, Estado.SLEEP, Estado.CRAFT],
	Estado.RUN: [Estado.IDLE, Estado.WALK, Estado.JUMP, Estado.SWIM, Estado.INTERACT, Estado.SLEEP, Estado.CRAFT],
	Estado.JUMP: [Estado.FALL, Estado.IDLE, Estado.WALK, Estado.SWIM, Estado.INTERACT],
	Estado.FALL: [Estado.IDLE, Estado.WALK, Estado.RUN, Estado.SWIM, Estado.INTERACT],
	Estado.SWIM: [Estado.WALK, Estado.IDLE, Estado.DIVE, Estado.SURFACE, Estado.INTERACT],
	Estado.DIVE: [Estado.SURFACE, Estado.SWIM],
	Estado.SURFACE: [Estado.SWIM, Estado.WALK, Estado.DIVE],
	Estado.INTERACT: [Estado.IDLE, Estado.WALK, Estado.RUN, Estado.JUMP, Estado.SWIM],
	Estado.SLEEP: [Estado.IDLE, Estado.WALK],
	Estado.CRAFT: [Estado.IDLE, Estado.WALK],
}

var _estado: int = Estado.IDLE

func estado_actual() -> int:
	return _estado

func nombre_actual() -> String:
	return str(NOMBRES.get(_estado, "?"))

## Devuelve true si la transicion `destino` esta declarada desde el estado actual.
func puede_transicionar(destino: int) -> bool:
	if not NOMBRES.has(destino):
		return false
	var destinos: Array = TRANSICIONES.get(_estado, [])
	return destinos.has(destino)

## Aplica una transicion. Devuelve false (y NO cambia de estado) si es invalida:
## asi el modelo no puede entrar en un estado imposible (C.64).
func transicionar(destino: int) -> bool:
	if not puede_transicionar(destino):
		return false
	_estado = destino
	return true

## Permiso de una accion ("mov" | "saltar" | "interactuar" | "correr") en el
## estado actual. Una accion desconocida devuelve false (falla cerrado).
func permite(accion: String) -> bool:
	var tabla: Dictionary = PERMISOS.get(_estado, {})
	return bool(tabla.get(accion, false))

## Deriva el estado a partir de un snapshot de runtime. Claves (todas opcionales):
##   durmiendo:bool  crafteando:bool  interactuando:bool  en_agua:bool
##   sumergido:bool  aire_restante:float(0..1)  en_suelo:bool
##   velocidad_y:float  magnitud_direccion:float  correr:bool
## Prioridad: dormir/craft/interact > agua (aire) > aire (jump/fall) > suelo.
func derivar(snapshot: Dictionary) -> int:
	if bool(snapshot.get("durmiendo", false)):
		return Estado.SLEEP
	if bool(snapshot.get("crafteando", false)):
		return Estado.CRAFT
	if bool(snapshot.get("interactuando", false)):
		return Estado.INTERACT

	if bool(snapshot.get("en_agua", false)):
		var aire: float = float(snapshot.get("aire_restante", 1.0))
		if aire <= AIRE_UMBRAL_SURFACE:
			return Estado.SURFACE
		if bool(snapshot.get("sumergido", false)):
			return Estado.DIVE
		return Estado.SWIM

	if not bool(snapshot.get("en_suelo", true)):
		var vy: float = float(snapshot.get("velocidad_y", 0.0))
		return Estado.JUMP if vy > 0.0 else Estado.FALL

	var magnitud: float = float(snapshot.get("magnitud_direccion", 0.0))
	if magnitud >= DIRECCION_MINIMA:
		return Estado.RUN if bool(snapshot.get("correr", false)) else Estado.WALK
	return Estado.IDLE

## Deriva y aplica el estado OBSERVADO. La derivacion es autoritativa (es el
## estado fisico real que reporta el runtime), y `derivar()` solo devuelve
## estados declarados, asi que el modelo no puede quedar en uno inexistente.
## `transicionar()` sigue siendo el camino validado para cambios EXPLICITOS
## (INTERACT/SLEEP/CRAFT y cualquier transicion scripted): ahi si se rechaza
## una transicion no declarada.
func actualizar_desde(snapshot: Dictionary) -> int:
	_estado = derivar(snapshot)
	return _estado

## Autochequeo del grafo: destinos declarados que no existen como estado.
## Debe devolver [] (lo afirma la suite).
func destinos_invalidos() -> Array:
	var malos: Array = []
	for origen in TRANSICIONES.keys():
		if not NOMBRES.has(origen):
			malos.append(origen)
			continue
		for destino in TRANSICIONES[origen]:
			if not NOMBRES.has(destino):
				malos.append(destino)
	return malos

## Estados declarados sin permisos o sin transiciones (cobertura completa).
func estados_incompletos() -> Array:
	var faltan: Array = []
	for e in NOMBRES.keys():
		if not PERMISOS.has(e) or not TRANSICIONES.has(e):
			faltan.append(e)
	return faltan

func cantidad_estados() -> int:
	return NOMBRES.size()
