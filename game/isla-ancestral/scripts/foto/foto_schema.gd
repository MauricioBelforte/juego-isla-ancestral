# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M56: FotoSchema — validación de presets fotográficos (RF5).
class_name FotoSchema
extends RefCounted

## Valida un preset como diccionario. Devuelve Array[String] vacía si es válido.
static func validar_preset(id: String, preset: Dictionary) -> Array[String]:
	var errores: Array[String] = []
	if id.is_empty():
		errores.append("id vacío")
	if preset.is_empty():
		errores.append("preset vacío")
		return errores
	if not preset.has("nombre") or str(preset["nombre"]).is_empty():
		errores.append("nombre ausente")
	for campo in ["saturacion", "contraste", "temperatura", "vineta", "dof"]:
		if not preset.has(campo):
			errores.append("campo ausente: %s" % campo)
	for campo in ["saturacion", "contraste"]:
		if preset.has(campo) and float(preset[campo]) <= 0.0:
			errores.append("%s debe ser > 0" % campo)
	if preset.has("vineta") and (float(preset["vineta"]) < 0.0 or float(preset["vineta"]) > 1.0):
		errores.append("vineta fuera de rango 0-1")
	if preset.has("temperatura") and (float(preset["temperatura"]) < -1.0 or float(preset["temperatura"]) > 1.0):
		errores.append("temperatura fuera de rango -1..1")
	if preset.has("dof") and (float(preset["dof"]) < 0.0 or float(preset["dof"]) > 1.0):
		errores.append("dof fuera de rango 0-1")
	return errores
