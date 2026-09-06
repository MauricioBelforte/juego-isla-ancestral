extends Node

## Módulo 19: NPC y Vecinos — Hook de diálogo (conectado a M21 DialogueManager)
## M21: al solicitar diálogo, inicia el DialogueManager (autoload) con el
## dialogue_id del vecino.
## M162 (Hy3 / T-M162-003): si npc_id está seteado, resuelve el grafo
## contextualmente vía ContextualDialogueManager antes de usar dialogue_id fijo.

signal linea_solicitada(vecino: Node, clave_linea: String)
signal respuestas_disponibles(vecino: Node, respuestas: Array[String])
signal conversacion_terminada(vecino: Node, resumen: Dictionary)

## M162 (Hy3 / T-M162-003): id del NPC en el registry contextual (ej: "NPC-RIZ_005").
## Si está vacío, se deriva de obtener_perfil().npc_id del vecino.
@export var npc_id: String = ""

## ID del diálogo fijo en data/dialogues/ (ej: "catalina_hola"). Fallback si M162
## no resuelve un diálogo contextual para este NPC.
@export var dialogue_id: String = ""

## M162 (Hy3 / T-M162-003): selector de diálogos contextuales (M162).
const ContextualDialogueManagerScript = preload("res://scripts/dialogos/contextual_dialogue_manager.gd")

var _vecino: Node = null
var _en_conversacion: bool = false


func inicializar(vecino: Node) -> void:
	_vecino = vecino


## El jugador solicita diálogo → inicia el DialogueManager de M21.
## M162 (Hy3 / T-M162-003): si el NPC tiene registry contextual, resuelve el grafo
## por contexto (capítulo, amistad, estación, hora, banderas) y lo usa; si M162 no
## resuelve, cae al dialogue_id fijo.
func solicitar_dialogo() -> void:
	var dm = get_node_or_null("/root/DialogueManager")
	# ¿Ya está en diálogo? (consulta el manager como fuente de verdad — evita
	# quedarse bloqueado si el diálogo anterior no llegó al nodo FIN)
	if dm and dm.is_dialogue_active():
		return
	if _en_conversacion and dm == null:
		return
	# Placeholder M19 (emitir señal)
	var clave: String = "saludo"
	if _vecino and _vecino.has_method("obtener_estado_animo"):
		var estado: String = _vecino.obtener_estado_animo()
		if estado == "alegre":
			clave = "saludo_alegre"
		elif estado == "triste":
			clave = "saludo_triste"
	linea_solicitada.emit(_vecino, clave)
	var nombre: String = _vecino.name if _vecino else "?"
	print("[DialogueHook] %s solicita diálogo: %s" % [nombre, clave])

	# M162 (Hy3 / T-M162-003): resolver grafo contextual; fallback a dialogue_id fijo.
	var graph_id := _resolver_dialogue_id()
	if graph_id == "":
		graph_id = dialogue_id

	# M21: iniciar el DialogueManager (autoload) con el grafo resuelto.
	if graph_id != "" and dm:
		_en_conversacion = true
		var ok: bool = dm.start_dialogue(graph_id, {"nombre_viajero": nombre})
		if ok:
			dm.dialogue_ended.connect(_on_m21_terminado, CONNECT_ONE_SHOT)
		else:
			_en_conversacion = false
			print("[DialogueHook] No se pudo iniciar diálogo: %s (grafo inválido?)" % graph_id)
			# No es necesario resincronizar si el manager rechazó; será re-intentable


## ── M162 (Hy3 / T-M162-003): resolución contextual de diálogo ──

## Resuelve el grafo de diálogo contextualmente vía ContextualDialogueManager.
## Devuelve el dialogue_id (sin .json) o "" si M162 no resuelve nada.
func _resolver_dialogue_id() -> String:
	var id_para_m162 := _resolver_npc_id()
	if id_para_m162 == "":
		return ""
	var ws = get_node_or_null("/root/WorldState")
	if ws == null or not ws.has_method("get_all_flags"):
		return ""  # sin WorldState no hay contexto -> fallback a dialogue_id
	var ctx := _construir_contexto(ws)
	var res := ContextualDialogueManagerScript.seleccionar(id_para_m162, "SALUDO", ctx)
	if res.get("ok", false):
		var entry: Dictionary = res.get("entry", {})
		var fname: String = str(entry.get("graph", ""))
		if fname != "":
			return fname.replace(".json", "")  # dialogue_id sin extensión
		print("[DialogueHook] M162 ok pero sin 'graph' en entry para %s" % id_para_m162)
	else:
		print("[DialogueHook] M162 no resolvió para %s: %s" % [id_para_m162, res.get("error", "")])
	return ""


