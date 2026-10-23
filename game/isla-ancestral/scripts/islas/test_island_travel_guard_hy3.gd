# Modelo: Hy3 (WorkBuddy / Tencent Hunyuan)
# Plataforma: WorkBuddy
# Fecha: 2026-10-23
#
# BACKLOG-MASTER Hy3 — item 62 (COLAS ACTIVA): Runtime test de M28/M27-Viajes:
# ruta / fast-travel gating. Verificacion runtime headless INDEPENDIENTE de
# M27/M28 (autor: DeepSeek-V4.1-Flash; verificador: Hunyuan -> cumple §21.23).
#
# Objeto bajo prueba: IslandTravelGuard (RefCounted puro, sin escena, sin disco,
# sin autoloads). Se instancia directo y se alimenta con una "vista" manual.
# La cola de operaciones (IslandOps, tambien RefCounted puro) se conduce en
# seco: se encola e inicia para simular cargas/descargas en curso.
#
# Cobertura de los 9 edge cases del bloque K del checklist:
#   K1  debe_precargar (vecino al borde, presupuesto por frame)
#   K2  evaluar_viaje (encolar / esperar / ninguna segun cola)
#   K3  evaluar_naufrago (en_tierra / a_bordo / oceano / agua_cerca)
#   K4  estado_destino (secreta / ancla / bloqueada / ok)
#   K5  punto_seguro (proyeccion radial al interior)
#   K6  cancelar_viaje (cancelacion limpia)
#   K7  evaluar_guardado (espera si hay carga/cola)
#   K8  respawn_cozy (siempre tierra firme)
#   K9  descarga_forzada / descarga_agresiva_viajeros (LRU, preserva progreso)
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral \
#     --script res://scripts/islas/test_island_travel_guard_hy3.gd
# Exit != 0 si falla.
#
# GUARDA ANTI-FALSO-VERDE (3 capas): _fin() por bloque + CHECKS_MINIMOS MEDIDO
# en verde + _summary() diferido SEPARADO. Si _run aborta por SCRIPT ERROR,
# _summary (deferred FIFO) detecta los bloques faltantes -> EXIT 1 (no cuelga).
# SONDA ROJA: si la env HY3_PROBE_ROJO=1 esta presente, se fuerza un check falso
# al inicio para probar que el suite REALMENTE falla (EXIT 1). Esto es la prueba
# de "test-vivo" que exige §21.8: un guardian que no pueda ponerse rojo es un
# falso verde.

extends SceneTree

# Piso MEDIDO en verde (ver Log 2147): 59 checks ejecutados, 0 fallos.
const CHECKS_MINIMOS := 59
const _WB_BLOQUES: Array[String] = [
	"_k4_estado_destino",
	"_k2_evaluar_viaje",
	"_k3k8_naufrago_respawn",
	"_k5_punto_seguro",
	"_k6_cancelar",
	"_k7_guardado",
	"_k9_descarga_forzada",
	"_k9_preset_baja",
	"_k1_precarga",
	"_validar_informe_snapshot",
]
var _checks: int = 0
var _fallos: int = 0
var _wb_vistos: Dictionary = {}
var _wb_cerrado: bool = false
var _probe_rojo: bool = false

func _init() -> void:
	_probe_rojo = (OS.get_environment("HY3_PROBE_ROJO") == "1")
	call_deferred("_run")
	call_deferred("_summary")

func _fin(nombre: String) -> void:
	_wb_vistos[nombre] = true

# ── Helpers ──────────────────────────────────────────────────────────────

## Construye un registro de vista valido por defecto (todas las CLAVES_REGISTRO).
func _mk(id: String, cx: float, cz: float, radio: float, opt: Dictionary = {}) -> Dictionary:
	var alt_min: float = float(opt.get("altura_min", 0.0))
	var alt_max: float = float(opt.get("altura_max", 50.0))
	var playa: float = float(opt.get("playa_ancho", 30.0))
	var centro := Vector3(cx, 0.0, cz)
	return {
		"id": id,
		"ancla": centro,
		"centro": centro,
		"radio": radio,
		"altura_min": alt_min,
		"altura_max": alt_max,
		"playa_ancho": playa,
		"anillo": 0,
		"es_flotante": bool(opt.get("es_flotante", false)),
		"es_secreta": bool(opt.get("es_secreta", false)),
		"tiene_ancla": bool(opt.get("tiene_ancla", true)),
		"descubierta": bool(opt.get("descubierta", true)),
		"visitada": bool(opt.get("visitada", true)),
		"desbloqueada": bool(opt.get("desbloqueada", true)),
		"punto_llegada": Vector3(cx + radio * 0.4, 1.0, cz),
		"punto_partida": Vector3(cx - radio * 0.4, 1.0, cz),
		"cargada": bool(opt.get("cargada", false)),
		"ultimo_uso": int(opt.get("ultimo_uso", 0)),
	}

