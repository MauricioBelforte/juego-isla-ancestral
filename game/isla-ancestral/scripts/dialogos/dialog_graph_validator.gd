# Modelo: Hy3
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M21: DialogGraphValidator — validacion estatica de grafos de dialogo.
# Complementa DialogueGraph.validate() (que ya chequea next/goto inexistentes,
# OPCIONES sin opciones y FIN alcanzable). Este validador agrega:
#   - nodos huerfanos (inaccesibles desde start por next/goto/opciones),
#   - operadores de condicion invalidos,
#   - claves de WorldStateService desconocidas (si se pasa un allowlist).
#
# NOTA: los parametros no llevan anotacion de tipo (class_name de otro script) para
# evitar el Parse Error en headless (ver 07-GUIA-GODOT.md §9.50). Se usa duck-typing;
# DialogueGraph/DialogueNode ya estan compilados en el proyecto (los tests los usan).

extends RefCounted

class_name DialogGraphValidator

const OPERADORES_VALIDOS := ["==", "!=", ">=", "<=", ">", "<"]

## Allowlist canonical de claves de mundo soportadas por WorldStateService (M21).
## Fuente unica de verdad: world_state_service.gd documenta estas claves.
## - claves escalares: hora, minuto, dia, mes, anio, estacion, es_de_dia, es_noche, dia_absoluto, clima
## - claves con sufijo por entidad: amistad_<npc_id>, flag_<clave>
## Las claves con sufijo se reconstruyen en _clave_conocida() (prefijo + "_").
const CLAVES_MUNDO_BASE := [
	"hora", "minuto", "dia", "mes", "anio", "estacion",
	"es_de_dia", "es_noche", "dia_absoluto", "clima",
	"amistad_", "flag_"
]

## Devuelve true si la clave es reconocida por WorldStateService (prefijo o exacta).
static func _clave_conocida(clave: String, allowlist: Array) -> bool:
	if allowlist.has(clave):
		return true
	for pref in allowlist:
		if str(pref).ends_with("_") and clave.begins_with(str(pref)):
			return true
	return false

## Valida un DialogueGraph ya cargado.
## claves_mundo: Array de claves validas de WorldStateService (opcional). Si esta vacio,
## NO se chequean claves de mundo desconocidas (solo se valida la sintaxis de la condicion).
## Devuelve Array de Strings (problemas). Vacio = grafo valido.
static func validar(grafo, claves_mundo: Array = []) -> Array:
	var problemas: Array = []
	if grafo == null:
		problemas.append("grafo nulo")
		return problemas
	if grafo.start_node_id == "":
		problemas.append("sin nodo de inicio (start)")
		return problemas
	if not grafo.nodes.has(grafo.start_node_id):
		problemas.append("el nodo de inicio '%s' no existe" % grafo.start_node_id)
		return problemas
	# nodos huerfanos (no alcanzables desde start por next/goto/opciones)
	var alcanzables := _alcanzables(grafo)
	for id_nodo in grafo.nodes:
		if not alcanzables.has(id_nodo):
			problemas.append("nodo huérfano (inaccesible desde start): '%s'" % id_nodo)
	# operadores de condicion invalidos + claves de mundo desconocidas
	for id_nodo in grafo.nodes:
		var nodo = grafo.nodes[id_nodo]
		for cond in nodo.conditions:
			_validar_cond(cond, id_nodo, claves_mundo, problemas)
		for opcion in nodo.options:
			for cond in _opcion_conds(opcion):
				_validar_cond(cond, id_nodo, claves_mundo, problemas)
	return problemas

## BFS desde start siguiendo next_id / goto_id / next_id de opciones.
static func _alcanzables(grafo) -> Dictionary:
	var visitados := {}
	var cola := [grafo.start_node_id]
	while not cola.is_empty():
		var id_actual: String = cola.pop_front()
		if visitados.has(id_actual):
			continue
		visitados[id_actual] = true
		var nodo = grafo.nodes.get(id_actual, null)
		if nodo == null:
			continue
		if nodo.next_id != "" and grafo.nodes.has(nodo.next_id):
			cola.append(nodo.next_id)
		if nodo.goto_id != "" and grafo.nodes.has(nodo.goto_id):
			cola.append(nodo.goto_id)
		for opcion in nodo.options:
			var nid := _opcion_next_id(opcion)
			if nid != "" and grafo.nodes.has(nid):
				cola.append(nid)
	return visitados

