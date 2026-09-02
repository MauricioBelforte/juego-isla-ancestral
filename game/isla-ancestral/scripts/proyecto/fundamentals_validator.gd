# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M01: Fundamentos del Proyecto — FundamentalsValidator
# Valida el catálogo de fundamentos: IDs únicos, título, detalle,
# políticas. Devuelve Array[String] de errores.

class_name FundamentalsValidator
extends RefCounted

static func validar(data: Dictionary) -> Array:
	var errores: Array = []
	var ids: Dictionary = {}
	for f in data.get("fundamentos", []):
		var id: String = String(f.get("id", ""))
		var etiqueta := id if not id.is_empty() else "(sin_id)"
		if id.is_empty():
			errores.append("Fundamento sin id")
		elif ids.has(id):
			errores.append("Fundamento duplicado: %s" % id)
		ids[id] = true
		if String(f.get("titulo", "")).is_empty():
			errores.append("%s: sin título" % etiqueta)
		if String(f.get("detalle", "")).is_empty():
			errores.append("%s: sin detalle" % etiqueta)
	if data.get("politicas", {}).is_empty():
		errores.append("Sin políticas de fundamentos")
	return errores

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M01] FundamentalsValidator: OK — fundamentos del proyecto definidos"
	var lineas: Array = ["[M01] FundamentalsValidator: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)