## Vista base completa y valida (isla principal "aurora" + islas normales + casos
## especiales para K4). Usada en K2/K4/K6/K7/K9.
func _vista_base() -> Dictionary:
	var v: Dictionary = {}
	v["aurora"]    = _mk("aurora", 0.0, 0.0, 200.0, {"cargada": true, "ultimo_uso": 0})
	v["isla_b"]    = _mk("isla_b", -500.0, 0.0, 200.0, {"cargada": true, "ultimo_uso": 0})
	v["isla_c"]    = _mk("isla_c", 500.0, 0.0, 200.0, {"cargada": true, "descubierta": false, "visitada": true, "ultimo_uso": 1})
	v["isla_d"]    = _mk("isla_d", 0.0, 500.0, 200.0, {"cargada": true, "ultimo_uso": 2})
	v["isla_e"]    = _mk("isla_e", 0.0, -500.0, 200.0, {"cargada": false, "ultimo_uso": 0})
	v["vecina"]    = _mk("vecina", 900.0, 0.0, 200.0, {"cargada": false, "ultimo_uso": 0})
	v["secreta"]   = _mk("secreta", 1500.0, 0.0, 200.0, {"es_secreta": true, "descubierta": false})
	v["sin_ancla"] = _mk("sin_ancla", -1500.0, 0.0, 200.0, {"tiene_ancla": false})
	v["bloqueada"] = _mk("bloqueada", 0.0, 1500.0, 200.0, {"desbloqueada": false})
	return v

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % msg)
	else:
		_fallos += 1
		print("  [FAIL] %s" % msg)

# ── Run ──────────────────────────────────────────────────────────────────

func _run() -> void:
	print("=== [HY3] IslandTravelGuard M28/M27-Viajes (item 62) ===")
	if _probe_rojo:
		# SONDA ROJA: prueba de test-vivo. Debe hacer fallar y forzar EXIT 1.
		_check(false, "SONDA ROJA (test-vivo): este check DEBE fallar y forzar EXIT 1")
	# Las demas ramas se ejecutan igual en verde y en rojo; en rojo el resumen
	# ya reportara fallos por la sonda, confirmando que el suite no esta muerto.
	_k4_estado_destino()
	_fin("_k4_estado_destino")
	_k2_evaluar_viaje()
	_fin("_k2_evaluar_viaje")
	_k3k8_naufrago_respawn()
	_fin("_k3k8_naufrago_respawn")
	_k5_punto_seguro()
	_fin("_k5_punto_seguro")
	_k6_cancelar()
	_fin("_k6_cancelar")
	_k7_guardado()
	_fin("_k7_guardado")
	_k9_descarga_forzada()
	_fin("_k9_descarga_forzada")
	_k9_preset_baja()
	_fin("_k9_preset_baja")
	_k1_precarga()
	_fin("_k1_precarga")
	_validar_informe_snapshot()
	_fin("_validar_informe_snapshot")

# ── K4: estado_destino ────────────────────────────────────────────────────

func _k4_estado_destino() -> void:
	var g := IslandTravelGuard.new()
	g.configurar(_vista_base())
	var r: Dictionary
	r = g.estado_destino("no_existe")
	_check(bool(r["viajable"]) == false and str(r["motivo"]) == "isla_desconocida",
		"K4 isla_desconocida -> viajable=false")
	r = g.estado_destino("secreta")
	_check(bool(r["viajable"]) == false and str(r["motivo"]) == "secreta_no_descubierta" and bool(r["espera_coherente"]) == false,
		"K4 secreta no descubierta -> viajable=false, no espera")
	r = g.estado_destino("sin_ancla")
	_check(bool(r["viajable"]) == false and str(r["motivo"]) == "ancla_pendiente" and bool(r["espera_coherente"]) == true,
		"K4 ancla_pendiente -> viajable=false, espera_coherente=true")
	r = g.estado_destino("bloqueada")
	_check(bool(r["viajable"]) == false and str(r["motivo"]) == "bloqueada_por_progreso" and bool(r["espera_coherente"]) == true,
		"K4 bloqueada_por_progreso -> viajable=false, espera_coherente=true")
	r = g.estado_destino("isla_b")
	_check(bool(r["viajable"]) == true and str(r["motivo"]) == "ok",
		"K4 isla normal -> viajable=true, ok")

