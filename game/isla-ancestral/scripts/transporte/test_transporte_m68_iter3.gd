# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-04
#
# M68 iter. 3 — Test headless de Transporte y Navegación (secciones J y T).
#
#   A. Waypoints de camino   de_camino: orden, fracciones, distancias (J)
#   B. Waypoints de plan     de_plan + validar + es_larga + avance (J)
#   C. Manager               waypoints_de_ruta / es_ruta_larga reales (J)
#   D. Contexto de viaje     diálogo bloquea (M21); inventario NO bloquea (T)
#   E. Edge: dinero justo    compra con el saldo exacto (T)
#   F. Edge: última hora     apertura/cierre del horario (T)
#   G. Edge: desbloqueo+clima parada recién desbloqueada + clima (T)
#   H. Integridad            el grafo y la compra siguen sanos (regresión)
#
# Determinista: hooks `forzar_contexto` / `forzar_cartera` / `forzar_contexto_viaje`.
#
# ⚠️ Guardia anti-falso-verde (3 capas, trampas 11/63/122):
#   1) cada bloque cierra con `_fin(letra)`; si aborta en silencio (M124) la letra
#      falta y `_summary()` FALLA;
#   2) piso `CHECKS_MINIMOS` MEDIDO en verde: un aborto parcial baja el conteo;
#   3) `_summary()` en un `call_deferred` SEPARADO (si `_run()` aborta, igual corre).
#   Watchdog por temporizador: si la suite no termina, cierra con código 1.
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/transporte/test_transporte_m68_iter3.gd
# Exit code != 0 si algún check falla, si falta un bloque o si salta el watchdog.

extends SceneTree

const TIMEOUT_SEG := 90.0
## Piso de checks MEDIDO en verde (no estimado): un aborto parcial baja el conteo.
const CHECKS_MINIMOS := 108
const BLOQUES_ESPERADOS: Array[String] = ["A", "B", "C", "D", "E", "F", "G", "H"]

var _fallos: int = 0
var _checks: int = 0
var _bloque: String = "(inicio)"
var _abortado: bool = false
var _completados: Array[String] = []
var _checks_por_bloque: Dictionary = {}
var _checks_marca: int = 0
var TM: Node = null
var RED: TransportNetwork = null


func _init() -> void:
	call_deferred("_run")
	# `_summary()` en la cola diferida: si `_run()` muere por un SCRIPT ERROR,
	# la cola sigue y el resumen CORRE igual (nombra los bloques faltantes).
	call_deferred("_summary")


func _run() -> void:
	create_timer(TIMEOUT_SEG, true).timeout.connect(_on_watchdog)
	print("=== [M68 iter.3] Transporte y Navegación — secciones J (waypoints) y T (edge cases) ===")
	TM = root.get_node_or_null("TransportManager")
	if TM == null:
		_check("autoload TransportManager presente", false, "(ausente)")
		return
	var r: Variant = TM.call("red")
	if r is TransportNetwork:
		RED = r
	_check("autoload TransportManager presente", true)
	_check("red de transporte cargada", RED != null)
	if RED == null:
		return

	_bloque_a_camino()
	_bloque_b_plan()
	_bloque_c_manager()
	_bloque_d_contexto()
	_bloque_e_dinero_justo()
	_bloque_f_horario()
	_bloque_g_desbloqueo_clima()
	_bloque_h_integridad()


func _on_watchdog() -> void:
	_abortado = true
	print("[M68-3] WATCHDOG: la suite no terminó en %.0f s — ABORTO (último bloque: %s)" % [TIMEOUT_SEG, _bloque])
	quit(1)


## ── Helpers ─────────────────────────────────────────────

func _ini(nombre: String) -> void:
	_bloque = nombre
	_checks_marca = _checks
	print("\n-- %s --" % nombre)


func _fin(nombre: String) -> void:
	var letra: String = nombre.substr(0, 1)
	if not _completados.has(letra):
		_completados.append(letra)
	var delta: int = _checks - _checks_marca
	_checks_por_bloque[letra] = int(_checks_por_bloque.get(letra, 0)) + delta
	_checks_marca = _checks
	print("[FIN] %s (+%d checks)" % [nombre, delta])


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])


