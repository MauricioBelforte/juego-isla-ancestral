# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-11
#
# M68: Transporte y Navegación — TransportNetwork (Resource).
# El grafo de paradas y rutas: ÚNICA FUENTE DE VERDAD del módulo
# (03-Diseno §1: "evita la discrepancia señalización-mapa").
#
# La señalización (M46), la capa del mapa (M54) y el panel (M53) leen ESTE
# objeto; nadie duplica la red. `validar()` es la puerta de calidad del
# dataset y la usa el test headless y el CI (M108/M118).

class_name TransportNetwork
extends Resource

## Paradas del grafo (puertos, plataformas, estaciones, muelles).
@export var stops: Array[TransportStop] = []
## Aristas dirigidas. La arista inversa es EXPLÍCITA (no se genera sola).
@export var routes: Array[TransportRoute] = []
## Versión del esquema del dataset (para migraciones futuras, M60).
@export var schema_version: int = 1


## ── Consultas ─────────────────────────────────────────────

func stop(id: StringName) -> TransportStop:
	for s in stops:
		if s != null and s.id == id:
			return s
	return null


func tiene_stop(id: StringName) -> bool:
	return stop(id) != null


func ruta(id: StringName) -> TransportRoute:
	for r in routes:
		if r != null and r.id == id:
			return r
	return null


func contar_stops() -> int:
	return stops.size()


func contar_rutas() -> int:
	return routes.size()


## Aristas que SALEN de `origen`. Si `permitir` es un Callable, filtra por él
## (se le pasa cada TransportRoute; debe devolver bool).
func rutas_desde(origen: StringName, permitir: Callable = Callable()) -> Array[TransportRoute]:
	var out: Array[TransportRoute] = []
	for r in routes:
		if r == null or r.from_id != origen:
			continue
		if permitir.is_valid() and not bool(permitir.call(r)):
			continue
		out.append(r)
	return out


## IDs de paradas alcanzables en un salto desde `origen`.
func vecinos(origen: StringName) -> Array[StringName]:
	var out: Array[StringName] = []
	for r in rutas_desde(origen):
		if not out.has(r.to_id):
			out.append(r.to_id)
	return out


## Dijkstra por coste (AO). Devuelve el camino más BARATO, no el más corto en
## saltos: es lo que hace que "combinar rutas" gane al viaje directo.
## `permitir` (Callable opcional) filtra aristas (desbloqueo M71, horario M29,
## clima M32). Sin camino → `{"ok": false, "motivo": ...}`.
func ruta_mas_barata(origen: StringName, destino: StringName, permitir: Callable = Callable()) -> Dictionary:
	if not tiene_stop(origen) or not tiene_stop(destino):
		return {"ok": false, "motivo": "parada inexistente", "coste": -1, "saltos": 0}
	if origen == destino:
		return {"ok": true, "coste": 0, "duracion": 0.0, "saltos": 0,
			"paradas": [String(origen)], "rutas": []}

	var coste: Dictionary = {}      # id -> int
	var dur: Dictionary = {}        # id -> float
	var previo: Dictionary = {}     # id -> StringName (parada anterior)
	var previo_ruta: Dictionary = {}  # id -> StringName (ruta usada)
	var visitado: Dictionary = {}
	var pendientes: Array[StringName] = [origen]
	coste[origen] = 0
	dur[origen] = 0.0

	while not pendientes.is_empty():
		# Extracción del mínimo (grafo pequeño: ≤ 20 aristas → barrido lineal).
		var mejor: StringName = pendientes[0]
		var mejor_coste: int = int(coste.get(mejor, 1 << 30))
		for p in pendientes:
			var c: int = int(coste.get(p, 1 << 30))
			if c < mejor_coste:
				mejor = p
				mejor_coste = c
		pendientes.erase(mejor)
		if visitado.has(mejor):
			continue
		visitado[mejor] = true
		if mejor == destino:
			break
		for r in rutas_desde(mejor, permitir):
			var n: StringName = r.to_id
			if visitado.has(n):
				continue
			var nuevo: int = mejor_coste + r.base_cost
			if nuevo < int(coste.get(n, 1 << 30)):
				coste[n] = nuevo
				dur[n] = float(dur.get(mejor, 0.0)) + r.duracion_seg
				previo[n] = mejor
				previo_ruta[n] = r.id
				if not pendientes.has(n):
					pendientes.append(n)

	if not coste.has(destino):
		return {"ok": false, "motivo": "sin camino", "coste": -1, "saltos": 0,
			"paradas": [], "rutas": []}

	# Reconstrucción del camino.
	var paradas: Array[String] = []
	var rutas: Array[String] = []
	var actual: StringName = destino
	var guardia: int = 0
	while guardia < 1000:
		guardia += 1
		paradas.push_front(String(actual))
		if actual == origen:
			break
		if not previo.has(actual):
			return {"ok": false, "motivo": "camino roto", "coste": -1, "saltos": 0,
				"paradas": [], "rutas": []}
		rutas.push_front(String(previo_ruta[actual]))
		actual = previo[actual]

	return {
		"ok": true,
		"coste": int(coste[destino]),
		"duracion": snappedf(float(dur.get(destino, 0.0)), 0.01),
		"saltos": rutas.size(),
		"paradas": paradas,
		"rutas": rutas,
	}


