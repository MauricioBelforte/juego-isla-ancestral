extends SceneTree

# Modelo: minimax-m3-1-flash
# Plataforma: MiniMax API (Kilo Code)
# Fecha: 2026-10-21
#
# M17 Construccion — suite NUEVA para el runner central (res://tests/).
#
# POR QUE EXISTE: las 8 suites de M17 viven en `scripts/construccion/`, que el runner central
# NO descubre (solo recorre `res://tests/`) -> M17 tenia CERO cobertura en la suite central, y
# `test_construccion_iter7.gd` incluso estaba en ROJO (piso 24 vs 22 checks medidos) sin que
# nadie lo viera, porque nunca corria en CI. Esta suite lleva la validacion al circuito central.
#
# QUE MIDE (nucleo puro, sin mundo ni assets):
#   * las 8 REGLAS de `ConstruccionValidator.validar()` en su orden documentado
#     (zona, ocupacion, soporte, regla, npc, mundo, limite, recursos) — cada una con su motivo;
#   * la FORMA del resultado (ok/motivos/detalle/celdas/texto/temporal) y la distincion
#     motivo TEMPORAL vs PERMANENTE (el HUD reintenta solo los temporales);
#   * la REJILLA de 1 m: `mundo_desde_celda` / `celda_desde_mundo` / `esquina_desde_celda`;
#   * la ROTACION en pasos de 90 grados (la huella intercambia ancho y fondo en 90/270);
#   * costo total y devolucion por item al demoler.
#
# ANTI-FALSO-VERDE: cada check es falsable (nunca `true`) y las lambdas del contexto son
# REALES (devuelven el valor que el validador espera), no stubs que siempre pasan.
#
# Uso:
#   "<godot_console>" --headless --path game/isla-ancestral \
#     --script res://tests/test_m17_construccion_validacion.gd
# Exit: 0 = verde medido | 1 = fallos

const MODULO := "M17 construccion: validacion de colocacion + rejilla"
const TIPOS := preload("res://scripts/construccion/construccion_tipos.gd")
const VAL := preload("res://scripts/construccion/construccion_validator.gd")
const MUNDO := preload("res://scripts/construccion/construccion_mundo.gd")
const CHECKS_MINIMOS := 30

