# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-07
#
# M24 iter. 5: test headless de la familia GRAVEDAD Y MOVIMIENTO (datos-driven).
# Cubre los items 92-98 del checklist:
#   92 burbujas de gravedad · 93 cambio de direccion · 94 plataformas sincronizadas ·
#   95 pulsos de aire · 96 cintas transportadoras · 97 sincronizacion con el reloj M29 ·
#   98 documentacion.
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/templos/test_puzzle_gravedad.gd
#
# Protocolo anti-falso-verde:
#   - BLOQUES nombrados + _fin() al final de cada uno.
#   - Piso CHECKS_MINIMOS MEDIDO en verde (no estimado).
#   - _summary() en call_deferred: si _run() aborta, el resumen igual corre y nombra lo que falto.
#   - Bloque D = SONDA ROJA: los validadores se prueban EN VIVO sobre copias mutadas de los puzzles reales.

extends SceneTree

const MODULO := "M24-Gravedad"
const CHECKS_MINIMOS := 59   # MEDIDO en verde (ajustar SOLO tras medir, nunca estimar)

const BLOQUES := ["A", "B", "C", "D", "E", "F"]

const RUTA_01 := "res://data/templos/puzzles/gravedad/gravedad_01.json"
const RUTA_02 := "res://data/templos/puzzles/gravedad/gravedad_02.json"

## Reloj de prueba con el contrato M29 (game_clock.gd): dia_absoluto/get_hora/get_minuto.
class RelojFalso extends RefCounted:
	func dia_absoluto() -> int:
		return 3
	func get_hora() -> int:
		return 5
	func get_minuto() -> int:
		return 7

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
	print("=== [%s] Test de la familia gravedad (datos-driven) ===" % MODULO)
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
	var g01: Dictionary = PuzzleGravedad.cargar(RUTA_01)
	var g02: Dictionary = PuzzleGravedad.cargar(RUTA_02)
	_check("A: gravedad_01.json existe y parsea", not g01.is_empty())
	_check("A: gravedad_02.json existe y parsea", not g02.is_empty())
	_check("A: gravedad_01 familia == gravedad", str(g01.get("familia", "")) == "gravedad")
	_check("A: gravedad_02 familia == gravedad", str(g02.get("familia", "")) == "gravedad")
	_check("A: gravedad_01 declara 2 emisores", PuzzleDef.ids_emisores(g01).size() == 2)
	_check("A: gravedad_02 declara 1 emisor", PuzzleDef.ids_emisores(g02).size() == 1)
	_check("A: gravedad_01 objetivo == [0,1]", _canon(PuzzleDef.ids_objetivo(g01)) == "0,1")
	_check("A: gravedad_02 objetivo == [0]", _canon(PuzzleDef.ids_objetivo(g02)) == "0")

# --- Bloque B: validacion (framework + capa de gravedad) -----------------

func _bloque_b_validacion() -> void:
	var g01: Dictionary = PuzzleGravedad.cargar(RUTA_01)
	var g02: Dictionary = PuzzleGravedad.cargar(RUTA_02)
	_check("B: validar_def(gravedad_01) sin errores", PuzzleDef.validar_def(g01).is_empty())
	_check("B: validar_def(gravedad_02) sin errores", PuzzleDef.validar_def(g02).is_empty())
	_check("B: soluciones_minimas(gravedad_01) == 1", PuzzleDef.soluciones_minimas(g01) == 1)
	_check("B: soluciones_minimas(gravedad_02) == 1", PuzzleDef.soluciones_minimas(g02) == 1)
	_check("B: validar_gravedad(gravedad_01) sin errores", PuzzleGravedad.desde_def(g01).validar_gravedad().is_empty())
	_check("B: validar_gravedad(gravedad_02) sin errores", PuzzleGravedad.desde_def(g02).validar_gravedad().is_empty())
	_check("B: gravedad_01 declara 2 plataformas", PuzzleGravedad.desde_def(g01).plataformas.size() == 2)
	_check("B: gravedad_02 declara 2 burbujas", PuzzleGravedad.desde_def(g02).burbujas.size() == 2)

