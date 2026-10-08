# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-07
#
# M24 iter. 5: test headless de la familia HIELO (deslizamiento, datos-driven).
# Cubre los items 67-71 del checklist:
#   67 deslizamiento · 68 patrones simetricos verificables · 69 colisiones (paredes y huecos) ·
#   70 pedazos de hielo opcionales · 71 documentacion.
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/templos/test_puzzle_hielo.gd
#
# Protocolo anti-falso-verde:
#   - BLOQUES nombrados + _fin() al final de cada uno.
#   - Piso CHECKS_MINIMOS MEDIDO en verde (no estimado).
#   - _summary() en call_deferred: si _run() aborta, el resumen igual corre y nombra lo que falto.
#   - Bloque D = SONDA ROJA: los validadores se prueban EN VIVO sobre copias mutadas de los puzzles reales.

extends SceneTree

const MODULO := "M24-Hielo"
const CHECKS_MINIMOS := 59   # MEDIDO en verde (ajustar SOLO tras medir, nunca estimar)

const BLOQUES := ["A", "B", "C", "D", "E", "F"]

const RUTA_01 := "res://data/templos/puzzles/hielo/hielo_01.json"
const RUTA_02 := "res://data/templos/puzzles/hielo/hielo_02.json"

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
	print("=== [%s] Test de la familia hielo (deslizamiento, datos-driven) ===" % MODULO)
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
	var h01: Dictionary = PuzzleHielo.cargar(RUTA_01)
	var h02: Dictionary = PuzzleHielo.cargar(RUTA_02)
	_check("A: hielo_01.json existe y parsea", not h01.is_empty())
	_check("A: hielo_02.json existe y parsea", not h02.is_empty())
	_check("A: hielo_01 familia == hielo", str(h01.get("familia", "")) == "hielo")
	_check("A: hielo_02 familia == hielo", str(h02.get("familia", "")) == "hielo")
	_check("A: hielo_01 declara 1 emisor", PuzzleDef.ids_emisores(h01).size() == 1)
	_check("A: hielo_02 declara 2 emisores", PuzzleDef.ids_emisores(h02).size() == 2)
	_check("A: hielo_01 objetivo == [0]", _canon(PuzzleDef.ids_objetivo(h01)) == "0")
	_check("A: hielo_02 objetivo == [0,1]", _canon(PuzzleDef.ids_objetivo(h02)) == "0,1")

# --- Bloque B: validacion (framework + capa de hielo) --------------------

func _bloque_b_validacion() -> void:
	var h01: Dictionary = PuzzleHielo.cargar(RUTA_01)
	var h02: Dictionary = PuzzleHielo.cargar(RUTA_02)
	_check("B: validar_def(hielo_01) sin errores", PuzzleDef.validar_def(h01).is_empty())
	_check("B: validar_def(hielo_02) sin errores", PuzzleDef.validar_def(h02).is_empty())
	_check("B: soluciones_minimas(hielo_01) == 1", PuzzleDef.soluciones_minimas(h01) == 1)
	_check("B: soluciones_minimas(hielo_02) == 1", PuzzleDef.soluciones_minimas(h02) == 1)
	_check("B: validar_hielo(hielo_01) sin errores", PuzzleHielo.desde_def(h01).validar_hielo().is_empty())
	_check("B: validar_hielo(hielo_02) sin errores", PuzzleHielo.desde_def(h02).validar_hielo().is_empty())
	_check("B: hielo_02 declara 2 bloques", PuzzleHielo.desde_def(h02).bloques.size() == 2)
	_check("B: hielo_02 declara 2 pedazos", PuzzleHielo.desde_def(h02).pedazos.size() == 2)

# --- Bloque C: propiedades de la familia (items 67-70) -------------------

func _bloque_c_propiedades_familia() -> void:
	# item 67: deslizamiento (hielo_01: grilla 5x1, sin paredes).
	var ph: PuzzleHielo = PuzzleHielo.desde_def(PuzzleHielo.cargar(RUTA_01))
	_check("C: bloque_a arranca en (0,0)", ph.pos_de("bloque_a") == Vector2i(0, 0))
	_check("C: deslizar ESTE devuelve true", ph.deslizar("bloque_a", PuzzleHielo.ESTE))
	_check("C: el bloque se desliza hasta el borde (4,0) (item 67)", ph.pos_de("bloque_a") == Vector2i(4, 0))
	_check("C: el emisor 0 queda ON al moverse", bool(ph.sala.emisores[0]))
	_check("C: receptor activado", ph.receptor_activado())
	_check("C: deslizar OESTE devuelve true", ph.deslizar("bloque_a", PuzzleHielo.OESTE))
	_check("C: vuelve a (0,0) (posicion inicial)", ph.pos_de("bloque_a") == Vector2i(0, 0))
	_check("C: al volver a la inicial el emisor queda OFF", not bool(ph.sala.emisores[0]))
	_check("C: direccion invalida (0,0) NO mueve", not ph.deslizar("bloque_a", Vector2i(0, 0)))
	_check("C: un bloque inexistente no se mueve", not ph.deslizar("no_existe", PuzzleHielo.ESTE))

	# item 68: simetria data-driven.
	var ph2: PuzzleHielo = PuzzleHielo.desde_def(PuzzleHielo.cargar(RUTA_02))
	_check("C: validar_simetria(hielo_02) sin errores (item 68)", ph2.validar_simetria().is_empty())

	# item 70: pedazos de hielo con durabilidad declarada.
	_check("C: pedazo (1,1) arranca con 2 usos", ph2.usos_pedazo(Vector2i(1, 1)) == 2)
	_check("C: pedazo (5,1) arranca con 2 usos", ph2.usos_pedazo(Vector2i(5, 1)) == 2)

	# item 69: una PARED detiene el bloque (pared en (2,1)).
	_check("C: (2,1) es pared", ph2.es_pared(Vector2i(2, 1)))
	ph2.deslizar("bloque_a", PuzzleHielo.ESTE)
	_check("C: el bloque se detiene en (1,1) contra la pared (item 69)", ph2.pos_de("bloque_a") == Vector2i(1, 1))

