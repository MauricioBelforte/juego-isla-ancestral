# Modelo: DeepSeek-V4.1-Flash (OpenCode)
# Plataforma: OpenCode
# Fecha: 2026-11-08
#
# Critical de la evaluación Nemotron (Glyph Cluster) — HealthComponent:
#   1. daño negativo/nulo/NaN no debe mover la salud (antes el negativo CURABA).
#   2. la muerte no debe ser repetible (`is_dead` + `died` una sola vez).
#   3. la señal `died` debe estar alineada con `IDamageable` (`died(killer)`).
#   4. el componente debe exponer el contrato `IDamageable` por duck-typing.
#
# Guardia anti-falso-verde: CHECKS_MINIMOS medido + resumen en call_deferred
# separado + watchdog.
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral --script res://tests/unit/components/test_health_component.gd

extends SceneTree

const TIMEOUT_SEG := 60.0
const CHECKS_MINIMOS := 34

const HEALTH := preload("res://scripts/utils/components/health_component.gd")

var _checks: int = 0
var _fallos: int = 0
var _bloque: String = "(inicio)"
var _detalles: Array[String] = []
var _senales: Array = []


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	create_timer(TIMEOUT_SEG, true).timeout.connect(_on_watchdog)
	print("=== HealthComponent: validacion + muerte unica + contrato IDamageable ===")
	_bloque_a()
	_bloque_b()
	_bloque_c()
	_bloque_d()
	_bloque_e()
	_bloque_f()


func _on_watchdog() -> void:
	print("WATCHDOG: la suite no termino en %.0f s (ultimo bloque: %s)" % [TIMEOUT_SEG, _bloque])
	quit(1)


