# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-25
#
# M122: Crash Reporting — Test headless de los servicios OFFLINE (P-36, Log 1150).
# Cubre los 10 helpers nuevos que cierran la deuda del módulo (los `[ ]` del checklist):
#   A. CrashMetadata        B. CrashContextSanitizer   C. CrashCache
#   D. CrashSender          E. CrashLogging            F. CrashBugTracking
#   G. CrashDebugMenu       H. CrashAlerts             I. CrashAnalytics
#   J. CrashPrioritizer
#
# Guardián de 3 capas:
#   1. cada bloque cierra con `_fin("X")` y `_summary()` NOMBRA los bloques que no cerraron;
#   2. `_summary()` va en su PROPIO `call_deferred` -> corre aunque `_run()` aborte (trampa 62);
#   3. piso `CHECKS_MINIMOS` MEDIDO en verde (no estimado) + aserciones falsables (nunca `true`).
#
# Sin red y sin disco externo: los transportes HTTP se inyectan como lambdas (stubs), y la caché
# escribe en `user://` (que funciona en headless; `DirAccess` NO, pitfall §9.6).

extends SceneTree

const _META := preload("res://scripts/crash/crash_metadata.gd")
const _SAN := preload("res://scripts/crash/crash_context_sanitizer.gd")
const _CACHE := preload("res://scripts/crash/crash_cache.gd")
const _SENDER := preload("res://scripts/crash/crash_sender.gd")
const _LOG := preload("res://scripts/crash/crash_logging.gd")
const _BUG := preload("res://scripts/crash/crash_bug_tracking.gd")
const _MENU := preload("res://scripts/crash/crash_debug_menu.gd")
const _ALERTS := preload("res://scripts/crash/crash_alerts.gd")
const _ANALYTICS := preload("res://scripts/crash/crash_analytics.gd")
const _PRIO := preload("res://scripts/crash/crash_prioritizer.gd")

const BLOQUES := ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
const CHECKS_MINIMOS := 168   # medido en verde (ver 07-Resultados-Testings.md)

# Vectores de referencia independientes del motor.
const SHA256_ABC := "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"

var _fallos: int = 0
var _checks: int = 0
var _bloque: String = ""
var _cerrados: Array = []


class LoggerStub extends RefCounted:
	var lineas: Array = []
	var categorias: Array = []
	func critical(mensaje: String, categoria: int = 0, _ctx: Dictionary = {}) -> void:
		lineas.append(mensaje)
		categorias.append(categoria)


class ReporterStub extends RefCounted:
	var llamadas: Array = []
	func reportar_crash(tipo: String, _m: String, _s: Array) -> String:
		llamadas.append(tipo)
		return "user://stub.json"
	func dumps_pendientes() -> Array:
		return ["user://crash/a.json", "user://crash/b.json"]


class ObjetoVacio extends RefCounted:
	pass


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	print("=== [M122] Test servicios offline ===")
	_bloque = "A"; _test_metadata()
	_bloque = "B"; _test_sanitizer()
	_bloque = "C"; _test_cache()
	_bloque = "D"; _test_sender()
	_bloque = "E"; _test_logging()
	_bloque = "F"; _test_bug_tracking()
	_bloque = "G"; _test_debug_menu()
	_bloque = "H"; _test_alerts()
	_bloque = "I"; _test_analytics()
	_bloque = "J"; _test_prioritizer()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _fin(nombre: String) -> void:
	_cerrados.append(nombre)

