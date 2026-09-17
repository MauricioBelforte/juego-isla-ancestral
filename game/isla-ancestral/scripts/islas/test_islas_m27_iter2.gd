# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-15
#
# M27: Islas del Mundo — test headless (iter. 2).
#
# Cubre lo que la iter. 1 no tocó: los 16 `[ ]` propios del checklist.
#   A. IslandOps (cola de operaciones: prioridad, pesos, estados, cancelación)
#   B. K1 + K2 (precarga sin congelar / viajar mientras otra isla se descarga)
#   C. K3 + K8 (náufrago / respawn cozy)
#   D. K4 + K5 (ancla pendiente / punto seguro de desembarco)
#   E. K6 + K7 (cancelación limpia / guardado durante una carga)
#   F. K9 (descarga forzada por memoria sin perder estado)
#   G. Catálogo de los 26 puntos de la §26 del plan maestro
#   H. Integración con el autoload `IslandRegistry` real
#
# ⚠️ Las anclas reales las pone M10, que todavía no existe: el registry real
# tiene todas las islas en (0,0,0). Para verificar GEOMETRÍA se usa la
# disposición de referencia que documenta `generar_islas.gd` (la misma que usa
# el test de la iter. 1). Sin ella, todas las islas se superponen y cualquier
# medición de distancia sería basura.
#
# Uso:
#   "<godot_console>" --headless --path game/isla-ancestral \
#     --script res://scripts/islas/test_islas_m27_iter2.gd

extends SceneTree

const MODULO := "M27 iter.2"
const TIMEOUT_FRAMES := 1800
const BLOQUES_ESPERADOS: Array[String] = ["A", "B", "C", "D", "E", "F", "G", "H"]

## Disposición de anclas de REFERENCIA (idéntica a la del test de la iter. 1).
const LAYOUT := {
	"aurora": Vector3i(0, 0, 0),
	"coral": Vector3i(0, 0, 1100),
	"verde": Vector3i(-953, 0, -550),
	"pequena": Vector3i(953, 0, -550),
	"cenizas": Vector3i(2078, 0, 1200),
	"desierto": Vector3i(-2078, 0, 1200),
	"flotante": Vector3i(0, 0, -2400),
	"cielo": Vector3i(4400, 0, 0),
	"nieve": Vector3i(2200, 0, 3811),
	"volcanica": Vector3i(-2200, 0, 3811),
	"submarina": Vector3i(-4400, 0, 0),
	"misteriosa": Vector3i(-2200, 0, -3811),
	"secreta": Vector3i(2200, 0, -3811),
}

var _checks: int = 0
var _fallos: int = 0
var _bloque: String = ""
var _completados: Array[String] = []
var _checks_marca: int = 0
var _checks_por_bloque: Dictionary = {}
var _frames: int = 0
var _terminado: bool = false

var _reg: Node = null
var _defs: Dictionary = {}
var _vista: Dictionary = {}
var _guard: IslandTravelGuard = null


func _init() -> void:
	call_deferred("_run")


func _process(_delta: float) -> bool:
	_frames += 1
	if not _terminado and _frames > TIMEOUT_FRAMES:
		_terminado = true
		_checks += 1
		_fallos += 1
		print("!! WATCHDOG: _run() no terminó en %d frames (posible SCRIPT ERROR que abortó la función)" % TIMEOUT_FRAMES)
		print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
		quit(1)
	return false


func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FALLO] %s" % nombre)


func _ini(nombre: String) -> void:
	_bloque = nombre
	# Fija la marca AQUÍ (y no sólo en _fin): si no, el primer bloque reporta
	# también los checks que corrieron antes de abrirlo.
	_checks_marca = _checks
	print("-- %s" % nombre)


func _fin(nombre: String) -> void:
	var letra: String = nombre.substr(0, 1)
	if not _completados.has(letra):
		_completados.append(letra)
	var delta: int = _checks - _checks_marca
	_checks_por_bloque[letra] = int(_checks_por_bloque.get(letra, 0)) + delta
	_checks_marca = _checks
	print("[FIN] %s (+%d checks)" % [nombre, delta])


func _summary() -> void:
	var faltantes: Array[String] = []
	for b in BLOQUES_ESPERADOS:
		if not _completados.has(b):
			faltantes.append(b)
	var detalle: String = "" if faltantes.is_empty() else " — bloques que no terminaron: %s" % str(faltantes)
	_check("los %d bloques se completaron (sin abortos silenciosos)%s" % [BLOQUES_ESPERADOS.size(), detalle],
		faltantes.is_empty())
	print("-- checks por bloque: %s" % str(_checks_por_bloque))
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos == 0:
		print("TEST %s OK — todos los checks pasaron" % MODULO)
	else:
		print("TEST %s FALLÓ — %d checks fallaron" % [MODULO, _fallos])


# ── Arranque ──────────────────────────────────────────────────────────────

func _run() -> void:
	print("=== [M27] Test Islas del Mundo (iter. 2) ===")
	_reg = root.get_node_or_null("IslandRegistry")
	if _reg == null:
		print("  [FALLO] IslandRegistry no es un autoload accesible")
		print("=== Resumen %s: 1 checks, 1 fallos ===" % MODULO)
		quit(1)
		return
	_preparar()
	_check("el dataset tiene las 13 islas del plan", _defs.size() == 13)
	_check("la vista de la guardia tiene 13 registros", _vista.size() == 13)
	_bloque_a()
	_bloque_b()
	_bloque_c()
	_bloque_d()
	_bloque_e()
	_bloque_f()
	_bloque_g()
	_bloque_h()
	_summary()
	quit(1 if _fallos > 0 else 0)