## Alias con el nombre del diseño (§2.1 usa "dijkstra").
func ruta_mas_corta(origen: StringName, destino: StringName, permitir: Callable = Callable()) -> Dictionary:
	return ruta_mas_barata(origen, destino, permitir)


## Paradas alcanzables desde `origen` (BFS, sin filtro de coste).
func alcanzables_desde(origen: StringName) -> Array[StringName]:
	var vistos: Dictionary = {origen: true}
	var cola: Array[StringName] = [origen]
	var out: Array[StringName] = []
	while not cola.is_empty():
		var actual: StringName = cola.pop_front()
		for n in vecinos(actual):
			if not vistos.has(n):
				vistos[n] = true
				out.append(n)
				cola.append(n)
	return out


## ── Validación (puerta de calidad del dataset) ────────────

## Devuelve un Array[String] de errores; vacío = red válida.
func validar() -> Array[String]:
	var errores: Array[String] = []
	var ids_stop: Dictionary = {}
	var ids_ruta: Dictionary = {}
	var pares: Dictionary = {}

	for s in stops:
		if s == null:
			errores.append("parada nula")
			continue
		if String(s.id).is_empty():
			errores.append("parada sin id")
			continue
		if ids_stop.has(s.id):
			errores.append("id de parada duplicado: %s" % s.id)
		ids_stop[s.id] = true
		if s.tipo.is_empty():
			errores.append("parada %s sin tipo" % s.id)
		elif not _tipo_valido(s.tipo):
			errores.append("parada %s con tipo desconocido: %s" % [s.id, s.tipo])

	for r in routes:
		if r == null:
			errores.append("ruta nula")
			continue
		if String(r.id).is_empty():
			errores.append("ruta sin id")
			continue
		if ids_ruta.has(r.id):
			errores.append("id de ruta duplicado: %s" % r.id)
		ids_ruta[r.id] = true
		if not ids_stop.has(r.from_id):
			errores.append("ruta %s: origen inexistente %s" % [r.id, r.from_id])
		if not ids_stop.has(r.to_id):
			errores.append("ruta %s: destino inexistente %s" % [r.id, r.to_id])
		if r.from_id == r.to_id:
			errores.append("ruta %s: origen == destino (bucle)" % r.id)
		var par := "%s>%s" % [r.from_id, r.to_id]
		if pares.has(par):
			errores.append("par dirigido duplicado: %s" % par)
		pares[par] = true
		if r.base_cost < 0:
			errores.append("ruta %s: coste negativo" % r.id)
		if r.duracion_seg <= 0.0:
			errores.append("ruta %s: duración no positiva" % r.id)

	return errores


func es_valida() -> bool:
	return validar().is_empty()


func _tipo_valido(t: String) -> bool:
	return t in ["barco", "dirigible", "tren", "muelle"]


## Huella determinista del grafo (ordenada) — para detectar cambios de dataset
## en CI y para el checksum de auditoría (patrón §9.11).
func huella() -> String:
	var paradas: Array[String] = []
	for s in stops:
		if s != null:
			paradas.append(String(s.id))
	paradas.sort()
	var aristas: Array[String] = []
	for r in routes:
		if r != null:
			aristas.append("%s|%s|%s|%d|%.2f" % [r.from_id, r.to_id, r.medio, r.base_cost, r.duracion_seg])
	aristas.sort()
	return "%d:%s;%d:%s" % [paradas.size(), ",".join(paradas), aristas.size(), ",".join(aristas)]
