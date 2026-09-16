class_name AnalizadorLayout
extends RefCounted
## M87 — Analizador de encaje de texto y expansión i18n.
##
## Mide con métricas REALES de fuente (`Font.get_string_size`) cuánto ocupa cada
## texto traducido, si cabe en su contenedor y cuánto crece el inglés respecto del
## español. Convierte en EVIDENCIA MEDIBLE lo que hasta ahora figuraba como
## "requiere QA visual" (ítems C del checklist de M87).
##
## Determinista y apto para headless: NO depende del render. La fuente se INYECTA,
## así el mismo analizador sirve con la fuente por defecto del tema
## (`ThemeDB.fallback_font`) o con la fuente real del juego cuando M46/M88
## entreguen los `.ttf` (ver BUG-042: hoy los `.ttf` del repo son páginas HTML 404).
##
## Uso típico:
##     var r := AnalizadorLayout.analizar(entradas, fuente, 320.0, 40.0)
##     print(AnalizadorLayout.formatear_informe(r))

## Criterio del checklist (ítem 72): el inglés puede ser hasta +30% más largo.
const UMBRAL_EXPANSION := 1.30
## Tamaño tipográfico de referencia si el llamador no indica otro.
const TAMANO_DEFECTO := 16
## Reducción máxima tolerada al recomendar "reducir_fuente" (no degradar legibilidad).
const FACTOR_MINIMO_FUENTE := 0.80
## Longitud a partir de la cual una palabra se considera "larga sin espacios" (ítem 128).
const LARGO_PALABRA_LARGA := 14

## ── Medición ─────────────────────────────────────────────

## Ancho/alto reales del texto con la fuente y el tamaño dados.
##
## `ancho_max <= 0` = una sola línea (`get_string_size`).
## `ancho_max > 0`  = bloque envuelto a ese ancho (`get_multiline_string_size`).
##
## ⚠️ NO usar `get_string_size` para comprobar encaje: con un ancho dado
## **recorta el ancho** y devuelve la altura de **una sola línea**. Medido en
## headless: «Settings of the island game» a 60 px da `(55, 23)` —como si fuera
## una línea que cabe— cuando en realidad ocupa 4 líneas (92 px de alto); y una
## palabra sin espacios a 60 px da `(56, 23)` en vez de sus 427 px reales, así
## que un desborde evidente pasaría por «cabe». `get_multiline_string_size`
## devuelve el bloque de verdad (`(67, 92)` y `(427, 23)` en esos mismos casos).
static func medir(fuente: Font, texto: String, tamano: int = TAMANO_DEFECTO,
		ancho_max: float = -1.0) -> Vector2:
	if fuente == null:
		return Vector2.ZERO
	if ancho_max > 0.0:
		return fuente.get_multiline_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, ancho_max, tamano)
	return fuente.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano)

## Ancho/alto de una línea SIN wrap (medida de referencia).
static func medir_linea(fuente: Font, texto: String, tamano: int = TAMANO_DEFECTO) -> Vector2:
	return medir(fuente, texto, tamano, -1.0)

## Altura de una línea de la fuente al tamaño dado.
static func altura_linea(fuente: Font, tamano: int = TAMANO_DEFECTO) -> float:
	if fuente == null:
		return 0.0
	return fuente.get_height(tamano)

## ¿El texto cabe en un contenedor de ancho × alto al tamaño dado?
## Con wrap activo, "cabe" exige que la altura resultante no supere el alto.
static func cabe(fuente: Font, texto: String, ancho_max: float, alto_max: float,
		tamano: int = TAMANO_DEFECTO) -> bool:
	if fuente == null or ancho_max <= 0.0 or alto_max <= 0.0:
		return false
	var caja: Vector2 = medir(fuente, texto, tamano, ancho_max)
	return caja.x <= ancho_max + 0.5 and caja.y <= alto_max + 0.5

## Cuánto más ancho es el texto inglés respecto del español (razón ≥ 0).
## Devuelve 0.0 si el español mide 0 (no hay base de comparación).
static func razon_expansion(texto_es: String, texto_en: String, fuente: Font,
		tamano: int = TAMANO_DEFECTO) -> float:
	var ancho_es: float = medir_linea(fuente, texto_es, tamano).x
	if ancho_es <= 0.0:
		return 0.0
	return medir_linea(fuente, texto_en, tamano).x / ancho_es

## Palabras sin espacios más largas que `minimo` caracteres (ítem 128).
## Devuelve un `Array[String]` (no un PackedStringArray) para que el llamador
## pueda compararlo con literales sin castear.
static func palabras_largas(texto: String, minimo: int = LARGO_PALABRA_LARGA) -> Array[String]:
	var salida: Array[String] = []
	for bruta in texto.split(" ", false):
		var palabra: String = str(bruta).strip_edges()
		if palabra.length() > minimo:
			salida.append(palabra)
	return salida

## ── Mitigaciones ─────────────────────────────────────────

## Inserta oportunidades de corte en una palabra sin espacios, cada `cada`
## caracteres, con un espacio de ancho cero (U+200B). El texto NO cambia
## visualmente: sólo permite que el TextServer parta la palabra.
static func partir_palabra(palabra: String, cada: int = 6) -> String:
	if cada <= 0 or palabra.length() <= cada:
		return palabra
	var trozos: Array[String] = []
	var i := 0
	while i < palabra.length():
		trozos.append(palabra.substr(i, cada))
		i += cada
	return "\u200b".join(trozos)

