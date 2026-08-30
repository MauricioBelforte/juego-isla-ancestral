# Modelo: Hy3
# Plataforma: Kilo
# Fecha: 2026-08-29
#
# M21: DialogueOption — opcion ramificada de un nodo de dialogo.

## Opcion de un nodo de dialogo (hasta 4 por nodo OPCIONES).
class_name DialogueOption
extends Resource

@export var text_key: String = ""
@export var next_id: String = ""
@export var conditions: Array = []
@export var blocked_text_key: String = ""
@export var effect: Array = []

## Evalua las condiciones contra el estado de sesion (WorldState simplificado)
func evaluate_conditions(session_vars: Dictionary) -> bool:
	for cond in conditions:
		if not _evalua_cond(cond, session_vars):
			return false
	return true

## Aplica los effects propios de la opcion (mismo contrato que DialogueNode).
func apply_effects(session_vars: Dictionary, _estado_mundo: Dictionary = {}) -> void:
	for ef in effect:
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
		match accion:
			"set":
				session_vars[clave] = ef.get("valor", null)
			"increment":
				session_vars[clave] = float(session_vars.get(clave, 0.0)) + float(ef.get("valor", 1.0))
			"remove":
				session_vars.erase(clave)

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