# --- Bloque D: SONDA ROJA (validadores sobre copias mutadas) -------------

func _bloque_d_sonda_roja() -> void:
	var h02: Dictionary = PuzzleHielo.cargar(RUTA_02)

	# Control positivo: el puzzle real valida.
	_check("D: control positivo — validar_hielo(hielo_02) sin errores",
		PuzzleHielo.desde_def(h02).validar_hielo().is_empty())

	# SONDA 1: pedazo con usos 0 -> DEBE fallar.
	var m1: Dictionary = h02.duplicate(true)
	(((m1["hielo"] as Dictionary)["pedazos"] as Array)[0] as Dictionary)["usos"] = 0
	_check("D: pedazo con usos 0 -> validar_hielo DEBE fallar",
		_contiene(PuzzleHielo.desde_def(m1).validar_hielo(), "usos 0 invalido"))

	# SONDA 2: pared y hueco en la misma celda -> DEBE fallar.
	var m2: Dictionary = h02.duplicate(true)
	((m2["hielo"] as Dictionary)["huecos"] as Array).append([2, 1])
	_check("D: celda pared+hueco -> validar_hielo DEBE fallar",
		_contiene(PuzzleHielo.desde_def(m2).validar_hielo(), "pared y hueco a la vez"))

	# SONDA 3: bloque con emisor inexistente -> DEBE fallar.
	var m3: Dictionary = h02.duplicate(true)
	(((m3["hielo"] as Dictionary)["bloques"] as Array)[0] as Dictionary)["emisor"] = 9
	_check("D: bloque con emisor 9 -> validar_hielo DEBE fallar",
		_contiene(PuzzleHielo.desde_def(m3).validar_hielo(), "emisor 9 inexistente"))

	# SONDA 4: simetria rota (quitar la pared (4,1)) -> DEBE fallar.
	var m4: Dictionary = h02.duplicate(true)
	var paredes4: Array = (m4["hielo"] as Dictionary)["paredes"]
	for i in range(paredes4.size() - 1, -1, -1):
		var p: Array = paredes4[i]
		if int(p[0]) == 4 and int(p[1]) == 1:
			paredes4.remove_at(i)
	_check("D: simetria rota -> validar_simetria DEBE fallar",
		_contiene(PuzzleHielo.desde_def(m4).validar_simetria(), "sin reflejo"))

	# SONDA 5: eje de simetria invalido -> DEBE fallar.
	var m5: Dictionary = h02.duplicate(true)
	(m5["hielo"] as Dictionary)["simetria"] = "z"
	_check("D: simetria 'z' -> validar_simetria DEBE fallar",
		_contiene(PuzzleHielo.desde_def(m5).validar_simetria(), "invalida"))

	# SONDA 6 (semantica): bloque sobre una pared -> DEBE fallar.
	var m6: Dictionary = h02.duplicate(true)
	(((m6["hielo"] as Dictionary)["bloques"] as Array)[0] as Dictionary)["pos"] = [2, 1]
	_check("D: bloque sobre pared -> validar_hielo DEBE fallar",
		_contiene(PuzzleHielo.desde_def(m6).validar_hielo(), "ya ocupada por pared"))

	# SONDA 7 (sintetica): bloque detenido por OTRO bloque (no por pared).
	var m7: Dictionary = PuzzleHielo.cargar(RUTA_01).duplicate(true)
	((m7["hielo"] as Dictionary)["bloques"] as Array).append({"id": "bloque_b", "pos": [3, 0], "emisor": 0})
	var ph7: PuzzleHielo = PuzzleHielo.desde_def(m7)
	ph7.deslizar("bloque_a", PuzzleHielo.ESTE)
	_check("D: bloque_a se detiene en (2,0) contra bloque_b", ph7.pos_de("bloque_a") == Vector2i(2, 0))

