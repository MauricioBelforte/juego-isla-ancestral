# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-12
#
# M121: Soporte Post-Lanzamiento — Test headless de los 4 servicios (D2)
# Cubre FAQManager, TicketManager, HotfixManager, PatchManager y su
# integracion a traves del autoload SupportManager.
#
# Guardian anti-falso-verde (3 capas, trampas 11/63/122):
#   1. marcadores _fin("X") por bloque -> nombra el bloque que no cerro
#   2. piso CHECKS_MINIMOS MEDIDO en verde -> caza el aborto dentro de un helper
#   3. _summary() diferido en _init -> si _run() aborta, el resumen corre igual
#      (un watchdog en _process NO sirve: trampa 61).

extends SceneTree

const _SC_FAQ := preload("res://scripts/support/faq_manager.gd")
const _SC_TICKET := preload("res://scripts/support/ticket_manager.gd")
const _SC_HOTFIX := preload("res://scripts/support/hotfix_manager.gd")
const _SC_PATCH := preload("res://scripts/support/patch_manager.gd")

const BLOQUES := ["A", "B", "C", "D", "E", "F"]
const CHECKS_MINIMOS := 70  # MEDIDO en verde (3 corridas), no estimado

var _fallos: int = 0
var _checks: int = 0
var _vistos: Dictionary = {}
var _terminado: bool = false

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _fin(nombre: String) -> void:
	_vistos[nombre] = true

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _run() -> void:
	print("=== [M121] Test de servicios de soporte (D2) ===")
	_bloque_a_faq()
	_bloque_b_tickets()
	_bloque_c_hotfix()
	_bloque_d_patch()
	_bloque_e_integracion()
	_bloque_f_negativos()
	_terminado = true

func _summary() -> void:
	if not _terminado:
		print("!! _run() no termino: posible SCRIPT ERROR que aborto la funcion")
	for n in BLOQUES:
		if not _vistos.has(n):
			_checks += 1
			_fallos += 1
			print("  [FAIL] bloque %s NO se ejecuto (posible SCRIPT ERROR)" % n)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("  [FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen M121 servicios: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M121 SERVICIOS FALLIDO - salida con codigo 1")
		quit(1)
	else:
		print("TEST M121 SERVICIOS OK")
		quit(0)

func _bloque_a_faq() -> void:
	print("--- A: FAQManager ---")
	var fm = _SC_FAQ.new()
	_check("A1 carga 15 FAQ", fm.total() == 15, "total=%d" % fm.total())
	_check("A2 por_categoria guardado (1)", fm.por_categoria("guardado").size() == 1)
	_check("A3 por_categoria inexistente (0)", fm.por_categoria("zzz").is_empty())
	_check("A4 search 'crash' >= 1", fm.search_faq("crash").size() >= 1)
	_check("A5 search vacio (0)", fm.search_faq("").is_empty())
	_check("A6 search 'xyz' (0)", fm.search_faq("xyz").is_empty())
	# categorias() DERIVA de los items de FAQ (no de la lista declarada en
	# faq.json, que tiene 11). Medido: 10 categorias presentes (guardado, crash,
	# rendimiento, cuenta, tecnica, gameplay, historia, dlc, bug, soporte).
	# La lista declarada de 11 la expone SupportManager.
	_check("A7 categorias presentes en FAQ (10)", fm.categorias().size() == 10, "n=%d" % fm.categorias().size())
	_check("A8 faq_data no vacio", not fm.faq_data.is_empty())
	_check("A9 search devuelve estructura", fm.search_faq("crash")[0].has("categoria"))
	_fin("A")

func _bloque_b_tickets() -> void:
	print("--- B: TicketManager ---")
	var tm = _SC_TICKET.new()
	var cuenta := {"created": 0, "resolved": 0}
	tm.ticket_created.connect(func(_tid): cuenta["created"] += 1)
	tm.ticket_resolved.connect(func(_tid): cuenta["resolved"] += 1)
	var id1: String = str(tm.create_ticket("bug", "alta", "no carga", {"plataforma": "windows"}))
	var id2: String = str(tm.create_ticket("crash", "critica", "crash al inicio", {}))
	var id3: String = str(tm.create_ticket("duda", "zzz", "prioridad invalida", {}))
	_check("B1 tres tickets", tm.total() == 3, "n=%d" % tm.total())
	_check("B2 ids unicos", id1 != id2 and id2 != id3 and id1 != id3)
	_check("B3 get_ticket devuelve dict", not tm.get_ticket(id1).is_empty())
	_check("B4 estado inicial abierto", str(tm.get_ticket(id1).get("estado", "")) == "abierto")
	_check("B5 prioridad invalida -> media", str(tm.get_ticket(id3).get("prioridad", "")) == "media")
	_check("B6 user_info preservada", str(tm.get_ticket(id1).get("user_info", {}).get("plataforma", "")) == "windows")
	_check("B7 update estado valido", bool(tm.update_ticket_status(id1, "en_progreso")))
	_check("B8 estado actualizado", str(tm.get_ticket(id1).get("estado", "")) == "en_progreso")
	_check("B9 estado invalido rechazado", not bool(tm.update_ticket_status(id1, "zzz")))
	_check("B10 ticket inexistente -> false", not bool(tm.update_ticket_status("NOPE", "resuelto")))
	_check("B11 resolve_ticket", bool(tm.resolve_ticket(id2)))
	_check("B12 por_estado resuelto (1)", tm.por_estado("resuelto").size() == 1)
	_check("B13 por_prioridad critica (1)", tm.por_prioridad("critica").size() == 1)
	_check("B14 get_ticket inexistente -> {}", tm.get_ticket("NOPE").is_empty())
	_check("B15 historial registra cambios", tm.get_ticket(id1).get("historial", []).size() == 2)
	_check("B16 senal ticket_created x3", int(cuenta["created"]) == 3, "n=%d" % int(cuenta["created"]))
	_check("B17 senal ticket_resolved x1", int(cuenta["resolved"]) == 1, "n=%d" % int(cuenta["resolved"]))
	_fin("B")

