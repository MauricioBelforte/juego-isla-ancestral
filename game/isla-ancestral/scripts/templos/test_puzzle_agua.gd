# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-07
#
# M24 iter. 5: test headless de la familia AGUA (niveles graduales, datos-driven).
# Cubre los items 58-63 del checklist:
#   58 compuertas con niveles · 59 fuente alimenta el nivel · 60 barca flotante ·
#   61 altura verificable por datos · 62 relleno/drenaje gradual · 63 documentacion.
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/templos/test_puzzle_agua.gd
#
# Protocolo anti-falso-verde:
#   - BLOQUES nombrados + _fin() al final de cada uno.
#   - Piso CHECKS_MINIMOS MEDIDO en verde (no estimado).
#   - _summary() en call_deferred: si _run() aborta, el resumen igual corre y nombra lo que falto.
#   - Bloque D = SONDA ROJA: los validadores se prueban EN VIVO sobre copias mutadas de los puzzles reales.

extends SceneTree

const MODULO := "M24-Agua"
const CHECKS_MINIMOS := 57   # MEDIDO en verde (ajustar SOLO tras medir, nunca estimar)

const BLOQUES := ["A", "B", "C", "D", "E", "F"]

const RUTA_01 := "res://data/templos/puzzles/agua/agua_01.json"
const RUTA_02 := "res://data/templos/puzzles/agua/agua_02.json"

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
	print("=== [%s] Test de la familia agua (niveles graduales, datos-driven) ===" % MODULO)
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
	var a01: Dictionary = PuzzleAgua.cargar(RUTA_01)
	var a02: Dictionary = PuzzleAgua.cargar(RUTA_02)
	_check("A: agua_01.json existe y parsea", not a01.is_empty())
	_check("A: agua_02.json existe y parsea", not a02.is_empty())
	_check("A: agua_01 familia == agua", str(a01.get("familia", "")) == "agua")
	_check("A: agua_02 familia == agua", str(a02.get("familia", "")) == "agua")
	_check("A: agua_01 declara 2 emisores", PuzzleDef.ids_emisores(a01).size() == 2)
	_check("A: agua_02 declara 1 emisor", PuzzleDef.ids_emisores(a02).size() == 1)
	_check("A: agua_01 objetivo == [0,1]", _canon(PuzzleDef.ids_objetivo(a01)) == "0,1")
	_check("A: agua_02 objetivo == [0]", _canon(PuzzleDef.ids_objetivo(a02)) == "0")

# --- Bloque B: validacion (framework + capa hidraulica) ------------------

func _bloque_b_validacion() -> void:
	var a01: Dictionary = PuzzleAgua.cargar(RUTA_01)
	var a02: Dictionary = PuzzleAgua.cargar(RUTA_02)
	_check("B: validar_def(agua_01) sin errores", PuzzleDef.validar_def(a01).is_empty())
	_check("B: validar_def(agua_02) sin errores", PuzzleDef.validar_def(a02).is_empty())
	_check("B: soluciones_minimas(agua_01) == 1", PuzzleDef.soluciones_minimas(a01) == 1)
	_check("B: soluciones_minimas(agua_02) == 1", PuzzleDef.soluciones_minimas(a02) == 1)
	_check("B: validar_agua(agua_01) sin errores", PuzzleAgua.desde_def(a01).validar_agua().is_empty())
	_check("B: validar_agua(agua_02) sin errores", PuzzleAgua.desde_def(a02).validar_agua().is_empty())
	_check("B: agua_01 declara 1 fuente", PuzzleAgua.desde_def(a01).fuentes.size() == 1)
	_check("B: agua_02 declara 2 fuentes", PuzzleAgua.desde_def(a02).fuentes.size() == 2)

# --- Bloque C: propiedades de la familia (items 58-62) -------------------

