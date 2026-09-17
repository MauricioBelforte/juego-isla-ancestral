# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-15
#
# M68 iter. 2 — Transporte y Navegación: PUENTE CON FAST TRAVEL (sección Q).
#
# Coordina las PARADAS de M68 con las ANCLAS de M69 (`fast_travel_service.gd`,
# datos en `data/fasttravel/anclas.json`). M68 aporta las estaciones; M69 aporta
# el salto. Reglas de la sección Q:
#   1. Compartir estaciones: una parada de M68 y un ancla de M69 en el mismo
#      punto son LA MISMA estación (no dos).
#   2. M69 sólo ofrece destinos cuya estación de M68 esté desbloqueada.
#   3. M69 no duplica costes ni rutas de M68: no redefine la red, la consulta.
#   4. DECISIÓN: el fast travel es MÁS CARO que el boleto de ruta (si no, nadie
#      usaría el transporte normal y el mundo se vaciaría).
#
# ⚠️ HALLAZGO MEDIDO (ver Log 910): con los datos actuales de `anclas.json`
# (x/z 256..320, isla RIZ) y las paradas de M68 (pos ±200, Z arriba) hay
# **0 coincidencias**: M69 y M68 todavía NO comparten ninguna estación. El
# puente lo DETECTA y lo reporta en vez de fingir que comparten.
#
# Puro y sin escena: las anclas entran como `Array[Dictionary]`, así que el
# puente es verificable headless sin instanciar M69.

class_name TransportM69Bridge
extends RefCounted

## Distancia (m, plano XZ) por debajo de la cual un ancla y una parada son la
## misma estación. Voxel 1 m: 12 m es "el mismo muelle".
const RADIO_COINCIDENCIA_M := 12.0

## DECISIÓN: el fast travel cuesta al menos un 60 % más que el boleto de ruta.
const FACTOR_M69 := 1.6
## ...y nunca menos de 10 AO por encima, para que no se note gratis en rutas baratas.
const MARGEN_MIN_M69 := 10

## Prefijo de los ids de ancla que M69 usa para localizaciones del mundo.
const PREFIJO_ANCLA := "ancla_"


## ── Precio (decisión 4) ──────────────────────────────────────────────────

## Precio del fast travel a un destino cuyo boleto de ruta cuesta `precio_boleto`.
## Siempre ESTRICTAMENTE mayor que el boleto.
func precio_m69(precio_boleto: int) -> int:
	var boleto: int = maxi(0, precio_boleto)
	var por_factor: int = int(ceil(float(boleto) * FACTOR_M69))
	return maxi(por_factor, boleto + MARGEN_MIN_M69)


## ¿Se cumple la decisión "M69 más caro que el boleto"?
func es_mas_caro_que_boleto(precio_fast: int, precio_boleto: int) -> bool:
	return precio_fast > precio_boleto


## ── 1. Estaciones compartidas ────────────────────────────────────────────

## Empareja cada ancla de M69 con su parada de M68 (por `stop_id` explícito, por
## `poi_id`, o por proximidad en el plano XZ). Devuelve Array[Dictionary] con
## {ancla_id, stop_id, distancia, via}.
func estaciones_compartidas(red: TransportNetwork, anclas: Array, radio: float = RADIO_COINCIDENCIA_M) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if red == null:
		return out
	for a in anclas:
		if not (a is Dictionary):
			continue
		var ancla: Dictionary = a
		var par: Dictionary = _emparejar(red, ancla, radio)
		if not par.is_empty():
			out.append(par)
	return out


## Anclas de M69 que NO corresponden a ninguna parada de M68 (huérfanas).
## Son destinos que M69 ofrece por su cuenta: hay que decidir si se re-anclan
## a una parada o si se declaran fuera de la red de transporte.
func anclas_huerfanas(red: TransportNetwork, anclas: Array, radio: float = RADIO_COINCIDENCIA_M) -> Array[String]:
	var out: Array[String] = []
	if red == null:
		return out
	for a in anclas:
		if not (a is Dictionary):
			continue
		var ancla: Dictionary = a
		if _emparejar(red, ancla, radio).is_empty():
			out.append(str(ancla.get("id", "")))
	out.sort()
	return out


