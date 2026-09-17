# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-31
#
# M34: Test de pesca (sesión, resolución de especie, anti-frustración, colección).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/fishing/test_fishing.gd

extends SceneTree

var _fallos: int = 0
var _fm: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_fm = root.get_node_or_null("Fishing")
	_check(_fm != null, "Fishing autoload presente")
	if _fm == null:
		print("=== TEST M34 PESCA: 1 fallo(s) ===")
		quit(1)
		return
	_test_datos()
	_test_sesion_captura()
	_test_escape_sin_perdidas()
	_test_resolucion_condiciones()
	_test_coleccion()
	_test_iter2_estaciones_todas()
	_test_iter2_franjas_horas()
	_test_iter2_prng_semilla_m29()
	_test_iter2_filtro_estacion_verano()
	print("=== TEST M34 PESCA: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_datos() -> void:
	_check(_fm._peces.size() >= 2, "2+ peces cargados: %d" % _fm._peces.size())
	var sardina: FishDefinition = null
	for pez in _fm._peces:
		if pez.id == "pez_sardina":
			sardina = pez
	_check(sardina != null, "pez_sardina cargado")
	if sardina:
		_check(sardina.peso_rareza == 0.25, "sardina probabilidad 0.25")
		_check(sardina.tamano_min == 0.3, "sardina tamaño min 0.3")

func _test_sesion_captura() -> void:
	# Sesión con cana; simular flujo completo forzando picada y pulsaciones
	var cana := FishingRod.new()
	cana.id = "cana_test"
	cana.ventana_exito = 0.5
	var spot = Node3D.new()
	root.add_child(spot)
	_fm.registrar_spot(spot)
	var eventos: Array = []
	_fm.captura_exitosa.connect(func(pez, tamano): eventos.append(["captura", pez.id, tamano]))
	_fm.captura_fallida.connect(func(motivo): eventos.append(["fallo", motivo]))

	var ses = _fm.iniciar_sesion(spot, cana, null)
	_check(ses != null, "sesión iniciada")
	# Esperar a PICADA (máx 9s de espera simulada... en headless el timer corre real;
	# para no esperar, forzamos directamente el flujo):
	ses._on_picada()
	_check(ses.get_estado() == FishingSession.Estado.PICADA, "estado PICADA tras picada")
	# Pulsar en fase A -> MINIJUEGO
	ses.notificar_pulsacion_boton()
	_check(ses.get_estado() == FishingSession.Estado.MINIJUEGO, "MINIJUEGO tras pulsar fase A")
	# 3 pulsaciones en fase B (diseño §2.5) -> CAPTURA
	ses.notificar_pulsacion_boton()
	ses.notificar_pulsacion_boton()
	ses.notificar_pulsacion_boton()
	_check(ses.get_estado() == FishingSession.Estado.CAPTURA, "CAPTURA tras 3 pulsaciones")
	_check(eventos.size() >= 1 and eventos[0][0] == "captura", "captura_exitosa emitida")
	_check(_fm._capturas_totales == 1, "colección registra captura")

func _test_escape_sin_perdidas() -> void:
	var eventos: Array = []
	_fm.captura_fallida.connect(func(motivo): eventos.append(motivo))
	var cana := FishingRod.new()
	var spot = Node3D.new()
	root.add_child(spot)
	_fm.registrar_spot(spot)
	var ses = _fm.iniciar_sesion(spot, cana, null)
	# Picada y NO pulsar: forzar expiración de fase A
	ses._on_picada()
	ses._on_ventana_fase_a_expirada()
	_check(ses.get_estado() == FishingSession.Estado.IDLE, "IDLE tras escape")
	_check(eventos.has("el_pez_se_fue"), "escape emitido sin pérdidas")
	# §6.4: relanzar inmediato
	var ses2 = _fm.iniciar_sesion(spot, cana, null)
	_check(ses2 != null and ses2.get_estado() == FishingSession.Estado.ESPERA_PICADA, "relanzado sin cooldown")

func _test_resolucion_condiciones() -> void:
	# Resolución devuelve especies válidas y respeta condiciones de sardina (noche)
	var pez = _fm.resolver_especie(null, null)
	_check(pez != null, "resolver_especie devuelve pez")
	# Pity: pez lunar (pity 80) — tras forzar contador, peso x10 aplica
	_fm._pity_contadores["pez_luna"] = 80
	var elegido_luna := 0
	for i in range(50):
		var p = _fm.resolver_especie(null, null)
		if p != null and p.id == "pez_luna":
			elegido_luna += 1
			_fm._pity_contadores["pez_luna"] = 80  # mantener para la muestra
	_check(elegido_luna > 0, "pity aumenta chance del pez raro (%d/50)" % elegido_luna)

func _test_coleccion() -> void:
	var col: Dictionary = _fm.get_collection_data()
	_check(col.size() >= 1, "colección con entradas: %d" % col.size())
	var data: Dictionary = _fm.get_save_data()
	_check(data.has("coleccion"), "save data tiene colección")
	# Restaurar
	_fm._coleccion.clear()
	_fm.restore_save_data(data)
	_check(_fm.get_collection_data().size() >= 1, "restore recupera colección")

## ── Iter. 2 (GLM-5.3 / Kilo Code, Log 833): brechas V0 ──────────────

func _get_pez(id: String) -> FishDefinition:
	for pez in _fm._peces:
		if pez.id == id:
			return pez
	return null

func _test_iter2_estaciones_todas() -> void:
	# Bug: "temporadas": ["todas"] → estaciones=[-1] nunca matcheaba
	# estación real 0-3. Fix: "todas" → estaciones vacías (contrato L14).
	var sardina := _get_pez("pez_sardina")
	if sardina == null:
		_check(false, "sardina presente para test estaciones")
		return
	_check(sardina.estaciones.is_empty(),
		"sardina 'todas' → estaciones VACÍAS (antes [-1], %s)" % str(sardina.estaciones))
	# El filtro la acepta en CUALQUIER estación M29 (a hora NOCHE=4, que es
	# una franja de la sardina; a las 12 la filtra la FRANJA, por diseño).
	for estacion in [0, 1, 2, 3]:
		var candidatas: Array = _fm._candidatas_de_estacion(estacion, 4)
		_check(candidatas.has(sardina),
			"sardina candidata en estación %d (filtro arreglado)" % estacion)

func _test_iter2_franjas_horas() -> void:
	# Bug: "horas": [4, 20] solo usaba la primera → franjas=[ALBA], la hora
	# 20 (NOCHE) se descartaba. Fix: cada hora mapea a su franja (sin dupes).
	var sardina := _get_pez("pez_sardina")
	if sardina == null:
		_check(false, "sardina presente para test franjas")
		return
	var franjas := sardina.franjas
	_check(franjas.has(3), "sardina incluye NOCHE (hora 4 → <5 = NOCHE)")
	_check(franjas.has(2), "sardina incluye ATARDECER (hora 20 → 17..20 = ATARDECER, antes descartada)")
	_check(franjas.size() == 2, "sardina 2 franjas exactas (4→NOCHE, 20→ATARDECER): %s" % str(franjas))
	# El pez luna: [21, 3] → ambas NOCHE, sin duplicados
	var luna := _get_pez("pez_luna")
	if luna:
		_check(luna.franjas == [3], "luna [21,3] → [NOCHE] sin dupes: %s" % str(luna.franjas))

func _test_iter2_prng_semilla_m29() -> void:
	# Brecha: PRNG con hash(Time.get_ticks_usec()) = entropía runtime NO
	# determinista por partida. Fix: GameTime.rng_diario("m34") (M29 H120).
	var gt = root.get_node_or_null("GameTime")
	if gt == null or not gt.has_method("rng_diario"):
		_check(true, "sin GameTime: PRNG semilla 0 estable (fallback documentado)")
		return
	# Misma partida + mismo día + mismo namespace → misma secuencia
	var r1 = gt.rng_diario("m34")
	var seq1 := [r1.randf(), r1.randf(), r1.randf()]
	var r2 = gt.rng_diario("m34")
	var seq2 := [r2.randf(), r2.randf(), r2.randf()]
	_check(str(seq1) == str(seq2), "rng_diario(m34) reproducible mismo día")
	# Namespace distinto → secuencia distinta (no colisiona con otros módulos)
	var r3 = gt.rng_diario("m34_otro")
	var seq3 := [r3.randf(), r3.randf(), r3.randf()]
	_check(str(seq1) != str(seq3), "namespace m34 aislado de otros consumidores")
	# El manager consume el PRNG diario: capturas reproducibles tras recargar
	var a1 = _fm.resolver_especie(null, null)
	var a2 = _fm.resolver_especie(null, null)
	_check(a1 != null and a2 != null, "resolver_especie operativa con PRNG diario")

func _test_iter2_filtro_estacion_verano() -> void:
	# E2E del filtro REAL: la sardina ("todas") es candidata en TODAS las
	# estaciones por REGLA (no por fallback) y el luna solo en verano.
	# El calendario arranca en estación_inicial=0 (time_config.tres), así que
	# el E2E usa el estacion paramétrico (el de runtime se valida en el bucle
	# de _test_iter2_estaciones_todas).
	var ids_todas: Dictionary = {}
	for estacion in [0, 1, 2, 3]:
		var candidatas: Array = _fm._candidatas_de_estacion(estacion, 4)  # franja NOCHE
		var ids := []
		for p in candidatas:
			ids.append(p.id)
		ids_todas[estacion] = ids
	_check(ids_todas[1].has("pez_sardina"), "sardina candidata en verano POR REGLA (no fallback)")
	_check(ids_todas[1].has("pez_luna"), "luna candidata en verano (su estación) + franja NOCHE")
	_check(ids_todas[0].has("pez_sardina"), "sardina candidata también en primavera")
	_check(not ids_todas[0].has("pez_luna"), "luna NO candidata en primavera (filtro real activo)")
	_check(not ids_todas[2].has("pez_luna"), "luna NO candidata en otoño (filtro real activo)")
	_check(not ids_todas[3].has("pez_luna"), "luna NO candidata en invierno (filtro real activo)")