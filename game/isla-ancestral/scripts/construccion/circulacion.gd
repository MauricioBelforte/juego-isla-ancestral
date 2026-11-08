# Modelo: DS-V4.1-Flash-Opencode (DeepSeek V4.1 Flash)
# Plataforma: OpenCode
# Fecha: 2026-11-08
#
# M17 Construccion — Circulacion: modelo PURO de conectividad de una zona.
#
# POR QUE EXISTE (L148): el validador sabia decir "hay soporte" y "no hay NPC",
# pero no podia responder "esta pieza tapa la unica salida de la zona". Este
# modelo hace un BFS 4-direccional (plano x/z, que es donde el jugador camina)
# sobre las celdas transitables de la zona y compara la conectividad ANTES y
# DESPUES de colocar la huella de la pieza.
#
# NUCLEO PURO: no referencia nodos, escenas, VoxelTools ni autoloads. Se puede
# cargar y testear en headless sin que el mundo exista.
#
# Semantica:
#   * `zona`      celdas transitables declaradas por el dueno de la zona.
#   * `salidas`   celdas marcadas como salida (puertas, aberturas al exterior).
#   * `ocupadas`  celdas ya bloqueadas por piezas existentes.
#   * `nuevas`    huella de la pieza que se quiere colocar.
#
# Regla: una pieza BLOQUEA si (a) tapa una salida, o (b) dos salidas que antes
# estaban conectadas dejan de estarlo, o (c) con una sola salida, la deja
# aislada del resto de la zona. Si una salida ya estaba aislada ANTES por una
# pieza previa, no se le atribuye a la pieza nueva.

class_name Circulacion
extends RefCounted

## Tope de celdas visitadas por BFS (guarda contra zonas gigantes o ciclos).
const MAX_VISITAS: int = 200000

## Vecinos del plano de caminata (x/z). La altura no cambia: se camina por y.
const VECINOS: Array[Vector3i] = [
	Vector3i(1, 0, 0), Vector3i(-1, 0, 0), Vector3i(0, 0, 1), Vector3i(0, 0, -1),
]