func _reset() -> void:
	# Restablece el estado del autoload entre bloques (sin tocar la red).
	TM.call("restore_save_data", {})
	TM.call("forzar_contexto", 12, 0, "primavera", 0)
	TM.call("forzar_cartera", -1)
	TM.call("limpiar_contexto_viaje")
	TM.call("forzar_fecha")


func _summary() -> void:
	# Capa 1: bloques que no cerraron (aborto silencioso M124).
	var faltantes: Array[String] = []
	for letra in BLOQUES_ESPERADOS:
		if not _completados.has(letra):
			faltantes.append(letra)
	_check("los 8 bloques se completaron (sin abortos silenciosos)", faltantes.is_empty(),
		"bloques que no terminaron: %s" % str(faltantes))
	# Capa 2: piso de checks medido en verde.
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("  [FAIL] solo %d checks ejecutados (mínimo %d)" % [_checks, CHECKS_MINIMOS])
	print("Checks por bloque: %s" % str(_checks_por_bloque))
	print("\n=== Resumen M68 iter.3: %d checks, %d fallos ===" % [_checks, _fallos])
	if _abortado:
		print("TEST M68 iter.3 ABORTADO por watchdog")
		quit(1)
	elif _fallos == 0:
		print("TEST M68 iter.3 OK — todos los checks pasaron")
		quit(0)
	else:
		print("TEST M68 iter.3 FALLÓ — %d checks fallaron" % _fallos)
		quit(1)


## ── A. Waypoints de camino (J) ───────────────────────────

func _bloque_a_camino() -> void:
	_ini("A. Waypoints de camino")
	# Camino real de 3 paradas: aurora(0,0,0) -> plataforma(0,60,-30) -> norte(0,0,-200).
	var wps: Array[Dictionary] = TransportRouteWaypoints.de_camino(
		["puerto_aurora", "plataforma_norte", "puerto_norte"], RED)
	_check("3 waypoints para un camino de 3 paradas", wps.size() == 3, "n=%d" % wps.size())
	if wps.size() == 3:
		_check("wp0 = puerto_aurora", String(wps[0]["stop_id"]) == "puerto_aurora")
		_check("wp1 = plataforma_norte", String(wps[1]["stop_id"]) == "plataforma_norte")
		_check("wp2 = puerto_norte", String(wps[2]["stop_id"]) == "puerto_norte")
		_check("índices 0,1,2", int(wps[0]["indice"]) == 0 and int(wps[1]["indice"]) == 1 and int(wps[2]["indice"]) == 2)
		_check("el primero tiene fracción 0.0", is_equal_approx(float(wps[0]["fraccion"]), 0.0))
		_check("el último tiene fracción 1.0", is_equal_approx(float(wps[2]["fraccion"]), 1.0))
		_check("sólo el último es destino",
			not bool(wps[0]["es_destino"]) and not bool(wps[1]["es_destino"]) and bool(wps[2]["es_destino"]))
		# Distancias XZ: 30 (aurora->plataforma) + 170 (plataforma->norte) = 200.
		_check("tramo 0 = 30 m", is_equal_approx(float(wps[1]["tramo_m"]), 30.0), str(wps[1]["tramo_m"]))
		_check("tramo 1 = 170 m", is_equal_approx(float(wps[2]["tramo_m"]), 170.0), str(wps[2]["tramo_m"]))
		_check("acumulado del último = 200 m", is_equal_approx(float(wps[2]["acumulado_m"]), 200.0), str(wps[2]["acumulado_m"]))
		_check("fracción intermedia = 30/200 = 0.15", is_equal_approx(float(wps[1]["fraccion"]), 0.15), str(wps[1]["fraccion"]))
		_check("validar() sin errores", TransportRouteWaypoints.validar(wps).is_empty(),
			str(TransportRouteWaypoints.validar(wps)))
	# Camino degenerado (1 parada): 1 waypoint, sin exigir fracción 1.0.
	var uno: Array[Dictionary] = TransportRouteWaypoints.de_camino(["puerto_aurora"], RED)
	_check("camino de 1 parada -> 1 waypoint", uno.size() == 1)
	_check("camino degenerado válido", TransportRouteWaypoints.validar(uno).is_empty(),
		str(TransportRouteWaypoints.validar(uno)))
	# Ids inexistentes se omiten; ninguno resoluble -> [].
	var mezcla: Array[Dictionary] = TransportRouteWaypoints.de_camino(["puerto_aurora", "no_existe", "muelle_raiz_sur"], RED)
	_check("ids inexistentes se omiten", mezcla.size() == 2, "n=%d" % mezcla.size())
	_check("lista vacía -> []", TransportRouteWaypoints.de_camino([], RED).is_empty())
	_check("red nula -> []", TransportRouteWaypoints.de_camino(["puerto_aurora"], null).is_empty())
	_fin("A. waypoints de camino")


