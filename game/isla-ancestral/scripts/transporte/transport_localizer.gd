# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-15
#
# M68 iter. 2 — Transporte y Navegación: LOCALIZACIÓN (sección V).
#
# Localiza todo lo que el jugador LEE del transporte: nombres de paradas y rutas,
# mensajes de viaje, horarios, carteles del mundo, avisos de bloqueo, viajes
# especiales/narrativos y eventos de ruta.
#
# Convención de claves (M87):
#   M68.STOP.<id>      nombre de la parada
#   M68.SIGN.<id>      plantilla del cartel: "→ {destino} · {metros} m"
#   M68.ROUTE.<id>     nombre de la ruta: "<origen> → <destino>"
#   M68.TRIP.*         mensajes del viaje y de la transición
#   M68.SPECIAL.*      viajes especiales (festivales M74, luna M31, tour)
#   M68.NARR.*         viajes narrativos (M22/M23) y sus diálogos a bordo (M21)
#   M68.EVENT.*        eventos de ruta (M64) y su señal (M43/M44)
#
# Reglas:
#   * Formatos de hora delegados a `LocaleUtils` (M87): es = 24 h, en = 12 h.
#     NO se reimplementa el reloj: se reutiliza.
#   * Plurales vía `msgid_plural` + `msgstr[n]` del catálogo (M87), con {n}.
#   * Resolución PURA por locale: el localizador lee los .po a memoria, así que
#     puede verificar es y en sin cambiar el idioma activo del juego (efecto
#     lateral que tendría `Localization.set_locale`).

class_name TransportLocalizer
extends RefCounted

const PREFIJO := "M68."
const CARPETA_LOCALES_DEFECTO := "res://locales/"
const LOCALE_FALLBACK := "es"

## Mensajes del viaje (sección L/M). Claves espejo de TransportTripPlanner.
const CLAVE_TRAVELING := "M68.TRIP.TRAVELING_TO"
const CLAVE_ARRIVED := "M68.TRIP.ARRIVED_AT"
const CLAVE_LOADING := "M68.TRIP.LOADING"
const CLAVE_OUT_OF_SCHEDULE := "M68.TRIP.OUT_OF_SCHEDULE"
const CLAVE_LOCKED := "M68.TRIP.LOCKED"
const CLAVE_SPECIAL_ONLY := "M68.TRIP.SPECIAL_ONLY"
const CLAVE_NO_MONEY := "M68.TRIP.NO_MONEY"
const CLAVE_SCHEDULE := "M68.TRIP.SCHEDULE"
const CLAVE_DURATION := "M68.TRIP.DURATION"
const CLAVE_PRICE := "M68.TRIP.PRICE"
const CLAVE_CURRENCY := "M68.TRIP.CURRENCY"

## Claves plurales (n = cantidad).
const CLAVE_PLURAL_SEGUNDOS := "M68.TRIP.SEGUNDOS"
const CLAVE_PLURAL_MINUTOS := "M68.TRIP.MINUTOS"
const CLAVE_PLURAL_HORAS := "M68.TRIP.HORAS"
const CLAVE_HORAS_MINUTOS := "M68.TRIP.HORAS_MINUTOS"

## Nombre en inglés de cada parada (la fuente en español es `nombre_fallback`).
const NOMBRES_EN := {
	"puerto_aurora": "Aurora Harbour",
	"muelle_raiz_sur": "Aurora South Dock",
	"plataforma_norte": "Northern Platform",
	"estacion_central": "Central Station",
	"puerto_sur": "South Island Harbour",
	"puerto_este": "East Island Harbour",
	"puerto_norte": "North Island Harbour",
	"puerto_brisa": "Breeze Island Harbour",
	"puerto_espejo": "Mirror Island Harbour",
	"puerto_festival": "Festival Harbour",
}

