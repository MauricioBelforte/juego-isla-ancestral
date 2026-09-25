# Modelo: ox-alpha
# Plataforma: Cline
# Fecha: 2026-08-25
#
# M39: Tiendas — ShopManager (autoload orquestador)
# Registro de tiendas, consultas de horario, compra/venta con transacción
# atómica y señales para UI (M53)/sonido (M43). Precios → M38, ítems → M14,
# tiempo → M29/M30: TODOS opcionales por duck-typing (aún no implementados).
# ⚠️ Sin class_name (el autoload ya se llama ShopManager — pitfall documentado).
extends Node

const SHOP_SCRIPT := preload("res://scripts/shops/shop.gd")
const GENERADOR_SCRIPT := preload("res://scripts/shops/stock_generator.gd")
const REPUTACION_SCRIPT := preload("res://scripts/shops/reputacion_tienda.gd")

## Motivos de rechazo (contrato de señales §5)
enum Motivo {
	TIENDA_INEXISTENTE,
	CERRADA,
	SIN_STOCK,
	SIN_FONDOS,
	INVENTARIO_LLENO,
	NO_RECOMPRA,
	SIN_ITEMS_JUGADOR,
	SISTEMA_NO_DISPONIBLE,
	CANTIDAD_INVALIDA,  # iter. glm (Log 1004): cantidad <= 0 en compra o venta
}

signal compra_exitosa(shop_id: String, item_id: String, cantidad: int, total: int, precio: int)
signal compra_rechazada(shop_id: String, item_id: String, motivo: Motivo)
signal venta_exitosa(shop_id: String, item_id: String, cantidad: int, total: int, precio: int)
signal venta_rechazada(shop_id: String, item_id: String, motivo: Motivo)
signal inventario_tienda_cambio(shop_id: String, item_id: String, stock: int)
signal tienda_abierta(shop_id: String)
## L95 (iter. glm, Log 1004): incluye la próxima apertura para el cartel de la UI.
## shop_ui no conecta esta señal (solo compra/venta/inventario): el cambio de
## firma es retrocompatible con los consumidores actuales.
signal tienda_cerrada(shop_id: String, proxima_apertura: Dictionary)

var _tiendas: Dictionary = {}
var _generador: RefCounted = null
var _reputacion: RefCounted = null
var _prng := RandomNumberGenerator.new()
var _dia_laborable_actual: int = 0
var _hora_actual: int = 8
var _estacion_actual: int = -1  # L189: -1 = sin calendario aún (degradación)

func _ready() -> void:
	_generador = GENERADOR_SCRIPT.new()
	_reputacion = REPUTACION_SCRIPT.new()
	_sincronizar_con_game_time()

## Conexión con el tiempo (M29 TimeCalendar, con fallback a M30 GameClock):
## abre/cierra tiendas por hora, restock diario automático y sincronía inicial sin
## esperar al primer tick. Si ambos faltan (tests fuera de árbol), queda modo manual.
## M29 (TimeCalendar) es la fuente canónica: agrega festivales/eventos a la lógica
## de apertura; M30 (GameTime) es el falback si M29 aún no está montado.
func _sincronizar_con_game_time() -> void:
	var tc = get_node_or_null("/root/TimeCalendar")
	var gt = get_node_or_null("/root/GameTime")
	var fuente = tc if tc != null else gt
	if fuente == null:
		return
	if fuente.has_signal("hora_cambio"):
		fuente.hora_cambio.connect(_on_hora_game_time)
	if fuente.has_signal("dia_cambio"):
		fuente.dia_cambio.connect(_on_dia_game_time)
	# L189 (iter. glm, Log 1004): la rotación estacional SOLO corre en el evento de
	# cambio de estación (M29/M30) — jamás por frame (RNF §7).
	if fuente.has_signal("estacion_cambio"):
		fuente.estacion_cambio.connect(_on_estacion_cambio)
	if fuente.has_method("get_semana_dia") and fuente.has_method("get_hora"):
		tick_hora(fuente.get_semana_dia(), fuente.get_hora())

func _on_hora_game_time(hora: int) -> void:
	var gt = get_node_or_null("/root/GameTime")
	if gt != null and gt.has_method("get_semana_dia"):
		tick_hora(gt.get_semana_dia(), hora)
	else:
		tick_hora(_dia_laborable_actual, hora)

func _on_dia_game_time(_info: Dictionary) -> void:
	var gt = get_node_or_null("/root/GameTime")
	if gt != null and gt.has_method("get_semana_dia"):
		_dia_laborable_actual = gt.get_semana_dia()
	reabastecer_diario(_dia_laborable_actual)
	_actualizar_mercaderes()

