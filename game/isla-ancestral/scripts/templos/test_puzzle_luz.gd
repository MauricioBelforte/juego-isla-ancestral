# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-07
#
# M24 iter. 4: test headless de la familia LUZ (grafo optico discreto, datos-driven).
# Cubre los items 39-45 del checklist:
#   39 espejo 45 verificable · 40 lente concentra · 41 prisma desvia ·
#   42 ocultacion por el jugador · 43 cristal activa runa · 44 validacion por datos ·
#   45 documentacion (fuera de esta suite, en 03-Diseno/04-Codigo).
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/templos/test_puzzle_luz.gd
#
# Protocolo anti-falso-verde:
#   - BLOQUES nombrados + _fin() al final de cada uno (un aborto silencioso deja el bloque sin marcar).
#   - Piso CHECKS_MINIMOS MEDIDO en verde (no estimado).
#   - _summary() registrado en call_deferred: si _run() aborta, el resumen igual corre y nombra lo que falto.
#   - Bloque D = SONDA ROJA: los validadores se prueban EN VIVO sobre copias mutadas de los puzzles reales.

extends SceneTree

const MODULO := "M24-Luz"
const CHECKS_MINIMOS := 60   # MEDIDO en verde (ajustar SOLO tras medir, nunca estimar)

const BLOQUES := ["A", "B", "C", "D", "E", "F"]

const RUTA_01 := "res://data/templos/puzzles/luz/luz_01.json"
const RUTA_02 := "res://data/templos/puzzles/luz/luz_02.json"

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
	print("=== [%s] Test de la familia luz (grafo optico, datos-driven) ===" % MODULO)
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
	var l01: Dictionary = PuzzleLuz.cargar(RUTA_01)
	var l02: Dictionary = PuzzleLuz.cargar(RUTA_02)
	_check("A: luz_01.json existe y parsea", not l01.is_empty())
	_check("A: luz_02.json existe y parsea", not l02.is_empty())
	_check("A: luz_01 familia == luz", str(l01.get("familia", "")) == "luz")
	_check("A: luz_02 familia == luz", str(l02.get("familia", "")) == "luz")
	_check("A: luz_01 declara 1 emisor", PuzzleDef.ids_emisores(l01).size() == 1)
	_check("A: luz_02 declara 1 emisor", PuzzleDef.ids_emisores(l02).size() == 1)
	_check("A: luz_01 objetivo == [0]", _canon(PuzzleDef.ids_objetivo(l01)) == "0")
	_check("A: luz_02 objetivo == [0]", _canon(PuzzleDef.ids_objetivo(l02)) == "0")

# --- Bloque B: validacion (framework + capa optica) ----------------------

func _bloque_b_validacion() -> void:
	var l01: Dictionary = PuzzleLuz.cargar(RUTA_01)
	var l02: Dictionary = PuzzleLuz.cargar(RUTA_02)
	_check("B: validar_def(luz_01) sin errores", PuzzleDef.validar_def(l01).is_empty())
	_check("B: validar_def(luz_02) sin errores", PuzzleDef.validar_def(l02).is_empty())
	_check("B: soluciones_minimas(luz_01) == 1", PuzzleDef.soluciones_minimas(l01) == 1)
	_check("B: soluciones_minimas(luz_02) == 1", PuzzleDef.soluciones_minimas(l02) == 1)
	_check("B: solucion_minima(luz_01) == objetivo",
		_canon(PuzzleDef.solucion_minima(l01)) == _canon(PuzzleDef.ids_objetivo(l01)))
	_check("B: solucion_minima(luz_02) == objetivo",
		_canon(PuzzleDef.solucion_minima(l02)) == _canon(PuzzleDef.ids_objetivo(l02)))
	_check("B: validar_optica(luz_01) sin errores", PuzzleLuz.desde_def(l01).validar_optica().is_empty())
	_check("B: validar_optica(luz_02) sin errores", PuzzleLuz.desde_def(l02).validar_optica().is_empty())

# --- Bloque C: propiedades de la familia (items 39-44) -------------------

