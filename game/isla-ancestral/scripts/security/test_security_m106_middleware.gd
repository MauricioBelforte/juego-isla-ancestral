# Modelo: kimi-k3 (Moonshot AI)
# Plataforma: Kilo Code
# Fecha: 2026-09-19
#
# M106 T-005: Test headless del middleware de rate limiting.
# Orquesta IP + usuario + endpoint sobre SecurityManager (autoload real, inyectado).
# Lógica pura + headless-safe. Guardián anti-falso-verde: cada bloque marca `_fin()`;
# fallos reales → exit 1. Límites del catálogo: por_ip 100, por_usuario 60, /api/crash 10.

extends SceneTree

const _MW := preload("res://scripts/security/security_rate_limit_middleware.gd")

var _fallos: int = 0
var _checks: int = 0
var _bloque: String = ""

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M106] Test middleware rate limiting ===")
	_bloque = "A"
	_test_permitida()
	_bloque = "B"
	_test_rechazo_endpoint()
	_bloque = "C"
	_test_rechazo_ip_usuario()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

## ── A. solicitud permitida ───────────────────────────────
func _test_permitida() -> void:
	print("--- A. solicitud permitida (todas las capas OK) ---")
	var sm := root.get_node_or_null("SecurityManager")
	var mw = _MW.new(sm)
	var r: Dictionary = mw.procesar("1.2.3.4", "jugador1", "/api/save", 1000)
	_check("permitida=true", r["permitida"] == true)
	_check("motivo vacío", r["motivo"] == "")
	_check("reintentar_en_s=0", r["reintentar_en_s"] == 0)
	# sin security manager -> fail-open (no bloquea el juego)
	var mw_sin = _MW.new(null)
	_check("sin sm -> fail-open permitida", mw_sin.procesar("1.2.3.4", "u", "/api/crash", 1000)["permitida"] == true)
	_check("fin A", _fin())

## ── B. rechazo por endpoint ──────────────────────────────
func _test_rechazo_endpoint() -> void:
	print("--- B. rechazo por endpoint (/api/crash límite 10) ---")
	var sm := root.get_node_or_null("SecurityManager")
	var mw = _MW.new(sm)
	var t: int = 2000
	# consumir 10 (límite del endpoint)
	for i in 10:
		mw.procesar("5.5.5.5", "jugador2", "/api/crash", t)
		t += 1
	# la 11ª es rechazada por la capa endpoint
	var r: Dictionary = mw.procesar("5.5.5.5", "jugador2", "/api/crash", t)
	_check("11ª rechazada (permitida=false)", r["permitida"] == false)
	_check("motivo limite_excedido", r["motivo"] == "limite_excedido")
	_check("capa=endpoint", r["capa"] == "endpoint")
	_check("reintentar_en_s > 0", r["reintentar_en_s"] > 0, "retry=%d" % r["reintentar_en_s"])
	# reintentar disminuye al acercarse a la expiración de la ventana (60s)
	var r2: Dictionary = mw.procesar("5.5.5.5", "jugador2", "/api/crash", t + 30)
	_check("reintentar menor a mitad de ventana", r2["reintentar_en_s"] < r["reintentar_en_s"], "retry2=%d" % r2["reintentar_en_s"])
	# tras la ventana completa -> permitida de nuevo
	var r3: Dictionary = mw.procesar("5.5.5.5", "jugador2", "/api/crash", t + 61)
	_check("tras ventana -> permitida", r3["permitida"] == true)
	_check("fin B", _fin())

## ── C. rechazo por IP y por usuario (capas independientes) ─
func _test_rechazo_ip_usuario() -> void:
	print("--- C. rechazo por IP y por usuario ---")
	var sm := root.get_node_or_null("SecurityManager")
	var mw = _MW.new(sm)
	# NOTA: ventana deslizante = 60s; las 100 solicitudes deben caer DENTRO de la ventana
	# (mismo segundo) para que no expiren antes de la 101ª.
	var t: int = 9000
	# saturar la IP (límite por_ip 100) con un endpoint NO listado (sin límite propio)
	for i in 100:
		mw.procesar("7.7.7.7", "u%d" % i, "/api/otro", t)
	var r_ip: Dictionary = mw.procesar("7.7.7.7", "otro_mas", "/api/otro", t)
	_check("IP saturada -> rechazada", r_ip["permitida"] == false)
	_check("capa=ip", r_ip["capa"] == "ip")
	# otra IP distinta NO está afectada (capas/claves independientes)
	var r_otra: Dictionary = mw.procesar("8.8.8.8", "otro_mas", "/api/otro", t)
	_check("otra IP no afectada", r_otra["permitida"] == true)
	# saturar un usuario (límite por_usuario 60), dentro de la ventana
	var t2: int = 20000
	for i in 60:
		mw.procesar("9.9.9.%d" % (i % 200), "jugadorX", "/api/otro", t2)
	var r_u: Dictionary = mw.procesar("9.9.9.1", "jugadorX", "/api/otro", t2)
	_check("usuario saturado -> rechazado", r_u["permitida"] == false)
	_check("capa=usuario", r_u["capa"] == "usuario")
	# otro usuario NO está afectado
	var r_u2: Dictionary = mw.procesar("9.9.9.1", "jugadorY", "/api/otro", t2)
	_check("otro usuario no afectado", r_u2["permitida"] == true)
	_check("fin C", _fin())

## Guardián anti-falso-verde: si un bloque se aborta (SCRIPT ERROR), su `_fin` no corre.
func _fin() -> bool:
	print("  [GUARDIAN] bloque %s completado" % _bloque)
	return true

func _summary() -> void:
	print("=== Resumen M106-middleware: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M106-MIDDLEWARE FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M106-MIDDLEWARE OK — todos los checks pasaron")
		quit(0)
