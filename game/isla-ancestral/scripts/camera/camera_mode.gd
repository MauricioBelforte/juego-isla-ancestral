## camera_mode.gd — Enum de modos de cámara y state machine
## Módulo 12: Cámara — Estilo Animal Crossing
class_name CameraMode
extends RefCounted

## Modos de cámara disponibles
enum ModoCamara {
	EXPLORE,    ## Juego normal — vista cenital ángulo fijo ~50°
	BUILD,      ## Modo construir (M17) — aérea 45°, distancia 12 m
	DIALOG,     ## Diálogos/NPC (M21) — encuadre de escena fijo
	CUTSCENE,   ## Eventos de historia (M22/M26) — planos fijos con fade
	MINIMAP     ## Vista de supervisor — textura top-down 2D (no render)
}

## Distancias de zoom por modo (en metros)
const ZOOM_LEVELS := {
	ModoCamara.EXPLORE: [3.0, 5.0, 8.0],   ## Close, Standard, Far
	ModoCamara.BUILD: [12.0],                ## Solo distancia aérea
	ModoCamara.DIALOG: [4.0],                ## Distancia fija para diálogos
	ModoCamara.CUTSCENE: [6.0],              ## Distancia estándar de cutscene
	ModoCamara.MINIMAP: [50.0]               ## Vista top-down lejana
}

## Ángulos de pitch por modo (en grados desde horizontal)
## Estilo Animal Crossing: ~50° = vista cenital con ángulo
const PITCH_ANGLES := {
	ModoCamara.EXPLORE: 50.0,     ## ~50° — vista Animal Crossing
	ModoCamara.BUILD: 45.0,       ## 45° aérea para construcción
	ModoCamara.DIALOG: 40.0,      ## 40° ligeramente más bajo para ver caras
	ModoCamara.CUTSCENE: 45.0,    ## 45° para planos cinematográficos
	ModoCamara.MINIMAP: 90.0      ## 90° = vista top-down pura
}

## Separación mínima de la cámara al colisionar (metros)
const MIN_COLLISION_DISTANCE := 0.8

## Velocidad de retorno tras colisión (lerp)
const COLLISION_RETURN_SPEED := 6.67  ## 1.0 / 0.15 s

## Distancia máxima en interiores (metros)
const MAX_INTERIOR_DISTANCE := 2.2

## Distancia de zoom durante uso de herramienta (metros)
const TOOL_AIM_DISTANCE := 3.5

## Tiempo de transición de zoom (segundos)
const ZOOM_TRANSITION_TIME := 0.3

## Intensidad máxima del shake (metros)
const SHAKE_AMPLITUDE_MAX := 0.15

## Duración máxima del shake (segundos)
const SHAKE_DURATION_MAX := 0.5

## Devuelve la distancia de zoom para un modo dado y nivel de zoom (función estática)
static func get_zoom_distance(modo: ModoCamara, zoom_level: int = 1) -> float:
	var levels: Array = ZOOM_LEVELS.get(modo, [5.0])
	zoom_level = clampi(zoom_level, 0, levels.size() - 1)
	return levels[zoom_level]

## Devuelve el ángulo de pitch para un modo dado (función estática)
static func get_pitch_angle(modo: ModoCamara) -> float:
	return PITCH_ANGLES.get(modo, 50.0)

## Verifica si un modo permite input del jugador (función estática)
static func allows_player_input(modo: ModoCamara) -> bool:
	return modo in [ModoCamara.EXPLORE, ModoCamara.BUILD]

## Verifica si un modo debe esconder el HUD (función estática)
static func hides_hud(modo: ModoCamara) -> bool:
	return modo in [ModoCamara.DIALOG, ModoCamara.CUTSCENE]
