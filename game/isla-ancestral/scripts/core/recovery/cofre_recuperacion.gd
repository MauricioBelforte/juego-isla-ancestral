# Modelo: ox-alpha (Cline)
# Plataforma: Cline
# Fecha: 2026-08-25
#
# M66: Anti-Softlock — Cofre de Recuperación
# Catálogo de objetos únicos recuperados. 1 copia inmutable por clave. Jamás duplicable.

# Modelo: ox-alpha (Cline)
# Plataforma: Cline
# Fecha: 2026-08-25
#
# M66: Anti-Softlock — Cofre de Recuperación
# Catálogo de objetos únicos recuperados. 1 copia inmutable por clave. Jamás duplicable.

## Cofre de recuperación: entrega cada objeto único recuperado una sola vez.
## Extiende Node (no Node3D) para poder ser child del autoload SoftlockGuard.
## El cofre físico 3D en el mundo se instancia como escena hija separada.
class_name CofreRecuperacion
extends Node

## Slot máximo de ítems
const MAX_SLOTS: int = 12

## Índice serializado: clave -> { entregado: bool, slot: int }
var indice: Dictionary = {}

## Inventario de slots (clave -> item identifier)
var _slots: Array[Dictionary] = []

func _init() -> void:
	for i in MAX_SLOTS:
		_slots.append({})

## Devuelve true si hay un slot disponible para esta clave.
func slot_disponible(clave: String) -> bool:
	if indice.has(clave) and indice[clave].get("entregado", false):
		return false  # Ya se entregó, no duplica
	for slot in _slots:
		if slot.is_empty():
			return true
	return false

## Devuelve true si la clave ya fue entregada (no duplicable jamás).
func fue_entregada(clave: String) -> bool:
	return indice.has(clave) and indice[clave].get("entregado", false)

## Deposita un objeto recuperado en el cofre (marca la clave).
## La copia es inmutable: al entregarse, se marca "entregado" y el slot queda vacío.
func depositar(clave: String, item_id: String) -> bool:
	if indice.has(clave) and indice[clave].get("entregado", false):
		return false  # Jamás duplicar
	for i in range(MAX_SLOTS):
		if _slots[i].is_empty():
			_slots[i] = {"clave": clave, "item_id": item_id}
			indice[clave] = {"entregado": false, "slot": i}
			return true
	return false  # Cofre lleno

## Entrega el objeto al jugador (1 sola vez). Marca "entregado" y libera el slot.
func entregar(clave: String) -> bool:
	if not indice.has(clave):
		return false
	if indice[clave].get("entregado", false):
		return false  # Solo una vez
	var slot_idx := int(indice[clave].get("slot", -1))
	if slot_idx < 0 or slot_idx >= MAX_SLOTS:
		return false
	_slots[slot_idx] = {}  # Libera slot (inmutable: no se vuelve a depositar)
	indice[clave]["entregado"] = true
	return true

## Serializa el índice para el guardado.
func serializar_indice() -> Dictionary:
	return indice.duplicate(true)

## Deserializa el índice desde el guardado.
func deserializar_indice(data: Dictionary) -> void:
	indice = data.duplicate(true)
	# Reconstruir slots a partir del índice
	_slots.clear()
	for i in MAX_SLOTS:
		_slots.append({})
	for clave in indice.keys():
		var slot_idx := int(indice[clave].get("slot", -1))
		if slot_idx >= 0 and slot_idx < MAX_SLOTS and not indice[clave].get("entregado", false):
			_slots[slot_idx] = {"clave": clave, "item_id": ""}

