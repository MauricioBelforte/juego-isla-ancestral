# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-13
#
# M87: Localización — ValidadorPO (herramienta dev/CI, RF21 + RN10 + RN12 + RF20).
# Valida catálogos gettext .po de forma determinista y sin depender del motor:
#   · bytes  : UTF-8 válido, sin BOM (AGENTS.md §28), saltos LF (RN10)
#   · cabecera: Content-Type / Language / Plural-Forms (RN12, compatibilidad Poedit)
#   · estructura: msgid ↔ msgstr, plurales contiguos desde 0, duplicados, sintaxis
#   · convención de claves MODULO.SECCION.CLAVE UPPER_SNAKE (RF20) con excepciones
#   · coherencia entre idiomas: claves faltantes/sobrantes y placeholders (RF21)
#   · no-traducidas: msgstr idéntico al de la fuente (hueco que validar_catalogos no ve)
#     — exento con el comentario de traductor `#. no-traducir: <motivo>` (P5)
#
# Uso: ValidadorPO.validar_par("res://locales/es.po", "res://locales/en.po")
# ⚠️ class_name nuevo → requiere `--headless --path game/isla-ancestral --editor --quit`
#    una vez para registrarse en la caché de clases globales.

class_name ValidadorPO
extends RefCounted

const REGEX_CLAVE := "^[A-Z][A-Z0-9_]*(\\.[A-Z0-9_]+)+$"
const REGEX_LLAVE := "\\{[a-zA-Z_][a-zA-Z0-9_]*\\}"
const REGEX_PRINTF := "%[sdf]"

## Claves que NO siguen MODULO.SECCION.CLAVE por diseño (excepciones documentadas).
## `npc.<id>`: el speaker_key de M21 es el id del NPC en los datos de diálogo
## (data/dialogues/*.json), en minúsculas y con el prefijo `npc.` — no es una clave
## de UI y renombrarla rompería la integración M21/M22.
const EXCEPCIONES_CLAVE: Array[String] = ["npc.catalina"]

## Claves cuyo msgstr puede coincidir literalmente entre idiomas sin ser un error
## de traducción (nombres propios y anglicismos de uso idéntico en ambos idiomas).
## · `npc.catalina`   → nombre propio del NPC (además es clave de datos de M21).
## · `SETTINGS.SLOTS` → "Slots" es el término que el propio juego usa en español
##   (convive con SETTINGS.SLOT_LIBRE = "Slot libre"). Pendiente de revisión
##   humana (RN9); si un traductor prefiere "Ranuras", sale de esta lista.
##
## Esta lista es el último recurso: para textos sin palabras que traducir
## (plantillas, códigos, símbolos) la exención se declara EN EL PROPIO .po con
## `MARCADOR_NO_TRADUCIBLE`, de modo que el traductor la ve en Poedit y no hay
## que tocar código. Ver `no_traducibles` en `validar_archivo`.
const NO_TRADUCIBLES: Array[String] = ["npc.catalina", "SETTINGS.SLOTS"]

## Marcador de comentario que exime a una entrada de la regla P5 (msgstr idéntico
## a la fuente). Es un comentario de traductor gettext estándar (`#.` = extraído),
## así que Poedit y `msgfmt` lo conservan y no lo interpretan como texto.
##
##   #. no-traducir: plantilla sin palabras (sólo flecha, distancia y unidad)
##   msgid "M68.SIGN.GENERICO"
##   msgstr "→ {destino} · {metros} m"
##
## Sin el marcador, un msgstr idéntico sigue siendo un AVISO (P5): la heurística
## no puede distinguir "sin traducir" de "no hay nada que traducir" por sí sola.
const MARCADOR_NO_TRADUCIBLE := "no-traducir"

## ── API pública ──────────────────────────────────────────

