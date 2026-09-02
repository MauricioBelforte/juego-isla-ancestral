# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M158: Test de ToolTierSystem (tiers data-driven, gates, forjas por isla,
# cursos de oficio, integración M14/M38, persistencia M59).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/herramientas158/test_tiers.gd

extends SceneTree

var _fallos: int = 0
var _ts: Node = null
var _inv: Node = null
var _eco: Node = null


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_ts = root.get_node_or_null("Tiers")
	_inv = root.get_node_or_null("Inventario")
	_eco = root.get_node_or_null("EconomyManager")
	_check(_ts != null, "ToolTierSystem autoload presente")
	_check(_inv != null, "Inventario presente (M14)")
	_check(_eco != null, "EconomyManager presente (M38)")
	if _ts == null:
		print("=== TEST M158 TIERS: 1+ fallo(s) ===")
		quit(1)
		return
	_test_carga_config()
	_test_tiers_propiedades()
	_test_gates_can_access()
	_test_gates_desbloqueo()
	_test_forjas()
	_test_anti_softlock()
	_test_cursos()
	_test_historia_blocks()
	_test_persistencia()
	print("=== TEST M158 TIERS: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)


func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)


func _test_carga_config() -> void:
	_check(_ts.tiers_count() == 4, "4 tiers cargados: %d" % _ts.tiers_count())
	_check(_ts.gates_count() == 6, "6 gates cargados: %d" % _ts.gates_count())
	_check(_ts.forjas_count() == 4, "4 forjas cargadas: %d" % _ts.forjas_count())
	_check(_ts.cursos_count() == 4, "4 cursos cargados: %d" % _ts.cursos_count())
	_check(_ts.get_section_name() == "tool_tiers", "sección 'tool_tiers' (M59)")


func _test_tiers_propiedades() -> void:
	# §B: propiedades exactas por tier
	var t1: Dictionary = _ts.get_tier("T1_COBRE")
	_check(float(t1.get("dano", 0)) == 1.0 and int(t1.get("area", 0)) == 1, "T1 dano 1.0 área 1x1")
	var t3: Dictionary = _ts.get_tier("T3_ORO")
	_check(float(t3.get("dano", 0)) == 3.5 and float(t3.get("velocidad", 0)) == 2.0 and int(t3.get("area", 0)) == 2, "T3 dano 3.5 vel 2.0 área 2x2")
	var t4: Dictionary = _ts.get_tier("T4_CRISTAL")
	_check(float(t4.get("dano", 0)) == 5.0 and float(t4.get("velocidad", 0)) == 3.0, "T4 dano 5.0 vel 3.0")
	# Orden de niveles coherente
	_check(_ts.get_tier_nivel("T2_HIERRO") > _ts.get_tier_nivel("T1_COBRE"), "T2 > T1")


func _test_gates_can_access() -> void:
	# Sin tier: gates cerrados
	_check(not _ts.can_access_zone("zona_bosque_denso", "hacha"), "gate rama T1 cerrado sin hacha mejorada")
	_check(not _ts.can_access_zone("zona_cueva_cristal", "martillo"), "gate cristal T4 cerrado")
	# Zona sin gate: libre
	_check(_ts.can_access_zone("zona_libre_inexistente"), "zona sin gate es libre")
	# info_gate para tooltip
	var info: Dictionary = _ts.info_gate("zona_cantera")
	_check(String(info.get("required_tier", "")) == "T2_HIERRO", "info_gate requiere T2: %s" % str(info))
	_check(not bool(info.get("abierto", true)), "info_gate cerrado inicialmente")


func _test_gates_desbloqueo() -> void:
	var senales: Array = []
	var cb := func(zone: String, gate: String) -> void:
		senales.append(gate)
	_ts.gate_unlocked.connect(cb)
	# Simular progreso: forjar T2 hacha en Ceniza → gate raíz anciana abrible
	_eco.depositar_monedas(2000)
	_inv.agregar_items({"hierro": 10})
	var res: Dictionary = _ts.forjar("isla_ceniza", "hacha")
	_check(bool(res.ok), "forja T2 hacha OK")
	_check(_ts.tiene_tier("hacha", "T2_HIERRO"), "hacha alcanza T2")
	# El gate NO se abre solo: el jugador interactúa → desbloquear_gate
	_check(_ts.can_access_zone("zona_raices", "hacha"), "raíz anciana accesible con T2 hacha")
	_check(bool(_ts.desbloquear_gate("gate_raiz_anciana")), "gate raíz desbloqueado (interacción)")
	_check(bool(_ts.desbloquear_gate("gate_raiz_anciana")) == false, "desbloqueo doble es no-op (idempotente)")
	_check(senales.has("gate_raiz_anciana"), "señal gate_unlocked emitida")
	_check(_ts.info_gate("zona_raices").get("abierto", false) == true, "info_gate abierto tras desbloqueo")
	_ts.gate_unlocked.disconnect(cb)


