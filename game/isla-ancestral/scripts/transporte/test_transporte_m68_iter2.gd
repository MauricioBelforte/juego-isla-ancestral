# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-15
#
# M68 iter. 2 — Test headless de Transporte y Navegación (secciones L/M/N/O/P/Q/V/W).
#
#   A. Planner        duración real vs fade, cozy < 4 s, fases, cargar ANTES de
#                      mover, orientación al destino, aborto sin mover (L/M)
#   B. Especiales     festivales M74, luna M31, tour; ocultos del grafo (N)
#   C. Narrativos     sin coste, no interrumpibles, hitos M22 (O)
#   D. Eventos        sin peligro, sin clima adverso, fases seguras (P)
#   E. M69            estaciones compartidas, no duplicar, más caro (Q)
#   F. Localización   12h/24h, plurales, claves es/en completas (V)
#   G. Validador      validate_transport.gd + ciclo completo (W)
#   H. Manager        integración real de los registros en el autoload
#
# Determinista: hooks `forzar_contexto` / `forzar_cartera` / `forzar_fecha`.
#
# ⚠️ Un error de script ABORTA la función en silencio (M124) → cada bloque imprime
# su marca `[FIN]` y un watchdog por temporizador cierra el proceso con código 1
# si la suite no termina, para que un aborto NO se lea como "0 fallos".
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/transporte/test_transporte_m68_iter2.gd
# Exit code != 0 si algún check falla o si salta el watchdog.

extends SceneTree

## Segundos tras los cuales el watchdog mata la suite (aborto silencioso).
const TIMEOUT_SEG := 90.0

var _fallos: int = 0
var _checks: int = 0
var _bloque: String = "(inicio)"
var _abortado: bool = false
## Bloques que llegaron a su `_fin()`. Si un bloque aborta en silencio (M124) su
## letra NO aparece: al final se comprueba que estén las 8 y la suite FALLA.
var _completados: Array[String] = []
const BLOQUES_ESPERADOS: Array[String] = ["A", "B", "C", "D", "E", "F", "G", "H"]
## Checks ejecutados por letra de bloque (medido, no estimado).
var _checks_por_bloque: Dictionary = {}
var _checks_marca: int = 0
var TM: Node = null
var RED: TransportNetwork = null


## Stub de M22 para verificar el contrato de avance de hitos sin mutar el
## estado real de la partida.
class HistoriaFalsa extends RefCounted:
	var completados: Array[String] = []
	var sellos: Array[String] = []

	func completar_nodo(id: String) -> Dictionary:
		completados.append(id)
		return {"ok": true, "motivo": ""}

	func marcar_sello(sello_id: String) -> bool:
		sellos.append(sello_id)
		return true

	func get_nodo(id: String) -> Dictionary:
		return {"id": id}


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	# Watchdog PRIMERO: si un bloque aborta en silencio, esto cierra el proceso.
	create_timer(TIMEOUT_SEG, true).timeout.connect(_on_watchdog)
	print("=== [M68 iter.2] Transporte y Navegación — secciones L/M/N/O/P/Q/V/W ===")
	TM = root.get_node_or_null("TransportManager")
	if TM == null:
		print("  [FAIL] autoload TransportManager ausente")
		_checks += 1
		_fallos += 1
		_summary()
		return
	var r: Variant = TM.call("red")
	if r is TransportNetwork:
		RED = r
	_check("autoload TransportManager presente", true)
	_check("red de transporte cargada", RED != null)
	if RED == null:
		_summary()
		return

	_bloque_a_planner()
	_bloque_b_especiales()
	_bloque_c_narrativos()
	_bloque_d_eventos()
	_bloque_e_m69()
	_bloque_f_localizacion()
	_bloque_g_validador()
	_bloque_h_manager()
	_summary()


func _on_watchdog() -> void:
	_abortado = true
	print("[M68-2] WATCHDOG: la suite no terminó en %.0f s — ABORTO" % TIMEOUT_SEG)
	print("[M68-2] último bloque iniciado: %s" % _bloque)
	print("=== Resumen M68 iter.2: %d checks, %d fallos (ABORTADO) ===" % [_checks, _fallos + 1])
	quit(1)


## ── Helpers ─────────────────────────────────────────────

func _ini(nombre: String) -> void:
	_bloque = nombre
	_checks_marca = _checks
	print("\n-- %s --" % nombre)


func _fin(nombre: String) -> void:
	# Registrar la letra del bloque: si el bloque abortó en silencio (M124),
	# `_fin()` no se ejecuta y la letra falta → la suite falla en `_summary()`.
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


func _fecha(mes: int = 1, dia: int = 1, hora: int = 12, dia_absoluto: int = 1, semana_dia: int = 0, estacion: int = 0) -> Dictionary:
	return {
		"mes": mes, "dia": dia, "anio": 1, "hora": hora,
		"dia_absoluto": dia_absoluto, "semana_dia": semana_dia, "estacion": estacion,
	}


## ── A. Planner (L/M) ────────────────────────────────────

