# Modelo: Hy3 / WorkBuddy
# Fecha: 2026-09-05
# M38 (T-ECO-002, RF13 economía precios/stock): smoke test headless de los
# primitivos de economía. Verifica que EconomyManager (M38) está funcional y que
# los métodos de precios/stock que M39 ShopManager consume existen y responden.
# No modifica M38 (propiedad de glm-5.3-flash): solo verifica comportamiento.
# Esto confirma que el bloqueo original "Bloqueada por M39 ShopManager" ya no aplica.

extends SceneTree

# --- Guardia anti-falso-verde (3 capas): _fin() por bloque + CHECKS_MINIMOS MEDIDO
#     + _summary() diferido. Instrumentacion LOTE 1 (suites SIN-DUENO), 2026-10-08,
#     DeepSeek-V4.1-Flash (msg 98). Piso = checks reales MEDIDOS (Log 1490).
#     NO cambia logica ni aserciones; solo agrega contador + control de bloques.
const CHECKS_MINIMOS := 7
const _WB_BLOQUES: Array[String] = ["run"]
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

const ECONOMY_SCRIPT = preload("res://scripts/economia/economy_manager.gd")

var _fallos := 0

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if cond:
		print("[OK]   " + msg)
	else:
		_fallos += 1
		printerr("[FAIL] " + msg)

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	var eco = ECONOMY_SCRIPT.new()
	eco._asegurar_precios()

	_check(eco.saldo > 0, "[M38] saldo inicial positivo (%d)" % eco.saldo)
	_check(eco.puede_pagar(eco.saldo), "[M38] puede_pagar(saldo) == true")
	_check(not eco.puede_pagar(eco.saldo + 1), "[M38] puede_pagar(saldo+1) == false")

	var antes: int = eco.saldo
	eco.retirar_monedas(10)
	_check(eco.saldo == antes - 10, "[M38] retirar_monedas(10) descuenta saldo (%d -> %d)" % [antes, eco.saldo])
	eco.depositar_monedas(5)
	_check(eco.saldo == antes - 5, "[M38] depositar_monedas(5) acredita saldo (%d)" % eco.saldo)

	# Primitivos de PRECIOS (RF13) que M39 ShopManager consume.
	if eco.has_method("precio_compra_vigente"):
		var pc: int = eco.precio_compra_vigente("madera", "", 1)
		_check(typeof(pc) == TYPE_INT and pc >= 0, "[M38] precio_compra_vigente('madera') -> int >= 0 (%d)" % pc)
	else:
		_check(false, "[M38] precio_compra_vigente ausente (rompe contrato M39)")
	if eco.has_method("precio_venta_vigente"):
		var pv: int = eco.precio_venta_vigente("madera")
		_check(typeof(pv) == TYPE_INT and pv >= 0, "[M38] precio_venta_vigente('madera') -> int >= 0 (%d)" % pv)
	else:
		_check(false, "[M38] precio_venta_vigente ausente (rompe contrato M39)")

	eco.free()
	_fin("run")
	_summary()
