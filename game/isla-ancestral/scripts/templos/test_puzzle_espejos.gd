# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-07
#
# M24 iter. 4: test headless de la familia ESPEJOS (rotacion discreta, datos-driven).
# Cubre los items 49-54 del checklist:
#   49 rotacion en multiplos de 45 · 50 caminos verificables ·
#   51 espejos fijos y moviles · 52 cadena con la familia de luz ·
#   53 feedback de direccion al rotar · 54 documentacion (fuera de esta suite).
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/templos/test_puzzle_espejos.gd
#
# Protocolo anti-falso-verde:
#   - BLOQUES nombrados + _fin() al final de cada uno.
#   - Piso CHECKS_MINIMOS MEDIDO en verde (no estimado).
#   - _summary() en call_deferred: si _run() aborta, el resumen igual corre y nombra lo que falto.
#   - Bloque D = SONDA ROJA: los validadores se prueban EN VIVO sobre copias mutadas de los puzzles reales.

extends SceneTree

const MODULO := "M24-Espejos"
const CHECKS_MINIMOS := 62   # MEDIDO en verde (ajustar SOLO tras medir, nunca estimar)
const BLOQUES := ["A", "B", "C", "D", "E", "F"]

const RUTA_01 := "res://data/templos/puzzles/espejos/espejos_01.json"
const RUTA_02 := "res://data/templos/puzzles/espejos/espejos_02.json"

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
	print("=== [%s] Test de la familia espejos (rotacion 45, datos-driven) ===" % MODULO)
	_bloque_a_carga()
	_fin("A")
	_bloque_b_validacion()
	_fin("B")
	_bloque_c_propiedades_familia()
	_fin("C")
	_bloque_d_sonda_roja()
	_fin("D")
	_bloque_e_simulacion()
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
	var e01: Dictionary = PuzzleEspejos.cargar(RUTA_01)
	var e02: Dictionary = PuzzleEspejos.cargar(RUTA_02)
	_check("A: espejos_01.json existe y parsea", not e01.is_empty())
	_check("A: espejos_02.json existe y parsea", not e02.is_empty())
	_check("A: espejos_01 familia == espejos", str(e01.get("familia", "")) == "espejos")
	_check("A: espejos_02 familia == espejos", str(e02.get("familia", "")) == "espejos")
	_check("A: espejos_01 declara 1 emisor", PuzzleDef.ids_emisores(e01).size() == 1)
	_check("A: espejos_02 declara 1 emisor", PuzzleDef.ids_emisores(e02).size() == 1)
	_check("A: espejos_01 objetivo == [0]", _canon(PuzzleDef.ids_objetivo(e01)) == "0")
	_check("A: espejos_02 objetivo == [0]", _canon(PuzzleDef.ids_objetivo(e02)) == "0")

# --- Bloque B: validacion (framework + optica + espejos) -----------------

func _bloque_b_validacion() -> void:
	var e01: Dictionary = PuzzleEspejos.cargar(RUTA_01)
	var e02: Dictionary = PuzzleEspejos.cargar(RUTA_02)
	_check("B: validar_def(espejos_01) sin errores", PuzzleDef.validar_def(e01).is_empty())
	_check("B: validar_def(espejos_02) sin errores", PuzzleDef.validar_def(e02).is_empty())
	_check("B: soluciones_minimas(espejos_01) == 1", PuzzleDef.soluciones_minimas(e01) == 1)
	_check("B: soluciones_minimas(espejos_02) == 1", PuzzleDef.soluciones_minimas(e02) == 1)
	_check("B: validar_optica(espejos_01) sin errores",
		PuzzleEspejos.desde_def(e01).luz.validar_optica().is_empty())
	_check("B: validar_optica(espejos_02) sin errores",
		PuzzleEspejos.desde_def(e02).luz.validar_optica().is_empty())
	_check("B: validar_espejos(espejos_01) sin errores",
		PuzzleEspejos.desde_def(e01).validar_espejos().is_empty())
	_check("B: validar_espejos(espejos_02) sin errores",
		PuzzleEspejos.desde_def(e02).validar_espejos().is_empty())
	_check("B: espejos_01 declara rotacion 45", PuzzleEspejos.desde_def(e01).rotacion_declarada == 45)
	_check("B: espejos_02 declara rotacion 45", PuzzleEspejos.desde_def(e02).rotacion_declarada == 45)

# --- Bloque C: propiedades de la familia (items 49-53) -------------------