func _bloque_a_planner() -> void:
	_ini("A. Planner: tiempos, cozy y transición")
	# Tres rutas distintas: corta (muelle), media (tren) y larga (barco).
	var casos: Array = [
		["r_aurora_muelle", true],
		["r_aurora_estacion", true],
		["r_aurora_espejo", false],
	]
	for caso in casos:
		var par: Array = caso
		var ruta: TransportRoute = RED.ruta(StringName(str(par[0])))
		_check("ruta %s existe" % str(par[0]), ruta != null)
		if ruta == null:
			continue
		var destino: TransportStop = RED.stop(ruta.to_id)
		var plan: Dictionary = TransportTripPlanner.planificar(ruta, destino)
		_check("%s: plan válido" % str(par[0]), TransportTripPlanner.es_plan_valido(plan),
			str(TransportTripPlanner.verificar_plan(plan)))
		var total: float = float(plan.get("duracion_total", 0.0))
		_check("%s: cozy (0 < %.2f s < 4)" % [str(par[0]), total],
			total > 0.0 and total < TransportTripPlanner.DURACION_MAX_COZY)
		# RF14: corto = tiempo real con vehículo; largo = montaje con fade.
		_check("%s: usa_vehiculo = %s" % [str(par[0]), str(bool(par[1]))],
			bool(plan.get("usa_vehiculo", false)) == bool(par[1]))
		var fases: Array = plan.get("fases", [])
		_check("%s: %d fases en el orden obligatorio" % [str(par[0]), fases.size()], fases.size() == 7)
		var i_carga: int = -1
		var i_mover: int = -1
		for i in fases.size():
			var f: Dictionary = fases[i]
			if str(f.get("id", "")) == "cargar_destino":
				i_carga = i
			elif str(f.get("id", "")) == "mover_jugador":
				i_mover = i
		_check("%s: cargar_destino ANTES de mover_jugador" % str(par[0]),
			i_carga >= 0 and i_mover >= 0 and i_carga < i_mover)
		var o: Vector3 = plan.get("orientacion", Vector3.ZERO) as Vector3
		_check("%s: orientación unitaria al destino" % str(par[0]), is_equal_approx(o.length(), 1.0), str(o))
		_check("%s: nunca pierde al jugador" % str(par[0]),
			not bool(plan.get("puede_perder_jugador", true)))
		_check("%s: mensaje para el jugador" % str(par[0]),
			not String(plan.get("mensaje", "")).is_empty())
	_fin("A. rutas y planes")

	# Barra de progreso (M08) si la carga del destino es lenta.
	var ruta_m: TransportRoute = RED.ruta(&"r_aurora_sur")
	var destino_m: TransportStop = RED.stop(&"puerto_sur")
	var rapido: Dictionary = TransportTripPlanner.planificar(ruta_m, destino_m, {"carga_destino_seg": 0.5})
	var lento: Dictionary = TransportTripPlanner.planificar(ruta_m, destino_m, {"carga_destino_seg": 3.0})
	_check("carga rápida: sin barra de progreso", not bool(rapido.get("necesita_barra", true)))
	_check("carga lenta: barra de progreso (M08)", bool(lento.get("necesita_barra", false)))
	_check("ambos planes siguen siendo válidos",
		TransportTripPlanner.es_plan_valido(rapido) and TransportTripPlanner.es_plan_valido(lento))

	# Aborto por fallo de carga (streaming pesado): NO se mueve al jugador.
	var abortado: Dictionary = TransportTripPlanner.planificar(ruta_m, destino_m, {"motivo_aborto": "streaming pesado"})
	_check("aborto: plan no válido", not bool(abortado.get("ok", true)))
	_check("aborto: nunca pierde al jugador", not bool(abortado.get("puede_perder_jugador", true)))
	_check("aborto: motivo reportado", String(abortado.get("motivo", "")) == "streaming pesado")
	_check("aborto: sin fases (no se ejecuta la transición)", (abortado.get("fases", []) as Array).is_empty())
	_check("aborto: reintentos_carga declarados", int(abortado.get("reintentos_carga", 0)) >= 1)
	_check("aborto: verificar_plan no acusa", TransportTripPlanner.verificar_plan(abortado).is_empty())

	# El verificador DETECTA un plan manipulado (si no, no valdría de nada).
	var malo: Dictionary = TransportTripPlanner.planificar(ruta_m, destino_m)
	var fases_malas: Array = (malo.get("fases", []) as Array).duplicate(true)
	fases_malas.reverse()
	malo["fases"] = fases_malas
	_check("verificar_plan detecta fases invertidas", not TransportTripPlanner.verificar_plan(malo).is_empty())
	var malo2: Dictionary = TransportTripPlanner.planificar(ruta_m, destino_m)
	malo2["puede_perder_jugador"] = true
	_check("verificar_plan detecta puede_perder_jugador", not TransportTripPlanner.verificar_plan(malo2).is_empty())
	var malo3: Dictionary = TransportTripPlanner.planificar(ruta_m, destino_m)
	malo3["orientacion"] = Vector3.ZERO
	_check("verificar_plan detecta orientación nula", not TransportTripPlanner.verificar_plan(malo3).is_empty())
	_fin("A. barra, aborto y detección")


## ── B. Viajes especiales (N) ────────────────────────────

