# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M127: Copyright del Juego — CopyrightValidator
# Valida el catálogo de elementos con copyright: IDs únicos, elemento,
# titular, políticas. Devuelve Array[String] de errores.

class_name CopyrightValidator
extends RefCounted

static func validar(data: Dictionary) -> Array:
	var errores: Array = []
	var ids: Dictionary = {}
	for e in data.get("elementos", []):
		var id: String = String(e.get("id", ""))
		var etiqueta := id if not id.is_empty() else "(sin_id)"
		if id.is_empty():
			errores.append("Elemento sin id")
		elif ids.has(id):
			errores.append("Elemento duplicado: %s" % id)
		ids[id] = true
		if String(e.get("elemento", "")).is_empty():
			errores.append("%s: sin nombre de elemento" % etiqueta)
		if String(e.get("titular", "")).is_empty():
			errores.append("%s: sin titular" % etiqueta)
	if data.get("politicas", {}).is_empty():
		errores.append("Sin políticas de copyright")
	return errores

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M127] CopyrightValidator: OK — copyright registrado"
	var lineas: Array = ["[M127] CopyrightValidator: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)