# Modelo: Hy3
# Plataforma: WorkBuddy
# Fecha: 2026-09-01
#
# M162: ContextualDialogueManager — selector de diálogos contextuales.
#
# Dado un NPC y un tipo (SALUDO, HISTORIA, MISION, AMBIENTE, AMISTAD,
# ESTACIONAL, HORA), elige el grafo M21 adecuado según el contexto actual,
# aplicando PRIORIDAD + FALLBACK sobre registry.json.
#
# Las condiciones usan SOLO claves válidas de M21 (ver dialog_graph_validator.gd
# -> CLAVES_MUNDO_BASE):
#   flag_capitulo (int 0-7)  <- lo fija M22 al avanzar capítulo
#   estacion                  <- M29
#   hora / es_de_dia / es_noche / dia / mes / clima   <- M29
#   amistad_<slug> (int 0-100)   <- M20
#   flag_ubicacion_<loc>     <- M160/M19 (jugador entra a ubicación)
#   flag_quest_<id>           <- M22/quests
#   flag_* (cualquiera)      <- banderas persistentes de WorldState
#
# No es un autoload: se usa como RefCounted (.new()) desde el sistema de
# interacción / diálogo, para no tocar la configuración de otros módulos.

class_name ContextualDialogueManager
extends RefCounted

const REGISTRY_PATH := "res://data/dialogues/contextual/registry.json"
const DIR_GRAFOS := "res://data/dialogues/contextual/"

## Selecciona el grafo M21 para npc_id + tipo con el contexto dado.
## contexto: Dictionary con variables de mundo (claves M21 arriba).
## Devuelve {ok, graph, entry, error}.
static func seleccionar(npc_id: String, tipo: String, contexto: Dictionary) -> Dictionary:
	var reg := _cargar_registry()
	if reg.is_empty():
		return {"ok": false, "error": "registry no encontrado", "graph": {}, "entry": {}}
	var slug := _slug_de(reg, npc_id)
	if slug == "":
		return {"ok": false, "error": "npc no registrado: " + npc_id, "graph": {}, "entry": {}}
	var entries: Array = reg.get("entries", [])
	var mejor := {}
	var mejor_prio := -1
	for e in entries:
		if e.get("npc") != slug:
			continue
		if e.get("tipo") != tipo:
			continue
		if not _cumple(e.get("condiciones", []), contexto):
			continue
		var p: int = int(e.get("prioridad", 0))
		if p > mejor_prio:
			mejor_prio = p
			mejor = e
	if mejor.is_empty():
		mejor = _fallback(reg, slug, tipo)
	if mejor.is_empty():
		return {"ok": false, "error": "sin diálogo para %s/%s" % [slug, tipo], "graph": {}, "entry": {}}
	var grafo := _cargar_grafo(mejor)
	if grafo.is_empty():
		return {"ok": false, "error": "grafo no cargado: " + str(mejor.get("graph")), "graph": {}, "entry": mejor}
	return {"ok": true, "graph": grafo, "entry": mejor}


## Evalúa una lista de condiciones contra el contexto (misma semántica que
## DialogueNode._evalua_cond: operadores == != >= <= > <).
static func _cumple(conds: Array, ctx: Dictionary) -> bool:
	for c in conds:
		if not (c is Dictionary):
			continue
		var clave: String = str(c.get("clave", ""))
		var op: String = str(c.get("operador", "=="))
		var val = c.get("valor", null)
		if not ctx.has(clave):
			return false
		var actual = ctx[clave]
		match op:
			"==":
				if actual != val:
					return false
			"!=":
				if actual == val:
					return false
			">=":
				if float(actual) < float(val):
					return false
			"<=":
				if float(actual) > float(val):
					return false
			">":
				if float(actual) <= float(val):
					return false
			"<":
				if float(actual) >= float(val):
					return false
	return true


## Fallback: entrada del mismo NPC+tipo con MENOS condiciones (más genérica).
## Si hay empate de condiciones, la de mayor prioridad.
static func _fallback(reg: Dictionary, slug: String, tipo: String) -> Dictionary:
	var candidatos: Array = []
	for e in reg.get("entries", []):
		if e.get("npc") == slug and e.get("tipo") == tipo:
			candidatos.append(e)
	if candidatos.is_empty():
		return {}
	candidatos.sort_custom(
		func(a, b):
			var ca: int = a.get("condiciones", []).size()
			var cb: int = b.get("condiciones", []).size()
			if ca != cb:
				return ca < cb
			return int(a.get("prioridad", 0)) > int(b.get("prioridad", 0))
	)
	return candidatos[0]


static func _slug_de(reg: Dictionary, npc_id: String) -> String:
	var npcs: Dictionary = reg.get("npcs", {})
	if npcs.has(npc_id):
		return npc_id
	for s in npcs.keys():
		if str(npcs[s].get("npc_id", "")) == npc_id:
			return s
	return ""


static func _cargar_registry() -> Dictionary:
	var f := FileAccess.open(REGISTRY_PATH, FileAccess.READ)
	if f == null:
		return {}
	var texto := f.get_as_text()
	f.close()
	var datos = JSON.parse_string(texto)
	return datos if datos is Dictionary else {}


static func _cargar_grafo(entry: Dictionary) -> Dictionary:
	var fname: String = str(entry.get("graph", ""))
	if fname == "":
		return {}
	var f := FileAccess.open(DIR_GRAFOS + fname, FileAccess.READ)
	if f == null:
		return {}
	var texto := f.get_as_text()
	f.close()
	var datos = JSON.parse_string(texto)
	return datos if datos is Dictionary else {}
