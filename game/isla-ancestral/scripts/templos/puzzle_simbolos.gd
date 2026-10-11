# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-09
#
# M24 iter. 6: familia SIMBOLOS y ambientales.
# Cierra los items 111, 112, 113 y 117 del checklist:
#   111 glifos ancestrales emparejados
#   112 glosario del templo con los glifos (M25 inscripciones)
#   113 sello de puerta por pareja correcta
#   117 documentacion en el plan-actual (03-Diseno.md, seccion "Familia simbolos")
#
# Modelo de datos puro (RefCounted + static). Los glifos siguen el CONTRATO de
# M25 documentado en `DOCUMENTACION/25-Ruinas/plan-actual/03-Diseno.md`
# ("Inscripciones / Glifos"): cada glifo declara `id`, `simbolos` (Array[String])
# y `significado` (String); el catalogo de 30-60 glifos vive en
# `data/ruinas/glifos.json` (aun NO creado por M25). El glosario del templo
# enlaza cada glifo con su inscripcion M25 sin inventar el catalogo.
#
# El sello de puerta abre SOLO cuando los dos pedestales tienen la pareja
# correcta: la colocacion NO activa los emisores por si sola; los activa el
# hecho de que el par sea el declarado (item 113).

class_name PuzzleSimbolos
extends RefCounted

var def: Dictionary = {}
var sala: PuzzleRoom = null
var glifos: Dictionary = {}
var parejas: Array = []
var pedestales: Dictionary = {}
var glosario: Dictionary = {}
var sello: Dictionary = {}

## Colocacion actual: pedestal_id -> glifo_id.
var _colocados: Dictionary = {}

# --- Carga ---------------------------------------------------------------