## L189 (iter. glm, Log 1004): en cambio de estación se RE-GENERA el stock de las
## tiendas de rotación fuerte con el filtro de temporada (canal 2 real).
func _on_estacion_cambio(estacion: int) -> void:
	_estacion_actual = estacion
	var ctx = _generador.Contexto.new()
	ctx.estacion = estacion
	ctx.dia_laborable = _dia_laborable_actual
	for id in _tiendas:
		var shop = _tiendas[id]
		if shop.definicion != null and bool(shop.definicion.rotacion_estacional_fuerte):
			shop.stock_actual = _generador.generar_con_contexto(shop.definicion, _prng, ctx)

## L98/L212/L227 (iter. glm): presencia diaria del mercader viajero según su
## calendario de aparición (PRNG de partida). Se llama SOLO en cambio de día
## y al cargar partida (jamás por frame).
func _actualizar_mercaderes() -> void:
	for id in _tiendas:
		var shop = _tiendas[id]
		if _es_mercader(shop):
			var presente: bool = _generador.aparece_mercader_hoy(shop.definicion, _prng)
			if presente != shop.mercader_presente:
				shop.mercader_presente = presente
				if not presente:
					tienda_cerrada.emit(id, proxima_apertura(id))

func _es_mercader(shop) -> bool:
	return shop.definicion != null and int(shop.definicion.dias_aparicion_mercader) > 0

## Inicializacion perezosa defensiva: garantiza subsistemas aunque _ready
## aun no haya corrido (ej: instancias montadas por tests fuera del arbol).
func _asegurar_subsistemas() -> void:
	if _generador == null:
		_generador = GENERADOR_SCRIPT.new()
	if _reputacion == null:
		_reputacion = REPUTACION_SCRIPT.new()

func set_semilla(semilla: int) -> void:
	_asegurar_subsistemas()
	_prng.seed = semilla

func registrar_tienda(definicion: Resource) -> void:
	_asegurar_subsistemas()
	if definicion == null or definicion.shop_id == "":
		return
	# L184/L232 (iter. glm, Log 1004): validación temprana. En runtime es
	# TOLERANTE (warning) para no romper tests/mock; la validación DURA vive en
	# CatalogoTiendas (tiendas oficiales, error en boot/editor).
	if String(definicion.npc_duenio_id) == "":
		push_warning("[M39] Tienda '%s' sin npc_duenio_id (validar en editor)" % String(definicion.shop_id))
	if definicion.catalogo_venta.is_empty():
		push_warning("[M39] Tienda '%s' con catálogo de venta vacío (validar en editor)" % String(definicion.shop_id))
	var shop = SHOP_SCRIPT.new(definicion)
	shop.inicializar_stock(_generador, _prng)
	_tiendas[definicion.shop_id] = shop

func obtener_tienda(shop_id: String) -> RefCounted:
	return _tiendas.get(shop_id)

func tick_hora(dia_semana: int, hora: int) -> void:
	_dia_laborable_actual = dia_semana
	_hora_actual = hora
	for id in _tiendas:
		var shop = _tiendas[id]
		var antes: bool = shop.abierta_ahora
		shop.abierta_ahora = shop.esta_abierta(dia_semana, hora)
		if shop.abierta_ahora and not antes:
			tienda_abierta.emit(id)
		elif not shop.abierta_ahora and antes:
			tienda_cerrada.emit(id, proxima_apertura(id))

func esta_abierta(shop_id: String) -> bool:
	var shop = _tiendas.get(shop_id)
	if shop == null:
		return false
	# L98/L212 (iter. glm): el mercader viajero "abre" según su calendario de
	# aparición (PRNG), no por franja horaria: sin presencia hoy → cerrada.
	if _es_mercader(shop) and not shop.mercader_presente:
		return false
	if not shop.esta_abierta(_dia_laborable_actual, _hora_actual):
		return false
	# Cierre por festival (M29 TimeCalendar): solo si la tienda lo configura.
	if bool(shop.definicion.cierra_en_festivales) and _hay_festival_hoy():
		return false
	return true

