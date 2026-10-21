# Modelo: deepseek-v4.1-flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-21
#
# M88 / M87 (i18n b3) - Auditor de glifos: mide si las fuentes REALES cubren los
# caracteres que exigen los catalogos .po.
#
# Por que existe (punto ciego medido el 2026-10-21):
#   El unico chequeo de cobertura de glifos del repo (bloque B de
#   `test_fuentes_reales_m88.gd`) decidia "falta el glifo" con
#   `get_string_size(ch).x <= 0.0`. ESO NO PRUEBA NADA: un glifo ausente se dibuja
#   como `.notdef` (la caja) y su avance NO es cero. Medido en este proyecto:
#   U+2192 (flecha) da **14.0 px** en las 3 fuentes de produccion con
#   `has_char() == false`. El detector por ancho reportaba "no falta nada"
#   mientras 31 claves x 2 idiomas del catalogo usan la flecha que ninguna
#   fuente tiene.
#   -> La unica prueba valida de "el glifo existe" es `Font.has_char(codepoint)`.
#
# Segundo punto ciego, del parser: contar los caracteres del ARCHIVO .po incluye
# los COMENTARIOS. Medido: el .po tiene 16 no-ASCII por bytes pero solo 14 en el
# texto que se muestra (U+2500 y el guion de las lineas `# ──` solo viven en
# comentarios). Por eso este auditor parsea ENTRADAS (msgid/msgstr/msgstr[n]) y
# descarta comentarios y la cabecera (msgid "").
#
# API pura (sin autoloads, corre en `--script`):
#   caracteres_de_po(rutas) -> {"chars": {int: [claves]}, "entradas": n, "formas": n, ...}
#   faltantes(fuente, codepoints) -> Array[int]
#   auditar(fuentes, rutas_po) -> informe por fuente
#   sustitutos_para(faltantes) -> {"U+2192": "»", ...} desde data/fonts/glifos_sustitutos.json
#   cobertura_tras_sustituir(res, sustitutos) -> cuantos faltantes quedan sin sustituto
extends RefCounted

const RUTA_SUSTITUTOS := "res://data/fonts/glifos_sustitutos.json"

## Campos de un .po que SON texto mostrable. `msgid` es la CLAVE en este
## proyecto, no texto: se excluye del conteo de glifos requeridos.
const CAMPOS_TEXTO := ["msgstr"]


## Parsea un .po y devuelve {clave: [formas...]}. Las formas son los msgstr
## (uno solo, o msgstr[0..n] en las entradas plurales). `msgid` vacio = cabecera.
static func entradas_po(texto: String) -> Dictionary:
	var entradas: Dictionary = {}
	var clave_actual := ""
	for campo in _campos(texto):
		var nombre: String = str(campo[0])
		var valor: String = str(campo[1])
		if nombre == "msgid":
			clave_actual = valor
			if not entradas.has(clave_actual):
				entradas[clave_actual] = []
			continue
		if clave_actual.is_empty():
			continue
		if nombre == "msgstr" or nombre.begins_with("msgstr["):
			var formas: Array = entradas[clave_actual]
			formas.append(valor)
			entradas[clave_actual] = formas
	return entradas


## Caracteres que el catalogo exige, con la lista de claves que usa cada uno.
## Excluye comentarios (nunca llegan a `_campos`) y la cabecera (msgid "").
static func caracteres_de_po(rutas: Array) -> Dictionary:
	var chars: Dictionary = {}
	var entradas := 0
	var formas := 0
	var con_texto := 0
	for ruta in rutas:
		var r: String = str(ruta)
		if not FileAccess.file_exists(r):
			continue
		var entradas_locales: Dictionary = entradas_po(FileAccess.get_file_as_string(r))
		for clave in entradas_locales.keys():
			var k: String = str(clave)
			entradas += 1
			var lista: Array = entradas_locales[clave]
			if k.is_empty():
				continue
			con_texto += 1
			for forma in lista:
				var f: String = str(forma)
				formas += 1
				for i in f.length():
					var cp: int = f.unicode_at(i)
					if cp < 32 or cp == 127:
						continue
					if not chars.has(cp):
						chars[cp] = []
					var claves: Array = chars[cp]
					if not claves.has(k):
						claves.append(k)
					chars[cp] = claves
	return {
		"chars": chars,
		"entradas": entradas,
		"entradas_con_texto": con_texto,
		"formas": formas,
		"codepoints": chars.size(),
		"rutas": rutas.duplicate(),
	}


## Glifos que la fuente NO tiene. `has_char` es la unica prueba valida:
## el ancho no distingue un glifo real de un `.notdef`.
static func faltantes(fuente: Font, codepoints: Array) -> Array:
	var out: Array = []
	if fuente == null:
		return out
	for cp in codepoints:
		var c: int = int(cp)
		if c < 32 or c == 127:
			continue
		if not fuente.has_char(c):
			out.append(c)
	out.sort()
	return out


