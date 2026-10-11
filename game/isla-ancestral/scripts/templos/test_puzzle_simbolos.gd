# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-09
#
# M24 iter. 6: test headless de la familia SIMBOLOS y ambientales.
# Cubre los items 111, 112, 113 y 117 del checklist:
#   111 glifos ancestrales emparejados · 112 glosario del templo (M25 inscripciones) ·
#   113 sello de puerta por pareja correcta · 117 documentacion.
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/templos/test_puzzle_simbolos.gd
#
# Protocolo anti-falso-verde:
#   - BLOQUES nombrados + _fin() al final de cada uno.
#   - Piso CHECKS_MINIMOS MEDIDO en verde (no estimado).
#   - _summary() en call_deferred: si _run() aborta, el resumen igual corre y nombra lo que falto.
#   - Bloque E = SONDA ROJA: los validadores se prueban EN VIVO sobre copias mutadas.

extends SceneTree

const MODULO := "M24-Simbolos"
const CHECKS_MINIMOS := 47   # MEDIDO en verde (ajustar SOLO tras medir, nunca estimar)

const BLOQUES := ["A", "B", "C", "D", "E", "F"]

const RUTA_01 := "res://data/templos/puzzles/simbolos/simbolos_01.json"
const RUTA_02 := "res://data/templos/puzzles/simbolos/simbolos_02.json"

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
	print("=== [%s] Test de la familia simbolos y ambientales ===" % MODULO)
	_bloque_a_carga()
	_fin("A")
	_bloque_b_validacion()
	_fin("B")
	_bloque_c_glifos_parejas()
	_fin("C")
	_bloque_d_glosario_m25()
	_fin("D")
	_bloque_e_sello_y_sonda()
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
	var s1: Dictionary = PuzzleSimbolos.cargar(RUTA_01)
	var s2: Dictionary = PuzzleSimbolos.cargar(RUTA_02)
	_check("A: simbolos_01.json existe y parsea", not s1.is_empty())
	_check("A: simbolos_02.json existe y parsea", not s2.is_empty())
	_check("A: simbolos_01 familia == simbolos", str(s1.get("familia", "")) == "simbolos")
	_check("A: simbolos_02 familia == simbolos", str(s2.get("familia", "")) == "simbolos")
	_check("A: simbolos_01 declara 2 emisores", PuzzleDef.ids_emisores(s1).size() == 2)
	_check("A: simbolos_02 declara 2 emisores", PuzzleDef.ids_emisores(s2).size() == 2)

# --- Bloque B: validacion -------------------------------------------------

func _bloque_b_validacion() -> void:
	var s1: Dictionary = PuzzleSimbolos.cargar(RUTA_01)
	var s2: Dictionary = PuzzleSimbolos.cargar(RUTA_02)
	_check("B: validar_def(simbolos_01) sin errores", PuzzleDef.validar_def(s1).is_empty())
	_check("B: validar_def(simbolos_02) sin errores", PuzzleDef.validar_def(s2).is_empty())
	_check("B: soluciones_minimas(simbolos_01) == 1", PuzzleDef.soluciones_minimas(s1) == 1)
	_check("B: soluciones_minimas(simbolos_02) == 1", PuzzleDef.soluciones_minimas(s2) == 1)
	_check("B: validar(simbolos_01) sin errores", PuzzleSimbolos.desde_def(s1).validar().is_empty())
	_check("B: validar(simbolos_02) sin errores", PuzzleSimbolos.desde_def(s2).validar().is_empty())

# --- Bloque C: glifos emparejados (item 111) -----------------------------

func _bloque_c_glifos_parejas() -> void:
	var ps: PuzzleSimbolos = PuzzleSimbolos.desde_def(PuzzleSimbolos.cargar(RUTA_01))
	_check("C: simbolos_01 declara 3 glifos", ps.ids_glifos().size() == 3)
	_check("C: glifo_sol respeta el contrato M25", ps.es_glifo_valido_m25("glifo_sol"))
	_check("C: simbolos_de(glifo_sol) == [circulo, rayos]",
		_canon(ps.simbolos_de("glifo_sol")) == "circulo,rayos")
	_check("C: significado_de(glifo_sol) == Sol", ps.significado_de("glifo_sol") == "Sol")
	_check("C: (glifo_sol, glifo_agua) es pareja", ps.es_pareja("glifo_sol", "glifo_agua"))
	_check("C: la pareja es indistinta al orden", ps.es_pareja("glifo_agua", "glifo_sol"))
	_check("C: (glifo_sol, glifo_piedra) NO es pareja", not ps.es_pareja("glifo_sol", "glifo_piedra"))
	_check("C: la compania de glifo_sol es glifo_agua", ps.pareja_de("glifo_sol") == "glifo_agua")
	_check("C: glifo_piedra no tiene compania (intruso)", ps.pareja_de("glifo_piedra").is_empty())

# --- Bloque D: glosario del templo (item 112, M25) -----------------------

func _bloque_d_glosario_m25() -> void:
	var ps: PuzzleSimbolos = PuzzleSimbolos.desde_def(PuzzleSimbolos.cargar(RUTA_01))
	_check("D: el glosario cubre todos los glifos", ps.glosario_completo())
	_check("D: glosario_tiene(glifo_sol)", ps.glosario_tiene("glifo_sol"))
	_check("D: inscripcion_de(glifo_sol) == INSCRIPCION_SOL",
		ps.inscripcion_de("glifo_sol") == "INSCRIPCION_SOL")
	_check("D: significado_glosario(glifo_sol) == Sol", ps.significado_glosario("glifo_sol") == "Sol")
	_check("D: inscripcion_de(no_existe) == cadena vacia", ps.inscripcion_de("no_existe").is_empty())
	_check("D: el glosario tiene 3 entradas", ps.ids_glosario().size() == 3)