func _bloque_c_propiedades_familia() -> void:
	var l01: Dictionary = PuzzleLuz.cargar(RUTA_01)
	var l02: Dictionary = PuzzleLuz.cargar(RUTA_02)
	var pl01: PuzzleLuz = PuzzleLuz.desde_def(l01)
	var pl02: PuzzleLuz = PuzzleLuz.desde_def(l02)

	# item 39: espejo a 45 grados VERIFICABLE -> el rayo E sale N.
	_check("C: espejo_a de luz_01 esta a 45 grados", pl01.angulo_espejo("espejo_a") == 45)
	_check("C: 45 es multiplo de 45 y esta en ANGULOS_ESPEJO",
		45 % 45 == 0 and PuzzleLuz.ANGULOS_ESPEJO.has(45))
	_check("C: espejo a 45 refleja E->N (verificable por datos)",
		pl01.direccion_salida("espejo_a") == Vector2i(0, -1))

	# item 40: la lente concentra el rayo.
	_check("C: luz_02 tiene 1 lente declarada", pl02.lentes.size() == 1)
	_check("C: la lente concentra el rayo (concentracion == 1)", pl02.concentracion() == 1)

	# item 41: el prisma desvia el rayo (E->S con desvio 90).
	_check("C: luz_02 tiene 1 prisma declarado", pl02.prismas.size() == 1)
	_check("C: tras el prisma el rayo va hacia el sur (celda (4,1) en el camino)",
		_contiene_celda(pl02.celdas(), Vector2i(4, 1)))

	# item 43: el cristal receptor activa la runa.
	_check("C: luz_01 llega al cristal", pl01.llega())
	_check("C: luz_01 activa el receptor (receptor_activado)", pl01.receptor_activado())
	_check("C: el emisor 0 de la sala queda ON", bool(pl01.sala.emisores[0]))
	_check("C: sala.estado_igual_objetivo() (S == T)", pl01.sala.estado_igual_objetivo())

	# item 44: validacion por DATOS -> el trazado es determinista (no fisica visual).
	var c1: Array = pl01.celdas()
	var c2: Array = pl01.trazar()["celdas"]
	_check("C: el trazado es determinista (mismos datos -> mismo camino)", _mismo_camino(c1, c2))
	_check("C: el camino arranca en la fuente", c1[0] == pl01.fuente_pos)

# --- Bloque D: SONDA ROJA (validadores sobre copias mutadas) -------------

func _bloque_d_sonda_roja() -> void:
	var l01: Dictionary = PuzzleLuz.cargar(RUTA_01)
	var l02: Dictionary = PuzzleLuz.cargar(RUTA_02)

	# Controles positivos: los puzzles reales validan.
	_check("D: control positivo — validar_optica(luz_01) sin errores",
		PuzzleLuz.desde_def(l01).validar_optica().is_empty())
	_check("D: control positivo — validar_optica(luz_02) sin errores",
		PuzzleLuz.desde_def(l02).validar_optica().is_empty())

	# SONDA 1 (item 39): angulo de espejo 30 (no multiplo de 45) -> validar_optica DEBE fallar.
	var m1: Dictionary = l01.duplicate(true)
	(((m1["luz"] as Dictionary)["espejos"] as Array)[0] as Dictionary)["angulo"] = 30
	var e1: Array = PuzzleLuz.desde_def(m1).validar_optica()
	_check("D: angulo 30 -> validar_optica DEBE fallar", not e1.is_empty())
	_check("D: el error nombra \"no es multiplo de 45\"", _contiene(e1, "no es multiplo de 45"))

	# SONDA 2 (item 41): desvio de prisma 45 (no multiplo de 90) -> validar_optica DEBE fallar.
	var m2: Dictionary = l02.duplicate(true)
	(((m2["luz"] as Dictionary)["prismas"] as Array)[0] as Dictionary)["desvio"] = 45
	var e2: Array = PuzzleLuz.desde_def(m2).validar_optica()
	_check("D: desvio de prisma 45 -> validar_optica DEBE fallar", not e2.is_empty())
	_check("D: el error nombra \"no es multiplo de 90\"", _contiene(e2, "no es multiplo de 90"))

	# SONDA 3: fuente fuera de la grilla -> validar_optica DEBE fallar.
	var m3: Dictionary = l01.duplicate(true)
	((m3["luz"] as Dictionary)["fuente"] as Dictionary)["pos"] = [99, 99]
	_check("D: fuente fuera de grilla -> validar_optica DEBE fallar",
		_contiene(PuzzleLuz.desde_def(m3).validar_optica(), "fuente fuera de la grilla"))

	# SONDA 4 (item 44): quitar la lente -> concentracion 0 -> el cristal (exige 1) NO se activa.
	var m4: Dictionary = l02.duplicate(true)
	(m4["luz"] as Dictionary)["lentes"] = []
	var pl4: PuzzleLuz = PuzzleLuz.desde_def(m4)
	_check("D: sin la lente la concentracion es 0", pl4.concentracion() == 0)
	_check("D: sin la lente el cristal (exige 1) NO se activa", not pl4.receptor_activado())

	# SONDA 5: desvio 0 en el prisma -> el rayo sigue de largo y NO llega.
	var m5: Dictionary = l02.duplicate(true)
	(((m5["luz"] as Dictionary)["prismas"] as Array)[0] as Dictionary)["desvio"] = 0
	_check("D: desvio 0 -> el rayo NO llega al cristal", not PuzzleLuz.desde_def(m5).llega())

	# SONDA 6: ambiguedad real de reglas -> 2 caminos OR -> 2 soluciones minimas.
	var m6: Dictionary = l01.duplicate(true)
	(m6["emisores"] as Array).append({"id": 1, "tipo": "cristal", "etiqueta": "cristal_extra"})
	(m6["reglas"] as Array).clear()
	(m6["reglas"] as Array).append({"emisores": [0], "receptor": "runa_luz"})
	(m6["reglas"] as Array).append({"emisores": [1], "receptor": "runa_luz"})
	_check("D: copia mutada (2 caminos OR) tiene soluciones_minimas == 2",
		PuzzleDef.soluciones_minimas(m6) == 2)
	_check("D: validar_def DEBE detectar la ambiguedad inyectada",
		_contiene(PuzzleDef.validar_def(m6), "ambiguo"))

