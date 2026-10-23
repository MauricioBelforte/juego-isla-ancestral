# Modelo: Step-5-WorkBuddy
# Fecha: 2026-10-23
#
# M59 tanda "save slots + autoguardado" (item 35 de la cola activa) — SUITE B:
# carga idempotente (sin duplicar objetos), limites de cantidad, casas
# parcialmente construidas y fallbacks ante muebles/items inexistentes.
#
# Items del 05-Checklist que cierra con evidencia:
#   L95  "Testear carga del mundo sin duplicar objetos" [C]
#   L105 "Testear carga sin duplicados y limites de cantidad (M60)" [C]
#   L115 "Testear carga con casas parcialmente construidas" [C]
#   L116 "Testear carga con muebles inexistentes (fallback)" [M]
#
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/saving/test_carga_idempotente_m59.gd
#
# Guardia anti-falso-verde de 3 capas (misma doctrina que test_slots_m59.gd):
#   1) _fin(clave) cierra cada bloque: un bloque que no cierra NO corrio.
#   2) CHECKS_MINIMOS: piso MEDIDO en la primera corrida VERDE (no estimado).
#   3) _summary() en call_deferred separado: sobrevive a un SCRIPT ERROR que
#      aborte _run() y decide el exit code.
#
# Contratos ejercitados (todos REALES, leidos en disco):
#   Inventario.restore_save_data  -> inventario_contenedor.deserializar (vacia
#     los slots antes de llenar = idempotente; ignora items desconocidos y
#     acota la cantidad al stack_max del catalogo).
#   Construccion.restaurar_estructuras (BuildManager) -> limpiar_estructuras()
#     primero = idempotente; tipo desconocido se conserva como fallback.
#   HouseManager.restaurar_estructuras -> limpia _casas primero; conserva la
#     etapa (planta) de cada casa.

extends SceneTree

## Piso de checks. MEDIDO en la primera corrida VERDE (28, 2026-10-23).
const CHECKS_MINIMOS: int = 28

const SLOT_A: int = 1
const BOLSILLO: int = 0

## Items reales del catalogo (verificados en data/items/):
##   baya_roja.stack_max = 99 · iron_ore.stack_max = 99 · herramienta_basica.stack_max = 1
const ITEM_A: String = "baya_roja"
const ITEM_B: String = "iron_ore"
const ITEM_C: String = "herramienta_basica"

var _checks: int = 0
var _fallos: int = 0
var _cerrados: Array[String] = []
var _abiertos: Dictionary = {}

var _ok_guardados := [0]
var _fail_guardados := [0]

var _inv_previo: Array = []
var _estructuras_previas: Array = []
var _casas_previas: Array = []
## Bandera de fin de _run(): _summary() la espera antes de reportar (run usa
## awaits; sin esto el resumen corria en el primer frame y su quit() mataba el
## proceso a mitad de la suite — medido 2026-10-23).
var _run_terminado := false

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

# ── utilidades de reporte ────────────────────────────────────────────────

func _ok(cond: bool, msg: String) -> void:
	_checks += 1
	if cond:
		print("  [ok] %s" % msg)
	else:
		_fallos += 1
		print("  FALLO: %s" % msg)

func _abrir(clave: String, desc: String) -> void:
	_abiertos[clave] = desc
	print("-- bloque %s: %s" % [clave, desc])

func _fin(clave: String) -> void:
	_abiertos.erase(clave)
	_cerrados.append(clave)
	print("-- fin bloque %s" % clave)

func _esperar_guardado() -> bool:
	for i in 120:
		await process_frame
		if _ok_guardados[0] + _fail_guardados[0] > 0:
			return true
	return false

func _backup() -> void:
	var inv := root.get_node_or_null("/root/Inventario")
	if inv != null and inv.contenedores.has(BOLSILLO):
		_inv_previo = inv.contenedores[BOLSILLO].serializar()
	var construccion := root.get_node_or_null("/root/Construccion")
	if construccion != null and construccion.has_method("obtener_estructuras"):
		_estructuras_previas = construccion.obtener_estructuras()
	var house := root.get_node_or_null("/root/HouseManager")
	if house != null and house.has_method("obtener_estructuras"):
		_casas_previas = house.obtener_estructuras()