func _bloque_b_especiales() -> void:
	_ini("B. Viajes especiales (M74/M31)")
	var esp: TransportSpecialTrips = TM.call("especiales")
	_check("registro de especiales expuesto", esp != null)
	if esp == null:
		return
	_check("7 viajes especiales (5 festival + luna + tour)", esp.contar() == 7, "got %d" % esp.contar())
	_check("registro válido contra la red", esp.validar(RED).is_empty(), str(esp.validar(RED)))
	_check("5 de tipo festival", esp.por_tipo("festival").size() == 5)
	_check("1 de tipo luna", esp.por_tipo("luna").size() == 1)
	_check("1 de tipo tour", esp.por_tipo("tour").size() == 1)

	# Oculta del grafo normal: sólo la ida/vuelta al Puerto del Festival.
	var ocultas: Array[String] = esp.rutas_ocultas()
	_check("oculta r_muelle_festival", ocultas.has("r_muelle_festival"), str(ocultas))
	_check("oculta r_festival_muelle", ocultas.has("r_festival_muelle"), str(ocultas))
	_check("no oculta una ruta normal", not esp.ruta_oculta("r_aurora_sur"))

	# Festival de Otoño (M74: mes 9, día 15, 08:00-20:00).
	var v_otono: Dictionary = esp.viaje("esp_festival_otono")
	_check("existe el viaje del festival de otoño", not v_otono.is_empty())
	var en_fecha: Dictionary = esp.disponible_en(v_otono, _fecha(9, 15, 10, 1, 0, 2))
	_check("festival de otoño disponible el 15/9", bool(en_fecha.get("ok", false)), str(en_fecha))
	var fuera_fecha: Dictionary = esp.disponible_en(v_otono, _fecha(9, 14, 10, 1, 0, 2))
	_check("festival de otoño NO disponible el 14/9", not bool(fuera_fecha.get("ok", false)))
	_check("el motivo indica la fecha", String(fuera_fecha.get("motivo", "")).contains("15/9"),
		String(fuera_fecha.get("motivo", "")))
	var fuera_hora: Dictionary = esp.disponible_en(v_otono, _fecha(9, 15, 23, 1, 0, 2))
	_check("festival de otoño NO disponible a las 23:00", not bool(fuera_hora.get("ok", false)))
	# Con M74 disponible, manda el evento (no la fecha).
	var m74_si: Dictionary = esp.disponible_en(v_otono, _fecha(1, 1, 12, 1, 0, 0), {"eventos_activos": ["festival_otono"]})
	_check("con M74 activo manda el evento", bool(m74_si.get("ok", false)), str(m74_si))
	var m74_no: Dictionary = esp.disponible_en(v_otono, _fecha(9, 15, 10, 1, 0, 2), {"eventos_activos": ["festival_luces"]})
	_check("con otro evento activo se bloquea", not bool(m74_no.get("ok", false)))
	_check("el motivo nombra el evento", String(m74_no.get("motivo", "")).contains("festival_otono"))

	# Tour de luna llena (M31): día 14 del ciclo de 28.
	var v_luna: Dictionary = esp.viaje("esp_luna_llena")
	_check("el tour de luna es más caro que el boleto",
		int(v_luna.get("precio", 0)) > int(v_luna.get("precio_base", 0)))
	_check("luna llena el día absoluto 14",
		bool(esp.disponible_en(v_luna, _fecha(1, 1, 21, 14)).get("ok", false)))
	_check("NO hay luna llena el día absoluto 20",
		not bool(esp.disponible_en(v_luna, _fecha(1, 1, 21, 20)).get("ok", false)))
	_check("M31 manda si expone luna_llena",
		bool(esp.disponible_en(v_luna, _fecha(1, 1, 21, 3), {"luna_llena": true}).get("ok", false)))

	# Tour panorámico: sólo fin de semana.
	var v_tour: Dictionary = esp.viaje("esp_tour_dirigible")
	_check("tour disponible el sábado (semana_dia 5)",
		bool(esp.disponible_en(v_tour, _fecha(1, 1, 12, 1, 5)).get("ok", false)))
	_check("tour NO disponible el martes (semana_dia 1)",
		not bool(esp.disponible_en(v_tour, _fecha(1, 1, 12, 1, 1)).get("ok", false)))

	# El validador detecta un registro roto.
	var roto := TransportSpecialTrips.new([{
		"id": "esp_malo", "tipo": "festival", "ruta_id": "r_inexistente",
		"origen_id": "x", "destino_id": "y", "precio": 0, "precio_base": 0,
		"ocultar_en_grafo_normal": true, "calendario": {},
	}])
	_check("validar detecta ruta inexistente y precio 0", roto.validar(RED).size() >= 2, str(roto.validar(RED)))
	_fin("B. especiales")


## ── C. Viajes narrativos (O) ────────────────────────────

func _bloque_c_narrativos() -> void:
	_ini("C. Viajes narrativos (M22/M23)")
	var nar: TransportNarrativeTrips = TM.call("narrativos")
	_check("registro de narrativos expuesto", nar != null)
	if nar == null:
		return
	var historia: Object = root.get_node_or_null("Historia")
	_check("3 viajes narrativos", nar.contar() == 3, "got %d" % nar.contar())
	_check("registro válido contra la red y M22", nar.validar(RED, historia).is_empty(), str(nar.validar(RED, historia)))

	var v: Dictionary = nar.viaje("nar_c4_templo_brisa")
	_check("existe el viaje narrativo del capítulo 4", not v.is_empty())
	_check("sin coste por diseño", bool(v.get("sin_coste", false)))
	_check("no interrumpible", not nar.es_interrumpible(v))
	_check("diálogos a bordo declarados (M21)", nar.dialogos_a_bordo(v).size() >= 2)

	# Plan narrativo: sin coste, modo narrativo y válido.
	var plan: Dictionary = nar.plan_narrativo(v, RED)
	_check("plan narrativo válido", TransportTripPlanner.es_plan_valido(plan), str(TransportTripPlanner.verificar_plan(plan)))
	_check("plan narrativo: modo narrativo", String(plan.get("modo", "")) == "narrativo")
	_check("plan narrativo: precio 0", int(plan.get("precio", -1)) == 0)
	_check("plan narrativo: no interrumpible", not bool(plan.get("interrumpible", true)))
	_check("plan narrativo: hito declarado", not String(plan.get("hito_llegada", "")).is_empty())
	_check("plan narrativo: viaje_id propagado", String(plan.get("viaje_id", "")) == "nar_c4_templo_brisa")

	# Gating por capítulo y por flag.
	var cap_bajo: Dictionary = nar.disponible_para(v, 2, [])
	_check("bloqueado antes del capítulo 4", not bool(cap_bajo.get("ok", false)))
	_check("el motivo nombra el capítulo", String(cap_bajo.get("motivo", "")).contains("capítulo 4"))
	var sin_flag: Dictionary = nar.disponible_para(v, 4, [])
	_check("bloqueado sin la flag del templo", not bool(sin_flag.get("ok", false)))
	var con_flag: Dictionary = nar.disponible_para(v, 4, ["templo_brisa_abierto"])
	_check("disponible con capítulo y flag", bool(con_flag.get("ok", false)), str(con_flag))

	# Avance de hitos con un stub (no muta la partida real).
	var falsa := HistoriaFalsa.new()
	var avance: Dictionary = nar.avanzar_hitos(v, falsa)
	_check("avanza el hito en M22", bool(avance.get("hito_ok", false)), str(avance))
	_check("el stub registró el nodo c4", falsa.completados.has("c4"), str(falsa.completados))
	var v_c7: Dictionary = nar.viaje("nar_c7_camara_sello")
	var avance2: Dictionary = nar.avanzar_hitos(v_c7, falsa)
	_check("marca el sello al llegar", bool(avance2.get("sello_ok", false)), str(avance2))
	_check("el stub registró sello_brisa_camara", falsa.sellos.has("sello_brisa_camara"), str(falsa.sellos))
	var sin_m22: Dictionary = nar.avanzar_hitos(v, null)
	_check("sin M22 no rompe, informa el motivo", not bool(sin_m22.get("ok", true)))

	# Barrido de los 7 capítulos: cada capítulo tiene un plan narrativo válido y
	# gratuito (los capítulos sin viaje declarado se inyectan para probar el
	# mecanismo; el CONTENIDO canónico de cada capítulo es de M22/M23).
	var cubiertos: int = 0
	for cap in range(1, 8):
		var viaje_cap: Dictionary = nar.viaje_para_capitulo(cap)
		if viaje_cap.is_empty():
			viaje_cap = {
				"id": "prueba_c%d" % cap, "capitulo": cap, "ruta_id": "r_aurora_sur",
				"origen_id": "puerto_aurora", "destino_id": "puerto_sur", "sin_coste": true,
				"precio": 0, "interrumpible": false, "hito_llegada": "", "sello_llegada": "",
				"dialogos_a_bordo": ["M68.NARR.PRUEBA"],
			}
		var p: Dictionary = nar.plan_narrativo(viaje_cap, RED)
		if TransportTripPlanner.es_plan_valido(p) and int(p.get("precio", -1)) == 0:
			cubiertos += 1
	_check("los 7 capítulos producen un plan narrativo válido y gratuito", cubiertos == 7, "got %d" % cubiertos)
	_check("capítulos cubiertos por el registro: %s" % str(nar.capitulos_cubiertos()),
		nar.capitulos_cubiertos().size() >= 2)
	_fin("C. narrativos")


