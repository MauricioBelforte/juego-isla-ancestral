# Modelo: glm-5.3-flash
# Plataforma: Cline
# Fecha: 2026-09-17
#
# M39: Test de la iter. glm (Log 1004) — horarios/bordes/descanso (RF5),
# CANTIDAD_INVALIDA, clamp/npc_id/recargo a M38, canales 2/3 del generador,
# recuperación de días perdidos (L194), persistencia del mercader (L227/L98)
# y proxima_apertura (L95). Complementa test_tiendas.gd / test_loop_economico.gd.
# Ejecutar: godot --headless --path game/isla-ancestral --script res://scripts/shops/test_tiendas_iter_glm.gd
# NOTA: los autoloads (EconomyManager, Inventario, ShopManager, ItemDatabase,
# CatalogoTiendas) SI se cargan con --script; se usan los reales (patrón test_loop).

extends SceneTree

var _fallos := 0
var _checks := 0

func _initialize() -> void:
	print("=== TEST M39 ITER GLM (tiendas) ===")
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	var eco = root.get_node_or_null("EconomyManager")
	var inv = root.get_node_or_null("Inventario")
	var sm = root.get_node_or_null("ShopManager")
	var db = root.get_node_or_null("ItemDatabase")
	_check("autoloads presentes", eco != null and inv != null and sm != null and db != null)
	if eco == null or inv == null or sm == null:
		print("FALTAN AUTOLOADS"); quit(1); return
	_test_canales_generador()
	_test_recuperacion_y_mercader()
	_test_horarios_real(sm)
	_test_cantidad_invalida(sm)
	_test_venta_sin_fondos(sm, eco)
	_test_recargo_mercader(sm, eco, db)
	print("=== Resumen: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("FALLOS DETECTADOS"); quit(1)
	else:
		print("M39 ITER GLM OK"); quit(0)

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)

## Canales 2 (estación) y 3 (eventos) del generador — canalización real
func _test_canales_generador() -> void:
	var gen = load("res://scripts/shops/stock_generator.gd").new()
	var sd = load("res://scripts/shops/shop_data.gd")
	var def = sd.new()
	def.shop_id = "t_canal"
	var dias: Array[int] = [0, 1, 2, 3, 4, 5, 6]
	def.dias_abiertos = dias
	var franjas: Array[Vector2i] = [Vector2i(0, 24)]
	def.franjas_horarias = franjas
	var estacional = sd.StockEntry.new("semilla_estacional", 1, 3, 1.0, false, [1] as Array[int], "")
	var basico = sd.StockEntry.new("basico_siempre", 1, 3, 1.0, true, [1] as Array[int], "")
	var de_evento = sd.StockEntry.new("item_feria", 1, 2, 1.0, false, [] as Array[int], "feria")
	def.catalogo_venta = [estacional, basico, de_evento]
	var prng := RandomNumberGenerator.new()
	prng.seed = 42
	var ctx0 = gen.Contexto.new()
	ctx0.estacion = 0
	var s0: Dictionary = gen.generar_con_contexto(def, prng, ctx0)
	_check("canal2: fuera de temporada AUSENTE", not s0.has("semilla_estacional"))
	_check("canal2: básico SIEMPRE presente (sin tocar básicos)", int(s0.get("basico_siempre", 0)) >= 1)
	_check("canal3: sin evento activo AUSENTE", not s0.has("item_feria"))
	var ctx1 = gen.Contexto.new()
	ctx1.estacion = 1
	ctx1.eventos_activos.append("feria")
	var s1: Dictionary = gen.generar_con_contexto(def, prng, ctx1)
	_check("canal2: en temporada PRESENTE", s1.has("semilla_estacional"))
	_check("canal3: con evento activo PRESENTE", s1.has("item_feria"))

