# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M83: Licencias de Software — LicenseValidator
# Valida el catálogo de licencias: IDs únicos, licencia/comercial_ok,
# políticas. Devuelve Array[String] de errores.

class_name LicenseValidator
extends RefCounted

static func validar(data: Dictionary) -> Array:
	var errores: Array = []
	var ids: Dictionary = {}
	for l in data.get("licencias", []):
		var id: String = String(l.get("id", ""))
		var etiqueta := id if not id.is_empty() else "(sin_id)"
		if id.is_empty():
			errores.append("Licencia sin id")
		elif ids.has(id):
			errores.append("Licencia duplicada: %s" % id)
		ids[id] = true
		if String(l.get("software", "")).is_empty():
			errores.append("%s: sin software" % etiqueta)
		if String(l.get("licencia", "")).is_empty():
			errores.append("%s: sin tipo de licencia" % etiqueta)
	if data.get("politicas", {}).is_empty():
		errores.append("Sin políticas de licencias")
	return errores

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M83] LicenseValidator: OK — licencias de software registradas"
	var lineas: Array = ["[M83] LicenseValidator: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)