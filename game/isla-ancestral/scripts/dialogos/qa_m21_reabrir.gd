# Modelo: GLM-5.3-Flash (G-5.3-Flash-Agente)
# Plataforma: Kilo Code
# Fecha: 2026-10-23
#
# M58 RF23: QA de reabrir_ultimo() del M21 (reabrir el último diálogo con el
# contexto de arranque conservado). Ejecutar: Godot --headless --path
# game\isla-ancestral --script res://scripts/dialogos/qa_m21_reabrir.gd

extends SceneTree

var _checks: int = 0
var _fallos: int = 0

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _summary() -> void:
	print("=== Resumen QA reabrir RF23 M21/M58: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _instalar_manager() -> Node:
	var existing := root.get_node_or_null("/root/DialogueManager")
	if existing != null:
		return existing
	var script := load("res://scripts/dialogos/dialogue_manager.gd") as Script
	var node := Node.new()
	node.name = "DialogueManager"
	node.set_script(script)
	root.add_child(node)
	return node

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	var mgr: Node = _instalar_manager()
	if mgr == null:
		_check(false, "manager no instalado")
		return

	# Pre: reabrir_ultimo sin contexto previo -> false
	mgr._rf23_ultimo_id = ""
	_check(mgr.reabrir_ultimo() == false, "reabrir sin historial debe devolver false")

	# 1) abrir dialogo con contexto propio
	var ok_start: bool = mgr.start_dialogue("finneas_slice", {"nombre_viajero": "Kael"})
	_check(ok_start, "start_dialogue finneas_slice debe abrir")
	_check(mgr.is_dialogue_active(), "dialogo activo tras start")

	# 2) avanzar un nodo (progreso) y cerrar
	var id_inicial: String = mgr._nodo_actual.id if mgr._nodo_actual != null else ""
	mgr.advance()
	var id_avanzado: String = mgr._nodo_actual.id if mgr._nodo_actual != null else ""
	_check(id_inicial == "saludo", "nodo inicial debe ser saludo, fue " + id_inicial)
	_check(id_avanzado != "", "advance movio a otro nodo")
	mgr.stop_dialogue()
	_check(not mgr.is_dialogue_active(), "dialogo cerrado")

	# 3) reabrir: mismo dialogo, contexto de arranque conservado
	var ok_re: bool = mgr.reabrir_ultimo()
	_check(ok_re, "reabrir_ultimo debe devolver true con historial")
	_check(mgr.is_dialogue_active(), "dialogo activo tras reabrir")
	_check(mgr._dialogue_id == "finneas_slice", "reabrio el mismo dialogo, fue " + str(mgr._dialogue_id))
	var vars: Dictionary = mgr._session_vars
	_check(String(vars.get("nombre_viajero", "")) == "Kael", "contexto de arranque conservado (nombre_viajero=Kael)")

	# 4) flujo continuable tras reabrir (advance no explota)
	mgr.advance()
	_check(mgr.is_dialogue_active(), "flujo continuable tras reabrir")
	mgr.stop_dialogue()

	# 5) reabrir con dialogo activo debe fallar (guard)
	mgr.start_dialogue("finneas_slice", {})
	var guard: bool = mgr.reabrir_ultimo()
	_check(guard == false, "reabrir con dialogo activo debe devolver false")
	mgr.stop_dialogue()

	# 6) historial tras el segundo dialogo apunta al mismo id ( unico ultimo )
	_check(String(mgr._rf23_ultimo_id) == "finneas_slice", "historial apunta al ultimo id")
