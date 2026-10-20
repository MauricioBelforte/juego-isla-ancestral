# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M69: Test headless del FastTravelService (anclas, desbloqueo, viaje).
extends SceneTree

var _fallos := 0
var _checks := 0

## Guardián anti-falso-verde: piso MEDIDO en la corrida real.
const CHECKS_MINIMOS: int = 54

func _init() -> void:
	call_deferred("_run")

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FALLO] %s" % nombre)

func _run() -> void:
	print("=== [M69] Test del FastTravelService ===")
	var svc = load("res://scripts/fasttravel/fast_travel_service.gd").new()
	root.add_child(svc)
	await process_frame
	_check("Service: 4 anclas cargadas", svc.anclas().size() == 4)
	_check("Service: las 4 desbloqueadas (base)", svc.anclas_desbloqueadas().size() == 4)
	_check("Service: ancla con coords (256,256)", svc.anclas()[0].get("x") == 256 and svc.anclas()[0].get("z") == 256)
	# desbloqueo incremental de una nueva
	var count_before = svc.anclas_desbloqueadas().size()
	svc.desbloquear("ancla_plaza")
	_check("Service: re-desbloqueo no duplica", svc.anclas_desbloqueadas().size() == count_before)
	# solicitud de viaje
	var solicitud = [false]
	svc.viaje_solicitado.connect(_on_viaje.bind(solicitud))
	var ok_viaje = svc.solicitar_viaje("LOC-RIZ-CASA-001")
	_check("Service: viaje solicitable (ancla desbloqueada)", ok_viaje)
	_check("Service: señal viaje emitida", solicitud[0])
	var ok_invalido = svc.solicitar_viaje("ancla_inexistente")
	_check("Service: ancla inexistente -> false", not ok_invalido)
	_b2_indice_costo(svc)
	_b3_restriccion_temporal(svc)
	_b4_costo_distancia(svc)
	_b5_waypoints_m28(svc)
	_b6_persistencia()
	_b7_portal_falla(svc)
	_b8_carga_100(svc)
	_b9_mil_teleports(svc)
	_b10_dia_noche(svc)
	_b11_stress_50(svc)
	svc.free()
	_resumen()

## K.33 — estrés: 50 anclas activas con ráfagas de solicitudes simultáneas.
func _b11_stress_50(svc) -> void:
	svc.set_restriccion_temporal_fn(func() -> bool: return false)
	var base_desb: int = svc.anclas_desbloqueadas().size()
	for i in 50:
		var id := "ancla_stress_%d" % i
		svc._anclas.append({"id": id, "nombre": "Stress %d" % i, "isla": "RIZ", "x": 500 + i, "z": 700 + i, "desbloquea": false})
		svc._indice[id] = svc._anclas[svc._anclas.size() - 1]
		svc.desbloquear(id)
	_check("Stress: 50 anclas activas desbloqueadas", svc.anclas_desbloqueadas().size() == base_desb + 50)
	var concedidas := [0]
	svc.viaje_solicitado.connect(func(_a): concedidas[0] += 1)
	var t0 := Time.get_ticks_msec()
	for ronda in 2:
		for i in 50:
			if not svc.solicitar_viaje("ancla_stress_%d" % i):
				break
	var dt: int = Time.get_ticks_msec() - t0
	_check("Stress: 100 ráfagas (2×50) concedidas", concedidas[0] == 100)
	_check("Stress: ráfagas < 250 ms (%d ms)" % dt, dt < 250)
	_check("Stress: sin drift de desbloqueos tras ráfagas", svc.anclas_desbloqueadas().size() == base_desb + 50)
	svc.set_restriccion_temporal_fn(Callable())

