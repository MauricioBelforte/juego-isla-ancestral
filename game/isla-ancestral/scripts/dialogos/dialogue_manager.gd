# Modelo: Hy3
# Plataforma: Kilo
# Fecha: 2026-08-29
#
# M21: DialogueManager — autoload de la maquina de dialogo (capa sin UI).
# Se comunica con la UI por senales: dialogue_started/node_entered/line_complete/
# option_selected/dialogue_ended. La UI (M53 o DialogUI minimal) solo recibe.

extends Node

signal dialogue_started(dialogue_id: String)
signal dialogue_ended(dialogue_id: String, last_node_id: String)
signal node_entered(node_id: String, speaker_key: String, text: String, tipo: int, options: Array)
signal line_complete()
signal option_selected(option_index: int)

const CARPETA_DIALOGOS := "res://data/dialogues/"

var _grafo_actual: DialogueGraph = null
var _nodo_actual: DialogueNode = null
var _dialogue_id: String = ""
var _session_vars: Dictionary = {}
var _grafos_cache: Dictionary = {}

func is_dialogue_active() -> bool:
	return _nodo_actual != null

func start_dialogue(dialogue_id: String, context: Dictionary = {}) -> bool:
	if is_dialogue_active():
		push_warning("[M21] Dialogo ya activo: " + _dialogue_id)
		return false
	var grafo := _cargar_grafo(dialogue_id)
	if grafo == null or grafo.nodes.is_empty():
		return false
	var problemas: Array = grafo.validate()
	if not problemas.is_empty():
		for prob in problemas:
			push_error("[VAL-DGT] " + str(prob))
		return false
	_dialogue_id = dialogue_id
	_grafo_actual = grafo
	_session_vars = context.duplicate()
	dialogue_started.emit(dialogue_id)
	_entrar_nodo(grafo.get_start_node())
	return true

func stop_dialogue() -> void:
	if not is_dialogue_active():
		return
	var ultimo := _nodo_actual.id
	_nodo_actual = null
	_grafo_actual = null
	dialogue_ended.emit(_dialogue_id, ultimo)

func advance() -> void:
	if not is_dialogue_active() or _nodo_actual == null:
		return
	var siguiente := _nodo_actual.next_id
	if siguiente == "":
		siguiente = _nodo_actual.goto_id
	if siguiente != "" and _grafo_actual.nodes.has(siguiente):
		_entrar_nodo(_grafo_actual.nodes[siguiente])
	else:
		stop_dialogue()

func choose_option(index: int) -> void:
	if not is_dialogue_active() or _nodo_actual == null:
		return
	if index < 0 or index >= _nodo_actual.options.size():
		return
	var opcion = _nodo_actual.options[index]
	_nodo_actual.apply_effects(_session_vars)
	option_selected.emit(index)
	if opcion.next_id != "" and _grafo_actual.nodes.has(opcion.next_id):
		_entrar_nodo(_grafo_actual.nodes[opcion.next_id])
	else:
		stop_dialogue()

func get_current_speaker_key() -> String:
	return _nodo_actual.speaker_key if _nodo_actual else ""

func get_current_text_key() -> String:
	return _nodo_actual.text_key if _nodo_actual else ""

## Resuelve texto: claves -> valores del contexto de sesion
func resolve_text(texto: String, placeholders: Dictionary) -> String:
	var resultado := texto
	for clave in placeholders:
		var marcador := "{" + str(clave) + "}"
		if _session_vars.has(clave):
			resultado = resultado.replace(marcador, str(_session_vars[clave]))
		else:
			resultado = resultado.replace(marcador, str(placeholders[clave]))
	return resultado

func get_session_vars() -> Dictionary:
	return _session_vars

func _cargar_grafo(dialogue_id: String) -> DialogueGraph:
	if _grafos_cache.has(dialogue_id):
		return _grafos_cache[dialogue_id]
	var grafo := DialogueGraph.load_from_json(CARPETA_DIALOGOS + dialogue_id + ".json")
	if not grafo.nodes.is_empty():
		_grafos_cache[dialogue_id] = grafo
	return grafo

func _entrar_nodo(nodo: DialogueNode) -> void:
	if nodo == null:
		stop_dialogue()
		return
	_nodo_actual = nodo
	nodo.apply_effects(_session_vars)
	var texto_resuelto := resolve_text(nodo.text_key, nodo.placeholders)
	node_entered.emit(nodo.id, nodo.speaker_key, texto_resuelto, nodo.tipo, nodo.options)
	if nodo.tipo == DialogueNode.TIPO_EVENTO:
		avance_evento()
	elif nodo.tipo == DialogueNode.TIPO_FIN:
		stop_dialogue()
	elif nodo.tipo == DialogueNode.TIPO_LINEA:
		line_complete.emit()

func avance_evento() -> void:
	advance()
