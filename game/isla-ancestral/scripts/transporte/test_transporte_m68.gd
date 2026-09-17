# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-11
#
# M68 iter. 1 — Test headless del núcleo data-driven de Transporte y Navegación:
#   T-017  transport_network.tres como única fuente de verdad
#   T-002  cargar el grafo de paradas/rutas desde el .tres
#   T-003  exponer API list_routes / buy_ticket (contrato para M53)
#   T-020  testear el grafo (dijkstra, orden de paradas, grafo simple)
#   T-049  persistencia de waypoints (M59)
#   + costes (M38), descuento (M20), horario (M29), clima (M32), desbloqueo (M71)
#
# Determinista: usa los hooks `forzar_contexto` / `forzar_cartera` del manager,
# así no depende del reloj, el clima ni el saldo reales de los autoloads.
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/transporte/test_transporte_m68.gd
# Exit code != 0 si algún check falla.

extends SceneTree

var _fallos: int = 0
var _checks: int = 0
var _senales: Array = []
## El autoload se resuelve por NODO (no como identificador global): en modo
## --script el script se compila ANTES de que existan los autoloads, así que
## `TransportManager` como identificador da "Identifier not found".
var TM: Node = null


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== [M68] Transporte y Navegación — núcleo data-driven ===")
	TM = root.get_node_or_null("TransportManager")
	if TM == null:
		print("  [FAIL] autoload TransportManager ausente")
		_checks += 1
		_fallos += 1
		_summary()
		return
	_check("autoload TransportManager presente", true)
	_test_dataset()
	_test_validar_detecta_errores()
	_test_dijkstra()
	_test_vecinos_y_alcanzables()
	_test_unidades_stop_route()
	_test_list_routes()
	_test_buy_ticket()
	_test_planificar()
	_test_desbloqueo()
	_test_waypoints()
	_test_persistencia()
	_test_senales()
	_summary()


## ── Helpers ─────────────────────────────────────────────

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])


func _ruta_por_id(rutas: Array, id: String) -> Dictionary:
	for r in rutas:
		if String(r.get("route_id", "")) == id:
			return r
	return {}


## ── A. Dataset y grafo ──────────────────────────────────

func _test_dataset() -> void:
	print("\n-- A. Dataset y grafo --")
	var red: TransportNetwork = TM.red()
	_check("la red se cargó desde el .tres", red != null)
	if red == null:
		return
	_check("10 paradas en el dataset", red.contar_stops() == 10, "got %d" % red.contar_stops())
	_check("20 rutas en el dataset", red.contar_rutas() == 20, "got %d" % red.contar_rutas())
	_check("schema_version = 1", red.schema_version == 1)
	_check("grafo válido (validar() vacío)", red.validar().is_empty(), str(red.validar()))
	_check("es_valida() coincide con validar()", red.es_valida() == red.validar().is_empty())

	# IDs únicos de parada
	var ids: Dictionary = {}
	var dup: bool = false
	for s in red.stops:
		if ids.has(s.id):
			dup = true
		ids[s.id] = true
	_check("ids de parada únicos", not dup)
	_check("ids de parada no vacíos", not ids.has(&""))

	# Pares dirigidos únicos
	var pares: Dictionary = {}
	var dup_par: bool = false
	for r in red.routes:
		var k: String = "%s>%s" % [r.from_id, r.to_id]
		if pares.has(k):
			dup_par = true
		pares[k] = true
	_check("pares dirigidos únicos (grafo simple)", not dup_par)

	# Endpoints existen
	var ok_endpoints: bool = true
	for r in red.routes:
		if not red.tiene_stop(r.from_id) or not red.tiene_stop(r.to_id):
			ok_endpoints = false
	_check("todos los endpoints de las rutas existen", ok_endpoints)

	# Tipos
	var tipos_ok: bool = true
	for s in red.stops:
		if not s.tipo in ["barco", "dirigible", "tren", "muelle"]:
			tipos_ok = false
	_check("todos los tipos de parada son válidos", tipos_ok)
	_check("hay 4 tipos distintos (barco/muelle/tren/dirigible)",
		_contar_tipos(red) == 4, "got %d" % _contar_tipos(red))

	# Huella determinista
	var h1: String = red.huella()
	var h2: String = red.huella()
	_check("huella determinista (2 llamadas iguales)", h1 == h2)
	_check("huella no vacía", not h1.is_empty())
	_check("huella incluye los 10 ids", h1.begins_with("10:") and h1.contains("puerto_aurora"))

	# Búsquedas
	_check("stop() encuentra puerto_aurora", red.stop(&"puerto_aurora") != null)
	_check("stop() devuelve null si no existe", red.stop(&"no_existe") == null)
	_check("ruta() encuentra r_aurora_sur", red.ruta(&"r_aurora_sur") != null)
	_check("ruta() devuelve null si no existe", red.ruta(&"no_existe") == null)
	_check("tiene_stop() true/false", red.tiene_stop(&"puerto_sur") and not red.tiene_stop(&"nope"))