## Textos base por locale: {clave: {es: ..., en: ...}}.
const TEXTOS := {
	CLAVE_TRAVELING: {"es": "Viajando a {destino}...", "en": "Travelling to {destino}..."},
	CLAVE_ARRIVED: {"es": "Has llegado a {destino}.", "en": "You have arrived at {destino}."},
	CLAVE_LOADING: {"es": "Preparando el viaje...", "en": "Preparing your trip..."},
	CLAVE_OUT_OF_SCHEDULE: {"es": "Fuera de horario ({horario}). ¿Esperar?", "en": "Outside opening hours ({horario}). Wait?"},
	CLAVE_LOCKED: {"es": "Destino bloqueado", "en": "Destination locked"},
	CLAVE_SPECIAL_ONLY: {"es": "Sólo disponible durante {evento}", "en": "Only available during {evento}"},
	CLAVE_NO_MONEY: {"es": "Te faltan monedas: cuesta {precio}", "en": "Not enough coins: it costs {precio}"},
	CLAVE_SCHEDULE: {"es": "Horario: {horario}", "en": "Opening hours: {horario}"},
	CLAVE_DURATION: {"es": "Duración: {duracion}", "en": "Duration: {duracion}"},
	CLAVE_PRICE: {"es": "Precio: {precio}", "en": "Price: {precio}"},
	CLAVE_CURRENCY: {"es": "AO", "en": "AO"},
	CLAVE_HORAS_MINUTOS: {"es": "{h} h {m} min", "en": "{h} h {m} min"},
}

## Formas plurales por locale: {clave: {es: [sing, plur], en: [sing, plur]}}.
const PLURALES := {
	CLAVE_PLURAL_SEGUNDOS: {"es": ["{n} segundo", "{n} segundos"], "en": ["{n} second", "{n} seconds"]},
	CLAVE_PLURAL_MINUTOS: {"es": ["{n} minuto", "{n} minutos"], "en": ["{n} minute", "{n} minutes"]},
	CLAVE_PLURAL_HORAS: {"es": ["{n} hora", "{n} horas"], "en": ["{n} hour", "{n} hours"]},
}