## Valida UN catálogo (bytes + cabecera + estructura + convención de claves).
## Devuelve {ruta, locale, entradas, claves, claves_plural, textos, placeholders,
##          no_traducibles, errores, avisos, ok}.
## `no_traducibles` son las claves exentas de P5 declaradas en el propio archivo
## con `MARCADOR_NO_TRADUCIBLE` (comentario `#. no-traducir: ...`).
static func validar_archivo(ruta: String, locale_esperado: String = "") -> Dictionary:
	var r: Dictionary = {
		"ruta": ruta, "locale": "", "entradas": 0, "claves": [], "claves_plural": [],
		"textos": {}, "placeholders": {}, "no_traducibles": [],
		"errores": [], "avisos": [], "ok": false,
	}
	if not FileAccess.file_exists(ruta):
		_err(r, "R1 archivo inexistente")
		return r
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes(ruta)
	bytes = _validar_bytes(r, bytes)
	var texto: String = bytes.get_string_from_utf8()
	var entradas: Array = _parsear(texto)
	r["entradas"] = entradas.size()
	if entradas.is_empty():
		_err(r, "R4 catálogo sin entradas")
		return r
	_validar_cabecera(r, entradas[0], locale_esperado)
	_validar_entradas(r, entradas)
	for e in entradas:
		var clave: String = str(e.get("msgid", ""))
		if clave.is_empty():
			continue
		if str(e.get("comentarios", "")).contains(MARCADOR_NO_TRADUCIBLE):
			(r["no_traducibles"] as Array).append(clave)
	r["ok"] = (r["errores"] as Array).is_empty()
	return r


## Valida DOS catálogos como par fuente↔traducción (RF21 completo).
## Devuelve {ok, fuente, traduccion, faltantes_en_traduccion, faltantes_en_fuente,
##          placeholders_desalineados, no_traducidas, exentas_p5, errores, avisos}.
## `no_traducidas` NO incluye las claves exentas (const `NO_TRADUCIBLES` o el
## marcador `#. no-traducir:` presente en cualquiera de los dos archivos); esas
## se listan aparte en `exentas_p5` para que la exención sea auditable.
static func validar_par(ruta_fuente: String, ruta_traduccion: String) -> Dictionary:
	var a: Dictionary = validar_archivo(ruta_fuente)
	var b: Dictionary = validar_archivo(ruta_traduccion)
	var r: Dictionary = {
		"ok": false, "fuente": a, "traduccion": b,
		"faltantes_en_traduccion": [], "faltantes_en_fuente": [],
		"placeholders_desalineados": [], "no_traducidas": [], "exentas_p5": [],
		"errores": [], "avisos": [],
	}
	r["errores"].append_array(a["errores"])
	r["errores"].append_array(b["errores"])
	var exentas: Dictionary = {}
	for k in NO_TRADUCIBLES:
		exentas[k] = true
	for k in a["no_traducibles"]:
		exentas[k] = true
	for k in b["no_traducibles"]:
		exentas[k] = true
	var set_b: Dictionary = _conjunto(b["claves"])
	var set_a: Dictionary = _conjunto(a["claves"])
	for k in a["claves"]:
		if not set_b.has(k):
			r["faltantes_en_traduccion"].append(k)
	for k in b["claves"]:
		if not set_a.has(k):
			r["faltantes_en_fuente"].append(k)
	for k in a["claves"]:
		if not set_b.has(k):
			continue
		var pa: Dictionary = (a["placeholders"] as Dictionary).get(k, {})
		var pb: Dictionary = (b["placeholders"] as Dictionary).get(k, {})
		if pa != pb:
			r["placeholders_desalineados"].append({"clave": k, "fuente": pa, "traduccion": pb})
		if (b["textos"] as Dictionary).get(k, "") != (a["textos"] as Dictionary).get(k, ""):
			continue
		if exentas.has(k):
			(r["exentas_p5"] as Array).append(k)
		else:
			r["no_traducidas"].append(k)
	var nf: int = (r["faltantes_en_traduccion"] as Array).size()
	if nf > 0:
		r["errores"].append("P1 %d clave(s) de la fuente ausentes en la traducción" % nf)
	var np: int = (r["placeholders_desalineados"] as Array).size()
	if np > 0:
		r["errores"].append("P3 %d clave(s) con placeholders desalineados entre idiomas" % np)
	if not (r["faltantes_en_fuente"] as Array).is_empty():
		r["avisos"].append("P2 %d clave(s) huérfanas en la traducción" % (r["faltantes_en_fuente"] as Array).size())
	if not (r["no_traducidas"] as Array).is_empty():
		r["avisos"].append("P5 %d clave(s) sin traducir (msgstr idéntico a la fuente)" % (r["no_traducidas"] as Array).size())
	r["ok"] = (r["errores"] as Array).is_empty()
	return r


