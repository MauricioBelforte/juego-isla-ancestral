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
