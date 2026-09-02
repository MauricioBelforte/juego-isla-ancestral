# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# M03: Documentación del Proyecto — DocumentationValidator
class_name DocumentationValidator
extends RefCounted
static func validar(data: Dictionary) -> Array:
	var errores: Array = []; var ids: Dictionary = {}
	for c in data.get("categorias", []):
		var id: String = String(c.get("id", "")); var et = id if not id.is_empty() else "(sin_id)"
		if id.is_empty(): errores.append("Categoría sin id")
		elif ids.has(id): errores.append("Categoría duplicada: %s" % id)
		ids[id] = true
		if String(c.get("nombre", "")).is_empty(): errores.append("%s: sin nombre" % et)
		if String(c.get("ubicacion", "")).is_empty(): errores.append("%s: sin ubicación" % et)
	if data.get("politicas", {}).is_empty(): errores.append("Sin políticas de documentación")
	return errores
static func reporte(errores: Array) -> String:
	if errores.is_empty(): return "[M03] DocumentationValidator: OK — documentación configurada"
	var lineas: Array = ["[M03] DocumentationValidator: %d ERRORES:" % errores.size()]
	for e in errores: lineas.append("  - %s" % e)
	return "\n".join(lineas)