## Nombres de los viajes especiales y narrativos (contenido de la sección V).
const ESPECIALES := {
	"M68.SPECIAL.FESTIVAL_PRIMAVERA": {"es": "Viaje al Festival de Primavera", "en": "Trip to the Spring Festival"},
	"M68.SPECIAL.FESTIVAL_PRIMAVERA_DESC": {"es": "Parada temporal en el Puerto del Festival.", "en": "Temporary stop at Festival Harbour."},
	"M68.SPECIAL.FESTIVAL_VERANO": {"es": "Viaje al Festival de Verano", "en": "Trip to the Summer Festival"},
	"M68.SPECIAL.FESTIVAL_VERANO_DESC": {"es": "Parada temporal en el Puerto del Festival.", "en": "Temporary stop at Festival Harbour."},
	"M68.SPECIAL.FESTIVAL_OTONO": {"es": "Viaje al Festival de Otoño", "en": "Trip to the Autumn Festival"},
	"M68.SPECIAL.FESTIVAL_OTONO_DESC": {"es": "Parada temporal en el Puerto del Festival.", "en": "Temporary stop at Festival Harbour."},
	"M68.SPECIAL.FESTIVAL_INVIERNO": {"es": "Viaje al Festival de Invierno", "en": "Trip to the Winter Festival"},
	"M68.SPECIAL.FESTIVAL_INVIERNO_DESC": {"es": "Parada temporal en el Puerto del Festival.", "en": "Temporary stop at Festival Harbour."},
	"M68.SPECIAL.FESTIVAL_LUCES": {"es": "Viaje al Festival de las Luces", "en": "Trip to the Festival of Lights"},
	"M68.SPECIAL.FESTIVAL_LUCES_DESC": {"es": "Travesía nocturna a los faroles.", "en": "Night crossing to the lanterns."},
	"M68.SPECIAL.LUNA_LLENA": {"es": "Tour de luna llena", "en": "Full moon tour"},
	"M68.SPECIAL.LUNA_LLENA_DESC": {"es": "Travesía nocturna a la Isla Espejo, con recargo.", "en": "Night crossing to Mirror Island, at a premium."},
	"M68.SPECIAL.TOUR_DIRIGIBLE": {"es": "Tour panorámico en dirigible", "en": "Airship sightseeing tour"},
	"M68.SPECIAL.TOUR_DIRIGIBLE_DESC": {"es": "Vuelo de fin de semana sobre la Isla del Norte.", "en": "Weekend flight over North Island."},
	"M68.NARR.C4_BRIS": {"es": "Travesía al Templo de la Brisa", "en": "Crossing to the Breeze Temple"},
	"M68.NARR.C7_CAMARA": {"es": "Travesía a la Cámara del Sello", "en": "Crossing to the Seal Chamber"},
	"M68.NARR.FINAL_SECRETO": {"es": "Travesía al secreto del Espejo", "en": "Crossing to the Mirror secret"},
	"M68.NARR.C4.01": {"es": "El viento cambia al salir del puerto.", "en": "The wind shifts as you leave the harbour."},
	"M68.NARR.C4.02": {"es": "Finneas señala el templo en el horizonte.", "en": "Finneas points to the temple on the horizon."},
	"M68.NARR.C7.01": {"es": "El mar está demasiado quieto.", "en": "The sea is far too still."},
	"M68.NARR.C7.02": {"es": "Los siete sellos pesan en la mochila.", "en": "The seven seals weigh on your pack."},
	"M68.NARR.C7.03": {"es": "La Cámara espera bajo el templo.", "en": "The Chamber waits beneath the temple."},
	"M68.NARR.SECRETO.01": {"es": "Las pistas pagadas por fin encajan.", "en": "The paid clues finally fit together."},
	"M68.EVENT.MUELLE_MATEO": {"es": "Mateo charla en el muelle", "en": "Mateo chats on the dock"},
	"M68.EVENT.MUELLE_MATEO.SENAL": {"es": "Ves a Mateo saludando desde el muelle.", "en": "You see Mateo waving from the dock."},
	"M68.EVENT.PUERTO_BRUNO": {"es": "Bruno te despide", "en": "Bruno sees you off"},
	"M68.EVENT.PUERTO_BRUNO.SENAL": {"es": "Bruno te grita un consejo desde el pantalán.", "en": "Bruno shouts a tip from the jetty."},
	"M68.EVENT.DIRIGIBLE_LUNA": {"es": "Luna sube contigo", "en": "Luna rides along"},
	"M68.EVENT.DIRIGIBLE_LUNA.SENAL": {"es": "Luna señala las islas desde el aire.", "en": "Luna points out the islands from above."},
	"M68.EVENT.LLEGADA_FINNEAS": {"es": "Finneas te espera", "en": "Finneas is waiting"},
	"M68.EVENT.LLEGADA_FINNEAS.SENAL": {"es": "Finneas levanta la mano al verte llegar.", "en": "Finneas raises a hand as you arrive."},
	"M68.EVENT.FESTIVAL_CATALINA": {"es": "Catalina en el festival", "en": "Catalina at the festival"},
	"M68.EVENT.FESTIVAL_CATALINA.SENAL": {"es": "Catalina te llama entre los faroles.", "en": "Catalina calls you among the lanterns."},
}

var _red: TransportNetwork = null
var _carpeta: String = CARPETA_LOCALES_DEFECTO
var _catalogos: Dictionary = {}    # locale -> {clave: texto}
var _plurales: Dictionary = {}     # locale -> {clave: [formas]}


func _init(red: TransportNetwork = null, carpeta_locales: String = CARPETA_LOCALES_DEFECTO) -> void:
	_red = red
	_carpeta = carpeta_locales


## ── Catálogos ────────────────────────────────────────────────────────────

