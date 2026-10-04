# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M117: Build System — BuildValidator
# Valida la configuración de builds: export_presets.cfg presente, presets
# requeridos por target, targets data-driven coherentes.
# Devuelve Array[String] de errores (vacía = OK).

class_name BuildValidator
extends RefCounted

const RUTA_PRESETS := "res://export_presets.cfg"

static func validar(targets: Dictionary, presets_existentes: Array) -> Array:
	var errores: Array = []
	# export_presets.cfg presente
	if not FileAccess.file_exists(RUTA_PRESETS):
		errores.append("Falta export_presets.cfg")
	# targets data-driven válidos
	var lista: Array = targets.get("targets", [])
	if lista.is_empty():
		errores.append("build_targets.json sin targets")
	for target in lista:
		var id: String = String(target.get("id", ""))
		var etiqueta := id if not id.is_empty() else "(sin_id)"
		if id.is_empty():
			errores.append("Target sin id")
		var preset: String = String(target.get("preset", ""))
		var prioridad: String = String(target.get("prioridad", ""))
		if preset.is_empty():
			errores.append("%s: sin preset" % etiqueta)
		elif not presets_existentes.has(preset):
			errores.append("%s: preset '%s' no existe en export_presets.cfg" % [etiqueta, preset])
		if prioridad.is_empty():
			errores.append("%s: sin prioridad" % etiqueta)
	return errores

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M117] BuildValidator: OK — configuración de builds válida"
	var lineas: Array = ["[M117] BuildValidator: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)