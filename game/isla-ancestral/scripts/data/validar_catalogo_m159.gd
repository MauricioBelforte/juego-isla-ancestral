# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy AI
# Fecha: 2026-10-11
#
# M159 - Validador de integridad del Catalogo de Objetos.
# Implementa la seccion "Integracion y Validacion" de
# DOCUMENTACION/159-Catalogo-De-Objetos/plan-actual/05-Checklist.md (L210-L216):
#
#   L210  IDs unicos
#   L211  toda categoria con al menos un objeto
#   L212  todo objeto con icono
#   L213  todo objeto interactivo con al menos una interaccion
#   L214  todo objeto colocable con tamano definido
#   L215  todo objeto de tienda con precio
#   L216  total >= 300 objetos (objetivo de diseno)
#
# Uso:
#   godot --headless --path game/isla-ancestral \
#     --script res://scripts/data/validar_catalogo_m159.gd
#
# Codigos de salida:
#   0 = sin hallazgos bloqueantes
#   1 = hay hallazgos (ver informe)
#   3 = DETECTOR CIEGO (no se pudo cargar el catalogo)
#
# El analisis puro vive en `analizar()` para que la suite headless lo reutilice.

extends SceneTree

const ITEMS_DIR := "res://data/items/"
const TOTAL_OBJETIVO := 300   # 05-Checklist.md L216 / 03-Diseno.md

## Categorias declaradas por ItemData.Categoria (16).
const N_CATEGORIAS := 16


## Analisis puro sobre una lista de ItemData ya cargados.
## Devuelve un Dictionary con los conteos y las listas de violaciones.
static func analizar(items: Array) -> Dictionary:
	var ids := {}
	var ids_duplicados: Array[String] = []
	var sin_id: Array[String] = []
	var invalidos: Array[String] = []
	var sin_icono: Array[String] = []
	var interactivos_sin_accion: Array[String] = []
	var sin_tamano: Array[String] = []
	var tienda_sin_precio: Array[String] = []
	var por_categoria := {}
	var precio_compra_pos := 0
	var precio_venta_pos := 0

	for i in range(N_CATEGORIAS):
		por_categoria[i] = 0

	for it in items:
		var oid: String = str(it.id)
		if oid == "":
			sin_id.append(str(it.resource_path))
			continue
		if ids.has(oid):
			ids_duplicados.append(oid)
		ids[oid] = true

		if not it.es_valido():
			invalidos.append(oid)

		if it.icono == null:
			sin_icono.append(oid)

		if it.interactivo and it.interacciones.size() == 0:
			interactivos_sin_accion.append(oid)

		if it.tamano.x <= 0 or it.tamano.y <= 0:
			sin_tamano.append(oid)

		if it.precio_compra > 0:
			precio_compra_pos += 1
		if it.precio_venta > 0:
			precio_venta_pos += 1
		# "Objeto de tienda" = comercializable. NO existe un campo `es_de_tienda`,
		# asi que la verificacion medible es: todo objeto tiene AL MENOS un precio
		# (de compra o de venta). Un objeto sin ningun precio no podria estar en tienda.
		if it.precio_compra <= 0 and it.precio_venta <= 0:
			tienda_sin_precio.append(oid)

		var c: int = int(it.categoria)
		por_categoria[c] = int(por_categoria.get(c, 0)) + 1

	var categorias_vacias: Array[int] = []
	for i in range(N_CATEGORIAS):
		if int(por_categoria[i]) == 0:
			categorias_vacias.append(i)

	return {
		"total": ids.size(),
		"cargados": items.size(),
		"ids_duplicados": ids_duplicados,
		"sin_id": sin_id,
		"invalidos": invalidos,
		"sin_icono": sin_icono,
		"interactivos_sin_accion": interactivos_sin_accion,
		"sin_tamano": sin_tamano,
		"tienda_sin_precio": tienda_sin_precio,
		"categorias_vacias": categorias_vacias,
		"por_categoria": por_categoria,
		"precio_compra_pos": precio_compra_pos,
		"precio_venta_pos": precio_venta_pos,
	}


## Carga todos los .tres de res://data/items/ como ItemData.
## Devuelve [] si la carpeta no existe (el llamador decide si es ceguera).
static func cargar() -> Array:
	var items: Array = []
	var dir := DirAccess.open(ITEMS_DIR)
	if dir == null:
		return items
	dir.list_dir_begin()
	var f := dir.get_next()
	while f != "":
		if f.ends_with(".tres"):
			var it = load(ITEMS_DIR.path_join(f))
			if it != null:
				items.append(it)
		f = dir.get_next()
	dir.list_dir_end()
	return items


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var items := cargar()
	if items.size() == 0:
		print("=== M159 validar_catalogo: DETECTOR CIEGO ===")
		print("No se cargo ningun .tres de %s" % ITEMS_DIR)
		quit(3)
		return

	var r := analizar(items)
	var hallazgos := 0

	print("=== M159 validar_catalogo: informe ===")
	print("L210 IDs unicos .......... %s (unicos=%d, duplicados=%d, sin_id=%d)"
		% [_ok(r["ids_duplicados"].size() == 0 and r["sin_id"].size() == 0),
		   r["total"], r["ids_duplicados"].size(), r["sin_id"].size()])
	print("L211 categorias con items  %s (vacias=%d/%d)"
		% [_ok(r["categorias_vacias"].size() == 0), r["categorias_vacias"].size(), N_CATEGORIAS])
	print("L212 objetos con icono ... %s (sin_icono=%d/%d)"
		% [_ok(r["sin_icono"].size() == 0), r["sin_icono"].size(), r["total"]])
	print("L213 interactivo->accion . %s (violaciones=%d)"
		% [_ok(r["interactivos_sin_accion"].size() == 0), r["interactivos_sin_accion"].size()])
	print("L214 colocable->tamano ... %s (violaciones=%d)"
		% [_ok(r["sin_tamano"].size() == 0), r["sin_tamano"].size()])
	print("L215 tienda->precio ...... %s (violaciones=%d)"
		% [_ok(r["tienda_sin_precio"].size() == 0), r["tienda_sin_precio"].size()])
	print("L216 total >= %d ......... %s (total=%d, faltan=%d)"
		% [TOTAL_OBJETIVO, _ok(r["total"] >= TOTAL_OBJETIVO), r["total"],
		   maxi(0, TOTAL_OBJETIVO - r["total"])])
	print("-- extra: invalidos(es_valido)=%d | precio_compra>0=%d | precio_venta>0=%d"
		% [r["invalidos"].size(), r["precio_compra_pos"], r["precio_venta_pos"]])

	for clave in ["ids_duplicados", "sin_id", "invalidos", "interactivos_sin_accion",
			"sin_tamano", "tienda_sin_precio"]:
		if r[clave].size() > 0:
			hallazgos += r[clave].size()
	if r["categorias_vacias"].size() > 0:
		hallazgos += r["categorias_vacias"].size()
	if r["sin_icono"].size() > 0:
		hallazgos += r["sin_icono"].size()
	if r["total"] < TOTAL_OBJETIVO:
		hallazgos += 1

	print("=== M159 validar_catalogo: %d hallazgo(s) ===" % hallazgos)
	quit(1 if hallazgos > 0 else 0)


static func _ok(v: bool) -> String:
	return "[OK]" if v else "[GAP]"
