# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M125: Términos de Servicio — TermsValidator
# Valida el catálogo de secciones de términos: IDs únicos, título, secciones
# obligatorias cubiertas, políticas. Devuelve Array[String] de errores.

class_name TermsValidator
extends RefCounted

static func validar(data: Dictionary) -> Array:
	var errores: Array = []
	var ids: Dictionary = {}
	var obligatorias_presentes: Array = []
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
		if bool(s.get("obligatoria", false)):
			obligatorias_presentes.append(id)
	if data.get("secciones", []).size() < 3:
		errores.append("Menos de 3 secciones de términos")
	if data.get("politicas", {}).is_empty():
		errores.append("Sin políticas de términos")
	return errores

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M125] TermsValidator: OK — términos de servicio configurados"
	var lineas: Array = ["[M125] TermsValidator: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)