# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M97: Steam Store Page — StorePageValidator
# Valida la configuración data-driven de la store page: descripción corta
# dentro del límite (ES/EN), secciones del About, keywords/tags no vacíos,
# requisitos completos, assets con dimensión y estado.
# Devuelve Array[String] de errores (vacía = OK).

class_name StorePageValidator
extends RefCounted

static func validar(data: Dictionary) -> Array:
	var errores: Array = []

	# Descripción corta ES/EN dentro de límite
	var desc: Dictionary = data.get("descripcion_corta", {})
	var max_chars: int = int(desc.get("max_caracteres", 300))
	for lang in ["es", "en"]:
		var texto: String = String(desc.get(lang, ""))
		if texto.is_empty():
			errores.append("Descripción corta %s vacía" % lang)
		elif texto.length() > max_chars:
			errores.append("Descripción corta %s excede %d caracteres (%d)" % [lang, max_chars, texto.length()])

	# About secciones
	var secciones: Array = data.get("about_secciones", [])
	if secciones.size() < 5:
		errores.append("About con menos de 5 secciones")
	for sec in secciones:
		if String(sec.get("titulo", "")).is_empty():
			errores.append("Sección About sin título")
		if (sec.get("bullet", []) as Array).is_empty():
			errores.append("Sección About '%s' sin bullets" % sec.get("titulo", "?"))

	# Keywords y tags
	if (data.get("keywords", []) as Array).is_empty():
		errores.append("Sin keywords")
	if (data.get("tags", []) as Array).size() > 20:
		errores.append("Más de 20 tags (límite Steamworks)")

	# Requisitos
	var req: Dictionary = data.get("requisitos", {})
	for campo in ["so_min", "so_rec", "ram_min", "ram_rec", "disco"]:
		if String(req.get(campo, "")).is_empty():
			errores.append("Requisito '%s' vacío" % campo)

	# Assets
	var assets: Array = data.get("assets", [])
	if assets.size() < 5:
		errores.append("Menos de 5 assets definidos")
	for a in assets:
		if String(a.get("dimension", "")).is_empty():
			errores.append("Asset '%s' sin dimensión" % a.get("id", "?"))
	return errores

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M97] StorePageValidator: OK — store page configurable"
	var lineas: Array = ["[M97] StorePageValidator: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)