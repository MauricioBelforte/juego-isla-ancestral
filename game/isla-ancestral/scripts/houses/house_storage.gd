# Modelo: Atria-Dawn-Preview (atria-dawn-s2)
# Plataforma: Kilo Code
# Fecha: 2026-10-11
# M18: HouseStorage — contenedores domésticos (cofre, estantería) con transferencia M14.
# Sin acoplar UI: solo lógica de slots y señales.
extends Node
class_name HouseStorage

signal storage_changed(mueble_id: String)
signal contenedor_lleno(mueble_id: String)

var _contenedores: Dictionary = {}  # mueble_id -> Array[Dictionary] slots {item_id, cantidad}
var _capacidades: Dictionary = {}   # mueble_id -> int

## Registra un contenedor con su capacidad de slots.
func registrar_contenedor(mueble_id: String, capacidad: int) -> void:
	if capacidad <= 0:
		capacidad = 1
	if not _contenedores.has(mueble_id):
		_contenedores[mueble_id] = []
		_capacidades[mueble_id] = capacidad

## Abre un contenedor: devuelve el snapshot de slots (contrato lectura).
func abrir(mueble_id: String) -> Dictionary:
	return {
		"mueble_id": mueble_id,
		"slots": _contenedores.get(mueble_id, []),
		"capacidad": int(_capacidades.get(mueble_id, 0)),
	}

## Cierra la vista (hook para limpieza; sin UI aquí).
func cerrar() -> void:
	pass

## Transfiere un slot del contenedor al inventario del jugador (M14).
## Devuelve la cantidad realmente transferida.
func transferir_a_inventario(mueble_id: String, idx: int, cantidad: int) -> int:
	var slots: Array = _contenedores.get(mueble_id, [])
	if idx < 0 or idx >= slots.size():
		return 0
	var slot: Dictionary = slots[idx]
	var item_id: String = String(slot.get("item_id", ""))
	var disponible: int = int(slot.get("cantidad", 0))
	if item_id.is_empty() or disponible <= 0 or cantidad <= 0:
		return 0
	var a_mover: int = mini(cantidad, disponible)
	var inv = _get_inventario()
	if inv == null:
		return 0
	if inv.has_method("add_item"):
		inv.add_item(item_id, a_mover)
	else:
		return 0
	disponible -= a_mover
	if disponible <= 0:
		slots.remove_at(idx)
	else:
		slots[idx] = {"item_id": item_id, "cantidad": disponible}
	_contenedores[mueble_id] = slots
	storage_changed.emit(mueble_id)
	return a_mover

## Transfiere items del inventario del jugador (M14) a un contenedor.
## Devuelve la cantidad realmente guardada.
func transferir_desde_inventario(mueble_id: String, item_id: String, cantidad: int) -> int:
	if item_id.is_empty() or cantidad <= 0:
		return 0
	var inv = _get_inventario()
	if inv == null:
		return 0
	if inv.has_method("count_item"):
		if int(inv.count_item(item_id)) < cantidad:
			return 0
	var slots: Array = _contenedores.get(mueble_id, [])
	var capacidad: int = int(_capacidades.get(mueble_id, 0))
	# ¿Slot existente del mismo item?
	var idx_existente := -1
	for i in slots.size():
		if String(slots[i].get("item_id", "")) == item_id:
			idx_existente = i
			break
	if idx_existente >= 0:
		var slot: Dictionary = slots[idx_existente]
		slot["cantidad"] = int(slot.get("cantidad", 0)) + cantidad
		slots[idx_existente] = slot
	elif slots.size() >= capacidad:
		contenedor_lleno.emit(mueble_id)
		return 0
	else:
		slots.append({"item_id": item_id, "cantidad": cantidad})
	if inv.has_method("remove_item"):
		inv.remove_item(item_id, cantidad)
	_contenedores[mueble_id] = slots
	storage_changed.emit(mueble_id)
	return cantidad

## Extraer todo el contenido de un contenedor (para mudanzas).
## No descuenta del inventario: devuelve los items.
func extraer_contenido(mueble_id: String) -> Array:
	var slots: Array = _contenedores.get(mueble_id, [])
	var copia: Array = slots.duplicate(true)
	slots.clear()
	_contenedores[mueble_id] = slots
	storage_changed.emit(mueble_id)
	return copia

## ¿El contenedor está lleno?
func esta_lleno(mueble_id: String) -> bool:
	var slots: Array = _contenedores.get(mueble_id, [])
	var capacidad: int = int(_capacidades.get(mueble_id, 0))
	return slots.size() >= capacidad

## Cantidad de items totales en un contenedor.
func cantidad_items(mueble_id: String) -> int:
	var total := 0
	for slot in _contenedores.get(mueble_id, []):
		total += int(slot.get("cantidad", 0))
	return total

## Estado completo para guardado (M58/M60).
func recolectar_estado() -> Dictionary:
	return _contenedores.duplicate(true)

## Restaura el estado desde guardado.
func restaurar_estado(datos: Dictionary) -> void:
	_contenedores = datos.duplicate(true)

func _get_inventario() -> Node:
	return get_node_or_null("/root/Inventario")
