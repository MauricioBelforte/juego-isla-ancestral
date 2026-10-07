# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-07
#
# M24 iter. 1: test headless del interprete datos-driven (PuzzleDef) + familia presion.
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://scripts/templos/test_puzzle_datos.gd
#
# Protocolo anti-falso-verde:
#   - BLOQUES nombrados + _fin() al final de cada uno (un aborto silencioso deja el bloque sin marcar).
#   - Piso CHECKS_MINIMOS MEDIDO en verde (no estimado).
#   - _summary() registrado en call_deferred: si _run() aborta, el resumen igual corre y nombra lo que falto.

extends SceneTree

const MODULO := "M24-PuzzleDatos"
const CHECKS_MINIMOS := 42   # MEDIDO en verde (ajustar SOLO tras medir, nunca estimar)

const BLOQUES := ["A", "B", "C", "D", "E", "F"]

const RUTA_01 := "res://data/templos/puzzles/presion/presion_01.json"
const RUTA_02 := "res://data/templos/puzzles/presion/presion_02.json"

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
	print("=== [%s] Test del interprete datos-driven ===" % MODULO)
	_bloque_a_carga()
	_fin("A")
	_bloque_b_validacion()
	_fin("B")
	_bloque_c_sondas_detector()
	_fin("C")
	_bloque_d_casi_solucion()
	_fin("D")
	_bloque_e_umbral_peso()
	_fin("E")
	_bloque_f_interprete()
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
	var p01: Dictionary = PuzzleDef.cargar(RUTA_01)
	var p02: Dictionary = PuzzleDef.cargar(RUTA_02)
	_check("A: presion_01.json existe y parsea", not p01.is_empty())
	_check("A: presion_02.json existe y parsea", not p02.is_empty())
	_check("A: presion_01 declara 2 emisores", PuzzleDef.ids_emisores(p01).size() == 2)
	_check("A: presion_02 declara 3 emisores", PuzzleDef.ids_emisores(p02).size() == 3)
	_check("A: presion_01 objetivo == [0,1]", _canon(PuzzleDef.ids_objetivo(p01)) == "0,1")
	_check("A: presion_01 familia == presion", str(p01.get("familia", "")) == "presion")

# --- Bloque B: validacion + unicidad (puzzles reales) --------------------

func _bloque_b_validacion() -> void:
	var p01: Dictionary = PuzzleDef.cargar(RUTA_01)
	var p02: Dictionary = PuzzleDef.cargar(RUTA_02)
	_check("B: validar_def(presion_01) sin errores", PuzzleDef.validar_def(p01).is_empty())
	_check("B: validar_def(presion_02) sin errores", PuzzleDef.validar_def(p02).is_empty())
	_check("B: soluciones_minimas(presion_01) == 1", PuzzleDef.soluciones_minimas(p01) == 1)
	_check("B: soluciones_minimas(presion_02) == 1", PuzzleDef.soluciones_minimas(p02) == 1)
	_check("B: solucion_minima(presion_01) == objetivo",
		_canon(PuzzleDef.solucion_minima(p01)) == _canon(PuzzleDef.ids_objetivo(p01)))
	_check("B: solucion_minima(presion_02) == objetivo",
		_canon(PuzzleDef.solucion_minima(p02)) == _canon(PuzzleDef.ids_objetivo(p02)))
	_check("B: completado_por(presion_01, [0,1])", PuzzleDef.completado_por(p01, [0, 1]))
	_check("B: NO completado_por(presion_01, [0])", not PuzzleDef.completado_por(p01, [0]))

# --- Bloque C: sondas sinteticas del detector ----------------------------

