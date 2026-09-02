# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M79: Legal Contratos — ContractValidator
# Valida el catálogo de contratos: IDs únicos, tipo/proveedor/estado.
# Devuelve Array[String] de errores.

class_name ContractValidator
extends RefCounted

static func validar(data: Dictionary) -> Array:
	var errores: Array = []
	var ids: Dictionary = {}
	for c in data.get("contratos", []):
		var id: String = String(c.get("id", ""))
		var etiqueta := id if not id.is_empty() else "(sin_id)"
		if id.is_empty():
			errores.append("Contrato sin id")
		elif ids.has(id):
			errores.append("Contrato duplicado: %s" % id)
		ids[id] = true
		if String(c.get("tipo", "")).is_empty():
			errores.append("%s: sin tipo" % etiqueta)
		if String(c.get("proveedor", "")).is_empty():
			errores.append("%s: sin proveedor" % etiqueta)
		if String(c.get("estado", "")).is_empty():
			errores.append("%s: sin estado" % etiqueta)
	if data.get("politicas", {}).is_empty():
		errores.append("Sin políticas de contratos")
	return errores

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M79] ContractValidator: OK — contratos registrados"
	var lineas: Array = ["[M79] ContractValidator: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)