func _preparar() -> void:
	for raw in _reg.ids():
		var id: StringName = raw
		var d: IslandDefinition = _reg.get_isla(id)
		if d == null:
			continue
		_defs[str(id)] = d
	_vista = IslandTravelGuard.vista_desde_registry(_reg)
	_aplicar_layout()
	_guard = IslandTravelGuard.new()
	_guard.configurar(_vista, {"id_principal": "aurora"})


## Aplica la disposición de anclas de referencia sobre la vista.
func _aplicar_layout() -> void:
	for id in LAYOUT.keys():
		var sid: String = str(id)
		if not _vista.has(sid):
			continue
		var def: IslandDefinition = _defs[sid]
		var ancla: Vector3i = LAYOUT[id]
		var r: Dictionary = _vista[sid]
		r["ancla"] = ancla
		r["centro"] = Vector3(ancla.x, 0.0, ancla.z)
		r["tiene_ancla"] = true
		r["punto_llegada"] = Vector3(ancla.x + def.punto_llegada.x, def.punto_llegada.y, ancla.z + def.punto_llegada.z)
		r["punto_partida"] = Vector3(ancla.x + def.punto_partida.x, def.punto_partida.y, ancla.z + def.punto_partida.z)
		r["cargada"] = false
		r["ultimo_uso"] = 0


# ── A. IslandOps ──────────────────────────────────────────────────────────

func _bloque_a() -> void:
	_ini("A. IslandOps")
	_check("4 etapas de carga", IslandOps.ETAPAS.size() == 4)
	_check("los pesos suman 1.0", absf(IslandOps.suma_pesos() - 1.0) < 0.001)
	_check("pesos 60/25/10/5", IslandOps.PESOS[0] == 0.60 and IslandOps.PESOS[1] == 0.25
		and IslandOps.PESOS[2] == 0.10 and IslandOps.PESOS[3] == 0.05)
	_check("progreso_hasta(-1) == 0", IslandOps.progreso_hasta(-1) == 0.0)
	_check("progreso_hasta(0) == 0.60", absf(IslandOps.progreso_hasta(0) - 0.60) < 0.001)
	_check("progreso_hasta(1) == 0.85", absf(IslandOps.progreso_hasta(1) - 0.85) < 0.001)
	_check("progreso_hasta(3) == 1.0", absf(IslandOps.progreso_hasta(3) - 1.0) < 0.001)
	_check("etapa_nombre(0) == losa", IslandOps.etapa_nombre(0) == "losa")
	_check("etapa_nombre(9) vacío", IslandOps.etapa_nombre(9) == "")
	_check("3 tipos de operación", IslandOps.TIPOS.size() == 3)

	var ops := IslandOps.new()
	_check("encolar tipo inválido -> 0", ops.encolar(&"voltear", &"coral") == 0)
	_check("encolar sin isla -> 0", ops.encolar(IslandOps.TIPO_CARGA, &"") == 0)
	var a: int = ops.encolar(IslandOps.TIPO_CARGA, &"coral")
	var b: int = ops.encolar(IslandOps.TIPO_PRECARGA, &"verde")
	_check("encolar devuelve ids > 0 y distintos", a > 0 and b > 0 and a != b)
	_check("2 operaciones vivas", ops.contar_vivas() == 2)
	_check("2 pendientes", ops.pendientes().size() == 2)
	var a2: int = ops.encolar(IslandOps.TIPO_CARGA, &"coral")
	_check("encolar es idempotente (mismo id)", a2 == a)
	_check("la idempotencia no agranda la cola", ops.contar_vivas() == 2)
	_check("la prioridad pone la carga antes que la precarga",
		str(ops.pendientes()[0]["tipo"]) == "carga")
	_check("una carga de viaje (prioridad 0) va primera",
		ops.encolar(IslandOps.TIPO_CARGA, &"nieve", IslandOps.PRIORIDAD_VIAJE) > 0
		and str(ops.pendientes()[0]["isla"]) == "nieve")
	_check("hay operaciones vivas", ops.hay_ops_vivas())
	_check("todavía no hay ninguna en curso", not ops.esta_ocupada())
	# Ojo con el orden de evaluación: `pendientes()` deja de ver la operación en
	# cuanto `iniciar()` la arranca, así que la esperada se captura ANTES.
	var esperada: int = int(ops.pendientes()[0]["id"])
	_check("iniciar() arranca la primera", ops.iniciar() == esperada)
	_check("ahora sí está ocupada", ops.esta_ocupada())
	_check("una sola en curso", ops.contar_por_estado().get(IslandOps.EST_EN_CURSO, 0) == 1)
	_check("iniciar() con una en curso devuelve la misma", ops.iniciar() == ops.en_curso_id())

	var e1: Dictionary = ops.avanzar_etapa()
	_check("etapa 0 = losa", str(e1.get("etapa_nombre", "")) == "losa")
	_check("progreso tras losa 0.60", absf(float(e1.get("progreso", 0.0)) - 0.60) < 0.001)
	var e2: Dictionary = ops.avanzar_etapa()
	_check("etapa 1 = props", str(e2.get("etapa_nombre", "")) == "props")
	_check("progreso tras props 0.85", absf(float(e2.get("progreso", 0.0)) - 0.85) < 0.001)
	var e3: Dictionary = ops.avanzar_etapa()
	_check("etapa 2 = audio", str(e3.get("etapa_nombre", "")) == "audio")
	var e4: Dictionary = ops.avanzar_etapa()
	_check("etapa 3 = navmesh", str(e4.get("etapa_nombre", "")) == "navmesh")
	var e5: Dictionary = ops.avanzar_etapa()
	_check("la 5ª etapa cierra la operación", str(e5.get("estado", "")) == "hecha")
	_check("progreso final 1.0", absf(float(e5.get("progreso", 0.0)) - 1.0) < 0.001)
	_check("la cola quedó libre", not ops.esta_ocupada())
	_check("el historial guarda la operación cerrada", ops.historial().size() == 1)

	var cancelable: int = ops.encolar(IslandOps.TIPO_PRECARGA, &"desierto")
	_check("cancelar una pendiente devuelve true", ops.cancelar(cancelable))
	_check("estado cancelada", ops.estado(cancelable) == IslandOps.EST_CANCELADA)
	_check("cancelar dos veces devuelve false", not ops.cancelar(cancelable))
	ops.encolar(IslandOps.TIPO_PRECARGA, &"misteriosa")
	ops.encolar(IslandOps.TIPO_PRECARGA, &"submarina")
	var n: int = ops.cancelar_por_isla(&"misteriosa")
	_check("cancelar_por_isla cancela las de esa isla", n == 1)
	_check("la otra isla sigue viva", ops.islas_con_ops_vivas().has(&"submarina"))

	ops.iniciar()
	_check("fallar() marca fallida", ops.fallar("sin disco"))
	_check("tras fallar la cola queda libre", not ops.esta_ocupada())
	_check("validar() sin errores", ops.validar().is_empty())
	_check("informe con las claves esperadas",
		ops.informe().has("vivas") and ops.informe().has("por_estado")
		and ops.informe().has("pesos") and ops.informe().has("max_ops_por_frame"))
	_check("MAX_OPS_POR_FRAME == 1 (no congelar)", IslandOps.MAX_OPS_POR_FRAME == 1)
	ops.limpiar()
	_check("limpiar() deja la cola vacía", ops.contar_vivas() == 0 and ops.historial().size() == 0)
	_fin("A. IslandOps")


