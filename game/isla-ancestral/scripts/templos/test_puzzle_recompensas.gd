# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-09
#
# M24 iter. 6: test headless de la capa de checkpoints y RECOMPENSAS.
# Cubre los items 157, 162, 163 y 164 del checklist:
#   157 checkpoint atomico (tmp + rename + .bak) · 162 recompensas unicas (M66) ·
#   163 recompensas alineadas al lore · 164 documentacion.
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/templos/test_puzzle_recompensas.gd
#
# Protocolo anti-falso-verde:
#   - BLOQUES nombrados + _fin() al final de cada uno.
#   - Piso CHECKS_MINIMOS MEDIDO en verde (no estimado).
#   - _summary() en call_deferred: si _run() aborta, el resumen igual corre y nombra lo que falto.
#   - Bloque D = SONDA ROJA: los validadores se prueban EN VIVO sobre copias mutadas.
#
# Composicion real: el guardado atomico es `scripts/templos/templo_checkpoint.gd`
# (patron tmp -> .bak -> rename, con las trampas headless ya resueltas) y las
# recompensas unicas usan `scripts/core/recovery/cofre_recuperacion.gd` (M66).

extends SceneTree

const MODULO := "M24-Recompensas"
const CHECKS_MINIMOS := 44   # MEDIDO en verde (ajustar SOLO tras medir, nunca estimar)

const BLOQUES := ["A", "B", "C", "D", "E", "F"]

const RUTA_01 := "res://data/templos/puzzles/recompensas/recompensas_01.json"
const RUTA_02 := "res://data/templos/puzzles/recompensas/recompensas_02.json"

const DIR_TEST := "user://templo/test_m24_recompensas"

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
	print("=== [%s] Test de checkpoints y recompensas ===" % MODULO)
	_bloque_a_carga()
	_fin("A")
	_bloque_b_validacion()
	_fin("B")
	_bloque_c_unicas_m66()
	_fin("C")
	_bloque_d_checkpoint_y_sonda()
	_fin("D")
	_bloque_e_repetible_lore()
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
	var r1: Dictionary = PuzzleRecompensas.cargar(RUTA_01)
	var r2: Dictionary = PuzzleRecompensas.cargar(RUTA_02)
	_check("A: recompensas_01.json existe y parsea", not r1.is_empty())
	_check("A: recompensas_02.json existe y parsea", not r2.is_empty())
	_check("A: recompensas_01 familia == recompensas", str(r1.get("familia", "")) == "recompensas")
	_check("A: recompensas_01 declara 1 emisor", PuzzleDef.ids_emisores(r1).size() == 1)
	_check("A: recompensas_02 declara 2 emisores", PuzzleDef.ids_emisores(r2).size() == 2)
	_check("A: recompensas_01 declara el patron atomico", PuzzleRecompensas.desde_def(r1).patron_atomico())

# --- Bloque B: validacion -------------------------------------------------

func _bloque_b_validacion() -> void:
	var r1: Dictionary = PuzzleRecompensas.cargar(RUTA_01)
	var r2: Dictionary = PuzzleRecompensas.cargar(RUTA_02)
	_check("B: validar_def(recompensas_01) sin errores", PuzzleDef.validar_def(r1).is_empty())
	_check("B: validar_def(recompensas_02) sin errores", PuzzleDef.validar_def(r2).is_empty())
	_check("B: soluciones_minimas(recompensas_01) == 1", PuzzleDef.soluciones_minimas(r1) == 1)
	_check("B: validar(recompensas_01) sin errores", PuzzleRecompensas.desde_def(r1).validar().is_empty())
	_check("B: validar(recompensas_02) sin errores", PuzzleRecompensas.desde_def(r2).validar().is_empty())

# --- Bloque C: recompensas unicas no duplicables (item 162, M66) ---------

