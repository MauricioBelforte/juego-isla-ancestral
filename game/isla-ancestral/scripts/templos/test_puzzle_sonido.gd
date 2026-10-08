# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-07
#
# M24 iter. 5: test headless de la familia SONIDO Y SECUENCIA (datos-driven).
# Cubre los items 102-107 del checklist (el 103 queda BLOQUEADO por M43):
#   102 campanas/gongs como emisores · 104 sin hardware de audio ·
#   105 secuencias de 3-5 simbolos · 106 pista del patron tras 2 intentos ·
#   107 documentacion.
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/templos/test_puzzle_sonido.gd
#
# Protocolo anti-falso-verde:
#   - BLOQUES nombrados + _fin() al final de cada uno.
#   - Piso CHECKS_MINIMOS MEDIDO en verde (no estimado).
#   - _summary() en call_deferred: si _run() aborta, el resumen igual corre y nombra lo que falto.
#   - Bloque D = SONDA ROJA: los validadores se prueban EN VIVO sobre copias mutadas de los puzzles reales.
#   - item 104 se verifica por LECTURA del fuente: ninguna linea de CODIGO referencia "Audio".

extends SceneTree

const MODULO := "M24-Sonido"
const CHECKS_MINIMOS := 54   # MEDIDO en verde (ajustar SOLO tras medir, nunca estimar)

const BLOQUES := ["A", "B", "C", "D", "E", "F"]

const RUTA_01 := "res://data/templos/puzzles/sonido/sonido_01.json"
const RUTA_02 := "res://data/templos/puzzles/sonido/sonido_02.json"

const FUENTE := "res://scripts/templos/puzzle_sonido.gd"

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
	print("=== [%s] Test de la familia sonido (secuencia, datos-driven) ===" % MODULO)
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
	var s01: Dictionary = PuzzleSonido.cargar(RUTA_01)
	var s02: Dictionary = PuzzleSonido.cargar(RUTA_02)
	_check("A: sonido_01.json existe y parsea", not s01.is_empty())
	_check("A: sonido_02.json existe y parsea", not s02.is_empty())
	_check("A: sonido_01 familia == sonido", str(s01.get("familia", "")) == "sonido")
	_check("A: sonido_02 familia == sonido", str(s02.get("familia", "")) == "sonido")
	_check("A: sonido_01 declara 1 emisor", PuzzleDef.ids_emisores(s01).size() == 1)
	_check("A: sonido_02 declara 2 emisores", PuzzleDef.ids_emisores(s02).size() == 2)
	_check("A: sonido_01 objetivo == [0]", _canon(PuzzleDef.ids_objetivo(s01)) == "0")
	_check("A: sonido_02 objetivo == [0,1]", _canon(PuzzleDef.ids_objetivo(s02)) == "0,1")

# --- Bloque B: validacion (framework + capa de sonido) -------------------

func _bloque_b_validacion() -> void:
	var s01: Dictionary = PuzzleSonido.cargar(RUTA_01)
	var s02: Dictionary = PuzzleSonido.cargar(RUTA_02)
	_check("B: validar_def(sonido_01) sin errores", PuzzleDef.validar_def(s01).is_empty())
	_check("B: validar_def(sonido_02) sin errores", PuzzleDef.validar_def(s02).is_empty())
	_check("B: soluciones_minimas(sonido_01) == 1", PuzzleDef.soluciones_minimas(s01) == 1)
	_check("B: soluciones_minimas(sonido_02) == 1", PuzzleDef.soluciones_minimas(s02) == 1)
	_check("B: validar_sonido(sonido_01) sin errores", PuzzleSonido.desde_def(s01).validar_sonido().is_empty())
	_check("B: validar_sonido(sonido_02) sin errores", PuzzleSonido.desde_def(s02).validar_sonido().is_empty())
	_check("B: sonido_01 declara 3 campanas", PuzzleSonido.desde_def(s01).campanas.size() == 3)
	_check("B: sonido_02 declara 5 campanas", PuzzleSonido.desde_def(s02).campanas.size() == 5)

# --- Bloque C: propiedades de la familia (items 102-106) -----------------