func _contar_tipos(red: TransportNetwork) -> int:
	var tipos: Dictionary = {}
	for s in red.stops:
		tipos[s.tipo] = true
	return tipos.size()


## ── B. validar() detecta errores ────────────────────────

func _test_validar_detecta_errores() -> void:
	print("\n-- B. validar() detecta errores --")
	var mala := TransportNetwork.new()

	var s1 := TransportStop.new()
	s1.id = &"a"
	s1.tipo = "barco"
	var s2 := TransportStop.new()
	s2.id = &"a"          # duplicado
	s2.tipo = "trineo"    # tipo inválido
	var s3 := TransportStop.new()
	s3.id = &""           # sin id
	var s4 := TransportStop.new()
	s4.id = &"b"
	s4.tipo = "tren"
	mala.stops = [s1, s2, s3, s4]

	var r1 := TransportRoute.new()
	r1.id = &"x"
	r1.from_id = &"a"
	r1.to_id = &"zzz"     # destino inexistente
	r1.base_cost = -5     # coste negativo
	r1.duracion_seg = 0.0 # duración no positiva
	var r2 := TransportRoute.new()
	r2.id = &"y"
	r2.from_id = &"a"
	r2.to_id = &"a"       # bucle
	r2.base_cost = 10
	r2.duracion_seg = 5.0
	var r3 := TransportRoute.new()
	r3.id = &"x"          # id duplicado
	r3.from_id = &"a"
	r3.to_id = &"b"
	r3.base_cost = 10
	r3.duracion_seg = 5.0
	var r4 := TransportRoute.new()
	r4.id = &"z"
	r4.from_id = &"a"
	r4.to_id = &"b"       # par dirigido duplicado
	r4.base_cost = 10
	r4.duracion_seg = 5.0
	mala.routes = [r1, r2, r3, r4]

	var errs: Array[String] = mala.validar()
	var txt: String = " | ".join(errs)
	_check("red mala: validar() no vacío", not errs.is_empty())
	_check("detecta id de parada duplicado", txt.contains("id de parada duplicado"))
	_check("detecta parada sin id", txt.contains("parada sin id"))
	_check("detecta tipo de parada desconocido", txt.contains("tipo desconocido"))
	_check("detecta origen/destino inexistente", txt.contains("destino inexistente"))
	_check("detecta bucle (origen == destino)", txt.contains("bucle"))
	_check("detecta par dirigido duplicado", txt.contains("par dirigido duplicado"))
	_check("detecta coste negativo", txt.contains("coste negativo"))
	_check("detecta duración no positiva", txt.contains("duración no positiva"))
	_check("detecta id de ruta duplicado", txt.contains("id de ruta duplicado"))
	_check("es_valida() false en red mala", not mala.es_valida())
	_check("la red buena sigue siendo válida tras crear la mala", TM.red().es_valida())


## ── C. Dijkstra (camino más barato) ─────────────────────

