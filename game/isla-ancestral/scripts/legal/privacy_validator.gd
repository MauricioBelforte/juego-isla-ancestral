# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M80: Legal Privacidad — PrivacyValidator
# Valida el catálogo de datos recolectados: IDs únicos, tipo/base_legal,
# regiones, políticas. Devuelve Array[String] de errores.

class_name PrivacyValidator
extends RefCounted

static func validar(data: Dictionary) -> Array:
	var errores: Array = []
	var ids: Dictionary = {}
	for d in data.get("datos_recolectados", []):
		var id: String = String(d.get("id", ""))
		var etiqueta := id if not id.is_empty() else "(sin_id)"
		if id.is_empty():
			errores.append("Dato sin id")
		elif ids.has(id):
			errores.append("Dato duplicado: %s" % id)
		ids[id] = true
		if String(d.get("tipo", "")).is_empty():
			errores.append("%s: sin tipo" % etiqueta)
		if String(d.get("base_legal", "")).is_empty():
			errores.append("%s: sin base legal" % etiqueta)
	if (data.get("regiones", []) as Array).is_empty():
		errores.append("Sin regiones definidas")
	if data.get("politicas", {}).is_empty():
		errores.append("Sin políticas de privacidad")
	return errores

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M80] PrivacyValidator: OK — privacidad configurada"
	var lineas: Array = ["[M80] PrivacyValidator: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)