# ── K2: evaluar_viaje ─────────────────────────────────────────────────────

func _k2_evaluar_viaje() -> void:
	var g := IslandTravelGuard.new()
	g.configurar(_vista_base())
	var ops: IslandOps
	var r: Dictionary

	# dest == isla_actual
	r = g.evaluar_viaje("aurora", "aurora", null)
	_check(bool(r["permitido"]) == false and str(r["accion"]) == "ninguna" and str(r["motivo"]) == "ya_estas_ahi",
		"K2 ya_estas_ahi -> permitido=false, accion=ninguna")

	# dest no viajable (secreta) con ops=null
	r = g.evaluar_viaje("secreta", "aurora", null)
	_check(bool(r["permitido"]) == false and str(r["accion"]) == "ninguna" and str(r["motivo"]) == "secreta_no_descubierta",
		"K2 secreta no viajable -> permitido=false, accion=ninguna")

	# ancla_pendiente -> esperar (espera_coherente true)
	r = g.evaluar_viaje("sin_ancla", "aurora", null)
	_check(bool(r["permitido"]) == false and str(r["accion"]) == "esperar" and str(r["motivo"]) == "ancla_pendiente",
		"K2 ancla_pendiente -> permitido=false, accion=esperar")

	# ops null + dest viajable -> encolar
	r = g.evaluar_viaje("isla_b", "aurora", null)
	_check(bool(r["permitido"]) == true and str(r["accion"]) == "encolar" and str(r["motivo"]) == "ok",
		"K2 ops=null + viajable -> permitido=true, accion=encolar")

	# descarga en curso de OTRO -> encolar, bloquea al otro
	ops = IslandOps.new()
	ops.encolar(IslandOps.TIPO_DESCARGA, &"otra_isla")
	ops.iniciar()
	r = g.evaluar_viaje("isla_b", "aurora", ops)
	_check(bool(r["permitido"]) == true and str(r["accion"]) == "encolar" and str(r["motivo"]) == "descarga_en_curso",
		"K2 descarga_en_curso (otro) -> encolar")
	var blk: Array = r["bloquea"]
	_check(blk.size() == 1 and blk.has("otra_isla"), "K2 bloquea=[otra_isla]")

	# destino mismo se esta descargando -> encolar, destino_descargandose
	ops = IslandOps.new()
	ops.encolar(IslandOps.TIPO_DESCARGA, &"isla_b")
	ops.iniciar()
	r = g.evaluar_viaje("isla_b", "aurora", ops)
	_check(bool(r["permitido"]) == true and str(r["accion"]) == "encolar" and str(r["motivo"]) == "destino_descargandose",
		"K2 destino_descargandose -> encolar")

	# destino se esta cargando -> esperar (carga_ya_en_curso)
	ops = IslandOps.new()
	ops.encolar(IslandOps.TIPO_CARGA, &"isla_b")
	ops.iniciar()
	r = g.evaluar_viaje("isla_b", "aurora", ops)
	_check(bool(r["permitido"]) == true and str(r["accion"]) == "esperar" and str(r["motivo"]) == "carga_ya_en_curso",
		"K2 carga_ya_en_curso -> esperar")

	# cola ocupada por otra carga (no el destino) -> encolar, cola_ocupada
	ops = IslandOps.new()
	ops.encolar(IslandOps.TIPO_CARGA, &"otra_isla")
	ops.iniciar()
	r = g.evaluar_viaje("isla_b", "aurora", ops)
	_check(bool(r["permitido"]) == true and str(r["accion"]) == "encolar" and str(r["motivo"]) == "cola_ocupada",
		"K2 cola_ocupada -> encolar")

# ── K3 / K8: naufrago + respawn_cozy ──────────────────────────────────────