## ── A. MetadataCollector ─────────────────────────────────────
func _test_metadata() -> void:
	print("--- A. CrashMetadata ---")
	var m = _META.new()
	var hw: Dictionary = m.recolectar_hardware()
	_check("hw: os no vacío", str(hw.get("os", "")) != "")
	_check("hw: cpu no vacío", str(hw.get("cpu", "")) != "")
	_check("hw: cpu_cores > 0", int(hw.get("cpu_cores", 0)) > 0)
	_check("hw: architecture no vacía", str(hw.get("architecture", "")) != "")
	_check("hw: ram_total > 0", int(hw.get("ram_total", 0)) > 0)
	_check("hw: ram_available > 0", int(hw.get("ram_available", 0)) > 0)
	_check("hw: sin get_dynamic_memory_usage (clave inexistente)", not hw.has("ram_dynamic"))
	var sw: Dictionary = m.recolectar_software("res://escena.tscn")
	_check("sw: game_version no vacía", str(sw.get("game_version", "")) != "")
	_check("sw: godot_version contiene 4.", str(sw.get("godot_version", "")).contains("4."))
	_check("sw: execution_mode debug en headless", str(sw.get("execution_mode", "")) == "debug")
	_check("sw: escena inyectada", str(sw.get("scene", "")) == "res://escena.tscn")
	var ctx: Dictionary = m.recolectar_contexto_juego({"game_time": "Día 3", "season": "verano"})
	_check("ctx: game_time inyectado", str(ctx.get("game_time", "")) == "Día 3")
	_check("ctx: season inyectada", str(ctx.get("season", "")) == "verano")
	_check("ctx: posición default Vector3.ZERO", ctx.get("player_position", Vector3.ONE) == Vector3.ZERO)
	var todo: Dictionary = m.recolectar_todo("res://e.tscn", {"game_time": "Día 1"})
	_check("todo: fusiona hw+sw+ctx", todo.has("os") and todo.has("game_version") and todo.has("game_time"))
	_fin("A")

## ── B. ContextSanitizer ──────────────────────────────────────
func _test_sanitizer() -> void:
	print("--- B. CrashContextSanitizer ---")
	var s = _SAN.new()
	_check("CLAVES_INSEGURAS = 9", _SAN.CLAVES_INSEGURAS.size() == 9)
	_check("es_clave_insegura(email)", s.es_clave_insegura("email"))
	_check("es_clave_insegura(EMAIL) case-insensitive", s.es_clave_insegura("EMAIL"))
	_check("es_clave_insegura(user_email) subcadena", s.es_clave_insegura("user_email"))
	_check("es_clave_insegura(ip_address) subcadena", s.es_clave_insegura("ip_address"))
	_check("scene NO es insegura", not s.es_clave_insegura("scene"))
	var entrada := {
		"scene": "res://mundo.tscn",
		"game_time": "Día 2",
		"username": "maury",
		"api_key": "secreto",
		"email": "a@b.c",
	}
	var limpio: Dictionary = s.sanitizar(entrada)
	_check("conserva scene", limpio.get("scene", "") == "res://mundo.tscn")
	_check("conserva game_time", limpio.get("game_time", "") == "Día 2")
	_check("elimina username", not limpio.has("username"))
	_check("elimina api_key", not limpio.has("api_key"))
	_check("elimina email", not limpio.has("email"))
	_check("no muta la entrada", entrada.has("username") and entrada.size() == 5)
	_check("claves_removidas = 3", s.claves_removidas(entrada).size() == 3)
	_check("es_contexto_seguro(entrada) = false", not s.es_contexto_seguro(entrada))
	_check("es_contexto_seguro(limpio) = true", s.es_contexto_seguro(limpio))
	# Recursión: el diseño era superficial y dejaba pasar el email anidado.
	var anidado := {"player": {"position": "1,2,3", "email": "x@y.z"}}
	var limpio2: Dictionary = s.sanitizar(anidado)
	var jugador: Dictionary = limpio2.get("player", {})
	_check("recursivo: conserva position anidada", jugador.get("position", "") == "1,2,3")
	_check("recursivo: elimina email anidado", not jugador.has("email"))
	_check("claves_removidas con ruta padre.hijo", s.claves_removidas(anidado).has("player.email"))
	# Arrays con diccionarios dentro.
	var con_array := {"entidades": [{"id": 1}, {"token": "abc"}]}
	var limpio3: Dictionary = s.sanitizar(con_array)
	var arr: Array = limpio3.get("entidades", [])
	_check("array: 2 elementos conservados", arr.size() == 2)
	var segundo: Dictionary = arr[1] if arr.size() > 1 else {}
	_check("array: token anidado eliminado", not segundo.has("token"))
	_fin("B")

