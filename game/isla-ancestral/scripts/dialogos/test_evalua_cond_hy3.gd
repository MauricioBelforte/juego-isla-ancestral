extends SceneTree

## Hy3 — verificacion Sec21.8 (verificador != autor) del evaluador de condiciones
## de dialogo en runtime (DialogueNode._evalua_cond / evaluate_conditions).
## No cierra nada: es evidencia independiente de que las ramas de dialogo
## decididas por condiciones se calculan correctamente, no solo que el
## validador estatico (M21) acepta la sintaxis de los operadores.
##
## Guardia anti-falso-verde: se aserta AMBOS polos de cada operador
## (caso que debe dar true y caso que debe dar false). Si el evaluador
## tuviera un bug (p.ej. ">=" resuelto como ">"), el caso false falla.

func _initialize() -> void:
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	var fallos := 0
	var chequeos := 0

	# (operador, actual, valor, esperado)
	var casos := [
		["==", 5, 5, true],
		["==", 5, 6, false],
		["!=", 5, 6, true],
		["!=", 5, 5, false],
		[">=", 5, 5, true],
		[">=", 4, 5, false],
		["<=", 5, 5, true],
		["<=", 6, 5, false],
		[">", 6, 5, true],
		[">", 5, 5, false],
		["<", 4, 5, true],
		["<", 5, 5, false],
	]

	for c in casos:
		var op: String = c[0]
		var actual = c[1]
		var valor = c[2]
		var esperado: bool = c[3]
		chequeos += 1
		var nodo := DialogueNode.new()
		nodo.id = "n"
		nodo.conditions = [{"clave": "x", "operador": op, "valor": valor}]
		var vars := {"x": actual}
		var res: bool = nodo.evaluate_conditions(vars)
		if res != esperado:
			fallos += 1
			printerr("FALLO op=%s actual=%s valor=%s esperado=%s obtenido=%s" % [op, str(actual), str(valor), str(esperado), str(res)])

	# clave ausente -> false (rama no debe activarse)
	chequeos += 1
	var nodo2 := DialogueNode.new()
	nodo2.conditions = [{"clave": "y", "operador": "==", "valor": 1}]
	var res2: bool = nodo2.evaluate_conditions({})
	if res2 != false:
		fallos += 1
		printerr("FALLO clave-ausente: esperado false, obtenido %s" % str(res2))

	# operador invalido -> false (no crash; el validador estatico ya lo marca)
	chequeos += 1
	var nodo3 := DialogueNode.new()
	nodo3.conditions = [{"clave": "x", "operador": "~~", "valor": 1}]
	var res3: bool = nodo3.evaluate_conditions({"x": 1})
	if res3 != false:
		fallos += 1
		printerr("FALLO op-invalido: esperado false, obtenido %s" % str(res3))

	print("TEST HY3 EVALUA_COND: %d chequeo(s) | %d fallo(s)" % [chequeos, fallos])
	quit(2 if fallos > 0 else 0)
