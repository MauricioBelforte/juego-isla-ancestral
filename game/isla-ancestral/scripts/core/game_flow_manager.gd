# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-31
#
# M40: GameFlowManager — máquina de estados del flujo del juego.
# Según 03-Diseno §1.1/§3: BOOT → MENU → CARGANDO → MUNDO → PAUSA → ERROR.
# Solo orquesta ESTADOS y valida transiciones; la carga de escenas la hace
# SceneManager (M63 pendiente) y los servicios de dominio no lo conocen.
# ⚠️ Sin class_name: es autoload (pitfall 07-GUIA-GODOT §9.17/§9.41).

extends Node

enum Estado { BOOT, MENU, CARGANDO, MUNDO, PAUSA, ERROR }

## Transiciones válidas: {desde: [hacia...]}
## Nota: BOOT->MUNDO directo es la ruta del prototipo (sin menú aún, M89/M63
## completarán BOOT->MENU->CARGANDO->MUNDO cuando exista el flujo completo).
const TRANSICIONES := {
	Estado.BOOT: [Estado.MENU, Estado.CARGANDO, Estado.MUNDO, Estado.ERROR],
	Estado.MENU: [Estado.CARGANDO, Estado.ERROR],
	Estado.CARGANDO: [Estado.MUNDO, Estado.MENU, Estado.ERROR],
	Estado.MUNDO: [Estado.PAUSA, Estado.CARGANDO, Estado.MENU, Estado.ERROR],
	Estado.PAUSA: [Estado.MUNDO, Estado.MENU, Estado.ERROR],
	Estado.ERROR: [Estado.BOOT, Estado.MENU],
}

signal estado_cambiado(anterior: int, nuevo: int)

var estado: int = Estado.BOOT

## Cambia de estado validando la transición. Devuelve false si es inválida.
## Desde iter. 2 (Log 323) también reenvía el cambio por EventBus.infra
## (dominio infra de M40) para que la UI/escuchas no dependan de la señal local.
func cambiar_estado(nuevo: int) -> bool:
	if nuevo == estado:
		return true
	var permitidas: Array = TRANSICIONES.get(estado, [])
	if not permitidas.has(nuevo):
		push_warning("[M40] Transición inválida %d -> %d" % [estado, nuevo])
		return false
	var anterior := estado
	estado = nuevo
	estado_cambiado.emit(anterior, nuevo)
	_emitir_por_event_bus(anterior, nuevo)
	print("[M40] Flujo: %d -> %d" % [anterior, nuevo])
	return true

func get_estado() -> int:
	return estado

func es_estado(nuevo: int) -> bool:
	return estado == nuevo

## ¿El juego está en mundo jugable (o pausado sobre él)?
func en_juego() -> bool:
	return estado == Estado.MUNDO or estado == Estado.PAUSA

## Devuelve las transiciones permitidas desde el estado actual (copia).
## Para la UI de pausa/menú (ítem L de 05-Checklist M40).
func transiciones_permitidas() -> Array:
	var desde: Array = TRANSICIONES.get(estado, [])
	return desde.duplicate()

## Reenvía el cambio de estado por EventBus.infra (dominio infra M40).
## Sin class_name: accede por get_node_or_null (pitfall §9.17/§9.51).
func _emitir_por_event_bus(anterior: int, nuevo: int) -> void:
	var bus := get_node_or_null("/root/EventBus")
	if bus == null:
		return
	var infra: Variant = bus.get("infra")
	if infra == null or not (infra is Object) or not infra.has_signal("game_flow_changed"):
		return
	infra.game_flow_changed.emit(anterior, nuevo)