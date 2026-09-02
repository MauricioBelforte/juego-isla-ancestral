# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M98: Trailer — TrailerValidator
# Valida la especificación del tráiler (trailer_spec.json): duración total
# coherente con las tomas, formato/resolución, música por toma, checklist
# anti-spoiler, subtítulos. Devuelve Array[String] de errores.

class_name TrailerValidator
extends RefCounted

static func validar(data: Dictionary) -> Array:
	var errores: Array = []
	var trailer: Dictionary = data.get("trailer", {})
	if trailer.is_empty():
		errores.append("Sin bloque 'trailer'")
		return errores

	# Duración total vs suma de tomas
	var duracion_total: int = int(trailer.get("duracion_total_s", 0))
	var tomas: Array = data.get("tomas", [])
	var suma_tomas := 0
	for t in tomas:
		suma_tomas += int(t.get("duracion_s", 0))
	if tomas.is_empty():
		errores.append("Sin tomas definidas")
	elif abs(suma_tomas - duracion_total) > 10:
		errores.append("Suma de tomas (%d s) difiere de duración total (%d s)" % [suma_tomas, duracion_total])

	# Formato y resolución
	if String(trailer.get("formato", "")).is_empty():
		errores.append("Sin formato")
	if String(trailer.get("resolucion", "")).is_empty():
		errores.append("Sin resolución")

	# Música por toma
	for t in tomas:
		if String(t.get("musica", "")).is_empty():
			errores.append("Toma '%s' sin música" % t.get("id", "?"))

	# Subtítulos
	if (trailer.get("idiomas_subtitulos", []) as Array).size() < 2:
		errores.append("Menos de 2 idiomas de subtítulos")

	# Anti-spoiler
	if (data.get("checklist_antiespoiler", []) as Array).is_empty():
		errores.append("Checklist anti-spoiler vacío")
	return errores

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M98] TrailerValidator: OK — especificación de tráiler válida"
	var lineas: Array = ["[M98] TrailerValidator: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)