func _bloque_c_propiedades_familia() -> void:
	var pa: PuzzleAgua = PuzzleAgua.desde_def(PuzzleAgua.cargar(RUTA_01))

	# item 61: altura verificable por datos (al inicio, todo a 0).
	_check("C: altura((1,1)) == 0 al inicio", pa.altura(Vector2i(1, 1)) == 0)
	_check("C: altura((0,0)) == 0 al inicio", pa.altura(Vector2i(0, 0)) == 0)

	# item 58: compuerta con umbral 6, cerrada al inicio.
	_check("C: compuerta_a declarada con umbral 6",
		int((pa.compuertas["compuerta_a"] as Dictionary)["umbral"]) == 6)
	_check("C: compuerta_a cerrada al inicio", not pa.compuerta_abierta("compuerta_a"))

	# item 60: barca declarada, aun no cruzo.
	_check("C: barca_a declarada con umbral 6",
		int((pa.barcas["barca_a"] as Dictionary)["umbral"]) == 6)
	_check("C: barca_a NO cruzo al inicio", not pa.barca_en_destino("barca_a"))

	# item 59 + 62: UN tick aporta EXACTAMENTE el caudal (2), no salta al umbral (6).
	pa.tick()
	_check("C: tras 1 tick la altura es 2 (== caudal)", pa.altura(Vector2i(1, 1)) == 2)
	_check("C: tras 1 tick la altura NO es el umbral (sin snap)", pa.altura(Vector2i(1, 1)) != 6)
	_check("C: tras 1 tick la compuerta sigue cerrada", not pa.compuerta_abierta("compuerta_a"))

	# item 62: el incremento por tick es constante y monotono.
	pa.tick()
	_check("C: tras 2 ticks la altura es 4 (gradual, +2)", pa.altura(Vector2i(1, 1)) == 4)

	# item 58 + 60: al llegar al umbral (6) la compuerta abre y la barca cruza.
	pa.tick()
	_check("C: tras 3 ticks la altura es 6 (== umbral)", pa.altura(Vector2i(1, 1)) == 6)
	_check("C: compuerta_a ABIERTA al alcanzar el umbral (item 58)", pa.compuerta_abierta("compuerta_a"))
	_check("C: barca_a CRUZO al alcanzar el umbral (item 60)", pa.barca_en_destino("barca_a"))
	_check("C: el emisor 0 (compuerta) queda ON", bool(pa.sala.emisores[0]))
	_check("C: el emisor 1 (barca) queda ON", bool(pa.sala.emisores[1]))
	_check("C: receptor activado (S == T)", pa.receptor_activado())

	# item 62: el drenaje es gradual (baja 1 por llamada), no un salto a 0.
	pa.drenar()
	_check("C: tras 1 drenaje la altura es 5 (gradual, -1)", pa.altura(Vector2i(1, 1)) == 5)
	_check("C: con altura 5 la compuerta vuelve a cerrarse", not pa.compuerta_abierta("compuerta_a"))
	_check("C: la barca sigue cruzada (el cruce es permanente)", pa.barca_en_destino("barca_a"))

# --- Bloque D: SONDA ROJA (validadores sobre copias mutadas) -------------

func _bloque_d_sonda_roja() -> void:
	var a01: Dictionary = PuzzleAgua.cargar(RUTA_01)

	# Control positivo: el puzzle real valida.
	_check("D: control positivo — validar_agua(agua_01) sin errores",
		PuzzleAgua.desde_def(a01).validar_agua().is_empty())

	# SONDA 1: umbral 0 -> validar_agua DEBE fallar.
	var m1: Dictionary = a01.duplicate(true)
	(((m1["agua"] as Dictionary)["compuertas"] as Array)[0] as Dictionary)["umbral"] = 0
	_check("D: umbral 0 -> validar_agua DEBE fallar",
		_contiene(PuzzleAgua.desde_def(m1).validar_agua(), "umbral 0 invalido"))

	# SONDA 2: emisor inexistente en la compuerta -> DEBE fallar.
	var m2: Dictionary = a01.duplicate(true)
	(((m2["agua"] as Dictionary)["compuertas"] as Array)[0] as Dictionary)["emisor"] = 9
	_check("D: compuerta con emisor 9 -> validar_agua DEBE fallar",
		_contiene(PuzzleAgua.desde_def(m2).validar_agua(), "emisor 9 inexistente"))

	# SONDA 3: fuente con caudal 0 -> DEBE fallar.
	var m3: Dictionary = a01.duplicate(true)
	(((m3["agua"] as Dictionary)["fuentes"] as Array)[0] as Dictionary)["caudal"] = 0
	_check("D: fuente con caudal 0 -> validar_agua DEBE fallar",
		_contiene(PuzzleAgua.desde_def(m3).validar_agua(), "caudal 0 invalido"))

	# SONDA 4: barca cuyo destino == posicion inicial -> DEBE fallar.
	var m4: Dictionary = a01.duplicate(true)
	(((m4["agua"] as Dictionary)["barcas"] as Array)[0] as Dictionary)["destino"] = [1, 1]
	_check("D: barca destino == posicion -> validar_agua DEBE fallar",
		_contiene(PuzzleAgua.desde_def(m4).validar_agua(), "destino == posicion"))

	# SONDA 5 (semantica): sin fuentes el nivel NUNCA sube -> el receptor jamas se activa.
	var m5: Dictionary = a01.duplicate(true)
	(m5["agua"] as Dictionary)["fuentes"] = []
	var pa5: PuzzleAgua = PuzzleAgua.desde_def(m5)
	for i in range(20):
		pa5.tick()
	_check("D: sin fuentes la altura sigue 0", pa5.altura(Vector2i(1, 1)) == 0)
	_check("D: sin fuentes el receptor NUNCA se activa", not pa5.receptor_activado())
	_check("D: sin fuentes validar_agua DEBE fallar",
		_contiene(pa5.validar_agua(), "sin fuentes"))

	# SONDA 6 (gradual): caudal 1 con umbral 6 -> 1 tick deja 1, no 6.
	var m6: Dictionary = a01.duplicate(true)
	(((m6["agua"] as Dictionary)["fuentes"] as Array)[0] as Dictionary)["caudal"] = 1
	var pa6: PuzzleAgua = PuzzleAgua.desde_def(m6)
	pa6.tick()
	_check("D: caudal 1 -> tras 1 tick la altura es 1 (sin snap)", pa6.altura(Vector2i(1, 1)) == 1)
	# Instancia FRESCA para contar los ticks desde cero (pa6 ya consumio 1).
	var pa6b: PuzzleAgua = PuzzleAgua.desde_def(m6)
	_check("D: con caudal 1 hacen falta 6 ticks para abrir",
		_funciona_en_n_ticks(pa6b, "compuerta_a", 6))