## Resuelve el id de NPC a usar con M162: prefiere el export npc_id; si está
## vacío, lo deriva del perfil del vecino (obtener_perfil().npc_id).
func _resolver_npc_id() -> String:
	if npc_id != "":
		return npc_id
	if _vecino != null and _vecino.has_method("obtener_perfil"):
		var perfil = _vecino.obtener_perfil()
		if perfil != null and "npc_id" in perfil:
			return str(perfil.npc_id)
	return ""


## M162 (Hy3 / T-M162-003): construye el contexto de mundo para M162 combinando
## todas las banderas persistibles (flag_*) con las claves dinámicas que el
## registry usa en condiciones (estacion, es_noche, clima, amistad_<slug>, etc.).
func _construir_contexto(ws: Node) -> Dictionary:
	var ctx: Dictionary = {}
	if ws.has_method("get_all_flags"):
		ctx = ws.get_all_flags().duplicate()
	var claves := ["estacion", "es_noche", "es_de_dia", "dia", "mes", "anio", "hora", "minuto", "clima"]
	var slug := _slug_de_npc_id(_resolver_npc_id())
	if slug != "":
		claves.append("amistad_" + slug)
	if ws.has_method("get_snapshot"):
		var snap: Dictionary = ws.get_snapshot(claves)
		for k in snap.keys():
			ctx[str(k)] = snap[k]
	return ctx


## Normaliza un npc_id del proyecto ("NPC-RIZ_005") a su slug de registry ("riz_005").
## Si ya es un slug, lo devuelve igual.
func _slug_de_npc_id(id: String) -> String:
	var s := id.strip_edges().to_lower()
	if s.begins_with("npc-"):
		s = s.trim_prefix("npc-")
	return s


func _on_m21_terminado(_id: String, _ultimo: String) -> void:
	_en_conversacion = false
	notificar_cierre()


## M21 llama esto para dar líneas al jugador.
## Retorna una línea placeholder (M21 reemplazará esto).
func obtener_linea(clave: String) -> String:
	if _vecino and _vecino.has_method("obtener_perfil"):
		var perfil = _vecino.obtener_perfil()
		if perfil:
			match clave:
				"saludo", "saludo_alegre", "saludo_triste":
					return perfil.linea_saludo
				"despedida":
					return perfil.linea_despedida
				"sueno":
					return perfil.linea_sueno
	return "..."


## Notifica que la conversación terminó → M20 registra charla.
func notificar_cierre() -> void:
	if not _en_conversacion:
		return
	_en_conversacion = false
	var nombre: String = _vecino.name if _vecino else ""
	var resumen: Dictionary = {"vecino_id": nombre}
	conversacion_terminada.emit(_vecino, resumen)
	print("[DialogueHook] Conversación terminada con %s" % _vecino.name if _vecino else "?")


## Reacción a regalo (placeholder → M21 mostrará línea).
func linea_reaccion_regalo(objeto_id: String) -> String:
	if _vecino and _vecino.has_method("obtener_perfil"):
		var perfil = _vecino.obtener_perfil()
		if perfil:
			var valor: float = perfil.evaluar_objeto(objeto_id)
			if valor > 0.0:
				return "¡Me encanta! ¡Gracias!"
			elif valor < 0.0:
				return "Hmm... no es lo mío, pero gracias."
	return "Gracias."


func esta_en_conversacion() -> bool:
	# Fuente de verdad: el manager (se resetea SOLO si el diálogo no quedó activo).
	var dm = get_node_or_null("/root/DialogueManager")
	if dm:
		return dm.is_dialogue_active()
	return _en_conversacion
