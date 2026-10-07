# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-07
#
# M24 iter. 4 — Frente 0: GATE DE REGRESION del catalogo de puzzles.
# No prueba una familia: corre TODAS las suites de M24 como subprocesos y exige,
# POR SUITE, EXIT 0 + 0 fallos + 0 SCRIPT ERROR + un piso de checks MEDIDO; y en
# conjunto un piso TOTAL medido. Cierra 0 items del checklist, pero es la red que
# impide que una familia nueva rompa las anteriores.
#
# Por que subprocesos y no llamadas directas: las suites son `extends SceneTree`
# (MainLoop), no se pueden instanciar como nodo. Y por que redirigimos a archivo:
# medido en este build, `OS.execute` NO captura el stdout de un Godot hijo (solo
# el banner); el redirect del shell SI. Por eso el comando va envuelto en el shell.
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/templos/test_regresion_templos.gd
#
# Protocolo anti-falso-verde:
#   - BLOQUES nombrados + _fin() al final de cada uno.
#   - Piso CHECKS_MINIMOS MEDIDO en verde (no estimado).
#   - _summary() en call_deferred: si _run() aborta, el resumen igual corre y nombra lo que falto.
#   - Bloque C = SONDA ROJA del CLASIFICADOR: se le alimentan salidas sinteticas buenas y
#     malas y se exige que discrimine. Si el clasificador no puede fallar, el gate no sirve.

extends SceneTree

const MODULO := "M24-Regresion"
const CHECKS_MINIMOS := 51   # MEDIDO en verde (ajustar SOLO tras medir, nunca estimar)

const BLOQUES := ["A", "B", "C"]

## Piso TOTAL de checks medidos en verde (suma de las suites con contador):
## 42 datos + 38 multilateral + 64 bloques + 60 luz + 62 espejos + 92 m26 + 4 headless = 362.
const TOTAL_MINIMO := 362

## Suites del catalogo de M24. "piso" es el CHECKS_MINIMOS real de cada suite (medido).
## "reporta_checks" = false para test_puzzles (suite original sin contador).
var SUITES := [
	{"nombre": "test_puzzles", "ruta": "res://scripts/templos/test_puzzles.gd", "piso": 0, "reporta_checks": false},
	{"nombre": "test_puzzle_datos", "ruta": "res://scripts/templos/test_puzzle_datos.gd", "piso": 42, "reporta_checks": true},
	{"nombre": "test_puzzle_multilateral", "ruta": "res://scripts/templos/test_puzzle_multilateral.gd", "piso": 38, "reporta_checks": true},
	{"nombre": "test_puzzle_bloques", "ruta": "res://scripts/templos/test_puzzle_bloques.gd", "piso": 64, "reporta_checks": true},
	{"nombre": "test_puzzle_luz", "ruta": "res://scripts/templos/test_puzzle_luz.gd", "piso": 60, "reporta_checks": true},
	{"nombre": "test_puzzle_espejos", "ruta": "res://scripts/templos/test_puzzle_espejos.gd", "piso": 62, "reporta_checks": true},
	{"nombre": "test_templo_m26", "ruta": "res://scripts/templos/test_templo_m26.gd", "piso": 92, "reporta_checks": true},
	{"nombre": "test_templo_headless", "ruta": "res://scripts/templos/test_templo_headless.gd", "piso": 4, "reporta_checks": true},
]

var _checks := 0
var _fallos := 0
var _vistos: Dictionary = {}
var _acumulado := 0

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
	print("=== [%s] Gate de regresion del catalogo de puzzles de M24 ===" % MODULO)
	_bloque_a_suites()
	_fin("A")
	_bloque_b_total()
	_fin("B")
	_bloque_c_sonda_clasificador()
	_fin("C")

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

# --- Bloque A: correr cada suite y clasificar su salida ------------------

