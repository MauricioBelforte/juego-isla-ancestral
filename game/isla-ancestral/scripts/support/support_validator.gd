# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M121: Soporte Post-Lanzamiento — SupportValidator
# Valida la configuración de soporte: FAQ con id/pregunta/respuesta,
# categorías válidas, canales no vacíos, política de respuesta presente.
# Devuelve Array[String] de errores.

class_name SupportValidator
extends RefCounted

static func validar(data: Dictionary) -> Array:
	var errores: Array = []
	var canales: Array = data.get("canales", [])
	if canales.is_empty():
		errores.append("Sin canales de soporte definidos")
	var categorias: Array = data.get("categorias", [])
	if categorias.is_empty():
		errores.append("Sin categorías de tickets definidas")
	var politica: Dictionary = data.get("politica_respuesta", {})
	if politica.is_empty():
		errores.append("Sin política de respuesta")
	var ids: Dictionary = {}
	for item in data.get("faq", []):
		var id: String = String(item.get("id", ""))
		var etiqueta := id if not id.is_empty() else "(sin_id)"
		if id.is_empty():
			errores.append("FAQ sin id")
		elif ids.has(id):
			errores.append("FAQ duplicada: %s" % id)
		ids[id] = true
		if String(item.get("pregunta", "")).is_empty():
			errores.append("%s: sin pregunta" % etiqueta)
		if String(item.get("respuesta", "")).is_empty():
			errores.append("%s: sin respuesta" % etiqueta)
		var categoria: String = String(item.get("categoria", ""))
		if categoria != "" and not categorias.has(categoria):
			errores.append("%s: categoría '%s' no definida" % [etiqueta, categoria])
	return errores

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M121] SupportValidator: OK — soporte configurado"
	var lineas: Array = ["[M121] SupportValidator: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)