## K.30 — 1000 teleports consecutivos sin drift de estado.
func _b9_mil_teleports(svc) -> void:
	svc.set_restriccion_temporal_fn(func() -> bool: return false)  # Ambiente determinista
	var base_desb: int = svc.anclas_desbloqueadas().size()
	var concedidos := [0]
	svc.viaje_solicitado.connect(func(_a): concedidos[0] += 1)
	var t0 := Time.get_ticks_msec()
	for i in 1000:
		if not svc.solicitar_viaje("LOC-RIZ-CASA-001"):
			break
	var dt: int = Time.get_ticks_msec() - t0
	_check("Teleports: 1000 consecutivos concedidos", concedidos[0] == 1000)
	_check("Teleports: presupuesto < 500 ms (%d ms)" % dt, dt < 500)
	_check("Teleports: sin drift de estado (desbloqueos estables)", svc.anclas_desbloqueadas().size() == base_desb)
	svc.set_restriccion_temporal_fn(Callable())

## K.31 — coherencia día/noche: la restricción sigue la definición de GameTime en 24 h.
func _b10_dia_noche(svc) -> void:
	var gt = root.get_node_or_null("GameTime")
	if gt == null or not gt.has_method("avanzar_hasta"):
		print("  [INFO] GameTime ausente — K.31 no verificada aquí")
		return
	var hora_antes: int = gt.get_hora()
	var we = root.get_node_or_null("Weather")
	var inconsistencias := 0
	for h in 24:
		gt.avanzar_hasta(h, 0)
		var tor := false
		if we != null and we.has_method("get_clima"):
			var cl: Variant = we.get("Clima")
			var tval: int = 3
			if cl is Dictionary and cl.has("TORMENTA"):
				tval = int(cl["TORMENTA"])
			tor = int(we.get_clima()) == tval
		var esperado: bool = (not bool(gt.es_de_dia())) or tor
		if svc.restriccion_temporal_activa() != esperado:
			inconsistencias += 1
	gt.avanzar_hasta(hora_antes, 0)
	_check("Día/Noche: 24 horas consistentes con GameTime+Weather (0 desvíos)", inconsistencias == 0)

## K.24 (M122) — portal roto: ancla sin coordenadas → rechazo "portal" + crash reportado.
func _b7_portal_falla(svc) -> void:
	_check("Portal: API reportar_falla_portal disponible", svc.has_method("reportar_falla_portal"))
	svc._anclas.append({"id": "ancla_rota", "nombre": "Rota", "isla": "RIZ", "desbloquea": true})
	svc._indice["ancla_rota"] = svc._anclas[svc._anclas.size() - 1]
	svc.desbloquear("ancla_rota")
	var crashes := []
	var cr = root.get_node_or_null("CrashReporter")
	if cr != null and cr.has_signal("crash_reportado"):
		cr.crash_reportado.connect(func(d): crashes.append(d))
	var viajes := []
	svc.viaje_solicitado.connect(func(a): viajes.append(a))
	var rechazos_portal := []
	svc.viaje_rechazado.connect(func(id, motivo): rechazos_portal.append([id, motivo]))
	var ok_rota = svc.solicitar_viaje("ancla_rota")
	_check("Portal: ancla sin coords -> false", not ok_rota)
	_check("Portal: rechazo con motivo 'portal'", rechazos_portal.size() == 1 and String(rechazos_portal[0][1]) == "portal")
	_check("Portal: crash reportado al CrashReporter real", crashes.size() >= 1)
	_check("Portal: señal de viaje NO emitida para portal roto", viajes.is_empty())
	# aceptación del portal con ancla sana (regresión del flujo)
	var ok_sana = svc.solicitar_viaje("LOC-RIZ-CASA-001")
	_check("Portal: ancla sana sigue concediendo viaje", ok_sana and viajes.size() == 1)