# --- Bloque E: simulacion real -------------------------------------------

func _bloque_e_simulacion() -> void:
	# agua_02: fuente_a caudal 3 (umbral 9) + fuente_b caudal 1.
	var pa2: PuzzleAgua = PuzzleAgua.desde_def(PuzzleAgua.cargar(RUTA_02))
	_check("E: agua_02 fuente_a arranca en 0", pa2.altura(Vector2i(2, 2)) == 0)
	pa2.tick()
	_check("E: agua_02 tras 1 tick (2,2) == 3", pa2.altura(Vector2i(2, 2)) == 3)
	_check("E: agua_02 tras 1 tick (3,2) == 1 (fuente_b)", pa2.altura(Vector2i(3, 2)) == 1)
	pa2.tick()
	_check("E: agua_02 tras 2 ticks (2,2) == 6", pa2.altura(Vector2i(2, 2)) == 6)
	_check("E: agua_02 compuerta cerrada a 6 (< 9)", not pa2.compuerta_abierta("compuerta_a"))
	pa2.tick()
	_check("E: agua_02 tras 3 ticks (2,2) == 9 (umbral)", pa2.altura(Vector2i(2, 2)) == 9)
	_check("E: agua_02 compuerta ABIERTA", pa2.compuerta_abierta("compuerta_a"))
	_check("E: agua_02 receptor activado", pa2.receptor_activado())
	_check("E: agua_02 sala.estado_igual_objetivo()", pa2.sala.estado_igual_objetivo())

	# tope "max": la fuente no supera su maximo.
	for i in range(10):
		pa2.tick()
	_check("E: la fuente respeta su tope max (12)", pa2.altura(Vector2i(2, 2)) == 12)

# --- Bloque F: rendimiento MEDIDO ----------------------------------------

func _bloque_f_rendimiento() -> void:
	var pa: PuzzleAgua = PuzzleAgua.desde_def(PuzzleAgua.cargar(RUTA_01))
	var iters := 5000
	var t0 := Time.get_ticks_usec()
	for i in range(iters):
		pa.tick()
	var us := float(Time.get_ticks_usec() - t0) / float(iters)
	print("  [INFO] tick() de agua_01: %.4f us/tick (%.6f ms)" % [us, us / 1000.0])
	_check("F: tick() de agua <= 1 ms (medido)", us <= 1000.0)

	var a01: Dictionary = PuzzleAgua.cargar(RUTA_01)
	var t1 := Time.get_ticks_usec()
	for i in range(500):
		PuzzleAgua.desde_def(a01).validar_agua()
	var us_val := float(Time.get_ticks_usec() - t1) / 500.0
	print("  [INFO] validar_agua(agua_01): %.2f us" % us_val)
	_check("F: validar_agua < 10 ms (autoria, no tick)", us_val < 10000.0)

# --- Helpers -------------------------------------------------------------

## Corre ticks hasta que la compuerta abra; true si abre EXACTAMENTE en n ticks.
func _funciona_en_n_ticks(pa: PuzzleAgua, id: String, n: int) -> bool:
	for i in range(n - 1):
		pa.tick()
		if pa.compuerta_abierta(id):
			return false
	pa.tick()
	return pa.compuerta_abierta(id)

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
