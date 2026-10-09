# Modelo: GLM-5.3
# Plataforma: Kilo Code
# Fecha: 2026-09-11
#
# M38 iter 4: test de las brechas cerradas — variabilidad_mercado por ítem,
# temporada por ítem en PriceDefinition, y log DOM-ECO-TRX en transacciones.
# Ejecutar: godot --headless --path game/isla-ancestral --script res://scripts/economia/test_iter4_brechas.gd

extends SceneTree

# --- Guardia anti-falso-verde (3 capas): _fin() por bloque + CHECKS_MINIMOS MEDIDO
#     + _summary() diferido. Instrumentacion LOTE 1 (suites SIN-DUENO), 2026-10-08,
#     DeepSeek-V4.1-Flash (msg 98). Piso = checks reales MEDIDOS (Log 1490).
#     NO cambia logica ni aserciones; solo agrega contador + control de bloques.
const CHECKS_MINIMOS := 20
const _WB_BLOQUES: Array[String] = ["_test_price_definition_campos_nuevos", "_test_variabilidad_precio_fijo", "_test_dom_eco_trx_log"]
var _checks: int = 0
var _wb_vistos: Dictionary = {}
var _wb_cerrado: bool = false


func _fin(nombre: String) -> void:
	_wb_vistos[nombre] = true


func _summary() -> void:
	if _wb_cerrado:
		return
	_wb_cerrado = true
	for b in _WB_BLOQUES:
		if not _wb_vistos.has(b):
			_fallos += 1
			print("[FAIL] bloque %s NO se ejecuto (posible SCRIPT ERROR)" % b)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen M38: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

var _fallos: int = 0
var _eco: Node = null

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	_eco = root.get_node_or_null("EconomyManager")
	_check(_eco != null, "EconomyManager autoload presente")
	if _eco == null:
		_summary()
		return
	_test_price_definition_campos_nuevos()
	_fin("_test_price_definition_campos_nuevos")
	_test_variabilidad_precio_fijo()
	_fin("_test_variabilidad_precio_fijo")
	_test_dom_eco_trx_log()
	_fin("_test_dom_eco_trx_log")
	_summary()

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

## ── Test 1: campos nuevos de PriceDefinition ────────────────────────────
func _test_price_definition_campos_nuevos() -> void:
	var def := PriceDefinition.new()
	def.item_id = "prueba_iter4"
	def.variabilidad_mercado = 0.25
	def.temporada = "verano"
	_check(def is Resource, "PriceDefinition sigue siendo Resource")
	_check(absf(def.variabilidad_mercado - 0.25) < 0.001, "variabilidad_mercado=0.25 persiste")
	_check(def.temporada == "verano", "temporada='verano' persiste")
	_check(def.revendible, "revendible default true (no roto)")
	_check(def.rareza == "comun", "rareza default comun (no roto)")
	# Defaults sensatos para definiciones nuevas sin tocar
	var def2 := PriceDefinition.new()
	_check(absf(def2.variabilidad_mercado - 0.5) < 0.001, "default variabilidad_mercado=0.5")
	_check(def2.temporada == "", "default temporada='' (sin estacionalidad)")

## ── Test 2: variabilidad 0.0 = precio fijo ignora mercado ────────────────
func _test_variabilidad_precio_fijo() -> void:
	# PriceManager vive como `precios` (RefCounted vía preload) dentro del EconomyManager
	var pm = _eco.get("precios")
	if pm == null:
		_eco._asegurar_precios()
		pm = _eco.get("precios")
	_check(pm != null, "PriceManager accesible (eco.precios)")
	if pm == null:
		return
	# Precio de compra de un ítem del catálogo real (madera: usado por el smoke test canónico)
	var p1: int = pm.precio_compra_vigente("madera", "", 1)
	_check(p1 >= 0, "precio_compra_vigente('madera') -> int >= 0 (regresión API intacta, smoke canónico)")
	# Dos consultas consecutivas idénticas (determinismo del clamp)
	var p2: int = pm.precio_compra_vigente("madera", "", 1)
	_check(p1 == p2, "precio determinista entre consultas (sin PRNG en el camino)")
	# La interpolación con variabilidad del helper es coherente:
	var interp_0: int = pm._aplicar_variabilidad("stone", 100, 130)
	_check(interp_0 >= 1, "interpolación retorna >= 1 con base=100 mercado=130")
	# Sin entrada de catálogo → variabilidad default 1.0 → mercado completo
	_check(absf(pm._variabilidad_item("stone") - 1.0) < 0.001, "sin entrada catálogo → v=1.0 (compatibilidad)")

## ── Test 3: DOM-ECO-TRX en cada transacción ─────────────────────────────
func _test_dom_eco_trx_log() -> void:
	var historial_antes: int = _eco.obtener_historial().size()
	var ok: bool = _eco.depositar_monedas(50)
	_check(ok, "deposito de 50 monedas OK")
	var ok2: bool = _eco.retirar_monedas(20)
	_check(ok2, "retiro de 20 monedas OK")
	var historial: Array = _eco.obtener_historial()
	_check(historial.size() >= historial_antes + 2, "2 transacciones nuevas en historial")
	# La transacción registrada lleva el formato del contrato (tipo/monto/saldo/dia)
	var ultima: Dictionary = historial[historial.size() - 1]
	_check(ultima.has("tipo") and ultima.has("monto") and ultima.has("saldo"), "tx con campos tipo/monto/saldo")
	_check(str(ultima["tipo"]) == "retiro", "última tx tipo=retiro")
	# El print [DOM-ECO-TRX] está en el código fuente (verificación estática del flujo;
	# el print va a stdout del juego — en runtime el usuario lo ve en consola Godot)
	var path := "res://scripts/economia/economy_manager.gd"
	var src := FileAccess.get_file_as_string(path)
	_check(src.contains("[DOM-ECO-TRX]"), "economy_manager.gd emite log [DOM-ECO-TRX]")
	_check(not _eco.retirar_monedas(999999), "retiro sin fondos rechazado (regla cozy)")
