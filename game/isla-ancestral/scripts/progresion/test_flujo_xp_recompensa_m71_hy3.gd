# Modelo: Hy3 (WorkBuddy / Tencent Hunyuan)
# Plataforma: WorkBuddy
# Fecha: 2026-10-21
#
# Bloque C #55 (BACKLOG-MASTER Hy3): Runtime test de M71 (Progresion) -
# flujo XP/recompensa: acumulacion de estadisticas (XP) -> reevaluacion
# de hitos -> entrega de recompensas (info/unlock/titulo) -> persistencia.
# Verificacion runtime headless INDEPENDIENTE del test_progresion.gd (agnes).
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral \
#     --script res://scripts/progresion/test_flujo_xp_recompensa_m71_hy3.gd
# Exit != 0 si falla.
#
# Guarda anti-falso-verde (3 capas): _fin() por bloque + CHECKS_MINIMOS MEDIDO
# + _summary() diferido SEPARADO. Si _run aborta por SCRIPT ERROR, _summary
# igual corre (deferred FIFO) y detecta bloques faltantes -> EXIT 1 (no cuelga).

extends SceneTree

# Piso MEDIDO en verde (ver Log). Ajustar al medir.
const CHECKS_MINIMOS := 37
const _WB_BLOQUES: Array[String] = [
	"_test_catalogo",
	"_test_flujo_evento_items",
	"_test_flujo_evento_misiones",
	"_test_marcar_hito_senal",
	"_test_recompensa_unlock",
	"_test_recompensa_titulo",
	"_test_idempotencia",
	"_test_evaluar_pura",
	"_test_economia_xp",
	"_test_persistencia",
]
var _checks: int = 0
var _fallos: int = 0
var _wb_vistos: Dictionary = {}
var _wb_cerrado: bool = false

var _pm: Node = null
var _pp: Node = null
var _bus: Node = null

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _fin(nombre: String) -> void:
	_wb_vistos[nombre] = true

func _run() -> void:
	print("=== [HY3] Flujo XP/recompensa M71 (Bloque C #55) ===")
	_pm = root.get_node_or_null("ProgressionManager")
	_pp = root.get_node_or_null("PlayerProfile")
	_bus = root.get_node_or_null("EventBus")
	_check(_pm != null, "ProgressionManager autoload presente")
	_check(_pp != null, "PlayerProfile autoload presente")
	_check(_bus != null, "EventBus autoload presente")
	if _pm == null or _pp == null or _bus == null:
		return  # _summary (diferido) reporta el fallo
	# Aislamiento (trampa M23): limpiar progresion persistida en user:// para que
	# los flujos de recompensa sean deterministicos y no hereden hitos marcados
	# por un save previo ni por otro bloque.
	_pm.restore_save_data({})
	_check(not _pm.hito_alcanzado("hito_items_50"), "aislamiento: hito_items_50 limpio tras restore")
	_check(not _pm.hito_alcanzado("hito_coleccion_flora"), "aislamiento: hito_coleccion_flora limpio tras restore")
	_check(int(_pm.titulo_count()) == 0, "aislamiento: sin titulos tras restore")
	print("[DBG2] count=%d marcar_coleccion_flora=%s marcar_inexistente=%s" % [_pm.hitos_count(), _pm.marcar_hito("hito_coleccion_flora"), _pm.marcar_hito("zzz_noexiste")])
	_test_catalogo()
	_fin("_test_catalogo")
	_test_flujo_evento_items()
	_fin("_test_flujo_evento_items")
	_test_flujo_evento_misiones()
	_fin("_test_flujo_evento_misiones")
	_test_marcar_hito_senal()
	_fin("_test_marcar_hito_senal")
	_test_recompensa_unlock()
	_fin("_test_recompensa_unlock")
	_test_recompensa_titulo()
	_fin("_test_recompensa_titulo")
	_test_idempotencia()
	_fin("_test_idempotencia")
	_test_evaluar_pura()
	_fin("_test_evaluar_pura")
	_test_economia_xp()
	_fin("_test_economia_xp")
	_test_persistencia()
	_fin("_test_persistencia")

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % msg)
	else:
		_fallos += 1
		print("  [FAIL] %s" % msg)

func _test_catalogo() -> void:
	_check(_pm.hitos_count() >= 25, ">=25 hitos cargados (catalogo): %d" % _pm.hitos_count())
	_check(_pm.get_section_name() == "progresion", "seccion save 'progresion' (M59)")