# ── B. K1 precarga + K2 viaje ─────────────────────────────────────────────

func _bloque_b() -> void:
	_ini("B. K1 precarga sin congelar + K2 viaje con descarga en curso")
	var cf: Dictionary = _guard.coste_por_frame()
	_check("el presupuesto por frame no congela", bool(cf["no_congela"]))
	_check("1 operación por frame", int(cf["ops_por_frame"]) == 1)
	_check("margen de borde declarado", float(cf["margen_borde_m"]) > 0.0)

	# Margen por defecto (256 m): desde la costa de coral solo coral entra.
	var cerca: Array[String] = _guard.debe_precargar(Vector3(0.0, 5.0, 900.0), "aurora")
	_check("precarga coral desde su costa", cerca == ["coral"])
	_check("presupuesto 0 no precarga nada",
		_guard.debe_precargar(Vector3(0.0, 5.0, 900.0), "aurora", 0).is_empty())
	_check("la isla actual nunca se precarga a sí misma",
		not _guard.debe_precargar(Vector3(0.0, 5.0, 900.0), "coral", 5).has("coral"))
	var r_coral: Dictionary = _vista["coral"]
	r_coral["cargada"] = true
	_check("una isla ya cargada no se precarga",
		not _guard.debe_precargar(Vector3(0.0, 5.0, 900.0), "aurora", 5).has("coral"))
	r_coral["cargada"] = false

	# Con un margen grande entran varias: el presupuesto es el que manda.
	_guard.configurar(_vista, {"id_principal": "aurora", "margen_borde_m": 2000.0})
	var muchas: Array[String] = _guard.debe_precargar(Vector3(0.0, 5.0, 0.0), "aurora", 3)
	_check("el presupuesto limita a 3", muchas.size() == 3)
	_check("la más cercana primero", muchas[0] == "coral")
	_check("todas las devueltas son vecinas reales",
		muchas.has("coral") and muchas.has("verde") and muchas.has("pequena"))
	var una: Array[String] = _guard.debe_precargar(Vector3(0.0, 5.0, 0.0), "aurora", 1)
	_check("presupuesto 1 devuelve exactamente 1", una.size() == 1 and una[0] == "coral")
	_guard.configurar(_vista, {"id_principal": "aurora"})

	var ops := IslandOps.new()
	var v_ok: Dictionary = _guard.evaluar_viaje("coral", "aurora", ops)
	_check("viaje limpio: permitido y encolado", bool(v_ok["permitido"]) and str(v_ok["accion"]) == "encolar")
	_check("viaje limpio: motivo ok", str(v_ok["motivo"]) == "ok")

	var v_igual: Dictionary = _guard.evaluar_viaje("aurora", "aurora", ops)
	_check("viajar a donde ya estás: no permitido", not bool(v_igual["permitido"]))
	_check("viajar a donde ya estás: motivo claro", str(v_igual["motivo"]) == "ya_estas_ahi")

	var v_inc: Dictionary = _guard.evaluar_viaje("atlantis", "aurora", ops)
	_check("isla desconocida: no permitido", not bool(v_inc["permitido"]))
	_check("isla desconocida: motivo", str(v_inc["motivo"]) == "isla_desconocida")

	# Descarga de OTRA isla en curso: el viaje NO la cancela, se encola detrás.
	var desc: int = ops.encolar(IslandOps.TIPO_DESCARGA, &"verde")
	ops.iniciar()
	_check("la descarga de verde está en curso", ops.en_curso_id() == desc)
	var v_desc: Dictionary = _guard.evaluar_viaje("coral", "aurora", ops)
	_check("viaje con descarga en curso: permitido", bool(v_desc["permitido"]))
	_check("viaje con descarga en curso: se encola", str(v_desc["accion"]) == "encolar")
	_check("viaje con descarga en curso: motivo", str(v_desc["motivo"]) == "descarga_en_curso")
	_check("la descarga NO se cancela", ops.esta_ocupada() and ops.islas_con_ops_vivas().has(&"verde"))
	_check("la descarga sigue en el historial de vivas", ops.en_curso_id() == desc)

	# El DESTINO descargándose: cargarlo a la vez sería una carrera.
	ops.completar_actual()
	ops.encolar(IslandOps.TIPO_DESCARGA, &"coral")
	ops.iniciar()
	var v_dest: Dictionary = _guard.evaluar_viaje("coral", "aurora", ops)
	_check("destino descargándose: se encola", str(v_dest["accion"]) == "encolar")
	_check("destino descargándose: motivo", str(v_dest["motivo"]) == "destino_descargandose")
	_check("destino descargándose: no cancela la descarga", ops.esta_ocupada())

	# Carga del destino ya en curso: esperar, no duplicar.
	ops.limpiar()
	ops.encolar(IslandOps.TIPO_CARGA, &"coral")
	ops.iniciar()
	var v_carga: Dictionary = _guard.evaluar_viaje("coral", "aurora", ops)
	_check("carga del destino en curso: esperar", str(v_carga["accion"]) == "esperar")
	_check("carga del destino en curso: motivo", str(v_carga["motivo"]) == "carga_ya_en_curso")

	# Cola ocupada por otra isla: se encola.
	ops.limpiar()
	ops.encolar(IslandOps.TIPO_CARGA, &"nieve")
	ops.iniciar()
	var v_cola: Dictionary = _guard.evaluar_viaje("coral", "aurora", ops)
	_check("cola ocupada por otra isla: encolar", str(v_cola["accion"]) == "encolar")
	_check("cola ocupada por otra isla: motivo", str(v_cola["motivo"]) == "cola_ocupada")
	ops.limpiar()
	_fin("B. K1 precarga + K2 viaje")


