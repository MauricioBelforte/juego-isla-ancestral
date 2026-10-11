# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-09
#
# M24 iter. 6: test headless de la capa de TUTORIALIZACION.
# Cubre los items 19, 20, 21, 22 y 23 del checklist:
#   19 guia del templo (mural) por zona · 20 narrador suave (hooks M33/M31) ·
#   21 iconografia de glifos · 22 visual-primero sin texto invasivo · 23 documentacion.
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/templos/test_puzzle_tutorial.gd
#
# Protocolo anti-falso-verde:
#   - BLOQUES nombrados + _fin() al final de cada uno.
#   - Piso CHECKS_MINIMOS MEDIDO en verde (no estimado).
#   - _summary() en call_deferred: si _run() aborta, el resumen igual corre y nombra lo que falto.
#   - Bloque D = SONDA ROJA: los validadores se prueban EN VIVO sobre copias mutadas.

extends SceneTree

const MODULO := "M24-Tutorial"
const CHECKS_MINIMOS := 39   # MEDIDO en verde (ajustar SOLO tras medir, nunca estimar)

const BLOQUES := ["A", "B", "C", "D", "E", "F"]

const RUTA := "res://data/templos/tutorial.json"

var _checks := 0
var _fallos := 0
var _vistos: Dictionary = {}

## Narrador FALSO que respeta el contrato real de M33:
## `start_dialogue(dialogue_id, context) -> bool`.
class NarradorFalso extends RefCounted:
	var llamado: bool = false
	var ultimo_id: String = ""
	func start_dialogue(dialogue_id: String, _context: Dictionary) -> bool:
		llamado = true
		ultimo_id = dialogue_id
		return true

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
	print("=== [%s] Test de la capa de tutorializacion ===" % MODULO)
	_bloque_a_carga()
	_fin("A")
	_bloque_b_validacion()
	_fin("B")
	_bloque_c_murales_iconografia()
	_fin("C")
	_bloque_d_narrador_presentacion_sonda()
	_fin("D")
	_bloque_e_integracion()
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
	var d: Dictionary = PuzzleTutorial.cargar(RUTA)
	_check("A: tutorial.json existe y parsea", not d.is_empty())
	_check("A: schema_version == 1", int(d.get("schema_version", 0)) == 1)
	var pt: PuzzleTutorial = PuzzleTutorial.desde_def(d)
	_check("A: declara 3 murales", pt.murales.size() == 3)
	_check("A: declara 6 glifos iconografiados", pt.glifos_iconografiados().size() == 6)
	_check("A: narrador.primera_solucion == true", pt.narrador_primera_solucion())

# --- Bloque B: validacion -------------------------------------------------

func _bloque_b_validacion() -> void:
	var pt: PuzzleTutorial = PuzzleTutorial.desde_def(PuzzleTutorial.cargar(RUTA))
	_check("B: validar() sin errores", pt.validar().is_empty())
	_check("B: la iconografia cubre todos los glifos de los murales", _iconografia_completa(pt))
	_check("B: las 3 zonas de mural existen",
		pt.tiene_guia("exteriores") and pt.tiene_guia("templos_medianos") and pt.tiene_guia("templo_subterraneo"))

# --- Bloque C: murales e iconografia (items 19, 21) ----------------------

func _bloque_c_murales_iconografia() -> void:
	var pt: PuzzleTutorial = PuzzleTutorial.desde_def(PuzzleTutorial.cargar(RUTA))
	# item 19: guia del templo por zona
	_check("C: tiene_guia(exteriores)", pt.tiene_guia("exteriores"))
	_check("C: NO tiene_guia(no_existe)", not pt.tiene_guia("no_existe"))
	_check("C: icono del mural de exteriores", pt.icono_de_zona("exteriores") == "mural_exteriores")
	_check("C: glifos del mural de exteriores == [glifo_sol, glifo_agua]",
		_canon(pt.glifos_de_zona("exteriores")) == "glifo_agua,glifo_sol")
	_check("C: zona sin mural -> glifos vacios", pt.glifos_de_zona("no_existe").is_empty())
	# item 21: iconografia reconocible
	_check("C: icono_de(glifo_sol) == icon_sol", pt.icono_de("glifo_sol") == "icon_sol")
	_check("C: familia_de(glifo_sol) == luz", pt.familia_de("glifo_sol") == "luz")
	_check("C: glifo_sol es reconocible", pt.es_glifo_reconocible("glifo_sol"))
	_check("C: 'no_existe' NO es reconocible", not pt.es_glifo_reconocible("no_existe"))
	_check("C: todos los glifos iconografiados son reconocibles", _todos_reconocibles(pt))

# --- Bloque D: narrador + presentacion + SONDA ROJA ----------------------

