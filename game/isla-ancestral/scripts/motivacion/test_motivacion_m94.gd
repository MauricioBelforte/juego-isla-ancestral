# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M94: Retención sin FOMO — Test headless
# Valida: catálogo data-driven, tablero por plazo, progreso/recompensa,
# rotación sin pérdida, cola de recompensas (límite 50), motor de variantes,
# AntiFomoAuditor (5 reglas) y persistencia snapshot/restaurar.
# Exit code != 0 si falla.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.

extends SceneTree

const _SC_ACTIVO := preload("res://scripts/motivacion/objetivo_activo.gd")
const _SC_RECOM := preload("res://scripts/motivacion/recompensa_acumulada.gd")
const _SC_VARIANTES := preload("res://scripts/motivacion/motor_variantes.gd")
const _SC_AUDITOR := preload("res://scripts/motivacion/antifomo_auditor.gd")

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M94] Test de Retención sin FOMO ===")
	_test_objetivo_activo()
	_test_catalogo_y_tablero()
	_test_progreso_y_recompensa()
	_test_rotacion_sin_perdida()
	_test_cola_recompensas()
	_test_motor_variantes()
	_test_antifomo_auditor()
	_test_persistencia()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

## ── ObjetivoActivo ──────────────────────────────────────

func _test_objetivo_activo() -> void:
	print("--- ObjetivoActivo: estado y avance ---")
	var o = _SC_ACTIVO.new("recolectar_madera")
	_check("id correcto", o.objetivo_id == "recolectar_madera")
	_check("no completo al inicio", not o.esta_completo(10))
	var completado := o.avanzar(10, 10)
	_check("avanzar 10 -> completo", completado and o.esta_completo(10))
	_check("completado flag", o.completado)
	var d := o.a_diccionario()
	_check("a_diccionario ok", d.get("progreso", 0) == 10 and d.get("completado", false) == true)
	var o2 = _SC_ACTIVO.desde_diccionario(d)
	_check("desde_diccionario round-trip", o2.progreso == 10 and o2.objetivo_id == "recolectar_madera")

## ── Catálogo y tablero ──────────────────────────────────

func _test_catalogo_y_tablero() -> void:
	print("--- Catálogo y tablero por plazo ---")
	var mm := root.get_node_or_null("MotivacionManager")
	if mm == null:
		_check("MotivacionManager autoload presente", false)
		_summary()
		quit(1)
		return
	_check("MotivacionManager autoload presente", true)
	_check("catálogo con 7 objetivos", mm.catalogo.size() == 7, "size=%d" % mm.catalogo.size())
	var diarios = mm.objetivos_por_plazo("diario")
	var semanales = mm.objetivos_por_plazo("semanal")
	var mensuales = mm.objetivos_por_plazo("mensual")
	_check("diarios = 3", diarios.size() == 3, "size=%d" % diarios.size())
	_check("semanales = 2", semanales.size() == 2, "size=%d" % semanales.size())
	_check("mensuales = 2", mensuales.size() == 2, "size=%d" % mensuales.size())

## ── Progreso y recompensa ───────────────────────────────

func _test_progreso_y_recompensa() -> void:
	print("--- Progreso y recompensa acumulada ---")
	var mm := root.get_node_or_null("MotivacionManager")
	var ok_parcial = mm.registrar_progreso("recolectar_madera", 5)
	_check("progreso parcial no completa", ok_parcial == false)
	var ok_completo = mm.registrar_progreso("recolectar_madera", 5)
	_check("progreso a 10 completa", ok_completo == true)
	_check("recompensa acumulada (1 pendiente)", mm.recompensas.pendientes_count() == 1, "count=%d" % mm.recompensas.pendientes_count())
	_check("objetivo marcado cobrado", mm.activos["recolectar_madera"].cobrado == true)

## ── Rotación sin pérdida ────────────────────────────────

func _test_rotacion_sin_perdida() -> void:
	print("--- Rotación sin pérdida (RF1) ---")
	var mm := root.get_node_or_null("MotivacionManager")
	# completar otro objetivo antes de rotar
	mm.registrar_progreso("regalar_regalo", 1)
	mm.rotar_objetivos()
	# al rotar, el premio pendiente de regalar_regalo quedó acumulado
	_check("rotación conserva premio pendiente", mm.recompensas.pendientes_count() >= 2, "count=%d" % mm.recompensas.pendientes_count())
	# objetivos reiniciados para el nuevo ciclo
	var madera = mm.activos["recolectar_madera"]
	_check("objetivo reiniciado tras rotación", madera.progreso == 0 and not madera.completado)
	_check("ciclo avanzó", madera.ciclo == 2, "ciclo=%d" % madera.ciclo)