func _k3k8_naufrago_respawn() -> void:
	# Vista minimalista: solo aurora (radio 200). Evita ambiguedad de islas vecinas.
	var g := IslandTravelGuard.new()
	g.configurar({"aurora": _mk("aurora", 0.0, 0.0, 200.0)})
	var r: Dictionary

	# en tierra firme
	r = g.evaluar_naufrago(Vector3(10.0, 5.0, 0.0), false)
	_check(bool(r["riesgo"]) == false and str(r["motivo"]) == "en_tierra" and str(r["accion"]) == "ninguna",
		"K3 en_tierra -> riesgo=false, accion=ninguna")

	# a bordo (en agua pero en barco)
	r = g.evaluar_naufrago(Vector3(300.0, 60.0, 0.0), true)
	_check(bool(r["riesgo"]) == false and str(r["motivo"]) == "a_bordo" and str(r["accion"]) == "ninguna",
		"K3 a_bordo -> riesgo=false, accion=ninguna")

	# agua cerca de isla (fuera del disco, y fuera de rango de altura)
	r = g.evaluar_naufrago(Vector3(300.0, 60.0, 0.0), false)
	_check(bool(r["riesgo"]) == true and str(r["motivo"]) == "en_agua_cerca_de_isla" and str(r["accion"]) == "salvavidas",
		"K3 en_agua_cerca_de_isla -> riesgo=true, accion=salvavidas")

	# oceano abierto (fuera de radio_seguridad 1200)
	r = g.evaluar_naufrago(Vector3(2000.0, 60.0, 0.0), false)
	_check(bool(r["riesgo"]) == true and str(r["motivo"]) == "oceano_abierto" and str(r["accion"]) == "respawn_cozy",
		"K3 oceano_abierto -> riesgo=true, accion=respawn_cozy")

	# respawn_cozy normal: devuelve punto de tierra firme
	r = g.respawn_cozy(Vector3(10.0, 5.0, 0.0))
	_check(bool(r["ok"]) == true and str(r["isla"]) == "aurora", "K8 respawn_cozy ok=true, isla=aurora")
	var p: Vector3 = r["posicion"]
	_check(absf(p.x) <= 200.0 and absf(p.z) <= 200.0 and p.y >= 0.0 and p.y <= 50.0,
		"K8 respawn_cozy posicion dentro del disco y en rango de altura")

	# respawn_cozy sin islas -> ok=false
	var gv := IslandTravelGuard.new()
	gv.configurar({})
	r = gv.respawn_cozy(Vector3(0.0, 0.0, 0.0))
	_check(bool(r["ok"]) == false and str(r["motivo"]) == "sin_islas", "K8 sin_islas -> ok=false")

# ── K5: punto_seguro ──────────────────────────────────────────────────────

func _k5_punto_seguro() -> void:
	var g := IslandTravelGuard.new()
	g.configurar({"aurora": _mk("aurora", 0.0, 0.0, 200.0)})
	var r: Dictionary

	# punto ya firme
	r = g.punto_seguro("aurora", Vector3(80.0, 1.0, 0.0))
	_check(bool(r["ok"]) == true and bool(r["ajustado"]) == false and bool(r["fiable"]) == true,
		"K5 punto firme -> ok, ajustado=false, fiable")

	# punto en agua fuera del disco -> proyeccion al interior (ajustado=true)
	r = g.punto_seguro("aurora", Vector3(1000.0, 1.0, 0.0))
	_check(bool(r["ok"]) == true and bool(r["ajustado"]) == true and bool(r["fiable"]) == true,
		"K5 fuera del disco -> proyectado al interior (ajustado=true)")
	var pp: Vector3 = r["posicion"]
	_check(absf(pp.x) <= 199.0 and pp.y >= 0.0 and pp.y <= 50.0,
		"K5 proyectado dentro del interior del disco (sin flotante fuera)")

	# isla desconocida -> no fiable
	r = g.punto_seguro("no_existe", Vector3(0.0, 1.0, 0.0))
	_check(bool(r["ok"]) == false and str(r["motivo"]) == "isla_desconocida" and bool(r["fiable"]) == false,
		"K5 isla_desconocida -> ok=false, fiable=false")

# ── K6: cancelar_viaje ───────────────────────────────────────────────────