## ── B. Waypoints de plan (J) ─────────────────────────────

func _bloque_b_plan() -> void:
	_ini("B. Waypoints de plan")
	# aurora -> norte: 2 saltos por la plataforma (120 AO).
	var plan_largo: Dictionary = RED.ruta_mas_barata(&"puerto_aurora", &"puerto_norte")
	_check("plan aurora->norte ok", bool(plan_largo.get("ok", false)))
	_check("plan aurora->norte = 2 saltos", int(plan_largo.get("saltos", -1)) == 2)
	_check("plan_es_largo(2 saltos)", TransportRouteWaypoints.plan_es_largo(plan_largo))
	var wp_largo: Dictionary = TransportRouteWaypoints.de_plan(plan_largo, RED)
	_check("de_plan ok", bool(wp_largo.get("ok", false)))
	_check("de_plan: es_larga true", bool(wp_largo.get("es_larga", false)))
	_check("de_plan: 3 waypoints", (wp_largo.get("waypoints", []) as Array).size() == 3)
	_check("de_plan: distancia 200 m", is_equal_approx(float(wp_largo.get("distancia_total_m", 0.0)), 200.0),
		str(wp_largo.get("distancia_total_m")))
	_check("de_plan: radio de llegada declarado", is_equal_approx(float(wp_largo.get("radio_llegada", 0.0)), TransportRouteWaypoints.RADIO_LLEGADA))
	# aurora -> sur: 2 saltos (68 AO, combinado gana al directo de 80).
	var plan_sur: Dictionary = RED.ruta_mas_barata(&"puerto_aurora", &"puerto_sur")
	_check("plan aurora->sur ok", bool(plan_sur.get("ok", false)))
	_check("plan aurora->sur = 2 saltos", int(plan_sur.get("saltos", -1)) == 2)
	var wp_sur: Dictionary = TransportRouteWaypoints.de_plan(plan_sur, RED)
	_check("de_plan aurora->sur es_larga", bool(wp_sur.get("es_larga", false)))
	_check("de_plan aurora->sur: 180 m", is_equal_approx(float(wp_sur.get("distancia_total_m", 0.0)), 180.0),
		str(wp_sur.get("distancia_total_m")))
	# Ruta corta (1 salto): NO es larga.
	var plan_corto: Dictionary = RED.ruta_mas_barata(&"puerto_aurora", &"muelle_raiz_sur")
	_check("plan corto = 1 salto", int(plan_corto.get("saltos", -1)) == 1)
	_check("plan corto NO es largo", not TransportRouteWaypoints.plan_es_largo(plan_corto))
	var wp_corto: Dictionary = TransportRouteWaypoints.de_plan(plan_corto, RED)
	_check("de_plan corto: es_larga false", not bool(wp_corto.get("es_larga", false)))
	_check("de_plan corto: 2 waypoints", (wp_corto.get("waypoints", []) as Array).size() == 2)
	# Plan fallido -> de_plan falla con motivo.
	var wp_falla: Dictionary = TransportRouteWaypoints.de_plan({"ok": false, "motivo": "sin camino"}, RED)
	_check("plan fallido -> de_plan ok=false", not bool(wp_falla.get("ok", true)))
	_check("plan fallido -> motivo conservado", String(wp_falla.get("motivo", "")) == "sin camino")
	_check("plan fallido -> sin waypoints", (wp_falla.get("waypoints", []) as Array).is_empty())
	# validar() detecta corrupción.
	var corrupto: Array[Dictionary] = (wp_largo.get("waypoints", []) as Array).duplicate(true)
	if corrupto.size() == 3:
		corrupto[2]["fraccion"] = 0.4
		_check("validar detecta fracción no monótona", not TransportRouteWaypoints.validar(corrupto).is_empty())
	var sin_destino: Array[Dictionary] = (wp_largo.get("waypoints", []) as Array).duplicate(true)
	if sin_destino.size() == 3:
		sin_destino[2]["es_destino"] = false
		_check("validar detecta último sin destino", not TransportRouteWaypoints.validar(sin_destino).is_empty())
	_check("validar lista vacía -> error", not TransportRouteWaypoints.validar([]).is_empty())
	# indice_mas_cercano / avance_en.
	var wps: Array = wp_largo.get("waypoints", [])
	_check("más cercano a la plataforma = índice 1", TransportRouteWaypoints.indice_mas_cercano(wps, Vector3(0, 60, -30)) == 1)
	_check("más cercano al norte = índice 2", TransportRouteWaypoints.indice_mas_cercano(wps, Vector3(0, 0, -190)) == 2)
	_check("avance en la plataforma = 0.15", is_equal_approx(TransportRouteWaypoints.avance_en(wps, Vector3(0, 60, -30)), 0.15))
	_check("avance en el destino = 1.0", is_equal_approx(TransportRouteWaypoints.avance_en(wps, Vector3(0, 0, -200)), 1.0))
	_check("avance con lista vacía = 0.0", is_equal_approx(TransportRouteWaypoints.avance_en([], Vector3.ZERO), 0.0))
	# resumen().
	var res: Dictionary = TransportRouteWaypoints.resumen(wps)
	_check("resumen: n=3", int(res.get("n", 0)) == 3)
	_check("resumen: primer/último", String(res.get("primer", "")) == "puerto_aurora" and String(res.get("ultimo", "")) == "puerto_norte")
	_fin("B. waypoints de plan")


