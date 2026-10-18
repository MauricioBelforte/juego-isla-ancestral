class_name TelemetriaM104
extends RefCounted

const EVENTO_VOLVER_A_CASA := "volver_a_casa"
const EVENTO_ACERCARSE_PUERTO := "acercarse_puerto"
const EVENTO_PAUSA_CONTEMPLATIVA := "pausa_contemplativa"

# Instrumenta los 3 eventos de telemetría M104 que M153-Objetivo-Final pide
# (ítems 33, 42 y 178 del checklist de M153, KnownIssue de DoD no bloqueante):
# 
#   * volver_a_casa          → entrar/registrar la parcela del jugador
#   * acercarse_puerto       → proximidad a un nodo de transporte (puerto)
#   * pausa_contemplativa    → pausa libre del jugador (sin objetivo activo)
# 
# Diseño (mismo patrón que el resto del proyecto):
#   * helper PURO y sin dependencias: registra en `/root/AnalyticsDirector` por
#     duck-typing, y si no está (headless, opt-out, tests) no hace nada.
#   * no rompe el flujo del emisor: cualquier excepción se degrada a nada.
#


# -*- coding: utf-8 -*-





static func _director() -> Node:
	if not Engine.has_singleton("AnalyticsDirector"):
		return null
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	var d: Node = tree.root.get_node_or_null("AnalyticsDirector")
	if d != null and not bool(d.call("esta_opt_out")) and d.has_method("registrar_evento"):
		return d
	return null

## Registra un evento M104. Devuelve true si se registró.
static func registrar(tipo: String, datos: Dictionary = {}) -> bool:
	var d := _director()
	if d == null:
		return false
	d.call("registrar_evento", tipo, datos)
	return true

## M153 ítem 33: el jugador vuelvió a su casa.
static func volver_a_casa(casa_id: String, pos: Vector3) -> bool:
	return registrar(EVENTO_VOLVER_A_CASA, {
		"casa_id": str(casa_id),
		"pos": [pos.x, pos.y, pos.z],
	})

## M153 ítem 42: el jugador se acercó a un puerto (nodo de transporte).
static func acercarse_puerto(nodo_id: String, pos: Vector3, distancia: float) -> bool:
	return registrar(EVENTO_ACERCARSE_PUERTO, {
		"nodo_id": str(nodo_id),
		"pos": [pos.x, pos.y, pos.z],
		"distancia": distancia,
	})

## M153 ítem 178: pausa contemplativa (mirar el paisaje, sin objetivo activo).
static func pausa_contemplativa(duracion_segundos: float) -> bool:
	return registrar(EVENTO_PAUSA_CONTEMPLATIVA, {
		"duracion_segundos": duracion_segundos,
	})