## Extrae el next_id de una opcion, sea DialogueOption o un Dictionary crudo
## (el formato que produce validar_texto al leer JSON).
static func _opcion_next_id(opcion) -> String:
	if opcion is DialogueOption:
		return opcion.next_id
	if opcion is Dictionary:
		return str(opcion.get("next_id", ""))
	return ""

## Extrae las condiciones de una opcion (Array de diccionarios), sea DialogueOption
## o un Dictionary crudo. Devuelve [] si no tiene condiciones (evita el error de
## acceder a '.conditions' sobre un Dictionary sin esa clave).
static func _opcion_conds(opcion) -> Array:
	if opcion is DialogueOption:
		return opcion.conditions
	if opcion is Dictionary:
		var c = opcion.get("conditions", [])
		return c if c is Array else []
	return []

static func _validar_cond(cond, id_nodo: String, claves_mundo: Array, problemas: Array) -> void:
	if not cond is Dictionary:
		problemas.append("nodo '%s': condicion no es un diccionario" % id_nodo)
		return
	var op: String = str(cond.get("operador", "=="))
	if not OPERADORES_VALIDOS.has(op):
		problemas.append("nodo '%s': operador de condicion invalido '%s'" % [id_nodo, op])
	# Si no se pasa allowlist explicita, usamos la base documentada (validacion siempre activa).
	var allowlist: Array = claves_mundo if not claves_mundo.is_empty() else CLAVES_MUNDO_BASE
	var clave: String = str(cond.get("clave", ""))
	if clave != "" and not _clave_conocida(clave, allowlist):
		problemas.append("nodo '%s': condicion usa clave de mundo desconocida '%s'" % [id_nodo, clave])

## Igual que validar_archivo pero recibe el texto JSON directamente (util para CI/plugins,
## o para validar sin tocar el disco). Construye el grafo desde el dict parseado.
static func validar_texto(texto: String, claves_mundo: Array = []) -> Dictionary:
	var datos = JSON.parse_string(texto)
	if datos == null or not datos is Dictionary:
		return {"ok": false, "error": "JSON invalido", "problemas": []}
	var grafo = DialogueGraph.new()
	grafo.dialogue_id = str(datos.get("id", ""))
	grafo.start_node_id = str(datos.get("start", ""))
	var nodos_datos: Dictionary = datos.get("nodes", {})
	for id_nodo in nodos_datos:
		var nd: Dictionary = nodos_datos[id_nodo]
		var nodo := DialogueNode.new()
		nodo.id = str(id_nodo)
		nodo.tipo = int(nd.get("tipo", DialogueNode.TIPO_LINEA))
		nodo.speaker_key = str(nd.get("speaker_key", ""))
		nodo.text_key = str(nd.get("text_key", ""))
		nodo.conditions = nd.get("conditions", [])
		nodo.next_id = str(nd.get("next_id", ""))
		nodo.goto_id = str(nd.get("goto_id", ""))
		nodo.options = nd.get("options", [])
		grafo.nodes[nodo.id] = nodo
	var problemas := validar(grafo, claves_mundo)
	return {"ok": problemas.is_empty(), "error": "", "problemas": problemas}

## Valida un archivo JSON de dialogo. Devuelve Dictionary {ok: bool, error: String, problemas: Array}.
## Para JSON malformado reporta error (sin linea/columna: Godot JSON.parse_string no
## expone posicion; limitacion conocida — ver 04-Codigo.md M21 iter 6).
static func validar_archivo(path: String, claves_mundo: Array = []) -> Dictionary:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {"ok": false, "error": "no se pudo abrir: " + path, "problemas": []}
	return validar_texto(f.get_as_text(), claves_mundo)