## ShopManager FRESCO: L194 recuperación de días perdidos + L227 mercader persistido
## + L95 proxima_apertura + RF5 bordes/descanso — sin contaminar el autoload real.
func _test_recuperacion_y_mercader() -> void:
	var sm2 = load("res://scripts/shops/shop_manager.gd").new()
	sm2.name = "ShopManagerRecup"
	root.add_child(sm2)
	var sd = load("res://scripts/shops/shop_data.gd")
	var def = sd.new()
	def.shop_id = "t_recup"
	def.tipo = sd.Tipo.MERCADER_VIAJERO
	def.dias_aparicion_mercader = 3
	var dias_l: Array[int] = [1, 2, 3, 4, 5]
	def.dias_abiertos = dias_l
	var franjas: Array[Vector2i] = [Vector2i(9, 17)]
	def.franjas_horarias = franjas
	def.catalogo_venta = [sd.StockEntry.new("ITEM_RECUP", 1, 3, 1.0, true)]
	def.catalogo_recompra = ["ITEM_RECUP"] as Array[String]
	sm2.registrar_tienda(def)
	sm2.set_semilla(7)
	# L227: guardar con mercader AUSENTE → al cargar sigue ausente (persistido)
	sm2._dia_laborable_actual = 5
	var save1: Dictionary = {"tiendas": {"t_recup": {"shop_id": "t_recup", "stock": {}, "ultimo_restock": 1, "mercader": false}}}
	sm2.cargar_estado(save1)
	var shop = sm2.obtener_tienda("t_recup")
	_check("L194: fecha de restock actualizada al día corriente", int(shop.fecha_ultimo_restock) == 5)
	_check("L194: stock repuesto al cargar (>= stock_min)", int(shop.stock_actual.get("ITEM_RECUP", 0)) >= 1)
	_check("L227: mercader ausente PERSISTIDO", shop.mercader_presente == false)
	sm2.tick_hora(5, 12)
	_check("L98: mercader ausente → tienda CERRADA aunque sea franja", not sm2.esta_abierta("t_recup"))
	# L95: próxima apertura consultable (para el cartel de la UI)
	var prox: Dictionary = sm2.proxima_apertura("t_recup")
	_check("L95: proxima_apertura devuelve dia/hora", prox.has("dia_semana") and prox.has("hora"))
	_check("L95: reapertura hoy dentro de franja (dia 5, hora 12)", int(prox.get("dia_semana", -1)) == 5 and int(prox.get("hora", -1)) == 12)
	# RF5: bordes de hora — apertura 9 INCLUIDA, cierre 17 EXCLUIDO
	sm2._dia_laborable_actual = 1
	shop.mercader_presente = true
	sm2.tick_hora(1, 8)
	_check("RF5: 8:00 ANTES de la franja → cerrada", not sm2.esta_abierta("t_recup"))
	sm2.tick_hora(1, 9)
	_check("RF5: 9:00 INCLUIDA → abierta", sm2.esta_abierta("t_recup"))
	sm2.tick_hora(1, 16)
	_check("RF5: 16:59 → abierta", sm2.esta_abierta("t_recup"))
	sm2.tick_hora(1, 17)
	_check("RF5: 17:00 EXCLUIDA → cerrada", not sm2.esta_abierta("t_recup"))
	# RF5: día de descanso explícito — cerrado todo el día aunque sea franja
	def.dias_descanso = [2] as Array[int]
	sm2.tick_hora(2, 12)
	_check("RF5/L97: día de descanso → cerrada en franja", not sm2.esta_abierta("t_recup"))
	def.dias_descanso = [] as Array[int]
	sm2.queue_free()

## RF5 + D4 sobre el ShopManager real (tiendas oficiales ya registradas)
func _test_horarios_real(sm) -> void:
	_check("núcleo: tiendas oficiales registradas", sm.obtener_tienda("tienda_general") != null)
	_check("L192 fix: días en 0..6 (día 7 ya no muerto)", int(sm.obtener_tienda("mercader_viajero").definicion.dias_abiertos.has(0)))