func _bloque_a_suites() -> void:
	for s in SUITES:
		var nombre: String = str(s["nombre"])
		var ruta: String = str(s["ruta"])
		var piso: int = int(s["piso"])
		var reporta: bool = bool(s["reporta_checks"])
		var r: Dictionary = _correr_suite(ruta)
		var salida: String = str(r["salida"])
		var rc: int = int(r["rc"])
		var res: Dictionary = _clasificar(salida, rc, piso, reporta)
		var checks: int = int(res["checks"])
		var fallos: int = int(res["fallos"])
		var se: int = int(res["script_error"])
		print("  [INFO] %s: EXIT=%d checks=%d fallos=%d SCRIPT_ERROR=%d" % [nombre, rc, checks, fallos, se])
		_check("A: %s — salida capturada (no vacia)" % nombre, not salida.strip_edges().is_empty())
		_check("A: %s — EXIT 0" % nombre, rc == 0)
		_check("A: %s — 0 fallos" % nombre, fallos == 0)
		_check("A: %s — 0 SCRIPT ERROR" % nombre, se == 0)
		if reporta:
			_check("A: %s — checks (%d) >= piso (%d)" % [nombre, checks, piso], checks >= piso)
		else:
			_check("A: %s — suite sin contador: 0 fallo(s)" % nombre, fallos == 0)
		if checks > 0:
			_acumulado += checks

# --- Bloque B: piso TOTAL medido -----------------------------------------

func _bloque_b_total() -> void:
	print("  [INFO] total de checks medidos en las suites: %d (piso total %d)" % [_acumulado, TOTAL_MINIMO])
	_check("B: total de checks (%d) >= piso total (%d)" % [_acumulado, TOTAL_MINIMO], _acumulado >= TOTAL_MINIMO)
	_check("B: se corrieron las 8 suites del catalogo", SUITES.size() == 8)

# --- Bloque C: SONDA ROJA del clasificador -------------------------------

func _bloque_c_sonda_clasificador() -> void:
	# 1) salida valida -> OK
	var c1: Dictionary = _clasificar("=== Resumen X: 42 checks, 0 fallos ===\nTEST OK", 0, 42, true)
	_check("C: clasifica OK una salida valida", bool(c1["ok"]))

	# 2) checks por debajo del piso -> RECHAZA
	var c2: Dictionary = _clasificar("=== Resumen X: 40 checks, 0 fallos ===\nTEST OK", 0, 42, true)
	var m2: Array = c2["motivos"]
	_check("C: RECHAZA si checks < piso", not bool(c2["ok"]) and _contiene(m2, "piso"))

	# 3) un fallo -> RECHAZA
	var c3: Dictionary = _clasificar("=== Resumen X: 42 checks, 1 fallos ===", 0, 42, true)
	var m3: Array = c3["motivos"]
	_check("C: RECHAZA si hay fallos", not bool(c3["ok"]) and _contiene(m3, "fallos"))

	# 4) SCRIPT ERROR -> RECHAZA
	var c4: Dictionary = _clasificar("SCRIPT ERROR: boom\n=== Resumen X: 42 checks, 0 fallos ===", 0, 42, true)
	var m4: Array = c4["motivos"]
	_check("C: RECHAZA si hay SCRIPT ERROR", not bool(c4["ok"]) and _contiene(m4, "SCRIPT ERROR"))

	# 5) sin linea de resumen -> RECHAZA
	var c5: Dictionary = _clasificar("nada util aqui", 0, 42, true)
	_check("C: RECHAZA si falta la linea de resumen", not bool(c5["ok"]))

	# 6) EXIT != 0 -> RECHAZA
	var c6: Dictionary = _clasificar("=== Resumen X: 42 checks, 0 fallos ===", 1, 42, true)
	var m6: Array = c6["motivos"]
	_check("C: RECHAZA si EXIT != 0", not bool(c6["ok"]) and _contiene(m6, "EXIT"))

	# 7) formato viejo (suite sin contador): "0 fallo(s)" -> OK
	var c7: Dictionary = _clasificar("=== TEST PUZZLES M24: 0 fallo(s) ===", 0, 0, false)
	_check("C: acepta el formato viejo '0 fallo(s)'", bool(c7["ok"]))

	# 8) formato viejo con 1 fallo -> RECHAZA
	var c8: Dictionary = _clasificar("=== TEST PUZZLES M24: 1 fallo(s) ===", 0, 0, false)
	_check("C: RECHAZA el formato viejo con 1 fallo(s)", not bool(c8["ok"]))

	# 9) salida vacia (captura fallida = detector ciego) -> RECHAZA
	var c9: Dictionary = _clasificar("", 0, 42, true)
	_check("C: RECHAZA si la salida esta vacia (detector ciego)", not bool(c9["ok"]))

