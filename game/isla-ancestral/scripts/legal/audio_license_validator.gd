# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M84: Música y Audio Legal — AudioLicenseValidator
# Valida el catálogo de tracks: IDs únicos, licencia, attribution cuando
# CC-BY, políticas. Devuelve Array[String] de errores.

class_name AudioLicenseValidator
extends RefCounted

static func validar(data: Dictionary) -> Array:
	var errores: Array = []
	var ids: Dictionary = {}
	for t in data.get("tracks", []):
		var id: String = String(t.get("id", ""))
		var etiqueta := id if not id.is_empty() else "(sin_id)"
		if id.is_empty():
			errores.append("Track sin id")
		elif ids.has(id):
			errores.append("Track duplicado: %s" % id)
		ids[id] = true
		if String(t.get("licencia", "")).is_empty():
			errores.append("%s: sin licencia" % etiqueta)
		var licencia: String = String(t.get("licencia", ""))
		if licencia == "CC-BY" and String(t.get("attribution", "")).is_empty():
			errores.append("%s: CC-BY sin atribución" % etiqueta)
	if data.get("politicas", {}).is_empty():
		errores.append("Sin políticas de audio")
	return errores

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M84] AudioLicenseValidator: OK — audio con licencias"
	var lineas: Array = ["[M84] AudioLicenseValidator: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)