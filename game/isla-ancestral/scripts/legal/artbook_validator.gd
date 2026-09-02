# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M130: Artbook — ArtbookValidator
# Valida el catálogo de secciones del artbook: IDs únicos, nombre, estado,
# políticas. Devuelve Array[String] de errores.

class_name ArtbookValidator
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
		if String(s.get("nombre", "")).is_empty():
			errores.append("%s: sin nombre" % etiqueta)
		if String(s.get("estado", "")).is_empty():
			errores.append("%s: sin estado" % etiqueta)
	if data.get("politicas", {}).is_empty():
		errores.append("Sin políticas de artbook")
	return errores

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M130] ArtbookValidator: OK — artbook configurado"
	var lineas: Array = ["[M130] ArtbookValidator: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)