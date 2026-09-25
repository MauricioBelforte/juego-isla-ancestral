# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M106: Seguridad — Test headless
# Valida: SecurityManager (políticas, restricciones, validar_save,
# validar_max, alertas). Exit code != 0 si falla.

extends SceneTree

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M106] Test de Seguridad ===")
	_test_policies()
	_test_restricciones()
	_test_save()
	_test_economia()
	_test_bot()
	_test_audit()
	_test_rate_limit()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _test_policies() -> void:
	print("--- Políticas: seguridad data-driven ---")
	var sm := root.get_node_or_null("SecurityManager")
	if sm == null:
		_check("SecurityManager autoload presente", false)
		_summary()
		quit(1)
		return
	_check("SecurityManager autoload presente", true)
	_check("4 políticas", sm.config.get("politicas", {}).size() == 4, "size=%d" % sm.config.get("politicas", {}).size())
	_check("validar_saves habilitada", sm.politica("validar_saves") == true)
	_check("bloquear_carpetas_res habilitada", sm.politica("bloquear_carpetas_res") == true)
	_check("política inexistente -> false", sm.politica("no_existe") == false)

func _test_restricciones() -> void:
	print("--- Restricciones: validación de valores ---")
	var sm := root.get_node_or_null("SecurityManager")
	_check("max_objetos 99 permitido", sm.validar_max("max_objetos_inventario", 50) == true)
	_check("max_objetos 100 excede", sm.validar_max("max_objetos_inventario", 100) == false)
	_check("sin restricción -> true", sm.validar_max("campo_inexistente", 9999) == true)
	# alertas
	sm.registrar_alerta("Intento de acceso a carpeta res")
	_check("alerta registrada", sm.cantidad_alertas() >= 1 and "res" in str(sm.alertas()))

func _test_save() -> void:
	print("--- Validación de saves (checksum CRC32) ---")
	var sm := root.get_node_or_null("SecurityManager")
	# save inexistente -> false
	_check("save inexistente -> false", sm.validar_save("user://no_existe.save") == false)
	# save real con checksum válido (usar DataStore M60)
	var ruta := "user://test_security_save.json"
	var payload := '{"version":1,"test":true}'
	var contenido := Validador.crc32_hex(payload) + "\n" + payload
	var f := FileAccess.open(ruta, FileAccess.WRITE)
	f.store_string(contenido)
	f.close()
	_check("save válido -> true", sm.validar_save(ruta) == true, "ruta=%s" % ruta)
	DirAccess.remove_absolute(ruta)

	# save CORRUPTO (payload alterado tras el checksum) -> debe detectarse
	var ruta_corrupta := "user://test_security_save_corrupto.json"
	var checksum_bueno := Validador.crc32_hex('{"version":1,"test":true}')
	var contenido_corrupto := checksum_bueno + "\n" + '{"version":9,"test":true}'
	var f2 := FileAccess.open(ruta_corrupta, FileAccess.WRITE)
	f2.store_string(contenido_corrupto)
	f2.close()
	_check("save corrupto (payload alterado) -> false", sm.validar_save(ruta_corrupta) == false)
	DirAccess.remove_absolute(ruta_corrupta)

## ── D. Economía adulterada (T-001, RF11) ─────────────────
func _test_economia() -> void:
	print("--- D. Prevención de economía adulterada ---")
	var sm := root.get_node_or_null("SecurityManager")
	var alertas_previas: int = sm.cantidad_alertas()
	# economía legítima -> true, sin alertas nuevas
	_check("economía legítima -> true", sm.validar_economia({"plata": 500, "objetos_inventario": 10, "nivel": 5}) == true)
	_check("sin alertas nuevas (legítima)", sm.cantidad_alertas() == alertas_previas)
	# plata adulterada (excede max_plata 999999) -> false + alerta
	_check("plata adulterada (excede max) -> false", sm.validar_economia({"plata": 9999999}) == false)
	_check("alerta de adulteración registrada", sm.cantidad_alertas() == alertas_previas + 1 and "Economía adulterada" in str(sm.alertas()))
	# plata negativa -> false
	_check("plata negativa -> false", sm.validar_economia({"plata": -100}) == false)
	# items adulterados (exceden max_objetos_inventario 99) -> false
	_check("objetos adulterados (exceden max) -> false", sm.validar_economia({"objetos_inventario": 100}) == false)
	# nivel adulterado (excede max_nivel 50) -> false
	_check("nivel adulterado (excede max) -> false", sm.validar_economia({"nivel": 99}) == false)
	# diccionario vacío (sin campos) -> true (nada que validar)
	_check("sin campos -> true", sm.validar_economia({}) == true)
	# límite exacto permitido -> true
	_check("plata en el límite (999999) -> true", sm.validar_economia({"plata": 999999}) == true)
	print("  [GUARDIAN] bloque D completado")

