# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-07
#
# M24 iter. 5: test headless de la familia PISTAS Y AYUDA (datos-driven).
# Cubre los items 132-139 del checklist:
#   132 3 capas (ambiental -> diario -> total) · 134 pista diferida (90 s) ·
#   135 pista de familia · 136 pista de emisor exacto · 137 solucion paso a paso tras 3 pistas ·
#   138 pistas ancladas a las reglas del grafo · 139 eleccion libre sin penalizacion.
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/templos/test_puzzle_pistas.gd
#
# Protocolo anti-falso-verde:
#   - BLOQUES nombrados + _fin() al final de cada uno.
#   - Piso CHECKS_MINIMOS MEDIDO en verde (no estimado).
#   - _summary() en call_deferred: si _run() aborta, el resumen igual corre y nombra lo que falto.
#   - Bloque D = SONDA ROJA: los validadores y las pistas se prueban EN VIVO sobre copias mutadas.

extends SceneTree

const MODULO := "M24-Pistas"
const CHECKS_MINIMOS := 58   # MEDIDO en verde (ajustar SOLO tras medir, nunca estimar)

const BLOQUES := ["A", "B", "C", "D", "E", "F"]

const RUTA_01 := "res://data/templos/puzzles/pistas/pistas_01.json"
const RUTA_02 := "res://data/templos/puzzles/pistas/pistas_02.json"

## Diario de prueba con el contrato real de diary_service.gd: registrar(id, categoria) -> bool.
class DiarioFalso extends RefCounted:
	var entradas: Array = []
	func registrar(entrada_id: String, categoria: String) -> bool:
		entradas.append([entrada_id, categoria])
		return true

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
	print("=== [%s] Test de la familia pistas (ayuda, datos-driven) ===" % MODULO)
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
	var p01: Dictionary = PuzzlePistas.cargar(RUTA_01)
	var p02: Dictionary = PuzzlePistas.cargar(RUTA_02)
	_check("A: pistas_01.json existe y parsea", not p01.is_empty())
	_check("A: pistas_02.json existe y parsea", not p02.is_empty())
	_check("A: pistas_01 familia == presion", str(p01.get("familia", "")) == "presion")
	_check("A: pistas_02 familia == luz", str(p02.get("familia", "")) == "luz")
	_check("A: pistas_01 declara 2 emisores", PuzzleDef.ids_emisores(p01).size() == 2)
	_check("A: pistas_02 declara 1 emisor", PuzzleDef.ids_emisores(p02).size() == 1)
	_check("A: pistas_01 categoria_diario == templos",
		PuzzlePistas.desde_def(p01).categoria_diario == "templos")

# --- Bloque B: validacion (framework + capa de pistas) -------------------

func _bloque_b_validacion() -> void:
	var p01: Dictionary = PuzzlePistas.cargar(RUTA_01)
	var p02: Dictionary = PuzzlePistas.cargar(RUTA_02)
	_check("B: validar_def(pistas_01) sin errores", PuzzleDef.validar_def(p01).is_empty())
	_check("B: validar_def(pistas_02) sin errores", PuzzleDef.validar_def(p02).is_empty())
	_check("B: soluciones_minimas(pistas_01) == 1", PuzzleDef.soluciones_minimas(p01) == 1)
	_check("B: soluciones_minimas(pistas_02) == 1", PuzzleDef.soluciones_minimas(p02) == 1)
	_check("B: validar_pistas(pistas_01) sin errores", PuzzlePistas.desde_def(p01).validar_pistas().is_empty())
	_check("B: validar_pistas(pistas_02) sin errores", PuzzlePistas.desde_def(p02).validar_pistas().is_empty())
	_check("B: pistas_01 tiene una solucion minima unica [0,1]",
		_canon(PuzzleDef.solucion_minima(p01)) == "0,1")

# --- Bloque C: propiedades de la familia (items 132-139) -----------------