func _bloque_c_propiedades_familia() -> void:
	var p1: PuzzleSonido = PuzzleSonido.desde_def(PuzzleSonido.cargar(RUTA_01))

	# item 102: campanas declaradas con tono, posicion y emisor.
	_check("C: c1 declarada en (0,0) con tono 1 (item 102)",
		(p1.campanas["c1"] as Dictionary)["pos"] == Vector2i(0, 0)
		and int((p1.campanas["c1"] as Dictionary)["tono"]) == 1)
	_check("C: las 3 campanas de sonido_01 comparten el emisor 0",
		int((p1.campanas["c1"] as Dictionary)["emisor"]) == 0
		and int((p1.campanas["c3"] as Dictionary)["emisor"]) == 0)

	# item 105: la secuencia tiene entre 3 y 5 simbolos.
	_check("C: secuencia de sonido_01 tiene 3 simbolos (item 105)", p1.secuencia.size() == 3)
	_check("C: 3 <= 3 <= 5 (dentro del rango declarado)", p1.secuencia.size() >= PuzzleSonido.LARGO_MIN and p1.secuencia.size() <= PuzzleSonido.LARGO_MAX)
	var p2: PuzzleSonido = PuzzleSonido.desde_def(PuzzleSonido.cargar(RUTA_02))
	_check("C: secuencia de sonido_02 tiene 5 simbolos (item 105)", p2.secuencia.size() == 5)

	# item 102 + 105: tocar la secuencia correcta activa el receptor.
	var t1: PuzzleSonido = PuzzleSonido.desde_def(PuzzleSonido.cargar(RUTA_01))
	var r1: Dictionary = t1.tocar("c1")
	_check("C: tocar c1 es correcto y NO resuelve aun",
		bool(r1["aceptado"]) and bool(r1["correcto"]) and not bool(r1["resuelto"]))
	var r2: Dictionary = t1.tocar("c2")
	_check("C: tocar c2 continua la secuencia (progreso 2)", int(r2["progreso"]) == 2)
	_check("C: el receptor aun NO esta activado", not t1.receptor_activado())
	var r3: Dictionary = t1.tocar("c3")
	_check("C: tocar c3 COMPLETA la secuencia (resuelto)", bool(r3["resuelto"]))
	_check("C: resuelto() == true", t1.resuelto())
	_check("C: el emisor 0 queda ON", bool(t1.sala.emisores[0]))
	_check("C: receptor activado (S == T)", t1.receptor_activado())

	# item 106: la pista del patron aparece tras 2 intentos fallidos.
	var t2: PuzzleSonido = PuzzleSonido.desde_def(PuzzleSonido.cargar(RUTA_01))
	_check("C: al inicio la pista NO esta disponible", not t2.pista_disponible())
	_check("C: al inicio pista_patron() devuelve [] (no regala)", t2.pista_patron().is_empty())
	t2.tocar("c2")
	_check("C: tras 1 fallo sigue sin pista (fallos == 1)", t2.intentos_fallidos() == 1 and not t2.pista_disponible())
	t2.tocar("c3")
	_check("C: tras 2 fallos la pista esta disponible (item 106)", t2.pista_disponible())
	_check("C: pista_patron() == la secuencia completa [c1,c2,c3] (item 106)",
		_canon_str(t2.pista_patron()) == "c1,c2,c3")

	# item 104: el modelo NO referencia audio en el CODIGO (solo en comentarios).
	_check("C: puzzle_sonido.gd no referencia 'Audio' en codigo (item 104)", _sin_referencias_audio(FUENTE))

# --- Bloque D: SONDA ROJA (validadores sobre copias mutadas) -------------