func _k6_cancelar() -> void:
	var g := IslandTravelGuard.new()
	g.configurar(_vista_base())
	var ops: IslandOps = IslandOps.new()
	ops.encolar(IslandOps.TIPO_CARGA, &"isla_b")
	ops.iniciar()
	var r: Dictionary = g.cancelar_viaje("isla_b", ops)
	_check(int(r["canceladas"]) >= 1, "K6 canceladas >= 1")
	_check(bool(r["limpio"]) == true, "K6 limpio=true (isla_b ya no tiene ops vivas)")
	_check((r["ops_vivas"] as Array).is_empty(), "K6 ops_vivas vacio tras cancelar")

	# ops null -> canceladas=0, limpio=true
	r = g.cancelar_viaje("isla_b", null)
	_check(int(r["canceladas"]) == 0 and bool(r["limpio"]) == true and (r["ops_vivas"] as Array).is_empty(),
		"K6 ops=null -> canceladas=0, limpio=true")

# ── K7: evaluar_guardado ─────────────────────────────────────────────────

func _k7_guardado() -> void:
	var g := IslandTravelGuard.new()
	g.configurar(_vista_base())
	var ops: IslandOps
	var r: Dictionary

	# ops null -> libre
	r = g.evaluar_guardado(null)
	_check(bool(r["puede_guardar"]) == true and bool(r["esperar"]) == false and str(r["motivo"]) == "libre",
		"K7 ops=null -> puede_guardar=true, libre")

	# carga en curso -> esperar
	ops = IslandOps.new()
	ops.encolar(IslandOps.TIPO_CARGA, &"isla_c")
	ops.iniciar()
	r = g.evaluar_guardado(ops)
	_check(bool(r["puede_guardar"]) == false and bool(r["esperar"]) == true and str(r["motivo"]) == "carga_en_curso",
		"K7 carga_en_curso -> esperar")
	_check(int(r["op"]) == ops.en_curso_id(), "K7 op == en_curso_id")

	# cola pendiente (sin iniciar) -> esperar, cola_pendiente
	ops = IslandOps.new()
	ops.encolar(IslandOps.TIPO_CARGA, &"isla_d")
	r = g.evaluar_guardado(ops)
	_check(bool(r["puede_guardar"]) == false and bool(r["esperar"]) == true and str(r["motivo"]) == "cola_pendiente",
		"K7 cola_pendiente -> esperar")
	_check(int(r["pendientes"]) >= 1, "K7 pendientes >= 1")

# ── K9: descarga_forzada (LRU, preserva descubierta/visitada) ─────────────

func _k9_descarga_forzada() -> void:
	var g := IslandTravelGuard.new()
	g.configurar(_vista_base(), {"coste_mb_por_isla": 320.0})
	var ops: IslandOps = IslandOps.new()
	var snap_antes: Dictionary = g.snapshot_estado()
	var res: Dictionary = g.descarga_forzada(3000.0, ops, "isla_b", 2048.0)
	var desc: Array = res["descargadas"]
	_check(desc.size() == 2, "K9 descarga_forzada descarga 2 islas (no intocables): %s" % desc)
	_check(desc.has("isla_c") and desc.has("isla_d"), "K9 descarga isla_c e isla_d (candidatas cargadas)")
	var intoc: Array = res["intocables"]
	_check(intoc.has("aurora") and intoc.has("isla_b"), "K9 intocables = [aurora, isla_b]")
	_check(bool(res["estado_preservado"]) == true, "K9 estado_preservado=true")
	# aurora e isla_b siguen cargadas; isla_c/isla_d NO
	var cargadas: Array = g.islas_cargadas()
	_check(cargadas.has("aurora") and cargadas.has("isla_b"), "K9 aurora+isla_b siguen cargadas")
	_check(not cargadas.has("isla_c") and not cargadas.has("isla_d"), "K9 isla_c/isla_d descargadas")
	# progreso (descubierta/visitada) intacto
	_check(bool(g.registro("isla_c")["descubierta"]) == false, "K9 isla_c sigue NO descubierta")
	_check(bool(g.registro("isla_c")["visitada"]) == true, "K9 isla_c sigue visitada")
	var snap_despues: Dictionary = g.snapshot_estado()
	_check(_snap_eq(snap_antes, snap_despues), "K9 snapshot descubierta/visitada igual antes/despues")

func _snap_eq(a: Dictionary, b: Dictionary) -> bool:
	if a.keys().size() != b.keys().size():
		return false
	for k in a.keys():
		if not b.has(k):
			return false
		if bool(a[k]["descubierta"]) != bool(b[k]["descubierta"]):
			return false
		if bool(a[k]["visitada"]) != bool(b[k]["visitada"]):
			return false
	return true

# ── K9: descarga_agresiva_viajeros (preset baja) ──────────────────────────

