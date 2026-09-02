# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M126: Marketing Legal — MarketingLegalValidator
# Valida el catálogo de cumplimientos de marketing: IDs únicos, regla,
# aplica_a, políticas. Devuelve Array[String] de errores.

class_name MarketingLegalValidator
extends RefCounted

static func validar(data: Dictionary) -> Array:
	var errores: Array = []
	var ids: Dictionary = {}
	for c in data.get("cumplimientos", []):
		var id: String = String(c.get("id", ""))
		var etiqueta := id if not id.is_empty() else "(sin_id)"
		if id.is_empty():
			errores.append("Cumplimiento sin id")
		elif ids.has(id):
			errores.append("Cumplimiento duplicado: %s" % id)
		ids[id] = true
		if String(c.get("regla", "")).is_empty():
			errores.append("%s: sin regla" % etiqueta)
		if (c.get("aplica_a", []) as Array).is_empty():
			errores.append("%s: sin alcance (aplica_a)" % etiqueta)
	if data.get("politicas", {}).is_empty():
		errores.append("Sin políticas de marketing legal")
	return errores

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M126] MarketingLegalValidator: OK — cumplimientos configurados"
	var lineas: Array = ["[M126] MarketingLegalValidator: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)