func _test_dijkstra() -> void:
	print("\n-- C. Dijkstra --")
	var red: TransportNetwork = TM.red()
	if red == null:
		return

	var d1: Dictionary = red.ruta_mas_barata(&"puerto_aurora", &"muelle_raiz_sur")
	_check("aurora→muelle ok", bool(d1.get("ok", false)))
	_check("aurora→muelle 1 salto", int(d1.get("saltos", -1)) == 1)
	_check("aurora→muelle coste 8", int(d1.get("coste", -1)) == 8)

	var d2: Dictionary = red.ruta_mas_barata(&"puerto_aurora", &"puerto_sur")
	_check("aurora→sur ok", bool(d2.get("ok", false)))
	_check("aurora→sur 2 saltos (vía muelle)", int(d2.get("saltos", -1)) == 2, str(d2.get("paradas")))
	_check("aurora→sur coste 68 (8+60)", int(d2.get("coste", -1)) == 68, "got %d" % int(d2.get("coste", -1)))
	_check("aurora→sur paradas [aurora, muelle, sur]",
		str(d2.get("paradas", [])) == str(["puerto_aurora", "muelle_raiz_sur", "puerto_sur"]), str(d2.get("paradas")))
	_check("aurora→sur rutas [r_aurora_muelle, r_muelle_sur]",
		str(d2.get("rutas", [])) == str(["r_aurora_muelle", "r_muelle_sur"]), str(d2.get("rutas")))
	_check("aurora→sur duración 60.0 (5+55)", is_equal_approx(float(d2.get("duracion", 0.0)), 60.0))

	# Propiedad de diseño: el directo es MÁS CARO que combinar.
	var directo: TransportRoute = red.ruta(&"r_aurora_sur")
	_check("coste directo (80) > combinado (68)", directo.base_cost > int(d2.get("coste", 0)))
	var directo_este: TransportRoute = red.ruta(&"r_aurora_este")
	var d3: Dictionary = red.ruta_mas_barata(&"puerto_aurora", &"puerto_este")
	_check("aurora→este combinado 78 (8+70)", int(d3.get("coste", -1)) == 78, "got %d" % int(d3.get("coste", -1)))
	_check("coste directo este (90) > combinado (78)", directo_este.base_cost > int(d3.get("coste", 0)))

	# Multi-salto obligatorio
	var d4: Dictionary = red.ruta_mas_barata(&"puerto_aurora", &"puerto_norte")
	_check("aurora→norte ok (sin ruta directa)", bool(d4.get("ok", false)))
	_check("aurora→norte 2 saltos por la plataforma", int(d4.get("saltos", -1)) == 2, str(d4.get("paradas")))
	_check("aurora→norte coste 120 (20+100)", int(d4.get("coste", -1)) == 120, "got %d" % int(d4.get("coste", -1)))
	_check("aurora→norte pasa por plataforma_norte",
		str(d4.get("paradas", [])).contains("plataforma_norte"))

	# Origen == destino
	var d5: Dictionary = red.ruta_mas_barata(&"puerto_aurora", &"puerto_aurora")
	_check("aurora→aurora ok con coste 0", bool(d5.get("ok", false)) and int(d5.get("coste", -1)) == 0)
	_check("aurora→aurora 0 saltos", int(d5.get("saltos", -1)) == 0)

	# Paradas sin salida → sin camino
	var d6: Dictionary = red.ruta_mas_barata(&"puerto_brisa", &"puerto_sur")
	_check("brisa→sur sin camino (brisa no tiene salidas)", not bool(d6.get("ok", false)))
	_check("sin camino devuelve motivo", String(d6.get("motivo", "")) != "")
	var d7: Dictionary = red.ruta_mas_barata(&"puerto_espejo", &"puerto_aurora")
	_check("espejo→aurora sin camino (arista sólo de ida)", not bool(d7.get("ok", false)))

	# Parada inexistente
	var d8: Dictionary = red.ruta_mas_barata(&"nope", &"puerto_sur")
	_check("parada inexistente → ok=false", not bool(d8.get("ok", false)))

	# Alias del nombre del diseño
	var d9: Dictionary = red.ruta_mas_corta(&"puerto_aurora", &"puerto_sur")
	_check("ruta_mas_corta() alias de ruta_mas_barata()", int(d9.get("coste", -1)) == 68)


## ── D. Vecinos y alcanzables ────────────────────────────

func _test_vecinos_y_alcanzables() -> void:
	print("\n-- D. Vecinos y alcanzables --")
	var red: TransportNetwork = TM.red()
	if red == null:
		return
	var v: Array[StringName] = red.vecinos(&"puerto_aurora")
	_check("aurora tiene 7 vecinos directos", v.size() == 7, "got %d: %s" % [v.size(), str(v)])
	_check("vecinos incluye muelle/estación/plataforma",
		v.has(&"muelle_raiz_sur") and v.has(&"estacion_central") and v.has(&"plataforma_norte"))
	_check("vecinos sin duplicados", _sin_duplicados(v))
	_check("vecinos de brisa = [] (sin salidas)", red.vecinos(&"puerto_brisa").is_empty())
	_check("rutas_desde() coincide con vecinos", red.rutas_desde(&"puerto_aurora").size() == 7)

	var alc: Array[StringName] = red.alcanzables_desde(&"puerto_aurora")
	_check("alcanzables desde aurora = 9 (todas menos ella)", alc.size() == 9, "got %d" % alc.size())
	_check("alcanzables incluye puerto_norte (multi-salto)", alc.has(&"puerto_norte"))
	_check("alcanzables no incluye aurora", not alc.has(&"puerto_aurora"))
	_check("alcanzables desde brisa = [] ", red.alcanzables_desde(&"puerto_brisa").is_empty())