func _bloque_c_unicas_m66() -> void:
	var pr: PuzzleRecompensas = PuzzleRecompensas.desde_def(PuzzleRecompensas.cargar(RUTA_01))
	_check("C: recompensas_01 declara 2 recompensas", pr.ids_recompensas().size() == 2)
	_check("C: rec_narrativa es unica", pr.es_unica("rec_narrativa"))
	_check("C: rec_material es unica", pr.es_unica("rec_material"))
	_check("C: el cofre M66 es inmutable", pr.es_inmutable())
	_check("C: la clave es unica por recompensa", pr.clave_de("rec_narrativa") == "recompensa:rec_narrativa")

	var cofre := CofreRecuperacion.new()
	_check("C: la 1ra entrega de rec_narrativa es true", pr.otorgar("rec_narrativa", cofre))
	_check("C: rec_narrativa queda marcada como entregada", pr.ya_otorgada("rec_narrativa", cofre))
	_check("C: la 2da entrega de rec_narrativa es false (no duplica)", not pr.otorgar("rec_narrativa", cofre))
	_check("C: la 1ra entrega de rec_material es true", pr.otorgar("rec_material", cofre))
	_check("C: la 2da entrega de rec_material es false (no duplica)", not pr.otorgar("rec_material", cofre))
	cofre.free()

# --- Bloque D: checkpoint atomico (item 157) + SONDA ROJA ----------------

func _bloque_d_checkpoint_y_sonda() -> void:
	var pr: PuzzleRecompensas = PuzzleRecompensas.desde_def(PuzzleRecompensas.cargar(RUTA_01))
	pr.usar_directorio_checkpoint(DIR_TEST)
	pr.checkpoint.borrar("cp_test")

	# Guardado atomico: el round-trip conserva el estado.
	_check("D: guardar_checkpoint devuelve true", pr.guardar_checkpoint("cp_test", {"s": [true, false], "t": 42}))
	_check("D: el checkpoint existe tras guardar", pr.checkpoint.existe("cp_test"))
	var cargado: Dictionary = pr.cargar_checkpoint("cp_test")
	_check("D: el round-trip conserva el valor t == 42", int(cargado.get("t", -1)) == 42)
	_check("D: NO queda ningun .tmp huerfano (atomo)", not FileAccess.file_exists(pr.checkpoint.ruta_tmp("cp_test")))

	# El 2do guardado respalda el anterior en .bak.
	pr.guardar_checkpoint("cp_test", {"s": [true, true], "t": 43})
	_check("D: tras el 2do guardado existe el .bak", pr.respaldo_existe("cp_test"))
	var recargado: Dictionary = pr.cargar_checkpoint("cp_test")
	_check("D: el checkpoint vigente es el ultimo (t == 43)", int(recargado.get("t", -1)) == 43)
	_check("D: el checkpoint no dejo .tmp", not FileAccess.file_exists(pr.checkpoint.ruta_tmp("cp_test")))
	pr.checkpoint.borrar("cp_test")

	# SONDA ROJA 1: cofre no inmutable -> validar DEBE fallar.
	var m1: Dictionary = PuzzleRecompensas.cargar(RUTA_01).duplicate(true)
	((m1["recompensas"] as Dictionary)["cofre_m66"] as Dictionary)["inmutable"] = false
	_check("D: cofre no inmutable -> validar DEBE fallar",
		_contiene(PuzzleRecompensas.desde_def(m1).validar(), "no esta declarado inmutable"))

	# SONDA ROJA 2: recompensa sin lore -> DEBE fallar.
	var m2: Dictionary = PuzzleRecompensas.cargar(RUTA_01).duplicate(true)
	(((m2["recompensas"] as Dictionary)["lista"] as Array)[0] as Dictionary).erase("lore")
	_check("D: recompensa sin lore -> validar DEBE fallar",
		_contiene(PuzzleRecompensas.desde_def(m2).validar(), "no esta alineada al lore"))

	# SONDA ROJA 3: lore no declarado -> DEBE fallar.
	var m3: Dictionary = PuzzleRecompensas.cargar(RUTA_01).duplicate(true)
	(((m3["recompensas"] as Dictionary)["lista"] as Array)[0] as Dictionary)["lore"] = "LORE_FANTASMA"
	_check("D: lore no declarado -> validar DEBE fallar",
		_contiene(PuzzleRecompensas.desde_def(m3).validar(), "usa un lore no declarado"))

	# SONDA ROJA 4: checkpoint sin patron atomico -> DEBE fallar.
	var m4: Dictionary = PuzzleRecompensas.cargar(RUTA_01).duplicate(true)
	(m4["recompensas"] as Dictionary)["checkpoint"] = {"patron": "simple"}
	_check("D: checkpoint sin patron atomico -> validar DEBE fallar",
		_contiene(PuzzleRecompensas.desde_def(m4).validar(), "no declara el patron atomico"))

	# SONDA ROJA 5: recompensa sin "unica" -> DEBE fallar.
	var m5: Dictionary = PuzzleRecompensas.cargar(RUTA_01).duplicate(true)
	(((m5["recompensas"] as Dictionary)["lista"] as Array)[0] as Dictionary).erase("unica")
	_check("D: recompensa sin 'unica' -> validar DEBE fallar",
		_contiene(PuzzleRecompensas.desde_def(m5).validar(), "no declara si es unica"))

