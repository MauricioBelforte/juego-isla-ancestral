# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-07
#
# M24 iter. 2: test headless de la familia MULTILATERAL migrada al esquema datos-driven.
# Cubre los 2 puzzles legacy multi-fuente del catalogo real:
#   - puz_anillos (columna_7_anillos, 7 anillos de la Columna) -> n=7
#   - puz_final_3fases (espejo_maestro_gongs_timon = luz+sonido+agua) -> n=3
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/templos/test_puzzle_multilateral.gd
#
# Protocolo anti-falso-verde:
#   - BLOQUES nombrados + _fin() al final de cada uno (un aborto silencioso deja el bloque sin marcar).
#   - Piso CHECKS_MINIMOS MEDIDO en verde (no estimado).
#   - _summary() registrado en call_deferred: si _run() aborta, el resumen igual corre y nombra lo que falto.
#   - Bloque D = SONDA ROJA: el detector de ambiguedad se prueba EN VIVO (una copia mutada del puzzle
#     real con 2 caminos OR incomparables -> soluciones_minimas == 2 -> validar_def DEBE fallar).

extends SceneTree

const MODULO := "M24-Multilateral"
const CHECKS_MINIMOS := 38   # MEDIDO en verde (ajustar SOLO tras medir, nunca estimar)

const BLOQUES := ["A", "B", "C", "D", "E"]

const RUTA_ANILLOS := "res://data/templos/puzzles/multilateral/multilateral_anillos.json"
const RUTA_FINAL := "res://data/templos/puzzles/multilateral/multilateral_final_3fases.json"
const RUTA_CATALOGO := "res://data/templos/templo_layout_diseno.json"

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
	print("=== [%s] Test de la familia multilateral (datos-driven) ===" % MODULO)
	_bloque_a_carga()
	_fin("A")
	_bloque_b_validacion()
	_fin("B")
	_bloque_c_cruce_legacy()
	_fin("C")
	_bloque_d_sonda_roja()
	_fin("D")
	_bloque_e_interprete()
	_fin("E")

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
	var anillos: Dictionary = PuzzleDef.cargar(RUTA_ANILLOS)
	var final: Dictionary = PuzzleDef.cargar(RUTA_FINAL)
	_check("A: multilateral_anillos.json existe y parsea", not anillos.is_empty())
	_check("A: multilateral_final_3fases.json existe y parsea", not final.is_empty())
	_check("A: anillos declara 7 emisores", PuzzleDef.ids_emisores(anillos).size() == 7)
	_check("A: final declara 3 emisores", PuzzleDef.ids_emisores(final).size() == 3)
	_check("A: anillos objetivo == [0..6]", _canon(PuzzleDef.ids_objetivo(anillos)) == "0,1,2,3,4,5,6")
	_check("A: anillos familia == multilateral", str(anillos.get("familia", "")) == "multilateral")
	_check("A: final familia == multilateral", str(final.get("familia", "")) == "multilateral")

# --- Bloque B: validacion + unicidad -------------------------------------

func _bloque_b_validacion() -> void:
	var anillos: Dictionary = PuzzleDef.cargar(RUTA_ANILLOS)
	var final: Dictionary = PuzzleDef.cargar(RUTA_FINAL)
	_check("B: validar_def(anillos) sin errores", PuzzleDef.validar_def(anillos).is_empty())
	_check("B: validar_def(final) sin errores", PuzzleDef.validar_def(final).is_empty())
	_check("B: soluciones_minimas(anillos) == 1", PuzzleDef.soluciones_minimas(anillos) == 1)
	_check("B: soluciones_minimas(final) == 1", PuzzleDef.soluciones_minimas(final) == 1)
	_check("B: solucion_minima(anillos) == objetivo",
		_canon(PuzzleDef.solucion_minima(anillos)) == _canon(PuzzleDef.ids_objetivo(anillos)))
	_check("B: solucion_minima(final) == objetivo",
		_canon(PuzzleDef.solucion_minima(final)) == _canon(PuzzleDef.ids_objetivo(final)))
	_check("B: completado_por(anillos, [0..6])", PuzzleDef.completado_por(anillos, [0, 1, 2, 3, 4, 5, 6]))
	_check("B: NO completado_por(anillos, [0..5])", not PuzzleDef.completado_por(anillos, [0, 1, 2, 3, 4, 5]))
	_check("B: n=7 no supera MAX_EMISORES (unicidad verificable)", PuzzleDef.ids_emisores(anillos).size() <= PuzzleDef.MAX_EMISORES)

# --- Bloque C: cruce contra el catalogo legacy REAL ----------------------