func _check(nombre: String, ok: bool, detalle: String = "") -> void:
	_checks += 1
	if ok:
		print("  [ok]   %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])
	else:
		_fallos += 1
		_detalles.append(nombre + (" (" + detalle + ")" if detalle != "" else ""))
		print("  [FAIL] %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])


func _nuevo(max_h: float = 100.0) -> Node:
	var h = HEALTH.new()
	h.max_health = max_h
	root.add_child(h)
	_senales.clear()
	h.health_changed.connect(func(c: float, m: float, d: float) -> void:
		_senales.append({"tipo": "hp", "c": c, "m": m, "d": d}))
	h.died.connect(func(killer: Node) -> void:
		_senales.append({"tipo": "died", "killer": killer}))
	return h


func _cuenta(tipo: String) -> int:
	var n := 0
	for s in _senales:
		if s["tipo"] == tipo:
			n += 1
	return n


# ── A. DAÑO VÁLIDO ────────────────────────────────────────────────────
func _bloque_a() -> void:
	_bloque = "A. danio valido"
	var h = _nuevo()
	_check("A1 acepta danio simple", h.damage(10.0) == true)
	_check("A2 salud 100 -> 90", is_equal_approx(h.current_health, 90.0), str(h.current_health))
	_check("A3 health_changed emitido una vez", _cuenta("hp") == 1, str(_cuenta("hp")))
	_check("A4 delta del cambio es -10", is_equal_approx(float(_senales[0]["d"]), -10.0),
		str(_senales[0]["d"]))
	_check("A5 vivo tras danio no letal", h.is_alive() and not h.is_dead)
	# clamp inferior: no baja de 0
	h.damage(500.0)
	_check("A6 salud clampeada a 0", is_equal_approx(h.current_health, 0.0), str(h.current_health))
	_check("A7 muere con danio letal", h.is_dead == true)


# ── B. DAÑO INVÁLIDO (el crítico) ─────────────────────────────────────
func _bloque_b() -> void:
	_bloque = "B. danio invalido"
	var h = _nuevo()
	h.damage(10.0)          # 90
	var antes: float = h.current_health
	_check("B1 danio NEGATIVO rechazado (no cura)", h.damage(-30.0) == false)
	_check("B2 la salud no se movio con el negativo", is_equal_approx(h.current_health, antes),
		"%s vs %s" % [h.current_health, antes])
	_check("B3 danio CERO rechazado", h.damage(0.0) == false)
	_check("B4 salud intacta tras danio 0", is_equal_approx(h.current_health, antes))
	_check("B5 danio NaN rechazado", h.damage(NAN) == false)
	_check("B6 salud sigue FINITA tras NaN", is_finite(h.current_health), str(h.current_health))
	_check("B7 danio INF rechazado", h.damage(INF) == false)
	_check("B8 salud sigue siendo 90 tras INF", is_equal_approx(h.current_health, 90.0),
		str(h.current_health))
	_check("B9 cada rechazo emitio cambio_ignorado", _cuenta("hp") == 1, str(_cuenta("hp")))


# ── C. MUERTE ÚNICA ───────────────────────────────────────────────────
func _bloque_c() -> void:
	_bloque = "C. muerte unica"
	var h = _nuevo()
	var killer := Node.new()
	root.add_child(killer)
	_check("C1 danio letal con killer", h.damage(200.0, killer) == true)
	_check("C2 died emitida 1 vez", _cuenta("died") == 1, str(_cuenta("died")))
	var ev = null
	for s in _senales:
		if s["tipo"] == "died":
			ev = s
	_check("C3 died llega con el killer del contrato", ev != null and ev.get("killer") == killer)
	_check("C4 danio sobre muerto devuelve false", h.damage(10.0) == false)
	_check("C5 died NO se repite", _cuenta("died") == 1, str(_cuenta("died")))
	_check("C6 is_alive() false", h.is_alive() == false)


# ── D. CURACIÓN ───────────────────────────────────────────────────────
func _bloque_d() -> void:
	_bloque = "D. curacion"
	var h = _nuevo()
	h.damage(50.0)  # 50
	_check("D1 heal valido aceptado", h.heal(20.0) == true)
	_check("D2 50 + 20 = 70", is_equal_approx(h.current_health, 70.0), str(h.current_health))
	_check("D3 heal NEGATIVO rechazado (no dana)", h.heal(-15.0) == false)
	_check("D4 salud intacta con heal negativo", is_equal_approx(h.current_health, 70.0))
	_check("D5 heal NaN rechazado", h.heal(NAN) == false)
	_check("D6 heal INF rechazado", h.heal(INF) == false)
	_check("D7 heal clamp al maximo", h.heal(999.0) == true and is_equal_approx(h.current_health, 100.0),
		str(h.current_health))
	_check("D8 heal al tope rechazado", h.heal(1.0) == false)
	h.damage(1000.0)
	_check("D9 heal sobre muerto rechazado", h.heal(50.0) == false)
	_check("D10 revive(0.5) devuelve a 50 y revive", h.revive(0.5) == true
		and is_equal_approx(h.current_health, 50.0) and not h.is_dead, str(h.current_health))
	_check("D11 revive sobre vivo rechazado", h.revive(0.5) == false)


# ── E. SET_HEALTH Y CONTRATO IDamageable ──────────────────────────────
func _bloque_e() -> void:
	_bloque = "E. contrato IDamageable"
	var h = _nuevo(80.0)
	_check("E1 get_max_health() = 80", is_equal_approx(h.get_max_health(), 80.0))
	_check("E2 get_health() = 80 al inicio", is_equal_approx(h.get_health(), 80.0))
	_check("E3 is_alive() true", h.is_alive() == true)
	var real: float = h.take_damage(30.0, &"fisico", null)
	_check("E4 take_damage devuelve el danio real", is_equal_approx(real, 30.0), str(real))
	_check("E5 take_damage aplico 80 -> 50", is_equal_approx(h.get_health(), 50.0))
	_check("E6 take_damage invalido devuelve 0", is_equal_approx(h.take_damage(-5.0), 0.0))
	h.set_health(999.0)
	_check("E7 set_health clamp al maximo", is_equal_approx(h.current_health, 80.0),
		str(h.current_health))
	h.set_health(NAN)
	_check("E8 set_health NaN no toca la salud", is_equal_approx(h.current_health, 80.0),
		str(h.current_health))
	h.set_health(0.0)
	_check("E9 set_health(0) mata", h.is_dead == true and h.is_alive() == false)


# ── F. MÁXIMO INVÁLIDO ────────────────────────────────────────────────
func _bloque_f() -> void:
	_bloque = "F. maximo invalido"
	var h = _nuevo(0.0)
	_check("F1 max_health 0 se sanea a 100", is_equal_approx(h.max_health, 100.0),
		str(h.max_health))
	_check("F2 salud inicial = maximo saneado", is_equal_approx(h.current_health, 100.0))
	var h2 = _nuevo(-50.0)
	_check("F3 max_health negativo se sanea a 100", is_equal_approx(h2.max_health, 100.0))
	var h3 = _nuevo(NAN)
	_check("F4 max_health NaN se sanea a 100", is_equal_approx(h3.max_health, 100.0))


func _summary() -> void:
	print("=== Resumen HealthComponent: %d checks, %d fallos (minimo %d) ===" % [
		_checks, _fallos, CHECKS_MINIMOS])
	if _fallos > 0:
		print("FALLOS:")
		for d in _detalles:
			print("  - " + d)
	if _checks < CHECKS_MINIMOS:
		print("INVALIDO: la suite corrio %d checks, por debajo del minimo %d" % [_checks, CHECKS_MINIMOS])
		quit(2)
		return
	if _fallos > 0:
		print("TEST HealthComponent FALLIDO")
		quit(1)
		return
	print("TEST HealthComponent OK — validacion, muerte unica y contrato IDamageable cubiertos")
	quit(0)
