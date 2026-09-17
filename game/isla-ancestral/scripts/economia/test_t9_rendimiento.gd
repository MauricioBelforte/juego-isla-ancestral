# Modelo: GLM-5.3
# Plataforma: Kilo Code
# Fecha: 2026-09-11
#
# M38 iter 5b: prueba de rendimiento T9 — 5000 transacciones simuladas sin picos
# (06-Plan-Testings §T9). Valida que la ventana de oferta mantiene memoria
# constante (MAX_ENTRADAS_VENTANA 120), el historial es anillo (200), y la
# tabla del día NO recalcula en consultas repetidas (caché L.3).
# Uso: godot --headless --path game/isla-ancestral --script res://scripts/economia/test_t9_rendimiento.gd

extends SceneTree

const N_TX := 5000
const LIMITE_SEGUNDOS := 10.0   # presupuesto holgado para 5000 tx headless

var _fallos := 0
var _checks := 0

func _initialize() -> void:
	print("=== TEST M38 T9: RENDIMIENTO 5000 TX ===")
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	var eco = root.get_node_or_null("EconomyManager")
	if eco == null or not eco.has_method("retirar_monedas"):
		print("[FAIL] EconomyManager no disponible"); quit(1); return
	var pm = eco.precios
	if pm == null:
		print("[FAIL] PriceManager no disponible"); quit(1); return

	# Estado inicial
	var saldo_ini: int = eco.saldo
	var t0: int = Time.get_ticks_msec()

	# 5000 transacciones mixtas: depósitos, retiros y ventas de mercado
	# intercaladas (los retiros fallan a propósito la mitad de las veces para
	# cubrir también el camino de rechazo).
	for i in range(N_TX):
		if i % 3 == 0:
			eco.depositar_monedas(2)
		elif i % 3 == 1:
			eco.retirar_monedas(1000000)  # SIN_FONDOS: rechazo rápido, sin efecto
		else:
			pm.registrar_venta("ITEM-T9", 1, 1 + (i / 500))  # días progresivos → podado de ventana
	var t1: int = Time.get_ticks_msec()
	var segundos := float(t1 - t0) / 1000.0

	# 1) Tiempo dentro de presupuesto
	_check("5000 tx en %.2fs (< %.1fs)" % [segundos, LIMITE_SEGUNDOS], segundos < LIMITE_SEGUNDOS)

	# 2) Ventana de oferta acotada (memoria constante L.7)
	var ventana: int = pm._ventas_ventana.size()
	_check("ventana de oferta acotada (n=%d <= 120)" % ventana, ventana <= 120)

	# 3) Historial en anillo (nunca > 200)
	var hist: int = eco._historial.size()
	_check("historial anillo <= 200 (n=%d)" % hist, hist <= 200)

	# 4) La caché de tabla NO recalcula por consulta (L.3): 1000 consultas
	#    seguidas deben ser mucho más baratas que 1000 cálculos completos.
	t0 = Time.get_ticks_msec()
	var tabla: Dictionary = {}
	for i in range(1000):
		tabla = pm.tabla_del_dia()
	t1 = Time.get_ticks_msec()
	var ms_consultas: int = t1 - t0
	_check("1000 consultas tabla cacheada en %dms (< 2000ms)" % ms_consultas, ms_consultas < 2000)
	_check("tabla cacheada devuelve contenido (n=%d)" % tabla.size(), tabla.size() > 0)

	# 5) Saldo consistente: solo los depósitos entraron (i%3==0 → ceil(5000/3)=1667
	#    depósitos × 2 monedas = +3334 netos). Se verifica el DELTA (no el
	#    absoluto: el saldo del autoload puede diferir del default SALDO_INICIAL
	#    si otra sesión depositó antes en la misma corrida).
	var delta: int = eco.saldo - saldo_ini
	_check("delta de saldo tras 5000 tx == +3334 (n=%d, ini=%d)" % [delta, saldo_ini], delta == 3334)

	print("=== Resumen: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("FALLOS DETECTADOS"); quit(1)
	else:
		print("M38 T9 RENDIMIENTO OK"); quit(0)

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)