func _test_forjas() -> void:
	# Forja T1 gratis (regalo carpintero) en isla_raiz
	var res: Dictionary = _ts.forjar("isla_raiz", "pico")
	_check(bool(res.ok), "T1 pico gratis en isla_raiz")
	_check(String(_ts.tier_max_de("pico")) == "T1_COBRE", "tier máx pico = T1")
	# Forja con materiales faltantes
	var saldo: int = int(_eco.saldo)
	_inv.agregar_items({"oro": 5})  # faltan 15 oro
	res = _ts.forjar("isla_coral", "pico")
	_check(not bool(res.ok), "forja T3 sin materiales rechazada")
	_check(int(_eco.saldo) == saldo, "saldo intacto tras rechazo de materiales")
	_check(String(res.motivo).contains("faltan materiales"), "motivo materiales: %s" % String(res.motivo))
	# Forja completa: monedas + materiales se consumen juntos
	_inv.agregar_items({"oro": 20})
	# Fondos para T3 (2000 AO): la forja T2 ya cobró 500, el saldo puede no alcanzar
	_eco.depositar_monedas(3000)
	var saldo_antes_t3: int = int(_eco.saldo)
	res = _ts.forjar("isla_coral", "pico")
	_check(bool(res.ok), "forja T3 pico OK con todo")
	_check(int(_eco.saldo) == saldo_antes_t3 - 2000, "2000 AO consumidos por T3")
	_check(int(_inv.count_item("oro")) == 5, "20 oro consumidos (25 agregados → 5): %d" % int(_inv.count_item("oro")))
	_check(String(_ts.tier_max_de("pico")) == "T3_ORO", "tier máx pico = T3")
	# Anti-doble-forja (cozy)
	res = _ts.forjar("isla_coral", "pico")
	_check(not bool(res.ok) and String(res.motivo).contains("ya tienes"), "no re-forjar tier alcanzado")


func _test_anti_softlock() -> void:
	# §I: la forja T1 en isla_raiz no cuesta nada y siempre está disponible
	var forja: Dictionary = _ts.get_forja("isla_raiz")
	_check(int(forja.get("monedas", -1)) == 0, "forja T1 gratis (anti-softlock)")
	_check((forja.get("materiales", {}) as Dictionary).is_empty(), "T1 sin materiales")


func _test_cursos() -> void:
	# Curso desconocido
	var res: Dictionary = _ts.tomar_curso("curso_fantasma")
	_check(not bool(res.ok), "curso desconocido rechazado")
	# Curso válido con fondos
	_eco.depositar_monedas(5000)
	res = _ts.tomar_curso("curso_carpinteria")
	_check(bool(res.ok), "curso carpintería tomado (300 AO)")
	_check(_ts.curso_aprendido("curso_carpinteria"), "curso registrado")
	# Único: no se repite
	res = _ts.tomar_curso("curso_carpinteria")
	_check(not bool(res.ok) and String(res.motivo).contains("único"), "curso no repetible")
	# Venta de herramientas habilitada por tier_max del curso
	_check(_ts.puede_vender_tier("T1_COBRE"), "curso permite vender T1")
	_check(not _ts.puede_vender_tier("T3_ORO"), "curso carpintería NO habilita T3")


func _test_historia_blocks() -> void:
	# §I: gates que bloquean historia consultables por M22
	# (el pico ya alcanzó T4 en _test_forjas; el hacha está en T2 < T3 requerido)
	_check(_ts.zona_bloquea_historia("zona_tumba", "hacha"), "tumba ancestral bloquea historia (hacha T2 < T4)")
	_check(not _ts.zona_bloquea_historia("zona_bosque_denso", "hacha"), "bosque denso NO bloquea historia (T1 normal)")
	# Con T4 pico ya forjado: cueva de cristal consultable (T4 == T4)
	_eco.depositar_monedas(10000)
	_inv.agregar_items({"cristal": 5})
	var res: Dictionary = _ts.forjar("isla_aurora", "pico")
	_check(bool(res.ok), "forja T4 pico OK")
	_check(_ts.tiene_tier("pico", "T4_CRISTAL"), "pico alcanza T4")


func _test_persistencia() -> void:
	var data: Dictionary = _ts.get_save_data()
	_check(int(data.get("version", 0)) == 1, "save_data versionado")
	var tm: Dictionary = data.get("tier_max", {})
	_check(String(tm.get("pico", "")) == "T4_CRISTAL", "tier máx persistido")
	_check(String(tm.get("hacha", "")) == "T2_HIERRO", "tier máx hacha persistido")
	_check((data.get("gates_abiertos", []) as Array).has("gate_raiz_anciana"), "gates persistidos")
	_check((data.get("cursos", []) as Array).has("curso_carpinteria"), "cursos persistidos")
	_check(int(data.get("forjas_count", 0)) >= 3, "conteo de forjas persistido")
	# Round-trip con purga de catálogo viejo
	var con_viejo: Dictionary = data.duplicate(true)
	(con_viejo.tier_max as Dictionary)["martillo"] = "T9_FANTASMA"
	(con_viejo.gates_abiertos as Array).append("gate_fantasma")
	(con_viejo.cursos as Array).append("curso_fantasma")
	_ts.restore_save_data({})
	_check(_ts.tier_max_de("pico") == "", "restore vacío limpia")
	_ts.restore_save_data(con_viejo)
	_check(String(_ts.tier_max_de("pico")) == "T4_CRISTAL", "round-trip restaura tiers")
	_check(_ts.tier_max_de("martillo") == "", "tier fantasma purgado (migración)")
	_check(_ts.curso_aprendido("curso_carpinteria"), "round-trip restaura cursos")
	_check(not _ts.curso_aprendido("curso_fantasma"), "curso fantasma purgado")
	_check(_ts.info_gate("zona_raices").get("abierto", false) == true, "gates abiertos restaurados")
	# NUNCA re-emisión: restaurar no dispara gate_unlocked
	var senales: Array = [0]
	var cb := func(_z: String, _g: String) -> void:
		senales[0] += 1
	_ts.gate_unlocked.connect(cb)
	_ts.restore_save_data(con_viejo)
	_check(int(senales[0]) == 0, "restore NO re-emite gate_unlocked (§2.3)")
	_ts.gate_unlocked.disconnect(cb)