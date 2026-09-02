# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M99: Marketing — MarketingValidator
# Valida el plan de marketing: canales, campañas con canal/fase, presupuesto.
# Devuelve Array[String] de errores.

class_name MarketingValidator
extends RefCounted

static func validar(data: Dictionary) -> Array:
	var errores: Array = []
	if (data.get("canales", []) as Array).is_empty():
		errores.append("Sin canales de marketing")
	var campanas: Array = data.get("campanas", [])
	if campanas.is_empty():
		errores.append("Sin campañas")
	for c in campanas:
		if String(c.get("nombre", "")).is_empty():
			errores.append("Campaña sin nombre")
		if String(c.get("canal", "")).is_empty():
			errores.append("Campaña '%s' sin canal" % c.get("nombre", "?"))
		if String(c.get("fase", "")).is_empty():
			errores.append("Campaña '%s' sin fase" % c.get("nombre", "?"))
	if data.get("presupuesto", {}).get("total_usd", 0) <= 0:
		errores.append("Presupuesto total no definido (>0)")
	if (data.get("kpis", []) as Array).is_empty():
		errores.append("Sin KPIs definidos")
	return errores

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M99] MarketingValidator: OK — plan de marketing válido"
	var lineas: Array = ["[M99] MarketingValidator: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)