func _bloque_c_cruce_legacy() -> void:
	var cat: Dictionary = _cargar_catalogo()
	_check("C: el catalogo legacy existe y parsea", not cat.is_empty())
	var leg_anillos: Dictionary = _puzzle_legacy(cat, "puz_anillos")
	var leg_final: Dictionary = _puzzle_legacy(cat, "puz_final_3fases")
	_check("C: el catalogo tiene puz_anillos", not leg_anillos.is_empty())
	_check("C: el catalogo tiene puz_final_3fases", not leg_final.is_empty())
	var anillos: Dictionary = PuzzleDef.cargar(RUTA_ANILLOS)
	var final: Dictionary = PuzzleDef.cargar(RUTA_FINAL)
	_check("C: receptor migrado == receptor legacy (anillos)",
		_receptor_de(anillos) == str(leg_anillos.get("receptor", "")))
	_check("C: receptor migrado == receptor legacy (final)",
		_receptor_de(final) == str(leg_final.get("receptor", "")))
	_check("C: el legacy puz_anillos es tipo multilateral",
		str(leg_anillos.get("tipo", "")) == "multilateral")
	_check("C: el legacy puz_final_3fases es tipo multilateral",
		str(leg_final.get("tipo", "")) == "multilateral")
	_check("C: el receptor legacy de anillos es 'receptor_columna'",
		str(leg_anillos.get("receptor", "")) == "receptor_columna")
	_check("C: el receptor legacy de final es 'receptor_final'",
		str(leg_final.get("receptor", "")) == "receptor_final")

# --- Bloque D: SONDA ROJA del detector de ambiguedad ---------------------

func _bloque_d_sonda_roja() -> void:
	var anillos: Dictionary = PuzzleDef.cargar(RUTA_ANILLOS)
	# Control positivo: el puzzle real valida sin errores y NO es ambiguo.
	_check("D: control positivo — el anillos real valida sin errores", PuzzleDef.validar_def(anillos).is_empty())
	_check("D: control negativo — el anillos real NO reporta 'ambiguo'",
		not _contiene(PuzzleDef.validar_def(anillos), "ambiguo"))

	# SONDA ROJA: se muta una COPIA del puzzle real reemplazando la unica regla AND
	# por DOS caminos OR incomparables ({0,1,2} o {3,4,5,6}) que activan el mismo receptor.
	# Ambos son minimos y ninguno contiene al otro -> 2 soluciones minimas -> ambiguo.
	var mutado: Dictionary = anillos.duplicate(true)
	(mutado["reglas"] as Array).clear()
	(mutado["reglas"] as Array).append({"emisores": [0, 1, 2], "receptor": "receptor_columna"})
	(mutado["reglas"] as Array).append({"emisores": [3, 4, 5, 6], "receptor": "receptor_columna"})

	_check("D: la copia mutada (2 caminos OR) tiene soluciones_minimas == 2",
		PuzzleDef.soluciones_minimas(mutado) == 2)
	_check("D: validar_def DEBE detectar la ambiguedad inyectada",
		_contiene(PuzzleDef.validar_def(mutado), "ambiguo"))
	_check("D: el error de la mutacion nombra 'soluciones minimas = 2'",
		_contiene(PuzzleDef.validar_def(mutado), "soluciones minimas = 2"))

# --- Bloque E: el interprete construye salas jugables --------------------

func _bloque_e_interprete() -> void:
	var anillos: Dictionary = PuzzleDef.cargar(RUTA_ANILLOS)
	var sala: PuzzleRoom = PuzzleDef.a_puzzle_room(anillos)
	_check("E: a_puzzle_room(anillos) declara 7 emisores", sala.emisores.size() == 7)
	_check("E: a_puzzle_room(anillos) declara 1 regla", sala.reglas.size() == 1)
	_check("E: a_puzzle_room(anillos) copia el objetivo [0..6]",
		_canon(sala.vector_objetivo()) == "0,1,2,3,4,5,6")
	for i in range(6):
		sala.set_emisor(i, true)
	_check("E: 6 de 7 anillos -> NO completado (distancia 1)", not sala.estado_igual_objetivo())
	_check("E: 6 de 7 anillos -> 'casi solucion'", sala.esta_a_casi_solucion())
	sala.set_emisor(6, true)
	_check("E: los 7 anillos -> completado (estado == objetivo)", sala.estado_igual_objetivo())

	var final: Dictionary = PuzzleDef.cargar(RUTA_FINAL)
	var sala2: PuzzleRoom = PuzzleDef.a_puzzle_room(final)
	_check("E: a_puzzle_room(final) declara 3 emisores", sala2.emisores.size() == 3)
	for i in range(3):
		sala2.set_emisor(i, true)
	_check("E: las 3 fases (luz+sonido+agua) -> completado", sala2.estado_igual_objetivo())

# --- Helpers -------------------------------------------------------------

func _cargar_catalogo() -> Dictionary:
	if not FileAccess.file_exists(RUTA_CATALOGO):
		return {}
	var crudo: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_CATALOGO))
	if typeof(crudo) != TYPE_DICTIONARY:
		return {}
	return crudo as Dictionary

## Busca un puzzle legacy por id dentro del catalogo (array "puzzles").
func _puzzle_legacy(cat: Dictionary, id: String) -> Dictionary:
	var lista: Variant = cat.get("puzzles", [])
	if typeof(lista) != TYPE_ARRAY:
		return {}
	for p in (lista as Array):
		if typeof(p) == TYPE_DICTIONARY and str((p as Dictionary).get("id", "")) == id:
			return p as Dictionary
	return {}

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