func _k9_preset_baja() -> void:
	var g := IslandTravelGuard.new()
	var v: Dictionary = {}
	v["aurora"] = _mk("aurora", 0.0, 0.0, 200.0, {"cargada": true})
	v["isla_b"] = _mk("isla_b", -500.0, 0.0, 200.0, {"cargada": true})
	v["isla_c"] = _mk("isla_c", 500.0, 0.0, 200.0, {"cargada": true})
	v["isla_d"] = _mk("isla_d", 0.0, 500.0, 200.0, {"cargada": true})
	g.configurar(v, {"preset": "baja"})
	_check(g.preset() == "baja", "K9(preset) preset=baja")
	_check(g.max_islas_en_memoria() == 1, "K9(preset) max_islas_en_memoria=1 (baja)")
	var ops: IslandOps = IslandOps.new()
	var res: Dictionary = g.descarga_agresiva_viajeros("isla_b", ops)
	var desc: Array = res["descargadas"]
	_check(desc.has("isla_c") and desc.has("isla_d"), "K9(preset) descarga isla_c e isla_d (viajeras)")
	_check(not desc.has("aurora") and not desc.has("isla_b"), "K9(preset) NO descarga principal ni actual")
	_check(str(res["motivo"]) == "preset_baja", "K9(preset) motivo=preset_baja")
	_check(bool(res["estado_preservado"]) == true, "K9(preset) estado_preservado=true")

# ── K1: debe_precargar ────────────────────────────────────────────────────

func _k1_precarga() -> void:
	var g := IslandTravelGuard.new()
	var v: Dictionary = {}
	v["aurora"] = _mk("aurora", 0.0, 0.0, 200.0, {"cargada": true})
	v["vecina"] = _mk("vecina", 500.0, 0.0, 200.0, {"cargada": false})
	g.configurar(v)
	# jugador en el borde de aurora (200,0,0); vecina a 300m, dentro del umbral
	# (radio+radio+margen = 200+200+256 = 656)
	var prec: Array = g.debe_precargar(Vector3(200.0, 0.0, 0.0), "aurora")
	_check(prec.size() == 1 and prec.has("vecina"), "K1 precarga vecina no cargada al borde: %s" % prec)
	# presupuesto 0 -> nada
	prec = g.debe_precargar(Vector3(200.0, 0.0, 0.0), "aurora", 0)
	_check(prec.is_empty(), "K1 presupuesto=0 -> sin precarga")
	# si vecina ya esta cargada, no es candidata
	v["vecina"] = _mk("vecina", 500.0, 0.0, 200.0, {"cargada": true})
	g.configurar(v)
	prec = g.debe_precargar(Vector3(200.0, 0.0, 0.0), "aurora")
	_check(prec.is_empty(), "K1 vecina ya cargada -> no es candidata")

# ── Validacion / informe / snapshot general ───────────────────────────────

func _validar_informe_snapshot() -> void:
	# vista valida
	var g := IslandTravelGuard.new()
	g.configurar(_vista_base())
	var errs: Array = g.validar()
	_check(errs.is_empty(), "VALIDAR vista base sin errores: %d" % errs.size())
	_check(g.es_valida() == true, "VALIDAR es_valida()=true")
	var info: Dictionary = g.informe()
	_check(int(info["islas"]) == 9, "INFORME islas=9 (vista base)")
	_check(int(info["max_islas_en_memoria"]) == 2, "INFORME max_islas_en_memoria=2 (media por defecto)")
	var snap: Dictionary = g.snapshot_estado()
	_check(snap.has("aurora") and snap.has("secreta"), "SNAPSHOT cubre todas las islas")

	# vista malformada: radio <= 0 -> error
	var g2 := IslandTravelGuard.new()
	var v2: Dictionary = {}
	v2["mala"] = _mk("mala", 0.0, 0.0, 0.0)  # radio 0
	g2.configurar(v2)
	var errs2: Array = g2.validar()
	var hay_radio: bool = false
	for e in errs2:
		if "radio <= 0" in str(e):
			hay_radio = true
	_check(hay_radio, "VALIDAR detecta radio <= 0")
	_check(g2.es_valida() == false, "VALIDAR es_valida()=false en vista malformada")

# ── Summary (3a capa) ─────────────────────────────────────────────────────

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
	print("=== Resumen HY3 M28 #62: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("FALLO (fallos=%d, checks=%d)" % [_fallos, _checks])
		quit(1)
	else:
		print("TODOS LOS CHECKS PASARON")
		quit(0)