## ── D. Eventos de ruta (P) ──────────────────────────────

func _bloque_d_eventos() -> void:
	_ini("D. Eventos de ruta (M64, RF18)")
	var ev: TransportRouteEvents = TM.call("eventos_de_ruta")
	_check("registro de eventos expuesto", ev != null)
	if ev == null:
		return
	var villager: Object = root.get_node_or_null("VillagerManager")
	_check("5 eventos de ruta", ev.contar() == 5, "got %d" % ev.contar())
	_check("registro válido contra la red y M64", ev.validar(RED, villager).is_empty(), str(ev.validar(RED, villager)))

	# Invariante dura: NINGÚN evento es peligroso ni rompe la transición.
	var inseguros: int = 0
	var rompen: int = 0
	for e in ev.eventos():
		if not ev.es_seguro(e):
			inseguros += 1
		if ev.rompe_transicion(e):
			rompen += 1
	_check("ningún evento es inseguro", inseguros == 0, "inseguros=%d" % inseguros)
	_check("ningún evento rompe la transición", rompen == 0, "rompen=%d" % rompen)

	# Con clima adverso no hay eventos de ruta.
	var con_tormenta: Dictionary = ev.elegir("r_aurora_sur", {"clima": 3, "stop_id": "puerto_sur"}, 0, RED)
	_check("con tormenta no se dispara evento", not bool(con_tormenta.get("ok", true)))
	_check("el motivo nombra el clima", String(con_tormenta.get("motivo", "")).contains("clima"),
		String(con_tormenta.get("motivo", "")))

	# Determinismo: misma semilla, mismo evento.
	var a1: Dictionary = ev.elegir("r_aurora_muelle", {"clima": 0, "stop_id": "muelle_raiz_sur"}, 7, RED)
	var a2: Dictionary = ev.elegir("r_aurora_muelle", {"clima": 0, "stop_id": "muelle_raiz_sur"}, 7, RED)
	_check("selección determinista con la misma semilla",
		str(a1.get("evento", {}).get("id", "")) == str(a2.get("evento", {}).get("id", "")),
		"%s vs %s" % [str(a1.get("evento", {}).get("id", "")), str(a2.get("evento", {}).get("id", ""))])
	_check("el evento elegido en el muelle es el de Mateo",
		str(a1.get("evento", {}).get("id", "")) == "ev_muelle_mateo", str(a1.get("evento", {}).get("id", "")))
	var senal: Dictionary = ev.senal(a1.get("evento", {}))
	_check("el evento trae señal (M43/M44)", not String(senal.get("clave", "")).is_empty())
	_check("la fase del evento es segura", TransportRouteEvents.FASES_SEGURAS.has(ev.fase(a1.get("evento", {}))))

	# El evento de festival exige el evento activo de M74.
	var fest_sin: Dictionary = ev.elegir("r_muelle_festival", {"clima": 0, "stop_id": "puerto_festival"}, 0, RED)
	_check("sin festival activo no hay evento de festival",
		str(fest_sin.get("evento", {}).get("id", "")) != "ev_festival_catalina",
		str(fest_sin.get("evento", {}).get("id", "")))
	var fest_con: Dictionary = ev.elegir("r_muelle_festival", {
		"clima": 0, "stop_id": "puerto_festival", "eventos_activos": ["festival_otono"],
	}, 0, RED)
	_check("con el festival activo aparece el evento de festival",
		str(fest_con.get("evento", {}).get("id", "")) == "ev_festival_catalina",
		str(fest_con.get("evento", {}).get("id", "")))

	# El validador detecta eventos peligrosos y fases críticas.
	var roto := TransportRouteEvents.new([
		{"id": "ev_malo", "tipo": "npc", "stop_id": "puerto_aurora", "npcs": [], "fase": "mover_jugador",
			"senal_clave": "X", "senal_tipo": "visual", "peligroso": true, "peso": 1},
	])
	var errs: Array[String] = roto.validar(RED)
	_check("validar detecta evento peligroso", _contiene(errs, "peligroso"), str(errs))
	_check("validar detecta fase crítica", _contiene(errs, "fase"), str(errs))
	_fin("D. eventos")


