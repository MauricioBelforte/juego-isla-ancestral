# Modelo: Ling-3.1-Flash
# Plataforma: Kilo Code
# Fecha: 2026-10-12
#
# M112 — Integración Pesca (M34) → Economía (M38):
# sesión de pesca → captura → entrega del ítem pez a Inventario
# (M14, E95/G115) → venta (precio_venta_vigente + deposito en
# saldo) → reputación RF13 + historial RF15 + roundtrip M59.
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral --script res://tests/integration/test_fishing_economy.gd
#
# Guardia anti-falso-verde: _fin() por bloque + CHECKS_MINIMOS
# medido + _summary() en call_deferred SEPARADO + watchdog.

extends SceneTree

const TIMEOUT_SEG := 60.0
const CHECKS_MINIMOS := 18
const BLOQUES_ESPERADOS: Array[String] = ['A', 'B', 'C', 'D']

const SHOP_MGR_SCRIPT := preload("res://scripts/shops/shop_manager.gd")

var _fm
var _inv
var _eco

var _fallos: int = 0
var _checks: int = 0
var _bloque: String = "(inicio)"
var _abortado: bool = false
var _completados: Array[String] = []
var _checks_por_bloque: Dictionary = {}
var _checks_marca: int = 0
var _pez_id: String = ""


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	create_timer(TIMEOUT_SEG, true).timeout.connect(_on_watchdog)
	print("=== M34+M38 Pesca↔Economía (headless) ===")
	_fm = root.get_node_or_null("Fishing")
	_inv = root.get_node_or_null("Inventario")
	_eco = root.get_node_or_null("EconomyManager")
	_check("autoload Fishing presente", _fm != null)
	_check("autoload Inventario presente", _inv != null)
	_check("autoload EconomyManager presente", _eco != null)
	if _fm == null or _inv == null or _eco == null:
		return
	_eco._asegurar_precios()
	_bloque_A()
	_bloque_B()
	_bloque_C()
	_bloque_D()


func _on_watchdog() -> void:
	_abortado = true
	print("WATCHDOG: la suite no termino en %.0f s (ultimo bloque: %s)" % [TIMEOUT_SEG, _bloque])
	quit(1)


func _ini(nombre: String) -> void:
	_bloque = nombre
	_checks_marca = _checks
	print("\n-- %s --" % nombre)


func _fin(nombre: String) -> void:
	var letra: String = nombre.substr(0, 1)
	if not _completados.has(letra):
		_completados.append(letra)
	var delta: int = _checks - _checks_marca
	_checks_por_bloque[letra] = int(_checks_por_bloque.get(letra, 0)) + delta
	_checks_marca = _checks
	print("[FIN] %s (+%d checks)" % [nombre, delta])


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])