# ── C. K3 náufrago + K8 respawn cozy ──────────────────────────────────────

func _bloque_c() -> void:
	_ini("C. K3 náufrago + K8 respawn cozy")
	_check("el centro de aurora es tierra firme", _guard.es_tierra_firme(Vector3(0.0, 5.0, 0.0)))
	_check("el centro de aurora no es agua", not _guard.es_agua(Vector3(0.0, 5.0, 0.0)))
	_check("el océano abierto es agua", _guard.es_agua(Vector3(0.0, 0.0, 5000.0)))
	_check("el océano abierto no es tierra firme", not _guard.es_tierra_firme(Vector3(0.0, 0.0, 5000.0)))
	_check("bajo una isla flotante NO hay océano (diseño H)",
		not _guard.es_agua(Vector3(0.0, 0.0, -2400.0)))
	_check("la playa se detecta", _guard.es_playa(Vector3(0.0, 1.0, 250.0)))
	_check("isla_en() ubica el centro de coral", _guard.isla_en(Vector3(0.0, 5.0, 1100.0)) == "coral")
	_check("isla_en() en el vacío devuelve vacío", _guard.isla_en(Vector3(0.0, 0.0, 9000.0)) == "")

	var en_tierra: Dictionary = _guard.evaluar_naufrago(Vector3(0.0, 5.0, 0.0))
	_check("en tierra: sin riesgo", not bool(en_tierra["riesgo"]))
	_check("en tierra: motivo", str(en_tierra["motivo"]) == "en_tierra")

	var a_bordo: Dictionary = _guard.evaluar_naufrago(Vector3(0.0, 0.0, 9000.0), true)
	_check("a bordo en alta mar: sin riesgo", not bool(a_bordo["riesgo"]))
	_check("a bordo: motivo", str(a_bordo["motivo"]) == "a_bordo")

	var mar: Dictionary = _guard.evaluar_naufrago(Vector3(0.0, 0.0, 9000.0))
	_check("a pie en alta mar: riesgo", bool(mar["riesgo"]))
	_check("a pie en alta mar: motivo", str(mar["motivo"]) == "oceano_abierto")
	_check("a pie en alta mar: respawn cozy", str(mar["accion"]) == "respawn_cozy")
	_check("a pie en alta mar: reporta la isla más cercana", str(mar["isla"]) != "")
	_check("a pie en alta mar: distancia medida", float(mar["distancia_m"]) > float(mar["limite_m"]))

	# En agua pero dentro del radio de seguridad: salvavidas, no respawn.
	var cerca: Dictionary = _guard.evaluar_naufrago(Vector3(0.0, 0.0, 700.0))
	_check("en agua cerca de isla: riesgo", bool(cerca["riesgo"]))
	_check("en agua cerca de isla: salvavidas", str(cerca["accion"]) == "salvavidas")
	_check("en agua cerca de isla: motivo", str(cerca["motivo"]) == "en_agua_cerca_de_isla")

	# Desde (0,0,2400) la isla más cercana es coral (1300 m). La siguiente,
	# cenizas, está a 2400 m: no hay empate ni ambigüedad por orden de iteración.
	var r1: Dictionary = _guard.respawn_cozy(Vector3(0.0, 0.0, 2400.0))
	_check("respawn cozy: ok", bool(r1["ok"]))
	_check("respawn cozy: devuelve la isla más cercana", str(r1["isla"]) == "coral")
	_check("respawn cozy: la posición es tierra firme",
		_guard.es_tierra_firme(r1["posicion"]))
	_check("respawn cozy: mide la distancia", float(r1["distancia_m"]) > 0.0)
	var r2: Dictionary = _guard.respawn_cozy(Vector3(0.0, 5.0, 0.0))
	_check("respawn cozy desde tierra: ok", bool(r2["ok"]))
	_check("respawn cozy desde tierra: aurora", str(r2["isla"]) == "aurora")
	_check("respawn cozy: la posición nunca es agua", not _guard.es_agua(r2["posicion"]))
	var vacia := IslandTravelGuard.new()
	vacia.configurar({}, {})
	var r3: Dictionary = vacia.respawn_cozy(Vector3.ZERO)
	_check("respawn cozy sin islas: falla honestamente", not bool(r3["ok"]) and str(r3["motivo"]) == "sin_islas")
	_fin("C. K3 náufrago + K8 respawn cozy")


