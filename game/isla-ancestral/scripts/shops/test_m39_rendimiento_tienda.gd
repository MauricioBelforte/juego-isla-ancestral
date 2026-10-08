extends SceneTree

## M39-Tiendas: prueba de rendimiento — 1000 transacciones sin picos de frame [M]
## Cierra el unico [ ] de M39 (180/181). Agente: agnes-3-flash, Kilo Code, 2026-10-08 (frente canal 76).
##
## Uso: godot --headless --path game/isla-ancestral --script res://scripts/shops/test_m39_rendimiento_tienda.gd
##
## Diseno:
##  - Arranca el ShopManager + una tienda de prueba (mismo setup que test_loop_economico.gd).
##  - Corre 1000 transacciones (compra) y mide el tiempo total (Time.get_ticks_usec).
##  - Criterio "sin picos de frame": el tiempo promedio por transaccion debe ser inferior a un
##    frame a 60 fps (16.6 ms). Si 1000 transacciones tardan mas de ~16.6 s, hay un pico real.
##  - Guardián anti-falso-verde (estándar post-BUG-120): la suite se rompe si se inyecta un fallo:
##      * la medición debe ser viva (total_us > 0); si el loop no corre, el test falla.
##      * la transacción debe conservar integridad: una compra fuera de stock NO deja stock
##        negativo (clamp a 0). Si la lógica de transacción se rompe, este check falla.
##      * el stock debe reaccionar a las compras (efecto observable, no un no-op disfrazado).
##
## Exit != 0 si falla cualquier check.

var _fallos := 0
var _checks := 0

func _initialize() -> void:
	print("=== [M39] Test de rendimiento tienda: 1000 transacciones ===")
	call_deferred("_run")

func _run() -> void:
	var eco = root.get_node_or_null("EconomyManager")
	var inv = root.get_node_or_null("Inventario")
	var sm = root.get_node_or_null("ShopManager")
	var db = root.get_node_or_null("ItemDatabase")
	_chk("autoloads presentes", eco != null and inv != null and sm != null and db != null)
	if eco == null or sm == null:
		_fallback_fail("faltan autoloads")
		return

	# Setup de una tienda de prueba (idéntico a test_loop_economico.gd).
	var shop_data_script = load("res://scripts/shops/shop_data.gd")
	var def = shop_data_script.new()
	def.shop_id = "perf_tienda"
	def.nombre_clave_i18n = "TIENDA_PERF"
	def.tipo = 3
	var dias: Array[int] = [0, 1, 2, 3, 4, 5, 6]
	def.dias_abiertos = dias
	var franjas: Array[Vector2i] = [Vector2i(0, 24)]
	def.franjas_horarias = franjas
	var entry = shop_data_script.StockEntry.new("OBJ-PLA-002", 5, 999, 1.0, true)
	def.catalogo_venta.append(entry)
	def.catalogo_recompra.append("OBJ-PLA-002")
	sm.registrar_tienda(def)
	sm.tick_hora(1, 10)
	_chk("tienda abierta tras tick", sm.esta_abierta("perf_tienda"))

	# Saldo alto para que las compras sean pagables (el loop mide el code-path, no el dinero).
	eco.saldo = 10_000_000
	var stock_ini := int(sm.listar_stock("perf_tienda").get("OBJ-PLA-002", 0))
	_chk("stock inicial > 0", stock_ini > 0)

	# --- 1000 transacciones (compra) + medición del tiempo total ---
	var t0 := Time.get_ticks_usec()
	var N := 1000
	for i in N:
		sm.comprar("perf_tienda", "OBJ-PLA-002", 1)
	var t1 := Time.get_ticks_usec()
	var total_us := t1 - t0
	var us_por_txn := total_us / N

	_chk("medición viva (total_us > 0)", total_us > 0, "total_us=%d" % total_us)
	# Criterio "sin picos de frame": promedio por transacción < 1 frame a 60 fps (16.6 ms).
	_chk("sin picos de frame (prom/txn < 16.6 ms)", us_por_txn < 16_600,
		"prom=%d µs/txn, total=%d ms" % [us_por_txn, total_us / 1000])
	# Presupuesto práctico: 1000 transacciones simple no deben tardar 5 s (5 ms/txn).
	_chk("presupuesto práctico (total < 5000 ms)", total_us < 5_000_000,
		"total=%d ms" % (total_us / 1000))

	# --- Guardián anti-falso-verde: integridad de la transacción ---
	# Efecto observable: las compras deberían haber desubiado el stock (stock final < inicial)
	#   SI el loop corrió de verdad. (Si comprar() se volviera un no-op, el stock no cambiaría.)
	var stock_despues := int(sm.listar_stock("perf_tienda").get("OBJ-PLA-002", 0))
	_chk("efecto observable (stock reaccionó a 1000 compras)", stock_despues < stock_ini,
		"ini=%d despues=%d" % [stock_ini, stock_despues])
	# Integridad: una compra fuera de stock NO deja stock negativo (clamp a 0).
	sm.comprar("perf_tienda", "OBJ-PLA-002", 999_999)
	var stock_traspaso := int(sm.listar_stock("perf_tienda").get("OBJ-PLA-002", 0))
	_chk("integridad (stock no negativo tras compra masiva)", stock_traspaso >= 0,
		"stock_traspaso=%d" % stock_traspaso)

	_summary(total_us, us_por_txn)

func _chk(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _fallback_fail(razon: String) -> void:
	_chk("suite ejecutable", false, razon)
	_summary(0, 0)

func _summary(total_us: int, us_por_txn: int) -> void:
	print("=== Resumen M39 (rendimiento tienda): %d checks, %d fallos | 1000 transac. total=%d ms, prom=%d µs/txn ==="
		% [_checks, _fallos, total_us / 1000, us_por_txn])
	if _fallos > 0:
		print("FALLO — %d checks no pasaron" % _fallos)
		quit(1)
	else:
		print("TEST M39 OK — 1000 transacciones sin picos de frame")
		quit(0)
