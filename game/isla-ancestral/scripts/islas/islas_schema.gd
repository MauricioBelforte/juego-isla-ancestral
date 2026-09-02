# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M27: IslasSchema + test (config data-driven de las 4 islas).
class_name IslasSchema
extends RefCounted

const CODIGOS := ["RIZ", "COR", "CEN", "AUR"]

## Devuelve Array[String] con los problemas (vacío si es válido).
static func validar_islas(config: Dictionary) -> Array[String]:
	var errores: Array[String] = []
	var islas: Variant = config.get("islas", {})
	if typeof(islas) != TYPE_DICTIONARY or islas.is_empty():
		return ["islas vacío o inválido"]
	for codigo in CODIGOS:
		if not islas.has(codigo):
			errores.append("falta la isla %s" % codigo)
			continue
		var isla: Dictionary = islas[codigo]
		var centro: Variant = isla.get("centro", [])
		if typeof(centro) != TYPE_ARRAY or centro.size() != 2:
			errores.append("%s: centro inválido" % codigo)
		if float(isla.get("radio", 0)) <= 0:
			errores.append("%s: radio inválido" % codigo)
		if not String(isla.get("nombre", "")).is_empty() == false and str(isla.get("nombre", "")).is_empty():
			errores.append("%s: sin nombre" % codigo)
		var biomas: Variant = isla.get("biomas", [])
		if typeof(biomas) != TYPE_ARRAY or biomas.is_empty():
			errores.append("%s: sin biomas" % codigo)
		var color := String(isla.get("color_agua", ""))
		if color == "" or not (color.begins_with("#") and color.length() == 7):
			errores.append("%s: color_agua inválido (%s)" % [codigo, color])
	return errores
