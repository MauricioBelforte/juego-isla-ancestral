# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-07
#
# M24 iter. 3: test headless de la familia BLOQUES (push/pull) datos-driven.
# Cubre los items 84-88 del checklist:
#   84 push/pull con restriccion de 1 eje · 85 ranuras de destino ·
#   86 puentes desplegables · 87 sin empuje a otras salas (limites) ·
#   88 documentacion (fuera de esta suite, en 03-Diseno/04-Codigo).
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/templos/test_puzzle_bloques.gd
#
# Protocolo anti-falso-verde:
#   - BLOQUES nombrados + _fin() al final de cada uno (un aborto silencioso deja el bloque sin marcar).
#   - Piso CHECKS_MINIMOS MEDIDO en verde (no estimado).
#   - _summary() registrado en call_deferred: si _run() aborta, el resumen igual corre y nombra lo que falto.
#   - Bloque D = SONDA ROJA: la capa espacial y el detector de ambiguedad se prueban EN VIVO
#     sobre copias mutadas de los puzzles reales.

extends SceneTree

const MODULO := "M24-Bloques"
const CHECKS_MINIMOS := 64   # MEDIDO en verde (ajustar SOLO tras medir, nunca estimar)

const BLOQUES := ["A", "B", "C", "D", "E", "F"]

const RUTA_01 := "res://data/templos/puzzles/bloques/bloques_01.json"
const RUTA_02 := "res://data/templos/puzzles/bloques/bloques_02.json"

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
	print("=== [%s] Test de la familia bloques (push/pull, datos-driven) ===" % MODULO)
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
	var b01: Dictionary = PuzzleBloques.cargar(RUTA_01)
	var b02: Dictionary = PuzzleBloques.cargar(RUTA_02)
	_check("A: bloques_01.json existe y parsea", not b01.is_empty())
	_check("A: bloques_02.json existe y parsea", not b02.is_empty())
	_check("A: bloques_01 familia == bloques", str(b01.get("familia", "")) == "bloques")
	_check("A: bloques_02 familia == bloques", str(b02.get("familia", "")) == "bloques")
	_check("A: bloques_01 declara 1 emisor", PuzzleDef.ids_emisores(b01).size() == 1)
	_check("A: bloques_02 declara 2 emisores", PuzzleDef.ids_emisores(b02).size() == 2)
	_check("A: bloques_01 objetivo == [0]", _canon(PuzzleDef.ids_objetivo(b01)) == "0")
	_check("A: bloques_02 objetivo == [0,1]", _canon(PuzzleDef.ids_objetivo(b02)) == "0,1")

# --- Bloque B: validacion (framework + capa espacial) --------------------

func _bloque_b_validacion() -> void:
	var b01: Dictionary = PuzzleBloques.cargar(RUTA_01)
	var b02: Dictionary = PuzzleBloques.cargar(RUTA_02)
	_check("B: validar_def(bloques_01) sin errores", PuzzleDef.validar_def(b01).is_empty())
	_check("B: validar_def(bloques_02) sin errores", PuzzleDef.validar_def(b02).is_empty())
	_check("B: soluciones_minimas(bloques_01) == 1", PuzzleDef.soluciones_minimas(b01) == 1)
	_check("B: soluciones_minimas(bloques_02) == 1", PuzzleDef.soluciones_minimas(b02) == 1)
	_check("B: solucion_minima(bloques_01) == objetivo",
		_canon(PuzzleDef.solucion_minima(b01)) == _canon(PuzzleDef.ids_objetivo(b01)))
	_check("B: solucion_minima(bloques_02) == objetivo",
		_canon(PuzzleDef.solucion_minima(b02)) == _canon(PuzzleDef.ids_objetivo(b02)))
	_check("B: completado_por(bloques_02, [0,1])", PuzzleDef.completado_por(b02, [0, 1]))
	_check("B: NO completado_por(bloques_02, [0])", not PuzzleDef.completado_por(b02, [0]))
	_check("B: validar_espacial(bloques_01) sin errores",
		PuzzleBloques.desde_def(b01).validar_espacial().is_empty())
	_check("B: validar_espacial(bloques_02) sin errores",
		PuzzleBloques.desde_def(b02).validar_espacial().is_empty())