var _checks := 0
var _fallos := 0
var _detalles: Array[String] = []


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
		print("  [FAIL] %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])


## Receta base valida (1x1, exige terreno, no es sobre agua).
func _receta() -> PlacementRule:
	var r := PlacementRule.new()
	r.id = &"pared_basica"
	r.nombre = "Pared basica"
	r.familia = &"estructura"
	r.tamano = Vector2i(1, 1)
	r.altura = 1.0
	r.soportes_minimos = 1
	r.superficie_ok = [&"terreno", &"piso", &"techo"]
	r.sobre_agua = false
	r.requiere_pared = false
	r.deconstruible = true
	r.devolucion = 0.5
	r.costo = {"madera": 4}
	r.bloque = 3
	return r


## Contexto completo y por defecto: todo valido salvo lo que se indique.
## Opciones: permiso, ocupada, superficie, npc, puede_pagar, piezas_en_zona, limite.
## (GDScript no admite argumentos con nombre, por eso van en un Dictionary.)
func _ctx(opts: Dictionary = {}) -> Dictionary:
	var permiso := int(opts.get("permiso", -1))
	var ocupada := bool(opts.get("ocupada", false))
	var superficie: StringName = opts.get("superficie", &"terreno")
	var npc := bool(opts.get("npc", false))
	var puede_pagar := bool(opts.get("puede_pagar", true))
	var piezas_en_zona := int(opts.get("piezas_en_zona", 0))
	var limite: AABB = opts.get("limite", AABB())
	return ConstruccionValidator.contexto(
		func(_c): return ocupada,
		func(_c): return superficie,
		func(_c): return npc,
		func(_c): return puede_pagar,
		func(_c): return (ConstruccionTipos.Permiso.EDIFICABLE if permiso < 0 else permiso),
		func(_r, _c): return piezas_en_zona,
		limite)


func _motivos(res: Dictionary) -> Array:
	return res.get("motivos", [])


func _correr() -> void:
	await process_frame
	print("=== %s ===" % MODULO)

	# ── A. Caso OK ──
	var receta := _receta()
	var res_ok := ConstruccionValidator.validar(receta, Vector3i(4, 1, 7), 0, _ctx({}))
	_check("caso valido: ok == true", bool(res_ok.get("ok", false)))
	_check("caso valido: sin motivos", (_motivos(res_ok) as Array).is_empty(), str(_motivos(res_ok)))
	_check("caso valido: la huella trae la celda", (res_ok.get("celdas", []) as Array).has(Vector3i(4, 1, 7)))
	_check("caso valido: la forma del resultado tiene las 6 claves",
		res_ok.has("ok") and res_ok.has("motivos") and res_ok.has("detalle")
		and res_ok.has("celdas") and res_ok.has("texto") and res_ok.has("temporal"))

	# ── B. REGLA 1: ZONA ──
	var res_zona := ConstruccionValidator.validar(receta, Vector3i(0, 1, 0), 0,
		_ctx({"permiso": ConstruccionTipos.Permiso.PROTEGIDA}))
	_check("zona protegida -> ZONA_PROTEGIDA",
		(_motivos(res_zona) as Array).has(ConstruccionTipos.Motivo.ZONA_PROTEGIDA), str(_motivos(res_zona)))
	var res_narr := ConstruccionValidator.validar(receta, Vector3i(0, 1, 0), 0,
		_ctx({"permiso": ConstruccionTipos.Permiso.NARRATIVA}))
	_check("zona narrativa -> ZONA_NARRATIVA",
		(_motivos(res_narr) as Array).has(ConstruccionTipos.Motivo.ZONA_NARRATIVA))
	var res_agua := ConstruccionValidator.validar(receta, Vector3i(0, 1, 0), 0,
		_ctx({"permiso": ConstruccionTipos.Permiso.AGUA}))
	_check("agua con receta normal -> AGUA_NO_PERMITIDA",
		(_motivos(res_agua) as Array).has(ConstruccionTipos.Motivo.AGUA_NO_PERMITIDA))
	var receta_puente := _receta()
	receta_puente.id = &"puente"
	receta_puente.sobre_agua = true
	receta_puente.soportes_minimos = 0
	receta_puente.superficie_ok = [&"agua"]
	var res_puente := ConstruccionValidator.validar(receta_puente, Vector3i(0, 1, 0), 0,
		_ctx({"permiso": ConstruccionTipos.Permiso.AGUA}))
	_check("receta sobre_agua en zona AGUA -> valida",
		bool(res_puente.get("ok", false)), str(_motivos(res_puente)))

	# ── C. REGLA 2: OCUPACION ──
	var res_ocup := ConstruccionValidator.validar(receta, Vector3i(2, 1, 2), 0, _ctx({"ocupada": true}))
	_check("celda ocupada -> CELDA_OCUPADA",
		(_motivos(res_ocup) as Array).has(ConstruccionTipos.Motivo.CELDA_OCUPADA))

	# ── D. REGLA 3: SOPORTE ──
	var res_sup := ConstruccionValidator.validar(receta, Vector3i(2, 3, 2), 0, _ctx({"superficie": &"aire"}))
	_check("sin superficie debajo -> SIN_SOPORTE",
		(_motivos(res_sup) as Array).has(ConstruccionTipos.Motivo.SIN_SOPORTE))
	var receta2 := _receta()
	receta2.id = &"puente_soporte_2"
	receta2.soportes_minimos = 2
	receta2.tamano = Vector2i(2, 1)
	var res_sup2 := ConstruccionValidator.validar(receta2, Vector3i(2, 1, 2), 0, _ctx({"superficie": &"aire"}))
	_check("pieza de 2 celdas sin apoyo -> SIN_SOPORTE (soportes_minimos=2)",
		(_motivos(res_sup2) as Array).has(ConstruccionTipos.Motivo.SIN_SOPORTE))

	# ── E. REGLA 4: REQUIERE PARED ──
	var receta_puerta := _receta()
	receta_puerta.id = &"puerta"
	receta_puerta.requiere_pared = true
	receta_puerta.soportes_minimos = 0
	var res_puerta := ConstruccionValidator.validar(receta_puerta, Vector3i(3, 1, 3), 0, _ctx({}))
	_check("puerta sin pared contigua -> REQUIERE_PARED",
		(_motivos(res_puerta) as Array).has(ConstruccionTipos.Motivo.REQUIERE_PARED))
	# con pared contigua: la superficie de una celda vecina es "pared"
	var ctx_pared := ConstruccionValidator.contexto(
		func(_c): return false,
		func(c): return &"pared" if c == Vector3i(4, 1, 3) else &"terreno",
		func(_c): return false,
		func(_c): return true,
		func(_c): return ConstruccionTipos.Permiso.EDIFICABLE,
		func(_r, _c): return 0,
		AABB())
	var res_puerta_ok := ConstruccionValidator.validar(receta_puerta, Vector3i(3, 1, 3), 0, ctx_pared)
	_check("puerta CON pared contigua -> sin REQUIERE_PARED",
		not (_motivos(res_puerta_ok) as Array).has(ConstruccionTipos.Motivo.REQUIERE_PARED),
		str(_motivos(res_puerta_ok)))

	# ── F. REGLA 5: NPC ──
	var res_npc := ConstruccionValidator.validar(receta, Vector3i(6, 1, 6), 0, _ctx({"npc": true}))
	_check("NPC en la celda -> NPC_EN_CELDA",
		(_motivos(res_npc) as Array).has(ConstruccionTipos.Motivo.NPC_EN_CELDA))
	_check("NPC_EN_CELDA es TEMPORAL (se puede reintentar solo)",
		bool(res_npc.get("temporal", false)))

	# ── G. REGLA 6: FUERA DEL MUNDO ──
	var limite := AABB(Vector3(0, 0, 0), Vector3(10, 10, 10))
	var res_fuera := ConstruccionValidator.validar(receta, Vector3i(50, 1, 50), 0, _ctx({"limite": limite}))
	_check("celda fuera del AABB jugable -> FUERA_DEL_MUNDO",
		(_motivos(res_fuera) as Array).has(ConstruccionTipos.Motivo.FUERA_DEL_MUNDO), str(_motivos(res_fuera)))
	var dentro := ConstruccionValidator.validar(receta, Vector3i(5, 1, 5), 0, _ctx({"limite": limite}))
	_check("celda dentro del AABB -> sin FUERA_DEL_MUNDO",
		not (_motivos(dentro) as Array).has(ConstruccionTipos.Motivo.FUERA_DEL_MUNDO))

	# ── H. REGLA 7: LIMITE POR ZONA ──
	var receta_tope := _receta()
	receta_tope.id = &"farol"
	receta_tope.max_por_zona = 2
	var res_lim := ConstruccionValidator.validar(receta_tope, Vector3i(8, 1, 8), 0, _ctx({"piezas_en_zona": 2}))
	_check("tope por zona alcanzado -> LIMITE_DE_ZONA",
		(_motivos(res_lim) as Array).has(ConstruccionTipos.Motivo.LIMITE_DE_ZONA))
	var res_lim_ok := ConstruccionValidator.validar(receta_tope, Vector3i(8, 1, 8), 0, _ctx({"piezas_en_zona": 1}))
	_check("tope por zona NO alcanzado -> sin LIMITE_DE_ZONA",
		not (_motivos(res_lim_ok) as Array).has(ConstruccionTipos.Motivo.LIMITE_DE_ZONA))

	# ── I. REGLA 8: RECURSOS ──
	var res_rec := ConstruccionValidator.validar(receta, Vector3i(9, 1, 9), 0, _ctx({"puede_pagar": false}))
	_check("sin recursos -> RECURSOS_INSUFICIENTES",
		(_motivos(res_rec) as Array).has(ConstruccionTipos.Motivo.RECURSOS_INSUFICIENTES))
	_check("RECURSOS_INSUFICIENTES es TEMPORAL (se puede reintentar)",
		bool(res_rec.get("temporal", false)))

	# ── J. ORDEN de las reglas (documentado en el validador) ──
	var orden_esperado: Array[String] = ["zona", "ocupacion", "soporte", "regla", "npc", "mundo", "limite", "recursos"]
	_check("el validador expone las 8 reglas en el orden documentado",
		ConstruccionValidator.ORDEN == orden_esperado, str(ConstruccionValidator.ORDEN))

	# ── K. MOTIVOS: temporales vs permanentes ──
	_check("NPC_EN_CELDA es temporal", ConstruccionTipos.es_temporal(ConstruccionTipos.Motivo.NPC_EN_CELDA))
	_check("RECURSOS_INSUFICIENTES es temporal",
		ConstruccionTipos.es_temporal(ConstruccionTipos.Motivo.RECURSOS_INSUFICIENTES))
	_check("ZONA_PROTEGIDA es PERMANENTE (no temporal)",
		not ConstruccionTipos.es_temporal(ConstruccionTipos.Motivo.ZONA_PROTEGIDA))
	_check("SIN_SOPORTE es PERMANENTE", not ConstruccionTipos.es_temporal(ConstruccionTipos.Motivo.SIN_SOPORTE))
	_check("todo motivo tiene texto legible (texto de motivo desconocido == 0 para 0)",
		ConstruccionTipos.texto(ConstruccionTipos.Motivo.CELDA_OCUPADA) != "motivo desconocido (0)")
	_check("la clave de celda es canonica y reversible",
		ConstruccionTipos.celda_de_clave(ConstruccionTipos.clave(Vector3i(3, 4, 5))) == Vector3i(3, 4, 5))

	# ── L. RECETA INVALIDA ──
	var receta_vacia := PlacementRule.new()
	var res_invalida := ConstruccionValidator.validar(receta_vacia, Vector3i(0, 0, 0), 0, _ctx({}))
	_check("receta sin id -> RECETA_INVALIDA",
		(_motivos(res_invalida) as Array).has(ConstruccionTipos.Motivo.RECETA_INVALIDA))
	var res_nula := ConstruccionValidator.validar(null, Vector3i(0, 0, 0), 0, _ctx({}))
	_check("receta nula -> RECETA_INVALIDA (no crashea)",
		(_motivos(res_nula) as Array).has(ConstruccionTipos.Motivo.RECETA_INVALIDA))

	# ── M. REJILLA de 1 m (round-trip celda <-> mundo) ──
	_check("OFFSET_MEDIO_VOXEL == 0.5 (celda en el centro del voxel)",
		is_equal_approx(MUNDO.OFFSET_MEDIO_VOXEL, 0.5))
	var rt := true
	for c in [Vector3i(0, 0, 0), Vector3i(3, 1, 5), Vector3i(-2, 4, -7), Vector3i(100, 0, 100)]:
		if MUNDO.celda_desde_mundo(MUNDO.mundo_desde_celda(c)) != c:
			rt = false
	_check("round-trip celda -> mundo -> celda (4 casos)", rt)
	_check("esquina_desde_celda da la esquina exacta (AABB)",
		MUNDO.esquina_desde_celda(Vector3i(2, 1, 3)) == Vector3(2, 1, 3))
	_check("celda_desde_mundo hace floor (no redondea)",
		MUNDO.celda_desde_mundo(Vector3(4.9, 0.1, 6.99)) == Vector3i(4, 0, 6))
	# El origen de la rejilla de construccion coincide con el origen global del mundo
	# voxel (celda (0,0,0) -> centro (0.5,0.5,0.5)): sin displacement ni offset extra.
	_check("el origen de la rejilla coincide con el origen global del mundo voxel",
		MUNDO.mundo_desde_celda(Vector3i.ZERO) == Vector3(0.5, 0.5, 0.5),
		str(MUNDO.mundo_desde_celda(Vector3i.ZERO)))
	# Una pieza de 2x2 ocupa EXACTAMENTE su area completa en la rejilla.
	var r_area := _receta()
	r_area.id = &"placa_2x2"
	r_area.tamano = Vector2i(2, 2)
	var huella := r_area.celdas(Vector3i(3, 1, 4), 0)
	var area_ok := (huella as Array).size() == 4
	for c in [Vector3i(3, 1, 4), Vector3i(4, 1, 4), Vector3i(3, 1, 5), Vector3i(4, 1, 5)]:
		if not (huella as Array).has(c):
			area_ok = false
	_check("una pieza de 2x2 ocupa exactamente su area completa en la rejilla", area_ok, str(huella))

	# ── N. ROTACION en pasos de 90 grados ──
	var r2 := _receta()
	r2.tamano = Vector2i(2, 1)
	var h0 := r2.celdas(Vector3i.ZERO, 0)
	var h1 := r2.celdas(Vector3i.ZERO, 1)
	_check("rotacion 0: huella 2x1 (2 celdas en X)", h0.size() == 2 and (h0 as Array).has(Vector3i(1, 0, 0)))
	_check("rotacion 1 (90 grados): la huella intercambia ancho y fondo",
		h1.size() == 2 and (h1 as Array).has(Vector3i(0, 0, 1)), str(h1))
	_check("rotacion 2 (180): vuelve al footprint original",
		(r2.celdas(Vector3i.ZERO, 2) as Array) == h0)
	_check("rotacion 3 (270): como la 1", (r2.celdas(Vector3i.ZERO, 3) as Array) == h1)
	_check("la rotacion es posmod (4 == 0)", (r2.celdas(Vector3i.ZERO, 4) as Array) == h0)

	# ── O. COSTO y devolucion ──
	_check("costo_total suma el costo de la receta", receta.costo_total() == 4)
	var dev := receta.devolucion_por_item()
	_check("devolucion al demoler = 50% (floor)", int(dev.get("madera", 0)) == 2, str(dev))
	var receta_dev := _receta()
	receta_dev.costo = {"madera": 3, "piedra": 5}
	_check("devolucion por item con 2 recursos",
		(receta_dev.devolucion_por_item() as Dictionary).size() == 2, str(receta_dev.devolucion_por_item()))

	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	for d in _detalles:
		print("  FALLO: " + d)
	if _fallos > 0 or _checks < CHECKS_MINIMOS:
		print("TEST %s FALLIDO (checks=%d, minimo=%d)" % [MODULO, _checks, CHECKS_MINIMOS])
		quit(1)
	else:
		print("TEST %s OK — la validacion de colocacion y la rejilla estan cubiertas" % MODULO)
		quit(0)
