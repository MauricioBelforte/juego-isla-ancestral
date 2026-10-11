# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-09
#
# M24 iter. 6: test headless de la familia PRESION avanzada.
# Cubre los items 77, 78, 79 y 80 del checklist:
#   77 elevadores por placas · 78 puertas por placas encadenadas ·
#   79 sin fallo punitivo (M66) · 80 documentacion.
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/templos/test_puzzle_presion.gd
#
# Protocolo anti-falso-verde:
#   - BLOQUES nombrados + _fin() al final de cada uno.
#   - Piso CHECKS_MINIMOS MEDIDO en verde (no estimado).
#   - _summary() en call_deferred: si _run() aborta, el resumen igual corre y nombra lo que falto.
#   - Bloque D = SONDA ROJA: los validadores se prueban EN VIVO sobre copias mutadas.

extends SceneTree

const MODULO := "M24-Presion"
const CHECKS_MINIMOS := 43   # MEDIDO en verde (ajustar SOLO tras medir, nunca estimar)

const BLOQUES := ["A", "B", "C", "D", "E", "F"]

const RUTA_03 := "res://data/templos/puzzles/presion/presion_03.json"
const RUTA_04 := "res://data/templos/puzzles/presion/presion_04.json"

var _checks := 0
var _fallos := 0
var _vistos: Dictionary = {}

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FALLO] %s" % nombre)

func _fin(bloque: String) -> void:
	_vistos[bloque] = true
	print("  [FIN] bloque %s (%d checks acumulados)" % [bloque, _checks])

func _run() -> void:
	print("=== [%s] Test de la familia presion avanzada ===" % MODULO)
	_bloque_a_carga()
	_fin("A")
	_bloque_b_validacion()
	_fin("B")
	_bloque_c_elevadores()
	_fin("C")
	_bloque_d_puertas_y_sonda()
	_fin("D")
	_bloque_e_sin_fallo_punitivo()
	_fin("E")
	_bloque_f_rendimiento()
	_fin("F")

