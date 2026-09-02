# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M132: Producción de Equipo — ProductionValidator
# Valida el catálogo de roles y políticas de producción. Devuelve Array[String] de errores.

class_name ProductionValidator
extends RefCounted

static func validar(data: Dictionary) -> Array:
	var errores: Array = []
	var ids: Dictionary = {}
	for r in data.get("roles", []):
		var id: String = String(r.get("id", ""))
		var etiqueta := id if not id.is_empty() else "(sin_id)"
		if id.is_empty():
			errores.append("Rol sin id")
		elif ids.has(id):
			errores.append("Rol duplicado: %s" % id)
		ids[id] = true
		if String(r.get("rol", "")).is_empty():
			errores.append("%s: sin nombre de rol" % etiqueta)
		if String(r.get("estado", "")).is_empty():
			errores.append("%s: sin estado" % etiqueta)
	if data.get("politicas", {}).is_empty():
		errores.append("Sin políticas de producción")
	return errores

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M132] ProductionValidator: OK — equipo configurado"
	var lineas: Array = ["[M132] ProductionValidator: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)