# --- Bloque E: recompensa repetible y lore (items 162, 163) --------------

func _bloque_e_repetible_lore() -> void:
	var pr: PuzzleRecompensas = PuzzleRecompensas.desde_def(PuzzleRecompensas.cargar(RUTA_02))
	_check("E: recompensas_02 declara 2 recompensas", pr.ids_recompensas().size() == 2)
	_check("E: rec_suministro NO es unica (repetible)", not pr.es_unica("rec_suministro"))
	_check("E: rec_lore_brisa SI es unica", pr.es_unica("rec_lore_brisa"))
	_check("E: todas las recompensas estan alineadas al lore", pr.todas_alineadas())
	_check("E: el lore de rec_suministro es LORE_BRISA", pr.lore_de("rec_suministro") == "LORE_BRISA")
	_check("E: el item de rec_suministro es planks", pr.item_de("rec_suministro") == "planks")

	var cofre := CofreRecuperacion.new()
	_check("E: la recompensa repetible se concede siempre (1ra)", pr.otorgar("rec_suministro", cofre))
	_check("E: la recompensa repetible se concede siempre (2da)", pr.otorgar("rec_suministro", cofre))
	_check("E: la recompensa unica de r02 se entrega 1 sola vez",
		pr.otorgar("rec_lore_brisa", cofre) and not pr.otorgar("rec_lore_brisa", cofre))
	cofre.free()

# --- Bloque F: rendimiento MEDIDO ----------------------------------------

func _bloque_f_rendimiento() -> void:
	var r1: Dictionary = PuzzleRecompensas.cargar(RUTA_01)
	var t0 := Time.get_ticks_usec()
	for i in range(500):
		PuzzleRecompensas.desde_def(r1).validar()
	var us := float(Time.get_ticks_usec() - t0) / 500.0
	print("  [INFO] validar() de recompensas_01: %.2f us" % us)
	_check("F: validar() < 10 ms (autoria, no tick)", us < 10000.0)

	var t1 := Time.get_ticks_usec()
	for i in range(500):
		PuzzleRecompensas.desde_def(PuzzleRecompensas.cargar(RUTA_02))
	var us2 := float(Time.get_ticks_usec() - t1) / 500.0
	print("  [INFO] cargar+desde_def: %.2f us" % us2)
	_check("F: cargar+desde_def < 5 ms", us2 < 5000.0)

# --- Helpers -------------------------------------------------------------

func _contiene(errores: Array, sub: String) -> bool:
	for e in errores:
		if str(e).contains(sub):
			return true
	return false