static func cargar(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_warning("[M24] PuzzleSimbolos.cargar: no existe %s" % path)
		return {}
	var crudo: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(crudo) != TYPE_DICTIONARY:
		push_warning("[M24] PuzzleSimbolos.cargar: %s no es un objeto JSON" % path)
		return {}
	return crudo as Dictionary

static func desde_def(d: Dictionary) -> PuzzleSimbolos:
	var ps := PuzzleSimbolos.new()
	ps._construir(d)
	return ps

func _construir(d: Dictionary) -> void:
	def = d
	sala = PuzzleDef.a_puzzle_room(d)
	glifos = {}
	parejas = []
	pedestales = {}
	glosario = {}
	sello = {}
	_colocados = {}
	var sz: Variant = d.get("simbolos", {})
	var s: Dictionary = (sz as Dictionary) if typeof(sz) == TYPE_DICTIONARY else {}
	var gl: Variant = s.get("glifos", [])
	if typeof(gl) == TYPE_ARRAY:
		for g in (gl as Array):
			if typeof(g) == TYPE_DICTIONARY:
				var gd: Dictionary = g as Dictionary
				glifos[str(gd.get("id", ""))] = gd
	var pa: Variant = s.get("parejas", [])
	if typeof(pa) == TYPE_ARRAY:
		parejas = (pa as Array).duplicate(true)
	var pe: Variant = s.get("pedestales", [])
	if typeof(pe) == TYPE_ARRAY:
		for p in (pe as Array):
			if typeof(p) == TYPE_DICTIONARY:
				var pd: Dictionary = p as Dictionary
				pedestales[str(pd.get("id", ""))] = pd
	var gs: Variant = s.get("glosario", [])
	if typeof(gs) == TYPE_ARRAY:
		for e in (gs as Array):
			if typeof(e) == TYPE_DICTIONARY:
				var ed: Dictionary = e as Dictionary
				glosario[str(ed.get("glifo", ""))] = ed
	var se: Variant = s.get("sello", {})
	sello = (se as Dictionary) if typeof(se) == TYPE_DICTIONARY else {}

# --- Item 111: glifos ancestrales emparejados ----------------------------

func glifo(id: String) -> Dictionary:
	var g: Variant = glifos.get(id, {})
	if typeof(g) != TYPE_DICTIONARY:
		return {}
	return g as Dictionary

func ids_glifos() -> Array:
	return glifos.keys()

## Contrato M25: la lista de simbolos base que componen el glifo.
func simbolos_de(id: String) -> Array:
	var s: Variant = glifo(id).get("simbolos", [])
	if typeof(s) != TYPE_ARRAY:
		return []
	return (s as Array).duplicate()

## Contrato M25: el significado canonico del glifo.
func significado_de(id: String) -> String:
	return str(glifo(id).get("significado", ""))

## Un glifo respeta el contrato de M25 si declara id, simbolos (no vacio) y significado.
func es_glifo_valido_m25(id: String) -> bool:
	if id.is_empty() or not glifos.has(id):
		return false
	if simbolos_de(id).is_empty():
		return false
	return not significado_de(id).is_empty()

func parejas_declaradas() -> Array:
	return parejas.duplicate(true)

## True si {a,b} es una pareja declarada (sin importar el orden).
func es_pareja(a: String, b: String) -> bool:
	for p in parejas:
		if typeof(p) != TYPE_ARRAY:
			continue
		var par: Array = p as Array
		if par.size() != 2:
			continue
		if str(par[0]) == a and str(par[1]) == b:
			return true
		if str(par[0]) == b and str(par[1]) == a:
			return true
	return false

## Compania de un glifo dentro de su pareja ("" si no pertenece a ninguna).
func pareja_de(glifo_id: String) -> String:
	for p in parejas:
		if typeof(p) != TYPE_ARRAY:
			continue
		var par: Array = p as Array
		if par.size() != 2:
			continue
		if str(par[0]) == glifo_id:
			return str(par[1])
		if str(par[1]) == glifo_id:
			return str(par[0])
	return ""

# --- Item 112: glosario del templo (M25 inscripciones) -------------------

func glosario_tiene(glifo_id: String) -> bool:
	return glosario.has(glifo_id)

func inscripcion_de(glifo_id: String) -> String:
	var e: Variant = glosario.get(glifo_id, {})
	if typeof(e) != TYPE_DICTIONARY:
		return ""
	return str((e as Dictionary).get("inscripcion_m25", ""))

func significado_glosario(glifo_id: String) -> String:
	var e: Variant = glosario.get(glifo_id, {})
	if typeof(e) != TYPE_DICTIONARY:
		return ""
	return str((e as Dictionary).get("significado", ""))

## El glosario esta completo si TODOS los glifos tienen entrada con inscripcion M25.
func glosario_completo() -> bool:
	for id in glifos:
		var gid: String = str(id)
		if not glosario_tiene(gid):
			return false
		if inscripcion_de(gid).is_empty():
			return false
	return glifos.size() > 0

func ids_glosario() -> Array:
	return glosario.keys()

# --- Item 113: sello de puerta por pareja correcta -----------------------

func pedestales_ids() -> Array:
	return pedestales.keys()

func emisor_de_pedestal(pid: String) -> int:
	var p: Variant = pedestales.get(pid, {})
	if typeof(p) != TYPE_DICTIONARY:
		return -1
	return int((p as Dictionary).get("emisor", -1))

## Coloca un glifo en un pedestal. NO activa el emisor por si solo: el emisor
## solo se enciende cuando la pareja colocada es la correcta (item 113).
func colocar(glifo_id: String, pid: String) -> bool:
	if not pedestales.has(pid) or not glifos.has(glifo_id):
		return false
	_colocados[pid] = glifo_id
	_recalcular_emisores()
	return true

func quitar(pid: String) -> void:
	if _colocados.has(pid):
		_colocados.erase(pid)
		_recalcular_emisores()

func colocados() -> Dictionary:
	return _colocados.duplicate()

func glifo_en(pid: String) -> String:
	return str(_colocados.get(pid, ""))

## La pareja colocada es correcta si el conjunto de glifos colocados coincide
## EXACTAMENTE con la pareja declarada del sello (uno en cada pedestal).
func pareja_correcta() -> bool:
	var par: Variant = sello.get("pareja", [])
	if typeof(par) != TYPE_ARRAY or (par as Array).size() != 2:
		return false
	var puesta: Array = []
	for pid in _colocados:
		var gid: String = str(_colocados[pid])
		if not gid.is_empty():
			puesta.append(gid)
	if puesta.size() != 2:
		return false
	return es_pareja(str(puesta[0]), str(puesta[1])) and _misma_pareja(puesta, par as Array)

## El sello esta abierto cuando S == T (ambos pedestales con la pareja correcta).
func sello_abierto() -> bool:
	if sala == null:
		return false
	return sala.estado_igual_objetivo()

## Atajo de autoria/prueba: coloca la pareja correcta en los dos primeros pedestales.
func colocar_pareja_correcta() -> bool:
	var ids: Array = pedestales_ids()
	if ids.size() < 2:
		return false
	var par: Variant = sello.get("pareja", [])
	if typeof(par) != TYPE_ARRAY or (par as Array).size() != 2:
		return false
	colocar(str((par as Array)[0]), str(ids[0]))
	colocar(str((par as Array)[1]), str(ids[1]))
	return true

func _recalcular_emisores() -> void:
	if sala == null:
		return
	var ok: bool = pareja_correcta()
	for pid in pedestales:
		var e: int = emisor_de_pedestal(str(pid))
		if e >= 0:
			sala.set_emisor(e, ok)

# --- Validacion -----------------------------------------------------------

## Valida el framework + la capa de simbolos. Devuelve [] si es coherente.
func validar() -> Array:
	var errores: Array = []
	errores.append_array(PuzzleDef.validar_def(def))
	if glifos.is_empty():
		errores.append("la familia de simbolos no declara glifos")
	for id in glifos:
		if not es_glifo_valido_m25(str(id)):
			errores.append("el glifo '%s' no respeta el contrato M25 (id + simbolos + significado)" % str(id))
	if parejas.is_empty():
		errores.append("la familia de simbolos no declara parejas")
	for p in parejas:
		if typeof(p) != TYPE_ARRAY or (p as Array).size() != 2:
			errores.append("pareja mal formada: %s" % str(p))
			continue
		for g in (p as Array):
			if not glifos.has(str(g)):
				errores.append("pareja cita glifo inexistente '%s'" % str(g))
	if not glosario_completo():
		errores.append("el glosario del templo no cubre todos los glifos (item 112)")
	var par_sello: Variant = sello.get("pareja", [])
	if typeof(par_sello) != TYPE_ARRAY or (par_sello as Array).size() != 2:
		errores.append("el sello no declara una pareja de 2 glifos")
	elif not es_pareja(str((par_sello as Array)[0]), str((par_sello as Array)[1])):
		errores.append("la pareja del sello no es una pareja declarada")
	if pedestales.is_empty():
		errores.append("la familia de simbolos no declara pedestales")
	var declarados: Array = PuzzleDef.ids_emisores(def)
	for pid in pedestales:
		var e: int = emisor_de_pedestal(str(pid))
		if not declarados.has(e):
			errores.append("el pedestal '%s' usa emisor inexistente %d" % [str(pid), e])
	return errores

# --- Helpers privados -----------------------------------------------------

func _misma_pareja(a: Array, b: Array) -> bool:
	if a.size() != b.size():
		return false
	var sa: Array = []
	for x in a:
		sa.append(str(x))
	var sb: Array = []
	for y in b:
		sb.append(str(y))
	sa.sort()
	sb.sort()
	for i in range(sa.size()):
		if sa[i] != sb[i]:
			return false
	return true