## ── E. Coordinación con M69 (Q) ─────────────────────────

func _bloque_e_m69() -> void:
	_ini("E. Coordinación con M69 (fast travel)")
	var puente: TransportM69Bridge = TM.call("puente_m69")
	_check("puente M69 expuesto", puente != null)
	if puente == null:
		return

	# Decisión 4: el fast travel siempre es más caro que el boleto.
	_check("boleto 80 -> fast 128", puente.precio_m69(80) == 128, "got %d" % puente.precio_m69(80))
	_check("boleto 10 -> fast 20 (margen mínimo)", puente.precio_m69(10) == 20, "got %d" % puente.precio_m69(10))
	_check("boleto 0 -> fast 10", puente.precio_m69(0) == 10, "got %d" % puente.precio_m69(0))
	var mas_caro: bool = true
	for p in [0, 5, 8, 10, 12, 20, 60, 80, 90, 100, 150, 220]:
		if not puente.es_mas_caro_que_boleto(puente.precio_m69(p), p):
			mas_caro = false
	_check("el fast travel es más caro en todos los precios del dataset", mas_caro)

	# Datos REALES de M69 (data/fasttravel/anclas.json): 4 anclas.
	var anclas: Array = _cargar_anclas_m69()
	_check("se cargaron las 4 anclas reales de M69", anclas.size() == 4, "got %d" % anclas.size())
	var compartidas: Array[Dictionary] = puente.estaciones_compartidas(RED, anclas)
	var huerfanas: Array[String] = puente.anclas_huerfanas(RED, anclas)
	_check("HALLAZGO: M69 y M68 comparten 0 estaciones hoy", compartidas.size() == 0,
		"compartidas=%d" % compartidas.size())
	_check("las 4 anclas de M69 son huérfanas de la red M68", huerfanas.size() == 4, str(huerfanas))
	_check("sin duplicación de costes ni rutas", puente.detectar_duplicacion(RED, anclas).is_empty(),
		str(puente.detectar_duplicacion(RED, anclas)))
	_check("el informe reporta el hallazgo", puente.informe(RED, anclas).contains("0 compartidas"),
		puente.informe(RED, anclas))

	# Mecanismo verificado con 3 destinos anclados a paradas reales.
	var tres: Array = [
		{"id": "ancla_aurora", "x": 0.0, "z": 0.0},
		{"id": "ancla_sur", "x": 0.0, "z": 180.0},
		{"id": "ancla_plataforma", "x": 0.0, "z": -30.0},
	]
	var comp3: Array[Dictionary] = puente.estaciones_compartidas(RED, tres)
	_check("3 destinos anclados a paradas reales", comp3.size() == 3, "got %d" % comp3.size())
	_check("se emparejan por proximidad",
		comp3.size() == 3 and String(comp3[0].get("via", "")) == "proximidad", str(comp3))
	var ofrecibles: Array[Dictionary] = puente.destinos_disponibles(RED, tres)
	_check("M69 ofrece los 3 destinos (paradas desbloqueadas de inicio)", ofrecibles.size() == 3,
		"got %d" % ofrecibles.size())
	# Con una parada bloqueada (puerto_brisa exige flag) no se ofrece.
	var bloqueada: Array = [{"id": "ancla_brisa", "x": 150.0, "z": 150.0}]
	_check("una parada bloqueada NO se ofrece", puente.destinos_disponibles(RED, bloqueada).is_empty())
	_check("...pero sí se ofrece si se desbloquea",
		puente.destinos_disponibles(RED, bloqueada, ["puerto_brisa"]).size() == 1)

	# Validación con precios: la decisión 4 se comprueba por destino.
	var precios: Dictionary = {"puerto_aurora": 0, "puerto_sur": 80, "plataforma_norte": 0}
	_check("validar() acepta los 3 destinos con precio más caro",
		puente.validar(RED, tres, precios).is_empty(), str(puente.validar(RED, tres, precios)))

	# Duplicación detectada.
	var dup: Array = [
		{"id": "puerto_aurora", "x": 0.0, "z": 0.0},
		{"id": "ancla_a", "x": 0.0, "z": 180.0},
		{"id": "ancla_b", "x": 0.0, "z": 180.0},
		{"id": "ancla_c", "x": 0.0, "z": 0.0, "precio": 50},
	]
	var errs_dup: Array[String] = puente.detectar_duplicacion(RED, dup)
	_check("detecta ancla que reusa el id de una parada", _contiene(errs_dup, "reusa el id"), str(errs_dup))
	_check("detecta dos anclas sobre la misma parada", _contiene(errs_dup, "misma parada"), str(errs_dup))
	_check("detecta coste propio en el ancla", _contiene(errs_dup, "coste propio"), str(errs_dup))
	_fin("E. M69")


## ── F. Localización (V) ─────────────────────────────────

