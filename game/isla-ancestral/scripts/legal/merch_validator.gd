# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M129: Merchandising — MerchValidator
# Valida el catálogo de productos: IDs únicos, producto/tipo/estado,
# políticas. Devuelve Array[String] de errores.

class_name MerchValidator
extends RefCounted

static func validar(data: Dictionary) -> Array:
	var errores: Array = []
	var ids: Dictionary = {}
	for p in data.get("productos", []):
		var id: String = String(p.get("id", ""))
		var etiqueta := id if not id.is_empty() else "(sin_id)"
		if id.is_empty():
			errores.append("Producto sin id")
		elif ids.has(id):
			errores.append("Producto duplicado: %s" % id)
		ids[id] = true
		if String(p.get("producto", "")).is_empty():
			errores.append("%s: sin nombre de producto" % etiqueta)
		if String(p.get("tipo", "")).is_empty():
			errores.append("%s: sin tipo" % etiqueta)
		if String(p.get("estado", "")).is_empty():
			errores.append("%s: sin estado" % etiqueta)
	if data.get("politicas", {}).is_empty():
		errores.append("Sin políticas de merchandising")
	return errores

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M129] MerchValidator: OK — merchandising configurado"
	var lineas: Array = ["[M129] MerchValidator: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)