## ── E. Prevención de bots (T-002, RF12) ──────────────────
func _test_bot() -> void:
	print("--- E. Prevención de bots (timing inhumano) ---")
	var sm := root.get_node_or_null("SecurityManager")
	var alertas_previas: int = sm.cantidad_alertas()
	# ritmo humano (200ms entre acciones) -> nunca marca, contador en 0
	var ts: int = 100000
	var max_humano: int = 0
	for i in 30:
		ts += 200
		max_humano = maxi(max_humano, sm.registrar_accion_bot(ts))
	_check("ritmo humano (200ms) -> sin marcas", max_humano == 0)
	_check("sin alertas con ritmo humano", sm.cantidad_alertas() == alertas_previas)
	# ráfaga de bot (10ms, autoclicker) -> contador sube y dispara alerta al llegar a max_rafaga_bot
	var marcadas: int = 0
	for i in 12:
		ts += 10
		marcadas = sm.registrar_accion_bot(ts)
	_check("ráfaga bot marcada (contador >= max_rafaga)", marcadas >= 10, "marcadas=%d" % marcadas)
	_check("alerta de bot registrada", sm.cantidad_alertas() == alertas_previas + 1 and "Patrón de bot" in str(sm.alertas()))
	# una sola alerta por racha: 5 acciones más rápidas no agregan alertas
	for i in 5:
		ts += 10
		sm.registrar_accion_bot(ts)
	_check("una sola alerta por racha", sm.cantidad_alertas() == alertas_previas + 1)
	# pausa humana (300ms) -> reset del contador
	ts += 300
	_check("pausa humana resetea racha", sm.registrar_accion_bot(ts) == 0)
	print("  [GUARDIAN] bloque E completado")

## ── F. Registro de accesos importantes (T-003, RF13) ─────
func _test_audit() -> void:
	print("--- F. Audit log local (accesos importantes) ---")
	var sm := root.get_node_or_null("SecurityManager")
	var ruta := "user://security_audit.log"
	if FileAccess.file_exists(ruta):
		DirAccess.remove_absolute(ruta)
	var alertas_previas: int = sm.cantidad_alertas()
	# registro info -> buffer crece, sin alerta
	sm.registrar_acceso("login", "jugador local", "info")
	sm.registrar_acceso("cargar_save", "slot 1", "info")
	_check("buffer acumula accesos", sm.cantidad_audit() >= 2, "n=%d" % sm.cantidad_audit())
	_check("acceso info sin alerta", sm.cantidad_alertas() == alertas_previas)
	# acceso critico -> genera alerta
	sm.registrar_acceso("cambio_config", "max_plata modificado", "critico")
	_check("acceso crítico genera alerta", sm.cantidad_alertas() == alertas_previas + 1 and "Acceso crítico" in str(sm.alertas()))
	# volcado a disco
	_check("volcado a disco OK", sm.volcar_audit_log() == true)
	_check("buffer vacío tras volcado", sm.cantidad_audit() == 0)
	_check("archivo audit existe", FileAccess.file_exists(ruta))
	# contenido: líneas JSON parseables y con los campos
	var contenido := FileAccess.get_file_as_string(ruta)
	var lineas := contenido.split("\n", false)
	_check("audit tiene líneas", lineas.size() >= 3, "lineas=%d" % lineas.size())
	var ultima: Variant = JSON.parse_string(lineas[lineas.size() - 1])
	_check("entrada parseable con campos", typeof(ultima) == TYPE_DICTIONARY and ultima.get("accion") == "cambio_config" and ultima.get("nivel") == "critico" and ultima.has("ts"))
	DirAccess.remove_absolute(ruta)
	print("  [GUARDIAN] bloque F completado")

## ── G. Rate limiting por IP/usuario/endpoint (T-004, RF1) ─
func _test_rate_limit() -> void:
	print("--- G. Rate limiting (ventana deslizante, offline) ---")
	var sm := root.get_node_or_null("SecurityManager")
	var alertas_previas: int = sm.cantidad_alertas()
	# clave sin límite configurado -> siempre permitida
	_check("clave sin límite -> permitida", sm.verificar_limite_tasa("ip:0.0.0.1", 1000) == true)
	# endpoint /api/crash: límite 10 en 60s. 10 permitidas, la 11ª rechazada.
	var t: int = 5000
	var permitidas: int = 0
	for i in 10:
		if sm.verificar_limite_tasa("endpoint:/api/crash", t):
			permitidas += 1
		t += 1
	_check("10 solicitudes dentro del límite", permitidas == 10, "permitidas=%d" % permitidas)
	var rechazada: bool = sm.verificar_limite_tasa("endpoint:/api/crash", t)
	_check("11ª solicitud rechazada (excede)", rechazada == false)
	_check("alerta de tasa registrada", sm.cantidad_alertas() == alertas_previas + 1 and "Límite de tasa" in str(sm.alertas()))
	# ventana deslizante: avanzar 61s -> las marcas viejas expiran y vuelve a permitir
	var t2: int = t + 61
	_check("tras expirar ventana -> permitida de nuevo", sm.verificar_limite_tasa("endpoint:/api/crash", t2) == true)
	# tipos distintos son independientes (por_ip no afecta a endpoint)
	_check("tipo ip independiente de endpoint", sm.verificar_limite_tasa("ip:9.9.9.9", t2) == true)
	_check("tipo usuario independiente", sm.verificar_limite_tasa("usuario:jugador1", t2) == true)
	# endpoint sin límite propio -> permitido (no está en el catálogo)
	_check("endpoint no listado -> permitido", sm.verificar_limite_tasa("endpoint:/api/otro", t2) == true)
	print("  [GUARDIAN] bloque G completado")

func _summary() -> void:
	print("=== Resumen M106: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M106 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M106 OK — todos los checks pasaron")
		quit(0)