# M163 - Test del Sistema de Encantamientos (suite ampliada, iter. 1)
# Cubre: catalogo, encantar/quitar, validaciones de recursos, contador de encantos,
# persistencia, dialogos del chaman (intro/regreso/todas), validadores M21,
# E2E cadena E (InteractionManager -> ShamanNPC -> DialogueManager -> ShamanUI ->
# encantar con cobro EconomyManager) y checks negativos (sondas de comportamiento).
# Ejecutar:
#   godot --headless --path game/isla-ancestral --script res://scripts/enchantment/test_enchantment.gd
extends SceneTree

var passed: int = 0
var failed: int = 0

func _init() -> void:
	call_deferred("_run")

func _check(cond: bool, msg: String) -> void:
	if cond:
		passed += 1
		print("[OK] " + msg)
	else:
		failed += 1
		print("[FAIL] " + msg)

func _fin() -> void:
	print("Resumen M163: %d checks, %d fallos" % [passed, failed])
	quit(1 if failed > 0 else 0)

func _run() -> void:
	# --- Autoloads ---
	var system = root.get_node_or_null("EnchantmentSystem")
	_check(system != null, "autoload EnchantmentSystem presente")
	if system == null:
		_fin()
		return
	var inv = root.get_node_or_null("Inventario")
	var item_db = root.get_node_or_null("ItemDatabase")
	var eco = root.get_node_or_null("EconomyManager")
	var dm = root.get_node_or_null("DialogueManager")
	var mgr = root.get_node_or_null("interacciones")
	_check(inv != null, "autoload Inventario presente")
	_check(item_db != null, "autoload ItemDatabase presente")
	_check(eco != null, "autoload EconomyManager presente")
	_check(dm != null, "autoload DialogueManager presente")
	_check(mgr != null, "autoload interacciones presente (M70)")

	# ================= A. Sistema (unit) =================
	_check(system.get_all_enchantments().size() == 4, "A1: catalogo con 4 encantamientos")
	_check(not system.is_enchanted("pickaxe_1"), "A2: sin encantar inicialmente")

	system.set_incense(10)
	_check(system.enchant_tool("pickaxe_1", "ancestral_cobre"), "A3: enchant_tool exitoso")
	_check(system.is_enchanted("pickaxe_1"), "A4: encantada tras enchant_tool")
	_check(not system.enchant_tool("pickaxe_1", "prospero_hierro"), "A5: doble encanto rechazado")
	var ability = system.get_active_ability("pickaxe_1")
	_check(ability.has("type") and ability.has("value"), "A6: get_active_ability con datos")
	_check(system.get_sell_bonus("pickaxe_2") == 0.0, "A7: sell bonus 0 sin encantar")
	_check(system.get_encantos_totales() >= 1, "A8: contador de encantos incrementa")

	# Sonda negativa 1: sin incienso -> falla
	system.set_incense(0)
	_check(not system.enchant_tool("pickaxe_2", "ancestral_cobre"), "A9: SIN incienso -> falla")
	# Sonda negativa 2: encantamiento inexistente en catalogo -> falla
	system.set_incense(10)
	_check(not system.enchant_tool("pickaxe_2", "id_fantasma"), "A10: encantamiento inexistente -> falla")
	# Nota: tool_id inexistente en inventario SI es aceptado por el system (registro por id
	# libre); la proteccion real esta en la UI (selecion desde inventario) y se prueba en C.

	# Todas encantadas
	system.set_incense(10)
	system.enchant_tool("pickaxe_2", "prospero_hierro")
	var todas_prev: bool = system.todas_encantadas(["pickaxe_1", "pickaxe_2"])
	_check(todas_prev, "A11: todas_encantadas true cuando ambas encantadas")
	_check(not system.todas_encantadas(["pickaxe_1", "pickaxe_3"]), "A12: false si alguna sin encantar")
	_check(not system.todas_encantadas([]), "A13: lista vacia -> false")

	# Persistencia (incluye contador M163)
	var dict_save: Dictionary = system.to_dict()
	var esperado_totales: int = system.get_encantos_totales()
	var esperado_incienso: int = system.get_incense()
	system.remove_enchantment("pickaxe_1")
	system.remove_enchantment("pickaxe_2")
	system.set_incense(0)
	_check(system.get_encantos_totales() == esperado_totales, "A14: remove NO altera el contador")
	system.from_dict(dict_save)
	_check(system.is_enchanted("pickaxe_1") and system.is_enchanted("pickaxe_2"), "A15: from_dict restaura encantamientos")
	_check(system.get_incense() == esperado_incienso, "A16: from_dict restaura incienso")
	_check(system.get_encantos_totales() == esperado_totales, "A17: from_dict restaura encantos_totales")

	# ================= B. Dialogos del chaman (M21) =================
	var dlg_ok := true
	for did in ["shaman_intro", "shaman_regreso", "shaman_todas"]:
		var grafo = load("res://scripts/dialogos/dialogue_graph.gd").load_from_json(
				"res://data/dialogues/" + did + ".json")
		if grafo == null or grafo.nodes.is_empty():
			dlg_ok = false
			_check(false, "B: grafo " + did + " carga")
			continue
		var probs: Array = grafo.validate()
		_check(probs.is_empty(), "B: " + did + " valida (0 problemas)")
		if did == "shaman_regreso":
			var nodo = grafo.get_start_node()
			_check(nodo != null and nodo.placeholders.has("encantos"),
					"B: shaman_regreso declara placeholder {encantos}")
	var validador = load("res://scripts/dialogos/dialog_graph_validator.gd").new()
	for did in ["shaman_intro", "shaman_regreso", "shaman_todas"]:
		var grafo2 = load("res://scripts/dialogos/dialogue_graph.gd").load_from_json(
				"res://data/dialogues/" + did + ".json")
		var vprob: Array = validador.validar(grafo2, validador.CLAVES_MUNDO_BASE)
		_check(vprob.is_empty(), "B: validador M21 " + did + " -> 0 claves desconocidas")

	# Reset de estado: la seccion A dejo encantos_totales > 0; el E2E debe
	# empezar como partida nueva (primera visita -> shaman_intro).
	system.from_dict({"enchantments": [], "incense": 0, "encantos_totales": 0})

	# ================= C. E2E cadena E (runtime real) =================
	# UIRoot (como main_island.gd L41)
	var ui_root = root.get_node_or_null("UIRoot")
	if ui_root == null:
		var ui_script = load("res://scripts/ui/ui_root.gd")
		ui_root = ui_script.new()
		ui_root.name = "UIRoot"
		root.add_child(ui_root)
	_check(root.get_node_or_null("UIRoot") != null, "C1: UIRoot montado")

	# Shaman spawneado (auto-registro InteractableBase)
	var shaman_script = load("res://scripts/enchantment/shaman_npc.gd")
	var shaman = shaman_script.new()
	shaman.name = "ShamanTest"
	root.add_child(shaman)
	_check(shaman.global_position.distance_to(Vector3(320, 35, 300)) < 0.1, "C2: chaman en spawn (320,35,300)")

	# Jugador fake cerca del chaman
	var jugador = Node3D.new()
	jugador.name = "JugadorFake"
	root.add_child(jugador)
	jugador.global_position = Vector3(321, 35, 300)
	mgr.configurar_jugador(jugador)
	for i in 4:
		await physics_frame
	# NOTA M163/M70: en tests --script el _process del manager NO corre;
	# el patron oficial del suite es invocar la evaluacion manualmente.
	mgr._evaluar_y_seleccionar()
	var objetivo = mgr.obtener_objetivo_actual()
	_check(objetivo != null and objetivo == shaman, "C3: manager detecta al chaman como objetivo (E)")

	# Recursos del jugador
	inv.add_item("OBJ-HER-001", 1)
	inv.add_item("OBJ-HER-002", 1)
	eco.depositar_monedas(500)
	system.set_incense(10)

	# --- Interaccion 1: primera visita -> shaman_intro ---
	if dm.is_dialogue_active():
		dm.stop_dialogue()
	mgr._evaluar_y_seleccionar()
	mgr.presionar_interact()
	_check(dm.is_dialogue_active(), "C4: E abre dialogo")
	_check(dm._dialogue_id == "shaman_intro", "C5: primera visita -> shaman_intro")
	_check(dm.get_session_vars().get("encantos", -1) == system.get_encantos_totales(),
			"C6: session {encantos} = contador real")
	var ui1 = shaman._ui
	_check(ui1 != null and ui1.visible, "C7: ShamanUI visible tras E")
	if ui1 == null:
		_check(false, "C7 aborta: ShamanUI no se creo (fin temprano del suite)")
		shaman.queue_free()
		jugador.queue_free()
		await process_frame
		_fin()
		return

	# --- UI funcional: lista herramientas y encanta end-to-end ---
	ui1.abrir()  # recarga herramientas (insertadas despues de abrir)
	var ids_herr: Array = load("res://scripts/enchantment/shaman_ui.gd").ids_herramientas(inv, item_db)
	_check(ids_herr.has("OBJ-HER-001") and ids_herr.has("OBJ-HER-002"), "C8: UI lista las 2 herramientas del jugador")

	ui1._seleccionar_herramienta(inv.CONTAINER_TYPE_CLASS.Id.BOLSILLO, 0, "OBJ-HER-001")
	ui1._seleccionar_encantamiento("ancestral_cobre")
	_check(not ui1._enchant_button.disabled, "C9: con recursos, boton Encantar habilitado")

	var saldo0: int = eco.saldo
	var inc0: int = system.get_incense()
	var total_antes_e2e: int = system.get_encantos_totales()
	_check(ui1.encantar_seleccion(), "C10: encantar_seleccion() end-to-end OK")
	_check(system.is_enchanted("OBJ-HER-001"), "C11: herramienta del jugador encantada")
	_check(eco.saldo == saldo0 - 200, "C12: cobro de monedas via EconomyManager (-200)")
	_check(system.get_incense() == inc0 - 3, "C13: cobro de incienso (-3)")
	_check("exit" in ui1._info_label.text, "C14: feedback de exito en la UI")
	_check(system.get_encantos_totales() == total_antes_e2e + 1, "C15: contador sube con el encanto E2E")

	# --- Interaccion 2: regreso -> shaman_regreso ---
	dm.stop_dialogue()
	mgr._evaluar_y_seleccionar()
	mgr.presionar_interact()
	_check(dm.is_dialogue_active() and dm._dialogue_id == "shaman_regreso",
			"C16: con encantos previos -> shaman_regreso")
	_check(dm.get_session_vars().get("encantos", -1) == system.get_encantos_totales(),
			"C17: regreso recuerda el contador real")

	# --- Encantar la 2a herramienta -> todas_encantadas -> shaman_todas ---
	system.set_incense(10)
	eco.depositar_monedas(250)
	ui1.abrir()
	ui1._seleccionar_herramienta(inv.CONTAINER_TYPE_CLASS.Id.BOLSILLO, 1, "OBJ-HER-002")
	ui1._seleccionar_encantamiento("prospero_hierro")
	_check(ui1.encantar_seleccion(), "C18: 2a herramienta encantada")
	_check(system.todas_encantadas(["OBJ-HER-001", "OBJ-HER-002"]), "C19: todas_encantadas true")
	dm.stop_dialogue()
	mgr._evaluar_y_seleccionar()
	mgr.presionar_interact()
	_check(dm.is_dialogue_active() and dm._dialogue_id == "shaman_todas",
			"C20: frase especial -> shaman_todas")

	# --- Checks negativos de la UI (comportamiento de fallo) ---
	dm.stop_dialogue()
	ui1.abrir()
	ui1._selected_tool_slot = {}
	ui1._selected_enchantment_id = ""
	_check(not ui1.encantar_seleccion(), "C21: sin seleccion -> false")
	ui1._seleccionar_herramienta(inv.CONTAINER_TYPE_CLASS.Id.BOLSILLO, 0, "OBJ-HER-001")
	ui1._seleccionar_encantamiento("ancestral_cobre")
	_check(not ui1.encantar_seleccion(), "C22: herramienta YA encantada -> false")
	_check("ya esta encantada" in ui1._info_label.text, "C23: feedback 'ya encantada'")
	ui1._seleccionar_herramienta(inv.CONTAINER_TYPE_CLASS.Id.BOLSILLO, 0, "OBJ-HER-003")
	ui1._seleccionar_encantamiento("caverna_cristal")
	system.set_incense(0)
	_check(not ui1.encantar_seleccion(), "C24: SIN incienso -> false (UI)")
	_check("incienso" in ui1._info_label.text, "C25: feedback 'falta incienso'")
	system.set_incense(20)  # caverna_cristal cuesta 12: pasa el filtro de incienso
	if eco.saldo > 0:
		eco.retirar_monedas(eco.saldo)
	_check(not ui1.encantar_seleccion(), "C26: SIN monedas -> false (UI)")
	_check("monedas" in ui1._info_label.text, "C27: feedback 'falta monedas'")
	_check(not system.enchant_tool("OBJ-HER-003", "id_fantasma"), "C28: encantamiento fantasma -> false")

	# Limpieza de escena de prueba
	shaman.queue_free()
	jugador.queue_free()
	await process_frame
	_fin()