func _restore() -> void:
	var inv := root.get_node_or_null("/root/Inventario")
	if inv != null:
		inv.restore_save_data({str(BOLSILLO): _inv_previo})
	var construccion := root.get_node_or_null("/root/Construccion")
	if construccion != null and construccion.has_method("restaurar_estructuras"):
		construccion.restaurar_estructuras(_estructuras_previas)
	var house := root.get_node_or_null("/root/HouseManager")
	if house != null and house.has_method("restaurar_estructuras"):
		house.restaurar_estructuras(_casas_previas)

# ── bloques ──────────────────────────────────────────────────────────────

## L95 + L105 (parte 1): round-trip end-to-end por el camino REAL de carga
## (SaveManager.load_slot -> SaveLoader -> snapshot.restore -> providers).
## Cargar dos veces NO debe duplicar los objetos.
func _b1_e2e_sin_duplicar(sm) -> void:
	_abrir("1", "e2e: guardar -> cargar -> cargar otra vez, sin duplicar")
	var inv := root.get_node_or_null("/root/Inventario")
	inv.restore_save_data({str(BOLSILLO): []})
	inv.add_item(ITEM_A, 5)
	inv.add_item(ITEM_B, 7)
	_ok_guardados[0] = 0
	_fail_guardados[0] = 0
	sm.request_save(SLOT_A, "tanda_carga_base")
	var listo := await _esperar_guardado()
	_ok(listo and _ok_guardados[0] >= 1 and _fail_guardados[0] == 0,
		"slot 1 guardado con 5 %s + 7 %s" % [ITEM_A, ITEM_B])
	var code1: int = sm.load_slot(SLOT_A)
	_ok(code1 == SaveLoader.LoadResult.OK or code1 == SaveLoader.LoadResult.RECOVERED,
		"primera carga OK/RECOVERED (dio %d)" % code1)
	_ok(inv.count_item(ITEM_A) == 5, "tras cargar 1: 5 %s (dio %d)" % [ITEM_A, inv.count_item(ITEM_A)])
	_ok(inv.count_item(ITEM_B) == 7, "tras cargar 1: 7 %s (dio %d)" % [ITEM_B, inv.count_item(ITEM_B)])
	var code2: int = sm.load_slot(SLOT_A)
	_ok(code2 == SaveLoader.LoadResult.OK or code2 == SaveLoader.LoadResult.RECOVERED,
		"segunda carga del MISMO slot OK/RECOVERED (dio %d)" % code2)
	_ok(inv.count_item(ITEM_A) == 5, "tras cargar 2: SIGUEN 5 %s — sin duplicar (dio %d)" % [ITEM_A, inv.count_item(ITEM_A)])
	_ok(inv.count_item(ITEM_B) == 7, "tras cargar 2: SIGUEN 7 %s — sin duplicar (dio %d)" % [ITEM_B, inv.count_item(ITEM_B)])
	# re-guardar lo cargado y volver a cargar: el ciclo no infla
	_ok_guardados[0] = 0
	_fail_guardados[0] = 0
	sm.request_save(SLOT_A, "tanda_carga_resave")
	var listo2 := await _esperar_guardado()
	_ok(listo2 and _ok_guardados[0] >= 1, "re-guardado del slot tras cargar OK")
	var code3: int = sm.load_slot(SLOT_A)
	_ok(code3 == SaveLoader.LoadResult.OK or code3 == SaveLoader.LoadResult.RECOVERED,
		"tercera carga OK/RECOVERED (dio %d)" % code3)
	_ok(inv.count_item(ITEM_A) == 5 and inv.count_item(ITEM_B) == 7,
		"ciclo guardar/cargar repetido NO infla cantidades (%d/%d)" % [inv.count_item(ITEM_A), inv.count_item(ITEM_B)])
	_fin("1")