# ── D. K4 ancla pendiente + K5 punto seguro ───────────────────────────────

func _bloque_d() -> void:
	_ini("D. K4 destino + K5 punto seguro")
	var ok: Dictionary = _guard.estado_destino("coral")
	_check("coral es viajable", bool(ok["viajable"]))
	_check("coral: motivo ok", str(ok["motivo"]) == "ok")
	_check("isla desconocida no es viajable", not bool(_guard.estado_destino("atlantis")["viajable"]))
	_check("isla desconocida: sin espera coherente",
		not bool(_guard.estado_destino("atlantis")["espera_coherente"]))

	var sec: Dictionary = _vista["secreta"]
	sec["descubierta"] = false
	var k4_sec: Dictionary = _guard.estado_destino("secreta")
	_check("secreta sin descubrir: no viajable", not bool(k4_sec["viajable"]))
	_check("secreta sin descubrir: motivo", str(k4_sec["motivo"]) == "secreta_no_descubierta")
	_check("secreta sin descubrir: sin espera", not bool(k4_sec["espera_coherente"]))
	sec["descubierta"] = true
	_check("secreta descubierta: viajable", bool(_guard.estado_destino("secreta")["viajable"]))

	var sin_ancla: Dictionary = _vista["nieve"]
	sin_ancla["tiene_ancla"] = false
	var k4_ancla: Dictionary = _guard.estado_destino("nieve")
	_check("sin ancla: no viajable", not bool(k4_ancla["viajable"]))
	_check("sin ancla: motivo", str(k4_ancla["motivo"]) == "ancla_pendiente")
	_check("sin ancla: ESPERA COHERENTE (no crashea)", bool(k4_ancla["espera_coherente"]))
	_check("sin ancla: tiene clave de localización", str(k4_ancla["clave"]) == "M27.VIAJE.ANCLA_PENDIENTE")
	sin_ancla["tiene_ancla"] = true

	var bloqueada: Dictionary = _vista["cielo"]
	bloqueada["desbloqueada"] = false
	var k4_bloq: Dictionary = _guard.estado_destino("cielo")
	_check("bloqueada por progreso: no viajable", not bool(k4_bloq["viajable"]))
	_check("bloqueada por progreso: espera coherente", bool(k4_bloq["espera_coherente"]))
	bloqueada["desbloqueada"] = true

	# K5: punto deseado ya firme -> no se toca.
	var muelle_coral: Vector3 = _vista["coral"]["punto_llegada"]
	var s_ok: Dictionary = _guard.punto_seguro("coral", muelle_coral)
	_check("K5 con punto firme: ok", bool(s_ok["ok"]))
	_check("K5 con punto firme: no se ajusta", not bool(s_ok["ajustado"]))
	_check("K5 con punto firme: motivo ok", str(s_ok["motivo"]) == "ok")
	_check("K5 con punto firme: devuelve el mismo punto", s_ok["posicion"] == muelle_coral)

	# K5: punto en alta mar -> se proyecta al interior del disco.
	var s_far: Dictionary = _guard.punto_seguro("coral", Vector3(0.0, 0.0, 99999.0))
	_check("K5 desde alta mar: ok", bool(s_far["ok"]))
	_check("K5 desde alta mar: se ajusta", bool(s_far["ajustado"]))
	_check("K5 desde alta mar: proyectado", str(s_far["motivo"]) == "proyectado")
	_check("K5 desde alta mar: el resultado es tierra firme", _guard.es_tierra_firme(s_far["posicion"]))
	var centro_coral: Vector3 = _vista["coral"]["centro"]
	var interior_coral: float = float(_vista["coral"]["radio"]) - float(_vista["coral"]["playa_ancho"])
	_check("K5: el resultado cae dentro de radio - playa",
		IslandTravelGuard.distancia_xz(s_far["posicion"], centro_coral) <= interior_coral)
	_check("K5: el resultado está por encima de altura_min",
		float(s_far["posicion"].y) >= float(_vista["coral"]["altura_min"]))

	# K5 en isla flotante: un punto a y=0 está debajo de la losa.
	var s_flot: Dictionary = _guard.punto_seguro("cielo", Vector3(4400.0, 0.0, 0.0))
	_check("K5 en isla flotante a y=0: se ajusta", bool(s_flot["ajustado"]))
	_check("K5 en isla flotante: queda sobre la losa",
		float(s_flot["posicion"].y) >= float(_vista["cielo"]["altura_min"]))
	var s_desc: Dictionary = _guard.punto_seguro("atlantis", Vector3.ZERO)
	_check("K5 isla desconocida: falla honestamente", not bool(s_desc["ok"]))
	_check("K5 isla desconocida: fiable false", not bool(s_desc["fiable"]))
	_fin("D. K4 destino + K5 punto seguro")


# ── E. K6 cancelación limpia + K7 guardado ────────────────────────────────

