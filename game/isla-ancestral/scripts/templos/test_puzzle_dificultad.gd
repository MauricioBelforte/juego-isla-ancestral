# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-09
#
# M24 iter. 6: test headless de la capa de DIFICULTAD y ayuda progresiva.
# Cubre los items 10, 11, 13 y 14 del checklist:
#   10 bandas (Exploracion/Ritual/Antiguo) · 11 progresion por zona ·
#   13 ayuda progresiva por intentos fallidos · 14 documentacion.
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/templos/test_puzzle_dificultad.gd
#
# Protocolo anti-falso-verde:
#   - BLOQUES nombrados + _fin() al final de cada uno.
#   - Piso CHECKS_MINIMOS MEDIDO en verde (no estimado).
#   - _summary() en call_deferred: si _run() aborta, el resumen igual corre y nombra lo que falto.
#   - Bloque D = SONDA ROJA: los validadores se prueban EN VIVO sobre copias mutadas.

extends SceneTree

const MODULO := "M24-Dificultad"
const CHECKS_MINIMOS := 43   # MEDIDO en verde (ajustar SOLO tras medir, nunca estimar)

const BLOQUES := ["A", "B", "C", "D", "E", "F"]

const RUTA := "res://data/templos/dificultad.json"

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
	print("=== [%s] Test de la capa de dificultad y ayuda progresiva ===" % MODULO)
	_bloque_a_carga()
	_fin("A")
	_bloque_b_validacion()
	_fin("B")
	_bloque_c_bandas_zonas()
	_fin("C")
	_bloque_d_ayuda_y_sonda()
	_fin("D")
	_bloque_e_progresion()
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
	var d: Dictionary = PuzzleDificultad.cargar(RUTA)
	_check("A: dificultad.json existe y parsea", not d.is_empty())
	_check("A: schema_version == 1", int(d.get("schema_version", 0)) == 1)
	var pd: PuzzleDificultad = PuzzleDificultad.desde_def(d)
	_check("A: declara 3 bandas", pd.bandas.size() == 3)
	_check("A: declara 5 zonas", pd.zonas.size() == 5)
	_check("A: intentos_para_subir == 3", pd.intentos_para_subir == 3)
	_check("A: max_subidas == 1", pd.max_subidas == 1)

# --- Bloque B: validacion -------------------------------------------------

func _bloque_b_validacion() -> void:
	var pd: PuzzleDificultad = PuzzleDificultad.desde_def(PuzzleDificultad.cargar(RUTA))
	_check("B: validar() sin errores", pd.validar().is_empty())
	_check("B: las 3 bandas obligatorias estan declaradas",
		pd.bandas.has("exploracion") and pd.bandas.has("ritual") and pd.bandas.has("antiguo"))
	_check("B: ids_bandas() == [exploracion, ritual, antiguo]",
		_canon(pd.ids_bandas()) == "antiguo,exploracion,ritual")

# --- Bloque C: bandas y zonas (items 10, 11) -----------------------------

func _bloque_c_bandas_zonas() -> void:
	var pd: PuzzleDificultad = PuzzleDificultad.desde_def(PuzzleDificultad.cargar(RUTA))
	# item 11: progresion por zona
	_check("C: zona exteriores -> exploracion", pd.banda_de_zona("exteriores") == "exploracion")
	_check("C: zona templos_medianos -> ritual", pd.banda_de_zona("templos_medianos") == "ritual")
	_check("C: zona templo_subterraneo -> antiguo", pd.banda_de_zona("templo_subterraneo") == "antiguo")
	_check("C: zona inexistente -> cadena vacia", pd.banda_de_zona("no_existe").is_empty())
	# item 10: bandas
	_check("C: ritual es banda valida", pd.es_banda_valida("ritual"))
	_check("C: 'no_existe' NO es banda valida", not pd.es_banda_valida("no_existe"))
	_check("C: exploracion cubre 2 zonas", pd.zonas_de_banda("exploracion").size() == 2)
	_check("C: antiguo cubre 2 zonas", pd.zonas_de_banda("antiguo").size() == 2)
	# rango de emisores y familias ocultas
	var r: Dictionary = pd.rango_emisores("exteriores")
	_check("C: exteriores exige 1..2 emisores", int(r.get("min", -1)) == 1 and int(r.get("max", -1)) == 2)
	_check("C: templo_subterraneo oculta 2 familias", pd.familias_ocultas("templo_subterraneo") == 2)
	_check("C: familia oculta de zona inexistente == -1", pd.familias_ocultas("no_existe") == -1)

# --- Bloque D: ayuda progresiva + SONDA ROJA -----------------------------

