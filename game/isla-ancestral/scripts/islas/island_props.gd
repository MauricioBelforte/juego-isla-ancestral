# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-11
#
# M27: Islas del Mundo — IslandProps.
# Spawn DECLARATIVO del contenido exclusivo de una isla. Este servicio no sabe
# spawnear nada: los módulos dueños (M50 flora, M36 fauna, M15 recursos, M64
# POI) registran un `Callable` por tipo y M27 los invoca en el orden y con el
# PRNG correctos.
#
# Determinismo (requisito 85): el PRNG de una isla se siembra con
# `semilla_isla` + el hash del id, así que la misma partida genera siempre los
# mismos props, en el mismo orden, sin importar cuándo se materialicen.

class_name IslandProps
extends RefCounted

## Tipos de spawner que M27 conoce (los ids son el contrato con los dueños).
const TIPO_FLORA := &"flora"
const TIPO_FAUNA := &"fauna"
const TIPO_RECURSO := &"recurso"
const TIPO_POI := &"poi"
const TIPOS: Array[StringName] = [TIPO_POI, TIPO_FLORA, TIPO_FAUNA, TIPO_RECURSO]

var _spawners: Dictionary = {}          # tipo -> Callable
var _materializadas: Dictionary = {}    # id de isla -> Dictionary (informe)
var _semillas: Dictionary = {}          # id de isla -> int (semilla de props)


## ── Registro ──────────────────────────────────────────────

func registrar_spawner(tipo: StringName, callable: Callable) -> bool:
	if not TIPOS.has(tipo):
		push_warning("[Islands] tipo de spawner desconocido: %s" % tipo)
		return false
	if not callable.is_valid():
		push_error("[Islands] spawner %s con Callable inválido" % tipo)
		return false
	_spawners[tipo] = callable
	return true


func tiene_spawner(tipo: StringName) -> bool:
	return _spawners.has(tipo)


func tipos_registrados() -> Array[StringName]:
	var out: Array[StringName] = []
	for t in TIPOS:
		if _spawners.has(t):
			out.append(t)
	return out


## ── Materialización ───────────────────────────────────────

## Semilla determinista de props de una isla.
func semilla_props(isla: IslandDefinition) -> int:
	if isla == null:
		return 0
	if _semillas.has(isla.id):
		return _semillas[isla.id]
	var s: int = int(abs(hash(String(isla.id)) ^ (isla.semilla_isla * 40503)) % 2147483647)
	_semillas[isla.id] = s
	return s


## Invoca los spawners registrados para la isla. `zona` permite materializar
## sólo un subconjunto (p. ej. los POI primero y la vegetación después).
## Devuelve {ok, isla, semilla, invocados, omitidos, props, errores}.
func materializar(isla: IslandDefinition, zona: int = -1) -> Dictionary:
	var informe: Dictionary = {
		"ok": false, "isla": "", "semilla": 0,
		"invocados": [], "omitidos": [], "props": {}, "errores": [],
	}
	if isla == null:
		informe["errores"] = ["isla nula"]
		return informe
	informe["isla"] = String(isla.id)
	if not isla.ancla_asignada:
		# Requisito 86: no se materializa una isla lejana sin ancla/terreno.
		informe["errores"] = ["isla %s sin ancla: no se materializa" % isla.id]
		return informe

	var semilla: int = semilla_props(isla)
	informe["semilla"] = semilla
	var rng := RandomNumberGenerator.new()
	rng.seed = semilla

	var conteo: Dictionary = {}
	for tipo in TIPOS:
		if not _spawners.has(tipo):
			informe["omitidos"].append(String(tipo))
			continue
		var ctx: Dictionary = _contexto(isla, tipo, rng, zona)
		if ctx.get("items", []).is_empty():
			informe["omitidos"].append(String(tipo))
			continue
		var fn: Callable = _spawners[tipo]
		var res: Variant = fn.call(isla, ctx)
		if typeof(res) == TYPE_DICTIONARY:
			conteo[String(tipo)] = int((res as Dictionary).get("spawneados", 0))
		else:
			conteo[String(tipo)] = int(res) if typeof(res) == TYPE_INT else 0
		informe["invocados"].append(String(tipo))

	informe["props"] = conteo
	informe["ok"] = true
	_materializadas[isla.id] = informe
	return informe


## Contexto que se le pasa a cada spawner: qué ids corresponden a ESTA isla y
## el PRNG ya sembrado. El spawner decide cómo y dónde colocarlos.
func _contexto(isla: IslandDefinition, tipo: StringName, rng: RandomNumberGenerator, zona: int) -> Dictionary:
	var items: PackedStringArray = PackedStringArray()
	match tipo:
		TIPO_FLORA:
			items = isla.flora_endemica
		TIPO_FAUNA:
			items = isla.fauna_endemica
		TIPO_RECURSO:
			items = isla.recursos_exclusivos
		TIPO_POI:
			# El contenido POI de una isla son sus puzzles/estaciones (M64 coloca
			# el marcador y el trigger; M27 sólo declara cuáles y con qué PRNG).
			items = isla.puzzles
	var semilla_zona: int = rng.randi() if zona >= 0 else 0
	return {
		"items": items,
		"bounds": isla.bounds_locales(),
		"centro": isla.centro_mundo(),
		"zona": zona,
		"semilla_zona": semilla_zona,
		"es_flotante": isla.es_flotante,
		"playa_ancho": isla.playa_ancho,
	}


## Conteo de props spawneados por tipo en una isla materializada.
## Devuelve p. ej. {"flora": 42, "fauna": 7}. Vacío si no se materializó.
func conteo_props(id: StringName) -> Dictionary:
	var inf: Dictionary = _materializadas.get(id, {})
	return inf.get("props", {}) as Dictionary


## ¿Se materializó ya esta isla?
func esta_materializada(id: StringName) -> bool:
	return _materializadas.has(id)


func informe(id: StringName) -> Dictionary:
	return _materializadas.get(id, {})


func limpiar(id: StringName) -> bool:
	_semillas.erase(id)
	return _materializadas.erase(id)


func limpiar_todo() -> void:
	_materializadas.clear()
	_semillas.clear()
