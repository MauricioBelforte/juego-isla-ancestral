# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-04
#
# M68 iter. 3 — TransportRouteWaypoints: waypoints AUTOMÁTICOS de ruta (RF5, sección J).
#
# Un "waypoint automático" es un punto de seguimiento que el viaje usa para no
# perder al jugador en rutas LARGAS (2+ saltos): cada parada intermedia del
# camino. NO se persisten (se derivan del plan); el jugador marca waypoints
# MANUALES (`TransportManager._waypoints`, persistidos por M59) — son cosas
# distintas y este archivo cubre sólo los automáticos.
#
# Modelo PURO y estático: recibe el plan (o el camino de paradas) y la red, y
# devuelve los puntos. No toca nodos ni autoloads, así que se testea headless y
# el TripService (cuando exista escena) sólo dibuja/consume.

class_name TransportRouteWaypoints
extends RefCounted

## Radio XZ (m) con el que el viaje considera "llegado" a un waypoint.
const RADIO_LLEGADA := 6.0
## Saltos a partir de los cuales una ruta es "larga" (usa waypoints de seguimiento).
const MIN_SALTOS_LARGA := 2


## Distancia en el plano XZ (el mundo voxel tiene Z arriba: XZ es el suelo).
static func distancia_xz(a: Vector3, b: Vector3) -> float:
	return Vector2(b.x - a.x, b.z - a.z).length()


## Waypoints ordenados del camino `paradas` (Array de ids, como lo devuelve
## `TransportNetwork.ruta_mas_barata()["paradas"]`). Las paradas que no resuelven
## en la red se OMITEN; si ninguna resuelve, devuelve []. Cada waypoint:
##   {indice, stop_id, pos, fraccion (0..1), es_destino, tramo_m, acumulado_m}
static func de_camino(paradas: Array, red: TransportNetwork) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if red == null or paradas.is_empty():
		return out
	var ids: Array[String] = []
	var puntos: Array[Vector3] = []
	for p in paradas:
		var s: TransportStop = red.stop(StringName(String(p)))
		if s == null:
			continue
		ids.append(String(s.id))
		puntos.append(s.pos)
	if puntos.is_empty():
		return out
	var total: float = 0.0
	var tramos: Array[float] = []
	for i in range(1, puntos.size()):
		var d: float = distancia_xz(puntos[i - 1], puntos[i])
		tramos.append(d)
		total += d
	var acum: float = 0.0
	for i in puntos.size():
		var tramo: float = 0.0
		if i > 0:
			tramo = tramos[i - 1]
			acum += tramo
		var frac: float = 0.0
		if total > 0.0:
			frac = clampf(acum / total, 0.0, 1.0)
		out.append({
			"indice": i,
			"stop_id": ids[i],
			"pos": puntos[i],
			"fraccion": snappedf(frac, 0.0001),
			"es_destino": i == puntos.size() - 1,
			"tramo_m": snappedf(tramo, 0.01),
			"acumulado_m": snappedf(acum, 0.01),
		})
	return out


## Waypoints de un PLAN de `TransportTripPlanner` (o del dict de
## `TransportNetwork.ruta_mas_barata`). Devuelve:
##   {ok, motivo, waypoints, distancia_total_m, saltos, es_larga, radio_llegada}
static func de_plan(plan: Dictionary, red: TransportNetwork) -> Dictionary:
	if not bool(plan.get("ok", false)):
		return {
			"ok": false,
			"motivo": String(plan.get("motivo", "plan no válido")),
			"waypoints": [], "distancia_total_m": 0.0, "saltos": 0,
			"es_larga": false, "radio_llegada": RADIO_LLEGADA,
		}
	var wps: Array[Dictionary] = de_camino(plan.get("paradas", []), red)
	if wps.is_empty():
		return {
			"ok": false, "motivo": "sin waypoints resolubles",
			"waypoints": [], "distancia_total_m": 0.0, "saltos": 0,
			"es_larga": false, "radio_llegada": RADIO_LLEGADA,
		}
	var total: float = float(wps[wps.size() - 1].get("acumulado_m", 0.0))
	var saltos: int = int(plan.get("saltos", 0))
	return {
		"ok": true, "motivo": "",
		"waypoints": wps,
		"distancia_total_m": snappedf(total, 0.01),
		"saltos": saltos,
		"es_larga": saltos >= MIN_SALTOS_LARGA,
		"radio_llegada": RADIO_LLEGADA,
	}


