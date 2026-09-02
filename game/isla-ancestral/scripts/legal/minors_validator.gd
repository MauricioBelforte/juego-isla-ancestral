# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M81: Legal Menores — MinorsValidator
# Valida el catálogo de políticas de menores: edades definidas, regiones
# con edad de consentimiento, políticas presentes. Devuelve Array[String] de errores.

class_name MinorsValidator
extends RefCounted

static func validar(data: Dictionary) -> Array:
	var errores: Array = []
	var edades: Dictionary = data.get("edades", {})
	if edades.is_empty():
		errores.append("Sin bloque 'edades'")
	else:
		if int(edades.get("requiere_consentimiento_parental_hasta", 0)) <= 0:
			errores.append("Edad de consentimiento parental no definida")
	var regiones: Dictionary = data.get("regiones", {})
	if regiones.is_empty():
		errores.append("Sin regiones")
	else:
		for region in regiones:
			if int(regiones[region].get("edad_consentimiento", 0)) <= 0:
				errores.append("Región '%s' sin edad de consentimiento" % region)
	if data.get("politicas", {}).is_empty():
		errores.append("Sin políticas de menores")
	return errores

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M81] MinorsValidator: OK — políticas de menores configuradas"
	var lineas: Array = ["[M81] MinorsValidator: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)