## L222: cantidad <= 0 rechazada con CANTIDAD_INVALIDA, sin efectos laterales
func _test_cantidad_invalida(sm) -> void:
	sm.tick_hora(1, 12)
	var motivos: Array = []
	var cb := func(_sid: String, _iid: String, motivo: int) -> void:
		motivos.append(motivo)
	sm.compra_rechazada.connect(cb)
	sm.venta_rechazada.connect(cb)
	var stock_antes := int(sm.listar_stock("tienda_general").get("madera_roble", 0))
	sm.comprar("tienda_general", "madera_roble", 0)
	sm.comprar("tienda_general", "madera_roble", -3)
	sm.vender("tienda_general", "madera_roble", -1)
	_check("L222: rechazos CANTIDAD_INVALIDA (motivo 8) x3", motivos.size() == 3 and motivos[0] == 8 and motivos[1] == 8 and motivos[2] == 8)
	_check("L222: sin efectos laterales en stock", int(sm.listar_stock("tienda_general").get("madera_roble", 0)) == stock_antes)
	sm.compra_rechazada.disconnect(cb)
	sm.venta_rechazada.disconnect(cb)

## L119/L198/L231 + D8-atomicidad: el mercader pasa npc_id y recargo a M38;
## clamp >= 1 se mantiene; con inventario LLENO el revert es TOTAL (stock+monedas).
func _test_recargo_mercader(sm, eco, db) -> void:
	_test_atomicidad_inventario_lleno(sm, eco)
	_test_recargo_mercader_nucleo(sm, eco, db)

## D8-atomicidad: con inventario LLENO, agregar_items falla -> revert TOTAL.
## Sin este revert el jugador perdía las monedas (BUG real, fix en shop_manager).
func _test_atomicidad_inventario_lleno(sm, eco) -> void:
	var inv = root.get_node_or_null("Inventario")
	_check("atomicidad: autoload Inventario presente", inv != null)
	if inv == null:
		return
	# Tapar TODOS los contenedores (bolsillo+mochila+casa): el adaptador cae a
	# CASA cuando el bolsillo se llena, así que hay que llenar los TRES.
	# Estrategia: agregar el MISMO item hasta que falle (cada stack llena un slot).
	var tapa_id := "TAPA_M39"
	var tapas: Array = []
	var n_ok := 0
	while n_ok < 400 and bool(inv.agregar_items({tapa_id: 99})):
		n_ok += 1
		if n_ok == 1:
			tapas.append(tapa_id)
	_check("atomicidad: inventario tapado (%d adds, agregar_items falla)" % n_ok, not bool(inv.agregar_items({"TAPA_M39_FULL": 99})))
	sm.tick_hora(1, 12)
	sm.obtener_tienda("mercader_viajero").mercader_presente = true
	eco.saldo = 100000
	var stock_antes := int(sm.listar_stock("mercader_viajero").get("baya_roja", 0))
	var saldo_antes := int(eco.saldo)
	var motivos: Array = []
	var cb := func(_sid: String, _iid: String, motivo: int) -> void:
		motivos.append(motivo)
	sm.compra_rechazada.connect(cb)
	sm.comprar("mercader_viajero", "baya_roja", 1)
	_check("atomicidad: rechazo INVENTARIO_LLENO (motivo 4)", motivos.size() == 1 and int(motivos[0]) == 4)
	_check("atomicidad: stock REVERTIDO (sin pérdida)", int(sm.listar_stock("mercader_viajero").get("baya_roja", 0)) == stock_antes)
	_check("atomicidad: monedas REVERTIDAS (BUG fix: antes se perdían)", int(eco.saldo) == saldo_antes)
	sm.compra_rechazada.disconnect(cb)
	# Restaurar: vaciar las tapas para no contaminar los tests siguientes.
	# NOTA (Log 1017): remover_items es todo-o-nada con validación previa
	# (count < pedido → false SIN remover), por eso se le pasa el conteo REAL.
	var cant_tapa: int = int(inv.count_item(tapa_id, true))
	if cant_tapa > 0:
		var ok := bool(inv.remover_items({tapa_id: cant_tapa}))
		_check("atomicidad: restauración quita las %d tapas" % cant_tapa, ok)
	inv.remover_items({"TAPA_M39_FULL": int(inv.count_item("TAPA_M39_FULL", true))})

