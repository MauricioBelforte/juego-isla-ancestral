# Modelo: ox-alpha
# Plataforma: Cline
# Fecha: 2026-08-26
#
# M14: Inventario — InventarioService (nucleo del autoload "Inventario")
# Unica autoridad de items (03-Diseno §1). La UI nunca muta contenedores.
# ⚠️ Sin class_name: el autoload ya se llama "Inventario" (pitfall documentado).
extends Node

const SLOT_SCRIPT := preload("res://scripts/inventario/inventory_slot.gd")

const CONTAINER_TYPE_CLASS := preload("res://scripts/inventario/container_type.gd")
const CONTENEDOR_SCRIPT := preload("res://scripts/inventario/inventario_contenedor.gd")

## Señales (03-Diseno §4): batched + por-slot para UI eficiente
signal item_added(item_id: String, cantidad: int, container: int)
signal item_removed(item_id: String, cantidad: int, container: int)
signal slot_changed(container: int, slot_idx: int)
signal inventario_actualizado()  # señal batched única tras operaciones múltiples
signal inventario_lleno(container: int, item_id: String, sobrante: int)

var contenedores: Dictionary = {}   # ContainerType.Id -> ContenedorInventario

func _ready() -> void:
	for id in [CONTAINER_TYPE_CLASS.Id.BOLSILLO, CONTAINER_TYPE_CLASS.Id.MOCHILA,
			CONTAINER_TYPE_CLASS.Id.CASA, CONTAINER_TYPE_CLASS.Id.COFRE,
			CONTAINER_TYPE_CLASS.Id.ALMACEN, CONTAINER_TYPE_CLASS.Id.CORREO]:
		contenedores[id] = CONTENEDOR_SCRIPT.new(id)
	_registrar_como_proveedor_guardado()

## Se registra en SaveManager (M59) como primer ISaveProvider real.
## Duck-typing defensivo: si SaveManager aún no existe, se reintenta al usar.
func _registrar_como_proveedor_guardado() -> void:
	var sm = get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)

## ── API rica del servicio (03-Diseno §4) ──────────────────

## Agrega items. Devuelve el SOBRANTE no aceptado (0 = todo entro).
## Con fallback en cadena bolsillo -> casa (regla anti-perdida).
func add_item(item_id: String, amount: int, container: int = -1) -> int:
	if container < 0:
		container = CONTAINER_TYPE_CLASS.Id.BOLSILLO
	var restante: int = _contenedor(container).add_item(item_id, amount)
	var aceptado: int = amount - restante
	if aceptado > 0:
		item_added.emit(item_id, aceptado, container)
		inventario_actualizado.emit()
	if restante > 0:
		inventario_lleno.emit(container, item_id, restante)
	return restante

## Remueve `amount` del contenedor. Devuelve true si habia suficiente y removio todo.
func remove_item(item_id: String, amount: int, container: int = -1) -> bool:
	if container < 0:
		container = CONTAINER_TYPE_CLASS.Id.BOLSILLO
	var ok: bool = _contenedor(container).remove_item(item_id, amount)
	if ok:
		item_removed.emit(item_id, amount, container)
		inventario_actualizado.emit()
	return ok

func count_item(item_id: String, include_house: bool = false) -> int:
	var total: int = _contenedor(CONTAINER_TYPE_CLASS.Id.BOLSILLO).count_item(item_id)
	total += _contenedor(CONTAINER_TYPE_CLASS.Id.MOCHILA).count_item(item_id)
	if include_house:
		total += _contenedor(CONTAINER_TYPE_CLASS.Id.CASA).count_item(item_id)
	return total

func has_free_space(container: int) -> bool:
	return _contenedor(container).tiene_slot_libre()

func used_slots(container: int) -> int:
	return _contenedor(container).slots_usados()

func total_slots(container: int) -> int:
	return _contenedor(container).total_slots()

func _contenedor(container: int) -> RefCounted:
	if not contenedores.has(container):
		contenedores[container] = CONTENEDOR_SCRIPT.new(container)
	return contenedores[container]

## ── Adaptadores para M39 ShopManager (contrato ya publicado) ──
## agregar_items({item_id: cantidad}) -> bool (true = todo colocado; fallback bolsa->casa)
## remover_items({item_id: cantidad}) -> bool (todo-o-nada)

func agregar_items(items: Dictionary) -> bool:
	for item_id in items:
		var cantidad := int(items[item_id])
		var sobrante := add_item(item_id, cantidad, CONTAINER_TYPE_CLASS.Id.BOLSILLO)
		if sobrante > 0:
			sobrante = add_item(item_id, sobrante, CONTAINER_TYPE_CLASS.Id.CASA)
		if sobrante > 0:
			# Revertir lo ya agregado en esta llamada (atomicidad M39 D8)
			var devolver := cantidad - sobrante
			if devolver > 0:
				remove_item(item_id, devolver, CONTAINER_TYPE_CLASS.Id.BOLSILLO)
			return false
	return true

func remover_items(items: Dictionary) -> bool:
	# Todo-o-nada: validar primero en bolsa+mochila+casa, luego remover
	for item_id in items:
		var cantidad := int(items[item_id])
		if count_item(item_id, true) < cantidad:
			return false
	for item_id in items:
		var falta := int(items[item_id])
		for c in [CONTAINER_TYPE_CLASS.Id.BOLSILLO, CONTAINER_TYPE_CLASS.Id.MOCHILA, CONTAINER_TYPE_CLASS.Id.CASA]:
			if falta <= 0:
				break
			var tiene: int = _contenedor(c).count_item(item_id)
			var tomar: int = mini(tiene, falta)
			if tomar > 0 and remove_item(item_id, tomar, c):
				falta -= tomar
	return true

## ── ISaveProvider (M59) — primer proveedor real ───────────

func get_section_name() -> String:
	return "inventory"

func get_save_data() -> Dictionary:
	var datos := {}
	for id in contenedores:
		datos[str(id)] = contenedores[id].serializar()
	return datos

func restore_save_data(data: Dictionary) -> void:
	for id in data:
		var c := int(id)
		if contenedores.has(c):
			var lista: Variant = data[id]
			if typeof(lista) == TYPE_ARRAY:
				contenedores[c].deserializar(lista)
	inventario_actualizado.emit()