## Carga los .po de `locales` a memoria. Devuelve cuántos se pudieron leer.
func cargar_catalogos(locales: Array[String] = ["es", "en"]) -> int:
	var n: int = 0
	for loc in locales:
		var datos: Dictionary = leer_catalogo(_carpeta + loc + ".po")
		if datos.is_empty():
			continue
		_catalogos[loc] = datos.get("mensajes", {})
		_plurales[loc] = datos.get("plurales", {})
		n += 1
	return n


func locales_cargados() -> Array[String]:
	var out: Array[String] = []
	for k in _catalogos.keys():
		out.append(str(k))
	out.sort()
	return out


## Lector .po mínimo y PURO (sin autoloads): {mensajes: {clave: texto},
## plurales: {clave: [formas]}}. Ignora la cabecera (msgid "").
## Se implementa aquí a propósito: verificar los catálogos NO debe depender del
## idioma activo del juego ni de `Localization.set_locale` (efecto lateral).
func leer_catalogo(ruta: String) -> Dictionary:
	var mensajes: Dictionary = {}
	var plurales: Dictionary = {}
	if not FileAccess.file_exists(ruta):
		return {"mensajes": mensajes, "plurales": plurales}
	var f := FileAccess.open(ruta, FileAccess.READ)
	if f == null:
		return {"mensajes": mensajes, "plurales": plurales}
	var clave_actual: String = ""
	var es_plural: bool = false
	while not f.eof_reached():
		var linea: String = f.get_line().strip_edges()
		if linea.begins_with("msgid_plural"):
			es_plural = true
			continue
		if linea.begins_with("msgid "):
			clave_actual = _quitar_comillas(linea.substr(6).strip_edges())
			es_plural = false
			continue
		if linea.begins_with("msgstr[") and not clave_actual.is_empty():
			var i_ini: int = linea.find("[")
			var i_fin: int = linea.find("]")
			if i_ini >= 0 and i_fin > i_ini:
				var idx: int = int(linea.substr(i_ini + 1, i_fin - i_ini - 1))
				var texto: String = _quitar_comillas(linea.substr(i_fin + 1).strip_edges())
				var formas: Array = plurales.get(clave_actual, [])
				while formas.size() <= idx:
					formas.append("")
				formas[idx] = texto
				plurales[clave_actual] = formas
			continue
		# `msgstr "..."` simple. Una entrada PLURAL nunca entra en `mensajes`:
		# si entrara, quedaría con texto vacío y `claves_vacias()` daría un falso
		# positivo. Las claves plurales viven sólo en `plurales`.
		if linea.begins_with("msgstr ") and not clave_actual.is_empty() and not es_plural:
			mensajes[clave_actual] = _quitar_comillas(linea.substr(7).strip_edges())
			continue
	f.close()
	return {"mensajes": mensajes, "plurales": plurales}


static func _quitar_comillas(s: String) -> String:
	var t: String = s.strip_edges()
	if t.begins_with("\"") and t.ends_with("\"") and t.length() >= 2:
		t = t.substr(1, t.length() - 2)
	return t


## ── Resolución de texto (pura, por locale) ───────────────────────────────

func texto(clave: String, params: Dictionary = {}, locale: String = LOCALE_FALLBACK, n: int = -1) -> String:
	var bruto: String = _buscar(clave, locale, n)
	var p: Dictionary = params.duplicate()
	if n != -1 and not p.has("n"):
		p["n"] = n
	for k in p.keys():
		bruto = bruto.replace("{" + str(k) + "}", str(p[k]))
	return bruto


func falta(clave: String, locale: String = LOCALE_FALLBACK) -> bool:
	var cat: Dictionary = _catalogos.get(locale, {})
	var plu: Dictionary = _plurales.get(locale, {})
	return not cat.has(clave) and not plu.has(clave)