# --- Bloque C: propiedades de la familia (items 84-87) -------------------

func _bloque_c_propiedades_familia() -> void:
	var b01: Dictionary = PuzzleBloques.cargar(RUTA_01)
	var b02: Dictionary = PuzzleBloques.cargar(RUTA_02)
	var pb01: PuzzleBloques = PuzzleBloques.desde_def(b01)
	var pb02: PuzzleBloques = PuzzleBloques.desde_def(b02)

	# item 84: 1 eje por pieza, dentro del vocabulario.
	_check("C: bloque_a de bloques_01 declara eje 'x'", pb01.eje_de("bloque_a") == "x")
	var todos_ejes_ok := true
	for id in pb02.piezas:
		var e: String = pb02.eje_de(str(id))
		if e != "x" and e != "y":
			todos_ejes_ok = false
	_check("C: cada pieza de bloques_02 declara 1 eje valido (x|y)", todos_ejes_ok)
	_check("C: bloques_02 tiene un bloque en eje x y otro en eje y (1 eje cada uno)",
		pb02.eje_de("bloque_a") == "x" and pb02.eje_de("bloque_b") == "y")

	# item 85: ranuras de destino declaradas y dentro de la grilla.
	_check("C: ranura de bloque_a (01) dentro de la grilla",
		_dentro(pb01, pb01.ranura_de("bloque_a")))
	_check("C: ambas ranuras de bloques_02 dentro de la grilla",
		_dentro(pb02, pb02.ranura_de("bloque_a")) and _dentro(pb02, pb02.ranura_de("bloque_b")))
	_check("C: hay tantas piezas como emisores declarados (01)",
		pb01.piezas.size() == PuzzleDef.ids_emisores(b01).size())
	_check("C: hay tantas piezas como emisores declarados (02)",
		pb02.piezas.size() == PuzzleDef.ids_emisores(b02).size())

	# item 86: el receptor del puzzle es un puente desplegable.
	_check("C: el receptor de bloques_01 es un puente",
		_receptor_de(b01).contains("puente"))
	_check("C: el receptor de bloques_02 es un puente",
		_receptor_de(b02).contains("puente"))

	# item 87: limites declarados (sin empuje a otras salas).
	_check("C: bloques_01 declara limites con salir_de_grilla=false",
		pb01.limites.has("salir_de_grilla") and not bool(pb01.limites["salir_de_grilla"]))
	_check("C: bloques_02 declara limites con salir_de_grilla=false",
		pb02.limites.has("salir_de_grilla") and not bool(pb02.limites["salir_de_grilla"]))
	_check("C: bloques_02 declara limites con salas_adyacentes=false",
		pb02.limites.has("salas_adyacentes") and not bool(pb02.limites["salas_adyacentes"]))

# --- Bloque D: SONDA ROJA (capa espacial + detector de ambiguedad) -------