## ── C. CrashCache ────────────────────────────────────────────
func _test_cache() -> void:
	print("--- C. CrashCache ---")
	var c = _CACHE.new()
	_check("MAX_CACHE_SIZE = 10", _CACHE.MAX_CACHE_SIZE == 10)
	c.limpiar()
	_check("limpiar deja 0", c.cantidad() == 0)
	_check("guardar 1 -> true", c.guardar({"tipo": "a", "n": 1}) == true)
	_check("cantidad = 1", c.cantidad() == 1)
	c.guardar({"tipo": "b", "n": 2})
	var leido: Array = c.cargar()
	_check("cargar 2 elementos", leido.size() == 2)
	var primero: Dictionary = leido[0] if not leido.is_empty() else {}
	_check("JSON round-trip del campo tipo", str(primero.get("tipo", "")) == "a")
	# Límite FIFO: al pasar de 10 se descarta el más viejo.
	for i in range(20):
		c.guardar({"tipo": "filler", "n": i})
	_check("límite respetado (10)", c.cantidad() == 10)
	var ultimo: Dictionary = c.cargar()[9]
	_check("el último es el más reciente", int(ultimo.get("n", -1)) == 19)
	var primero2: Dictionary = c.cargar()[0]
	_check("el primero NO es el original (FIFO)", str(primero2.get("tipo", "")) != "a")
	_check("archivo existe", c.archivo_existe())
	c.limpiar()
	_check("limpiar deja 0 (2ª vez)", c.cantidad() == 0)
	_fin("C")

## ── D. CrashSender ───────────────────────────────────────────
func _test_sender() -> void:
	print("--- D. CrashSender ---")
	var s = _SENDER.new()
	_check("sin transporte -> tiene_transporte false", not s.tiene_transporte())
	_check("enviar sin transporte -> false (fail-closed)", s.enviar({"a": 1}) == false)
	s.configurar("https://ejemplo.test/api", "clave123", Callable())
	var h: PackedStringArray = s.construir_headers()
	_check("header Content-Type", h.has("Content-Type: application/json"))
	_check("header Authorization con api_key", h.has("Authorization: Bearer clave123"))
	_check("construir_cuerpo es JSON", s.construir_cuerpo({"x": 1}) == '{"x":1}')
	var s2 = _SENDER.new()
	s2.configurar("https://ejemplo.test/api", "", func(_u, _h2, _c): return true)
	_check("api_key vacía -> sin header Authorization", not s2.construir_headers().has("Authorization: Bearer "))
	_check("con transporte ok -> enviar true", s2.enviar({"a": 1}) == true)
	var s3 = _SENDER.new()
	s3.configurar("https://ejemplo.test/api", "k", func(_u, _h2, _c): return false)
	_check("transporte falla -> enviar false", s3.enviar({"a": 1}) == false)
	# enviar_cache: 1er item falla siempre, 2º acierta al 3er intento.
	var intentos := [0]
	var s4 = _SENDER.new()
	s4.configurar("https://e.test", "k", func(_u, _h2, _c):
		intentos[0] += 1
		return intentos[0] >= 5   # items 1 y 2 fallan 3 veces cada uno; el 2º item llega a 6
	)
	var r: Dictionary = s4.enviar_cache([{"id": 1}], 3)
	_check("enviar_cache: fallido tras 3 intentos", int(r.get("enviados", -1)) == 0)
	_check("enviar_cache: 1 fallido", (r.get("fallidos", []) as Array).size() == 1)
	_check("enviar_cache: intentó 3 veces", intentos[0] == 3)
	var intentos2 := [0]
	var s5 = _SENDER.new()
	s5.configurar("https://e.test", "k", func(_u, _h2, _c):
		intentos2[0] += 1
		return intentos2[0] >= 3
	)
	var r2: Dictionary = s5.enviar_cache([{"id": 1}], 3)
	_check("enviar_cache: acierta al 3er intento", int(r2.get("enviados", -1)) == 1)
	_check("enviar_cache: 0 fallidos", (r2.get("fallidos", []) as Array).is_empty())
	_check("MAX_REINTENTOS = 3", _SENDER.MAX_REINTENTOS == 3)
	_check("intentos_de ruta nueva = 0", s4.intentos_de("user://x.json") == 0)
	s4.marcar_intento("user://x.json")
	_check("marcar_intento acumula", s4.intentos_de("user://x.json") == 1)
	# Compresión GZIP (ítem "compresión de datos antes de envío").
	var cuerpo_largo := s.construir_cuerpo({"stack": ["linea_repetida"] , "padding": "x".repeat(500)})
	var comprimido: PackedByteArray = s.comprimir(cuerpo_largo)
	_check("comprimir produce bytes", comprimido.size() > 0)
	_check("comprimido < original", comprimido.size() < cuerpo_largo.to_utf8_buffer().size())
	_check("descomprimir round-trip", s.descomprimir(comprimido) == cuerpo_largo)
	_check("descomprimir bytes vacíos -> ''", s.descomprimir(PackedByteArray()).is_empty())
	_fin("D")