## K.29 — carga: 100 anclas adicionales, índice O(1) medible.
func _b8_carga_100(svc) -> void:
	var base: int = svc._anclas.size()
	var base_desb: int = svc.anclas_desbloqueadas().size()
	for i in 100:
		var id := "ancla_carga_%d" % i
		svc._anclas.append({"id": id, "nombre": "Carga %d" % i, "isla": "RIZ", "x": 100 + i, "z": 200 + i, "desbloquea": false})
		svc._indice[id] = svc._anclas[svc._anclas.size() - 1]
	_check("Carga: %d anclas totales (base %d + 100)" % [base + 100, base], svc.anclas().size() == base + 100)
	for i in 50:
		svc.desbloquear("ancla_carga_%d" % i)
	_check("Carga: %d desbloqueadas (base + 50)" % (base_desb + 50), svc.anclas_desbloqueadas().size() == base_desb + 50)
	var t0 := Time.get_ticks_msec()
	var hits := 0
	for i in 1000:
		if not svc.ancla_de("ancla_carga_%d" % (i % 100)).is_empty():
			hits += 1
	var dt := Time.get_ticks_msec() - t0
	_check("Carga: 1000 lookups O(1) correctos (%d ms)" % dt, hits == 1000 and dt < 100)
	svc.set_costo_distancia_fn(func(a: Dictionary) -> int: return 7)
	_check("Carga: costo por ancla escala a las nuevas", svc.costo_total_de("ancla_carga_99") == 7)
	svc.set_costo_distancia_fn(Callable())

## K.32 — recuperar estado sin perder progreso: desbloqueos persisten (M59).
func _b6_persistencia() -> void:
	var sm = root.get_node_or_null("SaveManager")
	_check("Persistencia: SaveManager presente (provider API)", sm != null and sm.has_method("register_provider"))

	# Instancia fresca: solo 2 anclas "recuperadas" del save.
	var s2 = load("res://scripts/fasttravel/fast_travel_service.gd").new()
	s2.registra_en_save = false  # evita colisión de sección con el servicio del boot
	root.add_child(s2)
	await process_frame
	_check("Persistencia: instancia nueva arranca con las 4 base", s2.anclas_desbloqueadas().size() == 4)
	s2.restore_save_data({"desbloqueadas": ["LOC-RIZ-PUB-001", "LOC-RIZ-CASA-001"]})
	_check("Persistencia: restore deja SOLO las 2 del save", s2.anclas_desbloqueadas().size() == 2
		and s2.esta_desbloqueada("LOC-RIZ-PUB-001") and s2.esta_desbloqueada("LOC-RIZ-CASA-001")
		and not s2.esta_desbloqueada("ancla_playa_norte"))

	# Round-trip: la data que exporta restore en una instancia nueva, idéntica.
	var d: Dictionary = s2.get_save_data()
	_check("Persistencia: get_save_data exporta 2 ids", d.get("desbloqueadas", []).size() == 2)
	var s3 = load("res://scripts/fasttravel/fast_travel_service.gd").new()
	s3.registra_en_save = false
	root.add_child(s3)
	await process_frame
	s3.restore_save_data(d)
	_check("Persistencia: round-trip idéntico en instancia nueva", s3.anclas_desbloqueadas().size() == 2
		and s3.esta_desbloqueada("LOC-RIZ-PUB-001"))

	# Idempotencia: re-restore no rompe ni duplica.
	s3.restore_save_data(d)
	_check("Persistencia: re-restore idempotent", s3.anclas_desbloqueadas().size() == 2)
	# Malformed: payload inválido es ignorado sin romper.
	s3.restore_save_data({"desbloqueadas": "no_soy_array"})
	_check("Persistencia: payload inválido ignorado", s3.anclas_desbloqueadas().size() == 2)
	s2.free()
	s3.free()

