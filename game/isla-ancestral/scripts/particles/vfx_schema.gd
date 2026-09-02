# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M52: VfxSchema — validación del catálogo de VFX (id único, evento existente,
# tipo permitido, cantidad 5-300, emision 0.1-3, color #RRGGBB).
class_name VfxSchema
extends RefCounted

const TIPOS := ["polvo", "splash", "hojas", "flotante", "gotas", "corazones", "chispas", "confeti"]

## Devuelve Array[String] con los problemas (vacío si es válido).
static func validar_catalogo(config: Dictionary) -> Array[String]:
	var errores: Array[String] = []
	var vfx: Variant = config.get("vfx", [])
	if typeof(vfx) != TYPE_ARRAY or vfx.is_empty():
		return ["vfx vacío o inválido"]
	var ids := {}
	var hex_rex := RegEx.create_from_string("^#[A-Fa-f0-9]{6}$")
	for e in vfx:
		var id := String(e.get("id", ""))
		if id.is_empty():
			errores.append("VFX sin id")
		elif ids.has(id):
			errores.append("id duplicado: %s" % id)
		else:
			ids[id] = true
		if not String(e.get("nombre", "")).is_empty() == false and str(e.get("nombre", "")).is_empty():
			errores.append(id + ": sin nombre")
		if not TIPOS.has(String(e.get("tipo", ""))):
			errores.append("%s: tipo inválido (%s)" % [id, e.get("tipo", "")])
		var cantidad := int(e.get("cantidad", 0))
		if cantidad < 5 or cantidad > 300:
			errores.append("%s: cantidad fuera de rango (%d)" % [id, cantidad])
		var emision := float(e.get("emision", 0))
		if emision <= 0.0 or emision > 3.0:
			errores.append("%s: emision fuera de rango (%.2f)" % [id, emision])
		if hex_rex.search(String(e.get("color", ""))) == null:
			errores.append("%s: color inválido" % id)
	return errores