func _sin_duplicados(a: Array) -> bool:
	var vistos: Dictionary = {}
	for x in a:
		if vistos.has(x):
			return false
		vistos[x] = true
	return true


## ── E. Unidades de TransportStop / TransportRoute ───────

func _test_unidades_stop_route() -> void:
	print("\n-- E. Unidades Stop/Route --")
	var s := TransportStop.new()
	s.horario_apertura = 6
	s.horario_cierre = 22
	_check("abierta_a(12) true", s.abierta_a(12))
	_check("abierta_a(5) false", not s.abierta_a(5))
	_check("abierta_a(22) false (cierre exclusivo)", not s.abierta_a(22))
	_check("abierta_a(6) true (apertura inclusiva)", s.abierta_a(6))
	_check("horario_texto()", s.horario_texto() == "06:00-22:00")

	var nocturna := TransportStop.new()
	nocturna.horario_apertura = 22
	nocturna.horario_cierre = 5
	_check("horario nocturno abierta_a(23)", nocturna.abierta_a(23))
	_check("horario nocturno abierta_a(2)", nocturna.abierta_a(2))
	_check("horario nocturno cerrada a las 12", not nocturna.abierta_a(12))

	var continua := TransportStop.new()
	continua.horario_apertura = 8
	continua.horario_cierre = 8
	_check("horario 8-8 = 24 h", continua.abierta_a(3) and continua.abierta_a(15))

	var r := TransportRoute.new()
	r.base_cost = 100
	r.duracion_seg = 40.0
	r.medio = "barco"
	_check("coste sin descuento (nivel 4) = 100", r.coste_con_descuento(4) == 100)
	_check("coste con descuento (nivel 5) = 80", r.coste_con_descuento(5) == 80)
	_check("coste con descuento (nivel 9) = 80", r.coste_con_descuento(9) == 80)
	_check("barco afectado por clima", r.afectada_por_clima())
	_check("barco con clima adverso +25% = 50", is_equal_approx(r.duracion_con_clima(1.0), 50.0))
	_check("barco sin clima = 40", is_equal_approx(r.duracion_con_clima(0.0), 40.0))
	var tren := TransportRoute.new()
	tren.medio = "tren"
	tren.duracion_seg = 10.0
	_check("tren NO afectado por clima", not tren.afectada_por_clima())
	_check("tren con clima adverso = 10 (sin cambio)", is_equal_approx(tren.duracion_con_clima(1.0), 10.0))
	_check("diccionario de ruta tiene las claves del contrato",
		r.a_diccionario().has("id") and r.a_diccionario().has("coste") and r.a_diccionario().has("medio"))


## ── F. list_routes (contrato para M53) ──────────────────