## Audita una lista de fuentes contra uno o varios .po.
## Devuelve {ok, po, fuentes: [{ruta, faltantes, cubiertos}], faltantes_globales}.
static func auditar(fuentes: Array, rutas_po: Array) -> Dictionary:
	var po: Dictionary = caracteres_de_po(rutas_po)
	var cps: Array = po["chars"].keys()
	cps.sort()
	var informe_fuentes: Array = []
	var globales: Dictionary = {}
	for ruta in fuentes:
		var r: String = str(ruta)
		var f: Font = null
		if FileAccess.file_exists(r):
			f = load(r) as Font
		var faltan: Array = faltantes(f, cps)
		for cp in faltan:
			globales[int(cp)] = true
		informe_fuentes.append({
			"ruta": r,
			"carga": f != null,
			"faltantes": faltan,
			"cubiertos": cps.size() - faltan.size(),
			"total": cps.size(),
		})
	var gl: Array = globales.keys()
	gl.sort()
	return {
		"ok": gl.is_empty(),
		"po": po,
		"fuentes": informe_fuentes,
		"faltantes_globales": gl,
	}


## Tabla de sustitutos declarada como DATO (data/fonts/glifos_sustitutos.json).
## Devuelve {codepoint: "texto sustituto"} solo para los codepoints pedidos.
static func sustitutos_para(faltantes_cp: Array) -> Dictionary:
	var out: Dictionary = {}
	if not FileAccess.file_exists(RUTA_SUSTITUTOS):
		return out
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_SUSTITUTOS))
	if typeof(parsed) != TYPE_DICTIONARY:
		return out
	var datos: Dictionary = parsed
	var tabla: Array = datos.get("sustitutos", [])
	for fila in tabla:
		if typeof(fila) != TYPE_DICTIONARY:
			continue
		var d: Dictionary = fila
		var cp: String = str(d.get("codepoint", ""))
		var reemplazo: String = str(d.get("sustituto", ""))
		if cp.is_empty() or reemplazo.is_empty():
			continue
		for f in faltantes_cp:
			if "U+%04X" % int(f) == cp.to_upper():
				out[int(f)] = reemplazo
	return out


## Cuantos faltantes quedan SIN sustituto declarado (0 = mitigable por tabla).
static func sin_sustituto(faltantes_cp: Array, sustitutos: Dictionary) -> Array:
	var out: Array = []
	for f in faltantes_cp:
		if not sustitutos.has(int(f)):
			out.append(int(f))
	return out


## Texto legible del informe (ASCII en el log, UTF-8 en consola).
static func informe(res: Dictionary) -> String:
	var po: Dictionary = res.get("po", {})
	var lineas: Array = []
	lineas.append("[M88] Auditor de glifos: %d entradas (%d formas), %d codepoints requeridos" % [
		int(po.get("entradas", 0)), int(po.get("formas", 0)), int(po.get("codepoints", 0))])
	for f in res.get("fuentes", []):
		var d: Dictionary = f
		var txt := ""
		for cp in d.get("faltantes", []):
			txt += "U+%04X " % int(cp)
		lineas.append("  %s: %d/%d cubiertos, faltan %d [%s]" % [
			String(d.get("ruta", "")).get_file(), int(d.get("cubiertos", 0)),
			int(d.get("total", 0)), (d.get("faltantes", []) as Array).size(), txt.strip_edges()])
	var gl: Array = res.get("faltantes_globales", [])
	if gl.is_empty():
		lineas.append("  VEREDICTO: todas las fuentes cubren el catalogo")
	else:
		var txt2 := ""
		for cp in gl:
			txt2 += "U+%04X " % int(cp)
		lineas.append("  VEREDICTO: %d codepoint(s) sin glifo en ninguna fuente [%s]" % [
			gl.size(), txt2.strip_edges()])
	return "\n".join(lineas)


## Campos (nombre, valor) de un .po, con continuaciones y escapes resueltos.
## Los comentarios (`#`) y las lineas vacias se descartan.
static func _campos(texto: String) -> Array:
	var campos: Array = []
	for linea in texto.split("\n"):
		var l: String = str(linea).strip_edges()
		if l.is_empty() or l.begins_with("#"):
			continue
		if l.begins_with("\""):
			if not campos.is_empty():
				var previo: Array = campos[campos.size() - 1]
				previo[1] = str(previo[1]) + _desescapar(l)
				campos[campos.size() - 1] = previo
			continue
		var sp: int = l.find(" ")
		if sp <= 0:
			continue
		campos.append([l.substr(0, sp), _desescapar(l.substr(sp + 1).strip_edges())])
	return campos


## Quita las comillas que rodean el valor y resuelve los escapes de gettext
## (`\"`, `\\`, `\n`, `\t`) en UNA pasada. Reemplazar en cadena confunde
## `\\n` (barra + n) con `\n` (salto), y el orden de los replaces cambia el
## resultado: se resuelve caracter por caracter.
static func _desescapar(valor: String) -> String:
	var v: String = valor.strip_edges()
	if v.begins_with("\""):
		v = v.substr(1)
	if v.length() > 0 and v.ends_with("\""):
		v = v.substr(0, v.length() - 1)
	var out := ""
	var i := 0
	while i < v.length():
		var c: int = v.unicode_at(i)
		if c == 92 and i + 1 < v.length():  # barra invertida
			var n: int = v.unicode_at(i + 1)
			match n:
				110:
					out += "\n"
				116:
					out += "\t"
				34:
					out += "\""
				92:
					out += "\\"
				_:
					out += String.chr(n)
			i += 2
			continue
		out += String.chr(c)
		i += 1
	return out
