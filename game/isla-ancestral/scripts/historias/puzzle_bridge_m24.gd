# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-26
#
# M23 — puente hacia el framework de puzzles de M24 (item L92 de 05-Checklist:
# "Definir la integracion con el framework M24").
#
# ESTADO MEDIDO ANTES DE ESTE ARCHIVO (2026-10-26):
#   - 78 pasos `tipo: "puzzle"` en las cadenas cargadas, con 78 `ref` DISTINTOS.
#   - El catalogo real de M24 tiene 28 puzzles en data/templos/puzzles/**.
#   - CRUCE: 0 de 78 resuelven (ni por substring) -> el `ref` no apuntaba a nada.
#   - `reportar_paso(..., "puzzle", ...)`: 0 llamadas de RUNTIME en todo el repo
#     (todas las que existen son de tests) -> ningun paso puzzle era completable.
#   - `validar_cadenas()` no valida NINGUNA referencia (ni ref, ni lugar, ni npc,
#     ni objeto), asi que las 78 referencias colgantes eran INVISIBLES.
#
# CONTRATO QUE DEFINE ESTE PUENTE (dos niveles, derivado del disco, sin campo nuevo
# en los datos y sin tocar el esquema de las cadenas):
#   Tier A "m24"       : el `ref` es un id del catalogo de M24. La sala jugable se
#                        construye con la API REAL de M24 (PuzzleDef.cargar ->
#                        PuzzleDef.a_puzzle_room) y al completarse reporta el paso.
#   Tier B "narrativo" : el `ref` NO es un puzzle de M24. No lo completa M24; lo
#                        completa el sistema narrativo (M19 dialogo / M14 inventario)
#                        reportando la MISMA evidencia (mismo contrato de
#                        reportar_paso). Es deuda MEDIDA, no silencio.
#   "vacio"            : paso puzzle sin `ref` -> defecto real de datos.
#
# RefCounted + static: no instancia escenas, no toca autoloads, verificable headless.
# Ejecutar la suite: godot --headless --path game/isla-ancestral \
#   --script res://scripts/historias/test_m23_l92_m24.gd

class_name PuzzleBridgeM24
extends RefCounted

## Raiz del catalogo de puzzles que publica M24.
const RUTA_PUZZLES := "res://data/templos/puzzles"

const TIER_M24 := "m24"
const TIER_NARRATIVO := "narrativo"
const TIER_VACIO := "vacio"


# --- Catalogo de M24 -----------------------------------------------------

## Puzzles que M24 publica en disco: {id: ruta_res}. Recorre subcarpetas (M24
## agrupa por tipo: agua/, bloques/, espejos/...). El id sale del campo `id` del
## JSON; si falta, se usa el nombre de archivo sin extension.
static func catalogo(dir: String = RUTA_PUZZLES) -> Dictionary:
	var out: Dictionary = {}
	_escanear(dir, out)
	return out


static func _escanear(dir: String, out: Dictionary) -> void:
	var d := DirAccess.open(dir)
	if d == null:
		return
	d.list_dir_begin()
	var n := d.get_next()
	while n != "":
		if not n.begins_with("."):
			var ruta := dir.path_join(n)
			var es_dir := d.current_is_dir()
			if es_dir:
				_escanear(ruta, out)
			elif n.get_extension().to_lower() == "json":
				var def: Dictionary = PuzzleDef.cargar(ruta)
				var id := String(def.get("id", ""))
				if id.is_empty():
					id = n.get_basename()
				out[id] = ruta
		n = d.get_next()
	d.list_dir_end()


# --- Clasificacion de las referencias de M23 -----------------------------

## Clasifica UN `ref` de paso puzzle contra el catalogo de M24.
## Devuelve TIER_M24 | TIER_NARRATIVO | TIER_VACIO.
static func resolver(ref: String, cat: Dictionary) -> String:
	var r := ref.strip_edges()
	if r.is_empty():
		return TIER_VACIO
	return TIER_M24 if cat.has(r) else TIER_NARRATIVO