## ── C. Manager (J) ───────────────────────────────────────

func _bloque_c_manager() -> void:
	_ini("C. Manager: waypoints de ruta")
	_reset()
	var w: Dictionary = TM.call("waypoints_de_ruta", &"puerto_aurora", &"puerto_norte")
	_check("waypoints_de_ruta ok", bool(w.get("ok", false)), str(w.get("motivo", "")))
	_check("waypoints_de_ruta es_larga", bool(w.get("es_larga", false)))
	_check("waypoints_de_ruta: 3 puntos", (w.get("waypoints", []) as Array).size() == 3)
	_check("es_ruta_larga(aurora,norte) = true", bool(TM.call("es_ruta_larga", &"puerto_aurora", &"puerto_norte")))
	_check("es_ruta_larga(aurora,muelle) = false", not bool(TM.call("es_ruta_larga", &"puerto_aurora", &"muelle_raiz_sur")))
	# Coherencia con planificar().
	var plan: Dictionary = TM.call("planificar", &"puerto_aurora", &"puerto_norte")
	var w2: Dictionary = TransportRouteWaypoints.de_plan(plan, RED)
	_check("manager y modelo coinciden en distancia",
		is_equal_approx(float(w.get("distancia_total_m", -1.0)), float(w2.get("distancia_total_m", -2.0))))
	# Ruta sin camino -> de_plan falla honestamente.
	var sin: Dictionary = TM.call("waypoints_de_ruta", &"puerto_aurora", &"puerto_brisa")
	_check("ruta bloqueada -> waypoints no ok", not bool(sin.get("ok", true)))
	_check("ruta bloqueada -> motivo reportado", not String(sin.get("motivo", "")).is_empty())
	_fin("C. manager waypoints")


## ── D. Contexto de viaje (T) ─────────────────────────────

