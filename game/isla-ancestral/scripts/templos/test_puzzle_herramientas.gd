# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-09
#
# M24 iter. 6: test headless de la familia HERRAMIENTAS.
# Cubre los items 121, 122, 123 y 124 del checklist:
#   121 uso de pico (grieta) · 122 uso de gancho (pasarela) · 123 uso de farol (runa) ·
#   124 condicion de inventario presente para la herramienta.
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/templos/test_puzzle_herramientas.gd
#
# Protocolo anti-falso-verde:
#   - BLOQUES nombrados + _fin() al final de cada uno.
#   - Piso CHECKS_MINIMOS MEDIDO en verde (no estimado).
#   - _summary() en call_deferred: si _run() aborta, el resumen igual corre y nombra lo que falto.
#   - Bloque E = SONDA ROJA: los validadores se prueban EN VIVO sobre copias mutadas.
#
# NOTA MEDIDA: el indice de `CatalogosEstaticos` indexa por NOMBRE DE ARCHIVO, asi
# que el id real de "Pico de hierro" es `item_obj_her_002` y el de "Farol" es
# `item_obj_luz_005` (NO los `OBJ-...` que declara el .tres). El bloque D lo verifica.

extends SceneTree

const MODULO := "M24-Herramientas"
const CHECKS_MINIMOS := 45   # MEDIDO en verde (ajustar SOLO tras medir, nunca estimar)

const BLOQUES := ["A", "B", "C", "D", "E", "F"]

const RUTA_01 := "res://data/templos/puzzles/herramientas/herramientas_01.json"
const RUTA_02 := "res://data/templos/puzzles/herramientas/herramientas_02.json"

var _checks := 0
var _fallos := 0
var _vistos: Dictionary = {}

## Inventario FALSO que respeta el contrato real de M15/M160:
## `count_item(item_id, include_house) -> int`.
class InventarioFalso extends RefCounted:
	var items: Dictionary = {}
	func _init(d: Dictionary = {}) -> void:
		items = d
	func count_item(item_id: String, _include_house: bool = false) -> int:
		return int(items.get(item_id, 0))

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
	print("=== [%s] Test de la familia herramientas ===" % MODULO)
	_bloque_a_carga()
	_fin("A")
	_bloque_b_validacion()
	_fin("B")
	_bloque_c_uso_pico()
	_fin("C")
	_bloque_d_condicion_inventario()
	_fin("D")
	_bloque_e_gancho_farol_y_sonda()
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
	var h1: Dictionary = PuzzleHerramientas.cargar(RUTA_01)
	var h2: Dictionary = PuzzleHerramientas.cargar(RUTA_02)
	_check("A: herramientas_01.json existe y parsea", not h1.is_empty())
	_check("A: herramientas_02.json existe y parsea", not h2.is_empty())
	_check("A: herramientas_01 familia == herramientas", str(h1.get("familia", "")) == "herramientas")
	_check("A: herramientas_01 declara 1 emisor", PuzzleDef.ids_emisores(h1).size() == 1)
	_check("A: herramientas_02 declara 2 emisores", PuzzleDef.ids_emisores(h2).size() == 2)
	_check("A: herramientas_01 exige inventario", PuzzleHerramientas.desde_def(h1).inventario_requerido)

# --- Bloque B: validacion -------------------------------------------------

func _bloque_b_validacion() -> void:
	var h1: Dictionary = PuzzleHerramientas.cargar(RUTA_01)
	var h2: Dictionary = PuzzleHerramientas.cargar(RUTA_02)
	_check("B: validar_def(herramientas_01) sin errores", PuzzleDef.validar_def(h1).is_empty())
	_check("B: validar_def(herramientas_02) sin errores", PuzzleDef.validar_def(h2).is_empty())
	_check("B: soluciones_minimas(herramientas_01) == 1", PuzzleDef.soluciones_minimas(h1) == 1)
	_check("B: validar(herramientas_01) sin errores", PuzzleHerramientas.desde_def(h1).validar().is_empty())
	_check("B: validar(herramientas_02) sin errores", PuzzleHerramientas.desde_def(h2).validar().is_empty())

# --- Bloque C: uso de pico (item 121) ------------------------------------

func _bloque_c_uso_pico() -> void:
	var ph: PuzzleHerramientas = PuzzleHerramientas.desde_def(PuzzleHerramientas.cargar(RUTA_01))
	_check("C: herramientas_01 declara 1 uso", ph.usos_declarados().size() == 1)
	_check("C: el uso usa la herramienta pico", ph.herramienta_de("uso_pico") == "pico")
	_check("C: el uso apunta a la grieta", ph.objetivo_de("uso_pico") == "grieta")
	_check("C: el uso activa el emisor 0", ph.emisor_de("uso_pico") == 0)
	_check("C: el pico esta mapeado al item real item_obj_her_002",
		ph.item_de("pico") == "item_obj_her_002")
	_check("C: la herramienta pico tiene item mapeado", ph.tiene_item_mapeado("pico"))

# --- Bloque D: condicion de inventario presente (item 124) ---------------

