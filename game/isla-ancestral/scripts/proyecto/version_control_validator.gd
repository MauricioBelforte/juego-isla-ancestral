# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M06: Control de Versiones — VersionControlValidator
# Valida el catálogo de políticas de versionado: IDs únicos, regla,
# políticas. Devuelve Array[String] de errores.

class_name VersionControlValidator
extends RefCounted

static func validar(data: Dictionary) -> Array:
	var errores: Array = []
	var ids: Dictionary = {}
	for p in data.get("reglas", []):
		var id: String = String(p.get("id", ""))
		var etiqueta := id if not id.is_empty() else "(sin_id)"
		if id.is_empty():
			errores.append("Política sin id")
		elif ids.has(id):
			errores.append("Política duplicada: %s" % id)
		ids[id] = true
		if String(p.get("regla", "")).is_empty():
			errores.append("%s: sin regla" % etiqueta)
	if data.get("politicas", {}).is_empty():
		errores.append("Sin políticas de versionado")
	return errores

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M06] VersionControlValidator: OK — control de versiones configurado"
	var lineas: Array = ["[M06] VersionControlValidator: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)