func _bloque_d_sonda_roja() -> void:
	var b01: Dictionary = PuzzleBloques.cargar(RUTA_01)

	# Controles positivos: el puzzle real valida en ambas capas.
	_check("D: control positivo — bloques_01 valida sin errores", PuzzleDef.validar_def(b01).is_empty())
	_check("D: control positivo — validar_espacial(bloques_01) sin errores",
		PuzzleBloques.desde_def(b01).validar_espacial().is_empty())

	# SONDA 1: eje invalido ('z') inyectado en una copia -> la capa espacial DEBE fallar.
	var mutado_eje: Dictionary = b01.duplicate(true)
	(((mutado_eje["bloques"] as Dictionary)["piezas"] as Array)[0] as Dictionary)["eje"] = "z"
	var err_eje: Array = PuzzleBloques.desde_def(mutado_eje).validar_espacial()
	_check("D: eje invalido 'z' -> validar_espacial DEBE fallar", not err_eje.is_empty())
	_check("D: el error nombra \"eje 'z' no permitido\"", _contiene(err_eje, "eje 'z' no permitido"))

	# SONDA 2: limite 'salir_de_grilla' puesto en true -> la capa espacial DEBE fallar.
	var mutado_lim: Dictionary = b01.duplicate(true)
	((mutado_lim["bloques"] as Dictionary)["limites"] as Dictionary)["salir_de_grilla"] = true
	_check("D: limite salir_de_grilla=true -> validar_espacial DEBE fallar",
		_contiene(PuzzleBloques.desde_def(mutado_lim).validar_espacial(), "debe ser false"))

	# SONDA 3: ambiguedad real de reglas -> 2 caminos OR -> 2 soluciones minimas.
	var mutado_amb: Dictionary = b01.duplicate(true)
	(mutado_amb["emisores"] as Array).append({"id": 1, "tipo": "ranura", "etiqueta": "ranura_oeste"})
	(mutado_amb["reglas"] as Array).clear()
	(mutado_amb["reglas"] as Array).append({"emisores": [0], "receptor": "puente_bloques"})
	(mutado_amb["reglas"] as Array).append({"emisores": [1], "receptor": "puente_bloques"})
	_check("D: copia mutada (2 caminos OR) tiene soluciones_minimas == 2",
		PuzzleDef.soluciones_minimas(mutado_amb) == 2)
	_check("D: validar_def DEBE detectar la ambiguedad inyectada",
		_contiene(PuzzleDef.validar_def(mutado_amb), "ambiguo"))

# --- Bloque E: simulacion real de push/pull ------------------------------

func _bloque_e_simulacion() -> void:
	var pb: PuzzleBloques = PuzzleBloques.desde_def(PuzzleBloques.cargar(RUTA_01))
	_check("E: bloque_a arranca en (0,0)", pb.posicion("bloque_a") == Vector2i(0, 0))
	_check("E: arranca con 0 ranuras ocupadas", pb.ranuras_ocupadas() == 0)
	_check("E: arranca con el puente NO activo", not pb.puente_activo())

	# item 84: eje permitido (x) mueve; eje prohibido (y) NO mueve.
	_check("E: empujar +x (eje permitido) mueve a (1,0)", pb.empujar("bloque_a", 1, 0) and pb.posicion("bloque_a") == Vector2i(1, 0))
	_check("E: empujar +y (eje PROHIBIDO) NO mueve (item 84)", not pb.empujar("bloque_a", 0, 1) and pb.posicion("bloque_a") == Vector2i(1, 0))
	_check("E: empujar -y (eje PROHIBIDO) NO mueve (item 84)", not pb.empujar("bloque_a", 0, -1) and pb.posicion("bloque_a") == Vector2i(1, 0))
	_check("E: empujar en diagonal NO mueve", not pb.empujar("bloque_a", 1, 1))

	# item 87: no se empuja fuera de la grilla.
	_check("E: volver a (0,0)", pb.empujar("bloque_a", -1, 0) and pb.posicion("bloque_a") == Vector2i(0, 0))
	_check("E: empujar -x fuera de la grilla NO mueve (item 87)", not pb.empujar("bloque_a", -1, 0))
	_check("E: la pieza sigue en (0,0) tras el rechazo (limite)", pb.posicion("bloque_a") == Vector2i(0, 0))

	# item 85/86: llegar a la ranura enciende el emisor y arma el puente.
	_check("E: 3 empujes +x llevan a la ranura (3,0)",
		pb.empujar("bloque_a", 1, 0) and pb.empujar("bloque_a", 1, 0) and pb.empujar("bloque_a", 1, 0) and pb.posicion("bloque_a") == Vector2i(3, 0))
	_check("E: la ranura queda ocupada (1)", pb.ranuras_ocupadas() == 1)
	_check("E: el emisor 0 queda ON en la sala", bool(pb.sala.emisores[0]))
	_check("E: el puente queda ACTIVO (S == objetivo)", pb.puente_activo())
	_check("E: sala.estado_igual_objetivo()", pb.sala.estado_igual_objetivo())

	# bloques_02: colision entre piezas + ambos ejes + puente con AMBOS.
	var pb2: PuzzleBloques = PuzzleBloques.desde_def(PuzzleBloques.cargar(RUTA_02))
	_check("E: 02 — bloque_b arranca en (0,1)", pb2.posicion("bloque_b") == Vector2i(0, 1))
	_check("E: 02 — empujar bloque_b -y hacia (0,0) ocupada por bloque_a -> rechazado (colision)",
		not pb2.empujar("bloque_b", 0, -1) and pb2.posicion("bloque_b") == Vector2i(0, 1))
	_check("E: 02 — empujar bloque_b +y (eje permitido) mueve a (0,2)",
		pb2.empujar("bloque_b", 0, 1) and pb2.posicion("bloque_b") == Vector2i(0, 2))
	_check("E: 02 — bloque_b NO se mueve en x (item 84)", not pb2.empujar("bloque_b", 1, 0))
	_check("E: 02 — bloque_a NO se mueve en y (item 84)", not pb2.empujar("bloque_a", 0, 1))
	# Completar bloque_a (3 empujes +x) y bloque_b (1 empuje +y restante).
	var a_ok: bool = pb2.empujar("bloque_a", 1, 0) and pb2.empujar("bloque_a", 1, 0) and pb2.empujar("bloque_a", 1, 0)
	_check("E: 02 — bloque_a llega a su ranura (3,0)", a_ok and pb2.posicion("bloque_a") == Vector2i(3, 0))
	_check("E: 02 — con solo bloque_a en su ranura el puente NO se arma (distancia 1)",
		pb2.ranuras_ocupadas() == 1 and not pb2.puente_activo() and pb2.sala.esta_a_casi_solucion())
	_check("E: 02 — bloque_b llega a su ranura (0,3)",
		pb2.empujar("bloque_b", 0, 1) and pb2.posicion("bloque_b") == Vector2i(0, 3))
	_check("E: 02 — con AMBAS ranuras el puente se arma", pb2.ranuras_ocupadas() == 2 and pb2.puente_activo())

