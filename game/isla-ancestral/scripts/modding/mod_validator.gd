# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M123: Modding — ModValidator
# Validación de mods: manifiesto con id/versión, compatibilidad con build,
# sin conflictos bloqueantes. Devuelve Array[String] de errores.

class_name ModValidator
extends RefCounted

static func validar(config: Dictionary) -> Array:
	var errores: Array = []
	var ids: Dictionary = {}
	for m in config.get("mods", []):
		var id: String = String(m.get("id", ""))
		var etiqueta := id if not id.is_empty() else "(sin_id)"
		if id.is_empty():
			errores.append("Mod sin id")
		elif ids.has(id):
			errores.append("Mod duplicado: %s" % id)
		ids[id] = true
		if String(m.get("version", "")).is_empty():
			errores.append("%s: sin versión" % etiqueta)
		if String(m.get("min_build", "")).is_empty():
			errores.append("%s: sin min_build" % etiqueta)
		# Override apunta a mod existente?
		for over in m.get("override", []):
			if not ids.has(over) and not _existe_en(config, over):
				errores.append("%s: override '%s' no existe" % [etiqueta, over])
	return errores

static func _existe_en(config: Dictionary, id: String) -> bool:
	for m in config.get("mods", []):
		if String(m.get("id", "")) == id:
			return true
	return false

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M123] ModValidator: OK — mods válidos"
	var lineas: Array = ["[M123] ModValidator: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)