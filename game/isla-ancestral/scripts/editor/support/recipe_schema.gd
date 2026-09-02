# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M109: RecipeSchema — validación de recetas (núcleo puro del Editor de recetas).
# Reglas de crafting.json (M93/M16): id, nombre, categoria, nivel>=1, estacion,
# coste_recursos (dict id->cantidad>0), resultado, resultado_cantidad>=1.
class_name RecipeSchema
extends RefCounted

const CATEGORIAS := ["estructura", "herramientas", "consumibles", "decoracion", "puzzle"]
const ESTACIONES := ["mesa_trabajo", "mesa_cocina", "banco_herreria", "telar", "ninguna"]

## Valida una receta como diccionario. Devuelve Array[String] vacía si es válida.
static func validar(id: String, receta: Dictionary) -> Array[String]:
	var errores: Array[String] = []
	if id.is_empty():
		errores.append("id vacío")
	if receta.is_empty():
		errores.append("receta vacía")
		return errores
	for campo in ["nombre", "categoria", "estacion", "resultado"]:
		if not receta.has(campo) or str(receta[campo]).is_empty():
			errores.append("campo requerido ausente: %s" % campo)
	if receta.has("categoria") and not CATEGORIAS.has(String(receta["categoria"])):
		errores.append("categoria inválida: %s" % receta["categoria"])
	if receta.has("estacion") and not ESTACIONES.has(String(receta["estacion"])):
		errores.append("estacion inválida: %s" % receta["estacion"])
	if not int(receta.get("nivel", 0)) >= 1:
		errores.append("nivel debe ser >= 1")
	if int(receta.get("resultado_cantidad", 0)) < 1:
		errores.append("resultado_cantidad >= 1")
	var costes: Variant = receta.get("coste_recursos", {})
	if typeof(costes) != TYPE_DICTIONARY or costes.is_empty():
		errores.append("coste_recursos vacío o inválido")
	else:
		for k in costes:
			if int(costes[k]) <= 0:
				errores.append("coste inválido: %s" % k)
	return errores

## Convierte "id:cant, id:cant" a diccionario (para el campo del editor).
static func costes_a_texto(costes: Dictionary) -> String:
	var partes: Array[String] = []
	for k in costes:
		partes.append("%s:%d" % [k, int(costes[k])])
	return ", ".join(partes)

## Convierte el texto del editor a diccionario. Devuelve null si el formato es inválido.
static func texto_a_costes(texto: String) -> Dictionary:
	var result := {}
	if texto.strip_edges().is_empty():
		return result
	for parte in texto.split(",", false):
		var kv := parte.split(":", true, 2)
		if kv.size() != 2:
			return {}
		var id_item := kv[0].strip_edges()
		var cantidad := kv[1].strip_edges()
		if id_item.is_empty() or not cantidad.is_valid_int():
			return {}
		result[id_item] = int(cantidad)
	return result