## ── E. CrashLogging ──────────────────────────────────────────
func _test_logging() -> void:
	print("--- E. CrashLogging ---")
	var l = _LOG.new()
	_check("NIVEL = CRITICAL", _LOG.NIVEL == "CRITICAL")
	_check("CATEGORIA_CRASH = 6 (enum M103)", _LOG.CATEGORIA_CRASH == 6)
	var datos := {
		"error": "NullInstance",
		"stack": ["a:10", "b:20"],
		"metadata": {"os": "Windows"},
		"context": {"scene": "res://m.tscn"},
	}
	var entradas: PackedStringArray = l.formatear_entradas(datos)
	_check("4 líneas CRITICAL", entradas.size() == 4)
	_check("línea 1 nombra el error", entradas[0] == "Crash detected: NullInstance")
	_check("línea 2 une el stack", entradas[1] == "Stack trace: a:10 | b:20")
	_check("línea 3 serializa metadata", entradas[2].contains("Windows"))
	_check("línea 4 serializa contexto", entradas[3].contains("res://m.tscn"))
	# Vocabulario del autoload (tipo/contexto, sin error/context).
	var entradas2: PackedStringArray = l.formatear_entradas({"tipo": "script_error", "contexto": {"x": 1}})
	_check("acepta vocabulario tipo/contexto", entradas2[0] == "Crash detected: script_error")
	# Fail-closed: sin logger no inventa registro.
	_check("registrar sin logger -> 0", l.registrar(datos, null) == 0)
	_check("registrar con objeto sin critical -> 0", l.registrar(datos, ObjetoVacio.new()) == 0)
	var stub := LoggerStub.new()
	_check("registrar con stub -> 4", l.registrar(datos, stub) == 4)
	_check("stub recibió 4 líneas", stub.lineas.size() == 4)
	_check("stub recibió categoría CRASH=6", stub.categorias.size() == 4 and int(stub.categorias[0]) == 6)
	_fin("E")

## ── F. CrashBugTracking ──────────────────────────────────────
func _test_bug_tracking() -> void:
	print("--- F. CrashBugTracking ---")
	var b = _BUG.new()
	_check("debe_crear_issue(CRITICAL) true", b.debe_crear_issue({"priority": "CRITICAL"}))
	_check("debe_crear_issue(critical) case-insensitive", b.debe_crear_issue({"priority": "critical"}))
	_check("debe_crear_issue(ALTA) false", not b.debe_crear_issue({"priority": "ALTA"}))
	_check("debe_crear_issue(prioridad ES) true", b.debe_crear_issue({"prioridad": "CRITICAL"}))
	var datos := {
		"priority": "CRITICAL",
		"error": "NullInstance",
		"stack": ["a:10"],
		"metadata": {"game_version": "0.0.6", "os": "Windows", "gpu": "Radeon", "cpu": "Ryzen", "ram_total": 17179869184},
		"context": {"scene": "res://m.tscn", "game_time": "Día 3", "season": "verano", "player_position": Vector3(1, 2, 3)},
		"frequency": 0.07,
	}
	_check("título con escena y error", b.formatear_titulo(datos) == "[CRASH] Crash en res://m.tscn - NullInstance")
	var cuerpo: String = b.formatear_cuerpo(datos)
	_check("cuerpo incluye stack", cuerpo.contains("Stack trace:\na:10"))
	_check("cuerpo incluye versión", cuerpo.contains("Versión: 0.0.6"))
	_check("cuerpo incluye OS/GPU/CPU", cuerpo.contains("OS: Windows") and cuerpo.contains("GPU: Radeon") and cuerpo.contains("CPU: Ryzen"))
	_check("cuerpo convierte RAM a GB", cuerpo.contains("RAM: 16.00 GB"))
	_check("cuerpo incluye escena/hora/estación", cuerpo.contains("Escena: res://m.tscn") and cuerpo.contains("Hora: Día 3") and cuerpo.contains("Estación: verano"))
	_check("cuerpo incluye frecuencia", cuerpo.contains("Frecuencia: 0.07"))
	_check("cuerpo marca prioridad CRÍTICA", cuerpo.contains("Prioridad: 🔴 CRÍTICA"))
	_check("sin transporte -> crear_issue false", b.crear_issue(datos, Callable()) == false)
	_check("no crítico -> crear_issue false aun con transporte", b.crear_issue({"priority": "ALTA"}, func(_u, _c): return true) == false)
	var capturado := [""]
	var ok: bool = b.crear_issue(datos, func(url, cuerpo_json):
		capturado[0] = url
		return true
	)
	_check("crítico + transporte -> crear_issue true", ok)
	_check("usa la API de GitHub", capturado[0] == _BUG.URL_API)
	_fin("F")

