# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M87: Localización — LocaleUtils (RefCounted estático).
# Formato de números y fechas por idioma (RF10/RF11) y nombres nativos (RF23).

class_name LocaleUtils
extends RefCounted

## Tabla por locale: separador decimal, separador de miles, orden fecha, reloj 24h.
const TABLAS := {
	"es": {"decimal": ",", "miles": ".", "fecha": "d/m/Y", "reloj_24h": true},
	"en": {"decimal": ".", "miles": ",", "fecha": "m/d/Y", "reloj_24h": false},
}

const NOMBRES_NATIVOS := {
	"es": "Español",
	"en": "English",
}

static func get_nombre_nativo(locale: String) -> String:
	return NOMBRES_NATIVOS.get(locale, locale)

static func get_tabla(locale: String) -> Dictionary:
	return TABLAS.get(locale, TABLAS["es"])

## Formatea un número con separadores del idioma: 1234.56 -> "1.234,56" (es).
static func format_number(value: float, locale: String = "es", decimales: int = -1) -> String:
	var tabla := get_tabla(locale)
	var dec: String = tabla["decimal"]
	var mil: String = tabla["miles"]
	var texto := "%.*f" % [decimales if decimales >= 0 else 2, value]
	var partes := texto.split(".")
	var entero := partes[0]
	var signo := ""
	if entero.begins_with("-"):
		signo = "-"
		entero = entero.trim_prefix("-")
	# Insertar separadores de miles
	var con_miles := ""
	var n := entero.length()
	while n > 3:
		con_miles = mil + entero.substr(n - 3, 3) + con_miles
		n -= 3
	con_miles = entero.substr(0, n) + con_miles
	var resultado := signo + con_miles
	if partes.size() > 1:
		resultado += dec + partes[1]
	return resultado

## Formatea una fecha a partir de un dict {dia, mes, anio} según el idioma.
## es: "17/08/2026" · en: "08/17/2026".
static func format_date(dia: int, mes: int, anio: int, locale: String = "es") -> String:
	var tabla := get_tabla(locale)
	var orden: String = tabla["fecha"]
	var dd := "%02d" % dia
	var mm := "%02d" % mes
	var yyyy := "%04d" % anio
	var out := orden
	out = out.replace("d", dd).replace("m", mm).replace("Y", yyyy)
	return out

## Hora en formato localizado: 14:30 (es, 24h) vs 2:30 PM (en, 12h).
static func format_hora(hora: int, minuto: int, locale: String = "es") -> String:
	var tabla := get_tabla(locale)
	if bool(tabla["reloj_24h"]):
		return "%02d:%02d" % [hora, minuto]
	var sufijo := "AM" if hora < 12 else "PM"
	var h12 := hora % 12
	if h12 == 0:
		h12 = 12
	return "%d:%02d %s" % [h12, minuto, sufijo]

## Idiomas soportados (para selector y validación).
static func locales_soportados() -> Array:
	return TABLAS.keys()