func _buscar(clave: String, locale: String, n: int) -> String:
	var candidatos: Array[String] = [locale, LOCALE_FALLBACK]
	if n != -1:
		for loc: String in candidatos:
			var plu: Dictionary = _plurales.get(loc, {})
			if plu.has(clave):
				var formas: Array = plu[clave]
				var idx: int = 1 if n != 1 else 0
				if idx < formas.size() and not str(formas[idx]).is_empty():
					return str(formas[idx])
	for loc2: String in candidatos:
		var cat: Dictionary = _catalogos.get(loc2, {})
		if cat.has(clave):
			return str(cat[clave])
	return clave


## ── Formatos (M87: se delega en LocaleUtils, no se reimplementa) ─────────

## Horario localizado: es "08:00-20:00" · en "8:00 AM-8:00 PM".
func horario_texto(apertura: int, cierre: int, locale: String = LOCALE_FALLBACK) -> String:
	return "%s-%s" % [
		LocaleUtils.format_hora(apertura, 0, locale),
		LocaleUtils.format_hora(cierre, 0, locale),
	]


## Horario de una parada (lee sus campos y lo localiza).
func horario_de_parada(stop: TransportStop, locale: String = LOCALE_FALLBACK) -> String:
	if stop == null:
		return ""
	return horario_texto(stop.horario_apertura, stop.horario_cierre, locale)


## Duración legible con plurales: 45 s · 5 minutos · 1 hora · 1 h 30 min.
func duracion_texto(segundos: float, locale: String = LOCALE_FALLBACK) -> String:
	var s: float = maxf(0.0, segundos)
	if s < 60.0:
		var n_seg: int = int(round(s))
		return texto(CLAVE_PLURAL_SEGUNDOS, {}, locale, n_seg)
	if s < 3600.0:
		var n_min: int = int(round(s / 60.0))
		return texto(CLAVE_PLURAL_MINUTOS, {}, locale, n_min)
	var horas: int = int(floor(s / 3600.0))
	var minutos: int = int(round(fmod(s, 3600.0) / 60.0))
	if minutos == 0:
		return texto(CLAVE_PLURAL_HORAS, {}, locale, horas)
	return texto(CLAVE_HORAS_MINUTOS, {"h": horas, "m": minutos}, locale)


## Precio con moneda y separadores del idioma: "80 AO" · "1.234 AO".
func precio_texto(precio: int, locale: String = LOCALE_FALLBACK) -> String:
	return "%s %s" % [LocaleUtils.format_number(float(precio), locale, 0), texto(CLAVE_CURRENCY, {}, locale)]


func mensaje_viaje(destino_nombre: String, locale: String = LOCALE_FALLBACK) -> String:
	return texto(CLAVE_TRAVELING, {"destino": destino_nombre}, locale)


func mensaje_llegada(destino_nombre: String, locale: String = LOCALE_FALLBACK) -> String:
	return texto(CLAVE_ARRIVED, {"destino": destino_nombre}, locale)


## Plantilla del cartel del mundo (M46): "→ Aurora Harbour · 120 m".
func texto_cartel(destino_nombre: String, metros: float, locale: String = LOCALE_FALLBACK) -> String:
	return texto("M68.SIGN.GENERICO", {
		"destino": destino_nombre,
		"metros": LocaleUtils.format_number(metros, locale, 0),
	}, locale)


## Nombre localizado de una parada. Orden: catálogo real → tabla propia del
## idioma (NOMBRES_EN, para no depender de que el .po ya esté aplicado) →
## fallback en español del propio recurso → id.
func nombre_parada(stop: TransportStop, locale: String = LOCALE_FALLBACK) -> String:
	if stop == null:
		return ""
	var clave: String = stop.nombre_clave if not stop.nombre_clave.is_empty() else "M68.STOP." + String(stop.id)
	var cat: Dictionary = _catalogos.get(locale, {})
	if cat.has(clave):
		return str(cat[clave])
	var sid: String = String(stop.id)
	if locale == "en" and NOMBRES_EN.has(sid):
		return str(NOMBRES_EN[sid])
	if not stop.nombre_fallback.is_empty():
		return stop.nombre_fallback
	return sid