## Analiza si `nuevas` bloquea la circulacion de `zona` respecto de `salidas`.
## Devuelve un Dictionary estable:
##   { sin_datos, bloquea, motivo, salidas_tapadas, salidas_aisladas,
##     celdas_libres_antes, celdas_libres_despues, componentes_antes,
##     componentes_despues }
static func analizar(zona: Array, salidas: Array, ocupadas: Array, nuevas: Array) -> Dictionary:
	var out: Dictionary = {
		"sin_datos": false,
		"bloquea": false,
		"motivo": "",
		"salidas_tapadas": [],
		"salidas_aisladas": [],
		"celdas_libres_antes": 0,
		"celdas_libres_despues": 0,
		"componentes_antes": 0,
		"componentes_despues": 0,
	}
	if zona.is_empty() or salidas.is_empty():
		out["sin_datos"] = true
		out["motivo"] = "sin zona o sin salidas declaradas: no se puede evaluar"
		return out

	var zonaset: Dictionary = _conjunto(zona)
	var ocupadaset: Dictionary = _conjunto(ocupadas)
	var nuevaset: Dictionary = _conjunto(nuevas)

	# Transitables antes y despues (la zona menos lo bloqueado).
	var antes: Dictionary = {}
	for k in zonaset.keys():
		if not ocupadaset.has(k):
			antes[k] = zonaset[k]
	var despues: Dictionary = {}
	for k in antes.keys():
		if not nuevaset.has(k):
			despues[k] = antes[k]

	out["celdas_libres_antes"] = antes.size()
	out["celdas_libres_despues"] = despues.size()

	# Salidas tapadas por la pieza nueva.
	var tapadas: Array = []
	for s in salidas:
		if nuevaset.has(_clave(s)):
			tapadas.append(s)
	out["salidas_tapadas"] = tapadas

	# Componentes antes y despues (solo para diagnostico).
	out["componentes_antes"] = _componentes(antes).size()
	out["componentes_despues"] = _componentes(despues).size()

	# Salidas alcanzables antes y despues (ignorando las tapadas por la pieza).
	var alcanzables_antes: Array = []
	var alcanzables_despues: Array = []
	for s in salidas:
		if tapadas.has(s):
			continue
		if antes.has(_clave(s)):
			alcanzables_antes.append(s)
		if despues.has(_clave(s)):
			alcanzables_despues.append(s)

	# (a) Tapa una salida.
	if not tapadas.is_empty():
		out["bloquea"] = true
		out["motivo"] = "tapa %d salida(s) de la zona" % tapadas.size()
		return out

	# (b) Dos salidas que antes estaban conectadas dejan de estarlo.
	var aisladas: Array = []
	var n_antes: int = alcanzables_antes.size()
	for i in range(n_antes):
		for j in range(i + 1, n_antes):
			var s1: Vector3i = alcanzables_antes[i]
			var s2: Vector3i = alcanzables_antes[j]
			var antes_conectadas: bool = _alcanzables(antes, s1).has(_clave(s2))
			if not antes_conectadas:
				continue
			var despues_conectadas: bool = despues.has(_clave(s1)) and despues.has(_clave(s2)) \
				and _alcanzables(despues, s1).has(_clave(s2))
			if not despues_conectadas:
				if not aisladas.has(s1):
					aisladas.append(s1)
				if not aisladas.has(s2):
					aisladas.append(s2)

	# (c) Una sola salida: quedo aislada del resto de la zona.
	if n_antes == 1:
		var unica: Vector3i = alcanzables_antes[0]
		if despues.has(_clave(unica)):
			var comp: Dictionary = _alcanzables(despues, unica)
			# Aislada = la salida es lo unico alcanzable y habia mas zona libre.
			if comp.size() <= 1 and despues.size() > 1:
				aisladas.append(unica)

	out["salidas_aisladas"] = aisladas
	if not aisladas.is_empty():
		out["bloquea"] = true
		out["motivo"] = "aisla %d salida(s) del resto de la zona" % aisladas.size()
	return out

## true si la pieza bloquea la circulacion. Atajo de `analizar`.
static func bloquea(zona: Array, salidas: Array, ocupadas: Array, nuevas: Array) -> bool:
	return bool(analizar(zona, salidas, ocupadas, nuevas).get("bloquea", false))

## Celdas alcanzables desde `inicio` en el conjunto `transitables` (BFS 4-dir).
static func _alcanzables(transitables: Dictionary, inicio: Vector3i) -> Dictionary:
	var vistos: Dictionary = {}
	var k0: String = _clave(inicio)
	if not transitables.has(k0):
		return vistos
	var cola: Array[Vector3i] = [inicio]
	vistos[k0] = true
	var head: int = 0
	while head < cola.size() and vistos.size() < MAX_VISITAS:
		var c: Vector3i = cola[head]
		head += 1
		for d in VECINOS:
			var n: Vector3i = c + d
			var k: String = _clave(n)
			if transitables.has(k) and not vistos.has(k):
				vistos[k] = true
				cola.append(n)
	return vistos

## Componentes conexos del conjunto (solo diagnostico).
static func _componentes(transitables: Dictionary) -> Array:
	var vistos: Dictionary = {}
	var out: Array = []
	for k in transitables.keys():
		if vistos.has(k):
			continue
		var c: Vector3i = transitables[k]
		var comp: Dictionary = _alcanzables(transitables, c)
		out.append(comp.size())
		for ck in comp.keys():
			vistos[ck] = true
	return out

## Conjunto clave -> celda (deterministico: la ultima celda gana si hay repetidas).
static func _conjunto(celdas: Array) -> Dictionary:
	var out: Dictionary = {}
	for c in celdas:
		if c is Vector3i:
			out[_clave(c)] = c
	return out

## Clave canonica de celda. Delega en ConstruccionTipos para no duplicar formato.
static func _clave(c: Vector3i) -> String:
	return ConstruccionTipos.clave(c)