func _bloque_f_localizacion() -> void:
	_ini("F. Localización (M87): formatos, plurales y claves")
	var loc: TransportLocalizer = TM.call("localizador")
	_check("localizador expuesto", loc != null)
	if loc == null:
		return
	var cargados: int = loc.cargar_catalogos(["es", "en"])
	_check("2 catálogos cargados", cargados == 2, "got %d" % cargados)

	# Formatos de hora: es 24 h, en 12 h (delegado a LocaleUtils de M87).
	_check("es 24 h: 08:00-20:00", loc.horario_texto(8, 20, "es") == "08:00-20:00", loc.horario_texto(8, 20, "es"))
	_check("en 12 h: 8:00 AM-8:00 PM", loc.horario_texto(8, 20, "en") == "8:00 AM-8:00 PM", loc.horario_texto(8, 20, "en"))
	_check("formato de parada localizado",
		loc.horario_de_parada(RED.stop(&"puerto_sur"), "en") == "7:00 AM-9:00 PM",
		loc.horario_de_parada(RED.stop(&"puerto_sur"), "en"))

	# Plurales.
	_check("45 s -> segundos", loc.duracion_texto(45.0, "es") == "45 segundos", loc.duracion_texto(45.0, "es"))
	_check("60 s -> 1 minuto (singular)", loc.duracion_texto(60.0, "es") == "1 minuto", loc.duracion_texto(60.0, "es"))
	_check("300 s -> 5 minutos (plural)", loc.duracion_texto(300.0, "es") == "5 minutos", loc.duracion_texto(300.0, "es"))
	_check("5400 s -> 1 h 30 min", loc.duracion_texto(5400.0, "es") == "1 h 30 min", loc.duracion_texto(5400.0, "es"))
	_check("plural en inglés: 1 minute", loc.duracion_texto(60.0, "en") == "1 minute", loc.duracion_texto(60.0, "en"))
	_check("plural en inglés: 5 minutes", loc.duracion_texto(300.0, "en") == "5 minutes", loc.duracion_texto(300.0, "en"))
	_check("el singular y el plural difieren", loc.duracion_texto(60.0, "es") != loc.duracion_texto(300.0, "es"))

	# Números y moneda por idioma.
	_check("precio es: 1.234 AO", loc.precio_texto(1234, "es") == "1.234 AO", loc.precio_texto(1234, "es"))
	_check("precio en: 1,234 AO", loc.precio_texto(1234, "en") == "1,234 AO", loc.precio_texto(1234, "en"))

	# Nombres de parada y ruta.
	_check("nombre en inglés de puerto_aurora",
		loc.nombre_parada(RED.stop(&"puerto_aurora"), "en") == "Aurora Harbour",
		loc.nombre_parada(RED.stop(&"puerto_aurora"), "en"))
	_check("nombre en español de puerto_aurora",
		loc.nombre_parada(RED.stop(&"puerto_aurora"), "es") == "Puerto de Aurora",
		loc.nombre_parada(RED.stop(&"puerto_aurora"), "es"))
	var nr_en: String = loc.nombre_ruta(RED.ruta(&"r_aurora_sur"), "en")
	_check("nombre de ruta en inglés traducido", nr_en.contains("South Island Harbour"), nr_en)
	_check("nombre de ruta con flecha", nr_en.contains("→"), nr_en)

	# Mensajes y carteles.
	_check("mensaje de viaje es", loc.mensaje_viaje("Puerto de Aurora", "es") == "Viajando a Puerto de Aurora...",
		loc.mensaje_viaje("Puerto de Aurora", "es"))
	_check("mensaje de viaje en", loc.mensaje_viaje("Aurora Harbour", "en") == "Travelling to Aurora Harbour...",
		loc.mensaje_viaje("Aurora Harbour", "en"))
	_check("mensaje de llegada es", loc.mensaje_llegada("Aurora", "es") == "Has llegado a Aurora.",
		loc.mensaje_llegada("Aurora", "es"))
	_check("cartel con destino y metros",
		loc.texto_cartel("Aurora Harbour", 120.0, "en") == "→ Aurora Harbour · 120 m",
		loc.texto_cartel("Aurora Harbour", 120.0, "en"))

	# Cobertura de claves contra los .po reales.
	var esp: Object = TM.call("especiales")
	var nar: Object = TM.call("narrativos")
	var ev: Object = TM.call("eventos_de_ruta")
	var totales: Array[String] = loc.claves_totales(RED, esp, nar, ev)
	_check("el inventario supera las 86 claves", totales.size() >= 86, "got %d" % totales.size())
	var faltan: Array[String] = loc.claves_faltantes(["es", "en"], RED, esp, nar, ev)
	_check("ninguna clave falta en es.po ni en en.po", faltan.is_empty(), str(faltan))
	var vacias: Array[String] = loc.claves_vacias(["es", "en"], RED, esp, nar, ev)
	_check("ninguna traducción vacía", vacias.is_empty(), str(vacias))
	_check("formatos verificados en es", loc.verificar_formatos("es").is_empty(), str(loc.verificar_formatos("es")))
	_check("formatos verificados en en", loc.verificar_formatos("en").is_empty(), str(loc.verificar_formatos("en")))
	_check("validar() completo sin errores", loc.validar(["es", "en"], RED, esp, nar, ev).is_empty(),
		str(loc.validar(["es", "en"], RED, esp, nar, ev)))

	# El catálogo GENERADO debe coincidir con el aplicado a los .po (si divergen,
	# la generación y el catálogo real se desincronizaron).
	var gen: Dictionary = loc.generar_catalogo("en", RED, esp, nar, ev)
	var divergentes: int = 0
	for clave in gen.keys():
		if loc.falta(String(clave), "en"):
			divergentes += 1
	_check("el catálogo generado está aplicado en en.po", divergentes == 0, "divergentes=%d" % divergentes)
	_check("los idiomas disponibles son 2 (es, en)", loc.locales_cargados().size() == 2, str(loc.locales_cargados()))
	_fin("F. localización")


## ── G. Validador y ciclo completo (W) ───────────────────