## L105 (parte 2): limites de cantidad al cargar (stack_max del catalogo) y
## L116 (parte inventario): items inexistentes se ignoran con aviso.
## Se ejercita el contrato del provider con datos de save manipulados.
func _b2_limites_y_fallback(sm) -> void:
	_abrir("2", "limites de cantidad (stack_max) y items desconocidos al cargar")
	var inv := root.get_node_or_null("/root/Inventario")
	var db := root.get_node_or_null("/root/ItemDatabase")
	_ok(db != null and db.get_item(ITEM_C) != null, "ItemDatabase con %s (stack_max=1)" % ITEM_C)
	var manipulados: Array = [
		{"slot": 0, "id": ITEM_C, "n": 5},          # herramienta: stack_max 1 -> acotar a 1
		{"slot": 1, "id": ITEM_A, "n": 200},        # baya_roja: stack_max 99 -> acotar a 99
		{"slot": 2, "id": "item_fantasma_s5", "n": 3},  # inexistente -> ignorar
		{"slot": 3, "id": ITEM_A, "n": 0},          # cantidad 0 -> ignorar
		{"slot": 4, "id": ITEM_A, "n": -3},         # cantidad negativa -> ignorar
	]
	inv.restore_save_data({str(BOLSILLO): manipulados})
	_ok(inv.count_item(ITEM_C) == 1,
		"cantidad acotada al stack_max: %s 5 -> 1 (dio %d)" % [ITEM_C, inv.count_item(ITEM_C)])
	_ok(inv.count_item(ITEM_A) == 99,
		"cantidad acotada al stack_max: %s 200 -> 99 (dio %d)" % [ITEM_A, inv.count_item(ITEM_A)])
	_ok(inv.count_item("item_fantasma_s5") == 0,
		"item inexistente ignorado con aviso (dio %d)" % inv.count_item("item_fantasma_s5"))
	var slots_usados: int = inv.contenedores[BOLSILLO].slots_usados()
	_ok(slots_usados == 2,
		"los slots con n=0 y n<3 negativa quedaron vacios (usados=%d, esperado 2)" % slots_usados)
	_fin("2")

## L95 (parte mundo): construcciones idempotentes — cargar dos veces la misma
## lista NO duplica las estructuras (restaurar_estructuras limpia primero).
func _b3_construcciones(sm) -> void:
	_abrir("3", "construcciones: doble carga sin duplicar")
	var construccion := root.get_node_or_null("/root/Construccion")
	_ok(construccion != null and construccion.has_method("restaurar_estructuras"),
		"autoload Construccion con el contrato obtener/restaurar estructuras")
	var lista: Array = [
		{"id": "E_s5_cama", "tipo": "cama", "pos": [10, 0, 10], "rot_y": 0, "planta": 0, "variante": ""},
		{"id": "E_s5_antorcha", "tipo": "antorcha_ancestral", "pos": [12, 0, 10], "rot_y": 90, "planta": 0, "variante": ""},
	]
	construccion.restaurar_estructuras(lista)
	_ok(construccion.cantidad_estructuras() == 2,
		"primera restauracion: 2 estructuras (dio %d)" % construccion.cantidad_estructuras())
	var obtenidas: Array = construccion.obtener_estructuras()
	_ok(obtenidas.size() == 2, "obtener_estructuras devuelve 2 (dio %d)" % obtenidas.size())
	var tipos_ok: bool = false
	for e in obtenidas:
		var t: String = String((e as Dictionary).get("tipo", ""))
		if t == "cama" or t == "antorcha_ancestral":
			tipos_ok = true
	_ok(tipos_ok, "los tipos reales del catalogo se conservan en el round-trip")
	construccion.restaurar_estructuras(lista)
	_ok(construccion.cantidad_estructuras() == 2,
		"segunda restauracion de la MISMA lista: siguen 2 — sin duplicar (dio %d)" % construccion.cantidad_estructuras())
	_fin("3")

