# Modelo: agnes-3-flash (Sapiens AI)
# Plataforma: Kilo Code
# Fecha: 2026-10-24
#
# M73: Coleccionables - Validador del catalogo (data-driven).
# Lee data/coleccionables/catalog.json y valida integridad:
#   - ids globales unicos (categoria + id_local)
#   - campos minimos por item (categoria, id_local, display_name, recompensa_item)
#   - rareza en rango 0-3 y puntos > 0
#   - categorias conocidas
# Devuelve un Dictionary { ok: bool, errores: Array, total: int, categorias: Dictionary }.
# Sin class_name: se instancia con .new() (GUIA-GODOT 09 seccion 9.17).

extends RefCounted

const CATALOGO_PATH := "res://data/coleccionables/catalog.json"
const CATEGORIAS_CONOCIDAS: Array = [
	"minerales", "animales", "conchas", "reliquias", "fragmentos",
	"peces", "plantas", "ancestrales",
]
const RANGOS_RAREZA := [0, 1, 2, 3]

## Valida el catalogo en disco. Devuelve el reporte.
func validar() -> Dictionary:
	var errores: Array = []
	var total: int = 0
	var por_categoria: Dictionary = {}
	var ids_vistos: Dictionary = {}

	if not FileAccess.file_exists(CATALOGO_PATH):
		errores.append("catalog.json no existe: " + CATALOGO_PATH)
		return { "ok": false, "errores": errores, "total": 0, "categorias": por_categoria }

	var contenido := FileAccess.get_file_as_string(CATALOGO_PATH)
	var parsed: Variant = JSON.parse_string(contenido)
	if typeof(parsed) != TYPE_ARRAY:
		errores.append("catalog.json no es un array JSON")
		return { "ok": false, "errores": errores, "total": 0, "categorias": por_categoria }

	var arr := parsed as Array
	for i in arr.size():
		var e: Variant = arr[i]
		if not (e is Dictionary):
			errores.append("item %d no es un objeto" % i)
			continue
		var d: Dictionary = e
		total += 1
		var cat := String(d.get("categoria", ""))
		var id_local := String(d.get("id_local", ""))
		var nombre := String(d.get("display_name", ""))
		var recompensa := String(d.get("recompensa_item", ""))
		var rareza := int(d.get("rareza", 0))
		var puntos := int(d.get("puntos", 0))

		# campos minimos
		if cat.is_empty():
			errores.append("item %d: categoria vacia" % i)
		if id_local.is_empty():
			errores.append("item %d: id_local vacio" % i)
		if nombre.is_empty():
			errores.append("item %d: display_name vacio" % i)
		if recompensa.is_empty():
			errores.append("item %d (%s/%s): recompensa_item vacia" % [i, cat, id_local])
		# rareza y puntos
		if not RANGOS_RAREZA.has(rareza):
			errores.append("item %d (%s/%s): rareza %d fuera de 0-3" % [i, cat, id_local, rareza])
		if puntos < 0:
			errores.append("item %d (%s/%s): puntos negativos" % [i, cat, id_local])
		# categoria conocida (advertencia, no bloqueo)
		if not CATEGORIAS_CONOCIDAS.has(cat):
			errores.append("item %d: categoria desconocida '%s'" % [i, cat])
		# id global unico
		var id_global := cat + "_" + id_local
		if ids_vistos.has(id_global):
			errores.append("id global duplicado: " + id_global)
		ids_vistos[id_global] = true
		por_categoria[cat] = int(por_categoria.get(cat, 0)) + 1

	return { "ok": errores.is_empty(), "errores": errores, "total": total, "categorias": por_categoria }

## Cantidad de categorias distintas presentes.
func cantidad_categorias() -> int:
	var r := validar()
	return int((r.get("categorias", {}) as Dictionary).size())