# --- Bloque C: propiedades de la familia (items 92-97) -------------------

func _bloque_c_propiedades_familia() -> void:
	var p1: PuzzleGravedad = PuzzleGravedad.desde_def(PuzzleGravedad.cargar(RUTA_01))
	var p2: PuzzleGravedad = PuzzleGravedad.desde_def(PuzzleGravedad.cargar(RUTA_02))

	# item 92: la burbuja_a cubre la grilla con gravedad hacia el NORTE.
	_check("C: (3,3) esta en una burbuja (item 92)", p1.en_burbuja(Vector2i(3, 3)))
	_check("C: direccion_gravedad((3,3)) == NORTE (item 92)",
		p1.direccion_gravedad(Vector2i(3, 3)) == PuzzleGravedad.NORTE)

	# item 93: dos zonas con direcciones opuestas cambian la direccion.
	_check("C: direccion_gravedad((1,1)) == OESTE (item 93)",
		p2.direccion_gravedad(Vector2i(1, 1)) == PuzzleGravedad.OESTE)
	_check("C: direccion_gravedad((4,1)) == ESTE (item 93)",
		p2.direccion_gravedad(Vector2i(4, 1)) == PuzzleGravedad.ESTE)
	_check("C: cambia_direccion((1,1),(4,1)) == true (item 93)",
		p2.cambia_direccion(Vector2i(1, 1), Vector2i(4, 1)))
	_check("C: cambia_direccion((1,1),(1,2)) == false (misma zona)",
		not p2.cambia_direccion(Vector2i(1, 1), Vector2i(1, 2)))

	# item 94: dos plataformas del grupo g1 comparten periodo -> sincronizadas.
	_check("C: plataformas_de('g1') son 2 (item 94)", p1.plataformas_de("g1").size() == 2)
	_check("C: plat_a y plat_b tienen el MISMO periodo (sincronizadas)",
		int((p1.plataformas["plat_a"] as Dictionary)["periodo"]) == int((p1.plataformas["plat_b"] as Dictionary)["periodo"]))
	_check("C: plataforma_offset('plat_a', 4) == amplitud 2 (item 94)",
		p1.plataforma_offset("plat_a", 4) == 2)
	_check("C: plataforma_en_extremo('plat_a', 4) == true (item 94)",
		p1.plataforma_en_extremo("plat_a", 4))
	_check("C: plataforma_en_extremo('plat_a', 0) == false",
		not p1.plataforma_en_extremo("plat_a", 0))
	_check("C: las dos plataformas estan en extremo en la MISMA fase (item 94)",
		p1.plataforma_en_extremo("plat_a", 4) == p1.plataforma_en_extremo("plat_b", 4))

	# item 95: pulso de aire con ventana [0, duracion).
	_check("C: pulso_activo('pulso_a', 0) == true (item 95)", p1.pulso_activo("pulso_a", 0))
	_check("C: pulso_activo('pulso_a', 2) == false (fuera de la ventana)", not p1.pulso_activo("pulso_a", 2))
	_check("C: pulso_activo('pulso_a', 6) == true (reinicia el periodo)", p1.pulso_activo("pulso_a", 6))

	# item 96: cintas transportadoras.
	_check("C: cinta_dir('cinta_a') == (1,0) (item 96)", p1.cinta_dir("cinta_a") == Vector2i(1, 0))
	_check("C: cinta_en((3,3)) == 'cinta_a' (item 96)", p1.cinta_en(Vector2i(3, 3)) == "cinta_a")
	_check("C: cinta_en((0,0)) == '' (celda sin cinta)", p1.cinta_en(Vector2i(0, 0)) == "")

	# item 97: sincronizacion con el reloj M29 (duck-typed, game_clock.gd).
	var reloj := RelojFalso.new()
	_check("C: fase_desde_reloj(reloj M29) == 3*1440+5*60+7 (item 97)",
		p1.fase_desde_reloj(reloj) == 3 * 1440 + 5 * 60 + 7)
	_check("C: fase_desde_reloj(null) == -1", p1.fase_desde_reloj(null) == -1)
	_check("C: fase_desde_reloj(objeto sin contrato) == -1",
		p1.fase_desde_reloj(RefCounted.new()) == -1)

