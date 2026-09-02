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
## M20 -> M21: reaccion del NPC a un regalo, por clase exacta de GiftEvaluator.Clase.
## La UI (cuando exista) muestra expresion + texto a partir de reaccion_id.
signal gift_reaction(npc_id: String, reaccion_id: String, clase: int, item_id: String, expresion: String)
## M20 -> M21: el NPC subio de nivel de amistad (reaccion de dialogo opcional).
signal level_up_reaction(npc_id: String, new_level: int)

const CARPETA_DIALOGOS := "res://data/dialogues/"

## M20 -> M21: mapeo de GiftEvaluator.Clase (0=AMADO, 1=GUSTA, 2=NEUTRAL, 3=DUPLICADO)
## a una reaccion de dialogo (id + expresion + texto_key). El texto se localiza en M87.
const REACCION_REGALO := {
	0: {"id": "R_AMADO", "expresion": "feliz_intenso", "texto": "REACCION_REGALO_AMADO"},
	1: {"id": "R_GUSTA", "expresion": "feliz", "texto": "REACCION_REGALO_GUSTA"},
	2: {"id": "R_NEUTRAL", "expresion": "neutral", "texto": "REACCION_REGALO_NEUTRAL"},
	3: {"id": "R_DUPLICADO", "expresion": "neutral", "texto": "REACCION_REGALO_DUPLICADO"},
}

## M20 -> M21 (L82): ids de los grafos de dialogo breve de evento disparados por
## gift_reaction / level_up_reaction. Los grafos viven en data/dialogues/.
const REACCION_REGALO_DIALOGO := "reaccion_regalo"
const REACCION_NIVEL_DIALOGO := "reaccion_nivel"

## M20 -> M21: ultima reaccion de regalo por NPC (contexto para diálogos
## subsiguientes). Clave = npc_id. Valor = {id, expresion, texto, item_id}.
var _ultima_reaccion_regalo: Dictionary = {}

func _ready() -> void:
	var bus: Node = get_node_or_null("/root/EventBus")
	if bus != null and bus.npc != null:
		if bus.npc.has_signal("gift_given") and not bus.npc.gift_given.is_connected(_on_gift_given):
			bus.npc.gift_given.connect(_on_gift_given)
		if bus.npc.has_signal("friendship_level_up") and not bus.npc.friendship_level_up.is_connected(_on_level_up):
			bus.npc.friendship_level_up.connect(_on_level_up)

## M20 -> M21: traduce la clase exacta del regalo a una reaccion de dialogo
## (id + expresion + texto_key) y la emite para que la UI la muestre.
func _on_gift_given(npc_id: String, item_id: String, clase: int) -> void:
	if not REACCION_REGALO.has(clase):
		return
	var r: Dictionary = REACCION_REGALO[clase]
	_ultima_reaccion_regalo[npc_id] = {
		"id": r["id"], "expresion": r["expresion"], "texto": r["texto"], "item_id": item_id,
	}
	gift_reaction.emit(npc_id, r["id"], clase, item_id, r["expresion"])
	# L82: escena breve de evento con dialogo (M21). Solo si no hay otro dialogo activo.
	if not is_dialogue_active():
		start_dialogue(REACCION_REGALO_DIALOGO,
			{"npc_id": npc_id, "reaccion_id": r["id"], "item_id": item_id})

## M20 -> M21: el NPC subio de nivel de amistad; la UI puede reaccionar.
func _on_level_up(npc_id: String, new_level: int) -> void:
	level_up_reaction.emit(npc_id, new_level)
	# L82: escena breve de evento con dialogo (M21). Solo si no hay otro dialogo activo.
	if not is_dialogue_active():
		start_dialogue(REACCION_NIVEL_DIALOGO, {"npc_id": npc_id, "new_level": new_level})

## M20 -> M21: consulta la ultima reaccion de regalo de un NPC (o {} si no hay).
func get_ultima_reaccion_regalo(npc_id: String) -> Dictionary:
	return _ultima_reaccion_regalo.get(npc_id, {})

