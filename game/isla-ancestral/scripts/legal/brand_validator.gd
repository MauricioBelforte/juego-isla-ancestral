# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M128: Identidad de Marca — BrandValidator
# Valida el catálogo de elementos de marca: IDs únicos, elemento/uso,
# políticas. Devuelve Array[String] de errores.

class_name BrandValidator
extends RefCounted

static func validar(data: Dictionary) -> Array:
	var errores: Array = []
	var ids: Dictionary = {}
	for e in data.get("elementos", []):
		var id: String = String(e.get("id", ""))
		var etiqueta := id if not id.is_empty() else "(sin_id)"
		if id.is_empty():
			errores.append("Elemento sin id")
		elif ids.has(id):
			errores.append("Elemento duplicado: %s" % id)
		ids[id] = true
		if String(e.get("elemento", "")).is_empty():
			errores.append("%s: sin nombre" % etiqueta)
		if String(e.get("uso", "")).is_empty():
			errores.append("%s: sin uso" % etiqueta)
	if data.get("politicas", {}).is_empty():
		errores.append("Sin políticas de marca")
	return errores

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M128] BrandValidator: OK — identidad de marca configurada"
	var lineas: Array = ["[M128] BrandValidator: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)