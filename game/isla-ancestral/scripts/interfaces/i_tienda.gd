@tool
extends Resource
class_name ITienda

##
# Interfaz para tiendas y puestos de comercio (contrato entre capas, M139 seccion 1).
# Implementar en recursos o nodos que expongan compra/venta (Shop, ShopManager, mercaderes).
#
# Creado 2026-10-14 por step-5-kilocode (encargo del director mimo, frente M139 Pre-Alpha):
# completaba el contrato de la seccion 1 del checklist, donde IInteractable ya existia
# pero ITienda/ITemplo/IViajable no. NO rompe consumidores: es superficie nueva.
#
# Convencion: todos los metodos devuelven false / vacio por defecto para que un
# implementador parcial no rompa el contrato (mismo patron que IInteractable v2).
#
# @see IInteractable, ITemplo, IViajable
# @see DOCUMENTACION/139-Pre-Alpha/plan-actual/05-Checklist.md (seccion 1)

## Compra `cantidad` unidades de `item_id` si hay stock, horario y saldo.
# @return true si la compra se concreto
func comprar(item_id: String, cantidad: int = 1) -> bool:
	return false

## Vende `cantidad` unidades de `item_id` a la tienda.
# @return true si la venta se concreto
func vender(item_id: String, cantidad: int = 1) -> bool:
	return false

## Precio unitario vigente del item (0 si no se vende aqui).
func precio_de(item_id: String) -> int:
	return 0

## Stock disponible del item.
func stock_de(item_id: String) -> int:
	return 0

## True si la tienda esta abierta en el dia/hora dados.
func esta_abierta(dia_semana: int, hora: int) -> bool:
	return false

## Identificador estable de la tienda (para persistencia y telemetria).
func id_tienda() -> String:
	return ""