func _test_list_routes() -> void:
	print("\n-- F. list_routes --")
	TM.forzar_contexto(12, 0, "primavera", 0)
	var rutas: Array[Dictionary] = TM.list_routes(&"puerto_aurora")
	_check("aurora ofrece 7 rutas a mediodía", rutas.size() == 7, "got %d" % rutas.size())

	var r_sur: Dictionary = _ruta_por_id(rutas, "r_aurora_sur")
	_check("la ruta a sur está en la lista", not r_sur.is_empty())
	_check("contrato: route_id/from/to/precio/duracion/horario",
		r_sur.has("route_id") and r_sur.has("from") and r_sur.has("to") and r_sur.has("precio")
		and r_sur.has("duracion") and r_sur.has("horario"))
	_check("precio sin amistad = 80", int(r_sur.get("precio", -1)) == 80)
	_check("precio_base = 80", int(r_sur.get("precio_base", -1)) == 80)
	_check("duración = 60 s", is_equal_approx(float(r_sur.get("duracion", 0.0)), 60.0))
	_check("horario del destino = 07:00-21:00", String(r_sur.get("horario", "")) == "07:00-21:00")
	_check("disponible = true", bool(r_sur.get("disponible", false)))
	_check("motivo_bloqueo vacío si disponible", String(r_sur.get("motivo_bloqueo", "x")).is_empty())
	_check("to_nombre es el fallback en español", String(r_sur.get("to_nombre", "")) == "Puerto de la Isla del Sur")

	# Descuento M20
	TM.forzar_contexto(12, 0, "primavera", 5)
	var rutas_desc: Array[Dictionary] = TM.list_routes(&"puerto_aurora")
	var r_desc: Dictionary = _ruta_por_id(rutas_desc, "r_aurora_sur")
	_check("con amistad 5 el precio baja a 64", int(r_desc.get("precio", -1)) == 64, "got %d" % int(r_desc.get("precio", -1)))
	_check("precio_base sigue siendo 80", int(r_desc.get("precio_base", -1)) == 80)

	# Horario M29: fuera de horario el destino se bloquea
	TM.forzar_contexto(23, 0, "primavera", 0)
	var rutas_noche: Array[Dictionary] = TM.list_routes(&"puerto_aurora")
	var r_noche: Dictionary = _ruta_por_id(rutas_noche, "r_aurora_sur")
	_check("a las 23:00 la ruta a sur no está disponible", not bool(r_noche.get("disponible", true)))
	_check("motivo menciona el horario", String(r_noche.get("motivo_bloqueo", "")).contains("horario"))
	var r_tren: Dictionary = _ruta_por_id(rutas_noche, "r_aurora_estacion")
	_check("la estación (6-21) tampoco a las 23", not bool(r_tren.get("disponible", true)))

	# Clima M32: tormenta bloquea barcos, no trenes/muelles
	TM.forzar_contexto(12, 3, "primavera", 0)
	var rutas_tormenta: Array[Dictionary] = TM.list_routes(&"puerto_aurora")
	var r_torm: Dictionary = _ruta_por_id(rutas_tormenta, "r_aurora_sur")
	_check("con tormenta el barco no está disponible", not bool(r_torm.get("disponible", true)))
	_check("motivo menciona el clima", String(r_torm.get("motivo_bloqueo", "")).contains("clima"))
	var r_muelle_torm: Dictionary = _ruta_por_id(rutas_tormenta, "r_aurora_muelle")
	_check("con tormenta el muelle sigue disponible", bool(r_muelle_torm.get("disponible", false)))
	var r_tren_torm: Dictionary = _ruta_por_id(rutas_tormenta, "r_aurora_estacion")
	_check("con tormenta el tren sigue disponible", bool(r_tren_torm.get("disponible", false)))
	_check("con tormenta el dirigible sigue disponible (viento = pendiente M32)",
		bool(_ruta_por_id(rutas_tormenta, "r_aurora_plataforma").get("disponible", false)))

	# Destino bloqueado por flag (M71/M22)
	TM.forzar_contexto(12, 0, "primavera", 0)
	var r_brisa: Dictionary = _ruta_por_id(TM.list_routes(&"puerto_aurora"), "r_aurora_brisa")
	_check("brisa bloqueada sin la flag de historia", not bool(r_brisa.get("disponible", true)))
	_check("motivo de brisa menciona el bloqueo", String(r_brisa.get("motivo_bloqueo", "")).contains("bloqueado"))

	# Gate de RUTA (distinto del gate de parada): espejo tiene la parada abierta
	# pero la ruta exige la flag de historia.
	var r_espejo: Dictionary = _ruta_por_id(TM.list_routes(&"puerto_aurora"), "r_aurora_espejo")
	_check("espejo bloqueado por flag de RUTA (no de parada)", not bool(r_espejo.get("disponible", true)))
	_check("motivo de espejo menciona el progreso", String(r_espejo.get("motivo_bloqueo", "")).contains("requiere progreso"))

	# Temporada (M29)
	TM.forzar_contexto(12, 0, "invierno", 0)
	var r_brisa_inv: Dictionary = _ruta_por_id(TM.list_routes(&"puerto_aurora"), "r_aurora_brisa")
	_check("brisa tampoco en invierno (aunque estuviera desbloqueada)",
		not bool(r_brisa_inv.get("disponible", true)))

	# Señal de listado
	TM.forzar_contexto(12, 0, "primavera", 0)