## L95/L210 (iter. glm): próxima apertura de una tienda, para el cartel de la UI.
## Consulta PURA sobre la definición (D4): nunca estado manual. Devuelve
## {} si la tienda no existe o no tiene días configurados.
func proxima_apertura(shop_id: String) -> Dictionary:
	var shop = _tiendas.get(shop_id)
	if shop == null or shop.definicion == null:
		return {}
	var def: Resource = shop.definicion
	for offset in range(0, 8):
		var dia := (_dia_laborable_actual + offset) % 7
		if dia in def.dias_descanso or dia == def.descanso_semanal:
			continue
		if not (dia in def.dias_abiertos):
			continue
		for franja in def.franjas_horarias:
			if offset > 0 or _hora_actual < franja.y:
				var hora: int = franja.x
				if offset == 0 and _hora_actual >= franja.x:
					hora = _hora_actual  # ya dentro de la franja de hoy: reapertura inmediata
				return {"dia_semana": dia, "hora": hora}
	return {}

## Consulta si hoy hay festival, usando M29 TimeCalendar (fuente canónica) con
## fallback a M30 GameClock. Devuelve false si ninguna fuente está disponible.
func _hay_festival_hoy() -> bool:
	var tc = get_node_or_null("/root/TimeCalendar")
	if tc != null and tc.has_method("hay_festival_hoy"):
		return bool(tc.hay_festival_hoy())
	var gt = get_node_or_null("/root/GameTime")
	if gt != null and gt.has_method("proximos_eventos"):
		return gt.proximos_eventos(1).size() > 0
	return false

func listar_stock(shop_id: String) -> Dictionary:
	var shop = _tiendas.get(shop_id)
	return shop.stock_actual.duplicate() if shop != null else {}


## ── COMPRA (jugador compra a la tienda) — Flujo 2.1 ──────
## Si M38/M14 no existen, rechaza con SISTEMA_NO_DISPONIBLE.
func comprar(shop_id: String, item_id: String, cantidad: int) -> void:
	var shop = _tiendas.get(shop_id)
	if shop == null:
		compra_rechazada.emit(shop_id, item_id, Motivo.TIENDA_INEXISTENTE); return
	if not esta_abierta(shop_id):
		compra_rechazada.emit(shop_id, item_id, Motivo.CERRADA); return
	# L222 (iter. glm, Log 1004): cantidad <= 0 se rechaza ANTES de tocar stock
	# (antes: precio*0 = 0 y la compra "exitosa" de 0 unidades pasaba).
	if cantidad <= 0:
		compra_rechazada.emit(shop_id, item_id, Motivo.CANTIDAD_INVALIDA); return
	if not shop.tiene_stock(item_id, cantidad):
		compra_rechazada.emit(shop_id, item_id, Motivo.SIN_STOCK); return

	var economia = get_node_or_null("/root/EconomyManager")   # M38 (opcional)
	var inventario = get_node_or_null("/root/Inventario")     # M14 (opcional)
	if economia == null or inventario == null \
			or not economia.has_method("precio_compra_vigente"):
		compra_rechazada.emit(shop_id, item_id, Motivo.SISTEMA_NO_DISPONIBLE); return

	# Precio SIEMPRE de M38 (este módulo jamás suma precios).
	# L198/L119/L231 (iter. glm, Log 1004): npc del dueño (descuento amistad M20),
	# recargo opcional del mercader viajero (topes de M38) y clamp defensivo >= 1.
	var precio: int = maxi(1, int(economia.precio_compra_vigente(item_id, String(shop.definicion.npc_duenio_id), cantidad, float(shop.definicion.recargo_mercader_pct))))
	var total: int = precio * cantidad
	if not bool(economia.retirar_monedas(total)):
		compra_rechazada.emit(shop_id, item_id, Motivo.SIN_FONDOS); return

	# Transacción atómica (D8): stock → monedas → inventario, con revert total.
	# Orden cozy: las monedas salen PRIMERO (puede_pagar ya pasó); si el inventario
	# falla, se devuelven monedas Y stock — el jugador nunca pierde nada.
	shop.remover_stock(item_id, cantidad)
	if not bool(inventario.agregar_items({item_id: cantidad})):
		shop.acumular_stock(item_id, cantidad)  # revertir stock
		economia.depositar_monedas(total)       # revertir monedas (BUG: antes se perdían)
		compra_rechazada.emit(shop_id, item_id, Motivo.INVENTARIO_LLENO); return

	compra_exitosa.emit(shop_id, item_id, cantidad, total, precio)
	inventario_tienda_cambio.emit(shop_id, item_id, int(shop.stock_actual.get(item_id, 0)))