func _bloque_d_narrador_presentacion_sonda() -> void:
	var pt: PuzzleTutorial = PuzzleTutorial.desde_def(PuzzleTutorial.cargar(RUTA))

	# item 22: visual-primero sin texto invasivo
	_check("D: orden_presentacion == [visual, icono, texto]",
		_canon_orden(pt.orden_presentacion()) == "visual,icono,texto")
	_check("D: es_visual_primero()", pt.es_visual_primero())
	_check("D: texto_max_palabras == 0", pt.texto_max_palabras() == 0)
	_check("D: sin_texto_invasivo()", pt.sin_texto_invasivo())

	# item 20: narrador suave en la primera solucion (M33 duck-typed)
	_check("D: narrador declara primera_solucion", pt.narrador_primera_solucion())
	_check("D: el narrador es suave", pt.es_suave())
	_check("D: el hook del narrador es M33", str(pt.narrador_hook().get("hook", "")) == "M33")

	var n1 := NarradorFalso.new()
	_check("D: dispara el narrador en la primera solucion", pt.disparar_narrador(true, n1))
	_check("D: el narrador recibio el dialogue_id", n1.llamado and n1.ultimo_id == "templo_primera_solucion")
	var n2 := NarradorFalso.new()
	_check("D: NO dispara el narrador si no es la primera solucion", not pt.disparar_narrador(false, n2))
	_check("D: NO dispara con narrador null", not pt.disparar_narrador(true, null))
	var mudo := RefCounted.new()
	_check("D: NO dispara con un objeto sin start_dialogue", not pt.disparar_narrador(true, mudo))

	# SONDA ROJA 1: orden con texto primero -> validar DEBE fallar.
	var m1: Dictionary = PuzzleTutorial.cargar(RUTA).duplicate(true)
	(m1["presentacion"] as Dictionary)["orden"] = ["texto", "visual", "icono"]
	_check("D: orden texto-primero -> validar DEBE fallar",
		_contiene(PuzzleTutorial.desde_def(m1).validar(), "no es visual-primero"))

	# SONDA ROJA 2: texto_max_palabras > 0 -> DEBE fallar.
	var m2: Dictionary = PuzzleTutorial.cargar(RUTA).duplicate(true)
	(m2["presentacion"] as Dictionary)["texto_max_palabras"] = 20
	_check("D: texto_max_palabras 20 -> validar DEBE fallar",
		_contiene(PuzzleTutorial.desde_def(m2).validar(), "textual"))

	# SONDA ROJA 3: mural que cita un glifo sin iconografia -> DEBE fallar.
	var m3: Dictionary = PuzzleTutorial.cargar(RUTA).duplicate(true)
	(((m3["murales"] as Array)[0] as Dictionary)["glifos"] as Array).append("glifo_fantasma")
	_check("D: mural cita glifo sin iconografia -> validar DEBE fallar",
		_contiene(PuzzleTutorial.desde_def(m3).validar(), "sin iconografia"))

	# SONDA ROJA 4: narrador desactivado -> DEBE fallar.
	var m4: Dictionary = PuzzleTutorial.cargar(RUTA).duplicate(true)
	(m4["narrador"] as Dictionary)["primera_solucion"] = false
	_check("D: narrador sin primera_solucion -> validar DEBE fallar",
		_contiene(PuzzleTutorial.desde_def(m4).validar(), "primera solucion"))

# --- Bloque E: integracion ------------------------------------------------

func _bloque_e_integracion() -> void:
	var pt: PuzzleTutorial = PuzzleTutorial.desde_def(PuzzleTutorial.cargar(RUTA))
	_check("E: el dialogue_id del narrador es 'templo_primera_solucion'",
		str(pt.narrador_hook().get("dialogue_id", "")) == "templo_primera_solucion")
	var todos_icono := true
	for z in pt.murales:
		if pt.icono_de_zona(str(z)).is_empty():
			todos_icono = false
	_check("E: todos los murales declaran icono", todos_icono)
	var todos_familia := true
	for gl in pt.glifos_iconografiados():
		if pt.familia_de(str(gl)).is_empty():
			todos_familia = false
	_check("E: todos los glifos iconografiados tienen familia", todos_familia)

# --- Bloque F: rendimiento MEDIDO ----------------------------------------

func _bloque_f_rendimiento() -> void:
	var d: Dictionary = PuzzleTutorial.cargar(RUTA)
	var t0 := Time.get_ticks_usec()
	for i in range(500):
		PuzzleTutorial.desde_def(d).validar()
	var us := float(Time.get_ticks_usec() - t0) / 500.0
	print("  [INFO] validar() de tutorial: %.2f us" % us)
	_check("F: validar() < 10 ms (autoria, no tick)", us < 10000.0)

	var t1 := Time.get_ticks_usec()
	for i in range(500):
		PuzzleTutorial.desde_def(PuzzleTutorial.cargar(RUTA))
	var us2 := float(Time.get_ticks_usec() - t1) / 500.0
	print("  [INFO] cargar+desde_def: %.2f us" % us2)
	_check("F: cargar+desde_def < 5 ms", us2 < 5000.0)

# --- Helpers -------------------------------------------------------------

func _iconografia_completa(pt: PuzzleTutorial) -> bool:
	for z in pt.murales:
		for gl in pt.glifos_de_zona(str(z)):
			if not pt.es_glifo_reconocible(str(gl)):
				return false
	return true

func _todos_reconocibles(pt: PuzzleTutorial) -> bool:
	for gl in pt.glifos_iconografiados():
		if not pt.es_glifo_reconocible(str(gl)):
			return false
	return pt.glifos_iconografiados().size() > 0

func _canon(arr: Array) -> String:
	var v: Array = []
	for x in arr:
		v.append(str(x))
	v.sort()
	return ",".join(v)

## Orden SIN reordenar (el orden importa para "visual-primero").
func _canon_orden(arr: Array) -> String:
	var v: Array = []
	for x in arr:
		v.append(str(x))
	return ",".join(v)

func _contiene(errores: Array, sub: String) -> bool:
	for e in errores:
		if str(e).contains(sub):
			return true
	return false