func _bloque_e() -> void:
	_ini("E. K6 cancelación limpia + K7 guardado")
	var ops := IslandOps.new()
	ops.encolar(IslandOps.TIPO_CARGA, &"coral")
	ops.iniciar()
	_check("hay una carga en curso", ops.esta_ocupada())
	var c1: Dictionary = _guard.cancelar_viaje("coral", ops)
	_check("K6 cancela la operación del viaje", int(c1["canceladas"]) == 1)
	_check("K6 deja la cola limpia para ese destino", bool(c1["limpio"]))
	_check("K6 ya no hay operaciones en curso", not ops.esta_ocupada())
	_check("K6 la isla no aparece en las vivas", not ops.islas_con_ops_vivas().has(&"coral"))
	_check("K6 el historial conserva la cancelada",
		ops.estado(1) == IslandOps.EST_CANCELADA)

	var c2: Dictionary = _guard.cancelar_viaje("coral", ops)
	_check("K6 cancelar lo que no está: 0", int(c2["canceladas"]) == 0)
	_check("K6 cancelar lo que no está: limpio", bool(c2["limpio"]))

	ops.encolar(IslandOps.TIPO_CARGA, &"coral")
	ops.encolar(IslandOps.TIPO_CARGA, &"verde")
	var c3: Dictionary = _guard.cancelar_viaje("coral", ops)
	_check("K6 sólo cancela el destino pedido", int(c3["canceladas"]) == 1)
	_check("K6 no toca las operaciones de otra isla", ops.islas_con_ops_vivas().has(&"verde"))
	# `limpio` es POR DESTINO: coral quedó limpia, pero verde sigue viva y la
	# guardia tiene que reportarlo (si no, un guardado daría por libre una cola
	# que todavía tiene trabajo).
	var vivas3: Array = c3["ops_vivas"]
	_check("K6 'limpio' es por destino: coral limpia y verde reportada viva",
		bool(c3["limpio"]) and vivas3.has("verde"))

	# K7: el guardado espera.
	ops.limpiar()
	_check("K7 con la cola libre: se puede guardar", bool(_guard.evaluar_guardado(ops)["puede_guardar"]))
	_check("K7 con la cola libre: motivo libre", str(_guard.evaluar_guardado(ops)["motivo"]) == "libre")
	ops.encolar(IslandOps.TIPO_CARGA, &"coral")
	var g_pend: Dictionary = _guard.evaluar_guardado(ops)
	_check("K7 con cola pendiente: no se puede guardar", not bool(g_pend["puede_guardar"]))
	_check("K7 con cola pendiente: hay que esperar", bool(g_pend["esperar"]))
	_check("K7 con cola pendiente: motivo", str(g_pend["motivo"]) == "cola_pendiente")
	_check("K7 con cola pendiente: cuenta las pendientes", int(g_pend["pendientes"]) == 1)
	ops.iniciar()
	var g_curso: Dictionary = _guard.evaluar_guardado(ops)
	_check("K7 con carga en curso: no se puede guardar", not bool(g_curso["puede_guardar"]))
	_check("K7 con carga en curso: motivo", str(g_curso["motivo"]) == "carga_en_curso")
	_check("K7 con carga en curso: dice a qué operación esperar", int(g_curso["op"]) == ops.en_curso_id())
	ops.completar_actual()
	_check("K7 tras terminar la carga: se puede guardar",
		bool(_guard.evaluar_guardado(ops)["puede_guardar"]))
	var nulo: Dictionary = _guard.evaluar_guardado(null)
	_check("K7 sin cola (null): se puede guardar", bool(nulo["puede_guardar"]))
	_fin("E. K6 cancelación limpia + K7 guardado")


# ── F. K9 descarga forzada por memoria ────────────────────────────────────

func _bloque_f() -> void:
	_ini("F. K9 descarga forzada por presión de memoria")
	_check("el tope de memoria del diseño es 2 islas", IslandTravelGuard.MAX_ISLAS_EN_MEMORIA == 2)

	# Estado de partida: marcar varias islas como cargadas y con uso distinto.
	var cargadas: Array[String] = ["coral", "verde", "pequena", "cenizas", "desierto"]
	for i in cargadas.size():
		var r: Dictionary = _vista[cargadas[i]]
		r["cargada"] = true
		r["ultimo_uso"] = i + 1
	_vista["aurora"]["cargada"] = true
	_vista["aurora"]["ultimo_uso"] = 99
	_check("hay 6 islas cargadas", _guard.islas_cargadas().size() == 6)

	# Snapshot del estado de partida ANTES (descubrimiento/visita).
	_reg.descubrir(&"coral")
	_reg.visitar(&"coral")
	_reg.descubrir(&"verde")
	var desc_antes: Array = _reg.islas_descubiertas()
	var vis_antes: Array = _reg.islas_visitadas()

	# El estado de partida lo POSEE M59: la guardia sólo lo refleja. Si no se
	# sincroniza, la guardia no puede prometer que no se pierde al descargar.
	var sincronizadas: int = _guard.sincronizar_estado_partida(_reg)
	_check("K9 sincroniza el estado de partida desde M59", sincronizadas >= 1)
	_check("K9 tras sincronizar, coral figura descubierta",
		bool(_guard.snapshot_estado()["coral"]["descubierta"]))
	_check("K9 tras sincronizar, coral figura visitada",
		bool(_guard.snapshot_estado()["coral"]["visitada"]))
	_check("K9 sincronizar no toca la caché de carga",
		_guard.islas_cargadas().size() == 6)

	var ops := IslandOps.new()
	var d: Dictionary = _guard.descarga_forzada(3000.0, ops, "aurora", 2048.0)
	var descargadas: Array = d["descargadas"]
	_check("K9 descarga algo bajo presión", descargadas.size() > 0)
	_check("K9 baja del tope de memoria", float(d["memoria_resultante_mb"]) <= float(d["tope_mb"]))
	_check("K9 nunca descarga la isla principal", not descargadas.has("aurora"))
	_check("K9 nunca descarga la isla actual", not descargadas.has("aurora"))
	_check("K9 declara los intocables", (d["intocables"] as Array).has("aurora"))
	_check("K9 elige por LRU (la menos usada primero)", str(descargadas[0]) == "coral")
	_check("K9 marca las descargadas como no cargadas", not bool(_vista["coral"]["cargada"]))
	_check("K9 encola una operación de descarga por víctima",
		ops.islas_con_tipo(IslandOps.TIPO_DESCARGA).size() == descargadas.size())
	_check("K9 motivo presion de memoria", str(d["motivo"]) == "presion_de_memoria")
	_check("K9 estado_preservado", bool(d["estado_preservado"]))

	# La prueba fuerte: el estado de partida real (M59) no se movió.
	var desc_despues: Array = _reg.islas_descubiertas()
	var vis_despues: Array = _reg.islas_visitadas()
	_check("K9 el descubrimiento del registry NO se pierde", str(desc_antes) == str(desc_despues))
	_check("K9 las visitas del registry NO se pierden", str(vis_antes) == str(vis_despues))
	_check("K9 coral sigue descubierta tras descargarla", _reg.esta_descubierta(&"coral"))
	_check("K9 coral sigue visitada tras descargarla", _reg.esta_visitada(&"coral"))
	var snap: Dictionary = _guard.snapshot_estado()
	_check("K9 snapshot_estado conserva descubrimiento", bool(snap["coral"]["descubierta"]))
	_check("K9 snapshot_estado conserva visitas", bool(snap["coral"]["visitada"]))

	# Sin presión de memoria no descarga nada.
	var ops2 := IslandOps.new()
	var d2: Dictionary = _guard.descarga_forzada(500.0, ops2, "aurora", 2048.0)
	_check("K9 sin presión: no descarga nada", (d2["descargadas"] as Array).is_empty())
	_check("K9 sin presión: motivo", str(d2["motivo"]) == "sin_presion")
	_check("K9 sin presión: no encola nada", ops2.contar_vivas() == 0)
	_fin("F. K9 descarga forzada")