## Informe legible para consola / CI.
static func formatear_informe(r: Dictionary) -> String:
	var l: Array[String] = []
	if r.has("fuente"):
		var a: Dictionary = r["fuente"]
		var b: Dictionary = r["traduccion"]
		l.append("── ValidadorPO: %s (%d entradas) ↔ %s (%d entradas)" % [
			a["ruta"], a["entradas"], b["ruta"], b["entradas"]])
		_volcar(l, "ERRORES", r["errores"])
		_volcar(l, "AVISOS", r["avisos"])
		_volcar(l, "Faltantes en la traducción", r["faltantes_en_traduccion"])
		_volcar(l, "Huérfanas en la traducción", r["faltantes_en_fuente"])
		_volcar(l, "Sin traducir", r["no_traducidas"])
		_volcar(l, "Exentas de P5 (marcador no-traducir)", r["exentas_p5"])
		for d in r["placeholders_desalineados"]:
			l.append("  placeholder desalineado %s: %s vs %s" % [d["clave"], d["fuente"], d["traduccion"]])
	else:
		l.append("── ValidadorPO: %s (%d entradas, locale=%s)" % [r["ruta"], r["entradas"], r["locale"]])
		_volcar(l, "ERRORES", r["errores"])
		_volcar(l, "AVISOS", r["avisos"])
	l.append("RESULTADO: " + ("OK" if r["ok"] else "CON ERRORES"))
	return "\n".join(l)


## Extrae los placeholders de un texto (+ formas plurales) para comparar idiomas.
static func placeholders_de(msgstr: String, plurales: Dictionary = {}) -> Dictionary:
	var textos: Array[String] = [msgstr]
	for k in plurales:
		textos.append(str(plurales[k]))
	var llaves: Array = []
	var printf: Array = []
	var printf_n: int = 0
	for t in textos:
		for m in _buscar_todos(t, REGEX_LLAVE):
			if not llaves.has(m):
				llaves.append(m)
		for m in _buscar_todos(t, REGEX_PRINTF):
			printf_n += 1
			if not printf.has(m):
				printf.append(m)
	var out: Dictionary = {}
	if not llaves.is_empty():
		out["llaves"] = llaves
	if not printf.is_empty():
		out["printf"] = printf
		out["printf_n"] = printf_n
	return out


## ¿La clave respeta MODULO.SECCION.CLAVE en UPPER_SNAKE (RF20)?
static func clave_cumple_convencion(clave: String) -> bool:
	if clave in EXCEPCIONES_CLAVE:
		return true
	var re := RegEx.new()
	re.compile(REGEX_CLAVE)
	return re.search(clave) != null

## ── Reglas de bytes (R1-R3) ──────────────────────────────

static func _validar_bytes(r: Dictionary, bytes: PackedByteArray) -> PackedByteArray:
	if bytes.size() >= 3 and bytes.slice(0, 3) == PackedByteArray([0xEF, 0xBB, 0xBF]):
		_err(r, "R1 BOM UTF-8 detectado (AGENTS.md §28: prohibido)")
		bytes = bytes.slice(3)
	var crlf: int = 0
	for b in bytes:
		if b == 13:
			crlf += 1
	if crlf > 0:
		_err(r, "R2 %d salto(s) CRLF (RN10 exige LF)" % crlf)
	if bytes.get_string_from_utf8().to_utf8_buffer() != bytes:
		_err(r, "R3 el archivo no es UTF-8 válido (posible cp1252)")
	return bytes