func _test_flujo_evento_items() -> void:
	# XP (items_recolectados) acumulado por evento -> hito_items_10 se alcanza -> recompensa.
	var alcanzados: Array = []
	var cb := func(id: String, _n: String, _r: Array) -> void:
		alcanzados.append(id)
	_pm.progreso_hito_alcanzado.connect(cb)
	for i in range(10):
		_bus.inventory.item_added.emit("baya_roja", 1)
	_check(alcanzados.has("hito_items_10"), "hito_items_10 alcanzado por evento (reeval. dirty)")
	_check(_pm.hito_alcanzado("hito_items_10"), "hito_items_10 marcado")
	var pp: Dictionary = _pm.progreso_parcial("hito_items_10")
	_check(float(pp.logrado) >= 10.0, "progreso parcial >= 10 (UI lazy-eval): %s" % pp.logrado)
	_pm.progreso_hito_alcanzado.disconnect(cb)

func _test_flujo_evento_misiones() -> void:
	var alcanzados: Array = []
	var cb := func(id: String, _n: String, _r: Array) -> void:
		alcanzados.append(id)
	_pm.progreso_hito_alcanzado.connect(cb)
	_bus.quest.quest_completed.emit("mision_de_prueba")
	_check(alcanzados.has("hito_misiones_1"), "hito_misiones_1 alcanzado por quest_completed")
	_check(float(_pp.get_stat("misiones_completadas")) >= 1.0, "stat misiones_completadas >= 1")
	_pm.progreso_hito_alcanzado.disconnect(cb)

func _test_marcar_hito_senal() -> void:
	# Marcar hito con recompensa info -> la senal entrega las recompensas.
	print("[DBG] antes marcar hito_items_50: alcanzado=%s items=%s" % [_pm.hito_alcanzado("hito_items_50"), _pp.get_stat("items_recolectados")])
	var senal: Dictionary = {}
	var cb := func(id: String, _n: String, recs: Array) -> void:
		senal = {"id": id, "recs": recs}
	_pm.progreso_hito_alcanzado.connect(cb)
	var ok: bool = _pm.marcar_hito("hito_items_50")
	_pm.progreso_hito_alcanzado.disconnect(cb)
	_check(ok, "marcar_hito('hito_items_50') retorna true")
	_check(senal.get("id", "") == "hito_items_50", "senal entrega id del hito")
	var recs: Array = senal.get("recs", [])
	_check(recs.size() >= 1, "senal entrega recompensas (info): %d" % recs.size())
	var hay_info: bool = false
	for r in recs:
		if String(r.get("tipo", "")) == "info":
			hay_info = true
	_check(hay_info, "recompensa tipo 'info' presente en la entrega")

func _test_recompensa_unlock() -> void:
	# hito_coleccion_flora tiene recompensa tipo 'unlock' -> se entrega via senal.
	print("[DBG] antes marcar hito_coleccion_flora: alcanzado=%s desb('')=%s" % [_pm.hito_alcanzado("hito_coleccion_flora"), _pm.desbloqueo_activo("")])
	var desb: Dictionary = {}
	var cb := func(id: String, tipo: String, valor: String) -> void:
		desb = {"id": id, "tipo": tipo, "valor": valor}
	_pm.progreso_desbloqueado.connect(cb)
	_pm.marcar_hito("hito_coleccion_flora")
	_pm.progreso_desbloqueado.disconnect(cb)
	_check(desb.get("valor", "") == "placa de herbario dorada",
		"recompensa unlock entregada (valor): '%s'" % desb.get("valor", ""))
	_check(String(desb.get("tipo", "")) == "info",
		"tipo_unlock entregado: '%s'" % desb.get("tipo", ""))
	# idempotencia del activar_desbloqueo (API publica) con id conocido
	_pm.activar_desbloqueo("unlock_test_hy3", "info", "x")
	_pm.activar_desbloqueo("unlock_test_hy3", "info", "x")
	_check(_pm.desbloqueo_activo("unlock_test_hy3"), "desbloqueo manual activo (idempotente)")