func _bloque_d_contexto() -> void:
	_ini("D. Contexto de viaje (diálogo / inventario)")
	_reset()
	var base: Dictionary = TM.call("contexto_de_viaje")
	_check("sin diálogo ni inventario lleno: no bloqueado", not bool(base.get("bloqueado", true)))
	_check("base: en_dialogo false", not bool(base.get("en_dialogo", true)))
	_check("base: inventario_lleno false", not bool(base.get("inventario_lleno", true)))
	# Diálogo activo -> bloquea.
	TM.call("forzar_contexto_viaje", true, false)
	var dia: Dictionary = TM.call("contexto_de_viaje")
	_check("diálogo: bloqueado", bool(dia.get("bloqueado", false)))
	_check("diálogo: motivo 'en diálogo (M21)'", String(dia.get("motivo", "")) == "en diálogo (M21)")
	_check("diálogo: en_dialogo true", bool(dia.get("en_dialogo", false)))
	# Inventario lleno -> REPORTA pero NO bloquea (decisión documentada).
	TM.call("forzar_contexto_viaje", false, true)
	var lleno: Dictionary = TM.call("contexto_de_viaje")
	_check("inventario lleno: NO bloqueado", not bool(lleno.get("bloqueado", true)))
	_check("inventario lleno: inventario_lleno true", bool(lleno.get("inventario_lleno", false)))
	_check("inventario lleno: motivo vacío", String(lleno.get("motivo", "x")).is_empty())
	# buy_ticket respeta el gate.
	TM.call("forzar_contexto_viaje", true, false)
	var res_dia: Dictionary = TM.call("buy_ticket", &"r_aurora_muelle", &"puerto_aurora")
	_check("buy_ticket con diálogo falla", not bool(res_dia.get("ok", true)))
	_check("buy_ticket con diálogo: motivo del contexto", String(res_dia.get("motivo", "")).contains("diálogo"),
		String(res_dia.get("motivo", "")))
	TM.call("forzar_contexto_viaje", false, true)
	TM.call("forzar_cartera", 50)
	var res_inv: Dictionary = TM.call("buy_ticket", &"r_aurora_muelle", &"puerto_aurora")
	_check("buy_ticket con inventario lleno SÍ compra (no bloquea)", bool(res_inv.get("ok", false)),
		String(res_inv.get("motivo", "")))
	TM.call("notificar_llegada")
	# Sin contexto -> compra normal.
	TM.call("limpiar_contexto_viaje")
	TM.call("forzar_cartera", 50)
	var res_ok: Dictionary = TM.call("buy_ticket", &"r_aurora_muelle", &"puerto_aurora")
	_check("sin contexto: compra OK", bool(res_ok.get("ok", false)))
	TM.call("notificar_llegada")
	# Duck-typing real: DialogueManager presente pero inactivo -> no bloquea.
	var dm := root.get_node_or_null("DialogueManager")
	_check("DialogueManager (M21) presente para el duck-typing", dm != null)
	if dm != null and dm.has_method("is_dialogue_active"):
		_check("M21 inactivo en headless -> no bloquea", not bool(TM.call("contexto_de_viaje").get("bloqueado", true)))
	_fin("D. contexto de viaje")


## ── E. Edge: dinero justo (T) ────────────────────────────

func _bloque_e_dinero_justo() -> void:
	_ini("E. Edge: dinero justo")
	_reset()
	var ruta: TransportRoute = RED.ruta(&"r_aurora_muelle")
	_check("ruta r_aurora_muelle existe", ruta != null)
	if ruta == null:
		_fin("E. dinero justo")
		return
	var precio: int = ruta.coste_con_descuento(0)
	# Saldo EXACTO: compra y queda en 0.
	TM.call("forzar_cartera", precio)
	var exacto: Dictionary = TM.call("buy_ticket", &"r_aurora_muelle", &"puerto_aurora")
	_check("saldo exacto: compra OK", bool(exacto.get("ok", false)), String(exacto.get("motivo", "")))
	_check("saldo exacto: precio cobrado = %d" % precio, int(exacto.get("precio", -1)) == precio)
	_check("saldo exacto: queda en 0", int(TM.call("saldo_simulado")) == 0, str(TM.call("saldo_simulado")))
	TM.call("notificar_llegada")
	# Un AO menos: falla y NO cobra.
	TM.call("forzar_cartera", precio - 1)
	var corto: Dictionary = TM.call("buy_ticket", &"r_aurora_muelle", &"puerto_aurora")
	_check("un AO menos: no compra", not bool(corto.get("ok", true)))
	_check("un AO menos: motivo AO insuficiente", String(corto.get("motivo", "")).contains("AO insuficiente"),
		String(corto.get("motivo", "")))
	_check("un AO menos: saldo intacto", int(TM.call("saldo_simulado")) == precio - 1)
	# Ruta cara (80 AO) con saldo exacto.
	TM.call("forzar_cartera", 80)
	var cara: Dictionary = TM.call("buy_ticket", &"r_aurora_sur", &"puerto_aurora")
	_check("ruta de 80 AO con saldo exacto: compra", bool(cara.get("ok", false)), String(cara.get("motivo", "")))
	_check("ruta cara: queda en 0", int(TM.call("saldo_simulado")) == 0)
	TM.call("notificar_llegada")
	_fin("E. dinero justo")