## ── Cabecera (R4) ────────────────────────────────────────

static func _validar_cabecera(r: Dictionary, cab: Dictionary, locale_esperado: String) -> void:
	if str(cab.get("msgid", "")) != "":
		_err(r, "R4 falta la cabecera gettext (msgid \"\" con Content-Type)")
		return
	var ms: String = str(cab.get("msgstr", ""))
	if not ms.contains("Content-Type"):
		_err(r, "R4 cabecera sin Content-Type (RN12 / Poedit)")
	if not ms.contains("Language:"):
		_err(r, "R4 cabecera sin Language:")
	else:
		r["locale"] = _campo(ms, "Language:")
		if locale_esperado != "" and r["locale"] != locale_esperado:
			_avs(r, "R4 Language=%s no coincide con lo esperado (%s)" % [r["locale"], locale_esperado])
	if not ms.contains("Plural-Forms"):
		_avs(r, "R4 cabecera sin Plural-Forms")

## ── Entradas (R5-R13) ────────────────────────────────────

static func _validar_entradas(r: Dictionary, entradas: Array) -> void:
	var vistos: Dictionary = {}
	for e in entradas:
		var clave: String = str(e.get("msgid", ""))
		if clave.is_empty():
			continue
		if vistos.has(clave):
			_err(r, "R7 msgid duplicado: " + clave)
		vistos[clave] = true
		r["claves"].append(clave)
		var plurales: Dictionary = e.get("plurales", {})
		var ms: String = str(e.get("msgstr", ""))
		var es_plural: bool = str(e.get("msgid_plural", "")) != ""
		if es_plural:
			if plurales.is_empty():
				_err(r, "R8 plural sin msgstr[0]: " + clave)
			if not plurales.has(0):
				_err(r, "R13 plural sin índice 0: " + clave)
			for k in plurales.keys():
				if str(plurales[k]).strip_edges().is_empty():
					_avs(r, "R6 msgstr[%d] vacío en %s" % [k, clave])
			if not ms.strip_edges().is_empty():
				_avs(r, "R8 entrada plural con msgstr simple además de msgstr[]: " + clave)
			r["claves_plural"].append(clave)
			r["textos"][clave] = " | ".join(plurales.values())
		else:
			if ms.strip_edges().is_empty():
				_err(r, "R6 msgstr vacío: " + clave)
			if not plurales.is_empty():
				_err(r, "R8 msgstr[] sin msgid_plural: " + clave)
			r["textos"][clave] = ms
		if not clave_cumple_convencion(clave):
			_avs(r, "R10 clave fuera de MODULO.SECCION.CLAVE (RF20): " + clave)
		if clave.contains(" ") or clave.contains("\t"):
			_err(r, "R11 clave con espacios: " + clave)
		if bool(e.get("corrupto", false)):
			_avs(r, "R5 línea msgstr[ malformada omitida en: " + clave)
		if bool(e.get("basura", false)):
			_avs(r, "R5 línea no reconocida en la entrada: " + clave)
		var ph: Dictionary = placeholders_de(ms, plurales)
		if not ph.is_empty():
			r["placeholders"][clave] = ph
			if ph.has("llaves") and ph.has("printf"):
				_avs(r, "R12 mezcla de convenciones {llave} y printf en: " + clave)

## ── Parseo .po (tolerante, con degradación) ──────────────

