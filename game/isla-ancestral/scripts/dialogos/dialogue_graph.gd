# Modelo: Hy3
# Plataforma: Kilo
# Fecha: 2026-08-29
#
# M21: DialogueGraph — grafo de dialogo cargado desde JSON, con validador estatico.

## Grafo de dialogo: nodos, inicio y validacion estatica.
class_name DialogueGraph
extends Resource

@export var dialogue_id: String = ""
@export var start_node_id: String = ""
@export var nodes: Dictionary = {}

## Carga un grafo desde un JSON:
## { "id": "...", "start": "...", "nodes": { "n1": {tipo, speaker_key, text_key, ...} } }
static func load_from_json(path: String) -> DialogueGraph:
	var grafo := DialogueGraph.new()
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("[M21] No se pudo abrir el dialogo: " + path)
		return grafo
	var datos: Dictionary = JSON.parse_string(f.get_as_text())
	if datos == null or not datos is Dictionary:
		push_error("[M21] JSON invalido: " + path)
		return grafo
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
		nodo.placeholders = nd.get("placeholders", {})
		nodo.conditions = nd.get("conditions", [])
		nodo.effects = nd.get("effects", [])
		nodo.next_id = str(nd.get("next_id", ""))
		nodo.goto_id = str(nd.get("goto_id", ""))
		for op in nd.get("options", []):
			var opcion := DialogueOption.new()
			opcion.text_key = str(op.get("text_key", ""))
			opcion.next_id = str(op.get("next_id", ""))
			opcion.conditions = op.get("conditions", [])
			opcion.blocked_text_key = str(op.get("blocked_text_key", ""))
			opcion.effect = op.get("effect", [])
			nodo.options.append(opcion)
		grafo.nodes[nodo.id] = nodo
	return grafo

func get_start_node() -> DialogueNode:
	return get_node_by_id(start_node_id)

func get_node_by_id(id: String) -> DialogueNode:
	return nodes.get(id, null)

## Validacion estatica: devuelve lista de problemas (String).
## Grafo valido => lista vacia.
func validate() -> Array:
	var problemas: Array = []
	if start_node_id == "":
		problemas.append("sin nodo de inicio")
		return problemas
	if not nodes.has(start_node_id):
		problemas.append("el nodo de inicio '%s' no existe" % start_node_id)
	# ids duplicados / next / goto / opciones
	for id_nodo in nodes:
		var nodo: DialogueNode = nodes[id_nodo]
		if nodo.next_id != "" and not nodes.has(nodo.next_id):
			problemas.append("'%s' apunta a next inexistente '%s'" % [id_nodo, nodo.next_id])
		if nodo.goto_id != "" and not nodes.has(nodo.goto_id):
			problemas.append("'%s' apunta a goto inexistente '%s'" % [id_nodo, nodo.goto_id])
		if nodo.tipo == DialogueNode.TIPO_OPCIONES and nodo.options.is_empty():
			problemas.append("nodo OPCIONES '%s' sin opciones" % id_nodo)
		for opcion in nodo.options:
			if opcion.next_id != "" and not nodes.has(opcion.next_id):
				problemas.append("opcion de '%s' apunta a next inexistente '%s'" % [id_nodo, opcion.next_id])
	# ciclos: nodo FIN inalcanzable (advertencia, no error — se reporta como problema suave)
	var alcanza_fin := false
	for id_nodo in nodes:
		if nodes[id_nodo].tipo == DialogueNode.TIPO_FIN:
			alcanza_fin = true
	if not alcanza_fin and nodes.size() > 0:
		problemas.append("el grafo no tiene nodo FIN (posible ciclo sin salida)")
	return problemas
