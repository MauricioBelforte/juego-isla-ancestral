# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M86: IA Generativa — GenAIValidator
# Valida las políticas de IA generativa: usos permitidos/prohibidos definidos,
# atribución configurada. Devuelve Array[String] de errores.

class_name GenAIValidator
extends RefCounted

static func validar(data: Dictionary) -> Array:
	var errores: Array = []
	var politicas: Dictionary = data.get("politicas", {})
	if politicas.is_empty():
		errores.append("Sin políticas de IA generativa")
	else:
		if (politicas.get("uso_permitido", []) as Array).is_empty():
			errores.append("Sin usos permitidos")
		if (politicas.get("uso_prohibido", []) as Array).is_empty():
			errores.append("Sin usos prohibidos")
	if data.get("atribucion", {}).get("requerida", false) == false:
		errores.append("Atribución no requerida")
	return errores

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M86] GenAIValidator: OK — políticas de IA generativa"
	var lineas: Array = ["[M86] GenAIValidator: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)