## K.21 (M28) — waypoints descubiertos: llegar por barco desbloquea anclas.
func _b5_waypoints_m28(svc) -> void:
	# La conexión duck-typed con el TravelService real del boot.
	svc._conectar_waypoints_m28()
	var ts = root.get_node_or_null("TravelService")
	if ts == null or not ts.has_signal("travel_arrived"):
		print("  [INFO] TravelService ausente — K.21 no verificada aquí")
		return
	_check("Waypoints: señal travel_arrived conectada", ts.travel_arrived.is_connected(svc._on_isla_descubierta))

	# Escenario observable: quito una ancla desbloqueada y la recupero llegando
	# a la isla (mapeo id-M28 -> clave RIZ del catálogo).
	var unlock_count := [0]
	svc.ancla_desbloqueada.connect(func(_id): unlock_count[0] += 1)
	svc._desbloqueadas.erase("ancla_playa_norte")
	_check("Waypoints: base 3 desbloqueadas tras consolidar", svc.anclas_desbloqueadas().size() == 3)
	svc.set_mapa_islas({"isla_prueba": "RIZ"})
	_check("Waypoints: mapa legible", svc.mapa_islas().get("isla_prueba", "") == "RIZ")
	ts.travel_arrived.emit("isla_prueba")
	_check("Waypoints: llegar a la isla desbloquea su ancla", svc.esta_desbloqueada("ancla_playa_norte") and svc.anclas_desbloqueadas().size() == 4)
	_check("Waypoints: señal ancla_desbloqueada emitida", unlock_count[0] >= 1)

	# Isla desconocida: inerte (sin unlock falso ni errores).
	svc._desbloqueadas.erase("ancla_playa_norte")
	ts.travel_arrived.emit("isla_desconocida")
	_check("Waypoints: isla desconocida es inerte", not svc.esta_desbloqueada("ancla_playa_norte"))
	svc.desbloquear("ancla_playa_norte")  # deja el estado como estaba

## K.25 (M124) — costo por distancia: default por ancla, fórmula inyectable.
func _b4_costo_distancia(svc) -> void:
	# Sin fórmula: consulta el costo global (en este punto del test: {moneda:3, tiempo:2} → 5).
	_check("Distancia: sin fórmula usa el costo global", svc.costo_total_de("LOC-RIZ-PUB-001") == svc.costo_total())

	# Fórmula cozy por defecto: todas las anclas dentro del tope 1..8.
	var activada: bool = svc.activar_costo_distancia_default()
	_check("Distancia: fórmula default activa (MundoRaiz presente)", activada)
	var minimo := 99
	var maximo := -1
	for a in svc.anclas():
		var c: int = svc.costo_total_de(String(a.get("id", "")))
		minimo = mini(minimo, c)
		maximo = maxi(maximo, c)
	_check("Distancia: costos dentro del rango cozy 1..8", minimo >= 1 and maximo <= 8)

	# Fórmula inyectable gana sobre la default (M124/M28 la proveyeron).
	svc.set_costo_distancia_fn(func(_a: Dictionary) -> int: return 42)
	_check("Distancia: fórmula inyectable gana", svc.costo_total_de("LOC-RIZ-PUB-001") == 42
		and svc.costo_total_de("LOC-RIZ-CASA-001") == 42)

	# Ancla inexistente con fórmula → {} vacío / 0.
	_check("Distancia: ancla inexistente -> vacío", svc.costo_total_de("no_existe") == 0)

	# Restauración: vuelve al global (inofensivo para el resto de la suite).
	svc.set_costo_distancia_fn(Callable())
	_check("Distancia: restauración al global", svc.costo_total_de("LOC-RIZ-PUB-001") == svc.costo_total())

