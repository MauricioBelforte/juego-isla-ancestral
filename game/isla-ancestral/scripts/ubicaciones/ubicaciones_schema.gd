# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M160: UbicacionesSchema — validación del mapa de ubicaciones del mundo
# (islas RIZ/COR/CEN/AUR, tipos, sellos por isla, coordenadas del mundo).
class_name UbicacionesSchema
extends RefCounted

const ISLAS := ["RIZ", "COR", "CEN", "AUR"]
const TIPOS := ["hito", "templo", "laguna", "volcan", "cielo", "punto", "hogar", "ruina", "playa", "pueblo"]
const SELLO_POR_ISLA := {"RIZ": "sello_raiz", "COR": "sello_coral", "CEN": "sello_ceniza", "AUR": "sello_aurora"}

## Devuelve Array[String] con los problemas (vacío si es válido).
static func validar_ubicaciones(config: Dictionary) -> Array[String]:
	var errores: Array[String] = []
	var ubi: Variant = config.get("ubicaciones", [])
	if typeof(ubi) != TYPE_ARRAY or ubi.is_empty():
		return ["ubicaciones vacío o inválido"]
	var ids := {}
	for e in ubi:
		var id := String(e.get("id", ""))
		if id.is_empty():
			errores.append("ubicación sin id")
		elif ids.has(id):
			errores.append("id duplicado: %s" % id)
		else:
			ids[id] = true
		if not ISLAS.has(String(e.get("isla", ""))):
			errores.append("%s: isla inválida" % id)
		if not TIPOS.has(String(e.get("tipo", ""))):
			errores.append("%s: tipo inválido (%s)" % [id, e.get("tipo", "")])
		var sello := String(e.get("sello", ""))
		if sello != "" and sello != SELLO_POR_ISLA.get(String(e.get("isla", "")), ""):
			errores.append("%s: sello %s no corresponde a la isla %s" % [id, sello, e.get("isla", "")])
		var x := float(e.get("x", -1))
		var z := float(e.get("z", -1))
		if x < 0 or z < 0:
			errores.append("%s: coordenadas inválidas (%s, %s)" % [id, x, z])
	return errores
