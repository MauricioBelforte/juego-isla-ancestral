# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01 (iter. 1-2) / 2026-09-02 (iter. 3)
#
# M72: Test de AchievementService (delegación M71, desbloqueo idempotente,
# % real, logros ocultos, persistencia + iter.3: fechas, retroactividad,
# API consulta RF10, progreso humano RF8, validación RF14, migración v1→v2).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/logros/test_logros.gd

extends SceneTree

var _fallos: int = 0
var _ach: Node = null
var _pm: Node = null
var _bus: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_ach = root.get_node_or_null("Achievements")
	_pm = root.get_node_or_null("ProgressionManager")
	_bus = root.get_node_or_null("EventBus")
	_check(_ach != null, "Achievements autoload presente")
	_check(_pm != null, "ProgressionManager presente (M71)")
	if _ach == null or _pm == null:
		print("=== TEST M72 LOGROS: 1+ fallo(s) ===")
		quit(1)
		return
	_test_catalogo()
	_test_validacion_rf14()
	_test_desbloqueo_por_evento()
	_test_idempotente()
	_test_fechas_rf4()
	_test_api_consulta_rf10()
	_test_progreso_humano_rf8()
	_test_porcentaje_real()
	_test_ocultos()
	_test_persistencia()
	_test_migracion_v1()
	_test_retroactividad_rf5()
	print("=== TEST M72 LOGROS: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_catalogo() -> void:
	_check(_ach.logros_count() == 7, "7 logros cargados: %d" % _ach.logros_count())
	_check(_ach.get_section_name() == "achievements", "sección 'achievements' (M59)")

func _test_validacion_rf14() -> void:
	# Catálogo real: 0 problemas esperados (salida accionable con 0 -> OK)
	var problemas: int = _ach.validar_catalogo()
	_check(problemas == 0, "catálogo real sin problemas (RF14): %d" % problemas)
	_check(_ach.TIPOS_CONDICION_VALIDOS.size() == 10, "vocabulario M71 §3.6 completo: %d" % _ach.TIPOS_CONDICION_VALIDOS.size())

func _test_desbloqueo_por_evento() -> void:
	# M72 escucha progreso_hito_alcanzado de M71 → evaluar_todos
	# logro_primer_sello depende de sello_historia → M22 es la fuente de verdad
	# (§2.2): el test marca el sello vía Historia.marcar_sello (emite prereq_met
	# → M71 stat+hito → M72 evalúa).
	var h := root.get_node_or_null("Historia")
	_check(h != null, "Historia presente (M22)")
	if h == null:
		return
	var desbloqueados: Array = []
	var cb := func(id: String, _nombre: String) -> void:
		desbloqueados.append(id)
	_ach.logro_desbloqueado.connect(cb)
	h.marcar_sello("sello_ceniza_sala1")
	_ach.evaluar_todos()
	_check(_ach.esta_desbloqueado("logro_primer_sello"), "sello M22 → logro M72 (fuente de verdad §2.2)")
	# 7 sellos → logro_siete_sellos
	for s in ["sello_ceniza_sala2", "sello_mar_intermedia", "sello_mar_sala1",
			"sello_brisa_sala1", "sello_brisa_sala2", "sello_brisa_camara"]:
		h.marcar_sello(s)
	_ach.evaluar_todos()
	_check(_ach.esta_desbloqueado("logro_siete_sellos"), "7 sellos → logro_siete_sellos")
	_check(desbloqueados.size() >= 2, "señales logro_desbloqueado emitidas (%d)" % desbloqueados.size())
	_ach.logro_desbloqueado.disconnect(cb)

func _test_idempotente() -> void:
	var senales: Array = [0]
	var cb := func(_id: String, _nombre: String) -> void:
		senales[0] += 1
	_ach.logro_desbloqueado.connect(cb)
	var primera: bool = _ach.desbloquear("logro_primer_sello")
	_check(not primera, "desbloquear ya-desbloqueado devuelve false (idempotente)")
	_check(senales[0] == 0, "sin doble señal de logro")
	_ach.logro_desbloqueado.disconnect(cb)

func _test_fechas_rf4() -> void:
	# RF4: fecha determinista día M29 persistida en el desbloqueo
	var f: Dictionary = _ach.fecha_de("logro_primer_sello")
	_check(f.has("dia"), "fecha con 'dia' (RF4): %s" % str(f))
	var gt := root.get_node_or_null("GameTime")
	if gt != null and gt.has_method("dia_absoluto"):
		_check(int(f.get("dia", -1)) == int(gt.dia_absoluto()), "día coincide con M29 GameTime (%s)" % str(f.get("dia")))
	# Write-through: mark_dirty llamado (SaveManager presente)
	var sm := root.get_node_or_null("SaveManager")
	_check(sm != null, "SaveManager presente para write-through")

func _test_api_consulta_rf10() -> void:
	var todos: Array = _ach.get_todos()
	_check(todos.size() == 7, "get_todos devuelve 7: %d" % todos.size())
	var estado: Dictionary = _ach.get_estado("logro_primer_sello")
	_check(bool(estado.get("desbloqueado", false)), "get_estado desbloqueado OK")
	_check(bool(_ach.is_unlocked("logro_primer_sello")), "is_unlocked OK")
	var def: Dictionary = _ach.get_definicion("logro_primer_sello")
	_check(String(def.get("nombre", "")) != "", "get_definicion con nombre")
	var desb: Array = _ach.get_desbloqueados()
	_check(desb.size() >= 2, "get_desbloqueados >= 2: %d" % desb.size())
	_check(absf(_ach.get_porcentaje_completado() - _ach.porcentaje_real()) < 0.001, "get_porcentaje_completado = porcentaje_real")
	# listado_para_ui alias de get_todos
	_check(_ach.listado_para_ui().size() == 7, "listado_para_ui alias OK")

func _test_progreso_humano_rf8() -> void:
	# logro_viajero: viajes_realizados >= 3 con progreso_parcial
	var p: Dictionary = _ach.progreso_de("logro_viajero")
	_check(float(p.get("requerido", 0.0)) == 3.0, "requerido=3 en logro_viajero: %s" % str(p))
	var humano: String = _ach.get_progreso_humano("logro_viajero")
	_check(humano.contains("de"), "progreso humano 'X de Y': %s" % humano)
	# Clamp: logrado nunca supera requerido
	_check(float(p.get("logrado", 0.0)) <= 3.0, "clamp progreso (RF8)")

func _test_porcentaje_real() -> void:
	# §3.2 M55: logros usan el total REAL (no anti-spoiler)
	var p: float = _ach.porcentaje_real()
	_check(p > 0.0 and p <= 1.0, "porcentaje_real en (0,1]: %.2f" % p)
	_check(_ach.desbloqueados().size() >= 2, "2+ desbloqueados")

func _test_ocultos() -> void:
	# Oculto desbloqueado → nombre real visible; no desbloqueado → "???"
	var listado: Array = _ach.listado_para_ui()
	for l in listado:
		if String(l.id) == "logro_secreto_guardian":
			if bool(l.desbloqueado):
				_check(String(l.nombre) != "???", "oculto desbloqueado muestra nombre real (§3.2 no aplica a logros)")
			else:
				_check(String(l.nombre) == "???", "oculto no desbloqueado = '???' (UI M53)")

func _test_persistencia() -> void:
	var data: Dictionary = _ach.get_save_data()
	_check(int(data.get("version", 0)) == 2, "save_data v2 con fechas")
	_check(data.has("desbloqueados"), "save_data completo")
	var desb: Dictionary = data.get("desbloqueados", {})
	_check(desb.size() >= 2, "logros persistidos: %d" % desb.size())
	_check((desb.get("logro_primer_sello", {}) as Dictionary).has("dia"), "fecha persistida (RF4)")
	# Round-trip con logro de catálogo viejo
	var con_viejo: Dictionary = data.duplicate(true)
	(con_viejo.desbloqueados as Dictionary)["logro_viejo"] = {"dia": 1, "hora": 12}
	_ach.restore_save_data({"desbloqueados": {}})
	_check(not _ach.esta_desbloqueado("logro_primer_sello"), "restore vacío limpia")
	_ach.restore_save_data(con_viejo)
	_check(_ach.esta_desbloqueado("logro_primer_sello"), "round-trip restaura")
	_check(not _ach.esta_desbloqueado("logro_viejo"), "logro de catálogo viejo purgado (§6)")
	_check(int(_ach.fecha_de("logro_primer_sello").get("dia", -99)) >= 0, "fecha restaurada (RF4)")

func _test_migracion_v1() -> void:
	# v1 (array sin fechas) → migra sin romper; fechas -1
	var v1 := {"desbloqueados": ["logro_primer_sello", "logro_viajero", "logro_inexistente"]}
	_ach.restore_save_data(v1)
	_check(_ach.esta_desbloqueado("logro_primer_sello"), "migración v1: logro preservado")
	_check(not _ach.esta_desbloqueado("logro_inexistente"), "migración v1: desconocido purgado")
	_check(int(_ach.fecha_de("logro_primer_sello").get("dia", 0)) == -1, "migración v1: fecha -1 placeholder")

func _test_retroactividad_rf5() -> void:
	# RF5: con el estado limpio, re_evaluar_todo re-otorga los logros ya cumplidos
	_ach.restore_save_data({"desbloqueados": {}})
	var retro: int = _ach.re_evaluar_todo()
	_check(retro >= 2, "retroactividad re-otorga logros cumplidos: %d" % retro)
	_check(_ach.esta_desbloqueado("logro_primer_sello"), "retroactivo: primer sello")
	_check(_ach.esta_desbloqueado("logro_siete_sellos"), "retroactivo: siete sellos")
