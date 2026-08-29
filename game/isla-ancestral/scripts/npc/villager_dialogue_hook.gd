extends Node

## Módulo 19: NPC y Vecinos — Hook de diálogo (conectado a M21 DialogueManager)
## M21: al solicitar diálogo, inicia el DialogueManager (autoload) con el
## dialogue_id del vecino.

signal linea_solicitada(vecino: Node, clave_linea: String)
signal respuestas_disponibles(vecino: Node, respuestas: Array[String])
signal conversacion_terminada(vecino: Node, resumen: Dictionary)

## ID del diálogo en data/dialogues/ (ej: "catalina_hola")
@export var dialogue_id: String = ""

var _vecino: Node = null
var _en_conversacion: bool = false


func inicializar(vecino: Node) -> void:
	_vecino = vecino


## El jugador solicita diálogo → inicia el DialogueManager de M21
func solicitar_dialogo() -> void:
	if _en_conversacion:
		return
	_en_conversacion = true
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
	# M21: iniciar el DialogueManager (autoload) si tenemos dialogue_id
	if dialogue_id != "":
		var dm = get_node_or_null("/root/DialogueManager")
		if dm:
			dm.start_dialogue(dialogue_id, {"nombre_viajero": nombre})
			dm.dialogue_ended.connect(_on_m21_terminado, CONNECT_ONE_SHOT)
		else:
			print("[DialogueHook] DialogueManager no encontrado (autoload?)")


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
	return _en_conversacion
