# Modelo: DeepSeek-V4.1-Flash (WorkBuddy)
# Fecha: 2026-10-04
#
# M17 Construccion iter. 3 — BuildHudModel: el MODELO PURO del HUD del modo.
#
# La capa UI real es M18 (Canvas/Control). Aqui NO hay nodos ni temas: esto es
# un modelo puro (RefCounted) que convierte el resultado de `BuildPreview` + la
# receta en FILAS y TEXTOS listos para pintar:
#   * costo de la pieza   (item_id -> cantidad, con nombre legible)
#   * motivos de rechazo  (traducidos por `ConstruccionTipos.texto`)
#   * una linea de estado para el jugador
#
# Separacion deliberada (03-Diseno §2): la UI solo DIBUJA lo que este modelo
# decide; asi el HUD se testea headless y no se acopla logica de colocacion a
# los scripts de UI.
#
# NUCLEO PURO: depende solo de PlacementRule y ConstruccionTipos (ambos puros).

class_name BuildHudModel
extends RefCounted

## Nombre legible por item de M14. Los que no esten aqui usan el id crudo
## (nunca se inventa un nombre: si falta, se muestra el id real).
const NOMBRE_ITEM: Dictionary = {
	"wood": "madera",
	"planks": "tablones",
	"stone": "piedra",
	"glass": "vidrio",
	"clay": "arcilla",
	"sand": "arena",
	"grass": "fibra",
	"crystal": "cristal",
	"iron_ore": "hierro",
	"copper_ore": "cobre",
	"charcoal": "carbon",
	"rope": "cuerda",
}

## Texto cuando la pieza no cuesta nada.
const TEXTO_GRATIS: String = "gratis"

## ── Costo ───────────────────────────────────────────────────────────────

## Nombre legible de un item de M14 (o el id crudo si no hay traduccion).
static func nombre_item(item_id: String) -> String:
	return String(NOMBRE_ITEM.get(item_id, item_id))

## Filas de costo ORDENADAS por item_id (determinismo para tests y UI).
## Cada fila: { item_id, nombre, cantidad, texto }.
static func filas_costo(receta: PlacementRule) -> Array:
	var out: Array = []
	if receta == null:
		return out
	var ids: Array = receta.costo.keys()
	ids.sort()
	for k in ids:
		var item_id: String = String(k)
		var n: int = int(receta.costo[k])
		var nombre: String = nombre_item(item_id)
		out.append({
			"item_id": item_id,
			"nombre": nombre,
			"cantidad": n,
			"texto": "%s x%d" % [nombre, n],
		})
	return out

## Texto de una linea con el costo completo ("piedra x3, tablones x1").
static func texto_costo(receta: PlacementRule) -> String:
	var filas: Array = filas_costo(receta)
	if filas.is_empty():
		return TEXTO_GRATIS
	var partes: Array = []
	for f in filas:
		partes.append(String(f["texto"]))
	return ", ".join(partes)

## Total de unidades del costo (0 = gratis).
static func costo_total(receta: PlacementRule) -> int:
	return receta.costo_total() if receta != null else 0

## ── Motivos ─────────────────────────────────────────────────────────────

## Filas de motivos de rechazo. Cada fila: { motivo, texto }.
## Un resultado valido -> lista vacia (no hay motivos que mostrar).
static func filas_motivos(res: Dictionary) -> Array:
	var out: Array = []
	if res.is_empty():
		return out
	for m in (res.get("motivos", []) as Array):
		out.append({"motivo": int(m), "texto": ConstruccionTipos.texto(int(m))})
	return out

## Texto con TODOS los motivos unidos ("sin soporte debajo | zona protegida").
static func texto_motivos(res: Dictionary) -> String:
	var filas: Array = filas_motivos(res)
	if filas.is_empty():
		return ""
	var partes: Array = []
	for f in filas:
		partes.append(String(f["texto"]))
	return " | ".join(partes)

## ── Estado ──────────────────────────────────────────────────────────────

## true si la colocacion se puede confirmar (el preview dice ok).
static func puede_confirmar(res: Dictionary) -> bool:
	return bool(res.get("ok", false))

## Nombre legible de la pieza (o su id si no tiene nombre).
static func nombre_pieza(receta: PlacementRule) -> String:
	if receta == null:
		return ""
	if receta.nombre != "":
		return receta.nombre
	return String(receta.id)

## Linea de estado para el HUD. Valido -> "OK — piedra x3"; invalido ->
## "RECHAZADO — sin soporte debajo". Nunca devuelve cadena vacia si hay receta.
static func linea_estado(res: Dictionary, receta: PlacementRule) -> String:
	if puede_confirmar(res):
		return "OK — %s" % texto_costo(receta)
	var m: String = texto_motivos(res)
	if m == "":
		m = "invalido"
	return "RECHAZADO — %s" % m

## Resumen completo listo para pintar (una sola llamada desde la UI).
## { ok, nombre, costo[], costo_texto, costo_total, motivos[], motivos_texto,
##   linea, celdas, color }.
static func resumen(res: Dictionary, receta: PlacementRule) -> Dictionary:
	return {
		"ok": puede_confirmar(res),
		"nombre": nombre_pieza(receta),
		"costo": filas_costo(receta),
		"costo_texto": texto_costo(receta),
		"costo_total": costo_total(receta),
		"motivos": filas_motivos(res),
		"motivos_texto": texto_motivos(res),
		"linea": linea_estado(res, receta),
		"celdas": res.get("celdas", []),
		"color": BuildPreview.color_del_resultado(res),
	}