func _bloque_g_validador() -> void:
	_ini("G. Validador unificado y ciclo completo (W)")
	var val := ValidateTransport.new()
	var esp: Object = TM.call("especiales")
	var nar: Object = TM.call("narrativos")
	var ev: Object = TM.call("eventos_de_ruta")
	var puente: Object = TM.call("puente_m69")
	var loc: Object = TM.call("localizador")
	var villager: Object = root.get_node_or_null("VillagerManager")
	var historia: Object = root.get_node_or_null("Historia")
	var anclas: Array = _cargar_anclas_m69()

	# Cada bloque por separado, para localizar el fallo.
	_check("bloque grafo", val.validar_grafo(RED).is_empty(), str(val.validar_grafo(RED)))
	_check("bloque planes (20 rutas)", val.validar_planes(RED).is_empty(), str(val.validar_planes(RED)))
	_check("bloque costes (descuento M20)", val.validar_costes(RED).is_empty(), str(val.validar_costes(RED)))
	# MEDICIÓN: "directo > combinar" NO es universal (corrige el [x] de la iter. 1).
	var med: Dictionary = val.medir_directo_vs_combinar(RED)
	_check("medición: 20 rutas medidas", int(med.get("total", 0)) == 20, str(med.get("total", 0)))
	_check("medición: 4 rutas cumplen directo>combinar", (med.get("cumplen", []) as Array).size() == 4,
		str(med.get("cumplen", [])))
	_check("medición: 6 rutas locales lo violan por diseño", (med.get("violan", []) as Array).size() == 6,
		str(med.get("violan", [])))
	_check("medición: 10 rutas sin alternativa", (med.get("sin_alternativa", []) as Array).size() == 10,
		str(med.get("sin_alternativa", [])))
	_check("medición: la ruta expresa aurora→sur cumple", (med.get("cumplen", []) as Array).has("r_aurora_sur"),
		str(med.get("cumplen", [])))
	_check("medición: la ruta local muelle→sur viola", (med.get("violan", []) as Array).has("r_muelle_sur"),
		str(med.get("violan", [])))
	_check("bloque especiales", val.validar_especiales(esp, RED).is_empty(), str(val.validar_especiales(esp, RED)))
	_check("bloque narrativos", val.validar_narrativos(nar, RED, historia).is_empty(), str(val.validar_narrativos(nar, RED, historia)))
	_check("bloque eventos", val.validar_eventos(ev, RED, villager).is_empty(), str(val.validar_eventos(ev, RED, villager)))
	_check("bloque M69", val.validar_m69(puente, RED, anclas, {"puerto_sur": 80}).is_empty(),
		str(val.validar_m69(puente, RED, anclas, {"puerto_sur": 80})))
	_check("bloque localización", val.validar_localizacion(loc, ["es", "en"], RED, esp, nar, ev).is_empty(),
		str(val.validar_localizacion(loc, ["es", "en"], RED, esp, nar, ev)))

	# Ciclo completo en 3 destinos: mapa -> elegir -> pagar -> viajar -> llegar.
	for caso in [["puerto_aurora", "r_aurora_sur"], ["puerto_aurora", "r_aurora_estacion"], ["puerto_aurora", "r_aurora_plataforma"]]:
		var par: Array = caso
		var res: Dictionary = val.simular_ciclo(TM, RED, str(par[0]), str(par[1]), {"contexto": [12, 0, "primavera", 0], "cartera": 5000})
		_check("ciclo %s completo" % str(par[1]), bool(res.get("ok", false)), str(res.get("errores", [])))
		_check("ciclo %s: 4 pasos" % str(par[1]), (res.get("pasos", []) as Array).size() >= 4, str(res.get("pasos", [])))

	# Sin dinero el ciclo se detiene con motivo (no crashea ni mueve al jugador).
	var sin_dinero: Dictionary = val.simular_ciclo(TM, RED, "puerto_aurora", "r_aurora_espejo",
		{"contexto": [12, 0, "primavera", 0], "cartera": 5})
	_check("sin dinero el ciclo falla con motivo", not bool(sin_dinero.get("ok", true)))
	_check("el motivo menciona el precio o el bloqueo",
		_contiene_alguna(sin_dinero.get("errores", []), ["AO", "disponible", "bloqueado", "progreso"]),
		str(sin_dinero.get("errores", [])))

	# validar_todo: la puerta de calidad completa.
	var todo: Dictionary = val.validar_todo(RED, {
		"manager": TM, "especiales": esp, "narrativos": nar, "eventos": ev,
		"m69": puente, "localizador": loc, "anclas": anclas,
		"precios": {"puerto_sur": 80, "puerto_este": 90, "puerto_norte": 100},
		"villager": villager, "historia": historia, "locales": ["es", "en"],
		"contexto": [12, 0, "primavera", 0], "cartera": 5000,
	})
	_check("validar_todo: OK", bool(todo.get("ok", false)), str(todo.get("errores", [])))
	_check("validar_todo: checks > 20", int(todo.get("checks", 0)) > 20, "got %d" % int(todo.get("checks", 0)))
	_check("validar_todo: 9 bloques", (todo.get("bloques", {}) as Dictionary).size() == 9,
		str(todo.get("bloques", {})))
	var informe: String = val.informe(todo)
	_check("el informe dice OK", informe.contains("VALIDATE-TRANSPORT OK"), informe)
	_check("el informe declara los pendientes externos", informe.contains("M46") and informe.contains("M54"), informe)
	_check("los pendientes externos son 4", (todo.get("pendientes", []) as Array).size() == 4,
		str(todo.get("pendientes", [])))

	# El validador DETECTA un registro roto (si no, sería decorativo).
	var roto := TransportSpecialTrips.new([{"id": "x", "tipo": "inventado", "ruta_id": "no_existe",
		"origen_id": "a", "destino_id": "b", "precio": 0, "precio_base": 0,
		"ocultar_en_grafo_normal": false, "calendario": {}}])
	var malo: Dictionary = val.validar_todo(RED, {"especiales": roto})
	_check("validar_todo falla con un registro roto", not bool(malo.get("ok", true)))
	_fin("G. validador")


## ── H. Integración en el manager ────────────────────────

