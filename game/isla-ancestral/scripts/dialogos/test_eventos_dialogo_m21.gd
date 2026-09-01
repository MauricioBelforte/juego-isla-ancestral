# Modelo: Hy3
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M21 (L82 + consumo M53): Test headless de las escenas breves de evento con dialogo
# disparadas por M20, y de que la UI de dialogo (M53) consume gift_reaction/level_up_reaction.
#
#  - reaccion_regalo.json: grafo que ramifica por reaccion_id (R_AMADO/R_GUSTA/R_NEUTRAL/R_DUPLICADO).
#  - reaccion_nivel.json: grafo breve de subida de nivel.
#  - DialogueManager auto-inicia estos dialogos en _on_gift_given / _on_level_up (guarda is_dialogue_active).
#  - DialogueUI muestra la expresion (badge) y guarda la ultima reaccion.
#
# NOTA: en --script los autoloads se anaden al arbol DESPUES de _init(), por eso la
# ejecucion se difiere con call_deferred (como test_amistad_eventos.gd / test_reaccion_m21_dialogo.gd).
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral \
#     --script res://scripts/dialogos/test_eventos_dialogo_m21.gd

extends SceneTree

var _fallos: int = 0

func _initialize() -> void:
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	_test_cargar_grafos()
	_test_ramas_por_clase()
	_test_ramas_por_nivel()
	_test_autodisparo_desde_eventbus()
	await _test_ui_consume_reaccion()
	await _test_ui_portrait_expresion()
	print("=== TEST EVENTOS DIALOGO M21 (L82 + M53 consume): %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, mensaje: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + mensaje)

func _test_cargar_grafos() -> void:
	var g1 := DialogueGraph.load_from_json("res://data/dialogues/reaccion_regalo.json")
	_check(g1.dialogue_id == "reaccion_regalo", "reaccion_regalo cargado")
	_check(g1.validate().is_empty(), "reaccion_regalo valido (sin problemas)")
	var g2 := DialogueGraph.load_from_json("res://data/dialogues/reaccion_nivel.json")
	_check(g2.dialogue_id == "reaccion_nivel", "reaccion_nivel cargado")
	_check(g2.validate().is_empty(), "reaccion_nivel valido (sin problemas)")

## Cada clase de GiftEvaluator desemboca en la rama de dialogo correcta (L82).
func _test_ramas_por_clase() -> void:
	var casos := [
		{"id": "R_GUSTA", "substr": "sonrisa"},
		{"id": "R_AMADO", "substr": "favorito"},
		{"id": "R_NEUTRAL", "substr": "detalle"},
		{"id": "R_DUPLICADO", "substr": "repetir"},
	]
	for c in casos:
		var mgr = load("res://scripts/dialogos/dialogue_manager.gd").new()
		var ok: bool = mgr.start_dialogue("reaccion_regalo",
			{"npc_id": "NPC_X", "reaccion_id": c["id"], "item_id": "FLOR"})
		_check(ok, "start reaccion_regalo para " + str(c["id"]))
		var txt: String = mgr.get_current_text_key()
		_check(txt.contains(c["substr"]), "rama %s -> linea contiene '%s'" % [c["id"], c["substr"]])
		mgr.stop_dialogue()
		mgr._grafos_cache.clear()

## reaccion_nivel ramifica por new_level (>=5, >=3, default) usando fall-through de condiciones.
func _test_ramas_por_nivel() -> void:
	var casos := [
		{"nivel": 5, "substr": "grandes amigos"},
		{"nivel": 3, "substr": "aprecio"},
		{"nivel": 1, "substr": "subio al nivel"},
	]
	for c in casos:
		var mgr = load("res://scripts/dialogos/dialogue_manager.gd").new()
		var ok: bool = mgr.start_dialogue("reaccion_nivel",
			{"npc_id": "NPC_X", "new_level": int(c["nivel"])})
		_check(ok, "start reaccion_nivel para nivel " + str(c["nivel"]))
		var txt: String = mgr.get_current_text_key()
		_check(txt.contains(c["substr"]), "rama nivel %s -> linea contiene '%s'" % [c["nivel"], c["substr"]])
		mgr.stop_dialogue()
		mgr._grafos_cache.clear()

## El flujo real M20->M21: gift_given / friendship_level_up auto-disparan el dialogo (L82).
func _test_autodisparo_desde_eventbus() -> void:
	var dm: Node = root.get_node_or_null("/root/DialogueManager")
	var bus: Node = root.get_node_or_null("/root/EventBus")
	if dm == null or bus == null or bus.npc == null:
		_check(false, "autoloads presentes para autodisparo"); return
	if dm.is_dialogue_active():
		dm.stop_dialogue()
	bus.npc.gift_given.emit("NPC_EV", "FLOR", int(1))
	_check(dm.is_dialogue_active(), "gift_given auto-inicia dialogo de reaccion")
	_check(dm.get_current_text_key().contains("sonrisa"), "dialogo auto-iniciado muestra rama R_GUSTA")
	dm.stop_dialogue()
	bus.npc.friendship_level_up.emit("NPC_EV", 3)
	_check(dm.is_dialogue_active(), "friendship_level_up auto-inicia dialogo de nivel")
	_check(dm.get_current_text_key().contains("nivel"), "dialogo de nivel (nivel 3) muestra linea de nivel")
	dm.stop_dialogue()

## La UI (M53) consume gift_reaction y guarda la expresion (badge + estado).
func _test_ui_consume_reaccion() -> void:
	var dm: Node = root.get_node_or_null("/root/DialogueManager")
	if dm == null:
		_check(false, "DialogueManager presente para UI"); return
	var ui_script := load("res://scripts/dialogos/ui/dialogue_ui.gd")
	var ui = ui_script.new()
	root.add_child(ui)
	await process_frame  # _ready conecta las senales del autoload
	dm.gift_reaction.emit("NPC_UI", "R_GUSTA", int(1), "FLOR", "feliz")
	_check(not ui.get_ultima_reaccion().is_empty(), "UI registra ultima reaccion")
	var r: Dictionary = ui.get_ultima_reaccion()
	_check(str(r.get("id")) == "R_GUSTA", "UI: reaccion_id = R_GUSTA")
	_check(str(r.get("expresion")) == "feliz", "UI: expresion = feliz")
	_check(ui._expresion != null and ui._expresion.text == "feliz", "UI: badge de expresion = feliz")
	# Tambien level_up_reaction
	dm.level_up_reaction.emit("NPC_UI", 4)
	var r2: Dictionary = ui.get_ultima_reaccion()
	_check(str(r2.get("id")) == "R_NIVEL", "UI: level_up_reaction -> R_NIVEL")
	_check(str(r2.get("new_level")) == "4", "UI: new_level = 4")
	if dm.is_dialogue_active():
		dm.stop_dialogue()
	ui.queue_free()

## El retrato grafico (M53) cambia de expresion con la reaccion (badge tint + estado).
func _test_ui_portrait_expresion() -> void:
	var dm: Node = root.get_node_or_null("/root/DialogueManager")
	if dm == null:
		_check(false, "DialogueManager presente para retrato"); return
	var ui_script := load("res://scripts/dialogos/ui/dialogue_ui.gd")
	var ui = ui_script.new()
	root.add_child(ui)
	await process_frame
	_check(ui._portrait != null, "UI tiene retrato (NpcPortraitUI)")
	# feliz (R_GUSTA)
	dm.gift_reaction.emit("NPC_P", "R_GUSTA", int(1), "FLOR", "feliz")
	_check(ui._portrait.get_expression() == "feliz", "Retrato: expresion = feliz")
	_check(ui._portrait._bg.color.is_equal_approx(Color(1.0, 0.95, 0.82)), "Retrato: tint feliz aplicado")
	# neutral (R_NEUTRAL)
	dm.gift_reaction.emit("NPC_P", "R_NEUTRAL", int(2), "PIEDRA", "neutral")
	_check(ui._portrait.get_expression() == "neutral", "Retrato: expresion = neutral")
	_check(ui._portrait._bg.color.is_equal_approx(Color(0.82, 0.82, 0.88)), "Retrato: tint neutral aplicado")
	# feliz_intenso (R_AMADO)
	dm.gift_reaction.emit("NPC_P", "R_AMADO", int(0), "FLOR", "feliz_intenso")
	_check(ui._portrait.get_expression() == "feliz_intenso", "Retrato: expresion = feliz_intenso")
	# el hablante se fija al entrar un nodo de dialogo
	ui._portrait.set_speaker("npc.Catalina")
	_check(ui._portrait.get_speaker() == "npc.Catalina", "Retrato: speaker = npc.Catalina")
	ui.queue_free()