func _bloque_c_propiedades_familia() -> void:
	var pp: PuzzlePistas = PuzzlePistas.desde_def(PuzzlePistas.cargar(RUTA_01))

	# item 132: 3 capas declaradas.
	_check("C: capas() == [ambiental, diario, total] (item 132)",
		_canon_str(pp.capas()) == "ambiental,diario,total")
	_check("C: el sistema tiene exactamente 3 capas (item 132)", pp.capas().size() == 3)

	# item 132: capa 2 — registra la entrada en el diario (ancla real diary_service).
	var d := DiarioFalso.new()
	_check("C: registrar_en_diario(diario) == true (item 132)", pp.registrar_en_diario(d))
	_check("C: el diario guardo 1 entrada", d.entradas.size() == 1)
	_check("C: la entrada del diario cita la familia 'presion'",
		str((d.entradas[0] as Array)[0]).contains("presion"))
	_check("C: la entrada usa la categoria 'templos'", str((d.entradas[0] as Array)[1]) == "templos")
	_check("C: registrar_en_diario(null) == false", not pp.registrar_en_diario(null))
	_check("C: registrar_en_diario(objeto sin contrato) == false",
		not pp.registrar_en_diario(RefCounted.new()))

	# item 134: pista diferida tras 90 s sin progreso.
	var pd: PuzzlePistas = PuzzlePistas.desde_def(PuzzlePistas.cargar(RUTA_01))
	_check("C: al inicio la pista diferida NO esta disponible", not pd.pista_diferida_disponible())
	pd.avanzar(89.0)
	_check("C: a los 89 s sigue sin estar disponible", not pd.pista_diferida_disponible())
	pd.avanzar(1.0)
	_check("C: a los 90 s la pista diferida SE habilita (item 134)", pd.pista_diferida_disponible())
	pd.reiniciar_espera()
	_check("C: reiniciar_espera() la deshabilita de nuevo", not pd.pista_diferida_disponible())

	# item 135: pista de familia.
	_check("C: pista_familia() cita 'presion' (item 135)", pp.pista_familia().contains("presion"))

	# item 136: pista de emisor exacto, derivada de la solucion minima.
	var pe: String = pp.pista_emisor_exacto()
	_check("C: pista_emisor_exacto() cita el emisor 0 (item 136)", pe.contains("0"))
	_check("C: pista_emisor_exacto() cita el emisor 1 (item 136)", pe.contains("1"))

	# item 138: pista anclada a las reglas del grafo (no texto suelto).
	var pg: String = pp.pista_anclada_a_grafo()
	_check("C: pista_anclada_a_grafo() cita el receptor 'puerta_pistas' (item 138)",
		pg.contains("puerta_pistas"))
	_check("C: pista_anclada_a_grafo() cita el conjunto de emisores [0, 1] (item 138)",
		pg.contains("0, 1"))

	# item 137: la solucion paso a paso NO se regala antes de 3 pistas.
	_check("C: sin pistas usadas, solucion_paso_a_paso() == [] (item 137)",
		pp.solucion_paso_a_paso().is_empty())
	pp.usar_pista()
	pp.usar_pista()
	_check("C: con 2 pistas sigue vacia", pp.solucion_paso_a_paso().is_empty())
	pp.usar_pista()
	var pasos: Array = pp.solucion_paso_a_paso()
	_check("C: con 3 pistas se ofrece la solucion paso a paso (item 137)", pasos.size() >= 3)
	_check("C: el ultimo paso cita el receptor 'puerta_pistas'",
		str(pasos[pasos.size() - 1]).contains("puerta_pistas"))

	# item 139: eleccion libre, sin penalizacion.
	_check("C: penalizacion() == 0 antes de usar pistas (item 139)", pp.penalizacion() == 0)
	pp.usar_pista()
	pp.usar_pista()
	_check("C: penalizacion() sigue 0 tras 5 pistas (item 139)", pp.penalizacion() == 0)
	_check("C: pistas_usadas() == 5 (solo se cuenta, no se castiga)", pp.pistas_usadas() == 5)

	# pista_actual() segun la capa disponible + ultima_pista().
	var pac: PuzzlePistas = PuzzlePistas.desde_def(PuzzlePistas.cargar(RUTA_01))
	_check("C: sin espera, pista_actual() es la anclada al grafo",
		pac.pista_actual().contains("puerta_pistas"))
	pac.avanzar(90.0)
	_check("C: tras 90 s, pista_actual() pasa a la de familia",
		pac.pista_actual().contains("presion"))
	_check("C: ultima_pista() refleja la ultima consulta", pac.ultima_pista().contains("presion"))

# --- Bloque D: SONDA ROJA (validadores y derivacion sobre copias mutadas) -