# --- Bloque E: simulacion real -------------------------------------------

func _bloque_e_simulacion() -> void:
	# E1: el bloque se detiene contra la pared central.
	var e1: PuzzleHielo = PuzzleHielo.desde_def(PuzzleHielo.cargar(RUTA_02))
	e1.deslizar("bloque_a", PuzzleHielo.ESTE)
	_check("E: bloque_a se detiene en (1,1)", e1.pos_de("bloque_a") == Vector2i(1, 1))
	_check("E: el emisor 0 queda ON", bool(e1.sala.emisores[0]))
	_check("E: el emisor 1 sigue OFF (bloque_b no se movio)", not bool(e1.sala.emisores[1]))
	_check("E: el receptor aun NO se activa (falta el bloque_b)", not e1.receptor_activado())

	# E2: el bloque_b tambien alcanza su ranura.
	var e2: PuzzleHielo = PuzzleHielo.desde_def(PuzzleHielo.cargar(RUTA_02))
	e2.deslizar("bloque_b", PuzzleHielo.OESTE)
	_check("E: bloque_b se detiene en (5,1)", e2.pos_de("bloque_b") == Vector2i(5, 1))
	_check("E: el emisor 1 queda ON", bool(e2.sala.emisores[1]))

	# E3: los DOS bloques movidos -> receptor activado (S == T).
	var e3: PuzzleHielo = PuzzleHielo.desde_def(PuzzleHielo.cargar(RUTA_02))
	e3.deslizar("bloque_a", PuzzleHielo.ESTE)
	e3.deslizar("bloque_b", PuzzleHielo.OESTE)
	_check("E: los DOS emisores ON", bool(e3.sala.emisores[0]) and bool(e3.sala.emisores[1]))
	_check("E: receptor activado (S == T)", e3.receptor_activado())
	_check("E: sala.estado_igual_objetivo()", e3.sala.estado_igual_objetivo())

	# E4: el pedazo se agrieta (2->1) y se rompe al segundo paso (item 70).
	var e4: PuzzleHielo = PuzzleHielo.desde_def(PuzzleHielo.cargar(RUTA_02))
	e4.deslizar("bloque_a", PuzzleHielo.ESTE)
	_check("E: tras 1 paso el pedazo (1,1) queda con 1 uso", e4.usos_pedazo(Vector2i(1, 1)) == 1)
	_check("E: el pedazo (1,1) AUN no es hueco", not e4.es_hueco(Vector2i(1, 1)))
	e4.deslizar("bloque_a", PuzzleHielo.OESTE)
	_check("E: el bloque vuelve a (0,1)", e4.pos_de("bloque_a") == Vector2i(0, 1))
	e4.deslizar("bloque_a", PuzzleHielo.ESTE)
	_check("E: tras 2 pasos el pedazo (1,1) se rompe (usos -> -1)", e4.usos_pedazo(Vector2i(1, 1)) == -1)
	_check("E: el pedazo roto deja un hueco en (1,1) (item 70)", e4.es_hueco(Vector2i(1, 1)))

	# E5: un hueco CONSUME el bloque (cae y desaparece del tablero) (item 69).
	e4.deslizar("bloque_a", PuzzleHielo.OESTE)
	_check("E: el bloque vuelve a (0,1)", e4.pos_de("bloque_a") == Vector2i(0, 1))
	e4.deslizar("bloque_a", PuzzleHielo.ESTE)
	_check("E: el bloque cae en el hueco (1,1)", e4.cayo_en_hueco("bloque_a"))
	_check("E: el bloque ya NO esta activo en el tablero", not e4.bloque_activo("bloque_a"))
	_check("E: el emisor 0 vuelve a OFF (el bloque desaparecio)", not bool(e4.sala.emisores[0]))

# --- Bloque F: rendimiento MEDIDO ----------------------------------------

func _bloque_f_rendimiento() -> void:
	var h02: Dictionary = PuzzleHielo.cargar(RUTA_02)
	var iters := 2000
	var t0 := Time.get_ticks_usec()
	for i in range(iters):
		var ph: PuzzleHielo = PuzzleHielo.desde_def(h02)
		ph.deslizar("bloque_a", PuzzleHielo.ESTE)
	var us := float(Time.get_ticks_usec() - t0) / float(iters)
	print("  [INFO] cargar+deslizar (hielo_02): %.2f us (%.4f ms)" % [us, us / 1000.0])
	_check("F: cargar+deslizar <= 5 ms (medido)", us <= 5000.0)

	var t1 := Time.get_ticks_usec()
	for i in range(500):
		PuzzleHielo.desde_def(h02).validar_hielo()
	var us_val := float(Time.get_ticks_usec() - t1) / 500.0
	print("  [INFO] validar_hielo(hielo_02): %.2f us" % us_val)
	_check("F: validar_hielo < 10 ms (autoria, no tick)", us_val < 10000.0)

# --- Helpers -------------------------------------------------------------

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