## ── G. buy_ticket y ciclo del viaje ─────────────────────

func _test_buy_ticket() -> void:
	print("\n-- G. buy_ticket --")
	TM.forzar_contexto(12, 0, "primavera", 0)
	TM.forzar_cartera(1000)

	var b1: Dictionary = TM.buy_ticket(&"r_aurora_sur", &"puerto_aurora")
	_check("compra ok", bool(b1.get("ok", false)), str(b1))
	_check("precio cobrado 80", int(b1.get("precio", -1)) == 80)
	_check("el viaje queda en curso", String(TM.viaje_en_curso()) == "r_aurora_sur")
	_check("saldo simulado 920", TM.saldo_simulado() == 920, "got %d" % TM.saldo_simulado())

	var b2: Dictionary = TM.buy_ticket(&"r_aurora_este", &"puerto_aurora")
	_check("segundo boleto rechazado (viaje en curso)", not bool(b2.get("ok", true)))
	_check("motivo del rechazo menciona el viaje en curso", String(b2.get("motivo", "")).contains("viaje en curso"))
	_check("el saldo no cambió con el rechazo", TM.saldo_simulado() == 920)

	var fin: Dictionary = TM.notificar_llegada()
	_check("llegada ok", bool(fin.get("ok", false)))
	_check("el viaje se cierra", String(TM.viaje_en_curso()).is_empty())
	_check("llegada reporta el destino", String(fin.get("to", "")) == "puerto_sur")
	_check("llegada sin viaje activo → ok=false", not bool(TM.notificar_llegada().get("ok", true)))

	# Ruta inexistente / desde otra parada
	var b3: Dictionary = TM.buy_ticket(&"no_existe", &"puerto_aurora")
	_check("ruta inexistente rechazada", not bool(b3.get("ok", true)))
	var b4: Dictionary = TM.buy_ticket(&"r_aurora_sur", &"puerto_este")
	_check("ruta que no sale de la parada rechazada", not bool(b4.get("ok", true)))
	_check("motivo de b4 correcto", String(b4.get("motivo", "")).contains("no sale"))

	# Destino bloqueado
	var b5: Dictionary = TM.buy_ticket(&"r_aurora_brisa", &"puerto_aurora")
	_check("boleto a destino bloqueado rechazado", not bool(b5.get("ok", true)))

	# Saldo insuficiente (M38)
	TM.forzar_cartera(10)
	var b6: Dictionary = TM.buy_ticket(&"r_aurora_sur", &"puerto_aurora")
	_check("saldo insuficiente rechaza la compra", not bool(b6.get("ok", true)))
	_check("motivo menciona AO insuficiente", String(b6.get("motivo", "")).contains("insuficiente"))
	_check("precio reportado aunque falle", int(b6.get("precio", -1)) == 80)
	_check("el saldo no se tocó", TM.saldo_simulado() == 10)
	_check("no quedó viaje en curso", String(TM.viaje_en_curso()).is_empty())

	# Compra con descuento
	TM.forzar_contexto(12, 0, "primavera", 5)
	TM.forzar_cartera(100)
	var b7: Dictionary = TM.buy_ticket(&"r_aurora_sur", &"puerto_aurora")
	_check("compra con descuento ok", bool(b7.get("ok", false)))
	_check("precio con descuento 64", int(b7.get("precio", -1)) == 64)
	_check("saldo tras descuento 36", TM.saldo_simulado() == 36)
	TM.notificar_llegada()

	# Sin cartera simulada el manager vuelve a M38 real
	TM.forzar_cartera(-1)
	TM.forzar_contexto(12, 0, "primavera", 0)


## ── H. planificar ───────────────────────────────────────

func _test_planificar() -> void:
	print("\n-- H. planificar --")
	TM.forzar_contexto(12, 0, "primavera", 0)
	var p1: Dictionary = TM.planificar(&"puerto_aurora", &"puerto_sur")
	_check("planificar aurora→sur ok", bool(p1.get("ok", false)))
	_check("planificar coste 68", int(p1.get("coste", -1)) == 68)
	_check("planificar expone precio", int(p1.get("precio", -1)) == 68)
	_check("planificar 2 saltos", int(p1.get("saltos", -1)) == 2)

	var p2: Dictionary = TM.planificar(&"puerto_aurora", &"puerto_brisa")
	_check("planificar a destino bloqueado → sin camino", not bool(p2.get("ok", false)))

	TM.forzar_contexto(23, 0, "primavera", 0)
	var p3: Dictionary = TM.planificar(&"puerto_aurora", &"puerto_sur")
	_check("a las 23 el plan a sur falla (destino cerrado)", not bool(p3.get("ok", false)))
	TM.forzar_contexto(12, 0, "primavera", 0)