## ── 2. Sólo destinos con estación desbloqueada ───────────────────────────

## Anclas que M69 puede ofrecer: su estación de M68 existe Y está desbloqueada.
## `desbloqueadas` es la lista de stop_id ya desbloqueados en runtime (M71/M59);
## si se pasa `manager`, se consulta su API en su lugar.
func destinos_disponibles(red: TransportNetwork, anclas: Array, desbloqueadas: Array = [], manager: Object = null, radio: float = RADIO_COINCIDENCIA_M) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if red == null:
		return out
	for a in anclas:
		if not (a is Dictionary):
			continue
		var ancla: Dictionary = a
		var par: Dictionary = _emparejar(red, ancla, radio)
		if par.is_empty():
			continue
		var stop_id: String = str(par.get("stop_id", ""))
		if not _esta_desbloqueada(stop_id, desbloqueadas, manager, red):
			continue
		var copia: Dictionary = ancla.duplicate(true)
		copia["stop_id"] = stop_id
		out.append(copia)
	return out


## ── 3. Sin duplicar costes ni rutas ──────────────────────────────────────

## Problemas de duplicación entre M69 y M68. Lista vacía = correcto.
func detectar_duplicacion(red: TransportNetwork, anclas: Array, radio: float = RADIO_COINCIDENCIA_M) -> Array[String]:
	var errores: Array[String] = []
	if red == null:
		return ["sin red de transporte"]
	var ids_ancla: Array[String] = []
	var stops_usados: Dictionary = {}
	for a in anclas:
		if not (a is Dictionary):
			errores.append("ancla de M69 no es Dictionary")
			continue
		var ancla: Dictionary = a
		var aid: String = str(ancla.get("id", ""))
		if aid.is_empty():
			errores.append("ancla de M69 sin id")
			continue
		if ids_ancla.has(aid):
			errores.append("ancla duplicada en M69: %s" % aid)
		ids_ancla.append(aid)
		# El ancla no puede reusar el id de una parada de M68 (dos verdades).
		if red.stop(StringName(aid)) != null:
			errores.append("el ancla '%s' reusa el id de una parada de M68" % aid)
		# El ancla no puede traer su propia definición de ruta/coste.
		if ancla.has("rutas") or ancla.has("routes"):
			errores.append("el ancla '%s' define rutas propias (M69 no redefine la red)" % aid)
		if ancla.has("precio") or ancla.has("cost"):
			errores.append("el ancla '%s' define coste propio (el coste lo fija M68/M38)" % aid)
		# Dos anclas sobre la misma parada = dos entradas para un mismo destino.
		var par: Dictionary = _emparejar(red, ancla, radio)
		if not par.is_empty():
			var sid: String = str(par.get("stop_id", ""))
			if stops_usados.has(sid):
				errores.append("dos anclas de M69 apuntan a la misma parada '%s': %s y %s" % [
					sid, str(stops_usados[sid]), aid])
			else:
				stops_usados[sid] = aid
	return errores


## ── Validación conjunta ──────────────────────────────────────────────────

## Valida la coordinación completa. `precios_boleto` mapea stop_id -> precio del
## boleto de ruta más barato a esa parada (para comprobar la decisión 4).
func validar(red: TransportNetwork, anclas: Array, precios_boleto: Dictionary = {}, desbloqueadas: Array = [], manager: Object = null) -> Array[String]:
	var errores: Array[String] = detectar_duplicacion(red, anclas)
	# Decisión 4: todo destino compartido con precio conocido debe ser más caro.
	for par in estaciones_compartidas(red, anclas):
		var sid: String = str(par.get("stop_id", ""))
		if not precios_boleto.has(sid):
			continue
		var boleto: int = int(precios_boleto[sid])
		var fast: int = precio_m69(boleto)
		if not es_mas_caro_que_boleto(fast, boleto):
			errores.append("el fast travel a '%s' no es más caro que el boleto (%d <= %d)" % [sid, fast, boleto])
	# Regla 2: M69 no puede ofrecer una estación bloqueada.
	var ofrecidos: Array[Dictionary] = destinos_disponibles(red, anclas, desbloqueadas, manager)
	for o in ofrecidos:
		var sid2: String = str(o.get("stop_id", ""))
		if not _esta_desbloqueada(sid2, desbloqueadas, manager, red):
			errores.append("M69 ofrece la parada bloqueada '%s'" % sid2)
	return errores


