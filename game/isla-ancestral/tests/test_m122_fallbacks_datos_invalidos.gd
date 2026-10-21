extends SceneTree

# Modelo: minimax-m3-1-flash
# Plataforma: MiniMax API (Kilo Code)
# Fecha: 2026-10-21
#
# M112 (Testing Automatico) — item "[?] Testear que fallbacks de M122 responden ante datos invalidos".
# ADJUDICADO por Ling-3.1-Flash (R3, 2026-10-13) como deferral real: "0 tests de crash
# paths/fallbacks en tests/". (El test que SI existe, scripts/crash/test_crash_m122_offline.gd,
# vive FUERA de res://tests, asi que el runner central de M112 no lo ejecuta — este suite lo
# trae al circuito central y ademas cubre el caso que el item pide: DATOS INVALIDOS.)
#
# QUE MIDE (por helper de M122):
#   * CrashCache        -> una cache CORRUPTA o con JSON no-array devuelve [] (no crashea).
#   * CrashSender       -> sin transporte devuelve false; con transporte que falla devuelve
#                          {enviados: 0, fallidos: [...]}; el roundtrip comprimir/descomprimir.
#   * CrashPrioritizer  -> prioridad_de({}) cae al valor por defecto; filtrar/ordenar saltan
#                          las entradas que no son Dictionary.
#   * CrashAlerts       -> evaluar() ignora entradas invalidas; enviar() sin transporte = false.
#   * CrashMetadata     -> recolectar_contexto_juego({}) devuelve los defaults documentados.
#   * CrashContextSanitizer -> sanitizar() quita las claves inseguras incluso en datos raros.
#   * CrashLogging      -> registrar() sin logger devuelve 0 (no crashea) y formatear_entradas
#                          devuelve las 4 lineas del diseno.
#
# ANTI-FALSO-VERDE: los asserts son falsables (nunca `true`); la cache corrupta se escribe de
# verdad y se lee de vuelta; y al final se RESTAURA el estado de user://crash_cache.json.
#
# Uso:
#   "<godot_console>" --headless --path game/isla-ancestral \
#     --script res://tests/test_m122_fallbacks_datos_invalidos.gd
# Exit: 0 = verde medido | 1 = fallos

const MODULO := "M122 fallbacks ante datos invalidos"
const _META := preload("res://scripts/crash/crash_metadata.gd")
const _SAN := preload("res://scripts/crash/crash_context_sanitizer.gd")
const _CACHE := preload("res://scripts/crash/crash_cache.gd")
const _SENDER := preload("res://scripts/crash/crash_sender.gd")
const _PRIO := preload("res://scripts/crash/crash_prioritizer.gd")
const _ALERTS := preload("res://scripts/crash/crash_alerts.gd")
const _LOG := preload("res://scripts/crash/crash_logging.gd")
const CACHE_ARCHIVO := "user://crash_cache.json"
const CHECKS_MINIMOS := 30

var _checks := 0
var _fallos := 0
var _detalles: Array[String] = []
var _cache_original := ""


class LoggerStub extends RefCounted:
	var lineas: Array[String] = []

	func critical(mensaje: String, categoria: int) -> void:
		lineas.append(mensaje)


func _initialize() -> void:
	var w := Timer.new()
	w.wait_time = 120.0
	w.one_shot = true
	w.timeout.connect(func() -> void:
		print("WATCHDOG: el suite excedio 120 s -> salida forzada con codigo 1")
		quit(1))
	root.add_child(w)
	w.start()
	call_deferred("_correr")


