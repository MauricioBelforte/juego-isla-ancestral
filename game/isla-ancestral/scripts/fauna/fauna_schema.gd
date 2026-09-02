# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M36: FaunaSchema + Auditoría del catálogo de especies (7 reales).
# Reglas (fauna_species.gd): id único, display_name, bioma válido, rareza
# COMUN..MUY_RARA, manada min<=max, escala min<=max, velocidades>0,
# radio_alarma<=radio_curiosidad, 2-3 variantes de color.
class_name FaunaSchema
extends RefCounted

const BIOMAS := ["playa", "pradera", "ribera", "bosque", "bosque_ancestral", "humedal", "montana", "volcan"]
const RAREZAS := ["COMUN", "POCO_COMUN", "RARA", "MUY_RARA"]
const CLASES := ["TERRESTRE", "ACUATICA", "AEREA", "ANFIBIA"]

static func validar_especie(datos: Dictionary) -> Array[String]:
	var errores: Array[String] = []
	if String(datos.get("id", "")).is_empty():
		errores.append("id vacío")
	if String(datos.get("display_name", "")).is_empty():
		errores.append("display_name vacío")
	if not BIOMAS.has(String(datos.get("bioma_principal", ""))):
		errores.append("bioma inválido: %s" % datos.get("bioma_principal", ""))
	if not RAREZAS.has(String(datos.get("rareza", ""))):
		errores.append("rareza inválida: %s" % datos.get("rareza", ""))
	if not CLASES.has(String(datos.get("clase", ""))):
		errores.append("clase inválida: %s" % datos.get("clase", ""))
	var min_manada := float(datos.get("manada_min", 1))
	var max_manada := float(datos.get("manada_max", 1))
	if min_manada <= 0 or max_manada < min_manada:
		errores.append("manada min/max inconsistentes (%s/%s)" % [min_manada, max_manada])
	var escala_min := float(datos.get("escala_min", 0))
	var escala_max := float(datos.get("escala_max", 0))
	if escala_min <= 0.0 or escala_max < escala_min:
		errores.append("escala min/max inconsistentes (%s/%s)" % [escala_min, escala_max])
	if float(datos.get("velocidad_deambular", 0)) <= 0.0 or float(datos.get("velocidad_huida", 0)) <= 0.0:
		errores.append("velocidades deben ser > 0")
	var radio_alarma := float(datos.get("radio_alarma", 0))
	var radio_curiosidad := float(datos.get("radio_curiosidad", 0))
	if radio_alarma > radio_curiosidad:
		errores.append("radio_alarma > radio_curiosidad")
	var colores: Variant = datos.get("color_variantes", [])
	if typeof(colores) != TYPE_ARRAY or colores.size() < 2 or colores.size() > 3:
		errores.append("color_variantes debe tener 2-3 colores")
	return errores
