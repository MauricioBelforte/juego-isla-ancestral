# Modelo: ox-alpha
# Plataforma: Cline
# Fecha: 2026-08-26
#
# M38: Economía — EconomyManager (autoload)
# Saldo, transacciones monetarias y persistencia (§1/§6).
# NO conoce tiendas ni trueques; los precios los calcula PriceManager.
# Contrato que consume M39 ShopManager:
#   precio_compra_vigente(item_id) / precio_venta_vigente(item_id) / puede_pagar / retirar_monedas / depositar_monedas
# ⚠️ Sin class_name: el autoload ya se llama "EconomyManager" (pitfall documentado).
extends Node

const PRICE_MANAGER_SCRIPT := preload("res://scripts/economia/price_manager.gd")

## Señales del contrato §5
signal saldo_cambiado(saldo: int)
signal transaccion_registrada(tx: Dictionary)

## Saldo inicial cozy: el jugador nunca arranca en bancarrota
const SALDO_INICIAL: int = 100

## Tope de saldo (anti-overflow y anti-grind extremo). Diseño M38 §2.
const MAX_SALDO: int = 999999

var saldo: int = SALDO_INICIAL
var precios: RefCounted = null  # PriceManager (vía preload, sin race de autoloads)

func _ready() -> void:
	_asegurar_precios()
	_registrar_como_proveedor_guardado()

## Inicializacion perezosa defensiva: garantiza PriceManager aunque _ready
## no haya corrido (ej: instancias montadas por tests fuera del arbol activo).
func _asegurar_precios() -> void:
	if precios == null:
		precios = PRICE_MANAGER_SCRIPT.new()

## Se registra en SaveManager (M59): sección "economy".
func _registrar_como_proveedor_guardado() -> void:
	var sm = get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)

## ── Consultas de precio (delegan a PriceManager) ─────────
func precio_compra_vigente(item_id: String, npc_id: String = "", cantidad: int = 1) -> int:
	_asegurar_precios()
	return precios.precio_compra_vigente(item_id, npc_id, cantidad)

func precio_venta_vigente(item_id: String) -> int:
	_asegurar_precios()
	return precios.precio_venta_vigente(item_id)

## ── Transacciones ────────────────────────────────────────

func puede_pagar(total: int) -> bool:
	return total >= 0 and saldo >= total

## Retira monedas. Devuelve false si no alcanza (saldo intacto).
func retirar_monedas(total: int) -> bool:
	if not puede_pagar(total):
		return false
	saldo -= total
	saldo_cambiado.emit(saldo)
	transaccion_registrada.emit({"tipo": "retiro", "monto": total, "saldo": saldo})
	return true

func depositar_monedas(total: int) -> bool:
	if total < 0:
		return false
	saldo = mini(saldo + total, MAX_SALDO)
	saldo_cambiado.emit(saldo)
	transaccion_registrada.emit({"tipo": "deposito", "monto": total, "saldo": saldo})
	return true

## Registro de venta para la ventana de oferta del PriceManager (M39 lo invoca).
func registrar_venta_para_mercado(item_id: String, cantidad: int, dia: int) -> void:
	precios.registrar_venta(item_id, cantidad, dia)

## ── Persistencia (ISaveProvider por duck-typing, M59) ────

func get_section_name() -> String:
	return "economy"

func get_save_data() -> Dictionary:
	var d := {"saldo": saldo}
	if precios != null:
		d["precios"] = precios.serializar()
	return d

func restore_save_data(data: Dictionary) -> void:
	saldo = clampi(int(data.get("saldo", SALDO_INICIAL)), 0, MAX_SALDO)
	if precios != null and data.has("precios") and typeof(data["precios"]) == TYPE_DICTIONARY:
		precios.deserializar(data["precios"])
	saldo_cambiado.emit(saldo)