## Devuelve un Array ORDENADO de entradas:
## {msgid, msgid_plural, msgstr, plurales:{idx:texto}, comentarios, corrupto?, basura?}.
##
## `comentarios` son las líneas `#...` que preceden al msgid, concatenadas. Se
## conservan porque `MARCADOR_NO_TRADUCIBLE` viaja ahí (comentario de traductor
## `#.`), no en el texto. El buffer se vacía al crear la entrada y al consumir el
## `msgstr`, de modo que un comentario suelto dentro de una entrada no se
## contagia a la siguiente (una exención P5 falsa sería silenciosa).
static func _parsear(texto: String) -> Array:
	var entradas: Array = []
	var e: Dictionary = {}
	var ultimo: String = ""
	var comentarios: String = ""
	for raw in texto.split("\n"):
		var l: String = raw.strip_edges()
		if l.is_empty():
			continue
		if l.begins_with("#"):
			comentarios += l + "\n"
			continue
		if l.begins_with("msgid_plural"):
			e["msgid_plural"] = _descomillar(l.substr(12))
			ultimo = "msgid_plural"
		elif l.begins_with("msgid"):
			if e.has("msgid"):
				entradas.append(e)
				e = {}
			e["msgid"] = _descomillar(l.substr(5))
			e["msgid_plural"] = ""
			e["msgstr"] = ""
			e["plurales"] = {}
			e["comentarios"] = comentarios
			comentarios = ""
			ultimo = "msgid"
		elif l.begins_with("msgstr["):
			var i: int = _idx_msgstr(l)
			if i < 0:
				e["corrupto"] = true
				continue
			var v: String = _descomillar(l.substr(l.find("]") + 1))
			e["plurales"][i] = str((e["plurales"] as Dictionary).get(i, "")) + v
			comentarios = ""
			ultimo = "plural:" + str(i)
		elif l.begins_with("msgstr"):
			e["msgstr"] = _descomillar(l.substr(6))
			comentarios = ""
			ultimo = "msgstr"
		elif l.begins_with("\""):
			var c: String = _descomillar(l)
			if ultimo == "msgid":
				e["msgid"] = str(e["msgid"]) + c
			elif ultimo == "msgid_plural":
				e["msgid_plural"] = str(e["msgid_plural"]) + c
			elif ultimo == "msgstr":
				e["msgstr"] = str(e["msgstr"]) + c
			elif ultimo.begins_with("plural:"):
				var k: int = int(ultimo.split(":")[1])
				e["plurales"][k] = str((e["plurales"] as Dictionary).get(k, "")) + c
			else:
				e["basura"] = true
		else:
			e["basura"] = true
	if e.has("msgid"):
		entradas.append(e)
	return entradas

## Índice de "msgstr[N]"; -1 si falta, no es numérico o no cierra.
static func _idx_msgstr(l: String) -> int:
	var a: int = l.find("[")
	var b: int = l.find("]")
	if a < 0 or b <= a:
		return -1
	var t: String = l.substr(a + 1, b - a - 1).strip_edges()
	return int(t) if t.is_valid_int() else -1

static func _descomillar(s: String) -> String:
	var t: String = s.strip_edges()
	if t.length() >= 2 and t.begins_with("\"") and t.ends_with("\""):
		t = t.substr(1, t.length() - 2)
	return t.replace("\\n", "\n").replace("\\\"", "\"")

static func _campo(t: String, nombre: String) -> String:
	for linea in t.split("\n"):
		var l: String = linea.strip_edges()
		if l.begins_with(nombre):
			return l.substr(nombre.length()).strip_edges()
	return ""

## ── Utilidades ───────────────────────────────────────────

static func _buscar_todos(t: String, patron: String) -> Array:
	var re := RegEx.new()
	re.compile(patron)
	var out: Array = []
	for m in re.search_all(t):
		out.append(m.get_string())
	return out

static func _conjunto(arr: Array) -> Dictionary:
	var d: Dictionary = {}
	for k in arr:
		d[k] = true
	return d

static func _err(r: Dictionary, msg: String) -> void:
	(r["errores"] as Array).append(msg)

static func _avs(r: Dictionary, msg: String) -> void:
	(r["avisos"] as Array).append(msg)

static func _volcar(l: Array[String], titulo: String, items: Array) -> void:
	if items.is_empty():
		return
	l.append("%s (%d):" % [titulo, items.size()])
	for i in items:
		l.append("  · " + str(i))