var _grafo_actual: DialogueGraph = null
var _nodo_actual: DialogueNode = null
var _dialogue_id: String = ""
var _session_vars: Dictionary = {}
var _grafos_cache: Dictionary = {}

## M21 (iter 7): cache del script DialogGraphValidator para validacion estatica en
## start_dialogue. Sin anotacion de tipo (class_name de otro script no compila en
## headless, ver 07-GUIA-GODOT.md §9.50); se resuelve con load() en runtime.
var _validador_script = null

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
	# M21 (iter 8 / Hy3 WorkBuddy): validacion estatica complementaria (nodos huerfanos,
	# operadores de condicion y claves de mundo). Ahora SI se chequean claves desconocidas
	# usando la allowlist canonica del validador (incluye "clima"), para detectar typos como
	# "climaX" en runtime y no solo en CI. Esto cierra el [?] F.11 de condiciones de clima.
	var vprob: Array = _obtener_validador_script().validar(grafo, _obtener_validador_script().CLAVES_MUNDO_BASE)
	if not vprob.is_empty():
		for p in vprob:
			push_error("[VAL-DGV] " + str(p))
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

## M21 (iter 10 / Hy3 WorkBuddy): estado de tipeo. La UI lo setea via set_tipeando()
## para que advance() respete el texto en curso (RF4 / [?] D.3: "advance() que respeta
## tipeo activo"). El manager es capa sin UI, asi que delega el flag a quien lo consume.
var _tipeando: bool = false

func set_tipeando(valor: bool) -> void:
	_tipeando = valor

func advance() -> void:
	if not is_dialogue_active() or _nodo_actual == null:
		return
	# Si la UI esta tipeando, el avance inmediato no debe saltar la linea:
	# la UI completa el texto primero y vuelve a llamar advance() con _tipeando=false.
	if _tipeando:
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
	var loc = null
	if is_inside_tree():
		loc = get_node_or_null("/root/Localization")
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
	# M21 (iter 9 / Hy3 WorkBuddy): evaluacion en lote con get_snapshot (una sola
	# lectura de WorldStateService en vez de N llamadas get_value). Cierra [?] F/I.9.
	if ws.has_method("get_snapshot"):
		var snap: Dictionary = ws.get_snapshot(claves_a_resolver)
		for clave in snap.keys():
			if not estado.has(clave):
				estado[clave] = snap[clave]
	else:
		for clave in claves_a_resolver:
			if not estado.has(clave):
				estado[clave] = ws.get_value(clave)
	return estado

func avance_evento() -> void:
	advance()

## M21 (iter 7): cachea y devuelve el script DialogGraphValidator (load en runtime,
## evita dependencia de parse-time / §9.50).
func _obtener_validador_script():
	if _validador_script == null:
		_validador_script = load("res://scripts/dialogos/dialog_graph_validator.gd")
	return _validador_script

## M21 (iter 7): salto rapido (fast-skip). Avanza automaticamente por nodos de LINEA
## y EVENTO aplicando sus efectos, hasta detenerse en un nodo de OPCIONES (el jugador
## debe elegir) o llegar a un FIN (termina el dialogo). NO salta decisiones: se queda
## en la primera bifurcacion para que el jugador elija. Usado por la UI (KEY_ESCAPE).
func skip_all() -> void:
	if not is_dialogue_active() or _nodo_actual == null:
		return
	var guard := 0
	while is_dialogue_active() and _nodo_actual != null and guard < 9999:
		guard += 1
		if _nodo_actual.tipo == DialogueNode.TIPO_OPCIONES:
			return  # se detiene en la eleccion: el jugador elige
		if _nodo_actual.tipo == DialogueNode.TIPO_FIN:
			stop_dialogue()
			return
		advance()  # LINEA o EVENTO: avanzar (los efectos ya se aplicaron al entrar)
	if is_dialogue_active():
		stop_dialogue()  # salvaguarda ante grafos ciclicos sin FIN
