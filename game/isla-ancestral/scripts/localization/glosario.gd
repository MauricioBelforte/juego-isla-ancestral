class_name Glosario
extends RefCounted
## M87 — Glosario de terminología canónica y validador de consistencia (ítem 73).
##
## El glosario fija, por término, la forma española y la traducción inglesa
## obligatoria. `verificar()` recorre el catálogo español, encuentra las claves
## que usan cada término y exige que su versión inglesa use la forma canónica (o
## una variante declarada). Detecta así el problema real de un catálogo traducido
## por varias manos: el mismo término español renderizado con sinónimos distintos
## según la clave ("Wood" en una, "Timber" en otra).
##
## El cotejo NO distingue mayúsculas ni acentos (un traductor puede escribir
## "Energia" o "Energía"), pero el glosario documenta la forma correcta.
##
## Determinista y sin dependencias: recibe los catálogos ya cargados, así sirve
## tanto al autoload como a un script de CI.

const RUTA_DEFECTO := "res://data/localization/glosario.json"

## Carga el glosario desde disco. Devuelve {} si falta o es inválido.
static func cargar(ruta: String = RUTA_DEFECTO) -> Dictionary:
	if not FileAccess.file_exists(ruta):
		return {}
	var f := FileAccess.open(ruta, FileAccess.READ)
	if f == null:
		return {}
	var crudo: String = f.get_as_text()
	f.close()
	var datos: Variant = JSON.parse_string(crudo)
	if datos is Dictionary:
		return datos as Dictionary
	return {}

## Lista de términos del glosario (cada uno un Dictionary).
static func terminos(glosario: Dictionary) -> Array:
	return glosario.get("terminos", []) as Array

## Normaliza para cotejar: minúsculas y sin acentos, diéresis ni eñe.
static func normalizar(texto: String) -> String:
	var s: String = texto.to_lower()
	s = s.replace("á", "a").replace("é", "e").replace("í", "i")
	s = s.replace("ó", "o").replace("ú", "u").replace("ü", "u")
	s = s.replace("ñ", "n").replace("à", "a").replace("è", "e")
	return s

## ¿La entrada es un TÉRMINO (etiqueta, nombre) y no PROSA?
##
## El glosario gobierna etiquetas y nombres, no frases narrativas. En una oración
## el término aparece conjugado o como parte de otra idea, y exigirle la forma
## canónica produce falsos positivos. Medido en M87 iter. 6: `M68.NARR.C4.01`
## («The wind shifts as you leave the harbour.») se marcaba como incumplimiento
## de SALIR sólo porque su texto español contiene «salir».
static func es_termino(texto: String) -> bool:
	var t: String = texto.strip_edges()
	if t.is_empty() or t.length() > 40:
		return false
	if t.contains("\n"):
		return false
	for cierre in [".", "!", "?", ":"]:
		if t.ends_with(cierre):
			return false
	return true

## ¿`termino` aparece en `texto` como PALABRA COMPLETA y no dentro de otra?
## Evita que «salir» se detecte dentro de «salirse» o «salirnos».
static func contiene_palabra(texto: String, termino: String) -> bool:
	if termino.is_empty():
		return false
	var desde := 0
	while true:
		var i: int = texto.find(termino, desde)
		if i < 0:
			return false
		var antes_ok := true
		var despues_ok := true
		if i > 0:
			antes_ok = not _es_letra(texto[i - 1])
		var fin: int = i + termino.length()
		if fin < texto.length():
			despues_ok = not _es_letra(texto[fin])
		if antes_ok and despues_ok:
			return true
		desde = i + 1
	return false

## Tras `normalizar()` las únicas letras posibles son a-z.
static func _es_letra(c: String) -> bool:
	return c >= "a" and c <= "z"

## Verifica la consistencia del catálogo inglés respecto del glosario.
##
## Devuelve { total, usados, sin_uso, inconsistencias, ok }. Cada inconsistencia
## es { termino, clave, esperado, obtenido }. Las claves listadas en el campo
## opcional `exentas` de un término no se exigen (p. ej. el título del juego, que
## es nombre propio y no se traduce).
static func verificar(glosario: Dictionary, cat_es: Dictionary, cat_en: Dictionary) -> Dictionary:
	var inconsistencias: Array = []
	var usados: Array = []
	var sin_uso: Array = []

	for bruto in terminos(glosario):
		var term: Dictionary = bruto as Dictionary
		var id: String = str(term.get("id", term.get("es", "?")))
		var es_form: String = normalizar(str(term.get("es", "")))
		var en_form: String = str(term.get("en", ""))
		if es_form.is_empty() or en_form.is_empty():
			continue

		var aceptadas: Array[String] = []
		aceptadas.append(normalizar(en_form))
		for v in (term.get("variantes_en", []) as Array):
			aceptadas.append(normalizar(str(v)))

		var exentas: Array[String] = []
		for e in (term.get("exentas", []) as Array):
			exentas.append(str(e))

		var encontrado := false
		for clave in cat_es:
			var clave_s: String = str(clave)
			if clave_s in exentas:
				continue
			var t_es_cruda: String = str(cat_es[clave])
			if not es_termino(t_es_cruda):
				continue
			var t_es: String = normalizar(t_es_cruda)
			if not contiene_palabra(t_es, es_form):
				continue
			encontrado = true
			var t_en: String = normalizar(str(cat_en.get(clave, "")))
			var coincide := false
			for a in aceptadas:
				if t_en.contains(a):
					coincide = true
					break
			if not coincide:
				inconsistencias.append({
					"termino": id,
					"clave": clave_s,
					"esperado": en_form,
					"obtenido": str(cat_en.get(clave, "")),
				})

		if encontrado:
			usados.append(id)
		else:
			sin_uso.append(id)

	return {
		"total": terminos(glosario).size(),
		"usados": usados,
		"sin_uso": sin_uso,
		"inconsistencias": inconsistencias,
		"ok": inconsistencias.is_empty(),
	}

## Informe legible del resultado de `verificar()`.
static func formatear_informe(r: Dictionary) -> String:
	var lineas: PackedStringArray = PackedStringArray()
	lineas.append("── Glosario: consistencia de terminología ──")
	lineas.append("términos en el glosario : %d" % int(r.get("total", 0)))
	lineas.append("términos en uso         : %d" % (r.get("usados", []) as Array).size())
	lineas.append("términos sin uso        : %d" % (r.get("sin_uso", []) as Array).size())
	var inc: Array = r.get("inconsistencias", []) as Array
	lineas.append("inconsistencias         : %d" % inc.size())
	for i in inc:
		var d: Dictionary = i as Dictionary
		lineas.append("  · %s en %s → esperado «%s», obtenido «%s»" % [
			d.get("termino", "?"), d.get("clave", "?"),
			d.get("esperado", "?"), d.get("obtenido", "?"),
		])
	return "\n".join(lineas)
