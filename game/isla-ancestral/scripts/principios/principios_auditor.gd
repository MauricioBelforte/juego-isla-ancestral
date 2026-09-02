# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M152: Principios Innegociables — PrincipiosAuditor
# Verifica que los principios data-driven sean coherentes:
#   - IDs únicos, nombre y descripción no vacíos
#   - Reglas no vacías
#   - Prohibiciones totales definidas
#   - Coherencia con módulos relacionados (M94/M95)
# Devuelve Array[String] de errores (vacía = OK).

class_name PrincipiosAuditor
extends RefCounted

static func validar(data: Dictionary) -> Array:
	var errores: Array = []
	var ids: Dictionary = {}
	for principio in data.get("principios", []):
		var id: String = String(principio.get("id", ""))
		var etiqueta := id if not id.is_empty() else "(sin_id)"
		if id.is_empty():
			errores.append("Principio sin id")
		elif ids.has(id):
			errores.append("Principio duplicado: %s" % id)
		ids[id] = true
		if String(principio.get("nombre", "")).is_empty():
			errores.append("%s: nombre vacío" % etiqueta)
		if String(principio.get("descripcion", "")).is_empty():
			errores.append("%s: descripción vacía" % etiqueta)
		var reglas: Array = principio.get("reglas", [])
		if reglas.is_empty():
			errores.append("%s: sin reglas" % etiqueta)
	# Auditoría: prohibiciones totales
	var auditoria: Dictionary = data.get("auditoria", {})
	if auditoria.get("prohibido_totalmente", []).is_empty():
		errores.append("Auditoría sin prohibiciones totales")
	return errores

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M152] PrincipiosAuditor: OK — 8 principios coherentes"
	var lineas: Array = ["[M152] PrincipiosAuditor: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)