## ── I. Desbloqueo (M71) ─────────────────────────────────

func _test_desbloqueo() -> void:
	print("\n-- I. Desbloqueo --")
	_check("aurora desbloqueada de inicio", TM.esta_parada_desbloqueada(&"puerto_aurora"))
	_check("brisa NO desbloqueada de inicio (requiere flag)", not TM.esta_parada_desbloqueada(&"puerto_brisa"))
	_check("parada inexistente → false", not TM.esta_parada_desbloqueada(&"nope"))
	_check("desbloquear brisa devuelve true", TM.desbloquear_parada(&"puerto_brisa"))
	_check("brisa ahora desbloqueada", TM.esta_parada_desbloqueada(&"puerto_brisa"))
	_check("desbloquear de nuevo devuelve false (idempotente)", not TM.desbloquear_parada(&"puerto_brisa"))
	_check("desbloquear inexistente devuelve false", not TM.desbloquear_parada(&"nope"))
	# Con brisa desbloqueada y verano, la ruta aparece
	TM.forzar_contexto(12, 0, "verano", 0)
	var r_brisa: Dictionary = _ruta_por_id(TM.list_routes(&"puerto_aurora"), "r_aurora_brisa")
	_check("en verano y desbloqueada, brisa disponible", bool(r_brisa.get("disponible", false)), str(r_brisa.get("motivo_bloqueo")))
	TM.forzar_contexto(12, 0, "invierno", 0)
	var r_brisa_inv: Dictionary = _ruta_por_id(TM.list_routes(&"puerto_aurora"), "r_aurora_brisa")
	_check("desbloqueada pero en invierno sigue bloqueada por temporada",
		not bool(r_brisa_inv.get("disponible", true)))
	_check("motivo menciona la temporada", String(r_brisa_inv.get("motivo_bloqueo", "")).contains("sólo en"))
	TM.forzar_contexto(12, 0, "primavera", 0)


## ── J. Waypoints (M59) ──────────────────────────────────

func _test_waypoints() -> void:
	print("\n-- J. Waypoints --")
	_check("sin waypoints al inicio", TM.waypoints().is_empty())
	_check("agregar waypoint válido", TM.agregar_waypoint(&"puerto_sur"))
	_check("tiene_waypoint true", TM.tiene_waypoint(&"puerto_sur"))
	_check("agregar duplicado devuelve false", not TM.agregar_waypoint(&"puerto_sur"))
	_check("sigue habiendo 1 waypoint", TM.waypoints().size() == 1)
	_check("agregar inexistente devuelve false", not TM.agregar_waypoint(&"nope"))
	_check("agregar un segundo waypoint", TM.agregar_waypoint(&"puerto_este"))
	_check("hay 2 waypoints", TM.waypoints().size() == 2)
	_check("quitar waypoint existente", TM.quitar_waypoint(&"puerto_sur"))
	_check("ya no tiene el waypoint", not TM.tiene_waypoint(&"puerto_sur"))
	_check("quitar de nuevo devuelve false", not TM.quitar_waypoint(&"puerto_sur"))
	_check("queda 1 waypoint", TM.waypoints().size() == 1)


## ── K. Persistencia (M59) ───────────────────────────────