func _bloque_c_propiedades_familia() -> void:
	var e01: Dictionary = PuzzleEspejos.cargar(RUTA_01)
	var pe: PuzzleEspejos = PuzzleEspejos.desde_def(e01)

	# item 52: cadena con la familia de luz (composicion, no reimplementacion).
	_check("C: la familia espejos COMPONE un motor de luz (item 52)", pe.luz != null)
	_check("C: la sala viene del motor de luz (compartida)", pe.sala() == pe.luz.sala)

	# item 51: espejos fijos y moviles.
	_check("C: espejo_a de espejos_01 es FIJO (item 51)", pe.es_fijo("espejo_a"))
	_check("C: espejo_b de espejos_01 es MOVIL (item 51)", pe.es_movil("espejo_b"))

	# item 49: rotacion en multiplos de 45.
	_check("C: angulo inicial de espejo_b == 0", pe.angulo("espejo_b") == 0)
	_check("C: rotar(espejo_b, 45) devuelve true (multiplo de 45)", pe.rotar("espejo_b", 45))
	_check("C: tras rotar 45 el angulo de espejo_b == 45", pe.angulo("espejo_b") == 45)
	_check("C: rotar(espejo_b, 30) devuelve false (NO multiplo de 45)", not pe.rotar("espejo_b", 30))
	_check("C: tras el rechazo el angulo sigue en 45", pe.angulo("espejo_b") == 45)
	_check("C: rotar sobre un espejo FIJO devuelve false (item 51)", not pe.rotar("espejo_a", 45))

	# item 53: feedback de direccion al rotar.
	_check("C: feedback(espejo_b) tras rotar es \"S->O\" (item 53)", pe.feedback("espejo_b") == "S->O")
	_check("C: direccion_salida(espejo_b) == OESTE", pe.direccion_salida("espejo_b") == Vector2i(-1, 0))

	# item 50: camino verificable.
	_check("C: camino() no esta vacio (item 50)", not pe.camino().is_empty())
	_check("C: validar_camino() sin errores con el puzzle resuelto", pe.validar_camino().is_empty())

# --- Bloque D: SONDA ROJA (validadores sobre copias mutadas) -------------

func _bloque_d_sonda_roja() -> void:
	var e01: Dictionary = PuzzleEspejos.cargar(RUTA_01)

	# Controles positivos.
	_check("D: control positivo — validar_espejos(espejos_01) sin errores",
		PuzzleEspejos.desde_def(e01).validar_espejos().is_empty())

	# SONDA 1 (item 49): rotacion declarada 30 -> validar_espejos DEBE fallar.
	var m1: Dictionary = e01.duplicate(true)
	((m1["espejos"] as Dictionary))["rotacion_grados"] = 30
	var err1: Array = PuzzleEspejos.desde_def(m1).validar_espejos()
	_check("D: rotacion declarada 30 -> validar_espejos DEBE fallar", not err1.is_empty())
	_check("D: el error nombra \"no es multiplo de 45\"", _contiene(err1, "no es multiplo de 45"))

	# SONDA 2: angulo de espejo 30 en la capa optica -> validar_optica DEBE fallar.
	var m2: Dictionary = e01.duplicate(true)
	(((m2["luz"] as Dictionary)["espejos"] as Array)[0] as Dictionary)["angulo"] = 30
	_check("D: angulo de espejo 30 -> validar_optica DEBE fallar",
		_contiene(PuzzleEspejos.desde_def(m2).luz.validar_optica(), "no es multiplo de 45"))

	# SONDA 3: movil inexistente -> validar_espejos DEBE fallar.
	var m3: Dictionary = e01.duplicate(true)
	((m3["espejos"] as Dictionary))["moviles"] = ["espejo_fantasma"]
	_check("D: movil inexistente -> validar_espejos DEBE fallar",
		_contiene(PuzzleEspejos.desde_def(m3).validar_espejos(), "inexistente"))

	# SONDA 4: un espejo declarado fijo Y movil -> DEBE fallar.
	var m4: Dictionary = e01.duplicate(true)
	((m4["espejos"] as Dictionary))["moviles"] = ["espejo_a", "espejo_b"]
	_check("D: espejo fijo y movil a la vez -> validar_espejos DEBE fallar",
		_contiene(PuzzleEspejos.desde_def(m4).validar_espejos(), "fijo y movil"))

	# SONDA 5: sin moviles -> no hay nada que rotar -> DEBE fallar.
	var m5: Dictionary = e01.duplicate(true)
	((m5["espejos"] as Dictionary))["moviles"] = []
	_check("D: sin espejos moviles -> validar_espejos DEBE fallar",
		_contiene(PuzzleEspejos.desde_def(m5).validar_espejos(), "sin espejos moviles"))

	# SONDA 6: ambiguedad real de reglas -> 2 caminos OR -> 2 soluciones minimas.
	var m6: Dictionary = e01.duplicate(true)
	(m6["emisores"] as Array).append({"id": 1, "tipo": "cristal", "etiqueta": "cristal_extra"})
	(m6["reglas"] as Array).clear()
	(m6["reglas"] as Array).append({"emisores": [0], "receptor": "runa_espejos"})
	(m6["reglas"] as Array).append({"emisores": [1], "receptor": "runa_espejos"})
	_check("D: copia mutada (2 caminos OR) tiene soluciones_minimas == 2",
		PuzzleDef.soluciones_minimas(m6) == 2)
	_check("D: validar_def DEBE detectar la ambiguedad inyectada",
		_contiene(PuzzleDef.validar_def(m6), "ambiguo"))

# --- Bloque E: simulacion real (rotar hasta resolver) --------------------

