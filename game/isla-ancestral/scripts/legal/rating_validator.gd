# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M82: Clasificación por Edades — RatingValidator
# Valida el catálogo de clasificaciones: cada organismo con rating/región,
# contenidos válidos, políticas. Devuelve Array[String] de errores.

class_name RatingValidator
extends RefCounted

static func validar(data: Dictionary) -> Array:
	var errores: Array = []
	var posibles: Array = data.get("contenidos_posibles", [])
	var clasifs: Dictionary = data.get("clasificaciones", {})
	if clasifs.is_empty():
		errores.append("Sin clasificaciones definidas")
	for organismo in clasifs:
		var entry: Dictionary = clasifs[organismo]
		if String(entry.get("rating", "")).is_empty():
			errores.append("%s: sin rating" % organismo)
		if String(entry.get("region", "")).is_empty():
			errores.append("%s: sin región" % organismo)
		for contenido in entry.get("contenidos", []):
			if not posibles.has(contenido):
				errores.append("%s: contenido '%s' no válido" % [organismo, contenido])
	if data.get("politicas", {}).is_empty():
		errores.append("Sin políticas de clasificación")
	return errores

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M82] RatingValidator: OK — clasificaciones configuradas"
	var lineas: Array = ["[M82] RatingValidator: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)