func _test_persistencia() -> void:
	print("\n-- K. Persistencia --")
	_check("sección de guardado = transporte", TM.get_section_name() == "transporte")

	TM.agregar_waypoint(&"puerto_norte")
	TM.desbloquear_parada(&"puerto_brisa")
	var datos: Dictionary = TM.get_save_data()
	_check("get_save_data trae waypoints", (datos.get("waypoints", []) as Array).size() == 2)
	_check("get_save_data trae desbloqueadas", (datos.get("desbloqueadas", []) as Array).size() >= 1)
	_check("get_save_data trae viaje_activo", datos.has("viaje_activo"))

	# Anti-aliasing (BUG-014): mutar el resultado no debe tocar el estado interno.
	var w: Array = datos.get("waypoints", [])
	w.append("inyectado")
	_check("mutar el dict devuelto NO altera el estado (anti-aliasing)",
		not TM.tiene_waypoint(&"inyectado"))

	# Round-trip
	var snapshot: Dictionary = TM.get_save_data()
	TM.restore_save_data(snapshot)
	_check("round-trip conserva waypoints", TM.waypoints().size() == 2)
	_check("round-trip conserva el desbloqueo de brisa",
		TM.esta_parada_desbloqueada(&"puerto_brisa"))

	# Restaurar con datos mínimos no rompe
	TM.restore_save_data({})
	_check("restaurar {} deja waypoints vacíos", TM.waypoints().is_empty())
	_check("restaurar {} deja brisa bloqueada de nuevo",
		not TM.esta_parada_desbloqueada(&"puerto_brisa"))

	# Ruta huérfana: un save con una ruta que ya no existe → viaje descartado
	TM.forzar_cartera(1000)
	TM.forzar_contexto(12, 0, "primavera", 0)
	TM.buy_ticket(&"r_aurora_sur", &"puerto_aurora")
	_check("viaje en curso antes de restaurar", String(TM.viaje_en_curso()) == "r_aurora_sur")
	TM.restore_save_data({"desbloqueadas": [], "waypoints": [], "viaje_activo": "r_inexistente"})
	_check("ruta huérfana descarta el viaje (nunca soft-lock)",
		String(TM.viaje_en_curso()).is_empty())
	TM.restore_save_data({"desbloqueadas": [], "waypoints": [], "viaje_activo": "r_aurora_sur"})
	_check("ruta válida se restaura", String(TM.viaje_en_curso()) == "r_aurora_sur")
	TM.notificar_llegada()
	TM.forzar_cartera(-1)

	# Limpieza final
	TM.restore_save_data({"desbloqueadas": [], "waypoints": [], "viaje_activo": ""})


## ── L. Señales ──────────────────────────────────────────

func _test_senales() -> void:
	print("\n-- L. Señales --")
	_senales.clear()
	# Lambdas con los argumentos absorbidos: cada señal tiene aridad distinta.
	TM.viaje_iniciado.connect(func(_r = null, _c = null): _senales.append("viaje_iniciado"))
	TM.viaje_llegado.connect(func(_r = null, _s = null): _senales.append("viaje_llegado"))
	TM.parada_desbloqueada.connect(func(_s = null): _senales.append("parada_desbloqueada"))
	TM.waypoint_agregado.connect(func(_s = null): _senales.append("waypoint_agregado"))
	TM.waypoint_quitado.connect(func(_s = null): _senales.append("waypoint_quitado"))
	TM.rutas_listadas.connect(func(_s = null, _l = null): _senales.append("rutas_listadas"))

	TM.forzar_contexto(12, 0, "primavera", 0)
	TM.forzar_cartera(1000)
	TM.list_routes(&"puerto_aurora")
	_check("list_routes emite rutas_listadas", _senales.has("rutas_listadas"), str(_senales))

	TM.buy_ticket(&"r_aurora_sur", &"puerto_aurora")
	_check("buy_ticket emite viaje_iniciado", _senales.has("viaje_iniciado"), str(_senales))
	TM.notificar_llegada()
	_check("notificar_llegada emite viaje_llegado", _senales.has("viaje_llegado"), str(_senales))

	TM.agregar_waypoint(&"puerto_sur")
	_check("agregar_waypoint emite waypoint_agregado", _senales.has("waypoint_agregado"), str(_senales))
	TM.quitar_waypoint(&"puerto_sur")
	_check("quitar_waypoint emite waypoint_quitado", _senales.has("waypoint_quitado"), str(_senales))

	TM.desbloquear_parada(&"puerto_festival")
	_check("desbloquear_parada emite parada_desbloqueada", _senales.has("parada_desbloqueada"), str(_senales))

	TM.forzar_cartera(-1)
	TM.restore_save_data({"desbloqueadas": [], "waypoints": [], "viaje_activo": ""})


## ── Resumen ─────────────────────────────────────────────

func _summary() -> void:
	print("\n=== Resumen M68: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos == 0:
		print("TEST M68 OK — todos los checks pasaron")
		quit(0)
	else:
		print("TEST M68 FALLÓ — %d checks fallaron" % _fallos)
		quit(1)