func _bloque_e_simulacion() -> void:
	# espejos_01: el espejo movil debe rotarse 45 grados para enviar el rayo al cristal.
	var pe: PuzzleEspejos = PuzzleEspejos.desde_def(PuzzleEspejos.cargar(RUTA_01))
	_check("E: 01 — al inicio el rayo NO llega al cristal", not pe.llega())
	_check("E: 01 — al inicio el receptor esta OFF", not pe.receptor_activado())
	_check("E: 01 — el espejo fijo desvia E->S", pe.feedback("espejo_a") == "E->S")
	_check("E: 01 — el espejo movil (angulo 0) devuelve el rayo S->N", pe.feedback("espejo_b") == "S->N")
	_check("E: 01 — tras rotar 45 el rayo LLEGA al cristal",
		pe.rotar("espejo_b", 45) and pe.llega())
	_check("E: 01 — y el receptor se activa (item 43/52)", pe.receptor_activado())
	_check("E: 01 — el emisor 0 de la sala queda ON", bool(pe.sala().emisores[0]))
	_check("E: 01 — sala.estado_igual_objetivo()", pe.sala().estado_igual_objetivo())
	var c: Array = pe.camino()
	_check("E: 01 — el camino resuelto termina en el cristal (0,4)",
		c.size() > 0 and c[c.size() - 1] == Vector2i(0, 4))
	_check("E: 01 — validar_camino() sin errores (item 50)", pe.validar_camino().is_empty())
	_check("E: 01 — rotar de vuelta -45 deja el receptor OFF",
		pe.rotar("espejo_b", -45) and not pe.receptor_activado())

	# espejos_02: hay que rotar DOS espejos moviles (90 grados cada uno).
	var pe2: PuzzleEspejos = PuzzleEspejos.desde_def(PuzzleEspejos.cargar(RUTA_02))
	_check("E: 02 — al inicio el rayo NO llega", not pe2.llega())
	_check("E: 02 — rotar espejo_a +90 lleva el rayo hacia el sur", pe2.rotar("espejo_a", 90) and pe2.angulo("espejo_a") == 135)
	_check("E: 02 — con un solo espejo rotado el rayo AUN no llega", not pe2.llega())
	_check("E: 02 — rotar espejo_b +90 cierra el camino al cristal",
		pe2.rotar("espejo_b", 90) and pe2.llega())
	_check("E: 02 — el receptor se activa", pe2.receptor_activado())
	var c2: Array = pe2.camino()
	_check("E: 02 — el camino termina en el cristal (0,4)",
		c2.size() > 0 and c2[c2.size() - 1] == Vector2i(0, 4))
	_check("E: 02 — validar_camino() sin errores", pe2.validar_camino().is_empty())

# --- Bloque F: rendimiento MEDIDO (item 171) -----------------------------

func _bloque_f_rendimiento() -> void:
	var iters := 2000
	var us01 := _tick_us(PuzzleEspejos.desde_def(PuzzleEspejos.cargar(RUTA_01)), iters)
	var us02 := _tick_us(PuzzleEspejos.desde_def(PuzzleEspejos.cargar(RUTA_02)), iters)
	print("  [INFO] rotar+trazado (espejos_01): %.4f us/tick (%.6f ms)" % [us01, us01 / 1000.0])
	print("  [INFO] rotar+trazado (espejos_02): %.4f us/tick (%.6f ms)" % [us02, us02 / 1000.0])
	_check("F: rotar+trazado (espejos_01) <= 1 ms (medido)", us01 <= 1000.0)
	_check("F: rotar+trazado (espejos_02) <= 1 ms (medido)", us02 <= 1000.0)

	var e01: Dictionary = PuzzleEspejos.cargar(RUTA_01)
	var t0 := Time.get_ticks_usec()
	for i in range(200):
		PuzzleEspejos.desde_def(e01).validar_espejos()
	var us_val := float(Time.get_ticks_usec() - t0) / 200.0
	print("  [INFO] validar_espejos(espejos_01): %.2f us (%.4f ms)" % [us_val, us_val / 1000.0])
	_check("F: validar_espejos(espejos_01) < 10 ms (autoria, no tick)", us_val < 10000.0)

## Coste medio de rotar un espejo + re-trazar (la operacion del tick del puzzle).
func _tick_us(pe: PuzzleEspejos, iters: int) -> float:
	var t0 := Time.get_ticks_usec()
	for i in range(iters):
		pe.rotar("espejo_b", 45 if (i % 2) == 0 else -45)
	return float(Time.get_ticks_usec() - t0) / float(iters)

# --- Helpers -------------------------------------------------------------

## Canoniza una lista de ids como string ordenada ("0,1"), robusta a floats de JSON.
func _canon(arr: Array) -> String:
	var v: Array = []
	for x in arr:
		v.append(int(x))
	v.sort()
	var s: Array = []
	for x in v:
		s.append(str(x))
	return ",".join(s)

func _contiene(errores: Array, sub: String) -> bool:
	for e in errores:
		if str(e).contains(sub):
			return true
	return false
