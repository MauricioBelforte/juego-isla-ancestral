# Modelo: agnes-3.0-flash
# Plataforma: Kilo Code
# Fecha: 2026-10-05
#
# M129: Merchandising — MerchValidator (v2, data-driven)
# Valida el catálogo de productos y sus especificaciones. Devuelve Array[String] de errores.
# Campios requeridos por producto: id/producto/tipo/estado (v1).
# Campiones de spec opcionales, validados solo si existen:
#   precio_usd [min,max] · margen [min,max] · tamanos[] · colores[] · calidad[] · seguridad[]
# Reglas: margen en [0,1]; precio min<=max y >0; min<=max en rangos.

class_name MerchValidator
extends RefCounted

const _TIPOS_VALIDOS: Array = ["fisico", "textil", "ceramica", "impreso", "audio", "juguete", "coleccionable"]

static func validar(data: Dictionary) -> Array:
	var errores: Array = []
	var ids: Dictionary = {}
	for p in data.get("productos", []):
		var id: String = String(p.get("id", ""))
		var etiqueta := id if not id.is_empty() else "(sin_id)"
		if id.is_empty():
			errores.append("Producto sin id")
		elif ids.has(id):
			errores.append("Producto duplicado: %s" % id)
		ids[id] = true
		if String(p.get("producto", "")).is_empty():
			errores.append("%s: sin nombre de producto" % etiqueta)
		var tipo := String(p.get("tipo", ""))
		if tipo.is_empty():
			errores.append("%s: sin tipo" % etiqueta)
		elif _TIPOS_VALIDOS.has(tipo) == false:
			errores.append("%s: tipo desconocido '%s' (esperado: %s)" % [etiqueta, tipo, ", ".join(_TIPOS_VALIDOS)])
		if String(p.get("estado", "")).is_empty():
			errores.append("%s: sin estado" % etiqueta)
		errores.append_array(_validar_rango(p, "precio_usd", "precio", etiqueta))
		errores.append_array(_validar_margen(p, etiqueta))
		errores.append_array(_validar_listas(p, etiqueta))
	if data.get("politicas", {}).is_empty():
		errores.append("Sin políticas de merchandising")
	return errores

static func _validar_rango(p: Dictionary, clave: String, nombre: String, etiqueta: String) -> Array:
	var errores: Array = []
	var val: Variant = p.get(clave, null)
	if val != null:
		var arr: Array = val
		if arr.size() == 2:
			var a: float = float(arr[0]); var b: float = float(arr[1])
			if a <= 0.0:
				errores.append("%s: %s min debe ser > 0 (%.2f)" % [etiqueta, nombre, a])
			if a > b:
				errores.append("%s: %s min (%.2f) > max (%.2f)" % [etiqueta, nombre, a, b])
	return errores

static func _validar_margen(p: Dictionary, etiqueta: String) -> Array:
	var errores: Array = []
	var m: Variant = p.get("margen", null)
	if m == null:
		var ms: Variant = p.get("margen_estimado", null)
		if ms != null:
			var mv: float = float(ms)
			m = [mv, mv]
	if m != null:
		var arr: Array = m
		var a: float = float(arr[0]); var b: float = float(arr[1])
		if a < 0.0 or b > 1.0 or a > b:
			errores.append("%s: margen (%.2f-%.2f) fuera de [0,1] o min>max" % [etiqueta, a, b])
	return errores

static func _validar_listas(p: Dictionary, etiqueta: String) -> Array:
	var errores: Array = []
	for clave in ["tamanos", "colores", "calidad", "seguridad", "formatos"]:
		var val: Variant = p.get(clave, null)
		if val != null:
			var arr: Array = val
			if arr.size() == 0:
				errores.append("%s: campo '%s' presente pero vacio/no-array" % [etiqueta, clave])
	return errores

static func reporte(errores: Array) -> String:
	if errores.is_empty():
		return "[M129] MerchValidator: OK — merchandising configurado"
	var lineas: Array = ["[M129] MerchValidator: %d ERRORES:" % errores.size()]
	for e in errores:
		lineas.append("  - %s" % e)
	return "\n".join(lineas)