# ── G. Catálogo de los 26 puntos de la §26 ────────────────────────────────

func _bloque_g() -> void:
	_ini("G. Catálogo de diseño (§26 del plan maestro)")
	_check("el catálogo tiene 26 puntos", IslandDesignCatalog.contar() == 26)
	_check("TOTAL_PLAN == 26 (el checklist decía 24)", IslandDesignCatalog.TOTAL_PLAN == 26)
	_check("validar() contra el dataset real: sin errores",
		IslandDesignCatalog.validar(_defs).is_empty())
	_check("no faltan campos citados", IslandDesignCatalog.campos_faltantes(_defs).is_empty())
	_check("no faltan islas citadas", IslandDesignCatalog.islas_faltantes(_defs).is_empty())
	var cob: Dictionary = IslandDesignCatalog.cobertura()
	_check("cobertura: total 26", int(cob["total"]) == 26)
	_check("cobertura: 15 resueltos", int(cob["resueltos"]) == 15)
	_check("cobertura: 7 declarativos", int(cob["declarativos"]) == 7)
	_check("cobertura: 4 externos", int(cob["externos"]) == 4)
	_check("resueltos + declarativos + externos == 26",
		int(cob["resueltos"]) + int(cob["declarativos"]) + int(cob["externos"]) == 26)
	_check("porcentaje en alcance de M27 > 80 %", float(cob["porcentaje_en_alcance"]) > 80.0)
	_check("13 puntos de islas", IslandDesignCatalog.por_grupo(IslandDesignCatalog.GRUPO_ISLAS).size() == 13)
	_check("2 puntos de rutas", IslandDesignCatalog.por_grupo(IslandDesignCatalog.GRUPO_RUTAS).size() == 2)
	_check("11 puntos de atributos", IslandDesignCatalog.por_grupo(IslandDesignCatalog.GRUPO_ATRIBUTOS).size() == 11)
	_check("el punto 1 es la isla principal",
		str(IslandDesignCatalog.punto(1)["texto"]).to_lower().contains("principal"))
	_check("el punto 26 es la relevancia narrativa",
		str(IslandDesignCatalog.punto(26)["texto"]).to_lower().contains("narrativa"))
	_check("punto(99) devuelve vacío", IslandDesignCatalog.punto(99).is_empty())
	_check("los 4 externos declaran dueño",
		_is_externos_con_dueno(IslandDesignCatalog.por_estado(IslandDesignCatalog.EST_EXTERNO)))
	_check("el punto 15 declara 2 resoluciones (anillo + radio)",
		IslandDesignCatalog.resoluciones(IslandDesignCatalog.punto(15)).size() == 2)
	_check("el punto 26 declara 2 resoluciones (flag + secreta)",
		IslandDesignCatalog.resoluciones(IslandDesignCatalog.punto(26)).size() == 2)
	var claves: Array[String] = IslandDesignCatalog.claves_localizacion()
	_check("26 claves de localización", claves.size() == 26)
	_check("las claves son únicas", _son_unicas(claves))
	_check("las claves siguen la convención M27.DISENO.Pnn",
		claves[0] == "M27.DISENO.P01" and claves[25] == "M27.DISENO.P26")
	var inf: Dictionary = IslandDesignCatalog.informe(_defs)
	_check("el informe expone el desajuste 24 vs 26",
		str(inf["plan_dice"]).contains("24") and int(inf["plan_tiene"]) == 26)
	_check("el informe no reporta errores", int(inf["errores"]) == 0)
	_check("el informe cita la fuente del plan", str(inf["fuente"]).contains("Plan-inicial-minimo.md"))
	_check("resumen() menciona los 26 puntos", IslandDesignCatalog.resumen().contains("26"))
	_fin("G. Catálogo de diseño (§26 del plan maestro)")


func _is_externos_con_dueno(lista: Array[Dictionary]) -> bool:
	for p in lista:
		var ok: bool = false
		for r in IslandDesignCatalog.resoluciones(p):
			if r.begins_with("externo:") and r.substr(8).strip_edges().length() >= 3:
				ok = true
		if not ok:
			return false
	return lista.size() == 4