func _bloque_d_sonda_roja() -> void:
	var p01: Dictionary = PuzzlePistas.cargar(RUTA_01)

	# Control positivo: el puzzle real valida.
	_check("D: control positivo — validar_pistas(pistas_01) sin errores",
		PuzzlePistas.desde_def(p01).validar_pistas().is_empty())

	# SONDA 1: definicion vacia -> DEBE fallar.
	_check("D: definicion vacia -> validar_pistas DEBE fallar",
		_contiene(PuzzlePistas.desde_def({}).validar_pistas(), "definicion vacia"))

	# SONDA 2: sin familia declarada -> DEBE fallar.
	var m2: Dictionary = p01.duplicate(true)
	m2["familia"] = ""
	_check("D: sin familia -> validar_pistas DEBE fallar",
		_contiene(PuzzlePistas.desde_def(m2).validar_pistas(), "sin familia declarada"))

	# SONDA 3: sin reglas -> DEBE fallar (no se puede anclar la pista).
	var m3: Dictionary = p01.duplicate(true)
	m3["reglas"] = []
	_check("D: sin reglas -> validar_pistas DEBE fallar",
		_contiene(PuzzlePistas.desde_def(m3).validar_pistas(), "sin reglas"))

	# SONDA 4 (item 138, semantica): la pista anclada se DERIVA de los datos.
	# Al cambiar el receptor en los datos, la pista DEBE citar el nuevo receptor.
	var m4: Dictionary = p01.duplicate(true)
	(((m4["reglas"] as Array)[0]) as Dictionary)["receptor"] = "puerta_renombrada"
	var pista4: String = PuzzlePistas.desde_def(m4).pista_anclada_a_grafo()
	_check("D: la pista anclada cita el receptor MUTADO 'puerta_renombrada' (item 138)",
		pista4.contains("puerta_renombrada"))
	_check("D: la pista anclada ya NO cita 'puerta_pistas' (deriva de datos)",
		not pista4.contains("puerta_pistas"))

	# SONDA 5 (item 136, semantica): cambiar la regla cambia el emisor exacto.
	var m5: Dictionary = p01.duplicate(true)
	(((m5["reglas"] as Array)[0]) as Dictionary)["emisores"] = [0]
	m5["objetivo"] = [0]
	var pista5: String = PuzzlePistas.desde_def(m5).pista_emisor_exacto()
	_check("D: con la regla [0], el emisor exacto cita solo el 0 (item 136)",
		pista5.contains("0") and not pista5.contains("1"))

	# SONDA 6 (semantica): sin pistas usadas, jamas se ofrece la solucion.
	var m6: PuzzlePistas = PuzzlePistas.desde_def(p01)
	_check("D: 0 pistas -> solucion_paso_a_paso() == [] (no regala)",
		m6.solucion_paso_a_paso().is_empty())
	_check("D: 0 pistas -> penalizacion() == 0", m6.penalizacion() == 0)

# --- Bloque E: simulacion real -------------------------------------------

func _bloque_e_simulacion() -> void:
	# pistas_02: familia luz, un unico emisor; pista diferida y paso a paso.
	var e1: PuzzlePistas = PuzzlePistas.desde_def(PuzzlePistas.cargar(RUTA_02))
	_check("E: pistas_02 pista_familia() cita 'luz'", e1.pista_familia().contains("luz"))
	_check("E: pistas_02 pista_emisor_exacto() cita el emisor 0",
		e1.pista_emisor_exacto().contains("0"))
	_check("E: pistas_02 pista_anclada cita 'runa_pistas'",
		e1.pista_anclada_a_grafo().contains("runa_pistas"))
	var d := DiarioFalso.new()
	_check("E: pistas_02 registra en el diario con la familia luz",
		e1.registrar_en_diario(d) and str((d.entradas[0] as Array)[0]).contains("luz"))
	for i in range(3):
		e1.usar_pista()
	_check("E: pistas_02 ofrece la solucion paso a paso tras 3 pistas",
		e1.solucion_paso_a_paso().size() >= 2)
	_check("E: pistas_02 penalizacion() == 0", e1.penalizacion() == 0)

# --- Bloque F: rendimiento MEDIDO ----------------------------------------

func _bloque_f_rendimiento() -> void:
	var p01: Dictionary = PuzzlePistas.cargar(RUTA_01)
	var iters := 2000
	var t0 := Time.get_ticks_usec()
	for i in range(iters):
		var pp: PuzzlePistas = PuzzlePistas.desde_def(p01)
		pp.pista_emisor_exacto()
		pp.pista_anclada_a_grafo()
	var us := float(Time.get_ticks_usec() - t0) / float(iters)
	print("  [INFO] cargar+derivar 2 pistas (pistas_01): %.2f us (%.4f ms)" % [us, us / 1000.0])
	_check("F: cargar+derivar 2 pistas <= 5 ms (medido)", us <= 5000.0)

	var t1 := Time.get_ticks_usec()
	for i in range(1000):
		PuzzlePistas.desde_def(p01).validar_pistas()
	var us_val := float(Time.get_ticks_usec() - t1) / 1000.0
	print("  [INFO] validar_pistas(pistas_01): %.2f us" % us_val)
	_check("F: validar_pistas < 10 ms (autoria, no tick)", us_val < 10000.0)

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

func _canon_str(arr: Array) -> String:
	var s: Array = []
	for x in arr:
		s.append(str(x))
	return ",".join(s)

func _contiene(errores: Array, sub: String) -> bool:
	for e in errores:
		if str(e).contains(sub):
			return true
	return false