func _test_recompensa_titulo() -> void:
	# RF12: hito_amistades_5 otorga titulo social 'Amigo del Pueblo'.
	var senales: Array = [0]
	var cb := func(_t_id: String, _nombre: String) -> void:
		senales[0] += 1
	_pm.progreso_titulo_obtenido.connect(cb)
	_pm.marcar_hito("hito_amistades_5")
	_pm.progreso_titulo_obtenido.disconnect(cb)
	_check(_pm.tiene_titulo("Amigo del Pueblo"), "titulo 'Amigo del Pueblo' otorgado por hito")
	_check(int(senales[0]) == 1, "senal progreso_titulo_obtenido emitida 1 vez")
	# idempotente: re-marcar no re-otorga
	_pm.marcar_hito("hito_amistades_5")
	_check(int(_pm.titulo_count()) == 1, "titulo idempotente (sin duplicado)")

func _test_idempotencia() -> void:
	# marcar dos veces un hito no-auto-disparado -> 1 sola senal, 1 entrada.
	var senales: Array = [0]
	var cb := func(_id: String, _n: String, _r: Array) -> void:
		senales[0] += 1
	_pm.progreso_hito_alcanzado.connect(cb)
	var primera: bool = _pm.marcar_hito("hito_viajero_3")
	var segunda: bool = _pm.marcar_hito("hito_viajero_3")
	_pm.progreso_hito_alcanzado.disconnect(cb)
	_check(primera and not segunda, "idempotente: 1a true, 2a false")
	_check(senales[0] == 1, "una sola senal de hito (§3.1)")

func _test_evaluar_pura() -> void:
	var estado_mock := {
		"profile": _pp, "game_time": null, "historia": null,
		"collection_registry": null, "tool_controller": null,
		"casa_manager": null, "alcanzados": _pm.hitos_alcanzados(),
	}
	var cond_si := {"tipo": "stat_min", "stat_id": "items_recolectados", "umbral": 10}
	_check(_pm.evaluar_pura(cond_si, estado_mock) == true,
		"evaluar_pura stat_min items>=10 = true (tras evento)")
	var cond_no := {"tipo": "stat_min", "stat_id": "items_recolectados", "umbral": 99999}
	_check(_pm.evaluar_pura(cond_no, estado_mock) == false,
		"evaluar_pura stat_min umbral alto = false")
	var cond_not := {"tipo": "compuesta", "operador": "NOT",
		"hijos": [{"tipo": "stat_min", "stat_id": "misiones_completadas", "umbral": 99999}]}
	_check(_pm.evaluar_pura(cond_not, estado_mock) == true,
		"evaluar_pura NOT misiones 99999 = true")

func _test_economia_xp() -> void:
	# XP de contribucion: monedas_ganadas alimenta reputacion.
	_pp.incrementar("monedas_ganadas", 500)
	_check(absf(_pp.contribucion_actual() - 500.0) < 0.01,
		"contribucion_actual = 500 tras +500 monedas")
	var rep: float = _pp.reputacion(-1.0)
	_check(absf(rep - 25.0) < 1.0, "reputacion solo-contrib 500/2000 = 25 (porcentaje): %.0f" % rep)

func _test_persistencia() -> void:
	var data: Dictionary = _pm.get_save_data()
	_check(data.has("version") and int(data.version) >= 1, "save_data versionado (§6): v%d" % data.version)
	_check((data.get("hitos_alcanzados", []) as Array).size() >= 3, "hitos persistidos (>=3)")
	var tit_antes: int = _pm.titulo_count()
	_pm.restore_save_data({})
	_check(_pm.hitos_alcanzados().is_empty(), "restore vacio limpia hitos")
	_check(int(_pm.titulo_count()) == 0, "restore vacio limpia titulos")
	_pm.restore_save_data(data)
	_check(_pm.hito_alcanzado("hito_items_10"), "round-trip restaura hito_items_10")
	_check(_pm.hito_alcanzado("hito_amistades_5"), "round-trip restaura hito_amistades_5")
	if tit_antes > 0:
		_check(_pm.tiene_titulo("Amigo del Pueblo"), "round-trip restaura titulo")
	else:
		_check(true, "sin titulos que restaurar (tit_antes=0)")

func _summary() -> void:
	if _wb_cerrado:
		return
	_wb_cerrado = true
	for b in _WB_BLOQUES:
		if not _wb_vistos.has(b):
			_fallos += 1
			print("[FAIL] bloque %s NO ejecutado (posible SCRIPT ERROR)" % b)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen HY3 M71 #55: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("FALLO (fallos=%d, checks=%d)" % [_fallos, _checks])
		quit(1)
	else:
		print("TODOS LOS CHECKS PASARON")
		quit(0)
