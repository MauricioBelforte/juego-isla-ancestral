# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-28
#
# M55 (iter. 7, checklist L164): clasificacion de SECCIONES LORE del diario.
#
# Diseno §3.2 ("Entrada secreta (lore) -> visible como '???' SOLO en secciones
# lore") y §11 regla 1 ("'secreta: true' solo en secciones lore (pistas,
# sellos, ruinas, cartas); NUNCA en colecciones (criaturas, plantas, minerales,
# recetas)").
#
# Fuente UNICA de la clasificacion: la usan
#   - diary_service.gd   -> visibilidad de la lista (una secreta de coleccion
#                           no se vuelve visible por estar marcada: sigue
#                           invisible hasta registrarse, como cualquier otra);
#   - diary_layer.gd     -> texto "???" de fila y detalle;
#   - validate_diary.gd  -> regla de DATOS (una 'secreta' fuera de lore es un
#                           defecto del catalogo, no solo un detalle de UI).
# Sin `class_name` a proposito: se carga por `preload` para no depender de la
# cache de clases en `--script` (pitfall GUIA-GODOT: un class_name nuevo no
# existe hasta reimportar `.godot/` en un worktree compartido).
#
# Ejecutar la suite: Godot --headless --path game/isla-ancestral
#   --script res://scripts/diario/test_diario_lore_m55.gd
extends RefCounted

## Secciones LORE: unicas donde se admite `secreta: true` y donde aplica el
## anti-spoiler "???" (DIARY.BLOQUEADO). El resto de las 14 categorias son
## COLECCIONES (personajes, lugares, criaturas, plantas, minerales, recetas,
## descubrimientos, misiones, eventos, fotografias).
const CATEGORIAS: Array[String] = ["pistas", "sellos", "ruinas", "cartas"]


## ¿La categoria es una seccion lore?
static func es_lore(categoria: String) -> bool:
	return categoria in CATEGORIAS


## ¿La entrada debe mostrarse como "???" (DIARY.BLOQUEADO)?
## Solo lore + secreta + NO registrada. En una coleccion la marca `secreta` se
## IGNORA: la entrada sigue invisible hasta registrarse (semantica normal de
## coleccion), en vez de aparecer como "???" fuera de lore (L164).
static func bloqueada(categoria: String, secreta: bool, registrada: bool) -> bool:
	return secreta and not registrada and es_lore(categoria)


## Entradas con `secreta` declarada como booleano verdadero.
## Devuelve [{id, categoria, en_lore}]. `en_lore` es false = defecto de datos.
static func secretas(parseado: Dictionary) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for c in parseado.get("categorias", []):
		var cat := String((c as Dictionary).get("id", ""))
		for e in (c as Dictionary).get("entradas", []):
			var d: Dictionary = e
			if not d.has("secreta"):
				continue
			if typeof(d.get("secreta")) != TYPE_BOOL:
				continue  # se reporta aparte (mal tipada)
			if not bool(d.get("secreta")):
				continue
			out.append({"id": String(d.get("id", "")), "categoria": cat, "en_lore": es_lore(cat)})
	return out


## Violaciones de la regla "secreta solo en lore" (§3.2 / §11.1 / L164).
## Cada item: {id, categoria}. Vacio = catalogo coherente.
static func violaciones_secreta(parseado: Dictionary) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for s in secretas(parseado):
		if not bool(s.get("en_lore", false)):
			out.append({"id": String(s.get("id", "")), "categoria": String(s.get("categoria", ""))})
	return out


## Entradas cuyo campo `secreta` esta presente pero NO es booleano.
## Devuelve [{id, categoria, tipo}] con el nombre del tipo medido.
static func secretas_mal_tipadas(parseado: Dictionary) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for c in parseado.get("categorias", []):
		var cat := String((c as Dictionary).get("id", ""))
		for e in (c as Dictionary).get("entradas", []):
			var d: Dictionary = e
			if not d.has("secreta"):
				continue
			if typeof(d.get("secreta")) == TYPE_BOOL:
				continue
			out.append({
				"id": String(d.get("id", "")),
				"categoria": cat,
				"tipo": type_string(typeof(d.get("secreta"))),
			})
	return out