## Clasifica todos los pasos puzzle de un diccionario de cadenas {id: cadena}.
## Devuelve {total, m24:[], narrativo:[], vacio:[], por_cadena:{cid:{paso:ref}}}.
## `cat` vacio = se mide el catalogo del disco (no se hereda de nadie).
static func clasificar(cadenas: Dictionary, cat: Dictionary = {}) -> Dictionary:
	var c: Dictionary = cat if not cat.is_empty() else catalogo()
	var out: Dictionary = {
		"total": 0, "m24": [], "narrativo": [], "vacio": [], "por_cadena": {}
	}
	for cid in cadenas:
		var cad: Variant = cadenas[cid]
		if typeof(cad) != TYPE_DICTIONARY:
			continue
		var pasos: Variant = (cad as Dictionary).get("pasos", [])
		if typeof(pasos) != TYPE_ARRAY:
			continue
		for p in (pasos as Array):
			if typeof(p) != TYPE_DICTIONARY:
				continue
			if String((p as Dictionary).get("tipo", "")) != "puzzle":
				continue
			out["total"] = int(out["total"]) + 1
			var ref := String((p as Dictionary).get("ref", ""))
			var tier := resolver(ref, c)
			(out[tier] as Array).append(ref)
			if not (out["por_cadena"] as Dictionary).has(cid):
				out["por_cadena"][cid] = {}
			(out["por_cadena"] as Dictionary)[cid][String((p as Dictionary).get("id", ""))] = ref
	return out


## Igual que clasificar() pero tomando las cadenas CARGADAS por el servicio
## (incluye ocultas y postgame). Devuelve {} si el servicio no expone la API.
static func clasificar_servicio(servicio: Object, cat: Dictionary = {}) -> Dictionary:
	if servicio == null or not servicio.has_method("ids_cadenas") \
			or not servicio.has_method("get_cadena"):
		return {}
	var cadenas: Dictionary = {}
	for cid in servicio.ids_cadenas():
		cadenas[String(cid)] = servicio.get_cadena(String(cid))
	return clasificar(cadenas, cat)


## Puzzles de M24 que NINGUNA cadena usa (el otro sentido del cruce). Si un dia
## una cadena apunta a un puzzle de M24, este deja de aparecer aca.
static func m24_sin_uso(cat: Dictionary, clasif: Dictionary) -> Array:
	var usados: Dictionary = {}
	for r in (clasif.get("m24", []) as Array):
		usados[String(r)] = true
	var out: Array = []
	for id in cat:
		if not usados.has(String(id)):
			out.append(String(id))
	out.sort()
	return out


# --- Puente de ejecucion -------------------------------------------------

## Construye la sala jugable de M24 a partir del `ref` de un paso puzzle.
## Devuelve null si el ref no es un puzzle de M24 (Tier B) o si la definicion
## no carga. Usa la API REAL de M24: PuzzleDef.cargar + PuzzleDef.a_puzzle_room.
static func sala_de(ref: String, cat: Dictionary = {}) -> PuzzleRoom:
	var c: Dictionary = cat if not cat.is_empty() else catalogo()
	if not c.has(ref):
		return null
	var def: Dictionary = PuzzleDef.cargar(String(c[ref]))
	if def.is_empty():
		return null
	return PuzzleDef.a_puzzle_room(def)


## Cablea una sala de M24 a un paso puzzle de M23: cuando la sala queda
## `completada`, el servicio reporta el paso usando como evidencia el `ref`
## esperado del paso actual (ref_paso_actual(), misma fuente de verdad que
## reportar_paso). Respeta un `al_cambiar` previo encadenandolo.
## Devuelve {ok: bool, motivo: String}.
static func conectar(sala: PuzzleRoom, servicio: Object, cadena_id: String) -> Dictionary:
	if sala == null:
		return {"ok": false, "motivo": "sala nula"}
	if servicio == null:
		return {"ok": false, "motivo": "servicio nulo"}
	if not servicio.has_method("reportar_paso"):
		return {"ok": false, "motivo": "servicio sin reportar_paso()"}
	if not servicio.has_method("ref_paso_actual"):
		return {"ok": false, "motivo": "servicio sin ref_paso_actual()"}
	var previo: Callable = sala.al_cambiar
	sala.al_cambiar = func(_activos: Array) -> void:
		if previo.is_valid():
			previo.call(_activos)
		if not sala.completada:
			return
		var ref := String(servicio.ref_paso_actual(cadena_id))
		if ref.is_empty():
			return
		servicio.reportar_paso(cadena_id, "puzzle", ref)
	return {"ok": true, "motivo": ""}