## ── VENTA (jugador vende a la tienda) — Flujo 2.2 ────────
func vender(shop_id: String, item_id: String, cantidad: int) -> void:
	var shop = _tiendas.get(shop_id)
	if shop == null:
		venta_rechazada.emit(shop_id, item_id, Motivo.TIENDA_INEXISTENTE); return
	if not esta_abierta(shop_id):
		venta_rechazada.emit(shop_id, item_id, Motivo.CERRADA); return
	# L222 (iter. glm): cantidad <= 0 se rechaza antes de tocar inventario.
	if cantidad <= 0:
		venta_rechazada.emit(shop_id, item_id, Motivo.CANTIDAD_INVALIDA); return
	if not shop.definicion.catalogo_recompra.has(item_id):
		venta_rechazada.emit(shop_id, item_id, Motivo.NO_RECOMPRA); return

	var economia = get_node_or_null("/root/EconomyManager")
	var inventario = get_node_or_null("/root/Inventario")
	if economia == null or inventario == null \
			or not economia.has_method("precio_venta_vigente"):
		venta_rechazada.emit(shop_id, item_id, Motivo.SISTEMA_NO_DISPONIBLE); return
	if not bool(inventario.remover_items({item_id: cantidad})):
		venta_rechazada.emit(shop_id, item_id, Motivo.SIN_ITEMS_JUGADOR); return

	# L231 (iter. glm): clamp defensivo — M38 no debería devolver 0 en venta, pero
	# el módulo no confía (D7 intacto: el precio SIEMPRE lo da M38).
	var precio: int = maxi(1, int(economia.precio_venta_vigente(item_id)))
	var total: int = precio * cantidad

	# Transacción atómica (D8)
	economia.depositar_monedas(total)
	shop.acumular_stock(item_id, cantidad)

	venta_exitosa.emit(shop_id, item_id, cantidad, total, precio)
	inventario_tienda_cambio.emit(shop_id, item_id, int(shop.stock_actual.get(item_id, 0)))

	# Anti-grind (M38): registra la venta en la ventana de oferta del mercado.
	# Usa dia_absoluto (M29) para que la ventana no se rompa al cambiar de mes.
	var gt = get_node_or_null("/root/GameTime")
	if gt != null and gt.has_method("dia_absoluto"):
		economia.registrar_venta_para_mercado(item_id, cantidad, int(gt.dia_absoluto()))

	# Reputación de venta (+1 normal; +3 si 3+ items en una visita)
	if _reputacion != null:
		var motivo_v := REPUTACION_SCRIPT.MotivoVenta.GRANDE if cantidad >= 3 \
				else REPUTACION_SCRIPT.MotivoVenta.NORMAL
		_reputacion.registrar_venta(motivo_v)

## ── Restock diario (lo invoca M29 al cambiar el día) ─────
func reabastecer_diario(dia_laborable: int) -> void:
	for id in _tiendas:
		_reabastecer_una(_tiendas[id], dia_laborable)

## Reabastecimiento de UNA tienda (iter. glm): también lo usa la recuperación de
## días perdidos al cargar (L194). Incluye la estación corriente en el contexto.
func _reabastecer_una(shop, dia_laborable: int) -> void:
	var ctx = _generador.Contexto.new()
	ctx.estacion = _estacion_actual
	ctx.dia_laborable = dia_laborable
	_generador.reabastecer_diario(shop, _prng, ctx)

## ── Persistencia (M59) ───────────────────────────────────
func guardar_estado() -> Dictionary:
	var datos: Dictionary = {"tiendas": {}, "reputacion": {}}
	for id in _tiendas:
		datos["tiendas"][id] = _tiendas[id].serializar()
	if _reputacion != null:
		datos["reputacion"] = _reputacion.serializar()
	return datos

func cargar_estado(d: Dictionary) -> void:
	var tiendas: Dictionary = d.get("tiendas", {})
	for id in tiendas:
		var shop = _tiendas.get(str(id))
		if shop != null:
			shop.deserializar(tiendas[id])
	if _reputacion != null:
		_reputacion.deserializar(d.get("reputacion", {}))
	# L194 (iter. glm, Log 1004): recuperación de días perdidos — una partida vieja
	# cargada con restock pendiente se repone al cargar (cozy, sin castigo).
	for id in _tiendas:
		var shop = _tiendas[id]
		if shop.fecha_ultimo_restock >= 0 and shop.fecha_ultimo_restock < _dia_laborable_actual:
			_reabastecer_una(shop, _dia_laborable_actual)
	# L227 (iter. glm): la presencia del mercader viajero viaja en el guardado;
	# SOLO si no viajaba (guardado de versión anterior) se recalcula hoy.
	var mercader_guardado := false
	for id in tiendas:
		var d_shop: Dictionary = tiendas[id]
		if d_shop.has("mercader"):
			mercader_guardado = true
			break
	if not mercader_guardado:
		_actualizar_mercaderes()

func reputacion() -> RefCounted:
	return _reputacion