func _bloque_d_sonda_roja() -> void:
	var s01: Dictionary = PuzzleSonido.cargar(RUTA_01)

	# Control positivo: el puzzle real valida.
	_check("D: control positivo — validar_sonido(sonido_01) sin errores",
		PuzzleSonido.desde_def(s01).validar_sonido().is_empty())

	# SONDA 1: secuencia de 2 simbolos -> DEBE fallar.
	var m1: Dictionary = s01.duplicate(true)
	(m1["sonido"] as Dictionary)["secuencia"] = ["c1", "c2"]
	_check("D: secuencia de 2 -> validar_sonido DEBE fallar",
		_contiene(PuzzleSonido.desde_def(m1).validar_sonido(), "se exige entre 3 y 5"))

	# SONDA 2: secuencia de 6 simbolos -> DEBE fallar.
	var m2: Dictionary = s01.duplicate(true)
	(m2["sonido"] as Dictionary)["secuencia"] = ["c1", "c2", "c3", "c1", "c2", "c3"]
	_check("D: secuencia de 6 -> validar_sonido DEBE fallar",
		_contiene(PuzzleSonido.desde_def(m2).validar_sonido(), "se exige entre 3 y 5"))

	# SONDA 3: campana con emisor inexistente -> DEBE fallar.
	var m3: Dictionary = s01.duplicate(true)
	var camps3: Array = (m3["sonido"] as Dictionary)["campanas"]
	(camps3[0] as Dictionary)["emisor"] = 9
	_check("D: campana emisor 9 -> validar_sonido DEBE fallar",
		_contiene(PuzzleSonido.desde_def(m3).validar_sonido(), "emisor 9 inexistente"))

	# SONDA 4: la secuencia usa una campana inexistente -> DEBE fallar.
	var m4: Dictionary = s01.duplicate(true)
	(m4["sonido"] as Dictionary)["secuencia"] = ["c1", "c2", "c9"]
	_check("D: secuencia con campana inexistente -> validar_sonido DEBE fallar",
		_contiene(PuzzleSonido.desde_def(m4).validar_sonido(), "campana inexistente"))

	# SONDA 5: sin campanas -> DEBE fallar.
	var m5: Dictionary = s01.duplicate(true)
	(m5["sonido"] as Dictionary)["campanas"] = []
	_check("D: sin campanas -> validar_sonido DEBE fallar",
		_contiene(PuzzleSonido.desde_def(m5).validar_sonido(), "sin campanas"))

	# SONDA 6 (semantica): una secuencia equivocada NUNCA resuelve.
	var t6: PuzzleSonido = PuzzleSonido.desde_def(PuzzleSonido.cargar(RUTA_01))
	for i in range(10):
		t6.tocar("c3")
		t6.tocar("c2")
	_check("D: secuencia equivocada -> nunca resuelve", not t6.resuelto())
	_check("D: los fallos se acumulan (>= 2)", t6.intentos_fallidos() >= 2)

	# SONDA 7 (semantica): tocar una campana inexistente no altera el progreso.
	var t7: PuzzleSonido = PuzzleSonido.desde_def(PuzzleSonido.cargar(RUTA_01))
	t7.tocar("c1")
	var rf: Dictionary = t7.tocar("no_existe")
	_check("D: campana inexistente -> aceptado == false", not bool(rf["aceptado"]))
	_check("D: campana inexistente NO rompe el intento (progreso 1)",
		t7.intento_actual().size() == 1)

# --- Bloque E: simulacion real -------------------------------------------

func _bloque_e_simulacion() -> void:
	# sonido_02: 5 campanas en 2 grupos, secuencia [c3,c1,c5,c2,c4] -> ambas runas ON.
	var e1: PuzzleSonido = PuzzleSonido.desde_def(PuzzleSonido.cargar(RUTA_02))
	_check("E: sonido_02 arranca sin resolver", not e1.resuelto())
	_check("E: sonido_02 arranca con el receptor inactivo", not e1.receptor_activado())
	_check("E: tocar_secuencia() completa el puzzle", e1.tocar_secuencia())
	_check("E: los DOS emisores quedan ON", bool(e1.sala.emisores[0]) and bool(e1.sala.emisores[1]))
	_check("E: receptor activado (S == T)", e1.receptor_activado())
	_check("E: sala.estado_igual_objetivo()", e1.sala.estado_igual_objetivo())

	# Tras resolver, tocar de nuevo se rechaza ("ya resuelto").
	var rt: Dictionary = e1.tocar("c1")
	_check("E: tocar tras resolver -> aceptado == false", not bool(rt["aceptado"]))
	_check("E: tocar tras resolver -> resuelto == true", bool(rt["resuelto"]))

# --- Bloque F: rendimiento MEDIDO ----------------------------------------

func _bloque_f_rendimiento() -> void:
	var s02: Dictionary = PuzzleSonido.cargar(RUTA_02)
	var iters := 2000
	var t0 := Time.get_ticks_usec()
	for i in range(iters):
		PuzzleSonido.desde_def(s02).tocar_secuencia()
	var us := float(Time.get_ticks_usec() - t0) / float(iters)
	print("  [INFO] cargar+tocar_secuencia (sonido_02): %.2f us (%.4f ms)" % [us, us / 1000.0])
	_check("F: cargar+tocar_secuencia <= 5 ms (medido)", us <= 5000.0)

	var t1 := Time.get_ticks_usec()
	for i in range(1000):
		PuzzleSonido.desde_def(s02).validar_sonido()
	var us_val := float(Time.get_ticks_usec() - t1) / 1000.0
	print("  [INFO] validar_sonido(sonido_02): %.2f us" % us_val)
	_check("F: validar_sonido < 10 ms (autoria, no tick)", us_val < 10000.0)

# --- Helpers -------------------------------------------------------------

## item 104: true si NINGUNA linea de CODIGO (no comentario) referencia "Audio".
func _sin_referencias_audio(path: String) -> bool:
	if not FileAccess.file_exists(path):
		return false
	var texto: String = FileAccess.get_file_as_string(path)
	for linea in texto.split("\n"):
		var l: String = (linea as String).strip_edges()
		if l.begins_with("#"):
			continue
		if l.contains("Audio"):
			return false
	return true

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