## Informe legible de la coordinación (para el log y el validador unificado).
func informe(red: TransportNetwork, anclas: Array, precios_boleto: Dictionary = {}, desbloqueadas: Array = []) -> String:
	var compartidas := estaciones_compartidas(red, anclas)
	var huerfanas := anclas_huerfanas(red, anclas)
	var disponibles := destinos_disponibles(red, anclas, desbloqueadas)
	var lineas: Array[String] = []
	lineas.append("M69/M68: %d anclas, %d compartidas, %d huérfanas, %d ofrecibles" % [
		anclas.size(), compartidas.size(), huerfanas.size(), disponibles.size()])
	if not compartidas.is_empty() and not precios_boleto.is_empty():
		for par in compartidas:
			var sid: String = str(par.get("stop_id", ""))
			var boleto: int = int(precios_boleto.get(sid, 0))
			lineas.append("  %s -> boleto %d AO, fast travel %d AO" % [sid, boleto, precio_m69(boleto)])
	if not huerfanas.is_empty():
		lineas.append("  huérfanas (M69 sin parada M68): %s" % str(huerfanas))
	return "\n".join(lineas)


## ── Helpers ──────────────────────────────────────────────────────────────

func _emparejar(red: TransportNetwork, ancla: Dictionary, radio: float) -> Dictionary:
	# 1) Enlace explícito (M69 declara la parada): es el camino preferido.
	var sid: String = str(ancla.get("stop_id", ""))
	if not sid.is_empty() and red.stop(StringName(sid)) != null:
		return {"ancla_id": str(ancla.get("id", "")), "stop_id": sid, "distancia": 0.0, "via": "stop_id"}
	# 2) Enlace por POI (M54).
	var poi: String = str(ancla.get("poi_id", ""))
	if not poi.is_empty():
		for s in red.stops:
			var stop: TransportStop = s as TransportStop
			if stop != null and stop.poi_id == poi:
				return {"ancla_id": str(ancla.get("id", "")), "stop_id": String(stop.id), "distancia": 0.0, "via": "poi_id"}
	# 3) Proximidad en el plano XZ.
	if not (ancla.has("x") and ancla.has("z")):
		return {}
	var ax: float = float(ancla.get("x", 0.0))
	var az: float = float(ancla.get("z", 0.0))
	var mejor: Dictionary = {}
	var mejor_d: float = radio
	for s in red.stops:
		var stop2: TransportStop = s as TransportStop
		if stop2 == null:
			continue
		var d: float = Vector2(stop2.pos.x - ax, stop2.pos.z - az).length()
		if d <= mejor_d:
			mejor_d = d
			mejor = {"ancla_id": str(ancla.get("id", "")), "stop_id": String(stop2.id), "distancia": snappedf(d, 0.01), "via": "proximidad"}
	return mejor


## ¿Está desbloqueada la parada? Prioriza el manager real (M71/M59), luego la
## lista explícita, y por último el propio dataset (`desbloqueada_inicial`).
func _esta_desbloqueada(stop_id: String, desbloqueadas: Array, manager: Object, red: TransportNetwork = null) -> bool:
	if manager != null and manager.has_method("esta_parada_desbloqueada"):
		return bool(manager.call("esta_parada_desbloqueada", StringName(stop_id)))
	if desbloqueadas.has(stop_id):
		return true
	if red != null:
		var s: TransportStop = red.stop(StringName(stop_id))
		if s != null:
			return s.desbloqueada_inicial
	return false