## Trunca el texto para que quepa en `ancho_max`, agregando "…" si sobró algo.
static func truncar_con_puntos(fuente: Font, texto: String, ancho_max: float,
		tamano: int = TAMANO_DEFECTO) -> String:
	if fuente == null or ancho_max <= 0.0:
		return texto
	if medir_linea(fuente, texto, tamano).x <= ancho_max:
		return texto
	var puntos := "…"
	var ancho_puntos: float = medir_linea(fuente, puntos, tamano).x
	var corte := ""
	for i in texto.length():
		var siguiente := corte + texto[i]
		if medir_linea(fuente, siguiente, tamano).x + ancho_puntos > ancho_max:
			break
		corte = siguiente
	if corte.is_empty():
		return puntos
	return corte + puntos

## Tamaño mínimo (entre `tamano_min` y `tamano`) que hace caber el texto.
## Devuelve -1 si ni siquiera en `tamano_min` cabe.
static func tamano_minimo_que_cabe(fuente: Font, texto: String, ancho_max: float,
		alto_max: float, tamano_min: int, tamano_max: int) -> int:
	if fuente == null:
		return -1
	var t := tamano_max
	while t >= tamano_min:
		if cabe(fuente, texto, ancho_max, alto_max, t):
			return t
		t -= 1
	return -1

## Estrategia recomendada para que el texto quepa:
## "cabe" · "reducir_fuente" · "partir_palabra" · "truncar".
static func estrategia(fuente: Font, texto: String, ancho_max: float, alto_max: float,
		tamano: int = TAMANO_DEFECTO) -> String:
	if cabe(fuente, texto, ancho_max, alto_max, tamano):
		return "cabe"
	var minimo: int = int(floor(float(tamano) * FACTOR_MINIMO_FUENTE))
	if tamano_minimo_que_cabe(fuente, texto, ancho_max, alto_max, minimo, tamano) > 0:
		return "reducir_fuente"
	for palabra in palabras_largas(texto):
		if not partir_palabra(palabra).is_empty():
			return "partir_palabra"
	return "truncar"

## ── Análisis por lotes ───────────────────────────────────

## Analiza un conjunto de claves bilingües.
##
## `entradas` = { clave: {"es": texto, "en": texto} }.
## Devuelve { total, caben_es, caben_en, desbordan, expansion_maxima,
## expansion_media, claves_sobre_umbral, sobre_umbral, palabras_largas,
## detalle: { clave: {...} } }.
static func analizar(entradas: Dictionary, fuente: Font, ancho_max: float,
		alto_max: float, tamano: int = TAMANO_DEFECTO) -> Dictionary:
	var detalle: Dictionary = {}
	var caben_es := 0
	var caben_en := 0
	var desbordan: Array[String] = []
	var sobre_umbral: Array[String] = []
	var expansion_maxima := 0.0
	var suma_expansion := 0.0
	var medidas := 0
	var largas: Array[String] = []

	for clave in entradas:
		var par: Dictionary = entradas[clave] as Dictionary
		var t_es: String = str(par.get("es", ""))
		var t_en: String = str(par.get("en", ""))
		var c_es: bool = cabe(fuente, t_es, ancho_max, alto_max, tamano)
		var c_en: bool = cabe(fuente, t_en, ancho_max, alto_max, tamano)
		var razon: float = razon_expansion(t_es, t_en, fuente, tamano)
		if c_es:
			caben_es += 1
		if c_en:
			caben_en += 1
		if not c_es or not c_en:
			desbordan.append(str(clave))
		if razon > 0.0:
			suma_expansion += razon
			medidas += 1
			expansion_maxima = maxf(expansion_maxima, razon)
			if razon > UMBRAL_EXPANSION:
				sobre_umbral.append(str(clave))
		for p in palabras_largas(t_en):
			largas.append(str(p))
		detalle[clave] = {
			"es": t_es,
			"en": t_en,
			"ancho_es": medir_linea(fuente, t_es, tamano).x,
			"ancho_en": medir_linea(fuente, t_en, tamano).x,
			"razon": razon,
			"cabe_es": c_es,
			"cabe_en": c_en,
			"estrategia_en": estrategia(fuente, t_en, ancho_max, alto_max, tamano),
		}

	return {
		"total": entradas.size(),
		"caben_es": caben_es,
		"caben_en": caben_en,
		"desbordan": desbordan,
		"expansion_maxima": expansion_maxima,
		"expansion_media": (suma_expansion / float(medidas)) if medidas > 0 else 0.0,
		"claves_sobre_umbral": sobre_umbral.size(),
		"sobre_umbral": sobre_umbral,
		"palabras_largas": largas,
		"detalle": detalle,
	}

## Informe legible del resultado de `analizar()` (consola / CI).
static func formatear_informe(r: Dictionary) -> String:
	var lineas: Array[String] = []
	lineas.append("── AnalizadorLayout: encaje y expansión ──")
	lineas.append("claves analizadas : %d" % int(r.get("total", 0)))
	lineas.append("caben en español  : %d" % int(r.get("caben_es", 0)))
	lineas.append("caben en inglés   : %d" % int(r.get("caben_en", 0)))
	lineas.append("desbordan         : %d" % (r.get("desbordan", []) as Array).size())
	lineas.append("expansión máxima  : %.3f" % float(r.get("expansion_maxima", 0.0)))
	lineas.append("expansión media   : %.3f" % float(r.get("expansion_media", 0.0)))
	lineas.append("sobre umbral %.2f : %d" % [UMBRAL_EXPANSION, int(r.get("claves_sobre_umbral", 0))])
	lineas.append("palabras largas   : %d" % (r.get("palabras_largas", []) as Array).size())
	return "\n".join(lineas)