func _bloque_c_sondas_detector() -> void:
	# (1) Ambiguedad real: dos formas (OR) de abrir la misma puerta -> 2 minimas.
	var ambigua: Dictionary = {
		"emisores": [{"id": 0}, {"id": 1}, {"id": 2}, {"id": 3}],
		"reglas": [
			{"emisores": [0, 1], "receptor": "puerta"},
			{"emisores": [2, 3], "receptor": "puerta"}
		],
		"objetivo": [0, 1]
	}
	_check("C: puzzle ambiguo -> soluciones_minimas == 2", PuzzleDef.soluciones_minimas(ambigua) == 2)
	_check("C: validar_def detecta la ambiguedad", _contiene(PuzzleDef.validar_def(ambigua), "ambiguo"))

	# (2) Emisor redundante: regla {0,1} y regla {0} -> minima {0} != objetivo {0,1}.
	var redundante: Dictionary = {
		"emisores": [{"id": 0}, {"id": 1}],
		"reglas": [
			{"emisores": [0, 1], "receptor": "puerta"},
			{"emisores": [0], "receptor": "puerta"}
		],
		"objetivo": [0, 1]
	}
	_check("C: redundante -> solucion_minima == [0]", _canon(PuzzleDef.solucion_minima(redundante)) == "0")
	_check("C: validar_def detecta objetivo != solucion minima",
		_contiene(PuzzleDef.validar_def(redundante), "no es la solucion minima"))

	# (3) Emisor inexistente en una regla.
	var inexistente: Dictionary = {
		"emisores": [{"id": 0}],
		"reglas": [{"emisores": [0, 99], "receptor": "puerta"}],
		"objetivo": [0]
	}
	_check("C: emisor inexistente -> error", _contiene(PuzzleDef.validar_def(inexistente), "emisor inexistente 99"))

	# (4) Emisor huerfano (regla desconectada).
	var huerfano: Dictionary = {
		"emisores": [{"id": 0}, {"id": 1}],
		"reglas": [{"emisores": [0], "receptor": "puerta"}],
		"objetivo": [0]
	}
	_check("C: emisor huerfano -> error", _contiene(PuzzleDef.validar_def(huerfano), "huerfano 1"))

	# (5) Mas de MAX_EMISORES -> rechazado (no se silencia la verificacion).
	var grande: Dictionary = {"emisores": [], "reglas": [{"emisores": [0], "receptor": "p"}], "objetivo": [0]}
	for i in range(PuzzleDef.MAX_EMISORES + 1):
		(grande["emisores"] as Array).append({"id": i})
	_check("C: >MAX_EMISORES -> rechazado", _contiene(PuzzleDef.validar_def(grande), "no se puede verificar unicidad"))

	# (6) Receptores multiples.
	var multi: Dictionary = {
		"emisores": [{"id": 0}, {"id": 1}],
		"reglas": [
			{"emisores": [0], "receptor": "p1"},
			{"emisores": [1], "receptor": "p2"}
		],
		"objetivo": [0, 1]
	}
	_check("C: receptores multiples -> error", _contiene(PuzzleDef.validar_def(multi), "receptores multiples"))

	# (7) Regla con conjunto de emisores vacio.
	var vacia: Dictionary = {
		"emisores": [{"id": 0}],
		"reglas": [{"emisores": [], "receptor": "puerta"}],
		"objetivo": [0]
	}
	_check("C: regla vacia -> error", _contiene(PuzzleDef.validar_def(vacia), "conjunto de emisores vacio"))

# --- Bloque D: feedback "casi solucion" (Hamming-1) ----------------------

func _bloque_d_casi_solucion() -> void:
	var sala := PuzzleRoom.new([0, 1, 2])
	sala.objetivo = [0, 1]
	_check("D: estado {} -> distancia 2", sala.distancia_objetivo() == 2)
	_check("D: estado {} NO es casi solucion", not sala.esta_a_casi_solucion())
	sala.set_emisor(0, true)
	_check("D: estado {0} -> distancia 1 (casi solucion)", sala.esta_a_casi_solucion())
	_check("D: estado {0} NO es completado", not sala.estado_igual_objetivo())
	sala.set_emisor(1, true)
	_check("D: estado {0,1} -> completado (distancia 0)", sala.estado_igual_objetivo())
	_check("D: estado {0,1} ya no es 'casi'", not sala.esta_a_casi_solucion())
	sala.set_emisor(2, true)
	_check("D: estado {0,1,2} -> distancia 1 (sobrepaso)", sala.esta_a_casi_solucion())
	_check("D: vector_objetivo() == [0,1]", _canon(sala.vector_objetivo()) == "0,1")

# --- Bloque E: umbral de peso (PuzzleEmisor) ----------------------------

func _bloque_e_umbral_peso() -> void:
	var emisor := PuzzleEmisor.new()
	emisor.id = 7
	emisor.umbral_peso_export = 3
	root.add_child(emisor)   # dispara _ready -> copia id y umbral
	_check("E: _ready copia umbral_peso_export", emisor.umbral_peso == 3)
	_check("E: _ready copia id", emisor.emisor_id == 7)
	var sala := PuzzleRoom.new([7])
	emisor.sala = sala
	emisor.recibir_peso(1)
	_check("E: peso 1 < umbral 3 -> NO activado", not emisor.activado)
	_check("E: sala sigue con emisor 7 OFF", not bool(sala.emisores[7]))
	emisor.recibir_peso(3)
	_check("E: peso 3 >= umbral 3 -> activado", emisor.activado)
	_check("E: sala recibe emisor 7 ON", bool(sala.emisores[7]))
	emisor.recibir_peso(0)
	_check("E: peso 0 -> desactivado", not emisor.activado)
	emisor.free()

# --- Bloque F: el interprete construye una sala jugable ------------------

func _bloque_f_interprete() -> void:
	var p01: Dictionary = PuzzleDef.cargar(RUTA_01)
	var sala: PuzzleRoom = PuzzleDef.a_puzzle_room(p01)
	_check("F: a_puzzle_room declara 2 emisores", sala.emisores.size() == 2)
	_check("F: a_puzzle_room declara 1 regla", sala.reglas.size() == 1)
	_check("F: a_puzzle_room copia el objetivo", _canon(sala.vector_objetivo()) == "0,1")
	sala.set_emisor(0, true)
	sala.set_emisor(1, true)
	_check("F: el interprete completa con objetivo [0,1]", sala.estado_igual_objetivo())

# --- Helpers -------------------------------------------------------------

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
