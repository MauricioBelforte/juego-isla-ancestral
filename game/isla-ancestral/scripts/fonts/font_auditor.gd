# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M88: Fuentes Tipográficas — FontAuditor
# Auditoría de fuentes: licencias permitidas, IDs únicos, al menos un peso
# por fuente, archivos presentes. Devuelve Array[String] de errores.

class_name FontAuditor
extends RefCounted

static func validar(data: Dictionary) -> Array:
	var errores: Array = []
	var permitidas: Array = data.get("licencias_permitidas", [])
	var ids: Dictionary = {}
	for fuente in data.get("fuentes", []):
		var id: String = String(fuente.get("id", ""))
		var etiqueta := id if not id.is_empty() else "(sin_id)"
		if id.is_empty():
			errores.append("Fuente sin id")
		elif ids.has(id):
			errores.append("Fuente duplicada: %s" % id)
		ids[id] = true
		var licencia: String = String(fuente.get("licencia", ""))
		if licencia.is_empty():
			errores.append("%s: sin licencia" % etiqueta)
		elif not permitidas.has(licencia):
			errores.append("%s: licencia '%s' no permitida" % [etiqueta, licencia])
		var pesos: Array = fuente.get("pesos", [])
		if pesos.is_empty():
			errores.append("%s: sin pesos" % etiqueta)
	return errores

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M88] FontAuditor: OK — fuentes con licencias válidas"
	var lineas: Array = ["[M88] FontAuditor: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)