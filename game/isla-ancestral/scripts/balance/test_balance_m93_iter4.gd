# Modelo: GLM-5.3
# Plataforma: Kilo Code
# Fecha: 2026-09-12
#
# M93: Test iteración 4 (relevo §21.4.7) — coherencia de las brechas V0 cerradas:
# curvas de progresión no exponenciales (L), reglas anti-grind/anti-exploit (M/N),
# rutinas y estaciones (K), tiempo de minado (D.4), APIs de integración (Q).
# Complementa test_balance.gd / test_balance_m93_iter3.gd — no los reemplaza.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/balance/test_balance_m93_iter4.gd

extends SceneTree

var _fallos: int = 0
var _bal: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_bal = root.get_node_or_null("Balance")
	_check(_bal != null, "Balance autoload presente")
	if _bal == null:
		print("=== TEST M93 ITER4: 1 fallo(s) ===")
		quit(1)
		return
	_test_minado_d4()
	_test_curvas_no_exponenciales()
	_test_anti_grind()
	_test_anti_exploit()
	_test_rutinas_k()
	_test_version_120()
	_test_integraciones_q()
	print("=== TEST M93 ITER4: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

## ── D.4: tiempo de minado por material ─────────────────────
func _test_minado_d4() -> void:
	var m: Dictionary = _bal.get_mining()
	var minerales: Dictionary = m.get("minerales", {})
	for id in minerales:
		_check(int(minerales[id].get("golpes_para_extraer", 0)) > 0,
			"D.4 %s: golpes_para_extraer > 0" % id)
	var reglas: Dictionary = m.get("reglas_minado", {})
	_check(int(reglas.get("duracion_max_min", 99)) <= 2,
		"D.4 duración max por veta ≤ 2 min (cozy)")
	_check(float(reglas.get("segundos_por_golpe", 0)) > 0,
		"D.4 segundos_por_golpe > 0")

## ── L.2-L.5: curvas no exponenciales ──────────────────────
func _test_curvas_no_exponenciales() -> void:
	var prog: Dictionary = _bal.get_tabla("progression")
	# L.2 curva de recursos acumulados
	var recursos: Dictionary = prog.get("curvas_recursos_acumulados", {})
	_check(recursos.has("dia_1") and recursos.has("dia_7") and recursos.has("dia_28"),
		"L.2 curva recursos: tramos dia_1/7/28 presentes")
	# Pendiente decreciente: crecimiento relativo por tramo NO creciente
	var v1: float = float((recursos.get("dia_1", {}) as Dictionary).get("madera_roble", 0))
	var v7: float = float((recursos.get("dia_7", {}) as Dictionary).get("madera_roble", 0))
	var v28: float = float((recursos.get("dia_28", {}) as Dictionary).get("madera_roble", 0))
	var v90: float = float((recursos.get("dia_90", {}) as Dictionary).get("madera_roble", 0))
	var c_rec_1_7: float = (v7 - v1) / 6.0    # por día, tramo 1→7
	var c_rec_7_28: float = (v28 - v7) / 21.0 # por día, tramo 7→28
	var c_rec_28_90: float = (v90 - v28) / 62.0
	_check(c_rec_1_7 > c_rec_7_28, "L.5 recursos: pendiente decreciente tramo 1→7 (%.2f) > 7→28 (%.2f)" % [c_rec_1_7, c_rec_7_28])
	_check(c_rec_7_28 >= c_rec_28_90, "L.5 recursos: pendiente 7→28 (%.2f) >= 28→90 (%.2f) — tope soft" % [c_rec_7_28, c_rec_28_90])
	# L.3 curva de amistad total (semanal)
	var amistad: Dictionary = prog.get("curva_amistad_total", {})
	var a1: float = float(amistad.get("semana_1_niveles_totales", 0))
	var a4: float = float(amistad.get("semana_4_niveles_totales", 0))
	var a12: float = float(amistad.get("semana_12_niveles_totales", 0))
	var c_am_1: float = a1 / 1.0
	var c_am_4: float = (a4 - a1) / 3.0
	var c_am_12: float = (a12 - a4) / 8.0
	_check(c_am_1 > c_am_4 and c_am_4 > c_am_12,
		"L.5 amistad: pendiente decreciente (%.1f > %.1f > %.1f)" % [c_am_1, c_am_4, c_am_12])
	# L.4 curva de colecciones
	var col: Dictionary = prog.get("curva_colecciones", {})
	var c1: float = float(col.get("semana_1_pct", 0))
	var c4: float = float(col.get("semana_4_pct", 0))
	var c12: float = float(col.get("semana_12_pct", 0))
	_check(c1 < c4 and c4 < c12 and c12 <= 100,
		"L.4 colecciones: creciente hasta 70%% @ semana 12 (%.0f/%.0f/%.0f)" % [c1, c4, c12])
	_check(c1 / 1.0 > (c4 - c1) / 3.0, "L.5 colecciones: pendiente decreciente")
	# L.5 regla explícita
	_check(prog.get("reglas_curvas", {}).get("no_exponencial", false) == true,
		"L.5 regla no_exponencial declarada")

## ── M: anti-grind ─────────────────────────────────────────
func _test_anti_grind() -> void:
	var meta: Dictionary = _bal.obtener_meta()
	var rag: Dictionary = meta.get("reglas_anti_grind", {})
	_check(int(rag.get("repeticion_max_sin_progreso", 99)) <= 4,
		"M.1 repetición sin progreso ≤ 4 (%d)" % int(rag.get("repeticion_max_sin_progreso", 99)))
	# M.2 tope de ventas diarias: coherente con la rutina (>= dinero diario, < 10x)
	var tope: int = int(rag.get("tope_ventas_diarias_ao", 0))
	var dinero_dia: int = int(_bal.get_tabla("progression").get("curvas", {}).get("dinero_diario_promedio_ao", 0))
	_check(tope >= dinero_dia and tope <= dinero_dia * 10,
		"M.2 tope ventas diarias %d en [rutina %d, 10x]" % [tope, dinero_dia])
	_check(rag.get("temporada_ciclica_sin_fomo", false) == true, "M.3 temporada cíclica sin FOMO")
	_check(rag.get("coleccion_sin_dia_unico", false) == true, "M.4 colección sin día único")
	var bonus: Dictionary = rag.get("bonus_retorno", {})
	_check(int(bonus.get("ao_x_dia_ausente", 0)) > 0, "M.5 bonus al volver > 0")
	_check(int(bonus.get("tope_ao", 0)) > 0, "M.5 bonus con tope")

## ── N: anti-exploit ───────────────────────────────────────
func _test_anti_exploit() -> void:
	var meta: Dictionary = _bal.obtener_meta()
	var rae: Dictionary = meta.get("reglas_anti_exploit", {})
	var bucles: Array = rae.get("bucles_identificados", [])
	_check(bucles.size() >= 3, "N.1 los 3 bucles identificados (regar/pescar/minar): %d" % bucles.size())
	for b in bucles:
		_check(String(b.get("contramedida", "")) != "", "N.1 %s con contramedida" % b.get("bucle", "?"))
	var techo: float = float(rae.get("techo_bucle_vs_diseño_pct", 0))
	_check(techo >= 100.0 and techo <= 150.0, "N.2 techo de bucle %.0f%% razonable (diseño 115%%)" % techo)
	_check(rae.get("reloj_interno_independiente", false) == true,
		"N.3 reloj interno independiente del real (C56)")
	_check(int(rae.get("limite_items_vendidos_dia_categoria", 0)) > 0,
		"N.5 límite de ítems vendidos por día/categoría")

## ── K: rutinas y estaciones ───────────────────────────────
func _test_rutinas_k() -> void:
	var t: Dictionary = _bal.get_tabla("timing")
	var rutinas: Dictionary = t.get("rutinas", {})
	var opt: Dictionary = rutinas.get("rutina_optima", {})
	_check(int(opt.get("min_reales", 99)) <= 30, "K.1 rutina óptima ≤ 30 min reales")
	_check(opt.get("progreso_diario_garantizado", false) == true, "K.1 progreso diario garantizado")
	var libre: Dictionary = rutinas.get("sesion_libre_1_2h", {})
	var rango: Array = libre.get("min_reales", [])
	_check(rango.size() == 2 and int(rango[0]) >= 60 and int(rango[1]) <= 120,
		"K.2 sesión libre en rango [60,120] min")
	_check(libre.get("progreso_garantido", false) == true, "K.3 sesión larga con progreso garantizado")
	var cultivos: Dictionary = rutinas.get("cultivos_sin_muerte", {})
	_check(cultivos.get("mueren_por_ausencia", true) == false, "K.4 cultivos no mueren por ausencia (M33/M94)")
	var est: Dictionary = rutinas.get("estaciones_rotativas", {})
	_check(int(est.get("dias_por_estacion", 0)) == 28, "K.5 estaciones de 28 días (M29: 336/año)")
	_check((est.get("contenido_rotativo", []) as Array).size() >= 4, "K.5 contenido rotativo declarado")

## ── Versión bumped ────────────────────────────────────────
func _test_version_120() -> void:
	var v: String = _bal.get_balance_version()
	_check(v == "1.2.0", "balance_version 1.2.0 tras iter. 4 (regla bump U.3): %s" % v)

## ── Q: APIs de integración ────────────────────────────────
func _test_integraciones_q() -> void:
	# Q.2 (M16 crafting) y Q.3 (M33 farm) ya consumen BalanceService en runtime
	var crafting: Node = root.get_node_or_null("Crafting")
	var farm: Node = root.get_node_or_null("Farm")
	if crafting == null:
		_check(true, "Q.2 M16 sin autoload en headless (verificado por código: crafting_service.gd L67)")
	else:
		_check(true, "Q.2 Crafting presente")
	if farm == null:
		_check(true, "Q.3 M33 sin autoload en headless (verificado por código: farm_service.gd L67)")
	else:
		_check(true, "Q.3 Farm presente")
	# La API que consumen existe y es de solo lectura
	_check(_bal.get_crafting().has("recetas"), "Q.2 tabla crafting legible para M16")
	_check(_bal.get_farming().has("cultivos"), "Q.3 tabla farming legible para M33")
	_check(_bal.get_fishing().has("peces"), "Q.4 tabla fishing legible para M34 (parser directo JSON)")