# --- Bloque E: simulacion real (trazado + ocultacion) --------------------

func _bloque_e_simulacion() -> void:
	# luz_01: fuente (0,3) hacia el este, espejo en (3,3), cristal en (3,1).
	var pl: PuzzleLuz = PuzzleLuz.desde_def(PuzzleLuz.cargar(RUTA_01))
	var c: Array = pl.celdas()
	_check("E: la fuente de luz_01 esta en (0,3)", pl.fuente_pos == Vector2i(0, 3))
	_check("E: el camino arranca en (0,3)", c.size() > 0 and c[0] == Vector2i(0, 3))
	_check("E: el camino pasa por el espejo (3,3)", _contiene_celda(c, Vector2i(3, 3)))
	_check("E: el camino termina en el cristal (3,1)", c[c.size() - 1] == Vector2i(3, 1))
	_check("E: el cristal esta en (3,1)", pl.cristal_pos == Vector2i(3, 1))

	# item 42: ocultacion del rayo por el jugador.
	_check("E: (1,3) NO esta bloqueada al inicio", not pl.esta_bloqueada(Vector2i(1, 3)))
	pl.bloquear(Vector2i(1, 3))
	_check("E: tras bloquear (1,3) el rayo YA NO llega (item 42)", not pl.llega())
	_check("E: con el rayo bloqueado el receptor queda OFF", not pl.receptor_activado())
	_check("E: el emisor 0 de la sala vuelve a OFF", not bool(pl.sala.emisores[0]))
	_check("E: el camino bloqueado termina en (1,3)", pl.celdas()[pl.celdas().size() - 1] == Vector2i(1, 3))
	pl.desbloquear(Vector2i(1, 3))
	_check("E: tras desbloquear (1,3) el rayo vuelve a llegar", pl.llega())
	_check("E: y el receptor se reactiva", pl.receptor_activado())

	# luz_02: lente (2,0) + prisma (4,0) -> cristal (4,2) con concentracion 1.
	var pl2: PuzzleLuz = PuzzleLuz.desde_def(PuzzleLuz.cargar(RUTA_02))
	_check("E: luz_02 concentracion == 1", pl2.concentracion() == 1)
	_check("E: luz_02 llega al cristal (4,2)", pl2.llega() and pl2.celdas()[pl2.celdas().size() - 1] == Vector2i(4, 2))
	_check("E: luz_02 receptor_activado", pl2.receptor_activado())
	_check("E: luz_02 sala.estado_igual_objetivo()", pl2.sala.estado_igual_objetivo())

# --- Bloque F: rendimiento MEDIDO (item 171) -----------------------------

func _bloque_f_rendimiento() -> void:
	var iters := 2000
	var us01 := _tick_us(PuzzleLuz.desde_def(PuzzleLuz.cargar(RUTA_01)), iters)
	var us02 := _tick_us(PuzzleLuz.desde_def(PuzzleLuz.cargar(RUTA_02)), iters)
	print("  [INFO] trazado+tick (luz_01): %.4f us/tick (%.6f ms)" % [us01, us01 / 1000.0])
	print("  [INFO] trazado+tick (luz_02): %.4f us/tick (%.6f ms)" % [us02, us02 / 1000.0])
	_check("F: trazado+tick (luz_01) <= 1 ms (medido)", us01 <= 1000.0)
	_check("F: trazado+tick (luz_02) <= 1 ms (medido)", us02 <= 1000.0)

	var l01: Dictionary = PuzzleLuz.cargar(RUTA_01)
	var t0 := Time.get_ticks_usec()
	for i in range(200):
		PuzzleLuz.desde_def(l01).validar_optica()
	var us_val := float(Time.get_ticks_usec() - t0) / 200.0
	print("  [INFO] validar_optica(luz_01): %.2f us (%.4f ms)" % [us_val, us_val / 1000.0])
	_check("F: validar_optica(luz_01) < 10 ms (autoria, no tick)", us_val < 10000.0)

## Coste medio de re-trazar la sala (la operacion del tick del rayo).
func _tick_us(pl: PuzzleLuz, iters: int) -> float:
	var t0 := Time.get_ticks_usec()
	for i in range(iters):
		pl.trazar()
	return float(Time.get_ticks_usec() - t0) / float(iters)

# --- Helpers -------------------------------------------------------------

func _contiene_celda(celdas: Array, celda: Vector2i) -> bool:
	for c in celdas:
		if c == celda:
			return true
	return false

func _mismo_camino(a: Array, b: Array) -> bool:
	if a.size() != b.size():
		return false
	for i in range(a.size()):
		if a[i] != b[i]:
			return false
	return true

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