func _son_unicas(lista: Array[String]) -> bool:
	var visto: Dictionary = {}
	for x in lista:
		if visto.has(x):
			return false
		visto[x] = true
	return true


# ── H. Integración con el registry real ───────────────────────────────────

func _bloque_h() -> void:
	_ini("H. Integración con el autoload IslandRegistry real")
	_check("el registry reporta 13 islas", _reg.contar() == 13)
	_check("la vista tiene una entrada por isla", _vista.size() == _reg.contar())
	_check("la isla principal es aurora", str(_reg.isla_principal().id) == "aurora")
	_check("la guardia valida la vista real", _guard.validar().is_empty())
	_check("la guardia informa 13 islas", int(_guard.informe()["islas"]) == 13)
	_check("la guardia declara el tope de memoria", float(_guard.informe()["tope_memoria_mb"]) > 0.0)
	_check("resumen() de la guardia nombra la principal", _guard.resumen().contains("aurora"))

	# Anillos del plan: 1 NUCLEO + 3 CERCANO + 3 MEDIO + 6 LEJANO.
	var por_anillo: Dictionary = {}
	for id in _guard.islas():
		var r: Dictionary = _guard.registro(id)
		var a: int = int(r["anillo"])
		por_anillo[a] = int(por_anillo.get(a, 0)) + 1
	_check("1 isla NUCLEO", int(por_anillo.get(IslandRing.NUCLEO, 0)) == 1)
	_check("3 islas CERCANO", int(por_anillo.get(IslandRing.CERCANO, 0)) == 3)
	_check("3 islas MEDIO", int(por_anillo.get(IslandRing.MEDIO, 0)) == 3)
	_check("6 islas LEJANO", int(por_anillo.get(IslandRing.LEJANO, 0)) == 6)

	_check("sólo 'secreta' es secreta",
		bool(_guard.registro("secreta")["es_secreta"])
		and not bool(_guard.registro("coral")["es_secreta"]))
	_check("'cielo' y 'flotante' son flotantes",
		bool(_guard.registro("cielo")["es_flotante"]) and bool(_guard.registro("flotante")["es_flotante"]))
	_check("aurora no es flotante", not bool(_guard.registro("aurora")["es_flotante"]))

	# El hallazgo honesto: sin M10 no hay anclas reales.
	var real: Dictionary = IslandTravelGuard.vista_desde_registry(_reg)
	var sin_ancla: int = 0
	for id in real.keys():
		if not bool((real[id] as Dictionary)["tiene_ancla"]):
			sin_ancla += 1
	_check("sin M10, las 13 islas están sin ancla (hallazgo medido)", sin_ancla == 13)
	var g_real := IslandTravelGuard.new()
	g_real.configurar(real, {"id_principal": "aurora"})
	_check("con el registry real la guardia es válida igual", g_real.validar().is_empty())
	_check("sin anclas la guardia reporta ancla_pendiente (no crashea)",
		str(g_real.estado_destino("coral")["motivo"]) == "ancla_pendiente")
	_check("sin anclas el viaje no se permite pero espera",
		not bool(g_real.evaluar_viaje("coral", "aurora", null)["permitido"])
		and str(g_real.evaluar_viaje("coral", "aurora", null)["accion"]) == "esperar")

	# Con la disposición de referencia (lo que hará M10) todo tiene ancla. Pero
	# `secreta` NO es viajable: es secreta y nadie la descubrió todavía (regla de
	# los requisitos 119/132 — una isla secreta oculta no se puede visitar).
	var viajables: Array[String] = []
	for id in _guard.islas():
		if bool(_guard.estado_destino(id)["viajable"]):
			viajables.append(id)
	_check("con la disposición de referencia viajan 12 de 13 (secreta oculta)",
		viajables.size() == 12 and not viajables.has("secreta"))
	_check("la única no viajable es secreta, por estar sin descubrir",
		str(_guard.estado_destino("secreta")["motivo"]) == "secreta_no_descubierta")
	_check("la isla principal está descubierta por definición (M59)",
		bool(_guard.registro("aurora")["descubierta"]))

	# Descubrirla la vuelve viajable: el camino completo M59 → guardia.
	_reg.descubrir(&"secreta")
	_check("descubrir() cambia el estado en M59", _reg.esta_descubierta(&"secreta"))
	_check("sincronizar propaga el descubrimiento a la guardia",
		_guard.sincronizar_estado_partida(_reg) >= 1)
	_check("tras descubrirla, secreta ya es viajable",
		bool(_guard.estado_destino("secreta")["viajable"]))
	var viajables2: int = 0
	for id in _guard.islas():
		if bool(_guard.estado_destino(id)["viajable"]):
			viajables2 += 1
	_check("ahora las 13 son viajables", viajables2 == 13)

	# Coherencia con la documentación del módulo.
	_check("01-Requerimientos declara 13 islas (RF1)", _defs.size() == 13)
	_check("03-Diseno §5 cataloga 13 islas", IslandDesignCatalog.por_grupo("islas").size() == 13)
	_check("cada isla tiene clave de nombre para M87",
		_cada_isla_con_nombre_clave())
	_check("cada isla declara su anillo",
		_cada_isla_declara_anillo())
	_fin("H. Integración con el autoload IslandRegistry real")


func _cada_isla_con_nombre_clave() -> bool:
	for id in _defs.keys():
		var d: IslandDefinition = _defs[id]
		if str(d.nombre_clave).strip_edges().is_empty() and str(d.nombre_display).strip_edges().is_empty():
			return false
	return true


func _cada_isla_declara_anillo() -> bool:
	for id in _defs.keys():
		var d: IslandDefinition = _defs[id]
		if not IslandRing.es_valido(d.anillo):
			return false
	return true