## Nombre localizado de una ruta: "<origen> → <destino>".
func nombre_ruta(ruta: TransportRoute, locale: String = LOCALE_FALLBACK) -> String:
	if ruta == null or _red == null:
		return ""
	var o: TransportStop = _red.stop(ruta.from_id)
	var d: TransportStop = _red.stop(ruta.to_id)
	return "%s → %s" % [nombre_parada(o, locale), nombre_parada(d, locale)]


## ── Inventario de claves ────────────────────────────────────────────────

func claves_de_parada(stop: TransportStop) -> Array[String]:
	var id: String = String(stop.id) if stop != null else ""
	if id.is_empty():
		return []
	return ["M68.STOP." + id, "M68.SIGN." + id]


func claves_de_ruta(ruta: TransportRoute) -> Array[String]:
	if ruta == null:
		return []
	return ["M68.ROUTE." + String(ruta.id)]


## Claves fijas del módulo (mensajes, plantillas, plurales).
func claves_de_viaje() -> Array[String]:
	var out: Array[String] = []
	for k in TEXTOS.keys():
		out.append(str(k))
	for k in PLURALES.keys():
		out.append(str(k))
	out.append("M68.SIGN.GENERICO")
	return out


## Todas las claves que M68 necesita, incluidas las de los registros vecinos.
func claves_totales(red: TransportNetwork = null, especiales: Object = null, narrativos: Object = null, eventos: Object = null) -> Array[String]:
	var out: Array[String] = []
	var r: TransportNetwork = red if red != null else _red
	if r != null:
		for s in r.stops:
			for k in claves_de_parada(s as TransportStop):
				if not out.has(k):
					out.append(k)
		for rt in r.routes:
			for k in claves_de_ruta(rt as TransportRoute):
				if not out.has(k):
					out.append(k)
	for k2 in claves_de_viaje():
		if not out.has(k2):
			out.append(k2)
	for reg in [especiales, narrativos, eventos]:
		if reg != null and reg.has_method("claves_localizacion"):
			var claves: Variant = reg.call("claves_localizacion")
			if claves is Array:
				for k3 in claves:
					if not out.has(str(k3)):
						out.append(str(k3))
	for k4 in ESPECIALES.keys():
		if not out.has(str(k4)):
			out.append(str(k4))
	out.sort()
	return out


## ── Catálogo generado (fuente de verdad del contenido) ──────────────────

## Texto de una clave en un locale, tomado de las tablas de este módulo.
## Es lo que se vuelca a los .po (es/en), así que la generación y la verificación
## comparten una única fuente de verdad.
func texto_generado(clave: String, locale: String) -> String:
	var loc: String = locale if locale in ["es", "en"] else LOCALE_FALLBACK
	if TEXTOS.has(clave):
		var t: Dictionary = TEXTOS[clave]
		return str(t.get(loc, t.get(LOCALE_FALLBACK, clave)))
	if ESPECIALES.has(clave):
		var e: Dictionary = ESPECIALES[clave]
		return str(e.get(loc, e.get(LOCALE_FALLBACK, clave)))
	if clave.begins_with("M68.SIGN."):
		return "→ {destino} · {metros} m"
	if clave.begins_with("M68.STOP.") and _red != null:
		var sid: String = clave.substr("M68.STOP.".length())
		var stop: TransportStop = _red.stop(StringName(sid))
		if stop != null:
			if loc == "en" and NOMBRES_EN.has(sid):
				return str(NOMBRES_EN[sid])
			return stop.nombre_fallback
	if clave.begins_with("M68.ROUTE.") and _red != null:
		var rid: String = clave.substr("M68.ROUTE.".length())
		return nombre_ruta(_red.ruta(StringName(rid)), loc)
	return clave