func _bloque_d_ayuda_y_sonda() -> void:
	var pd: PuzzleDificultad = PuzzleDificultad.desde_def(PuzzleDificultad.cargar(RUTA))

	# item 13: demora base por banda
	_check("D: demora_pista(exteriores) == 90", pd.demora_pista("exteriores") == 90)
	_check("D: demora_pista(templos_medianos) == 60", pd.demora_pista("templos_medianos") == 60)
	_check("D: demora_pista(templo_subterraneo) == 45", pd.demora_pista("templo_subterraneo") == 45)

	# item 13: niveles de ayuda
	_check("D: nivel_ayuda(0) == 0", pd.nivel_ayuda(0) == 0)
	_check("D: nivel_ayuda(2) == 0 (aun no sube)", pd.nivel_ayuda(2) == 0)
	_check("D: nivel_ayuda(3) == 1 (sube al 3er intento)", pd.nivel_ayuda(3) == 1)
	_check("D: nivel_ayuda(6) == 1 (tope max_subidas)", pd.nivel_ayuda(6) == 1)

	# item 13: demora efectiva
	_check("D: demora efectiva sin ayuda == base (45)", pd.demora_pista_efectiva("templo_subterraneo", 0) == 45)
	_check("D: demora efectiva con 1 subida == 30 (45-15)", pd.demora_pista_efectiva("templo_subterraneo", 3) == 30)
	_check("D: demora efectiva topeada en 30 (nunca baja mas)", pd.demora_pista_efectiva("templo_subterraneo", 9) == 30)
	_check("D: ayuda_activa(templo_subterraneo, 3)", pd.ayuda_activa("templo_subterraneo", 3))
	_check("D: ayuda NO activa con 0 intentos", not pd.ayuda_activa("templo_subterraneo", 0))

	# La ayuda NUNCA sube la demora (es ayuda, no castigo).
	var nunca_sube := true
	for zona in ["exteriores", "templos_medianos", "templo_subterraneo"]:
		var base: int = pd.demora_pista(zona)
		for n in range(0, 12):
			if pd.demora_pista_efectiva(zona, n) > base:
				nunca_sube = false
	_check("D: la ayuda NUNCA supera la demora base", nunca_sube)

	# SONDA ROJA 1: banda sin pista_segundos -> validar DEBE fallar.
	var m1: Dictionary = PuzzleDificultad.cargar(RUTA).duplicate(true)
	((m1["bandas"] as Array)[0] as Dictionary)["pista_segundos"] = 0
	_check("D: banda con pista_segundos 0 -> validar DEBE fallar",
		_contiene(PuzzleDificultad.desde_def(m1).validar(), "pista_segundos <= 0"))

	# SONDA ROJA 2: zona apuntando a banda inexistente -> DEBE fallar.
	var m2: Dictionary = PuzzleDificultad.cargar(RUTA).duplicate(true)
	((m2["zonas"] as Array)[0] as Dictionary)["banda"] = "fantasma"
	_check("D: zona con banda inexistente -> validar DEBE fallar",
		_contiene(PuzzleDificultad.desde_def(m2).validar(), "banda inexistente"))

	# SONDA ROJA 3: falta una banda obligatoria -> DEBE fallar.
	var m3: Dictionary = PuzzleDificultad.cargar(RUTA).duplicate(true)
	var bl: Array = []
	for b in (m3["bandas"] as Array):
		if str((b as Dictionary).get("id", "")) != "antiguo":
			bl.append(b)
	m3["bandas"] = bl
	_check("D: sin la banda 'antiguo' -> validar DEBE fallar",
		_contiene(PuzzleDificultad.desde_def(m3).validar(), "falta la banda obligatoria 'antiguo'"))

	# SONDA ROJA 4: emisores_max < emisores_min -> DEBE fallar.
	var m4: Dictionary = PuzzleDificultad.cargar(RUTA).duplicate(true)
	((m4["bandas"] as Array)[0] as Dictionary)["emisores_max"] = 0
	_check("D: emisores_max < emisores_min -> validar DEBE fallar",
		_contiene(PuzzleDificultad.desde_def(m4).validar(), "emisores_max < emisores_min"))

# --- Bloque E: progresion (item 11) --------------------------------------

func _bloque_e_progresion() -> void:
	var pd: PuzzleDificultad = PuzzleDificultad.desde_def(PuzzleDificultad.cargar(RUTA))
	_check("E: la banda exploracion tiene zonas", not pd.zonas_de_banda("exploracion").is_empty())
	_check("E: la banda ritual tiene zonas", not pd.zonas_de_banda("ritual").is_empty())
	_check("E: la banda antiguo tiene zonas", not pd.zonas_de_banda("antiguo").is_empty())
	# La dificultad crece: la banda mas dura da MENOS tiempo antes de la pista.
	_check("E: antiguo da menos demora que exploracion (mas dificil)",
		pd.demora_pista("templo_subterraneo") < pd.demora_pista("exteriores"))

# --- Bloque F: rendimiento MEDIDO ----------------------------------------

func _bloque_f_rendimiento() -> void:
	var d: Dictionary = PuzzleDificultad.cargar(RUTA)
	var t0 := Time.get_ticks_usec()
	for i in range(500):
		PuzzleDificultad.desde_def(d).validar()
	var us := float(Time.get_ticks_usec() - t0) / 500.0
	print("  [INFO] validar() de dificultad: %.2f us" % us)
	_check("F: validar() < 10 ms (autoria, no tick)", us < 10000.0)

	var t1 := Time.get_ticks_usec()
	for i in range(500):
		PuzzleDificultad.desde_def(PuzzleDificultad.cargar(RUTA))
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
