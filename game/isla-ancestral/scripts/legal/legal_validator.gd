# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M78: Legal Propiedad Intelectual — LegalValidator
# Valida el catálogo de IPs: IDs únicos, tipo/titular/jurisdicción no vacíos,
# políticas presentes. Devuelve Array[String] de errores.

class_name LegalValidator
extends RefCounted

static func validar(data: Dictionary) -> Array:
	var errores: Array = []
	var ids: Dictionary = {}
	for ip in data.get("ips", []):
		var id: String = String(ip.get("id", ""))
		var etiqueta := id if not id.is_empty() else "(sin_id)"
		if id.is_empty():
			errores.append("IP sin id")
		elif ids.has(id):
			errores.append("IP duplicada: %s" % id)
		ids[id] = true
		if String(ip.get("tipo", "")).is_empty():
			errores.append("%s: sin tipo" % etiqueta)
		if String(ip.get("titular", "")).is_empty():
			errores.append("%s: sin titular" % etiqueta)
		if String(ip.get("jurisdiccion", "")).is_empty():
			errores.append("%s: sin jurisdicción" % etiqueta)
	if data.get("politicas", {}).is_empty():
		errores.append("Sin políticas definidas")
	return errores

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M78] LegalValidator: OK — IPs registradas"
	var lineas: Array = ["[M78] LegalValidator: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)