## ── Cola de recompensas ─────────────────────────────────

func _test_cola_recompensas() -> void:
	print("--- RecompensaAcumulada: límite 50 y cobro ---")
	var r = _SC_RECOM.new()
	for i in range(55):
		r.agregar("moneda", 10)
	_check("límite 50 pendientes", r.pendientes_count() == 50, "count=%d" % r.pendientes_count())
	var cobradas = r.cobrar_pendientes()
	_check("cobrar devuelve 50", cobradas.size() == 50, "size=%d" % cobradas.size())
	_check("cola vacía tras cobrar", r.pendientes_count() == 0)
	# serialización
	r.agregar("moneda", 5)
	var d := r.a_diccionario()
	var r2 = _SC_RECOM.desde_diccionario(d)
	_check("round-trip cola", r2.pendientes_count() == 1)

## ── Motor de variantes ──────────────────────────────────

func _test_motor_variantes() -> void:
	print("--- MotorEventosVariantes: ciclo 3+ y participaciones ---")
	var mv = _SC_VARIANTES.new()
	mv.registrar("festival_test", ["a", "b", "c", "d"])
	_check("siguiente_variante a", mv.siguiente_variante("festival_test") == "a")
	_check("siguiente_variante b", mv.siguiente_variante("festival_test") == "b")
	_check("siguiente_variante c", mv.siguiente_variante("festival_test") == "c")
	_check("siguiente_variante d (4ª)", mv.siguiente_variante("festival_test") == "d")
	_check("cicla a 'a' en la 5ª", mv.siguiente_variante("festival_test") == "a")
	_check("participaciones acumuladas", mv.participaciones("festival_test") == 5, "count=%d" % mv.participaciones("festival_test"))
	_check("festividad sin variantes -> ''", mv.siguiente_variante("no_existe") == "")
	var d := mv.a_diccionario()
	var mv2 = _SC_VARIANTES.desde_diccionario(d)
	var participaciones_ok: int = mv2.participaciones("festival_test")
	_check("round-trip participaciones", participaciones_ok == 5, "count=%d" % participaciones_ok)
	_check("round-trip siguiente variante", mv2.siguiente_variante("festival_test") == "b")

## ── AntiFomoAuditor ─────────────────────────────────────

func _test_antifomo_auditor() -> void:
	print("--- AntiFomoAuditor: 5 reglas ---")
	var mm := root.get_node_or_null("MotivacionManager")
	var violaciones = mm.auditar()
	_check("config del juego: 0 violaciones", violaciones.is_empty(), "viol=%s" % str(violaciones))
	# config con violaciones a propósito -> detectadas
	var malas = _SC_AUDITOR.escanear([], {"penaliza_ausencia": true, "usa_tiempo_real": true})
	_check("detección ausencia + reloj real", malas.size() == 2 and "R3_no_castigo_ausencia" in malas and "R5_no_reloj_real" in malas)
	var todas = _SC_AUDITOR.escanear([], {"permite_streak": true, "permite_expiracion": true, "penaliza_ausencia": true, "exclusivo_temporal": true, "usa_tiempo_real": true})
	_check("detección de las 5 reglas", todas.size() == 5, "size=%d" % todas.size())
	var reporte := _SC_AUDITOR.reporte(malas)
	_check("reporte contiene R3", reporte.contains("R3_no_castigo_ausencia"))
	_check("reporte OK cuando limpio", _SC_AUDITOR.reporte([]).contains("OK"))

## ── Persistencia ────────────────────────────────────────

func _test_persistencia() -> void:
	print("--- Persistencia snapshot/restaurar ---")
	var mm := root.get_node_or_null("MotivacionManager")
	var snap = mm.snapshot()
	_check("snapshot con activos/recompensas/variantes", snap.has("activos") and snap.has("recompensas") and snap.has("motor_variantes"))
	mm.restaurar(snap)
	_check("restaurar mantiene cola", mm.recompensas.pendientes_count() == mm.recompensas.pendientes_count())

## ── Summary ──────────────────────────────────────────────

func _summary() -> void:
	print("=== Resumen M94: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M94 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M94 OK — todos los checks pasaron")
		quit(0)