## ── G. CrashDebugMenu ────────────────────────────────────────
func _test_debug_menu() -> void:
	print("--- G. CrashDebugMenu ---")
	var m = _MENU.new()
	var panel: Array = m.describir_panel({"os": "Windows", "gpu": "Radeon", "cpu": "Ryzen", "ram_total": 8589934592})
	_check("panel con 4 ítems", panel.size() == 4)
	var b0: Dictionary = panel[0]
	_check("ítem 1 = botón Test Crash", str(b0.get("tipo", "")) == "boton" and str(b0.get("etiqueta", "")) == "Test Crash")
	var b1: Dictionary = panel[1]
	_check("ítem 2 = botón Send Crash Report", str(b1.get("accion", "")) == "send_crash_report")
	var l2: Dictionary = panel[2]
	_check("ítem 3 = etiqueta de metadata", str(l2.get("tipo", "")) == "etiqueta")
	var meta_txt: String = m.formatear_metadata({"os": "Windows", "gpu": "Radeon", "cpu": "Ryzen", "ram_total": 8589934592})
	_check("metadata formateada con GB", meta_txt == "OS: Windows\nGPU: Radeon\nCPU: Ryzen\nRAM: 8.00 GB")
	_check("metadata con dict vacío no rompe", m.formatear_metadata({}).contains("RAM: 0.00 GB"))
	_check("accion_test_crash(null) false", m.accion_test_crash(null) == false)
	_check("accion_test_crash(sin método) false", m.accion_test_crash(ObjetoVacio.new()) == false)
	var rep := ReporterStub.new()
	_check("accion_test_crash(stub) true", m.accion_test_crash(rep) == true)
	_check("stub recibió el tipo test_crash", rep.llamadas.has("test_crash"))
	_check("accion_enviar_pendientes(null, null) = 0", m.accion_enviar_pendientes(null, null) == 0)
	var sender_stub := _SENDER.new()
	sender_stub.configurar("https://e.test", "k", func(_u, _h2, _c): return true)
	_check("accion_enviar_pendientes envía 2", m.accion_enviar_pendientes(rep, sender_stub) == 2)
	var sender_malo := _SENDER.new()
	_check("sin transporte -> 0 enviados", m.accion_enviar_pendientes(rep, sender_malo) == 0)
	_fin("G")

## ── H. CrashAlerts ───────────────────────────────────────────
func _test_alerts() -> void:
	print("--- H. CrashAlerts ---")
	var a = _ALERTS.new()
	_check("UMBRAL_CRITICO = 0.05", _ALERTS.UMBRAL_CRITICO == 0.05)
	_check("UMBRAL_NUEVA = 0.01", _ALERTS.UMBRAL_NUEVA == 0.01)
	_check("canal #crash-alerts", _ALERTS.CANAL == "#crash-alerts")
	# 7 % -> crítico. 2 % nueva -> nueva. 0,5 % -> nada.
	var crashes := [
		{"stack": ["a:1"], "frequency": 0.07},
		{"stack": ["b:1"], "frequency": 0.02, "new_crash": true},
		{"stack": ["c:1"], "frequency": 0.005},
	]
	var msgs: PackedStringArray = a.evaluar(crashes)
	_check("2 alertas (crítico + nueva)", msgs.size() == 2)
	_check("alerta 1 dice 'Crash crítico'", msgs[0].begins_with("Crash crítico"))
	_check("alerta 1 con 7.0%", msgs[0].contains("7.0%"))
	_check("alerta 2 dice 'Crash nueva'", msgs[1].begins_with("Crash nueva"))
	_check("no alerta el de 0.5%", not "\n".join(msgs).contains("c:1"))
	# 6 % nueva -> 2 alertas; 6 % vieja -> 1 alerta.
	_check("6% + nueva -> 2 alertas", a.evaluar([{"stack": ["x"], "frequency": 0.06, "new_crash": true}]).size() == 2)
	_check("6% sin nueva -> 1 alerta", a.evaluar([{"stack": ["x"], "frequency": 0.06}]).size() == 1)
	_check("2% sin nueva -> 0 alertas", a.evaluar([{"stack": ["x"], "frequency": 0.02}]).size() == 0)
	_check("vocabulario ES (frecuencia/nueva)", a.evaluar([{"stack": ["x"], "frecuencia": 0.08, "nueva": true}]).size() == 2)
	var texto: String = a.formatear_alerta({"stack": ["a:1"], "frequency": 0.07}, "Crash crítico")
	_check("formato de alerta", texto == "Crash crítico: a:1 afecta al 7.0% de usuarios")
	var payload: Dictionary = a.construir_payload("hola")
	_check("payload con message y channel", payload.get("message", "") == "hola" and payload.get("channel", "") == "#crash-alerts")
	_check("enviar sin transporte false", a.enviar("hola", Callable()) == false)
	_check("enviar con transporte true", a.enviar("hola", func(_u, _c): return true) == true)
	_check("enviar_todas 2", a.enviar_todas(crashes, func(_u, _c): return true) == 2)
	_check("enviar_todas sin transporte 0", a.enviar_todas(crashes, Callable()) == 0)
	_check("lista vacía -> 0 alertas", a.evaluar([]).is_empty())
	_fin("H")

