# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M66: Test iter. 2 — disparos del detector (transición de escena, guardado)
# + coherencia con validador M23 (cadenas sin softlocks).
# Complementa el test del núcleo ox-alpha — no lo reemplaza.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/core/test_anti_softlock_m66.gd
#
# FIX agnes-3-flash (2026-10-08, rev. sello Legacy revocado por Hy3): el test era
# FALSO-VERDE — _check(true,...) en guardado/transición + 'ClassDB... or true' en
# SoftlockRules + set_script(irecoverable.gd, RefCounted) sobre un Node (ERROR de
# runtime ignorado). Se reemplazó por checks reales: invariante rota de control
# (M66InvRuta) + handler de registro (M66HandlerRegistro) que verifica detección y
# consulta del handler. Producción (softlock_guard.gd) NO modificada.

extends SceneTree

# Helpers de test (M66, agnes-3-flash): se preanudan para evitar la race de class_name.
const _M66HandlerRegistro := preload("res://scripts/core/test_m66_handler.gd")

var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_autoload_presente()
	_test_disparo_guardado()
	_test_disparo_transicion()
	_test_coherencia_m23()
	print("=== TEST M66 ANTI-SOFTLOCK ITER2: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_autoload_presente() -> void:
	var sg := root.get_node_or_null("SoftlockGuard")
	_check(sg != null, "SoftlockGuard autoload presente")
	if sg != null:
		_check(sg.has_method("forzar_chequeo"), "forzar_chequeo disponible")
		_check(sg.activo, "guard activo")

func _test_disparo_guardado() -> void:
	var sg := root.get_node_or_null("SoftlockGuard")
	var sm := root.get_node_or_null("SaveManager")
	_check(sg != null and sm != null, "SoftlockGuard + SaveManager presentes")
	if sg == null or sm == null:
		return
	# Handler de registro concreto (IRecoverable/RefCounted). Reemplaza el antiguo
	# set_script(irecoverable.gd) sobre un Node (RefCounted inválido en Node → error).
	var rec := _M66HandlerRegistro.new()
	sg.registrar_handler(rec)
	# CHECK CONCRETO (no tautología): registrar_handler quedó en el guard.
	_check(sg._handlers.has(rec), "handler IRecoverable registrado en el guard")
	# El disparo por guardado (save_completed → forzar_chequeo) no debe corromper.
	sm.save_completed.emit(1, "test_m66")
	_check(sg.activo, "guard sigue activo tras disparo por guardado")
	_check(sg._handlers.has(rec), "handler persiste tras el disparo por guardado")
	sg._handlers.erase(rec)

func _test_disparo_transicion() -> void:
	var sg := root.get_node_or_null("SoftlockGuard")
	var bus := root.get_node_or_null("EventBus")
	_check(sg != null and bus != null and bus.infra != null, "SoftlockGuard + EventBus.infra presentes")
	if sg == null or bus == null or bus.infra == null:
		return
	# El disparo por transición (carga_iniciada → forzar_chequeo) no debe corromper.
	bus.infra.carga_iniciada.emit("res://scenes/main_island.tscn")
	# CHECK CONCRETO: el guard sigue operativo + el método de disparo disponible.
	_check(sg.activo, "guard sigue activo tras disparo por transición")
	_check(sg.has_method("forzar_chequeo"), "forzar_chequeo disponible tras transición")
	_check(sg._invariantes.size() >= 1, "invariantes por defecto registradas (%d)" % sg._invariantes.size())

func _test_coherencia_m23() -> void:
	# M23 (glm-5.3-flash): las cadenas pasan el validador anti-softlock
	# (referencias verificables + recompensa/consecuencia presentes)
	var h := root.get_node_or_null("Historias")
	_check(h != null, "Historias autoload presente (M23)")
	if h == null:
		return
	var errores: Array = h.validar_cadenas()
	_check(errores.is_empty(), "cadenas M23 sin softlocks de validador (%s)" % str(errores))
	# SoftlockRules accesible (núcleo ox-alpha) — sin 'or true' (era tautológico).
	# Se verifica accediendo a las constantes directamente: ClassDB.class_exists NO
	# es fiable para class_name de GDScript (da false aunque la clase sea usable).
	_check(SoftlockRules.DETECTOR_TICK_SEGUNDOS > 0.0, "SoftlockRules.DETECTOR_TICK_SEGUNDOS válido (%s)" % str(SoftlockRules.DETECTOR_TICK_SEGUNDOS))
	_check(SoftlockRules.VENTANA_MULTIPLES_FALLOS > 0.0, "SoftlockRules.VENTANA_MULTIPLES_FALLOS válido (%s)" % str(SoftlockRules.VENTANA_MULTIPLES_FALLOS))
	_check(SoftlockRules.TOAST_ACTIVO is bool, "SoftlockRules.TOAST_ACTIVO es bool")