# --- Runner + clasificador -----------------------------------------------

## Corre una suite como subproceso, redirigiendo su salida a un archivo temporal.
## Devuelve {rc: int, salida: String}.
func _correr_suite(ruta: String) -> Dictionary:
	var exe := _exe_console()
	var proj := ProjectSettings.globalize_path("res://")
	var tmp := OS.get_temp_dir().path_join("m24_reg_%d.txt" % Time.get_ticks_usec())
	var cmd := "\"" + exe + "\" --headless --path \"" + proj + "\" --script " + ruta + " > \"" + tmp + "\" 2>&1"
	var rc := -1
	if OS.get_name() == "Windows":
		rc = OS.execute("cmd.exe", ["/C", cmd], [], true)
	else:
		rc = OS.execute("bash", ["-c", cmd], [], true)
	var salida := ""
	if FileAccess.file_exists(tmp):
		salida = FileAccess.get_file_as_string(tmp)
		DirAccess.remove_absolute(tmp)
	return {"rc": rc, "salida": salida}

## Prefiere el binario `_console` (el de `OS.get_executable_path()` no vuelca stdout).
func _exe_console() -> String:
	var exe := OS.get_executable_path()
	if exe.get_file().to_lower().contains("_console"):
		return exe
	var alt := exe.get_basename() + "_console.exe"
	if FileAccess.file_exists(alt):
		return alt
	return exe

## Clasifica la salida de una suite. Devuelve {ok, checks, fallos, script_error, motivos}.
func _clasificar(salida: String, rc: int, piso: int, reporta_checks: bool) -> Dictionary:
	var motivos: Array = []
	if salida.strip_edges().is_empty():
		motivos.append("salida VACIA (no se pudo capturar)")
	var checks := -1
	var fallos := -1
	var re := RegEx.new()
	re.compile("Resumen[^:]*:\\s*(\\d+)\\s+checks,\\s*(\\d+)\\s+fallos")
	var m := re.search(salida)
	if m != null:
		checks = int(m.get_string(1))
		fallos = int(m.get_string(2))
	else:
		var re2 := RegEx.new()
		re2.compile("(\\d+)\\s+fallo\\(s\\)")
		var m2 := re2.search(salida)
		if m2 != null:
			fallos = int(m2.get_string(1))
			checks = 0
	if rc != 0:
		motivos.append("EXIT %d (se exige 0)" % rc)
	if fallos < 0:
		motivos.append("sin linea de resumen")
	elif fallos != 0:
		motivos.append("%d fallos (se exige 0)" % fallos)
	var se := salida.count("SCRIPT ERROR")
	if se != 0:
		motivos.append("%d SCRIPT ERROR" % se)
	if reporta_checks and checks >= 0 and checks < piso:
		motivos.append("%d checks < piso %d" % [checks, piso])
	return {"ok": motivos.is_empty(), "checks": checks, "fallos": fallos, "script_error": se, "motivos": motivos}

func _contiene(errores: Array, sub: String) -> bool:
	for e in errores:
		if str(e).contains(sub):
			return true
	return false