## ¿El plan es una ruta "larga" (2+ saltos)?
static func plan_es_largo(plan: Dictionary) -> bool:
	return int(plan.get("saltos", 0)) >= MIN_SALTOS_LARGA


## Valida una lista de waypoints: orden, monotonía de fracción y acumulado, y
## que el primero sea 0.0 y el último el destino (fracción 1.0). Devuelve
## Array[String] de errores; vacío = válida.
static func validar(waypoints: Array) -> Array[String]:
	var errores: Array[String] = []
	if waypoints.is_empty():
		errores.append("sin waypoints")
		return errores
	var prev_frac: float = -1.0
	var prev_acum: float = -1.0
	for i in waypoints.size():
		var w: Dictionary = waypoints[i]
		if int(w.get("indice", -1)) != i:
			errores.append("waypoint %d con índice inconsistente" % i)
		if String(w.get("stop_id", "")).is_empty():
			errores.append("waypoint %d sin stop_id" % i)
		var f: float = float(w.get("fraccion", -1.0))
		if f < 0.0 or f > 1.0:
			errores.append("waypoint %d: fracción fuera de [0,1]" % i)
		if f < prev_frac:
			errores.append("waypoint %d: fracción no monótona" % i)
		prev_frac = f
		var a: float = float(w.get("acumulado_m", -1.0))
		if a < prev_acum:
			errores.append("waypoint %d: acumulado no monótono" % i)
		prev_acum = a
	var primero: Dictionary = waypoints[0]
	var ultimo: Dictionary = waypoints[waypoints.size() - 1]
	# Camino degenerado (origen == destino): un solo waypoint que es a la vez
	# origen y destino. No se le exige fracción 1.0 (el viaje no recorrió nada).
	if waypoints.size() > 1:
		if not is_equal_approx(float(primero.get("fraccion", -1.0)), 0.0):
			errores.append("el primer waypoint no tiene fracción 0.0")
		if not bool(ultimo.get("es_destino", false)):
			errores.append("el último waypoint no es el destino")
		if not is_equal_approx(float(ultimo.get("fraccion", -1.0)), 1.0):
			errores.append("el último waypoint no tiene fracción 1.0")
	return errores


## Resumen legible (para logs y HUD del viaje).
static func resumen(waypoints: Array) -> Dictionary:
	var n: int = waypoints.size()
	if n == 0:
		return {"n": 0, "distancia_total_m": 0.0, "primer": "", "ultimo": ""}
	return {
		"n": n,
		"distancia_total_m": snappedf(float(waypoints[n - 1].get("acumulado_m", 0.0)), 0.01),
		"primer": String(waypoints[0].get("stop_id", "")),
		"ultimo": String(waypoints[n - 1].get("stop_id", "")),
	}


## Índice del waypoint más cercano (XZ) a `punto`; -1 si la lista está vacía.
## Los empates los resuelve el primero (orden estable).
static func indice_mas_cercano(waypoints: Array, punto: Vector3) -> int:
	var mejor: int = -1
	var mejor_d: float = 1.0e20
	for i in waypoints.size():
		var w: Dictionary = waypoints[i]
		var p: Vector3 = w.get("pos", Vector3.ZERO)
		var d: float = distancia_xz(p, punto)
		if d < mejor_d:
			mejor_d = d
			mejor = i
	return mejor


## Fracción de avance (0..1) del `punto` a lo largo de la ruta: la del waypoint
## más cercano. Sirve para que el viaje sepa por dónde va el jugador.
static func avance_en(waypoints: Array, punto: Vector3) -> float:
	var i: int = indice_mas_cercano(waypoints, punto)
	if i < 0:
		return 0.0
	return float(waypoints[i].get("fraccion", 0.0))
