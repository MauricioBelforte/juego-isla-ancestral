# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-07
#
# M24 iter. 1: interprete datos-driven del framework emisor->receptor.
# Un puzzle se define en datos ({emisores, reglas, objetivo}); este script lo
# carga, lo valida y computa cuantas soluciones MINIMAS tiene (garantia de
# "puzzles justos": exactamente 1). RefCounted + static: no instancia escenas.
#
# SEMANTICA (decidida con el director, canal DeepSeek/64; documentada en
# 03-Diseno.md, seccion "Semantica de objetivo y solucion"):
#   - objetivo T = conjunto de ids de emisores que deben estar ON (declarado en datos).
#   - El puzzle se COMPLETA cuando el estado S == T (NO cuando "todas las reglas"
#     se cumplen: esa era la semantica ambigua de recalcular() para multi-receptor).
#   - Una "solucion" es un conjunto M de emisores que ACTIVA el receptor objetivo
#     (satisface al menos una regla). Es MINIMA si ningun subconjunto propio la activa.
#   - Un puzzle es JUSTO si tiene exactamente 1 solucion minima y esa solucion == T.

class_name PuzzleDef
extends RefCounted

## Tope de la fuerza bruta 2^n (2^16 = 65536 estados). Si un puzzle declara mas,
## validar_def() lo RECHAZA en vez de silenciar la verificacion de unicidad.
const MAX_EMISORES := 16

# --- Carga ---------------------------------------------------------------