## ── F. Edge: última hora de horario (T) ──────────────────

func _bloque_f_horario() -> void:
	_ini("F. Edge: última hora de horario")
	_reset()
	# El destino muelle_raiz_sur abre 06:00 y cierra 22:00 (h < 22).
	var casos: Array = [
		[21, true, "21:00 (última hora abierta)"],
		[22, false, "22:00 (justo al cerrar)"],
		[6, true, "06:00 (justo al abrir)"],
		[5, false, "05:00 (antes de abrir)"],
	]
	for caso in casos:
		var c: Array = caso
		TM.call("forzar_contexto", int(c[0]), 0, "primavera", 0)
		TM.call("forzar_cartera", 50)
		var res: Dictionary = TM.call("buy_ticket", &"r_aurora_muelle", &"puerto_aurora")
		_check("a las %s: compra=%s" % [str(c[2]), str(c[1])], bool(res.get("ok", false)) == bool(c[1]),
			String(res.get("motivo", "")))
		if bool(res.get("ok", false)):
			TM.call("notificar_llegada")
	# Fuera de horario: el motivo lo dice.
	TM.call("forzar_contexto", 22, 0, "primavera", 0)
	TM.call("forzar_cartera", 50)
	var fuera: Dictionary = TM.call("buy_ticket", &"r_aurora_muelle", &"puerto_aurora")
	_check("fuera de horario: motivo 'fuera de horario'", String(fuera.get("motivo", "")).contains("fuera de horario"),
		String(fuera.get("motivo", "")))
	# list_routes también lo marca como no disponible.
	var rutas: Array = TM.call("list_routes", &"puerto_aurora")
	var marcada := false
	for rr in rutas:
		var d: Dictionary = rr
		if String(d.get("route_id", "")) == "r_aurora_muelle":
			marcada = not bool(d.get("disponible", true)) and String(d.get("motivo_bloqueo", "")).contains("fuera de horario")
	_check("list_routes marca r_aurora_muelle no disponible a las 22:00", marcada)
	_fin("F. última hora")


## ── G. Edge: desbloqueo + clima (T) ──────────────────────

