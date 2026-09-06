# Modelo: Hy3 / WorkBuddy
# Fecha: 2026-09-05
# M162 (T-M162-003, Log 665) + M19: test headless de INTEGRACION M162 -> M19.
# Verifica que villager_dialogue_hook.gd resuelve el grafo contextualmente via
# ContextualDialogueManager y que DialogueManager (M21) lo carga desde
# data/dialogues/contextual/ (fallback de _cargar_grafo). Tambien verifica la
# ruta legacy (dialogue_id fijo) y el fallback a dialogue_id cuando M162 falla.

extends SceneTree

const WorldStateScript = preload("res://scripts/dialogos/world_state_service.gd")
const DialogueManagerScript = preload("res://scripts/dialogos/dialogue_manager.gd")
const HookScript = preload("res://scripts/npc/villager_dialogue_hook.gd")
const CDM = preload("res://scripts/dialogos/contextual_dialogue_manager.gd")

var _fallos := 0

func _check(cond: bool, msg: String) -> void:
	if cond:
		print("[OK]   " + msg)
	else:
		_fallos += 1
		printerr("[FAIL] " + msg)

func _init() -> void:
	# Diferir al primer frame: asegura que root y autoloads esten listos.
	call_deferred("_run")

func _run() -> void:
	var ws = _asegurar("/root/WorldState", WorldStateScript)
	var dm = _asegurar("/root/DialogueManager", DialogueManagerScript)

	# Estado de mundo mínimo y determinista para riz_005 SALUDO cap0.
	ws.set_flag("flag_capitulo", 0)

	# Instanciar el hook y conectarlo al arbol.
	var hook = HookScript.new()
	root.add_child(hook)

	# ---- Test 1: M162 resuelve contextualmente ----
	hook.npc_id = "NPC-RIZ_005"
	hook.dialogue_id = ""
	var ctx := _contexto(ws, "NPC-RIZ_005")
	var exp_entry = CDM.seleccionar("NPC-RIZ_005", "SALUDO", ctx).get("entry", {})
	var esperado := str(exp_entry.get("graph", "")).replace(".json", "")
	print("[T1] M162 esperado para NPC-RIZ_005/SALUDO: '%s'" % esperado)
	hook.solicitar_dialogo()
	_check(dm.is_dialogue_active(), "[T1] DialogueManager activo tras solicitar (M162 resolvió)")
	_check(dm._dialogue_id == esperado, "[T1] graph_id resuelto == esperado M162 ('%s' fue '%s')" % [esperado, dm._dialogue_id])
	_check(dm._grafo_actual != null and not dm._grafo_actual.nodes.is_empty(),
		"[T1] grafo contextual cargado con nodos (fallback data/dialogues/contextual/)")
	dm.stop_dialogue()

	# ---- Test 2: ruta legacy intacta (solo dialogue_id fijo, sin npc_id) ----
	hook.npc_id = ""
	hook.dialogue_id = "riz_005_cap0_saludo"
	hook.solicitar_dialogo()
	_check(dm.is_dialogue_active(), "[T2] ruta legacy activa con dialogue_id fijo")
	_check(dm._dialogue_id == "riz_005_cap0_saludo", "[T2] usa dialogue_id fijo ('%s')" % dm._dialogue_id)
	dm.stop_dialogue()

	# ---- Test 3: fallback a dialogue_id cuando M162 NO resuelve ----
	hook.npc_id = "NPC-INEXISTENTE-XYZ"
	hook.dialogue_id = "riz_005_cap0_saludo"
	hook.solicitar_dialogo()
	_check(dm.is_dialogue_active(), "[T3] fallback a dialogue_id cuando M162 falla")
	_check(dm._dialogue_id == "riz_005_cap0_saludo", "[T3] usa dialogue_id fijo tras fallo M162 ('%s')" % dm._dialogue_id)
	dm.stop_dialogue()

	print("\n=== test_m162_integracion_m19: %d fallo(s) ===" % _fallos)
	quit(0 if _fallos == 0 else 1)

## Asegura que el autoload exista en /root (real si --script lo cargo, simulado si no).
func _asegurar(path: String, script) -> Node:
	var n = root.get_node_or_null(path)
	if n == null:
		n = script.new()
		n.name = path.replace("/root/", "")
		root.add_child(n)
	return n

## Replica el contexto que construye el hook (misma fuente = mismo resultado M162).
func _contexto(ws: Node, npc_id: String) -> Dictionary:
	var ctx := {}
	if ws.has_method("get_all_flags"):
		ctx = ws.get_all_flags().duplicate()
	var claves := ["estacion", "es_noche", "es_de_dia", "dia", "mes", "anio", "hora", "minuto", "clima"]
	var slug := npc_id.strip_edges().to_lower().trim_prefix("npc-")
	if slug != "":
		claves.append("amistad_" + slug)
	if ws.has_method("get_snapshot"):
		var snap = ws.get_snapshot(claves)
		for k in snap.keys():
			ctx[str(k)] = snap[k]
	return ctx