## K.22 — restricción temporal (noche/tormenta): fn inyectable + autoloads reales.
func _b3_restriccion_temporal(svc) -> void:
	svc.set_puede_pagar_fn(Callable())  # neutraliza el costo del bloque anterior
	var rechazos := []
	svc.viaje_rechazado.connect(func(id, motivo): rechazos.append([id, motivo]))

	# Inyectada: bloqueo total → rechazo con motivo 'horario', sin señal de viaje.
	var bloqueado := [true]
	svc.set_restriccion_temporal_fn(func() -> bool: return bloqueado[0])
	var pedidos := []
	svc.viaje_solicitado.connect(func(a): pedidos.append(a))
	var ok_r0 = svc.solicitar_viaje("LOC-RIZ-CASA-001")
	_check("Horario: bloqueado (fn) -> sin viaje", not ok_r0)
	_check("Horario: motivo 'horario'", rechazos.size() == 1 and String(rechazos[0][1]) == "horario")
	_check("Horario: señal de viaje NO emitida", pedidos.is_empty())

	# Inyectada: sin bloqueo → el viaje procede normal (regresión del flujo base).
	bloqueado[0] = false
	var ok_r1 = svc.solicitar_viaje("LOC-RIZ-CASA-001")
	_check("Horario: sin bloqueo el viaje se concede", ok_r1 and rechazos.size() == 1)
	_check("Horario: señal de viaje emitida al desbloquear", pedidos.size() == 1)

	# Autoloads reales: noche GameTime → restricción activa; día → inactiva.
	var gt = root.get_node_or_null("GameTime")
	if gt != null and gt.has_method("avanzar_hasta") and gt.has_method("es_de_dia"):
		svc.set_restriccion_temporal_fn(Callable())  # vuelve al built-in
		var hora_antes: int = gt.get_hora()
		gt.avanzar_hasta(23, 30)
		_check("Horario: GameTime real de noche restringe", svc.restriccion_temporal_activa() and not gt.es_de_dia())
		gt.avanzar_hasta(10, 0)
		_check("Horario: GameTime real de día no restringe", (not svc.restriccion_temporal_activa()) and gt.es_de_dia())
		gt.avanzar_hasta(hora_antes, 0)
	else:
		print("  [INFO] GameTime ausente — ramas reales K.22 no verificadas aquí")
	svc.set_restriccion_temporal_fn(Callable())

## D52 (O(1)) + RF4/P3 (costo de viaje).
func _b2_indice_costo(svc) -> void:
	_check("Índice O(1): ancla_de devuelve la ancla por id", svc.ancla_de("LOC-RIZ-PUB-001").get("nombre") == "Pueblo Raiz")
	_check("Índice O(1): id inexistente -> {} vacío", svc.ancla_de("no_existe").is_empty())
	# El índice deben cubrir todas las anclas cargadas.
	var n_idx := 0
	for a in svc.anclas():
		if not svc.ancla_de(String(a.get("id", ""))).is_empty():
			n_idx += 1
	_check("Índice O(1): cubre las %d anclas" % svc.anclas().size(), n_idx == svc.anclas().size())

	# Costo: por defecto gratuito.
	_check("Costo: por defecto 0 (viaje gratuito)", svc.costo_total() == 0)
	svc.set_costo_viaje({"moneda": 5})
	_check("Costo: configurable en recursos", svc.costo_total() == 5)
	svc.set_costo_viaje({"moneda": 3, "tiempo": 2})
	_check("Costo: varios recursos se suman", svc.costo_total() == 5)

	# Rechazo por costo con validador inyectable (M38/M59).
	var puede := [true]
	svc.set_puede_pagar_fn(func(_ancla_id: String) -> bool: return puede[0])
	var rechazos := []
	svc.viaje_rechazado.connect(func(id, motivo): rechazos.append([id, motivo]))
	var ok_pago = svc.solicitar_viaje("LOC-RIZ-PUB-001")
	_check("Costo: con saldo el viaje se concede", ok_pago and rechazos.is_empty())

	puede[0] = false
	var ok_sin_pago = svc.solicitar_viaje("LOC-RIZ-PUB-001")
	_check("Costo: sin saldo el viaje se rechaza", not ok_sin_pago)
	_check("Costo: el rechazo lleva motivo 'costo'", rechazos.size() == 1 and String(rechazos[0][1]) == "costo")
	_check("Costo: el rechazo nombra el ancla", String(rechazos[0][0]) == "LOC-RIZ-PUB-001")

func _on_viaje(ancla: Dictionary, contenedor: Array) -> void:
	contenedor[0] = true

func _resumen() -> void:
	print("=== RESUMEN M69: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0 or _checks < CHECKS_MINIMOS:
		print("RESULTADO: FALLO (%d checks de %d, %d fallos)" % [_checks, CHECKS_MINIMOS, _fallos])
		quit(1)
		return
	print("RESULTADO: PASS")
	quit(0)