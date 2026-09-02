# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M124: Contenido Generado por Usuarios — UgcValidator
# Valida el catálogo UGC: IDs únicos, tipos/estados válidos, política
# presente. Devuelve Array[String] de errores.

class_name UgcValidator
extends RefCounted

static func validar(data: Dictionary) -> Array:
	var errores: Array = []
	var tipos: Array = data.get("tipos_validos", [])
	var estados: Array = data.get("estados_validos", [])
	if tipos.is_empty():
		errores.append("Sin tipos válidos definidos")
	if estados.is_empty():
		errores.append("Sin estados válidos definidos")
	if data.get("politica", {}).is_empty():
		errores.append("Sin política UGC")
	var ids: Dictionary = {}
	for c in data.get("contenido", []):
		var id: String = String(c.get("id", ""))
		var etiqueta := id if not id.is_empty() else "(sin_id)"
		if id.is_empty():
			errores.append("UGC sin id")
		elif ids.has(id):
			errores.append("UGC duplicado: %s" % id)
		ids[id] = true
		var tipo: String = String(c.get("tipo", ""))
		if tipo != "" and not tipos.has(tipo):
			errores.append("%s: tipo '%s' no válido" % [etiqueta, tipo])
		var estado: String = String(c.get("estado", ""))
		if estado != "" and not estados.has(estado):
			errores.append("%s: estado '%s' no válido" % [etiqueta, estado])
	return errores

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M124] UgcValidator: OK — catálogo UGC válido"
	var lineas: Array = ["[M124] UgcValidator: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)