# --- Bloque D: SONDA ROJA (validadores sobre copias mutadas) -------------

func _bloque_d_sonda_roja() -> void:
	var g01: Dictionary = PuzzleGravedad.cargar(RUTA_01)

	# Control positivo: el puzzle real valida.
	_check("D: control positivo — validar_gravedad(gravedad_01) sin errores",
		PuzzleGravedad.desde_def(g01).validar_gravedad().is_empty())

	# SONDA 1: plataforma con periodo 0 -> DEBE fallar.
	var m1: Dictionary = g01.duplicate(true)
	var plats1: Array = (m1["gravedad"] as Dictionary)["plataformas"]
	(plats1[0] as Dictionary)["periodo"] = 0
	_check("D: periodo 0 -> validar_gravedad DEBE fallar",
		_contiene(PuzzleGravedad.desde_def(m1).validar_gravedad(), "periodo 0 invalido"))

	# SONDA 2: plataforma con amplitud 0 -> DEBE fallar.
	var m2: Dictionary = g01.duplicate(true)
	var plats2: Array = (m2["gravedad"] as Dictionary)["plataformas"]
	(plats2[0] as Dictionary)["amplitud"] = 0
	_check("D: amplitud 0 -> validar_gravedad DEBE fallar",
		_contiene(PuzzleGravedad.desde_def(m2).validar_gravedad(), "amplitud 0 invalida"))

	# SONDA 3: burbuja con direccion nula -> DEBE fallar.
	var m3: Dictionary = g01.duplicate(true)
	var bubs3: Array = (m3["gravedad"] as Dictionary)["burbujas"]
	(bubs3[0] as Dictionary)["dir"] = [0, 0]
	_check("D: burbuja dir (0,0) -> validar_gravedad DEBE fallar",
		_contiene(PuzzleGravedad.desde_def(m3).validar_gravedad(), "invalida"))

	# SONDA 4: plataforma con emisor inexistente -> DEBE fallar.
	var m4: Dictionary = g01.duplicate(true)
	var plats4: Array = (m4["gravedad"] as Dictionary)["plataformas"]
	(plats4[0] as Dictionary)["emisor"] = 9
	_check("D: plataforma emisor 9 -> validar_gravedad DEBE fallar",
		_contiene(PuzzleGravedad.desde_def(m4).validar_gravedad(), "emisor 9 inexistente"))

	# SONDA 5: mismo grupo con periodos distintos -> NO estan sincronizadas.
	var m5: Dictionary = g01.duplicate(true)
	var plats5: Array = (m5["gravedad"] as Dictionary)["plataformas"]
	plats5.append({"id": "plat_c", "pos": [2, 3], "grupo": "g1", "amplitud": 2, "periodo": 5, "emisor": 0})
	_check("D: grupo g1 con periodos distintos -> validar_gravedad DEBE fallar",
		_contiene(PuzzleGravedad.desde_def(m5).validar_gravedad(), "no estan sincronizadas"))

	# SONDA 6: sin plataformas -> DEBE fallar.
	var m6: Dictionary = g01.duplicate(true)
	(m6["gravedad"] as Dictionary)["plataformas"] = []
	_check("D: sin plataformas -> validar_gravedad DEBE fallar",
		_contiene(PuzzleGravedad.desde_def(m6).validar_gravedad(), "sin plataformas"))

	# SONDA 7: pulso con duracion > periodo -> DEBE fallar.
	var m7: Dictionary = g01.duplicate(true)
	var pulsos7: Array = (m7["gravedad"] as Dictionary)["pulsos"]
	(pulsos7[0] as Dictionary)["duracion"] = 99
	_check("D: pulso duracion 99 -> validar_gravedad DEBE fallar",
		_contiene(PuzzleGravedad.desde_def(m7).validar_gravedad(), "fuera de"))

	# SONDA 8: burbuja con zona mal formada -> DEBE fallar.
	var m8: Dictionary = g01.duplicate(true)
	var bubs8: Array = (m8["gravedad"] as Dictionary)["burbujas"]
	(bubs8[0] as Dictionary)["zona"] = [0, 0]
	_check("D: burbuja zona [0,0] -> validar_gravedad DEBE fallar",
		_contiene(PuzzleGravedad.desde_def(m8).validar_gravedad(), "zona invalida"))

	# SONDA 9 (semantica): sin burbujas la gravedad vuelve al valor por defecto (SUR).
	var m9: Dictionary = g01.duplicate(true)
	(m9["gravedad"] as Dictionary)["burbujas"] = []
	var p9: PuzzleGravedad = PuzzleGravedad.desde_def(m9)
	_check("D: sin burbujas -> direccion por defecto (SUR)",
		p9.direccion_gravedad(Vector2i(3, 3)) == PuzzleGravedad.GRAVEDAD_DEFECTO)

	# SONDA 10 (semantica): sin plataformas el receptor NUNCA se activa.
	var p10: PuzzleGravedad = PuzzleGravedad.desde_def(m6)
	for i in range(20):
		p10.tick()
	_check("D: sin plataformas el receptor NUNCA se activa", not p10.receptor_activado())

