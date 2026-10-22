# Modelo: GLM-5.3-Flash (G-5.3-Flash-Agente)
# Plataforma: Kilo Code
# Fecha: 2026-10-22
#
# M21: QA del auto-snapshot del WorldState al iniciar dialogos (habilita
# condiciones de historia/misiones/sellos/festivales; turno 2-BIS).
# Ejecutar: Godot --headless --path game\isla-ancestral --script res://scripts/dialogos/qa_m21_contexto_mundo.gd

extends SceneTree

var _checks: int = 0
var _fallos: int = 0

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _summary() -> void:
	print("=== Resumen QA contexto-mundo M21: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _grafo_cond() -> DialogueGraph:
	var g := DialogueGraph.new()
	g.dialogue_id = "ctx_mundo"
	g.start_node_id = "s"
	var s := DialogueNode.new()
	s.id = "s"
	s.tipo = DialogueNode.TIPO_LINEA
	s.conditions = [{"clave": "historia_stage", "operador": ">=", "valor": 2}]
	s.next_id = "fin"
	g.nodes["s"] = s
	var fin := DialogueNode.new()
	fin.id = "fin"
	fin.tipo = DialogueNode.TIPO_FIN
	g.nodes["fin"] = fin
	return g

func _run() -> void:
	var ws := root.get_node_or_null("/root/WorldState")
	_check(ws != null and ws.has_method("get_all_flags"), "WorldState autoload presente con get_all_flags")
	var dm: Node = load("res://scripts/dialogos/dialogue_manager.gd").new()
	root.add_child(dm)
	dm._grafos_cache["ctx_mundo"] = _grafo_cond()

	# 1. Auto-snapshot: flag del mundo visible en session_vars sin context explicito
	ws.set_flag("historia_stage", 2)
	var ok: bool = dm.start_dialogue("ctx_mundo")
	_check(ok, "arranque con condicion de mundo OK")
	var sv: Dictionary = dm.get_session_vars()
	_check(int(sv.get("historia_stage", -1)) == 2, "auto-snapshot: historia_stage del mundo visible en session_vars (=%s)" % str(sv.get("historia_stage")))
	dm.stop_dialogue()

	# 2. El contexto explicito del llamador MANDA (no lo pisa el mundo)
	ws.set_flag("historia_stage", 1)  # mundo en etapa anterior
	ok = dm.start_dialogue("ctx_mundo", {"historia_stage": 9})
	sv = dm.get_session_vars()
	_check(ok and int(sv.get("historia_stage", -1)) == 9, "contexto explicito manda sobre el mundo (9 vs 1)")
	dm.stop_dialogue()

	# 3. El nodo con condicion de mundo evoluciona (gate responde al snapshot)
	#    cond >= 2 con mundo en stage 2 -> el grafo entra al nodo "s" sin bloqueo
	ws.set_flag("historia_stage", 2)
	ok = dm.start_dialogue("ctx_mundo")
	_check(ok, "gate: cond >= 2 con stage 2 permitio el arranque")
	dm.stop_dialogue()

	# 4. Nombre de flag tipico de misiones/sellos/festivales (paridad M22/M23/M73)
	ws.set_flag("mision_etapa_cocina", 3)
	ws.set_flag("sello_templo", "obtenido")
	ws.set_flag("festival_activo", "solsticio")
	ok = dm.start_dialogue("ctx_mundo", {"historia_stage": 0})  # context evita gate
	sv = dm.get_session_vars()
	_check(int(sv.get("mision_etapa_cocina", 0)) == 3 and String(sv.get("sello_templo", "")) == "obtenido" and String(sv.get("festival_activo", "")) == "solsticio",
		"paridad: flags de misiones/sellos/festivales entran al snapshot")
	dm.stop_dialogue()

	# 5. Regresion del flujo lineal (el auto-snapshot no rompe dialogos sin condiciones)
	dm._grafos_cache.clear()
	var g2 := DialogueGraph.new()
	g2.dialogue_id = "lineal_plain"
	g2.start_node_id = "s"
	var s2 := DialogueNode.new()
	s2.id = "s"
	s2.tipo = DialogueNode.TIPO_LINEA
	s2.next_id = "fin"
	g2.nodes["s"] = s2
	var fin2 := DialogueNode.new()
	fin2.id = "fin"
	fin2.tipo = DialogueNode.TIPO_FIN
	g2.nodes["fin"] = fin2
	dm._grafos_cache["lineal_plain"] = g2
	_check(dm.start_dialogue("lineal_plain"), "regresion: dialogo sin condiciones arranca igual")
	_check(dm.is_dialogue_active(), "regresion: dialogo lineal activo")
	dm.stop_dialogue()
	dm.queue_free()
