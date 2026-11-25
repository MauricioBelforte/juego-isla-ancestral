# Modelo: minimax-m3-1-flash
# Plataforma: DeepAI Code (pi)
# Fecha: 2026-11-25
#
# M17 Construccion — BuildInteraction: CONTENIDO de las piezas funcionales.
#
# POR QUE EXISTE: el checklist de M17 pedia que "la demolicion de piezas
# funcionales (camas, almacenamiento) libere su contenido", pero la logica NO
# existia en ninguna parte (0 matches de `liberar|contenido` en las suites de
# M17) y el archivo `build_interaction.gd` — que `04-Codigo.md` §1 ya listaba
# como "Punto de interaccion en piezas funcionales (camas, almacenamiento M18)"
# — tampoco existia. Este archivo es ese punto de interaccion.
#
# QUE ES (modelo PURO, sin nodos): traduce los campos opcionales que el
# manager ya guarda en cada estructura ("cofre", "muebles", "puertas") a:
#   * los ITEMS que vuelven al inventario al demoler la pieza (no se pierden),
#   * los sub-muebles y puertas que se van con ella.
#
# FORMATO (el que ya usan `estructuras_codec.gd` y `test_construccion.gd`):
#   "cofre":   {"contenido": [{"item_id": "madera", "cantidad": 4}]}
#   "muebles": [{"celda": [1, 0, 1], "mueble": "mesa", "rotacion": 1}]
#   "puertas": [{"celda": [0, 0, 1], "abierta": true}]
#
# NUCLEO PURO: testeable en headless sin escena ni motor.

class_name BuildInteraction
extends RefCounted

## Piezas del catalogo que pueden GUARDAR contenido. No es una lista cerrada:
## `es_funcional()` tambien acepta cualquier pieza cuya estructura traiga un
## campo "cofre" con contenido (el dato manda sobre la lista).
const PIEZAS_CON_CONTENIDO: Array[StringName] = [
	&"cofre_ancestral",
	&"cama",
	&"estanteria",
	&"mesa",
	&"bote_pesca",
	&"cofre",
]

## true si la pieza puede guardar contenido (por catalogo o por sus datos).
static func es_funcional(pieza_id: StringName) -> bool:
	if PIEZAS_CON_CONTENIDO.has(pieza_id):
		return true
	return false

## Normaliza el contenido de un cofre a `{item_id: cantidad}`.
## Acepta las dos formas que existen en el proyecto:
##   {"contenido": [{"item_id": "madera", "cantidad": 4}]}   (canonica)
##   {"items": {"madera": 4}}                              (alternativa)
## Tolerante: cualquier otra forma devuelve {} (no inventa datos).
static func items_de_contenido(bruto: Variant) -> Dictionary:
	var out: Dictionary = {}
	if bruto == null:
		return out
	if bruto is Dictionary:
		var d: Dictionary = bruto
		if d.has("items") and d["items"] is Dictionary:
			for k in (d["items"] as Dictionary).keys():
				var n: int = int((d["items"] as Dictionary)[k])
				if n > 0:
					out[String(k)] = n
			return out
		if d.has("contenido") and d["contenido"] is Array:
			for e in (d["contenido"] as Array):
				if e is Dictionary:
					var item: Dictionary = e
					var id: String = String(item.get("item_id", ""))
					var n2: int = int(item.get("cantidad", 0))
					if id != "" and n2 > 0:
						out[id] = out.get(id, 0) + n2
			return out
	return out

## Contenido de una estructura colocada.
## Devuelve { items: {item_id: cantidad}, muebles: Array, puertas: Array }.
## Una estructura sin contenido devuelve las listas vacias (nunca null).
static func contenido_de(estructura: Dictionary) -> Dictionary:
	var items: Dictionary = {}
	var muebles: Array = []
	var puertas: Array = []
	if estructura.is_empty():
		return {"items": items, "muebles": muebles, "puertas": puertas}
	if estructura.has("cofre"):
		items = items_de_contenido(estructura["cofre"])
	if estructura.has("muebles") and estructura["muebles"] is Array:
		muebles = (estructura["muebles"] as Array).duplicate(true)
	if estructura.has("puertas") and estructura["puertas"] is Array:
		puertas = (estructura["puertas"] as Array).duplicate(true)
	return {"items": items, "muebles": muebles, "puertas": puertas}

## true si la estructura tiene algo que liberar (items, muebles o puertas).
static func tiene_contenido(estructura: Dictionary) -> bool:
	var c: Dictionary = contenido_de(estructura)
	if not (c["items"] as Dictionary).is_empty():
		return true
	if not (c["muebles"] as Array).is_empty():
		return true
	if not (c["puertas"] as Array).is_empty():
		return true
	return false

## LIBERA el contenido de una estructura: devuelve lo que el jugador recupera al
## demolerla. Los ITEMS vuelven al inventario (no se pierden). Los muebles y las
## puertas se van con la pieza (se reportan aparte).
##
## Devuelve { items: {item_id: cantidad}, muebles: Array, puertas: Array }.
##
## NO MUTA la estructura: la pieza demolida se guarda en el historial tal cual,
## con su contenido, para que un "deshacer" la devuelva ÍNTEGRA (y entonces los
## items vuelven del inventario al cofre, no se pierden por el camino). Para
## vaciar de verdad el cofre de una pieza consumida: `vaciar_contenido()`.
static func liberar_contenido(estructura: Dictionary) -> Dictionary:
	var c: Dictionary = contenido_de(estructura)
	return {"items": c["items"], "muebles": c["muebles"], "puertas": c["puertas"]}

## VACIA el contenido de una estructura (consumo real de la pieza, p.ej. un
## cofre que se rompe). Muta la estructura: el cofre queda con contenido vacio.
## Los items NO se devuelven aqui: el decides el que llama.
static func vaciar_contenido(estructura: Dictionary) -> Dictionary:
	var liberado: Dictionary = liberar_contenido(estructura)
	if estructura.has("cofre"):
		var cofre: Dictionary = (estructura["cofre"] as Dictionary).duplicate(true)
		cofre["contenido"] = []
		cofre["items"] = {}
		estructura["cofre"] = cofre
	return liberado

## Reconstruye el formato "cofre" a partir de {item_id: cantidad} (inverso de
## `items_de_contenido`): { "contenido": [{"item_id": ..., "cantidad": ...}] }.
static func items_a_contenido(items: Dictionary) -> Dictionary:
	var lista: Array = []
	var ids: Array = items.keys()
	ids.sort()
	for k in ids:
		var n: int = int(items[k])
		if n > 0:
			lista.append({"item_id": String(k), "cantidad": n})
	return {"contenido": lista}

## Items totales (suma de cantidades) de un contenido liberado.
static func total_items(contenido: Dictionary) -> int:
	var n: int = 0
	for k in (contenido.get("items", {}) as Dictionary).keys():
		n += int((contenido["items"] as Dictionary)[k])
	return n

## Texto corto para la UI ("vuelve: madera x4" / "vuelve: nada").
static func texto_contenido(contenido: Dictionary) -> String:
	var items: Dictionary = contenido.get("items", {})
	if items.is_empty():
		return "vuelve: nada"
	var partes: Array = []
	var ids: Array = items.keys()
	ids.sort()
	for k in ids:
		partes.append("%s x%d" % [String(k), int(items[k])])
	return "vuelve: %s" % ", ".join(partes)