## ── I. CrashAnalytics ────────────────────────────────────────
func _test_analytics() -> void:
	print("--- I. CrashAnalytics ---")
	var an = _ANALYTICS.new()
	_check("huella(abc) = vector estándar", "abc".sha256_text() == SHA256_ABC)
	var h1: String = an.huella_stack(["func_a:10", "func_b:20"])
	_check("huella no vacía", h1 != "")
	_check("huella = sha256 del stack normalizado", h1 == "func_a\nfunc_b".sha256_text())
	# La misma huella si cambian direcciones de memoria y números de línea.
	var h2: String = an.huella_stack(["func_a:99", "func_b:1234"])
	_check("huella estable ante números de línea", h1 == h2)
	var h3: String = an.huella_stack(["func_a 0xDEADBEEF:10", "func_b 0x1234:20"])
	_check("huella estable ante direcciones 0x", h1 == h3)
	_check("huella distinta para otro stack", an.huella_stack(["otra:1"]) != h1)
	_check("normaliza quitando vacías", an.normalizar_stack(["  a:1  ", "", "   "]) == "a")
	_check("stack String también se acepta", an.huella_stack("func_a:10") == an.huella_stack(["func_a:10"]))
	var crashes := [
		{"stack": ["x:1", "y:2"], "frequency": 0.06},
		{"stack": ["x:5", "y:9"], "frequency": 0.06},
		{"stack": ["x:7", "y:3"], "frequency": 0.06},
		{"stack": ["z:1"], "frequency": 0.02},
	]
	var grupos: Dictionary = an.agrupar(crashes)
	_check("2 grupos", grupos.size() == 2)
	var frecs: Dictionary = an.frecuencias(crashes)
	var hx: String = an.huella_stack(["x:1", "y:2"])
	_check("grupo x: 3 elementos", int((grupos[hx] as Dictionary)["cantidad"]) == 3)
	_check("frecuencia de x = 0.75", is_equal_approx(float(frecs[hx]), 0.75))
	var top: Array = an.top(crashes, 10)
	_check("top devuelve 2", top.size() == 2)
	var t0: Dictionary = top[0]
	_check("top ordena por cantidad", str(t0["huella"]) == hx and int(t0["cantidad"]) == 3)
	_check("top(n=1) recorta", an.top(crashes, 1).size() == 1)
	_check("top(-1) no recorta", an.top(crashes, -1).size() == 2)
	var nuevas_h: Array = an.nuevas(crashes, [hx])
	_check("nuevas excluye la conocida", nuevas_h.size() == 1 and not nuevas_h.has(hx))
	_check("frecuencias con lista vacía no divide por cero", an.frecuencias([]).is_empty())
	_check("agrupar ignora no-diccionarios", an.agrupar([1, "x", {}]).size() == 1)
	_fin("I")