## Catálogo completo {clave: texto} para `locale` (sólo claves simples).
func generar_catalogo(locale: String, red: TransportNetwork = null, especiales: Object = null, narrativos: Object = null, eventos: Object = null) -> Dictionary:
	var out: Dictionary = {}
	var r: TransportNetwork = red if red != null else _red
	var previa: TransportNetwork = _red
	_red = r
	for clave in claves_totales(r, especiales, narrativos, eventos):
		if PLURALES.has(clave):
			continue
		out[clave] = texto_generado(clave, locale)
	_red = previa
	return out


## Formas plurales {clave: [sing, plur]} para `locale`.
func generar_plurales(locale: String) -> Dictionary:
	var loc: String = locale if locale in ["es", "en"] else LOCALE_FALLBACK
	var out: Dictionary = {}
	for clave in PLURALES.keys():
		var formas: Dictionary = PLURALES[clave]
		out[str(clave)] = formas.get(loc, formas.get(LOCALE_FALLBACK, []))
	return out


## ── Verificación ────────────────────────────────────────────────────────

## Claves que faltan en los catálogos reales, como "locale:CLAVE".
func claves_faltantes(locales: Array[String] = ["es", "en"], red: TransportNetwork = null, especiales: Object = null, narrativos: Object = null, eventos: Object = null) -> Array[String]:
	var out: Array[String] = []
	var necesarias: Array[String] = claves_totales(red, especiales, narrativos, eventos)
	for loc in locales:
		if not _catalogos.has(loc):
			out.append(loc + ":<catálogo no cargado>")
			continue
		for clave in necesarias:
			if falta(clave, loc):
				out.append(loc + ":" + clave)
	return out


## Claves cuyo texto quedó vacío en algún catálogo.
func claves_vacias(locales: Array[String] = ["es", "en"], red: TransportNetwork = null, especiales: Object = null, narrativos: Object = null, eventos: Object = null) -> Array[String]:
	var out: Array[String] = []
	for loc in locales:
		var cat: Dictionary = _catalogos.get(loc, {})
		for clave in claves_totales(red, especiales, narrativos, eventos):
			if cat.has(clave) and str(cat[clave]).strip_edges().is_empty():
				out.append(loc + ":" + clave)
	return out


## Verifica formato (12 h/24 h) y plurales en un locale.
func verificar_formatos(locale: String) -> Array[String]:
	var errores: Array[String] = []
	var h24: String = horario_texto(8, 20, locale)
	var esperado: String = "08:00-20:00" if locale == "es" else "8:00 AM-8:00 PM"
	if h24 != esperado:
		errores.append("formato de horario inesperado en %s: '%s'" % [locale, h24])
	# Plural: 1 debe usar la forma singular y 5 la plural.
	var uno: String = duracion_texto(60.0, locale)
	var cinco: String = duracion_texto(300.0, locale)
	if uno == cinco:
		errores.append("el plural no distingue 1 de 5 en %s" % locale)
	if not uno.contains("1"):
		errores.append("la forma singular de %s no incluye la cantidad" % locale)
	if not cinco.contains("5"):
		errores.append("la forma plural de %s no incluye la cantidad" % locale)
	return errores


func validar(locales: Array[String] = ["es", "en"], red: TransportNetwork = null, especiales: Object = null, narrativos: Object = null, eventos: Object = null) -> Array[String]:
	var errores: Array[String] = []
	for f in claves_faltantes(locales, red, especiales, narrativos, eventos):
		errores.append("clave sin traducir: " + f)
	for v in claves_vacias(locales, red, especiales, narrativos, eventos):
		errores.append("texto vacío: " + v)
	for loc in locales:
		for f2 in verificar_formatos(loc):
			errores.append(f2)
	return errores


func resumen() -> String:
	return "M68 localización: %d claves, catálogos %s" % [
		claves_totales().size(), str(locales_cargados())]
