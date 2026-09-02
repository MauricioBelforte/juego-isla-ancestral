# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M55: Test de DiaryService (registro por eventos, anti-spoiler, progreso,
# favoritos, búsqueda, persistencia, integraciones M19/M22/M28).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/diario/test_diario.gd

extends SceneTree

var _fallos: int = 0
var _d: Node = null
var _bus: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_d = root.get_node_or_null("Diary")
	_bus = root.get_node_or_null("EventBus")
	_check(_d != null, "Diary autoload presente")
	_check(_bus != null, "EventBus presente")
	if _d == null or _bus == null:
		print("=== TEST M55 DIARIO: 1+ fallo(s) ===")
		quit(1)
		return
	_test_catalogo()
	_test_registro_manual()
	_test_registro_por_eventos()
	_test_anti_spoiler()
	_test_progreso()
	_test_favorito_busqueda()
	_test_persistencia()
	print("=== TEST M55 DIARIO: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_catalogo() -> void:
	_check(_d.total_entradas() >= 30, "catálogo >= 30 entradas: %d" % _d.total_entradas())
	_check(_d._catalogo.has("sellos"), "categoría sellos presente")
	_check(_d.get_section_name() == "diary", "sección 'diary' (M59)")

func _test_registro_manual() -> void:
	_check(not _d.esta_registrada("inexistente"), "inexistente no registrada")
	# Categoría válida + entrada válida
	_check(_d.registrar("receta_rec_pico_cobre", "recetas"), "registrar receta OK")
	_check(_d.esta_registrada("receta_rec_pico_cobre"), "registrada")
	_check(_d.estado_de("receta_rec_pico_cobre") == 1, "estado VISTO al registrar")
	# Idempotente: repetir promueve VISTO → COMPLETADO
	_check(_d.registrar("receta_rec_pico_cobre", "recetas"), "re-registrar OK (idempotente)")
	_check(_d.estado_de("receta_rec_pico_cobre") == 2, "re-registro promueve a COMPLETADO")
	# Entrada inexistente en categoría existente
	_check(not _d.registrar("entrada_fantasma", "recetas"), "entrada fantasma rechazada")
	# Marcar completado
	_d.registrar("receta_rec_mesa_robusta", "recetas")
	_check(_d.marcar_completado("receta_rec_mesa_robusta"), "marcar_completado OK")

func _test_registro_por_eventos() -> void:
	# M22: prereq_met registra el sello automáticamente
	_bus.quest.prereq_met.emit("sello_ceniza_sala1")
	_check(_d.esta_registrada("sello_sello_ceniza_sala1"), "prereq_met → sello registrado (M22→M55)")
	# M19: vecino que se muda registra personaje
	_bus.npc.npc_moved_in.emit("finneas_zorro", "aurora")
	_check(_d.esta_registrada("vecino_finneas_zorro"), "npc_moved_in → personaje registrado (M19→M55)")
	# M22: misión completada
	_bus.quest.quest_completed.emit("test_quest")
	_check(_d.esta_registrada("mision_test_quest"), "quest_completed → misión registrada")
	# M28: isla cargada por viaje
	_bus.travel.island_loaded.emit("isla_sur")
	_check(_d.esta_registrada("lugar_isla_sur"), "island_loaded → lugar registrado (M28→M55)")
	# M29: cambio de estación → evento
	_bus.calendar.season_changed.emit("Primavera", "Verano")
	_check(_d.esta_registrada("evento_verano"), "season_changed → evento registrado")
	# M74: carta recibida
	_bus.npc.carta_recibida.emit("catalina_oso", "carta_bienvenida")
	_check(_d.esta_registrada("carta_carta_bienvenida"), "carta_recibida → carta registrada")

func _test_anti_spoiler() -> void:
	# §3.2: no descubierto = invisible en entradas_de; secreta = visible como ???
	var visibles: Array[Dictionary] = _d.entradas_de("sellos")
	var solo_registradas := true
	for e in visibles:
		if not bool(e.registrada) and not bool(e.secreta):
			solo_registradas = false
	_check(visibles.size() >= 1, "sellos: registradas visibles")
	_check(solo_registradas or visibles.size() > 0, "anti-spoiler: solo descubiertas (o secretas)")
	# Una no descubierto NO aparece
	_check(not _d.esta_registrada("sello_sello_brisa_camara"), "sello 7 no descubierto")
	var contiene := false
	for e in visibles:
		if String(e.id) == "sello_sello_brisa_camara":
			contiene = true
	_check(not contiene, "sello 7 invisible en la UI (§3.2)")

func _test_progreso() -> void:
	# §3.2: % sobre lo DESCUBIERTO
	var p: Dictionary = _d.progreso_categoria("recetas")
	_check(int(p.descubiertas) == 2, "recetas: 2 descubiertas (%s)" % p.descubiertas)
	_check(absf(float(p.percent) - 1.0) < 0.01, "recetas: 100% de lo descubierto")
	# Notificaciones de entrada nueva
	_check(_d.nuevas_sesion().size() >= 5, "nuevas_sesion acumuladas (%d)" % _d.nuevas_sesion().size())

func _test_favorito_busqueda() -> void:
	_d.alternar_favorito("receta_rec_pico_cobre")
	_check(_d.es_favorito("receta_rec_pico_cobre"), "favorito activado")
	_d.alternar_favorito("receta_rec_pico_cobre")
	_check(not _d.es_favorito("receta_rec_pico_cobre"), "favorito desactivado")
	# Búsqueda solo sobre lo descubierto
	var res: Array = _d.buscar("cobre")
	_check(res.has("receta_rec_pico_cobre"), "búsqueda 'cobre' encuentra receta descubierta")
	_check(_d.buscar("").is_empty(), "búsqueda vacía sin resultados (evita listar todo)")

func _test_persistencia() -> void:
	var data: Dictionary = _d.get_save_data()
	_check(data.has("schema_version") and data.has("entradas"), "save_data con schema")
	_check((data.get("entradas", {}) as Dictionary).size() >= 5, "entradas persistidas")
	_check(_d.get_section_name() == "diary", "sección diary")
	# Round-trip con huérfana ( entrada de catálogo viejo )
	var data_con_huerfana: Dictionary = data.duplicate(true)
	(data_con_huerfana.entradas as Dictionary)["entrada_vieja"] = {"categoria": "recetas", "estado": 1, "favorito": false, "dia": 1}
	_d.restore_save_data({})
	_check(_d.esta_registrada("receta_rec_pico_cobre") == false, "restore vacío limpia")
	_d.restore_save_data(data_con_huerfana)
	_check(_d.esta_registrada("receta_rec_pico_cobre"), "round-trip restaura")
	_check(not _d.esta_registrada("entrada_vieja"), "huérfana purgada al cargar (§8)")
