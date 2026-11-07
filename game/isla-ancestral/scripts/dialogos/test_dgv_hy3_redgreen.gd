# Hy3 - verificacion §21.8 red/green del DialogGraphValidator (M162 / M21).
# OBJETIVO: probar el guardian EN ROJO por inyeccion (trampa 1) para descartar
# que el verde de test_contextual_dialogue_m162.gd sea un falso-verde.
#   - ROJO: grafo con 4 defectos inyectados debe reportar problemas (no pasar).
#   - VERDE: grafo bien formado debe dar 0 problemas.
#   - VERDE-2: validar_texto() sobre JSON crudo bien formado debe dar ok.

extends SceneTree

func _init() -> void:
	var fallos := 0

	# ---- ROJO: 4 defectos inyectados ----
	var rojo = _grafo_roto()
	var pr: Array = DialogGraphValidator.validar(rojo)
	if pr.is_empty():
		fallos += 1
		print("FALLO ROJO: el grafo roto paso como valido (FALSE-GREEN)")
	else:
		print("  ROJO OK: %d problema(s) detectado(s)" % pr.size())
		for p in pr:
			print("    - %s" % p)
		var txt: String = ""
		for p in pr:
			txt += str(p) + " "
		if not txt.contains("huérfano"):
			fallos += 1
			print("FALLO ROJO: no detecto nodo huérfano")
		if not txt.contains("no existe"):
			fallos += 1
			print("FALLO ROJO: no detecto next_id colgante")
		if not txt.contains("operador"):
			fallos += 1
			print("FALLO ROJO: no detecto operador invalido")
		if not txt.contains("desconocida"):
			fallos += 1
			print("FALLO ROJO: no detecto clave de mundo desconocida")

	# ---- VERDE: grafo bien formado ----
	var verde = _grafo_bueno()
	var pv: Array = DialogGraphValidator.validar(verde)
	if not pv.is_empty():
		fallos += 1
		print("FALLO VERDE: grafo correcto reporto problemas: %s" % pv)
	else:
		print("  VERDE OK: 0 problemas en grafo correcto")

	# ---- VERDE-2: validar_texto() sobre JSON crudo bien formado ----
	var d = {}
	d["id"] = "g1"
	d["start"] = "n0"
	var nodos = {}
	var nd0 = {"tipo": 1, "next_id": "n1"}
	var nd1 = {"tipo": 1}
	nodos["n0"] = nd0
	nodos["n1"] = nd1
	d["nodes"] = nodos
	var jt: String = JSON.stringify(d)
	var rt = DialogGraphValidator.validar_texto(jt)
	if not rt.ok:
		fallos += 1
		print("FALLO VERDE texto: %s" % rt)
	else:
		print("  VERDE-2 OK: validar_texto() acepta JSON crudo bien formado")

	print("=== TEST HY3 RED/GREEN DGV: %d fallo(s) ===" % fallos)
	quit(1 if fallos > 0 else 0)

func _grafo_bueno():
	var g = DialogueGraph.new()
	g.start_node_id = "n0"
	var n0 = DialogueNode.new()
	n0.id = "n0"
	n0.next_id = "n1"
	var n1 = DialogueNode.new()
	n1.id = "n1"
	g.nodes = {"n0": n0, "n1": n1}
	return g

func _grafo_roto():
	var g = DialogueGraph.new()
	g.start_node_id = "n0"
	var n0 = DialogueNode.new()
	n0.id = "n0"
	n0.next_id = "n_inexistente"
	var n1 = DialogueNode.new()
	n1.id = "n1"
	var n2 = DialogueNode.new()
	n2.id = "n2"
	var c = {}
	c["operador"] = "~~"
	c["clave"] = "clave_quee_no_existe"
	n2.conditions = [c]
	g.nodes = {"n0": n0, "n1": n1, "n2": n2}
	return g