## Carga un puzzle desde un JSON. Devuelve {} si no existe o no es un objeto.
static func cargar(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_warning("[M24] PuzzleDef.cargar: no existe %s" % path)
		return {}
	var crudo: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(crudo) != TYPE_DICTIONARY:
		push_warning("[M24] PuzzleDef.cargar: %s no es un objeto JSON" % path)
		return {}
	return crudo as Dictionary

# --- Lectura de campos ---------------------------------------------------

## Ids de emisores declarados, en orden de declaracion.
## Acepta tanto dicts ({id:...}) como enteros sueltos.
static func ids_emisores(def: Dictionary) -> Array:
	var out: Array = []
	var lista: Variant = def.get("emisores", [])
	if typeof(lista) != TYPE_ARRAY:
		return out
	for e in (lista as Array):
		if typeof(e) == TYPE_DICTIONARY:
			out.append(int((e as Dictionary).get("id", -1)))
		elif typeof(e) == TYPE_INT or typeof(e) == TYPE_FLOAT:
			out.append(int(e))
	return out

## Ids del objetivo T (los emisores que deben estar ON).
static func ids_objetivo(def: Dictionary) -> Array:
	var out: Array = []
	var lista: Variant = def.get("objetivo", [])
	if typeof(lista) != TYPE_ARRAY:
		return out
	for x in (lista as Array):
		out.append(int(x))
	return out

static func reglas_def(def: Dictionary) -> Array:
	var lista: Variant = def.get("reglas", [])
	if typeof(lista) != TYPE_ARRAY:
		return []
	return lista as Array

## Umbral de peso de un emisor (0 si no aplica o no esta declarado).
static func umbral_peso_de(def: Dictionary, id: int) -> int:
	var lista: Variant = def.get("emisores", [])
	if typeof(lista) != TYPE_ARRAY:
		return 0
	for e in (lista as Array):
		if typeof(e) == TYPE_DICTIONARY:
			var d: Dictionary = e as Dictionary
			if int(d.get("id", -1)) == id:
				return int(d.get("umbral_peso", 0))
	return 0

# --- Semantica de completado y solucion ----------------------------------

## Un estado (lista de ids ON) completa el puzzle si coincide con el objetivo T.
static func completado_por(def: Dictionary, estado: Array) -> bool:
	return _mismos_ids(estado, ids_objetivo(def))

## Numero de conjuntos MINIMOS de emisores que activan el receptor objetivo.
## Fuerza bruta 2^n (n <= MAX_EMISORES). Se exige exactamente 1 (puzzle no ambiguo).
static func soluciones_minimas(def: Dictionary) -> int:
	var ids: Array = ids_emisores(def)
	var n: int = ids.size()
	if n == 0 or n > MAX_EMISORES:
		return 0
	var activadoras: Array = _mascaras_activas(def, ids, n)
	var minimas: int = 0
	for mask in activadoras:
		if _es_minima(int(mask), activadoras):
			minimas += 1
	return minimas

## Devuelve los ids de la UNICA solucion minima, o [] si hay 0 o 2+.
static func solucion_minima(def: Dictionary) -> Array:
	var ids: Array = ids_emisores(def)
	var n: int = ids.size()
	if n == 0 or n > MAX_EMISORES:
		return []
	var activadoras: Array = _mascaras_activas(def, ids, n)
	var minimas: Array = []
	for mask in activadoras:
		if _es_minima(int(mask), activadoras):
			minimas.append(int(mask))
	if minimas.size() != 1:
		return []
	var m: int = int(minimas[0])
	var out: Array = []
	for i in range(n):
		if ((m >> i) & 1) == 1:
			out.append(ids[i])
	return out

# --- Validacion ----------------------------------------------------------

## Valida estructura + PROPIEDAD DE UNICIDAD. Devuelve [] si el puzzle es justo.
## Mensajes (no exhaustivos): "sin emisores", "emisor duplicado N",
## "sala sin reglas", "regla con conjunto de emisores vacio", "regla usa emisor
## inexistente N", "emisor huerfano N", "sin objetivo declarado",
## "receptores multiples", "soluciones minimas = N", "el objetivo declarado ...".
static func validar_def(def: Dictionary) -> Array:
	var errores: Array = []
	if def.is_empty():
		errores.append("definicion vacia")
		return errores

	var ids: Array = ids_emisores(def)
	if ids.is_empty():
		errores.append("sin emisores declarados")
	if ids.size() > MAX_EMISORES:
		errores.append("demasiados emisores (%d > %d): no se puede verificar unicidad" % [ids.size(), MAX_EMISORES])

	var vistos: Dictionary = {}
	for id in ids:
		var i: int = int(id)
		if vistos.has(i):
			errores.append("emisor duplicado id %d" % i)
		vistos[i] = true

	var reglas: Array = reglas_def(def)
	if reglas.is_empty():
		errores.append("sala sin reglas: arbitraria")

	var receptores: Dictionary = {}
	var usados: Dictionary = {}
	for regla in reglas:
		if typeof(regla) != TYPE_DICTIONARY:
			errores.append("regla no es un objeto")
			continue
		var r: Dictionary = regla as Dictionary
		var receptor: String = str(r.get("receptor", ""))
		if receptor.is_empty():
			errores.append("regla sin receptor")
		receptores[receptor] = true
		var emis: Variant = r.get("emisores", [])
		if typeof(emis) != TYPE_ARRAY:
			errores.append("regla %s: 'emisores' no es array" % receptor)
			continue
		if (emis as Array).is_empty():
			errores.append("regla con conjunto de emisores vacio (receptor %s)" % receptor)
		for eid in (emis as Array):
			var e: int = int(eid)
			usados[e] = true
			if not vistos.has(e):
				errores.append("regla usa emisor inexistente %d (receptor %s)" % [e, receptor])

	if receptores.size() > 1:
		errores.append("receptores multiples %s: el objetivo debe ser unico" % str(receptores.keys()))

	# Regla desconectada: emisor declarado pero no referenciado por ninguna regla.
	for id in ids:
		if not usados.has(int(id)):
			errores.append("emisor huerfano %d: declarado pero sin regla (regla desconectada)" % int(id))

	var obj: Array = ids_objetivo(def)
	if obj.is_empty():
		errores.append("sin objetivo declarado")
	for id in obj:
		if not vistos.has(int(id)):
			errores.append("objetivo usa emisor inexistente %d" % int(id))

	# Unicidad: solo si la estructura es coherente y n <= tope.
	if errores.is_empty():
		var n: int = soluciones_minimas(def)
		if n != 1:
			errores.append("soluciones minimas = %d (se exige exactamente 1): puzzle ambiguo" % n)
		else:
			var minima: Array = solucion_minima(def)
			if not _mismos_ids(minima, obj):
				errores.append("el objetivo declarado %s no es la solucion minima unica %s" % [str(obj), str(minima)])
	return errores

# --- Integracion con PuzzleRoom ------------------------------------------

## Construye un PuzzleRoom con los emisores, reglas y objetivo de la definicion.
static func a_puzzle_room(def: Dictionary) -> PuzzleRoom:
	var sala := PuzzleRoom.new(ids_emisores(def))
	for regla in reglas_def(def):
		if typeof(regla) != TYPE_DICTIONARY:
			continue
		var r: Dictionary = regla as Dictionary
		var arr: Array = []
		var emis: Variant = r.get("emisores", [])
		if typeof(emis) == TYPE_ARRAY:
			for e in (emis as Array):
				arr.append(int(e))
		sala.add_regla(arr, str(r.get("receptor", "")))
	sala.objetivo = ids_objetivo(def)
	return sala

# --- Helpers privados ----------------------------------------------------

## Mascaras (bitmask) de los subconjuntos NO vacios que activan el receptor.
static func _mascaras_activas(def: Dictionary, ids: Array, n: int) -> Array:
	var idx: Dictionary = {}
	for i in range(n):
		idx[int(ids[i])] = i
	var out: Array = []
	for mask in range(1, 1 << n):
		if _mascara_activa(mask, idx, def):
			out.append(mask)
	return out

static func _mascara_activa(mask: int, idx: Dictionary, def: Dictionary) -> bool:
	for regla in reglas_def(def):
		if typeof(regla) != TYPE_DICTIONARY:
			continue
		var emis: Variant = (regla as Dictionary).get("emisores", [])
		if typeof(emis) != TYPE_ARRAY:
			continue
		var cumple: bool = true
		for eid in (emis as Array):
			var e: int = int(eid)
			if not idx.has(e):
				cumple = false
				break
			if ((mask >> int(idx[e])) & 1) == 0:
				cumple = false
				break
		if cumple:
			return true
	return false

static func _es_minima(mask: int, activadoras: Array) -> bool:
	for otra in activadoras:
		var o: int = int(otra)
		if o != mask and (o & mask) == o:
			return false
	return true

static func _mismos_ids(a: Array, b: Array) -> bool:
	var sa: Dictionary = {}
	for x in a:
		sa[int(x)] = true
	var sb: Dictionary = {}
	for y in b:
		sb[int(y)] = true
	if sa.size() != sb.size():
		return false
	for k in sa:
		if not sb.has(k):
			return false
	return true
