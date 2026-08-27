# Modelo: ox-alpha (Cline)
# Plataforma: Cline
# Fecha: 2026-08-25
#
# M66: Anti-Softlock — SoftlockRules (config)
# Configuración central de tiempos, radios y slots del detector anti-atasco.

## Singleton de configuración (autoload opcional, también usable como Resource)
class_name SoftlockRules
extends Node

## === Tiempos ===
## Tick real del detector de invariantes (segundos)
const DETECTOR_TICK_SEGUNDOS: float = 60.0

## Tiempo máximo para que una recuperación se complete tras detectar (segundos)
const MAX_RECUPERACION_SEGUNDOS: float = 15.0

## Ventana de detección de "3 recuperaciones de la misma instancia" (segundos)
const VENTANA_MULTIPLES_FALLOS: float = 600.0  # 10 minutos

## Threshold de reaparición para vehículos fuera del mundo
const TIEMPO_REAPARICION_VEHICULO: float = 30.0

## Timeout del watchdog anti-atasco de NPC (M64).
## 2 s para re-path, 6 s para teleport discreto al hogar.
const NPC_REPATH_SEGUNDOS: float = 2.0
const NPC_TELEPORT_HOGAR_SEGUNDOS: float = 6.0

## === Radios ===
## Radio máximo de teleport del jugador al cofre de recuperación (metros)
const RADIO_TELEPORT_JUGADOR: float = 3.0

## Radio de detección de objetos fuera del mundo / inaccesibles
const RADIO_DETECCION_OBJETO: float = 2.0

## === Checkpoints ===
## Número máximo de slots de backup por bioma (rotativo)
const SLOTS_POR_BIOMA: int = 3

## Slot global de emergencia (además de los por bioma)
const SLOT_EMERGENCIA: bool = true

## Número máximo de escrituras a disco por evento de checkpoint
const MAX_ESCRITURAS_POR_EVENTO: int = 4

## === Cofre de recuperación ===
## Número máximo de objetos en el cofre de recuperación por zona
const SLOTS_COFRE_RECUPERACION: int = 12

## === Flags ===
## Si el detector de invariantes está activo en builds de release
const DETECTOR_ACTIVO_EN_RELEASE: bool = true

## Si el toast de recuperación es visible al jugador (cosy: nunca spam)
const TOAST_ACTIVO: bool = true

## Tiempo mínimo entre toasts del mismo tipo (cooldown, segundos)
const TOAST_COOLDOWN: float = 30.0

## Devuelve la configuración como dictionary (para serializar en save)
func to_dict() -> Dictionary:
	return {
		"detector_tick": DETECTOR_TICK_SEGUNDOS,
		"max_recuperacion": MAX_RECUPERACION_SEGUNDOS,
		"slots_bioma": SLOTS_POR_BIOMA,
		"toast_activo": TOAST_ACTIVO,
	}