func _summary() -> void:
	var faltantes: Array[String] = []
	for letra in BLOQUES_ESPERADOS:
		if not _completados.has(letra):
			faltantes.append(letra)
	_check("todos los bloques se completaron (sin abortos silenciosos)", faltantes.is_empty(),
		"bloques que no terminaron: %s" % str(faltantes))
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("  [FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("Checks por bloque: %s" % str(_checks_por_bloque))
	print("\n=== Resumen M34+M38: %d checks, %d fallos ===" % [_checks, _fallos])
	if _abortado:
		quit(1)
	elif _fallos == 0:
		print("TEST OK — todos los checks pasaron")
		quit(0)
	else:
		print("TEST FALLO — %d checks fallaron" % _fallos)
		quit(1)


## Flujo de captura forzado (patrón de scripts/fishing/test_fishing.gd):
## sesión → picada → pulsación fase A → 3 pulsaciones fase B → CAPTURA.
func _capturar_un_pez() -> String:
	var cana := FishingRod.new()
	cana.id = "cana_test_m112"
	cana.ventana_exito = 0.5
	var spot = Node3D.new()
	root.add_child(spot)
	_fm.registrar_spot(spot)
	## Las lambdas capturan locales POR VALOR (Log 1127): un holder
	## Array (referencia) para que la captura del pez sea visible.
	var captura: Array = []
	_fm.captura_exitosa.connect(func(pez, _tam): captura.append(pez))
	var ses = _fm.iniciar_sesion(spot, cana, null)
	if ses == null:
		return ""
	ses._on_picada()
	# 1 pulsación en fase A (-> MINIJUEGO) + 3 en fase B (-> CAPTURA),
	# diseño §2.5 (patrón de scripts/fishing/test_fishing.gd).
	ses.notificar_pulsacion_boton()
	ses.notificar_pulsacion_boton()
	ses.notificar_pulsacion_boton()
	ses.notificar_pulsacion_boton()
	if captura.is_empty():
		return ""
	return str(captura[0].id)


func _bloque_A() -> void:
	_ini("A. sesion de pesca: captura y entrega a M14")
	var ses_eventos: Array = []
	_fm.captura_fallida.connect(func(_m): ses_eventos.append("fallo"))
	var antes_sardina: int = _inv.count_item("pez_sardina")
	_pez_id = _capturar_un_pez()
	_check("captura resuelta (id de pez obtenido)", _pez_id != "")
	if _pez_id != "":
		_check("pez entregado al inventario M14 (E95/G115)",
			_inv.count_item(_pez_id) >= 1, "id=%s n=%d" % [_pez_id, _inv.count_item(_pez_id)])
		_check("coleccion registra la captura", _fm._capturas_totales >= 1,
			"totales=%d" % _fm._capturas_totales)
		_check("sin captura_fallida en flujo exitoso", not ses_eventos.has("fallo"))
	_fin("A. sesion de pesca: captura y entrega a M14")


func _bloque_B() -> void:
	_ini("B. venta real: ShopManager.vender (M39)")
	_check("hay pez capturado para vender", _pez_id != "")
	if _pez_id == "":
		_fin("B. venta real: ShopManager.vender (M39)")
		return
	var sm = root.get_node_or_null("ShopManager")
	_check("autoload ShopManager presente", sm != null)
	if sm == null:
		_fin("B. venta real: ShopManager.vender (M39)")
		return
	## Horario comercial determinista: día laborable 1, hora 10
	## (tienda_general abre 8-20, días 1-6 — catalogo_tiendas.gd:109-111).
	## tick_hora es público (shop_manager.gd:147) y recorre el mismo
	## camino que la señal hora_cambio de GameTime.
	sm.tick_hora(1, 10)
	_check("tienda_general abierta en horario comercial", sm.esta_abierta("tienda_general"))
	var rechazo: Array = []
	var exito: Array = []
	sm.venta_rechazada.connect(func(_s, _i, motivo): rechazo.append(int(motivo)))
	sm.venta_exitosa.connect(func(_s, _i, _c, _t, _p): exito.append(1))
	var saldo_antes: int = int(_eco.saldo)
	sm.vender("tienda_general", _pez_id, 1)
	## HALLAZGO R3-H1 (2026-10-12): las 3 tiendas oficiales tienen 0
	## peces en catalogo_recompra (catalogo_tiendas.gd:123-167 — solo
	## wood/stone/copper_ore/grass/OBJ-ITE-024/OBJ-ART-003). La venta
	## de la captura NO está integrada M34→M39: el jugador no puede
	## vender peces ni con la tienda abierta. Caracterización del
	## contrato actual (rechazo NO_RECOMPRA). Cuando M38/M39 agreguen
	## peces al catálogo, invertir estas aserciones (rechazo →
	## venta_exitosa + saldo aumentado).
	_check("venta de pez rechazada con tienda ABIERTA: no recompran peces (GAP M39, R3-H1)",
		exito.is_empty() and rechazo.size() == 1
		and int(rechazo[0]) == SHOP_MGR_SCRIPT.Motivo.NO_RECOMPRA,
		"rechazos=%s exitos=%d" % [str(rechazo), exito.size()])
	_check("saldo intacto ante venta rechazada (transacción atómica D8)",
		int(_eco.saldo) == saldo_antes)
	_fin("B. venta real: ShopManager.vender (M39)")


func _bloque_C() -> void:
	_ini("C. catálogo de precios M38 (econ_prices.tres)")
	var precio_sardina: int = _eco.precio_venta_vigente("pez_sardina")
	_check("pez_sardina sí tiene precio en econ_prices.tres", precio_sardina > 0,
		"precio=%d" % precio_sardina)
	## HALLAZGO R3-H1: solo 1 de 25 peces tiene precio en econ_prices.tres
	## (grep 'item_id = "pez_' = 1 hit). Los otros 24 devuelven 0 y, de
	## recomprarse algún día, venderían al piso maxi(1, 0) = 1 moneda
	## (shop_manager.gd:276). Caracterización del gap de datos M38/M93.
	var precio_anchoa: int = _eco.precio_venta_vigente("pez_anchoa")
	_check("pez_anchoa SIN precio en M38 (24/25 peces, GAP R3-H1)",
		precio_anchoa == 0, "precio=%d" % precio_anchoa)
	_fin("C. catálogo de precios M38 (econ_prices.tres)")


func _bloque_D() -> void:
	_ini("D. roundtrip M59: economia + inventario")
	var eco_data: Dictionary = _eco.get_save_data()
	var eco2 = load("res://scripts/economia/economy_manager.gd").new()
	eco2._asegurar_precios()
	eco2.restore_save_data(eco_data)
	_check("saldo restaurado en instancia nueva", int(eco2.saldo) == int(_eco.saldo),
		"restaurado=%d vivo=%d" % [int(eco2.saldo), int(_eco.saldo)])
	eco2.free()
	## Roundtrip con ítem M15 real: el mecanismo M59 funciona.
	_inv.agregar_items({"wood": 3})
	var inv_data: Dictionary = _inv.get_save_data()
	var inv2 = load("res://scripts/inventario/inventario_service.gd").new()
	inv2.name = "InvTestM112"
	root.add_child(inv2)  # _ready() usa get_node("/root/..."): requiere árbol activo
	inv2._ready()
	inv2.restore_save_data(inv_data)
	_check("roundtrip M59 conserva ítems M15 (wood)", int(inv2.count_item("wood")) == 3,
		"wood=%d" % int(inv2.count_item("wood")))
	## HALLAZGO R3-H2 (2026-10-12): los peces NO son ítems M15 —
	## ItemDatabase no tiene ningún id pez_* (grep 0 hits en las
	## fuentes de ítems; solo fishing.json/lore.json/econ_prices.tres
	## los conocen). deserializar() valida contra ItemDatabase y
	## descarta lo desconocido (M14-DOM-14): la captura de pesca
	## SE PIERDE al cargar partida. Caracterización del gap: el pez
	## capturado no sobrevive el roundtrip. Cuando M15 registre los
	## peces, invertir esta aserción (se conserva en el restore).
	if _pez_id != "":
		_check("pez capturado NO sobrevive el roundtrip M59 (GAP M15, R3-H2)",
			int(inv2.count_item(_pez_id)) == 0,
			"id=%s n=%d (esperado 0: descartado por ItemDatabase)" % [_pez_id, int(inv2.count_item(_pez_id))])
	root.remove_child(inv2)
	inv2.free()
	_fin("D. roundtrip M59: economia + inventario")