func _bloque_h_manager() -> void:
	_ini("H. Integración en TransportManager")
	_check("accesor especiales()", TM.call("especiales") != null)
	_check("accesor narrativos()", TM.call("narrativos") != null)
	_check("accesor eventos_de_ruta()", TM.call("eventos_de_ruta") != null)
	_check("accesor puente_m69()", TM.call("puente_m69") != null)
	_check("accesor localizador()", TM.call("localizador") != null)

	# Fuera de la ventana del festival, la parada temporal NO aparece.
	TM.call("forzar_contexto", 12, 0, "primavera", 0)
	TM.call("forzar_fecha", 1, 1, 1, 1, 0, 0)
	var rutas_fuera: Array = TM.call("list_routes", &"muelle_raiz_sur")
	var ids_fuera: Array[String] = []
	for r in rutas_fuera:
		ids_fuera.append(str((r as Dictionary).get("route_id", "")))
	_check("fuera de ventana no aparece r_muelle_festival", not ids_fuera.has("r_muelle_festival"), str(ids_fuera))
	_check("fuera de ventana no aparece r_festival_muelle", not ids_fuera.has("r_festival_muelle"), str(ids_fuera))
	_check("las rutas normales del muelle siguen ahí", ids_fuera.has("r_muelle_aurora"), str(ids_fuera))

	# Dentro de la ventana del festival de otoño SÍ aparece.
	TM.call("forzar_fecha", 15, 9, 1, 258, 0, 2)
	var rutas_dentro: Array = TM.call("list_routes", &"muelle_raiz_sur")
	var ids_dentro: Array[String] = []
	for r in rutas_dentro:
		ids_dentro.append(str((r as Dictionary).get("route_id", "")))
	_check("en la ventana aparece r_muelle_festival", ids_dentro.has("r_muelle_festival"), str(ids_dentro))
	_check("viajes_especiales_disponibles() = 1", (TM.call("viajes_especiales_disponibles") as Array).size() == 1,
		str(TM.call("viajes_especiales_disponibles")))
	var especiales_hoy: Array = TM.call("viajes_especiales_disponibles")
	if especiales_hoy.size() == 1:
		_check("el viaje disponible es el de otoño",
			str((especiales_hoy[0] as Dictionary).get("id", "")) == "esp_festival_otono",
			str((especiales_hoy[0] as Dictionary).get("id", "")))

	# La compra de la ruta oculta fuera de ventana queda bloqueada.
	TM.call("forzar_fecha", 1, 1, 1, 1, 0, 0)
	TM.call("forzar_cartera", 5000)
	var compra: Dictionary = TM.call("buy_ticket", &"r_muelle_festival", &"muelle_raiz_sur")
	_check("buy_ticket rechaza el viaje programado fuera de ventana", not bool(compra.get("ok", true)), str(compra))
	_check("el motivo lo explica", String(compra.get("motivo", "")).contains("programado"), str(compra))

	# Evento de ruta desde el manager.
	var ev_mgr: Dictionary = TM.call("evento_de_ruta", "r_aurora_muelle", 3)
	_check("evento_de_ruta() devuelve un evento", bool(ev_mgr.get("ok", false)), str(ev_mgr))

	# Viajes narrativos: con capítulo 0 no hay ninguno disponible.
	var narr_disponibles: Array = TM.call("viajes_narrativos_disponibles")
	_check("sin capítulo alcanzado no hay viajes narrativos", narr_disponibles.is_empty(), str(narr_disponibles))

	# Limpieza de hooks.
	TM.call("forzar_cartera", -1)
	TM.call("forzar_contexto", -1, -1, "", -1)
	TM.call("forzar_fecha", -1, -1, -1, -1, -1, -1)
	_check("los hooks se limpian", (TM.call("fecha_forzada") as Dictionary).is_empty())
	_fin("H. manager")


## ── Utilidades ──────────────────────────────────────────

func _cargar_anclas_m69() -> Array:
	var out: Array = []
	var ruta := "res://data/fasttravel/anclas.json"
	if not FileAccess.file_exists(ruta):
		return out
	var f := FileAccess.open(ruta, FileAccess.READ)
	if f == null:
		return out
	var crudo: String = f.get_as_text()
	f.close()
	var datos: Variant = JSON.parse_string(crudo)
	if not (datos is Dictionary):
		return out
	var d: Dictionary = datos
	var viajes: Dictionary = d.get("viajes", {}) if d.get("viajes", null) is Dictionary else {}
	for isla in viajes.keys():
		var entrada: Dictionary = viajes[isla] if viajes[isla] is Dictionary else {}
		for a in entrada.get("anclas", []):
			if a is Dictionary:
				out.append(a)
	return out


func _contiene(lista: Array, fragmento: String) -> bool:
	for x in lista:
		if str(x).contains(fragmento):
			return true
	return false


func _contiene_alguna(lista: Variant, fragmentos: Array) -> bool:
	if not (lista is Array):
		return false
	for x in lista:
		for fr in fragmentos:
			if str(x).contains(str(fr)):
				return true
	return false


## ── Resumen ─────────────────────────────────────────────

func _summary() -> void:
	# GUARDA ANTI-FALSO-VERDE (M124): si un bloque abortó en silencio, su `_fin()`
	# no corrió. Un "0 fallos" con bloques faltantes es MENTIRA y debe fallar.
	var faltantes: Array[String] = []
	for letra in BLOQUES_ESPERADOS:
		if not _completados.has(letra):
			faltantes.append(letra)
	_check("los 8 bloques se completaron (sin abortos silenciosos)", faltantes.is_empty(),
		"bloques que no terminaron: %s" % str(faltantes))
	print("Checks por bloque: %s" % str(_checks_por_bloque))
	print("\n=== Resumen M68 iter.2: %d checks, %d fallos ===" % [_checks, _fallos])
	if _abortado:
		print("TEST M68 iter.2 ABORTADO por watchdog")
		quit(1)
	elif _fallos == 0:
		print("TEST M68 iter.2 OK — todos los checks pasaron")
		quit(0)
	else:
		print("TEST M68 iter.2 FALLÓ — %d checks fallaron" % _fallos)
		quit(1)
