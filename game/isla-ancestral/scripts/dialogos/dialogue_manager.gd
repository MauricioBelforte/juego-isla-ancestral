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
	var estado_combinado := _combinar_estado(_nodo_actual)
	_nodo_actual.apply_effects(_session_vars, estado_combinado)
	if opcion is DialogueOption and opcion.effect.size() > 0:
		opcion.apply_effects(_session_vars, estado_combinado)
	option_selected.emit(index)
	if opcion.next_id != "" and _grafo_actual.nodes.has(opcion.next_id):
		_entrar_nodo(_grafo_actual.nodes[opcion.next_id])
	else:
		stop_dialogue()

func get_current_speaker_key() -> String:
	return _nodo_actual.speaker_key if _nodo_actual else ""

func get_current_text_key() -> String:
	return _nodo_actual.text_key if _nodo_actual else ""

## Resuelve texto: claves -> valores del contexto de sesion.
## Si el texto es una clave de localización (M87), se traduce con
## Localization.traducir_clave; los placeholders {clave} se resuelven después.
func resolve_text(texto: String, placeholders: Dictionary) -> String:
	var loc = get_node_or_null("/root/Localization")
	if loc != null and loc.has_method("traducir_clave") and _es_clave_localizacion(texto):
		var n := int(placeholders.get("n", -1)) if placeholders.has("n") else -1
		texto = loc.traducir_clave(texto, {}, n)
	var resultado := texto
	for clave in placeholders:
		var marcador := "{" + str(clave) + "}"
		if _session_vars.has(clave):
			resultado = resultado.replace(marcador, str(_session_vars[clave]))
		else:
			resultado = resultado.replace(marcador, str(placeholders[clave]))
	return resultado

## Heurística de clave de localización: MAYÚSCULAS + sin espacios + al menos un punto.
func _es_clave_localizacion(texto: String) -> bool:
	return texto.to_upper() == texto and not texto.contains(" ") and texto.contains(".")

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
	# M21 RF5: evaluar condiciones contra estado combinado (sesion + mundo).
	var estado_combinado := _combinar_estado(nodo)
	if not nodo.evaluate_conditions(estado_combinado):
		# Condicion no cumplida: saltar al siguiente si existe, si no avanzar.
		var siguiente := nodo.next_id if nodo.next_id != "" else nodo.goto_id
		if siguiente != "" and _grafo_actual.nodes.has(siguiente):
			_entrar_nodo(_grafo_actual.nodes[siguiente])
		else:
			advance()
		return
	_nodo_actual = nodo
	nodo.apply_effects(_session_vars, estado_combinado)
	var texto_resuelto := resolve_text(nodo.text_key, nodo.placeholders)
	node_entered.emit(nodo.id, nodo.speaker_key, texto_resuelto, nodo.tipo, nodo.options)
	if nodo.tipo == DialogueNode.TIPO_EVENTO:
		avance_evento()
	elif nodo.tipo == DialogueNode.TIPO_FIN:
		stop_dialogue()
	elif nodo.tipo == DialogueNode.TIPO_LINEA:
		line_complete.emit()

## Combina variables de sesion con el estado del mundo (WorldStateService)
## para evaluar condiciones. Las variables de sesion tienen prioridad.
## `nodo` es opcional: si se pasa, se resuelven tambien las claves de sus
## condiciones y opciones (incluye prefijos amistad_*/flag_*).
func _combinar_estado(nodo: DialogueNode = null) -> Dictionary:
	var estado := _session_vars.duplicate()
	# Si el manager no esta en el arbol (tests headless), no consultar autoloads.
	if not is_inside_tree():
		return estado
	var ws = get_node_or_null("/root/WorldState")
	if ws == null or not ws.has_method("get_value"):
		return estado
	var claves_a_resolver: Array = [
		"hora", "minuto", "dia", "mes", "anio", "estacion",
		"es_de_dia", "es_noche", "dia_absoluto", "clima",
	]
	if nodo != null:
		for cond in nodo.conditions:
			var clave_cond: String = str(cond.get("clave", ""))
			if clave_cond != "" and not claves_a_resolver.has(clave_cond):
				claves_a_resolver.append(clave_cond)
		for op in nodo.options:
			if op is DialogueOption:
				for cond in op.conditions:
					var clave_op: String = str(cond.get("clave", ""))
					if clave_op != "" and not claves_a_resolver.has(clave_op):
						claves_a_resolver.append(clave_op)
	for clave in claves_a_resolver:
		if not estado.has(clave):
			estado[clave] = ws.get_value(clave)
	return estado

func avance_evento() -> void:
	advance()