## ── J. CrashPrioritizer ──────────────────────────────────────
func _test_prioritizer() -> void:
	print("--- J. CrashPrioritizer ---")
	var p = _PRIO.new()
	# Matriz completa del diseño (03-Diseno.md §13).
	_check(">5% crash todos -> CRÍTICA", p.prioridad(0.10, "crash", "todos") == _PRIO.CRITICA)
	_check(">5% hang todos -> CRÍTICA", p.prioridad(0.10, "hang", "todos") == _PRIO.CRITICA)
	_check(">5% crash algunos -> ALTA", p.prioridad(0.10, "crash", "algunos") == _PRIO.ALTA)
	_check("2% crash todos -> ALTA", p.prioridad(0.02, "crash", "todos") == _PRIO.ALTA)
	_check("0.5% crash algunos -> MEDIA", p.prioridad(0.005, "crash", "algunos") == _PRIO.MEDIA)
	_check("0.5% hang algunos -> BAJA", p.prioridad(0.005, "hang", "algunos") == _PRIO.BAJA)
	# Huecos interpolados (documentados).
	_check("2% crash algunos -> MEDIA (hueco interpolado)", p.prioridad(0.02, "crash", "algunos") == _PRIO.MEDIA)
	_check("0.5% crash todos -> MEDIA (hueco interpolado)", p.prioridad(0.005, "crash", "todos") == _PRIO.MEDIA)
	_check("límite 5% exacto NO es crítico", p.prioridad(0.05, "crash", "todos") == _PRIO.ALTA)
	_check("límite 1% exacto es ALTA", p.prioridad(0.01, "crash", "todos") == _PRIO.ALTA)
	_check("case-insensitive", p.prioridad(0.10, "CRASH", "TODOS") == _PRIO.CRITICA)
	_check("prioridad_de usa frequency/severity/impact", p.prioridad_de({"frequency": 0.10, "severity": "crash", "impact": "todos"}) == _PRIO.CRITICA)
	_check("prioridad_de vocabulario ES", p.prioridad_de({"frecuencia": 0.10, "severidad": "crash", "impacto": "todos"}) == _PRIO.CRITICA)
	var crashes := [
		{"stack": ["a"], "frequency": 0.005, "severity": "hang", "impact": "algunos", "platform": "Windows", "scene": "res://a.tscn"},
		{"stack": ["b"], "frequency": 0.10, "severity": "crash", "impact": "todos", "platform": "Linux", "scene": "res://b.tscn"},
		{"stack": ["c"], "frequency": 0.02, "severity": "crash", "impact": "todos", "platform": "Windows", "scene": "res://c.tscn"},
	]
	_check("filtrar por platform Windows -> 2", p.filtrar(crashes, {"platform": "Windows"}).size() == 2)
	_check("filtrar por scene -> 1", p.filtrar(crashes, {"scene": "res://b.tscn"}).size() == 1)
	_check("filtrar por priority CRÍTICA -> 1", p.filtrar(crashes, {"priority": "CRÍTICA"}).size() == 1)
	_check("filtrar por severity hang -> 1", p.filtrar(crashes, {"severity": "hang"}).size() == 1)
	_check("filtrar sin filtros -> 3", p.filtrar(crashes, {}).size() == 3)
	_check("filtrar no muta la entrada", crashes.size() == 3)
	var ordenados: Array = p.ordenar(crashes)
	_check("ordenar: 1º es CRÍTICA", p.prioridad_de(ordenados[0]) == _PRIO.CRITICA)
	_check("ordenar: último es BAJA", p.prioridad_de(ordenados[2]) == _PRIO.BAJA)
	_check("ordenar conserva 3", ordenados.size() == 3)
	_check("ORDEN tiene 4 prioridades", _PRIO.ORDEN.size() == 4)
	_fin("J")

## Guardián de 3 capas.
func _summary() -> void:
	var faltantes: Array = []
	for b in BLOQUES:
		if not _cerrados.has(b):
			faltantes.append(b)
	print("=== Resumen M122-offline: %d checks, %d fallos ===" % [_checks, _fallos])
	if not faltantes.is_empty():
		print("[FAIL] bloques que NO se ejecutaron: %s" % str(faltantes))
	if _checks < CHECKS_MINIMOS:
		print("[FAIL] checks ejecutados (%d) por debajo del piso (%d)" % [_checks, CHECKS_MINIMOS])
	if _fallos > 0 or not faltantes.is_empty() or _checks < CHECKS_MINIMOS:
		print("TEST M122-OFFLINE FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M122-OFFLINE OK — todos los checks pasaron")
		quit(0)
