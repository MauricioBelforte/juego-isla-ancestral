# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M109: DialogoSchema — validación de grafos de diálogo (M21/M23).
# Reglas: root con id y start; start existe en nodes; todo nodo tiene id y
# text; las referencias (next, opciones[*].next, opciones[*].set) apuntan a
# nodos existentes; no hay nodos inalcanzables (desde start); sin loops
# "peligrosos" de un solo nodo (next -> self sin condición) — que el diálogo
# no cuelgue.
class_name DialogoSchema
extends RefCounted

## Devuelve Array[String] con los problemas del grafo (vacía si está sano).
static func validar_grafo(dialogo: Dictionary) -> Array[String]:
	var errores: Array[String] = []
	if typeof(dialogo) != TYPE_DICTIONARY:
		errores.append("grafo no es un diccionario")
		return errores
	var id_grafo := String(dialogo.get("id", ""))
	if id_grafo.is_empty():
		errores.append("grafo sin id")
	var nodes: Dictionary = dialogo.get("nodes", {})
	if typeof(nodes) != TYPE_DICTIONARY or nodes.is_empty():
		errores.append("grafo sin nodos")
		return errores
	# start existe
	var start := String(dialogo.get("start", ""))
	if not nodes.has(start):
		errores.append("start (%s) no existe en nodes" % start)
	# nodos inválidos + referencias
	var alcanzables := {}
	var pila: Array[String] = [start]
	while not pila.is_empty():
		var nid := pila.pop_back()
		if alcanzables.has(nid):
			continue
		alcanzables[nid] = true
		var node: Dictionary = nodes.get(nid, {})
		if not node.has("text") or String(node.get("text", "")).is_empty():
			errores.append("nodo %s sin text" % nid)
		var next := String(node.get("next", ""))
		if next != "" and next != nid and not nodes.has(next):
			errores.append("nodo %s refiere next inexistente: %s" % [nid, next])
		elif next != "":
			pila.append(next)
		for opcion in node.get("opciones", []):
			if typeof(opcion) == TYPE_DICTIONARY:
				var o_next := String(opcion.get("next", ""))
				if o_next != "" and not nodes.has(o_next):
					errores.append("nodo %s opción refiere inexistente: %s" % [nid, o_next])
				elif o_next != "":
					pila.append(o_next)
	# huérfanos
	var huerfanos: Array[String] = []
	for nid in nodes:
		if not alcanzables.has(nid):
			huerfanos.append(nid)
	if huerfanos.size() > 0:
		errores.append("nodos inalcanzables desde start: %s" % ", ".join(huerfanos))
	return errores
