# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M85: Modelos 3D Legal — Model3DValidator
# Valida el catálogo de assets 3D: IDs únicos, licencia, políticas.
# Devuelve Array[String] de errores.

class_name Model3DValidator
extends RefCounted

static func validar(data: Dictionary) -> Array:
	var errores: Array = []
	var ids: Dictionary = {}
	for a in data.get("assets", []):
		var id: String = String(a.get("id", ""))
		var etiqueta := id if not id.is_empty() else "(sin_id)"
		if id.is_empty():
			errores.append("Asset sin id")
		elif ids.has(id):
			errores.append("Asset duplicado: %s" % id)
		ids[id] = true
		if String(a.get("licencia", "")).is_empty():
			errores.append("%s: sin licencia" % etiqueta)
	if data.get("politicas", {}).is_empty():
		errores.append("Sin políticas de assets")
	return errores

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M85] Model3DValidator: OK — assets 3D con licencias"
	var lineas: Array = ["[M85] Model3DValidator: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)