# --- Bloque E: simulacion real -------------------------------------------

func _bloque_e_simulacion() -> void:
	# E1: gravedad_01 — las 2 plataformas sincronizadas llegan al extremo en la fase 4.
	var e1: PuzzleGravedad = PuzzleGravedad.desde_def(PuzzleGravedad.cargar(RUTA_01))
	_check("E: al inicio (fase 0) el receptor NO esta activado", not e1.receptor_activado())
	for i in range(3):
		e1.tick()
	_check("E: tras 3 ticks (fase 3) el receptor aun NO se activa", not e1.receptor_activado())
	var rep4: Dictionary = e1.tick()
	_check("E: tras 4 ticks (fase 4) el receptor SE activa", e1.receptor_activado())
	_check("E: los DOS emisores quedan ON", bool(e1.sala.emisores[0]) and bool(e1.sala.emisores[1]))
	_check("E: sala.estado_igual_objetivo()", e1.sala.estado_igual_objetivo())
	_check("E: el informe de la fase 4 nombra las 2 plataformas en extremo",
		(rep4["plataformas_en_extremo"] as Array).size() == 2)

	# E2: gravedad_02 — una sola plataforma con periodo 4 alcanza el extremo en la fase 2.
	var e2: PuzzleGravedad = PuzzleGravedad.desde_def(PuzzleGravedad.cargar(RUTA_02))
	e2.tick()
	_check("E: gravedad_02 fase 1 — receptor aun NO", not e2.receptor_activado())
	e2.tick()
	_check("E: gravedad_02 fase 2 — receptor SE activa", e2.receptor_activado())
	_check("E: gravedad_02 emisor 0 ON", bool(e2.sala.emisores[0]))

# --- Bloque F: rendimiento MEDIDO ----------------------------------------

func _bloque_f_rendimiento() -> void:
	var p1: PuzzleGravedad = PuzzleGravedad.desde_def(PuzzleGravedad.cargar(RUTA_01))
	var iters := 20000
	var t0 := Time.get_ticks_usec()
	for i in range(iters):
		p1.tick()
	var us := float(Time.get_ticks_usec() - t0) / float(iters)
	print("  [INFO] tick() de gravedad_01: %.4f us/tick (%.6f ms)" % [us, us / 1000.0])
	_check("F: tick() de gravedad <= 1 ms (medido)", us <= 1000.0)

	var g01: Dictionary = PuzzleGravedad.cargar(RUTA_01)
	var t1 := Time.get_ticks_usec()
	for i in range(500):
		PuzzleGravedad.desde_def(g01).validar_gravedad()
	var us_val := float(Time.get_ticks_usec() - t1) / 500.0
	print("  [INFO] validar_gravedad(gravedad_01): %.2f us" % us_val)
	_check("F: validar_gravedad < 10 ms (autoria, no tick)", us_val < 10000.0)

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
