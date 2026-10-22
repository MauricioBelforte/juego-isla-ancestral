# Modelo: GLM-5.3-Flash (G-5.3-Flash-Agente)
# Plataforma: Kilo Code
# Fecha: 2026-10-22
#
# M21->M64: QA del puente de rutina (NPC pausa mientras habla; item [S]
# "NPC se detiene... + La rutina del NPC se bloquea mientras habla y se
# reanuda despues" del 05-Checklist de M21; turno 2-BIS).
# Ejecutar: Godot --headless --path game\isla-ancestral --script res://scripts/dialogos/qa_m21_puente_m64.gd

extends SceneTree

var _checks: int = 0
var _fallos: int = 0

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _summary() -> void:
	print("=== Resumen QA puente M21->M64: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

## Stub NPC en el grupo "npcs" (duck-typing igual que el consumidor real).
class StubNPC extends Node:
	var pauses: int = 0
	var resumes: int = 0
	func pause_ai() -> void:
		pauses += 1
	func resume_ai() -> void:
		resumes += 1

func _run() -> void:
	var dm: Node = load("res://scripts/dialogos/dialogue_manager.gd").new()
	root.add_child(dm)
	# Stub NPC en el grupo (mismo grupo que usa PhotoService)
	var npc := StubNPC.new()
	npc.name = "bruno_sapo"
	root.add_child(npc)
	npc.add_to_group("npcs")
	# Grafo simple en cache (patron de test_skip)
	var g := DialogueGraph.new()
	g.dialogue_id = "conv_npc"
	g.start_node_id = "s"
	var s := DialogueNode.new()
	s.id = "s"
	s.tipo = DialogueNode.TIPO_LINEA
	s.next_id = "fin"
	g.nodes["s"] = s
	var fin := DialogueNode.new()
	fin.id = "fin"
	fin.tipo = DialogueNode.TIPO_FIN
	g.nodes["fin"] = fin
	dm._grafos_cache["conv_npc"] = g

	# 1. start con npc_id en contexto -> pausa al NPC
	var ok: bool = dm.start_dialogue("conv_npc", {"npc_id": "bruno_sapo"})
	_check(ok, "arranque de dialogo con npc_id OK")
	_check(npc.pauses == 1, "puente: pause_ai llamado al iniciar el dialogo (%d)" % npc.pauses)
	_check(dm.get("_npc_pausado_id") == "bruno_sapo", "puente: el manager recuerda al pausado")

	# 2. stop -> reanuda
	dm.stop_dialogue()
	_check(npc.resumes == 1, "puente: resume_ai al terminar (%d)" % npc.resumes)
	_check(String(dm.get("_npc_pausado_id")) == "", "puente: id de pausa limpiado")

	# 3. Dialogo sin npc_id: sin pausa (headless-safe, otros usos intactos)
	ok = dm.start_dialogue("conv_npc")
	_check(ok and npc.pauses == 1, "puente: sin npc_id no pausa a nadie")
	dm.stop_dialogue()
	_check(npc.resumes == 1, "puente: stop sin pausado previo es no-op")

	# 4. npc_id inexistente: no crashea ni pausa a otros
	npc.name = "otro_nombre"
	ok = dm.start_dialogue("conv_npc", {"npc_id": "fantasma"})
	_check(ok and npc.pauses == 1, "puente: npc_id fantasma no pausa a otros agentes")
	dm.stop_dialogue()
	npc.queue_free()
	dm.queue_free()