# --- Bloque E: sello por pareja correcta (item 113) + SONDA ROJA ---------

func _bloque_e_sello_y_sonda() -> void:
	var ps: PuzzleSimbolos = PuzzleSimbolos.desde_def(PuzzleSimbolos.cargar(RUTA_01))
	_check("E: el sello exige la pareja [glifo_sol, glifo_agua]",
		_canon(ps.sello.get("pareja", [])) == "glifo_agua,glifo_sol")
	_check("E: el sello esta cerrado al inicio", not ps.sello_abierto())

	# Colocar solo un glifo NO abre el sello.
	_check("E: colocar glifo_sol en pedestal_a", ps.colocar("glifo_sol", "pedestal_a"))
	_check("E: con 1 glifo la pareja NO es correcta", not ps.pareja_correcta())
	_check("E: con 1 glifo el sello sigue cerrado", not ps.sello_abierto())

	# Pareja INCORRECTA: glifo_sol + glifo_piedra -> sigue cerrado.
	ps.colocar("glifo_piedra", "pedestal_b")
	_check("E: pareja incorrecta -> sello cerrado", not ps.sello_abierto())
	_check("E: pareja incorrecta -> emisores OFF", not bool(ps.sala.emisores[0]))

	# Pareja CORRECTA: glifo_sol + glifo_agua -> abre.
	ps.quitar("pedestal_b")
	ps.colocar("glifo_agua", "pedestal_b")
	_check("E: pareja correcta -> pareja_correcta()", ps.pareja_correcta())
	_check("E: pareja correcta -> sello ABIERTO", ps.sello_abierto())
	_check("E: pareja correcta -> S == T", ps.sala.estado_igual_objetivo())
	_check("E: emisor 0 ON", bool(ps.sala.emisores[0]))
	_check("E: emisor 1 ON", bool(ps.sala.emisores[1]))
	_check("E: glifo_en(pedestal_a) == glifo_sol", ps.glifo_en("pedestal_a") == "glifo_sol")

	# El atajo de autoria coloca la pareja correcta.
	var ps2: PuzzleSimbolos = PuzzleSimbolos.desde_def(PuzzleSimbolos.cargar(RUTA_01))
	_check("E: colocar_pareja_correcta() abre el sello", ps2.colocar_pareja_correcta() and ps2.sello_abierto())

	# SONDA ROJA 1: glifo sin significado -> validar DEBE fallar.
	var m1: Dictionary = PuzzleSimbolos.cargar(RUTA_01).duplicate(true)
	(((m1["simbolos"] as Dictionary)["glifos"] as Array)[0] as Dictionary)["significado"] = ""
	_check("E: glifo sin significado -> validar DEBE fallar",
		_contiene(PuzzleSimbolos.desde_def(m1).validar(), "contrato M25"))

	# SONDA ROJA 2: pareja del sello no declarada -> DEBE fallar.
	var m2: Dictionary = PuzzleSimbolos.cargar(RUTA_01).duplicate(true)
	((m2["simbolos"] as Dictionary)["sello"] as Dictionary)["pareja"] = ["glifo_sol", "glifo_piedra"]
	_check("E: pareja de sello no declarada -> validar DEBE fallar",
		_contiene(PuzzleSimbolos.desde_def(m2).validar(), "no es una pareja declarada"))

	# SONDA ROJA 3: pedestal con emisor inexistente -> DEBE fallar.
	var m3: Dictionary = PuzzleSimbolos.cargar(RUTA_01).duplicate(true)
	(((m3["simbolos"] as Dictionary)["pedestales"] as Array)[0] as Dictionary)["emisor"] = 9
	_check("E: pedestal con emisor 9 -> validar DEBE fallar",
		_contiene(PuzzleSimbolos.desde_def(m3).validar(), "emisor inexistente 9"))

	# SONDA ROJA 4: glosario incompleto -> DEBE fallar.
	var m4: Dictionary = PuzzleSimbolos.cargar(RUTA_01).duplicate(true)
	((m4["simbolos"] as Dictionary)["glosario"] as Array).pop_back()
	_check("E: glosario incompleto -> validar DEBE fallar",
		_contiene(PuzzleSimbolos.desde_def(m4).validar(), "no cubre todos los glifos"))

# --- Bloque F: rendimiento MEDIDO ----------------------------------------

func _bloque_f_rendimiento() -> void:
	var s1: Dictionary = PuzzleSimbolos.cargar(RUTA_01)
	var t0 := Time.get_ticks_usec()
	for i in range(500):
		PuzzleSimbolos.desde_def(s1).validar()
	var us := float(Time.get_ticks_usec() - t0) / 500.0
	print("  [INFO] validar() de simbolos_01: %.2f us" % us)
	_check("F: validar() < 10 ms (autoria, no tick)", us < 10000.0)

	var t1 := Time.get_ticks_usec()
	for i in range(500):
		PuzzleSimbolos.desde_def(PuzzleSimbolos.cargar(RUTA_02))
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
