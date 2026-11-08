extends SceneTree

## Hy3 — verificacion Sec21.8 (verificador != autor) de PLAYBACK de dialogos.
## Capstone de la trilogia de logica de M21 (validacion estatica 2358/2359,
## evaluador de condiciones 2360, efectos 2362).
##
## La validacion estatica garantiza "sin nodos huerfanos" (todos alcanzables
## desde start) pero NO que el grafo TERMINA: un ciclo sin salida pasaria la
## validacion y seria imposible de jugar. Esta prueba hace BFS desde start y
## exige al menos un nodo terminal alcanzable (FIN / punto de opciones / linea
## sin continuacion), con conjunto de visitados para descartar ciclos infinitos.
##
## Cubre los 8 JSON sueltos de NPC de la raiz de data/dialogues (los mismos que
## valida el gate CI del log 2359).

const TIPO_FIN := 3

func _initialize() -> void:
	call_deferred("_ejecutar")

func _build_graph(texto: String) -> DialogueGraph:
	var datos = JSON.parse_string(texto)
	if datos == null or not datos is Dictionary:
		return null
	var grafo := DialogueGraph.new()
	grafo.dialogue_id = str(datos.get("id", ""))
	grafo.start_node_id = str(datos.get("start", ""))
	var nodos_datos: Dictionary = datos.get("nodes", {})
	for id_nodo in nodos_datos:
		var nd: Dictionary = nodos_datos[id_nodo]
		var nodo := DialogueNode.new()
		nodo.id = str(id_nodo)
		nodo.tipo = int(nd.get("tipo", 0))
		nodo.next_id = str(nd.get("next_id", ""))
		nodo.goto_id = str(nd.get("goto_id", ""))
		nodo.options = nd.get("options", [])
		grafo.nodes[nodo.id] = nodo
	return grafo

func _es_terminal(nodo) -> bool:
	if nodo == null:
		return false
	if nodo.tipo == TIPO_FIN:
		return true
	if nodo.next_id == "" and (nodo.options == null or nodo.options.is_empty()):
		return true
	return false

func _hay_terminal_alcanzable(grafo: DialogueGraph) -> bool:
	if grafo == null:
		return false
	var start: String = grafo.start_node_id
	if not grafo.nodes.has(start):
		return false
	if _es_terminal(grafo.nodes[start]):
		return true
	var visitados := {}
	var cola := [start]
	while not cola.is_empty():
		var id_actual: String = cola.pop_front()
		if visitados.has(id_actual):
			continue
		visitados[id_actual] = true
		var nodo = grafo.nodes.get(id_actual, null)
		if nodo == null:
			continue
		var siguientes := []
		if nodo.next_id != "" and grafo.nodes.has(nodo.next_id):
			siguientes.append(nodo.next_id)
		if nodo.goto_id != "" and grafo.nodes.has(nodo.goto_id):
			siguientes.append(nodo.goto_id)
		for op in nodo.options:
			var nid := ""
			if op is Dictionary:
				nid = str(op.get("next_id", ""))
			if nid != "" and grafo.nodes.has(nid):
				siguientes.append(nid)
		for sg in siguientes:
			var sn = grafo.nodes[sg]
			if _es_terminal(sn):
				return true
			if not visitados.has(sg):
				cola.append(sg)
	return false

func _ejecutar() -> void:
	var fallos := 0
	var chequeos := 0
	var archivos := [
		"res://data/dialogues/catalina_hola.json",
		"res://data/dialogues/shaman_intro.json",
		"res://data/dialogues/shaman_regreso.json",
		"res://data/dialogues/shaman_todas.json",
		"res://data/dialogues/finneas_slice.json",
		"res://data/dialogues/reaccion_nivel.json",
		"res://data/dialogues/reaccion_regalo.json",
		"res://data/dialogues/ejemplo_localizado_m21.json"
	]
	for path in archivos:
		chequeos += 1
		var f := FileAccess.open(path, FileAccess.READ)
		if f == null:
			fallos += 1
			printerr("FALLO abrir: " + path)
			continue
		var texto := f.get_as_text()
		f.close()
		var grafo := _build_graph(texto)
		if not _hay_terminal_alcanzable(grafo):
			fallos += 1
			printerr("FALLO playback: " + path + " no alcanza un FIN/terminal desde start (ciclo sin salida?)")
	print("TEST HY3 PLAYBACK: %d archivo(s) | %d fallo(s)" % [chequeos, fallos])
	quit(2 if fallos > 0 else 0)