func _bloque_c_hotfix() -> void:
	print("--- C: HotfixManager ---")
	var hm = _SC_HOTFIX.new()
	var hf: String = str(hm.trigger_hotfix("BUG-999", "1.0.1"))
	_check("C1 hotfix creado", hm.total() == 1)
	_check("C2 fase inicial identificado", str(hm.get_hotfix(hf).get("fase", "")) == "identificado")
	_check("C3 sla 48 h", int(hm.get_hotfix(hf).get("sla_horas", 0)) == 48)
	_check("C4 avanzar fase corregido", bool(hm.avanzar_fase(hf, "corregido")))
	_check("C5 fase invalida rechazada", not bool(hm.avanzar_fase(hf, "zzz")))
	_check("C6 deploy por version", bool(hm.deploy_hotfix("1.0.1")))
	_check("C7 queda desplegado", bool(hm.get_hotfix(hf).get("desplegado", false)))
	_check("C8 deploy version inexistente -> false", not bool(hm.deploy_hotfix("9.9.9")))
	_check("C9 desplegados (1)", hm.desplegados().size() == 1)
	var anuncio: String = str(hm.communicate_hotfix("1.0.1", "crash al inicio"))
	_check("C10 anuncio con version", anuncio.contains("1.0.1"))
	_check("C11 anuncio con descripcion", anuncio.contains("crash al inicio"))
	_fin("C")

func _bloque_d_patch() -> void:
	print("--- D: PatchManager ---")
	var pm = _SC_PATCH.new()
	var reg: Dictionary = pm.create_patch("1.1.0", ["BUG-1"])
	_check("D1 parche creado", pm.total() == 1)
	_check("D2 fase acumulando", str(reg.get("fase", "")) == "acumulando")
	_check("D3 bug_ids 1", pm.get_patch("1.1.0").get("bug_ids", []).size() == 1)
	_check("D4 acumular bug nuevo", bool(pm.acumular_bug("1.1.0", "BUG-2")))
	_check("D5 no duplica bug", not bool(pm.acumular_bug("1.1.0", "BUG-2")))
	_check("D6 bug_ids 2", pm.get_patch("1.1.0").get("bug_ids", []).size() == 2)
	_check("D7 avanzar fase testeando", bool(pm.avanzar_fase("1.1.0", "testeando")))
	_check("D8 deploy", bool(pm.deploy_patch("1.1.0")))
	_check("D9 queda desplegado", bool(pm.get_patch("1.1.0").get("desplegado", false)))
	_check("D10 deploy inexistente -> false", not bool(pm.deploy_patch("9.9.9")))
	var cl: String = str(pm.update_changelog("1.1.0", []))
	_check("D11 changelog con version", cl.contains("1.1.0"))
	_check("D12 changelog lista 2 bugs", cl.contains("BUG-1") and cl.contains("BUG-2"))
	_check("D13 changelog inexistente -> vacio", str(pm.update_changelog("9.9.9", [])).is_empty())
	_fin("D")

func _bloque_e_integracion() -> void:
	print("--- E: integracion SupportManager ---")
	var sm: Variant = root.get_node_or_null("SupportManager")
	if sm == null:
		_check("E1 SupportManager presente", false)
		_fin("E")
		return
	_check("E1 SupportManager presente", true)
	_check("E2 accessor faq_manager", sm.faq_manager() != null)
	_check("E3 accessor ticket_manager", sm.ticket_manager() != null)
	_check("E4 accessor hotfix_manager", sm.hotfix_manager() != null)
	_check("E5 accessor patch_manager", sm.patch_manager() != null)
	_check("E6 acceso cacheado (misma instancia)", sm.ticket_manager() == sm.ticket_manager())
	var tid: String = str(sm.create_ticket("bug", "alta", "desde support_manager", {}))
	_check("E7 create_ticket devuelve id", tid != "")
	_check("E8 ticket visible en el manager", not sm.ticket_manager().get_ticket(tid).is_empty())
	_check("E9 resolve_ticket ok", bool(sm.resolve_ticket(tid)))
	_check("E10 setup_email_autoresponder", str(sm.setup_email_autoresponder().get("email", "")) == "support@islaancestral.com")
	_check("E11 setup_discord_channels (3)", sm.setup_discord_channels().size() == 3)
	_check("E12 var support_email", str(sm.support_email) == "support@islaancestral.com")
	_fin("E")

func _bloque_f_negativos() -> void:
	print("--- F: negativos y bordes ---")
	var tm = _SC_TICKET.new()
	_check("F1 manager nuevo sin tickets", tm.total() == 0)
	_check("F2 por_estado vacio", tm.por_estado("resuelto").is_empty())
	var fm = _SC_FAQ.new("res://data/support/no_existe_zzz.json")
	_check("F3 FAQ ruta inexistente -> 0", fm.total() == 0)
	_check("F4 FAQ ruta inexistente -> sin categorias", fm.categorias().is_empty())
	var hm = _SC_HOTFIX.new()
	_check("F5 hotfix inexistente -> {}", hm.get_hotfix("NOPE").is_empty())
	_check("F6 avanzar fase sobre inexistente -> false", not bool(hm.avanzar_fase("NOPE", "corregido")))
	var pm = _SC_PATCH.new()
	_check("F7 acumular bug en parche inexistente -> false", not bool(pm.acumular_bug("NOPE", "B")))
	_check("F8 get_patch inexistente -> {}", pm.get_patch("NOPE").is_empty())
	_fin("F")
