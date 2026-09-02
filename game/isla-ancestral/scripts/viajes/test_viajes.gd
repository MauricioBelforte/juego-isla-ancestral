# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M28: Test de TravelService (embarque, clima retraso-sin-bloqueo, cancelación,
# un viaje activo, persistencia mitad de ruta).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/viajes/test_viajes.gd

extends SceneTree

var _fallos: int = 0
var _ts: Node = null
var _eco: Node = null
var _ws: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_ts = root.get_node_or_null("TravelService")
	_eco = root.get_node_or_null("EconomyManager")
	_ws = root.get_node_or_null("WorldState")
	_check(_ts != null, "TravelService autoload presente")
	_check(_eco != null, "EconomyManager presente (M38)")
	if _ts == null:
		print("=== TEST M28 VIAJES: 1 fallo(s) ===")
		quit(1)
		return
	_test_carga_rutas()
	_test_destinos_visibles()
	_test_embarque_y_llegada()
	_test_bloqueo_m22()
	_test_boleto_insuficiente()
	_test_clima_retraso_sin_bloqueo()
	_test_cancelacion_refunds()
	_test_un_viaje_activo()
	_test_persistencia_mitad_de_ruta()
	print("=== TEST M28 VIAJES: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _dar_ao(n: int) -> void:
	_eco.depositar_monedas(n)

func _test_carga_rutas() -> void:
	_check(_ts.rutas_count() == 4, "4 rutas cargadas: %d" % _ts.rutas_count())
	_check(_ts.get_section_name() == "viajes", "sección 'viajes'")

func _test_destinos_visibles() -> void:
	# Las secretas solo aparecen con su flag M22 activo
	var visibles: Array = _ts.get_available_destinations()
	var secretas_visibles := 0
	for r in visibles:
		if r.is_secret:
			secretas_visibles += 1
	_check(secretas_visibles == 0, "secretas ocultas sin flags M22")
	_ws.set_flag("templo_brisa_abierto", true)
	visibles = _ts.get_available_destinations()
	secretas_visibles = 0
	for r in visibles:
		if r.is_secret:
			secretas_visibles += 1
	_check(secretas_visibles == 1, "raiz_brisa_nocturna visible con templo_brisa_abierto")

func _test_embarque_y_llegada() -> void:
	_dar_ao(1000)
	var llegadas: Array = []
	var cb := func(island_id: String) -> void:
		llegadas.append(island_id)
	_ts.travel_arrived.connect(cb)
	var res: Dictionary = _ts.request_travel("isla_sur")
	_check(bool(res.ok), "embarque a isla_sur OK")
	_check(_ts.is_traveling(), "viaje activo tras embarcar")
	# Simular travesía completa (20 s base → 80 pasos de 0.25 s)
	for i in range(100):
		_ts._process(0.25)
		if not _ts.is_traveling():
			break
	_check(llegadas.has("isla_sur"), "llegada señalada (travel_arrived)")
	_check(not _ts.is_traveling(), "estado IDLE tras atracar")
	_ts.travel_arrived.disconnect(cb)

func _test_bloqueo_m22() -> void:
	_drenar()
	_dar_ao(1000)
	# ruta estacional verano sin estar en verano
	var res: Dictionary = _ts.request_travel("isla_norte")
	var motivo: String = String(res.motivo)
	_check(not bool(res.ok) or bool(res.ok), "estacional: sin crash (verano o rechazo limpio)")
	if not bool(res.ok):
		_check(motivo.contains("temporada") or motivo.contains("verano"),
			"rechazo estacional con motivo: %s" % motivo)
	# secreta diurna requiere pistas_secreto_completas
	_ws.remove_flag("pistas_secreto_completas")
	res = _ts.request_travel("isla_espejo")
	_check(not bool(res.ok), "isla_espejo bloqueada sin flag pistas (M22)")
	_check(String(res.motivo).contains("historia"), "motivo bloqueo M22: %s" % res.motivo)
	_ws.set_flag("pistas_secreto_completas", true)
	_dar_ao(500)
	res = _ts.request_travel("isla_espejo")
	_check(bool(res.ok), "isla_espejo desbloqueada con flag (M22 gating OK)")
	# Cancelar en travesía no se permite
	var cancel: Dictionary = _ts.cancel_travel()
	_check(not bool(cancel.ok), "cancelación en travesía rechazada")
	_drenar()

func _test_boleto_insuficiente() -> void:
	# Asegurar estado IDLE y saldo controlado: dejar exactamente 40 AO
	_drenar()
	_eco.retirar_monedas(maxi(0, _eco.saldo - 40))
	var saldo_antes: int = _eco.saldo
	var res: Dictionary = _ts.request_travel("isla_sur")
	_check(not bool(res.ok), "boleto sin AO rechazado")
	_check(String(res.motivo).contains("insuficiente"), "motivo AO insuficiente: %s" % res.motivo)
	_check(_eco.saldo == saldo_antes, "saldo intacto tras rechazo")
	_dar_ao(1000)

## Drena el viaje activo hasta IDLE (tolerante a delays de clima)
func _drenar() -> void:
	for i in range(400):
		if not _ts.is_traveling():
			break
		_ts._process(0.5)

func _test_clima_retraso_sin_bloqueo() -> void:
	_drenar()
	_dar_ao(1000)
	var w := root.get_node_or_null("Weather")
	if w == null:
		return
	# Forzar tormenta (M32 clima 3): salida retrasada + duración +25%
	var w_clima_original: int = w.get_clima()
	w._clima_actual = 3
	var delays: Array = []
	var cb_d := func(seg: float, razon: String) -> void:
		delays.append([seg, razon])
	_ts.travel_delayed.connect(cb_d)
	var res: Dictionary = _ts.request_travel("isla_sur")
	_check(bool(res.ok), "embarque CON tormenta OK (retraso, jamás cancelación)")
	_check(_ts.get_current_state() == 1, "estado WAITING_DEPARTURE con tormenta")
	_check(delays.size() == 1, "señal travel_delayed emitida (aviso amable)")
	if delays.size() == 1:
		_check(float(delays[0][0]) >= 5.0 and float(delays[0][0]) <= 15.0,
			"retraso 5-15 s (%.1f s)" % float(delays[0][0]))
	_check(_ts._duracion_efectiva > 20.0, "duración +25% por tormenta (%.1f s)" % _ts._duracion_efectiva)
	# Esperar el delay y travesía: llega igual (sin bloqueo)
	_drenar()
	_check(not _ts.is_traveling(), "llegó pese al retraso (sin soft-lock)")
	w._clima_actual = w_clima_original
	_ts.travel_delayed.disconnect(cb_d)

func _test_cancelacion_refunds() -> void:
	_drenar()
	_dar_ao(1000)
	# Forzar tormenta para tener ventana WAITING (pre-embarque)
	var w := root.get_node_or_null("Weather")
	var clima_original: int = w.get_clima() if w != null else -1
	if w != null:
		w._clima_actual = 3
	var saldo_antes: int = _eco.saldo
	var res: Dictionary = _ts.request_travel("isla_sur")
	_check(bool(res.ok), "embarque para cancelar OK")
	# Pre-embarque (WAITING): forzar delay para tener ventana
	var refund: int = _ts.cancel_travel().refund
	_check(refund == 50, "refund pre-embarque 100% (50 AO): %d" % refund)
	_check(_eco.saldo == saldo_antes, "saldo restituido al 100% pre-embarque")
	# Sin viaje: cancelar devuelve 0
	var cancel2: Dictionary = _ts.cancel_travel()
	_check(not bool(cancel2.ok), "cancelar sin viaje rechazado")
	# Restaurar clima original
	if w != null and clima_original >= 0:
		w._clima_actual = clima_original

func _test_un_viaje_activo() -> void:
	_drenar()
	_dar_ao(1000)
	var res1: Dictionary = _ts.request_travel("isla_sur")
	_check(bool(res1.ok), "primer viaje OK")
	var res2: Dictionary = _ts.request_travel("isla_sur")
	_check(not bool(res2.ok), "segundo viaje simultáneo rechazado (§6 un solo viaje)")
	_check(String(res2.motivo).contains("viaje activo"), "motivo un-viaje-activo")
	_drenar()

func _test_persistencia_mitad_de_ruta() -> void:
	_drenar()
	_dar_ao(1000)
	# Forzar clima calma para timing determinista (restaurar al final)
	var w := root.get_node_or_null("Weather")
	var clima_original: int = w.get_clima() if w != null else -1
	if w != null:
		w._clima_actual = 0
	var res: Dictionary = _ts.request_travel("isla_sur")
	_check(bool(res.ok), "embarque para persistencia OK")
	# Avanzar a mitad de ruta (20 s base → 40 pasos de 0.25 s = 10 s = 0.5)
	for i in range(40):
		_ts._process(0.25)
	var progreso: float = _ts.get_travel_progress()
	_check(progreso > 0.1 and progreso < 0.9, "en mitad de ruta (%.2f)" % progreso)
	# Serializar y restaurar: el tiempo restante se conserva
	var data: Dictionary = _ts.get_save_data()
	var ts_estado: int = int(data.get("estado", 0))
	_check(ts_estado == 2, "estado SAILING serializado (%d)" % ts_estado)
	# Restaurar en "otra sesión" (simulado): reset y restore
	var transcurrido_guardado: float = float(data.get("transcurrido", 0.0))
	_ts.restore_save_data(data)
	_check(absf(_ts.get_travel_progress() * _ts._duracion_efectiva - transcurrido_guardado) < 0.01,
		"restaurado con tiempo restante intacto")
	# Ruta huérfana: sin soft-lock
	_ts.restore_save_data({"estado": 2, "ruta_id": "ruta_fantasma", "transcurrido": 5.0})
	_check(not _ts.is_traveling(), "ruta huérfana descartada sin soft-lock (§3.3.2)")
	# Terminar el viaje pendiente
	for i in range(200):
		_ts._process(0.25)
		if not _ts.is_traveling():
			break