## L115: casas parcialmente construidas — la etapa (planta) se conserva al
## cargar y una casa a medias no se "completa" ni se duplica.
func _b4_casas_parciales(sm) -> void:
	_abrir("4", "casas parcialmente construidas: etapa preservada, sin duplicar")
	var house := root.get_node_or_null("/root/HouseManager")
	_ok(house != null and house.has_method("restaurar_estructuras"),
		"autoload HouseManager con el contrato obtener/restaurar estructuras")
	var lista: Array = [
		{"id": "casa_s5_cimientos", "tipo": "casa", "pos": [20, 0, 20], "rot_y": 0.0, "planta": 1, "variante": ""},
		{"id": "casa_s5_completa", "tipo": "casa", "pos": [30, 0, 30], "rot_y": 0.0, "planta": 3, "variante": ""},
	]
	house.restaurar_estructuras(lista)
	var obtenidas: Array = house.obtener_estructuras()
	_ok(obtenidas.size() == 2, "2 casas restauradas (dio %d)" % obtenidas.size())
	var plantas := {}
	for e in obtenidas:
		plantas[String((e as Dictionary).get("id", ""))] = int((e as Dictionary).get("planta", -1))
	_ok(int(plantas.get("casa_s5_cimientos", -1)) == 1,
		"la casa en cimientos conserva planta=1 (dio %d)" % int(plantas.get("casa_s5_cimientos", -1)))
	_ok(int(plantas.get("casa_s5_completa", -1)) == 3,
		"la casa completa conserva planta=3 (dio %d)" % int(plantas.get("casa_s5_completa", -1)))
	house.restaurar_estructuras(lista)
	_ok(house.obtener_estructuras().size() == 2,
		"segunda carga de las mismas casas: siguen 2 — sin duplicar (dio %d)" % house.obtener_estructuras().size())
	_fin("4")

## L116 (parte mundo): muebles inexistentes — el restore no crashea y aplica
## un fallback definido (se conserva la estructura con el tipo crudo).
func _b5_muebles_inexistentes(sm) -> void:
	_abrir("5", "muebles inexistentes: fallback sin crash")
	var construccion := root.get_node_or_null("/root/Construccion")
	construccion.limpiar_estructuras()
	var fantasma: Array = [
		{"id": "E_s5_fantasma", "tipo": "mueble_fantasma_s5", "pos": [40, 0, 40], "rot_y": 0, "planta": 0, "variante": ""},
	]
	construccion.restaurar_estructuras(fantasma)
	_ok(construccion.cantidad_estructuras() == 1,
		"el mueble inexistente NO crashea: fallback = estructura conservada con el tipo crudo (dio %d)" % construccion.cantidad_estructuras())
	var obtenidas: Array = construccion.obtener_estructuras()
	var tipo_ok: bool = false
	for e in obtenidas:
		if String((e as Dictionary).get("tipo", "")) == "mueble_fantasma_s5":
			tipo_ok = true
	_ok(tipo_ok, "el tipo desconocido sobrevive el round-trip para depuracion (no se inventa uno valido)")
	_fin("5")

# ── orquestacion ─────────────────────────────────────────────────────────

func _run() -> void:
	var sm = root.get_node_or_null("/root/SaveManager")
	_ok(sm != null, "SaveManager autoload presente")
	if sm == null:
		return
	sm.save_completed.connect(func(_s, _r): _ok_guardados[0] += 1)
	sm.save_failed.connect(func(_s, _r): _fail_guardados[0] += 1)
	_backup()
	await _b1_e2e_sin_duplicar(sm)
	await _b2_limites_y_fallback(sm)
	await _b3_construcciones(sm)
	await _b4_casas_parciales(sm)
	await _b5_muebles_inexistentes(sm)
	_restore()
	_run_terminado = true

## Corre en un call_deferred separado: si _run() aborta por un error de
## runtime, este resumen igual se ejecuta y delata los bloques sin cerrar.
## ESPERA a que _run() termine (run tiene awaits): si _run aborta, la bandera
## no se prende y el resumen sale tras el limite de frames con los bloques
## sin cerrar nombrados.
func _summary() -> void:
	for i in 3000:
		if _run_terminado:
			break
		await process_frame
	print("=== RESUMEN M59 CARGA IDEMPOTENTE: %d checks, %d fallos, %d bloques cerrados ===" % [
		_checks, _fallos, _cerrados.size()])
	var abortado := false
	if not _abiertos.is_empty():
		abortado = true
		print("  BLOQUES QUE NO CERRARON (abortados por un error de runtime):")
		for clave in _abiertos.keys():
			print("    - [%s] %s" % [clave, _abiertos[clave]])
	if _checks < CHECKS_MINIMOS:
		abortado = true
		print("  PISO NO CUMPLIDO: %d checks < CHECKS_MINIMOS=%d (suite muerta o recortada)" % [
			_checks, CHECKS_MINIMOS])
	if abortado:
		print("RESULTADO: FALLO (suite incompleta)")
		quit(1)
		return
	if _fallos > 0:
		print("RESULTADO: FALLO (%d)" % _fallos)
		quit(1)
	else:
		print("RESULTADO: OK")
		quit(0)