# --- Bloque F: rendimiento MEDIDO (item 171) -----------------------------

func _bloque_f_rendimiento() -> void:
	var iters := 2000
	var us01 := _tick_us(PuzzleBloques.desde_def(PuzzleBloques.cargar(RUTA_01)), iters)
	var us02 := _tick_us(PuzzleBloques.desde_def(PuzzleBloques.cargar(RUTA_02)), iters)
	print("  [INFO] tick de sala (01): %.4f us/tick (%.6f ms)" % [us01, us01 / 1000.0])
	print("  [INFO] tick de sala (02): %.4f us/tick (%.6f ms)" % [us02, us02 / 1000.0])
	_check("F: tick de sala (01) <= 1 ms (medido)", us01 <= 1000.0)
	_check("F: tick de sala (02) <= 1 ms (medido)", us02 <= 1000.0)

	# Coste de la herramienta de autoria (validar_def con fuerza bruta 2^n), n=2.
	var b02: Dictionary = PuzzleBloques.cargar(RUTA_02)
	var t0 := Time.get_ticks_usec()
	for i in range(200):
		PuzzleDef.validar_def(b02)
	var us_val := float(Time.get_ticks_usec() - t0) / 200.0
	print("  [INFO] validar_def(bloques_02, n=2): %.2f us (%.4f ms)" % [us_val, us_val / 1000.0])
	_check("F: validar_def(bloques_02) < 10 ms (autoria, no tick)", us_val < 10000.0)

## Coste medio de un "tick" de sala: alternar un emisor + recalcular + distancia.
func _tick_us(pb: PuzzleBloques, iters: int) -> float:
	var sala: PuzzleRoom = pb.sala
	var t0 := Time.get_ticks_usec()
	for i in range(iters):
		sala.set_emisor(0, (i % 2) == 0)
		sala.distancia_objetivo()
	return float(Time.get_ticks_usec() - t0) / float(iters)

# --- Helpers -------------------------------------------------------------

func _dentro(pb: PuzzleBloques, p: Vector2i) -> bool:
	return p.x >= 0 and p.y >= 0 and p.x < pb.ancho and p.y < pb.alto

## Primer receptor declarado en las reglas de una definicion.
func _receptor_de(def: Dictionary) -> String:
	for r in PuzzleDef.reglas_def(def):
		if typeof(r) == TYPE_DICTIONARY:
			return str((r as Dictionary).get("receptor", ""))
	return ""

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
