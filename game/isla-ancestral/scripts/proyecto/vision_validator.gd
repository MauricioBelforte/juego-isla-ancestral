# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M02: Visión y Concepto — VisionValidator
# Valida el catálogo de pilares de visión: IDs únicos, pilar, detalle,
# políticas. Devuelve Array[String] de errores.

class_name VisionValidator
extends RefCounted

static func validar(data: Dictionary) -> Array:
	var errores: Array = []
	var ids: Dictionary = {}
	for p in data.get("pilares", []):
		var id: String = String(p.get("id", ""))
		var etiqueta := id if not id.is_empty() else "(sin_id)"
		if id.is_empty():
			errores.append("Pilar sin id")
		elif ids.has(id):
			errores.append("Pilar duplicado: %s" % id)
		ids[id] = true
		if String(p.get("pilar", "")).is_empty():
			errores.append("%s: sin nombre de pilar" % etiqueta)
		if String(p.get("detalle", "")).is_empty():
			errores.append("%s: sin detalle" % etiqueta)
	if data.get("politicas", {}).is_empty():
		errores.append("Sin políticas de visión")
	return errores

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M02] VisionValidator: OK — visión y concepto definidos"
	var lineas: Array = ["[M02] VisionValidator: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)