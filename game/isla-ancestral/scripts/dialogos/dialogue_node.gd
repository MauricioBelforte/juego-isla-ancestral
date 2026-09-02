# Modelo: Hy3
# Plataforma: Kilo
# Fecha: 2026-08-29
#
# M21: DialogueNode — nodo del grafo de dialogo (LINEA, OPCIONES, EVENTO, FIN).

## Nodo del grafo de dialogo.
class_name DialogueNode
extends Resource

const TIPO_LINEA := 0
const TIPO_OPCIONES := 1
const TIPO_EVENTO := 2
const TIPO_FIN := 3

@export var id: String = ""
@export var tipo: int = TIPO_LINEA
@export var speaker_key: String = ""
@export var text_key: String = ""
@export var placeholders: Dictionary = {}
@export var conditions: Array = []
@export var effects: Array = []
@export var next_id: String = ""
@export var goto_id: String = ""
@export var options: Array = []

## Evalua las condiciones del nodo contra el estado de sesion
func evaluate_conditions(session_vars: Dictionary) -> bool:
	for cond in conditions:
		if not _evalua_cond(cond, session_vars):
			return false
	return true

func _evalua_cond(cond: Dictionary, vars: Dictionary) -> bool:
	var clave: String = str(cond.get("clave", ""))
	var operador: String = str(cond.get("operador", "=="))
	var valor = cond.get("valor", null)
	if not vars.has(clave):
		return false
	var actual = vars[clave]
	match operador:
		"==":
			return actual == valor
		"!=":
			return actual != valor
		">=":
			return float(actual) >= float(valor)
		"<=":
			return float(actual) <= float(valor)
		">":
			return float(actual) > float(valor)
		"<":
			return float(actual) < float(valor)
	return false

## Aplica los effects del nodo (sobre el estado de sesion).
## Si un effect lleva "destino": "world" o la clave empieza con "flag_",
## se escribe en WorldStateService (bandera persistente, M59).
func apply_effects(session_vars: Dictionary, _estado_mundo: Dictionary = {}) -> void:
	for ef in effects:
		var clave: String = str(ef.get("clave", ""))
		var accion: String = str(ef.get("accion", "set"))
		var destino: String = str(ef.get("destino", "session"))
		if clave == "":
			continue
		var es_world: bool = destino == "world" or clave.begins_with("flag_")
		if es_world:
			var ws = Engine.get_main_loop().root.get_node_or_null("/root/WorldState") if Engine.get_main_loop() else null
			if ws == null:
				continue
			match accion:
				"set":
					ws.set_flag(clave, ef.get("valor", null))
				"remove":
					ws.set_flag(clave, null)
				"increment":
					var base: float = float(ws.get_flag(clave, 0.0))
					ws.set_flag(clave, base + float(ef.get("valor", 1.0)))
			continue
		# M21 (iter 10 / Hy3 WorkBuddy): efectos de amistad hacia un NPC (M19).
		# destino == "amistad" + clave = <npc_id> aplica set/increment a Friendship.
		if destino == "amistad":
			var fs = Engine.get_main_loop().root.get_node_or_null("/root/Friendship") if Engine.get_main_loop() else null
			if fs == null or not fs.has_method("set_nivel"):
				continue
			match accion:
				"set":
					fs.set_nivel(clave, int(ef.get("valor", 0)))
				"increment":
					var base_i: int = int(fs.get_nivel(clave)) if fs.has_method("get_nivel") else 0
					fs.set_nivel(clave, base_i + int(ef.get("valor", 1)))
		match accion:
			"set":
				session_vars[clave] = ef.get("valor", null)
			"increment":
				session_vars[clave] = float(session_vars.get(clave, 0.0)) + float(ef.get("valor", 1.0))
			"remove":
				session_vars.erase(clave)