func _bloque_g_desbloqueo_clima() -> void:
	_ini("G. Edge: parada recién desbloqueada + clima")
	_reset()
	# puerto_brisa NO está desbloqueada de inicio (flag templo_brisa_abierto).
	_check("puerto_brisa bloqueada de inicio", not bool(TM.call("esta_parada_desbloqueada", &"puerto_brisa")))
	TM.call("forzar_contexto", 12, 0, "verano", 0)
	TM.call("forzar_cartera", 500)
	var antes: Dictionary = TM.call("buy_ticket", &"r_aurora_brisa", &"puerto_aurora")
	_check("sin desbloquear: no compra (destino bloqueado)", not bool(antes.get("ok", true)))
	_check("sin desbloquear: motivo 'destino bloqueado'", String(antes.get("motivo", "")).contains("destino bloqueado"),
		String(antes.get("motivo", "")))
	# Desbloqueo en runtime (M71): ahora sí, en verano.
	var ok_unlock: bool = bool(TM.call("desbloquear_parada", &"puerto_brisa"))
	_check("desbloquear_parada(puerto_brisa) devuelve true", ok_unlock)
	_check("puerto_brisa ahora desbloqueada", bool(TM.call("esta_parada_desbloqueada", &"puerto_brisa")))
	var verano: Dictionary = TM.call("buy_ticket", &"r_aurora_brisa", &"puerto_aurora")
	_check("recién desbloqueada en verano: compra", bool(verano.get("ok", false)), String(verano.get("motivo", "")))
	TM.call("notificar_llegada")
	# La misma parada, fuera de temporada: la ruta está cerrada ("sólo en verano").
	TM.call("forzar_contexto", 12, 0, "invierno", 0)
	TM.call("forzar_cartera", 500)
	var invierno: Dictionary = TM.call("buy_ticket", &"r_aurora_brisa", &"puerto_aurora")
	_check("desbloqueada pero fuera de temporada: no compra", not bool(invierno.get("ok", true)))
	_check("motivo de temporada", String(invierno.get("motivo", "")).contains("verano"),
		String(invierno.get("motivo", "")))
	# Clima cambiadizo: un barco se bloquea con tormenta (M32) y se libera al mejorar.
	TM.call("forzar_contexto", 12, 3, "primavera", 0)
	TM.call("forzar_cartera", 500)
	var tormenta: Dictionary = TM.call("buy_ticket", &"r_aurora_sur", &"puerto_aurora")
	_check("barco con tormenta (clima 3): no compra", not bool(tormenta.get("ok", true)))
	_check("motivo de clima", String(tormenta.get("motivo", "")).contains("clima"),
		String(tormenta.get("motivo", "")))
	TM.call("forzar_contexto", 12, 0, "primavera", 0)
	TM.call("forzar_cartera", 500)
	var calma: Dictionary = TM.call("buy_ticket", &"r_aurora_sur", &"puerto_aurora")
	_check("clima en calma: compra", bool(calma.get("ok", false)), String(calma.get("motivo", "")))
	TM.call("notificar_llegada")
	# Nota de alcance: "sin señal" (cartel M46) es externo y no se verifica headless.
	print("  [nota] 'sin señal' (cartel M46) = externo, fuera del alcance headless")
	_fin("G. desbloqueo + clima")


## ── H. Integridad (regresión) ────────────────────────────

func _bloque_h_integridad() -> void:
	_ini("H. Integridad del grafo")
	_reset()
	_check("10 paradas", int(TM.call("contar_paradas")) == 10, str(TM.call("contar_paradas")))
	_check("20 rutas", int(TM.call("contar_rutas")) == 20, str(TM.call("contar_rutas")))
	_check("red válida (validar() sin errores)", RED.validar().is_empty())
	# Compra normal tras el reset (no quedó estado colgado del gate).
	TM.call("forzar_cartera", 100)
	var normal: Dictionary = TM.call("buy_ticket", &"r_aurora_muelle", &"puerto_aurora")
	_check("compra normal tras reset", bool(normal.get("ok", false)), String(normal.get("motivo", "")))
	_check("viaje en curso registrado", String(TM.call("viaje_en_curso")) == "r_aurora_muelle")
	var llegada: Dictionary = TM.call("notificar_llegada")
	_check("notificar_llegada ok", bool(llegada.get("ok", false)))
	_check("viaje en curso limpiado", String(TM.call("viaje_en_curso")).is_empty())
	# Persistencia (M59) sigue coherente con los waypoints MANUALES.
	TM.call("agregar_waypoint", &"puerto_sur")
	var datos: Dictionary = TM.call("get_save_data")
	var wps: Array = datos.get("waypoints", [])
	_check("waypoint manual persistido", wps.has("puerto_sur"), str(wps))
	# El grafo es coherente con lo que el modelo de waypoints espera.
	var w: Dictionary = TM.call("waypoints_de_ruta", &"puerto_aurora", &"puerto_sur")
	var lista: Array = w.get("waypoints", [])
	_check("waypoints de una ruta real validan", TransportRouteWaypoints.validar(lista).is_empty(),
		str(TransportRouteWaypoints.validar(lista)))
	_fin("H. integridad")