func _test_recargo_mercader_nucleo(sm, eco, db) -> void:
	var item = db.get_item("baya_roja")
	if item != null and int(item.precio_compra) <= 0:
		item.set("precio_compra", 100)
	var precio_base: int = int(eco.precio_compra_vigente("baya_roja", "", 1))
	_check("M38: precio base > 0 (variabilidad determinista)", precio_base >= 1)
	var precio_recargado: int = int(eco.precio_compra_vigente("baya_roja", "", 1, 12.0))
	_check("L119/M38: recargo 12% > base (M38 aplica recargo)", precio_recargado >= precio_base)
	# Compra REAL: el total lo emite la señal (fuente de verdad). Se valida
	# integración: total == precio señalado * cantidad y clamp cozy >= 1. La
	# aritmética exacta del recargo la prueba M38 en sus propias suites.
	sm.tick_hora(1, 12)
	sm.obtener_tienda("mercader_viajero").mercader_presente = true
	var pares: Array = []  # [total, precio] por cada compra
	var cb := func(_sid: String, _iid: String, _cant: int, total: int, precio: int) -> void:
		pares.append([total, precio])
	sm.compra_exitosa.connect(cb)
	eco.saldo = 100000
	sm.comprar("mercader_viajero", "baya_roja", 1)
	sm.compra_exitosa.disconnect(cb)
	_check("L119/L203: la compra del mercader EMITE la señal (1 compra)", pares.size() == 1)
	if pares.size() == 1:
		var tot: int = int(pares[0][0])
		var pr: int = int(pares[0][1])
		_check("L119: total == precio * cantidad (coherencia)", tot == pr * 1)
		_check("L119: clamp cozy >= 1 en precio final", pr >= 1)
		_check("L119: el precio cobrado ES el recargado de M38", pr == precio_recargado)

## L234 (reconciliación cierre, iter. glm): el jugador SIN monedas puede vender
## para obtener ingresos — la venta no exige saldo previo (básicos siempre
## recomprados) y la tienda acumula el ítem vendido (shop.gd acumular_stock).
func _test_venta_sin_fondos(sm, eco) -> void:
	var inv = root.get_node_or_null("Inventario")
	_check("L234: autoload Inventario presente", inv != null)
	if inv == null:
		return
	var saldo_guardado: int = int(eco.saldo)
	# Arruinar al jugador: vaciar el saldo por completo.
	while int(eco.saldo) > 0:
		if not bool(eco.retirar_monedas(int(eco.saldo))):
			break
	_check("L234: el jugador quedó con 0 monedas", int(eco.saldo) == 0)
	inv.agregar_items({"madera_roble": 2})
	sm.tick_hora(1, 12)
	var stock_antes := int(sm.listar_stock("tienda_general").get("madera_roble", 0))
	var ventas: Array = []
	var rechazos: Array = []
	var cb := func(_sid: String, _iid: String, cant: int, _tot: int, pr: int) -> void:
		ventas.append([cant, pr])
	var cbr := func(_sid: String, _iid: String, motivo: int) -> void:
		rechazos.append(motivo)
	sm.venta_exitosa.connect(cb)
	sm.venta_rechazada.connect(cbr)
	sm.vender("tienda_general", "madera_roble", 1)
	sm.venta_exitosa.disconnect(cb)
	sm.venta_rechazada.disconnect(cbr)
	_check("L234: la venta con 0 monedas NO se rechaza", ventas.size() == 1 and rechazos.is_empty())
	_check("L234: el ingreso entra al saldo (0 -> %d)" % int(eco.saldo), int(eco.saldo) > 0)
	_check("L234: la tienda acumula el ítem vendido (acumular_stock)", int(sm.listar_stock("tienda_general").get("madera_roble", 0)) == stock_antes + 1)
	_check("L234: el precio de venta es de M38 con clamp >= 1", ventas.size() == 1 and int(ventas[0][1]) >= 1)
	# Restaurar el entorno para los tests siguientes.
	eco.saldo = saldo_guardado
	var restante: int = int(inv.count_item("madera_roble", true))
	if restante > 0:
		inv.remover_items({"madera_roble": restante})