func _check(nombre: String, ok: bool, detalle: String = "") -> void:
	_checks += 1
	if ok:
		print("  [ok]   %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])
	else:
		_fallos += 1
		_detalles.append(nombre + (" (" + detalle + ")" if detalle != "" else ""))
		print("  [FALL] %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])


func _escribir_cache(texto: String) -> void:
	var f := FileAccess.open(CACHE_ARCHIVO, FileAccess.WRITE)
	if f != null:
		f.store_string(texto)
		f.close()


func _correr() -> void:
	await process_frame
	print("=== %s ===" % MODULO)

	# Estado original de la cache (se restaura al final)
	if FileAccess.file_exists(CACHE_ARCHIVO):
		_cache_original = FileAccess.get_file_as_string(CACHE_ARCHIVO)

	# ── A. CrashCache: fallback ante cache corrupta ──
	_escribir_cache("esto no es json {{{")
	var cache := _CACHE.new()
	var cargada_corrupta := cache.cargar()
	_check("CrashCache: una cache CORRUPTA devuelve [] (fallback documentado)",
		cargada_corrupta is Array and (cargada_corrupta as Array).is_empty(),
		"tipo=%s" % type_string(typeof(cargada_corrupta)))
	_check("CrashCache: cantidad() == 0 con la cache corrupta", cache.cantidad() == 0)
	_check("CrashCache: archivo_existe() == true (el archivo corrupto sigue ahi)", cache.archivo_existe())

	_escribir_cache("{\"no\":\"es un array\"}")
	_check("CrashCache: un JSON que no es array devuelve []", (cache.cargar() as Array).is_empty())

	_escribir_cache("[]")
	_check("CrashCache: una cache vacia valida devuelve []", (cache.cargar() as Array).is_empty())

	_escribir_cache("no-es-un-json-de-todo")
	var cache2 := _CACHE.new()
	_check("CrashCache: texto no-JSON devuelve [] sin crashear", (cache2.cargar() as Array).is_empty())

	# guardar / limpiar con datos invalidos
	var guardado := cache.guardar({"error": "E", "vacio": {}})
	_check("CrashCache: guardar() con datos parciales devuelve true", guardado)
	_check("CrashCache: el crash guardado se puede leer de vuelta", cache.cantidad() == 1)
	var guardado_vacio := cache.guardar({})
	_check("CrashCache: guardar() con un diccionario VACIO no crashea", typeof(guardado_vacio) == TYPE_BOOL)
	_check("CrashCache: limpiar() devuelve true", cache.limpiar())
	_check("CrashCache: tras limpiar() la cantidad es 0", cache.cantidad() == 0)

	# ── B. CrashSender: sin transporte / con transporte que falla ──
	var sender := _SENDER.new()
	_check("CrashSender: sin transporte, enviar() devuelve false", sender.enviar({"error": "E"}) == false)
	var res_vacio = sender.enviar_cache([])
	_check("CrashSender: enviar_cache([]) devuelve {enviados: 0, fallidos: []}",
		int(res_vacio.get("enviados", -1)) == 0 and (res_vacio.get("fallidos", []) as Array).is_empty(),
		str(res_vacio))
	sender.configurar("https://ejemplo.invalid/api", "clave", func(_u, _h, _c): return false)
	_check("CrashSender: tiene_transporte() == true con el stub inyectado", sender.tiene_transporte())
	_check("CrashSender: con transporte que falla, enviar() devuelve false", sender.enviar({"error": "E"}) == false)
	var res_fallido = sender.enviar_cache([{"error": "E"}], 1)
	_check("CrashSender: con transporte que falla, nada se envia y el crash queda en fallidos",
		int(res_fallido.get("enviados", -1)) == 0 and (res_fallido.get("fallidos", []) as Array).size() == 1,
		str(res_fallido))
	sender.configurar("https://ejemplo.invalid/api", "clave", func(_u, _h, _c): return true)
	_check("CrashSender: con transporte que responde OK, enviar() devuelve true", sender.enviar({"error": "E"}) == true)
	var res_ok = sender.enviar_cache([{"error": "E"}], 1)
	_check("CrashSender: con transporte OK, el crash se cuenta como enviado",
		int(res_ok.get("enviados", -1)) == 1, str(res_ok))
	_check("CrashSender: construir_cuerpo de un dict vacio es {}",
		sender.construir_cuerpo({}) == "{}")
	_check("CrashSender: construir_cuerpo serializa las claves",
		sender.construir_cuerpo({"error": "E"}).contains("error"))
	var comprimido = sender.comprimir("hola mundo")
	_check("CrashSender: el roundtrip comprimir/descomprimir conserva el texto",
		sender.descomprimir(comprimido) == "hola mundo")
	_check("CrashSender: comprimir un texto vacio no crashea",
		sender.descomprimir(sender.comprimir("")) == "")

	# ── C. CrashPrioritizer: defaults y entradas invalidas ──
	var prio := _PRIO.new()
	_check("CrashPrioritizer: prioridad_de({}) cae al valor por defecto MEDIA",
		prio.prioridad_de({}) == "MEDIA", prio.prioridad_de({}))
	_check("CrashPrioritizer: frecuencia alta + impacto todos = CRITICA",
		prio.prioridad_de({"frequency": 0.9, "impact": "todos"}) == "CRÍTICA")
	_check("CrashPrioritizer: vocabulario en espanol (frecuencia/impacto) tambien funciona",
		prio.prioridad_de({"frecuencia": 0.03, "impacto": "todos"}) == "ALTA",
		prio.prioridad_de({"frecuencia": 0.03, "impacto": "todos"}))
	_check("CrashPrioritizer: crash de baja frecuencia = BAJA si no es crash",
		prio.prioridad_de({"severity": "hang"}) == "BAJA", prio.prioridad_de({"severity": "hang"}))
	var filtrados = prio.filtrar([1, "texto", null, {"severity": "crash"}, {"severity": "hang"}], {"severity": "crash"})
	_check("CrashPrioritizer: filtrar() ignora las entradas que no son Dictionary",
		(filtrados as Array).size() == 1, "quedaron %d" % (filtrados as Array).size())
	# OJO: `ordenar()` ordena por la prioridad DERIVADA (prioridad_de: frecuencia+severidad+impacto),
	# no por el campo "priority" del dump — por eso los datos de prueba llevan frecuencia/impacto.
	var ordenados = prio.ordenar([{"severity": "hang"}, 5, "x", {"frequency": 0.9, "impact": "todos"}])
	_check("CrashPrioritizer: ordenar() no crashea con entradas invalidas",
		(ordenados as Array).size() == 2, "quedaron %d" % (ordenados as Array).size())
	_check("CrashPrioritizer: ordenar() deja la prioridad DERIVADA mas alta primero (CRITICA antes que BAJA)",
		(ordenados as Array).size() == 2
		and prio.prioridad_de((ordenados as Array)[0]) == "CRÍTICA",
		"primera=%s" % str(prio.prioridad_de((ordenados as Array)[0])))

	# ── D. CrashAlerts: entradas invalidas y sin transporte ──
	var alerts := _ALERTS.new()
	_check("CrashAlerts: evaluar([]) no genera mensajes", (alerts.evaluar([]) as PackedStringArray).is_empty())
	_check("CrashAlerts: evaluar() ignora las entradas que no son Dictionary",
		(alerts.evaluar([42, "texto", null]) as PackedStringArray).is_empty())
	_check("CrashAlerts: un crash sin frecuencia no dispara alerta",
		(alerts.evaluar([{}]) as PackedStringArray).is_empty())
	var criticos = alerts.evaluar([{"frequency": 0.9, "error": "Boom"}])
	_check("CrashAlerts: un crash de alta frecuencia genera alerta",
		(criticos as PackedStringArray).size() >= 1, str(criticos))
	_check("CrashAlerts: el mensaje incluye el porcentaje de usuarios",
		(criticos as PackedStringArray).size() >= 1
		and (criticos as PackedStringArray)[0].contains("afecta al"))
	var payload = alerts.construir_payload("mensaje")
	_check("CrashAlerts: construir_payload devuelve {message, channel}",
		String(payload.get("message", "")) == "mensaje" and String(payload.get("channel", "")) == "#crash-alerts",
		str(payload))
	_check("CrashAlerts: enviar() sin transporte devuelve false", alerts.enviar("mensaje") == false)
	_check("CrashAlerts: enviar_todas() sin transporte devuelve 0",
		alerts.enviar_todas([{"frequency": 0.9, "error": "Boom"}]) == 0)

	# ── E. CrashMetadata: defaults con datos ausentes o de tipo raro ──
	var meta := _META.new()
	var ctx = meta.recolectar_contexto_juego({})
	_check("CrashMetadata: contexto vacio -> game_time por defecto", String(ctx.get("game_time", "x")) == "")
	_check("CrashMetadata: contexto vacio -> season por defecto", String(ctx.get("season", "x")) == "")
	_check("CrashMetadata: contexto vacio -> player_position = Vector3.ZERO",
		ctx.get("player_position", Vector3.ONE) == Vector3.ZERO)
	_check("CrashMetadata: contexto vacio -> world_seed por defecto", String(ctx.get("world_seed", "x")) == "")
	var ctx_raro = meta.recolectar_contexto_juego({"game_time": 123, "season": null})
	_check("CrashMetadata: un game_time numerico se convierte a texto sin crashear",
		String(ctx_raro.get("game_time", "")) == "123", str(ctx_raro.get("game_time", "")))
	_check("CrashMetadata: recolectar_todo() con datos invalidos devuelve un diccionario",
		meta.recolectar_todo("escena", {"game_time": 5}) is Dictionary)

	# ── F. CrashContextSanitizer: datos raros ──
	var san := _SAN.new()
	_check("CrashContextSanitizer: sanitizar({}) devuelve {}",
		(san.sanitizar({}) as Dictionary).is_empty())
	var limpio = san.sanitizar({"username": "u", "email": "e", "token": "t", "score": 5})
	_check("CrashContextSanitizer: quita las claves inseguras",
		not limpio.has("username") and not limpio.has("email") and not limpio.has("token"))
	_check("CrashContextSanitizer: conserva las claves seguras", limpio.get("score", -1) == 5)
	_check("CrashContextSanitizer: es_clave_insegura por subcadena (player_email)",
		san.es_clave_insegura("player_email"))
	_check("CrashContextSanitizer: es_clave_insegura('score') == false", not san.es_clave_insegura("score"))
	var removidas = san.claves_removidas({"a": {"api_key": 1, "ok": 2}})
	_check("CrashContextSanitizer: claves_removidas reporta la ruta anidada",
		(removidas as Array).has("a.api_key"), str(removidas))
	_check("CrashContextSanitizer: es_contexto_seguro() detecta contexto con datos sensibles",
		not san.es_contexto_seguro({"username": "u"}))
	_check("CrashContextSanitizer: es_contexto_seguro() acepta contexto limpio",
		san.es_contexto_seguro({"score": 1}))

	# ── G. CrashLogging: sin logger y con logger stub ──
	var log := _LOG.new()
	_check("CrashLogging: registrar() sin logger devuelve 0 (fallback, no crashea)",
		log.registrar({"error": "E"}) == 0)
	_check("CrashLogging: registrar() con un objeto sin metodo critical devuelve 0",
		log.registrar({"error": "E"}, RefCounted.new()) == 0)
	var lineas = log.formatear_entradas({})
	_check("CrashLogging: formatear_entradas() devuelve las 4 lineas del diseno",
		(lineas as PackedStringArray).size() == 4, str(lineas))
	_check("CrashLogging: sin datos, la linea del error dice 'desconocido'",
		(lineas as PackedStringArray).size() == 4
		and (lineas as PackedStringArray)[0].contains("desconocido"))
	var stub := LoggerStub.new()
	var n = log.registrar({"error": "E", "stack": [], "metadata": {}, "context": {}}, stub)
	_check("CrashLogging: registrar() con logger inyectado registra las 4 lineas",
		n == 4 and stub.lineas.size() == 4, "n=%d lineas=%d" % [n, stub.lineas.size()])

	# ── restaurar el estado de la cache ──
	if _cache_original.is_empty():
		if FileAccess.file_exists(CACHE_ARCHIVO):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(CACHE_ARCHIVO))
	else:
		_escribir_cache(_cache_original)

	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	for d in _detalles:
		print("  FALLO: " + d)
	if _fallos > 0 or _checks < CHECKS_MINIMOS:
		print("TEST %s FALLIDO (checks=%d, minimo=%d)" % [MODULO, _checks, CHECKS_MINIMOS])
		quit(1)
	else:
		print("TEST %s OK — los fallbacks de M122 responden ante datos invalidos" % MODULO)
		quit(0)