func _summary() -> void:
	for b in BLOQUES:
		if not _vistos.has(b):
			_fallos += 1
			print("  [FALLO] el bloque %s NO se ejecuto (posible SCRIPT ERROR)" % b)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("  [FALLO] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos == 0:
		print("TEST OK")
	quit(1 if _fallos > 0 else 0)

# --- Bloque A: carga de datos --------------------------------------------

func _bloque_a_carga() -> void:
	var p3: Dictionary = PuzzlePresion.cargar(RUTA_03)
	var p4: Dictionary = PuzzlePresion.cargar(RUTA_04)
	_check("A: presion_03.json existe y parsea", not p3.is_empty())
	_check("A: presion_04.json existe y parsea", not p4.is_empty())
	_check("A: presion_03 familia == presion", str(p3.get("familia", "")) == "presion")
	_check("A: presion_04 familia == presion", str(p4.get("familia", "")) == "presion")
	_check("A: presion_03 declara 2 emisores", PuzzleDef.ids_emisores(p3).size() == 2)
	_check("A: presion_04 declara 3 emisores", PuzzleDef.ids_emisores(p4).size() == 3)

# --- Bloque B: validacion -------------------------------------------------

func _bloque_b_validacion() -> void:
	var p3: Dictionary = PuzzlePresion.cargar(RUTA_03)
	var p4: Dictionary = PuzzlePresion.cargar(RUTA_04)
	_check("B: validar_def(presion_03) sin errores", PuzzleDef.validar_def(p3).is_empty())
	_check("B: validar_def(presion_04) sin errores", PuzzleDef.validar_def(p4).is_empty())
	_check("B: soluciones_minimas(presion_03) == 1", PuzzleDef.soluciones_minimas(p3) == 1)
	_check("B: soluciones_minimas(presion_04) == 1", PuzzleDef.soluciones_minimas(p4) == 1)
	_check("B: validar(presion_03) sin errores", PuzzlePresion.desde_def(p3).validar().is_empty())
	_check("B: validar(presion_04) sin errores", PuzzlePresion.desde_def(p4).validar().is_empty())

# --- Bloque C: elevadores por placas (item 77) ---------------------------

func _bloque_c_elevadores() -> void:
	var pp: PuzzlePresion = PuzzlePresion.desde_def(PuzzlePresion.cargar(RUTA_03))
	_check("C: presion_03 declara 1 elevador", pp.elevadores.size() == 1)
	_check("C: elevador_a arranca a altura 0", pp.altura_elevador("elevador_a") == 0)
	_check("C: elevador_a NO esta en tope al inicio", not pp.elevador_en_tope("elevador_a"))
	pp.activar_emisor(0, true)
	_check("C: con 1 placa la altura es 1", pp.altura_elevador("elevador_a") == 1)
	_check("C: con 1 placa aun no esta en tope", not pp.elevador_en_tope("elevador_a"))
	pp.activar_emisor(1, true)
	_check("C: con 2 placas la altura es 2", pp.altura_elevador("elevador_a") == 2)
	_check("C: con 2 placas (== niveles) esta en tope", pp.elevador_en_tope("elevador_a"))
	_check("C: elevador inexistente -> altura -1", pp.altura_elevador("no_existe") == -1)
	_check("C: emisores_on() == [0,1]", _canon(pp.emisores_on()) == "0,1")

# --- Bloque D: puertas encadenadas (item 78) + SONDA ROJA ----------------

func _bloque_d_puertas_y_sonda() -> void:
	var pp: PuzzlePresion = PuzzlePresion.desde_def(PuzzlePresion.cargar(RUTA_04))
	_check("D: presion_04 declara 3 puertas encadenadas", pp.puertas.size() == 3)

	# Cadena progresiva: puerta_1 exige [0]; puerta_2 [0,1]; puerta_final [0,1,2].
	_check("D: sin placas, puerta_1 cerrada", not pp.puerta_encadenada_abierta("puerta_1"))
	pp.activar_emisor(0, true)
	_check("D: con placa 0, puerta_1 ABIERTA", pp.puerta_encadenada_abierta("puerta_1"))
	_check("D: con placa 0, puerta_2 aun cerrada", not pp.puerta_encadenada_abierta("puerta_2"))
	pp.activar_emisor(1, true)
	_check("D: con placas 0,1, puerta_2 ABIERTA", pp.puerta_encadenada_abierta("puerta_2"))
	_check("D: con placas 0,1, puerta_final aun cerrada", not pp.puerta_encadenada_abierta("puerta_final"))
	pp.activar_emisor(2, true)
	_check("D: con placas 0,1,2, puerta_final ABIERTA", pp.puerta_encadenada_abierta("puerta_final"))
	_check("D: las 3 puertas abiertas con todo ON",
		_canon(pp.puertas_abiertas()) == "puerta_1,puerta_2,puerta_final")
	_check("D: puerta inexistente -> cerrada", not pp.puerta_encadenada_abierta("no_existe"))
	_check("D: la sala alcanza el objetivo (S == T)", pp.sala.estado_igual_objetivo())

	# SONDA ROJA 1: elevador con emisor inexistente -> validar DEBE fallar.
	var m1: Dictionary = PuzzlePresion.cargar(RUTA_03).duplicate(true)
	(((m1["presion"] as Dictionary)["elevadores"] as Array)[0] as Dictionary)["emisor"] = 9
	_check("D: elevador con emisor 9 -> validar DEBE fallar",
		_contiene(PuzzlePresion.desde_def(m1).validar(), "emisor inexistente 9"))

	# SONDA ROJA 2: elevador con niveles 0 -> DEBE fallar.
	var m2: Dictionary = PuzzlePresion.cargar(RUTA_03).duplicate(true)
	(((m2["presion"] as Dictionary)["elevadores"] as Array)[0] as Dictionary)["niveles"] = 0
	_check("D: elevador con niveles 0 -> validar DEBE fallar",
		_contiene(PuzzlePresion.desde_def(m2).validar(), "niveles <= 0"))

	# SONDA ROJA 3: puerta sin cadena -> DEBE fallar.
	var m3: Dictionary = PuzzlePresion.cargar(RUTA_04).duplicate(true)
	(((m3["presion"] as Dictionary)["puertas_encadenadas"] as Array)[0] as Dictionary)["requiere"] = []
	_check("D: puerta sin cadena -> validar DEBE fallar",
		_contiene(PuzzlePresion.desde_def(m3).validar(), "sin cadena de placas"))

	# SONDA ROJA 4: sin_fallo_punitivo false -> DEBE fallar (item 79).
	var m4: Dictionary = PuzzlePresion.cargar(RUTA_03).duplicate(true)
	(m4["presion"] as Dictionary)["sin_fallo_punitivo"] = false
	_check("D: sin_fallo_punitivo false -> validar DEBE fallar",
		_contiene(PuzzlePresion.desde_def(m4).validar(), "sin_fallo_punitivo = true"))

# --- Bloque E: sin fallo punitivo (item 79) ------------------------------

func _bloque_e_sin_fallo_punitivo() -> void:
	var pp3: PuzzlePresion = PuzzlePresion.desde_def(PuzzlePresion.cargar(RUTA_03))
	pp3.activar_emisor(0, true)
	pp3.activar_emisor(1, true)
	_check("E: el reinicio NO penaliza (penalizacion == 0)", pp3.penalizacion_reinicio() == 0)
	_check("E: el reinicio NO es punitivo", not pp3.es_reinicio_punitivo())
	pp3.reiniciar()
	_check("E: tras reiniciar no hay emisores ON", pp3.emisores_on().is_empty())
	_check("E: tras reiniciar la altura vuelve a 0", pp3.altura_elevador("elevador_a") == 0)
	# La sala sigue siendo resoluble tras reiniciar (no queda bloqueada).
	pp3.activar_emisor(0, true)
	pp3.activar_emisor(1, true)
	_check("E: tras reiniciar la sala vuelve a resolverse", pp3.sala.estado_igual_objetivo())

	var pp4: PuzzlePresion = PuzzlePresion.desde_def(PuzzlePresion.cargar(RUTA_04))
	pp4.activar_emisor(0, true)
	pp4.activar_emisor(1, true)
	pp4.activar_emisor(2, true)
	pp4.reiniciar()
	_check("E: tras reiniciar no queda ninguna puerta abierta", pp4.puertas_abiertas().is_empty())

# --- Bloque F: rendimiento MEDIDO ----------------------------------------

func _bloque_f_rendimiento() -> void:
	var p3: Dictionary = PuzzlePresion.cargar(RUTA_03)
	var t0 := Time.get_ticks_usec()
	for i in range(500):
		PuzzlePresion.desde_def(p3).validar()
	var us := float(Time.get_ticks_usec() - t0) / 500.0
	print("  [INFO] validar() de presion_03: %.2f us" % us)
	_check("F: validar() < 10 ms (autoria, no tick)", us < 10000.0)

	var t1 := Time.get_ticks_usec()
	for i in range(500):
		PuzzlePresion.desde_def(PuzzlePresion.cargar(RUTA_04))
	var us2 := float(Time.get_ticks_usec() - t1) / 500.0
	print("  [INFO] cargar+desde_def: %.2f us" % us2)
	_check("F: cargar+desde_def < 5 ms", us2 < 5000.0)

# --- Helpers -------------------------------------------------------------

func _canon(arr: Array) -> String:
	var v: Array = []
	for x in arr:
		v.append(str(x))
	v.sort()
	return ",".join(v)

func _contiene(errores: Array, sub: String) -> bool:
	for e in errores:
		if str(e).contains(sub):
			return true
	return false
