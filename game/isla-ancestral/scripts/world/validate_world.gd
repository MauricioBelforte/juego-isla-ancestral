# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M147: World Building — ValidateWorld
# Validador de consistencia del canon (RF10): IDs únicos, canonRef de las
# capas apunta a personajes/lugares existentes, sellos definidos, timeline
# ordenada, canon_version presente. Devuelve Array[String] de errores.
# Diseño original (04-Codigo.md §2.3, validate_world.gd).

class_name ValidateWorld
extends RefCounted

static func validar(data: Dictionary) -> Array:
	var errores: Array = []

	# canon_version
	if String(data.get("canon_version", "")).is_empty():
		errores.append("Falta canon_version")

	# IDs únicos en personajes
	var ids_personajes: Dictionary = {}
	for id in data.get("personajes", {}):
		if ids_personajes.has(id):
			errores.append("Personaje duplicado: %s" % id)
		ids_personajes[id] = true

	# IDs únicos en lugares
	var ids_lugares: Dictionary = {}
	for id in data.get("lugares", {}):
		if ids_lugares.has(id):
			errores.append("Lugar duplicado: %s" % id)
		ids_lugares[id] = true

	# canonRef de capas: cada revela[] debe existir en personajes o lugares
	var capas: Dictionary = data.get("capas_por_sello", {})
	for sello in capas:
		var revela: Array = capas[sello].get("revela", [])
		for ref in revela:
			if not ids_personajes.has(ref) and not ids_lugares.has(ref):
				errores.append("Capas %s refiere a '%s' inexistente" % [sello, ref])
		# sello debe existir en simbolos
		if not data.get("simbolos", {}).has(sello):
			errores.append("Sello '%s' en capas no existe en simbolos" % sello)

	# timeline ordenada
	var timeline: Array = data.get("linea_tiempo", [])
	var prev_orden: int = 0
	for epoch in timeline:
		var orden: int = int(epoch.get("orden", 0))
		if orden <= prev_orden:
			errores.append("Timeline desordenada en '%s' (orden %d)" % [epoch.get("nombre", "?"), orden])
		prev_orden = orden

	return errores

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M147] ValidateWorld: OK — canon consistente"
	var lineas: Array = ["[M147] ValidateWorld: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)