extends SceneTree

## Hy3 — verificacion Sec21.8 (verificador != autor) de los EFECTOS de dialogo
## en runtime (DialogueNode.apply_effects). Complementa la validacion estatica
## (log 2358/2359) y el evaluador de condiciones (log 2360).
##
## Cubre el camino determinista de SESION (set / increment / remove) que no
## depende de autoloads, y el camino de MUNDO (flag_) si WorldState esta
## montado en --script headless.
##
## Guardia anti-falso-verde: se aserta el valor RESULTANTE correcto de cada
## accion (p.ej. increment 2+5 = 7.0, no 7 ni "7"; remove borra solo la clave).

func _initialize() -> void:
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	var fallos := 0
	var chequeos := 0

	# caso 1: session set
	chequeos += 1
	var n1 := DialogueNode.new()
	n1.effects = [{"clave": "x", "accion": "set", "valor": 3}]
	var sv1 := {}
	n1.apply_effects(sv1, {})
	if not (sv1.has("x") and sv1["x"] == 3):
		fallos += 1
		printerr("FALLO session set: esperado x==3, obtenido %s" % str(sv1.get("x", "NA")))

	# caso 2: session increment (2 + 5 = 7.0 en float)
	chequeos += 1
	var n2 := DialogueNode.new()
	n2.effects = [{"clave": "x", "accion": "increment", "valor": 5}]
	var sv2 := {"x": 2}
	n2.apply_effects(sv2, {})
	if not (sv2.has("x") and float(sv2["x"]) == 7.0):
		fallos += 1
		printerr("FALLO session increment: esperado 7.0, obtenido %s" % str(sv2.get("x", "NA")))

	# caso 3: session remove (borra solo la clave indicada)
	chequeos += 1
	var n3 := DialogueNode.new()
	n3.effects = [{"clave": "x", "accion": "remove"}]
	var sv3 := {"x": 1, "y": 9}
	n3.apply_effects(sv3, {})
	if sv3.has("x"):
		fallos += 1
		printerr("FALLO session remove: x sigue presente")
	if not sv3.has("y"):
		fallos += 1
		printerr("FALLO session remove: y borrado por error")

	# caso 4: session increment desde clave ausente (0.0 + 1 = 1.0)
	chequeos += 1
	var n4 := DialogueNode.new()
	n4.effects = [{"clave": "z", "accion": "increment", "valor": 1}]
	var sv4 := {}
	n4.apply_effects(sv4, {})
	if not (sv4.has("z") and float(sv4["z"]) == 1.0):
		fallos += 1
		printerr("FALLO session increment ausente: esperado 1.0, obtenido %s" % str(sv4.get("z", "NA")))

	# casos 5/6: world flag (solo si WorldState autoload esta montado en --script)
	var ws = null
	if Engine.get_main_loop() != null:
		ws = Engine.get_main_loop().root.get_node_or_null("/root/WorldState")
	if ws != null and ws.has_method("get_flag"):
		chequeos += 1
		var n5 := DialogueNode.new()
		n5.effects = [{"clave": "flag_hy3_test", "accion": "set", "valor": 9, "destino": "world"}]
		n5.apply_effects({}, {})
		if ws.get_flag("flag_hy3_test", null) != 9:
			fallos += 1
			printerr("FALLO world flag explicito: esperado 9")
		chequeos += 1
		var n6 := DialogueNode.new()
		n6.effects = [{"clave": "flag_hy3_imp", "accion": "set", "valor": 4}]
		n6.apply_effects({}, {})
		if ws.get_flag("flag_hy3_imp", null) != 4:
			fallos += 1
			printerr("FALLO world flag implicito (flag_): esperado 4")
	else:
		print("SKIP world: WorldState no montado en --script (no es fallo)")

	print("TEST HY3 APPLY_EFFECTS: %d chequeo(s) | %d fallo(s)" % [chequeos, fallos])
	quit(2 if fallos > 0 else 0)
