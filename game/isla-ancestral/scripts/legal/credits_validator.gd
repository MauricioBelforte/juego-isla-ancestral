# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M131: Créditos — CreditsValidator
# Valida el catálogo de secciones de créditos: IDs únicos, título, entradas,
# políticas. Devuelve Array[String] de errores.

class_name CreditsValidator
extends RefCounted

static func validar(data: Dictionary) -> Array:
	var errores: Array = []
	var ids: Dictionary = {}
	for s in data.get("secciones", []):
		var id: String = String(s.get("id", ""))
		var etiqueta := id if not id.is_empty() else "(sin_id)"
		if id.is_empty():
			errores.append("Sección sin id")
		elif ids.has(id):
			errores.append("Sección duplicada: %s" % id)
		ids[id] = true
		if String(s.get("titulo", "")).is_empty():
			errores.append("%s: sin título" % etiqueta)
		if (s.get("entradas", []) as Array).is_empty():
			errores.append("%s: sin entradas" % etiqueta)
	if data.get("politicas", {}).is_empty():
		errores.append("Sin políticas de créditos")
	return errores

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M131] CreditsValidator: OK — créditos configurados"
	var lineas: Array = ["[M131] CreditsValidator: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)