# Modelo: ox-alpha
# Plataforma: Cline
# Fecha: 2026-08-26
#
# M14: Inventario — ContenedorInventario (contenedor generico de slots)
# Add en DOS pasadas (skill godot-inventory-system):
#   pasada 1: llenar stacks parciales; pasada 2: slots vacios.
# Devuelve el SOBRANTE como int (nunca pierde items; fallback en cadena
# bolsillo -> casa -> mundo lo maneja el servicio).

class_name ContenedorInventario
extends RefCounted

## Señales para UI reactiva (solo emite cuando hay cambio real)
signal slot_changed(idx: int)

var tipo: int = ContainerType.Id.BOLSILLO
var slots: Array[InventorySlot] = []

func _init(p_tipo: int = ContainerType.Id.BOLSILLO, p_tamano: int = -1) -> void:
	tipo = p_tipo
	var n := p_tamano if p_tamano > 0 else int(ContainerType.TAMANOS.get(p_tipo, 24))
	for i in n:
		slots.append(InventorySlot.new())

func total_slots() -> int:
	return slots.size()

func slots_usados() -> int:
	var n := 0
	for s in slots:
		if not s.esta_libre():
			n += 1
	return n

## Stack maximo de un item segun ItemDatabase (fallback 99 si no hay DB/catalogo)
func _stack_max_de(item_id: String) -> int:
	var db = Engine.get_main_loop().root.get_node_or_null("/root/ItemDatabase")
	if db != null:
		var item = db.get_item(item_id)
		if item != null:
			return maxi(1, int(item.stack_max)) if bool(item.apilable) else 1
	return 99

## Agrega `cantidad` del item. Devuelve el SOBRANTE no aceptado.
## Dos pasadas + favoritos intactos + instancia solo en slot nuevo no apilable.
func add_item(item_id: String, cantidad: int, instancia: Dictionary = {}) -> int:
	if cantidad <= 0 or item_id == "":
		return cantidad
	var stack_max := _stack_max_de(item_id)
	var restante := cantidad

	# Pasada 1: completar stacks parciales del mismo item
	if stack_max > 1 and instancia.is_empty():
		for i in slots.size():
			if restante <= 0:
				break
			var s := slots[i]
			if not s.esta_libre() and s.item_id == item_id and not s.favorito:
				var cabe := stack_max - s.cantidad
				if cabe > 0:
					var tomar := mini(cabe, restante)
					s.cantidad += tomar
					restante -= tomar
					slot_changed.emit(i)

	# Pasada 2: slots vacios (no bloqueados, no favoritos vacios reservados)
	if restante > 0:
		for i in slots.size():
			if restante <= 0:
				break
			var s := slots[i]
			if s.esta_libre() and not s.bloqueado:
				var tomar := mini(stack_max, restante)
				s.ocupar(item_id, tomar, instancia if stack_max == 1 else {})
				restante -= tomar
				slot_changed.emit(i)

	return restante

## Remueve `cantidad` del item si existe suficiente. Devuelve true si removio todo.
func remove_item(item_id: String, cantidad: int) -> bool:
	if count_item(item_id) < cantidad:
		return false
	var falta := cantidad
	for i in range(slots.size() - 1, -1, -1):  # desde el final para conservar primeros slots
		var s := slots[i]
		if falta <= 0:
			break
		if s.item_id == item_id:
			var tomar := mini(s.cantidad, falta)
			s.cantidad -= tomar
			falta -= tomar
			if s.cantidad <= 0:
				s.vaciar()
			slot_changed.emit(i)
	return falta <= 0

func count_item(item_id: String) -> int:
	var n := 0
	for s in slots:
		if s.item_id == item_id:
			n += s.cantidad
	return n

func tiene_slot_libre() -> bool:
	for s in slots:
		if s.esta_libre() and not s.bloqueado:
			return true
	return false

## Serializa solo slots ocupados (ids + cantidades + instancia; skill save-load)
func serializar() -> Array:
	var out: Array = []
	for i in slots.size():
		var d := slots[i].serializar()
		if not d.is_empty():
			d["slot"] = i
			out.append(d)
	return out

func deserializar(lista: Array) -> void:
	for s in slots:
		s.vaciar()
	for d in lista:
		var idx := int(d.get("slot", -1))
		if idx >= 0 and idx < slots.size():
			var slot := InventorySlot.deserializar(d)
			# [64/164] Validar que el item_id exista en el catálogo
			if slot.item_id != "":
				var db = Engine.get_main_loop().root.get_node_or_null("/root/ItemDatabase")
				if db != null and db.get_item(slot.item_id) == null:
					push_warning("[M14-DOM-14] Item desconocido '%s' en slot %d, ignorado" % [slot.item_id, idx])
					continue
				if slot.cantidad <= 0:
					push_warning("[M14] Cantidad inválida (%d) para '%s' en slot %d, ignorado" % [slot.cantidad, slot.item_id, idx])
					continue
			slots[idx] = slot

## Valida que todas las cantidades sean legales (≥0, ≤stack_max).
## Devuelve la cantidad de slots corregidos.
func validate_quantities() -> int:
	var fixes := 0
	for s in slots:
		if s.esta_libre():
			continue
		if s.cantidad < 0:
			s.cantidad = 0
			s.vaciar()
			fixes += 1
			continue
		var stack_max := _stack_max_de(s.item_id)
		if s.cantidad > stack_max:
			s.cantidad = stack_max
			fixes += 1
	return fixes