func _bloque_d_condicion_inventario() -> void:
	# El id real existe en el catalogo (medido por indice de nombre de archivo).
	CatalogosEstaticos.cargar()
	_check("D: item_obj_her_002 existe en el catalogo real", CatalogosEstaticos.tiene_item("item_obj_her_002"))

	var ph: PuzzleHerramientas = PuzzleHerramientas.desde_def(PuzzleHerramientas.cargar(RUTA_01))
	var vacio := InventarioFalso.new()
	var con_pico := InventarioFalso.new({"item_obj_her_002": 1})

	_check("D: inventario_presente(vacio) == false",
		not ph.inventario_presente(vacio, "item_obj_her_002"))
	_check("D: inventario_presente(con_pico) == true",
		ph.inventario_presente(con_pico, "item_obj_her_002"))
	_check("D: inventario null -> false", not ph.inventario_presente(null, "item_obj_her_002"))
	_check("D: sin el pico NO puede usar", not ph.puede_usar("uso_pico", vacio))
	_check("D: con el pico SI puede usar", ph.puede_usar("uso_pico", con_pico))
	_check("D: usos_posibles(vacio) esta vacio", ph.usos_posibles(vacio).is_empty())
	_check("D: usos_posibles(con_pico) == [uso_pico]", _canon(ph.usos_posibles(con_pico)) == "uso_pico")

	# Sin el pico, usar NO activa el emisor.
	var ph_sin: PuzzleHerramientas = PuzzleHerramientas.desde_def(PuzzleHerramientas.cargar(RUTA_01))
	_check("D: usar sin el pico devuelve false", not ph_sin.usar("uso_pico", vacio))
	_check("D: usar sin el pico deja el emisor OFF", not bool(ph_sin.sala.emisores[0]))

	# Con el pico, usar activa el emisor y completa el puzzle.
	var ph_con: PuzzleHerramientas = PuzzleHerramientas.desde_def(PuzzleHerramientas.cargar(RUTA_01))
	_check("D: usar con el pico devuelve true", ph_con.usar("uso_pico", con_pico))
	_check("D: usar con el pico activa el emisor 0", bool(ph_con.sala.emisores[0]))
	_check("D: con el pico el puzzle se completa (S == T)", ph_con.sala.estado_igual_objetivo())

# --- Bloque E: gancho + farol (items 122, 123) + SONDA ROJA --------------

func _bloque_e_gancho_farol_y_sonda() -> void:
	var ph: PuzzleHerramientas = PuzzleHerramientas.desde_def(PuzzleHerramientas.cargar(RUTA_02))
	_check("E: herramientas_02 declara 2 usos", ph.usos_declarados().size() == 2)
	_check("E: el uso 1 es el gancho", ph.herramienta_de("uso_gancho") == "gancho")
	_check("E: el uso 2 es el farol", ph.herramienta_de("uso_farol") == "farol")
	_check("E: el farol esta mapeado al item real item_obj_luz_005",
		ph.item_de("farol") == "item_obj_luz_005")
	_check("E: item_obj_luz_005 existe en el catalogo real", CatalogosEstaticos.tiene_item("item_obj_luz_005"))
	# Residual honesto: el gancho no tiene item en el catalogo.
	_check("E: el gancho figura como residual (sin item)", _canon(ph.residuales()) == "gancho")

	var con_farol := InventarioFalso.new({"item_obj_luz_005": 1})
	var sin_farol := InventarioFalso.new()
	_check("E: usar el farol sin el item -> false", not ph.usar("uso_farol", sin_farol))
	_check("E: usar el farol con el item -> true", ph.usar("uso_farol", con_farol))
	_check("E: el farol activa el emisor 1", bool(ph.sala.emisores[1]))
	# El gancho NO se puede usar: no hay item en el catalogo.
	_check("E: el gancho NO se puede usar (sin item)", not ph.puede_usar("uso_gancho", con_farol))

	# SONDA ROJA 1: uso con emisor inexistente -> validar DEBE fallar.
	var m1: Dictionary = PuzzleHerramientas.cargar(RUTA_01).duplicate(true)
	(((m1["herramientas"] as Dictionary)["usos"] as Array)[0] as Dictionary)["emisor"] = 9
	_check("E: uso con emisor 9 -> validar DEBE fallar",
		_contiene(PuzzleHerramientas.desde_def(m1).validar(), "emisor inexistente 9"))

	# SONDA ROJA 2: uso sin objetivo -> DEBE fallar.
	var m2: Dictionary = PuzzleHerramientas.cargar(RUTA_01).duplicate(true)
	(((m2["herramientas"] as Dictionary)["usos"] as Array)[0] as Dictionary)["objetivo"] = ""
	_check("E: uso sin objetivo -> validar DEBE fallar",
		_contiene(PuzzleHerramientas.desde_def(m2).validar(), "no declara objetivo"))

	# SONDA ROJA 3: herramienta mapeada a item vacio -> DEBE fallar.
	var m3: Dictionary = PuzzleHerramientas.cargar(RUTA_01).duplicate(true)
	((m3["herramientas"] as Dictionary)["inventario"] as Dictionary)["pico"] = ""
	_check("E: herramienta mapeada a item vacio -> validar DEBE fallar",
		_contiene(PuzzleHerramientas.desde_def(m3).validar(), "mapeada a un item vacio"))

# --- Bloque F: rendimiento MEDIDO ----------------------------------------

func _bloque_f_rendimiento() -> void:
	var h2: Dictionary = PuzzleHerramientas.cargar(RUTA_02)
	var t0 := Time.get_ticks_usec()
	for i in range(500):
		PuzzleHerramientas.desde_def(h2).validar()
	var us := float(Time.get_ticks_usec() - t0) / 500.0
	print("  [INFO] validar() de herramientas_02: %.2f us" % us)
	_check("F: validar() < 10 ms (autoria, no tick)", us < 10000.0)

	var t1 := Time.get_ticks_usec()
	for i in range(500):
		PuzzleHerramientas.desde_def(PuzzleHerramientas.cargar(RUTA_01))
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
