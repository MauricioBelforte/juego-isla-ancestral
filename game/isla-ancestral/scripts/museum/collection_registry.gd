# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01 (iter. 1-2) / 2026-09-02 (iter. 3)
#
# M37: Museos y Colecciones — CollectionRegistry (autoload "CollectionRegistry")
# Única autoridad de progreso (03-Diseno §2.1):
#  - Qué piezas están registradas en cada exposición y qué recompensas se otorgaron.
#  - Emite item_registered / exhibition_completed (una sola vez, marca guardada).
#  - Persistencia ISaveProvider M59: sección "collections".
#  - Exposiciones data-driven en data/museum/exhibiciones.json (M34 pesca
#    capturada, M25 fósiles, M15/M33 flora — piezas físicas del inventario).
# Iter. 3 (glm-5.3-flash 2026-09-02, Log 542):
#  - Toast no bloqueante al completar exposición vía EventBus.notify (RF6).
#  - validar_catalogo() con errores accionables (headless-friendly, RF14).
#  - API panel M53: get_resumen_para_ui() (cartel de entrada §7) +
#    exposiciones_completas_count().
#  - RF2: exposición fauna con especies reales de M36 (data-driven).
# ⚠️ Sin class_name: es autoload (pitfall 07-GUIA-GODOT §9.17/§9.41).
extends Node

signal item_registered(exhibition_id: String, item_id: String)
signal exhibition_completed(exhibition_id: String)

## id_exposicion -> {nombre, categoria, items: Array[String], recompensa_item_id, recompensa_nombre}
var _exposiciones: Dictionary = {}
## id_exposicion -> Array[String] de items registrados
var _registradas: Dictionary = {}
## id_exposicion -> true si la recompensa ya se otorgó (idempotencia §4.2)
var _recompensas: Dictionary = {}


func _ready() -> void:
	_cargar_exposiciones()
	_registrar_proveedor_guardado()
	# RF14: validación accionable en arranque
	var problemas := validar_catalogo()
	if problemas > 0:
		push_warning("[M37][RF14] Catálogo con %d problema(s)" % problemas)


func _cargar_exposiciones() -> void:
	_exposiciones.clear()
	var texto := FileAccess.get_file_as_string("res://data/museum/exhibiciones.json")
	var parseado: Variant = JSON.parse_string(texto)
	if typeof(parseado) != TYPE_DICTIONARY:
		push_error("[M37] exhibiciones.json inválido")
		return
	for exp in parseado.get("exposiciones", []):
		var id := String(exp.get("id", ""))
		if id.is_empty():
			continue
		var items: Array[String] = []
		for it in exp.get("items", []):
			items.append(String(it))
		_exposiciones[id] = {
			"nombre": String(exp.get("nombre", id)),
			"descripcion": String(exp.get("descripcion", "")),
			"categoria": String(exp.get("categoria", "pedestal")),
			"origen": String(exp.get("origen", "")),
			"items": items,
			"recompensa_item_id": String(exp.get("recompensa_item_id", "")),
			"recompensa_nombre": String(exp.get("recompensa_nombre", "")),
		}
	print("[M37] Exposiciones cargadas: %d" % _exposiciones.size())


func _registrar_proveedor_guardado() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)


## ── API pública (03-Diseno §5) ──────────────────────────

func exposiciones_count() -> int:
	return _exposiciones.size()


func pertenece(exhibition_id: String, item_id: String) -> bool:
	var exp: Dictionary = _exposiciones.get(exhibition_id, {})
	return String(item_id) in exp.get("items", [])


func register_item(exhibition_id: String, item_id: String) -> bool:
	# §4.4.3: si ya está registrado, la operación es no-op idempotente
	if is_registered(exhibition_id, item_id):
		return false
	if not _exposiciones.has(exhibition_id):
		return false
	if not _registradas.has(exhibition_id):
		_registradas[exhibition_id] = []
	_registradas[exhibition_id].append(String(item_id))
	item_registered.emit(exhibition_id, String(item_id))
	# §4.2: exposición completa → una sola vez (marca guardada)
	if is_exhibition_completed(exhibition_id) and not is_reward_claimed(exhibition_id):
		exhibition_completed.emit(exhibition_id)
		# RF6 iter. 3: toast no bloqueante (cola/presentación dueño M53)
		_emitir_toast_completada(exhibition_id)
	return true


func _emitir_toast_completada(exhibition_id: String) -> void:
	var bus := get_node_or_null("/root/EventBus")
	# La señal notify vive en el dominio interno UIEvents (bus.ui), no en la raíz
	if bus == null or bus.ui == null or not bus.ui.has_signal("notify"):
		return
	var nombre := String(_exposiciones.get(exhibition_id, {}).get("nombre", exhibition_id))
	var recompensa := String(_exposiciones.get(exhibition_id, {}).get("recompensa_nombre", ""))
	bus.ui.notify.emit({
		"tipo": "museo",
		"id": exhibition_id,
		"titulo": "Exposición completa: " + nombre,
		"texto": "Recompensa disponible: " + (recompensa if recompensa != "" else "especial del museo"),
	})


func is_registered(exhibition_id: String, item_id: String) -> bool:
	return _registradas.has(exhibition_id) and String(item_id) in _registradas[exhibition_id]


func is_exhibition_completed(exhibition_id: String) -> bool:
	var exp: Dictionary = _exposiciones.get(exhibition_id, {})
	if exp.is_empty():
		return false
	for item_id in exp.get("items", []):
		if not is_registered(exhibition_id, String(item_id)):
			return false
	return true


func get_registered(exhibition_id: String) -> Array:
	return (_registradas.get(exhibition_id, []) as Array).duplicate()


## Progreso de una exposición: {registered, total, percent}
func get_exhibition_progress(exhibition_id: String) -> Dictionary:
	var exp: Dictionary = _exposiciones.get(exhibition_id, {})
	var total: int = (exp.get("items", []) as Array).size()
	var reg: int = get_registered(exhibition_id).size()
	var percent := 0.0
	if total > 0:
		percent = float(reg) / float(total)
	return {"registered": reg, "total": total, "percent": percent}


## Progreso global del museo (cartel de entrada, §7)
func get_total_progress() -> float:
	var total := 0
	var reg := 0
	for id in _exposiciones:
		var p: Dictionary = get_exhibition_progress(String(id))
		total += int(p.get("total", 0))
		reg += int(p.get("registered", 0))
	if total == 0:
		return 0.0
	return float(reg) / float(total)


## ── Iter. 3: API panel M53 (cartel de entrada §7) ───────

func exposiciones_completas_count() -> int:
	var n := 0
	for id in _exposiciones:
		if is_exhibition_completed(String(id)):
			n += 1
	return n


## Resumen para el cartel de entrada y el panel del museo (M53)
func get_resumen_para_ui() -> Dictionary:
	var lista: Array[Dictionary] = []
	for id in _exposiciones:
		var exp: Dictionary = _exposiciones[id]
		var p := get_exhibition_progress(String(id))
		lista.append({
			"id": String(id),
			"nombre": String(exp.get("nombre", "")),
			"descripcion": String(exp.get("descripcion", "")),
			"hecha": is_exhibition_completed(String(id)),
			"progreso": "%d de %d" % [int(p.get("registered", 0)), int(p.get("total", 0))],
			"percent": float(p.get("percent", 0.0)),
			"recompensa": String(exp.get("recompensa_nombre", "")),
			"recompensa_entregada": is_reward_claimed(String(id)),
		})
	return {
		"percent_global": get_total_progress(),
		"completas": exposiciones_completas_count(),
		"total_exposiciones": _exposiciones.size(),
		"exposiciones": lista,
	}


## ── RF14: Validación de catálogo (errores accionables) ──

func validar_catalogo() -> int:
	"""RF14: devuelve cantidad de problemas; imprime cada uno accionable."""
	var problemas := 0
	var vistos := {}
	var texto := FileAccess.get_file_as_string("res://data/museum/exhibiciones.json")
	var parseado: Variant = JSON.parse_string(texto)
	var entradas: Array = parseado.get("exposiciones", []) if typeof(parseado) == TYPE_DICTIONARY else []
	for exp in entradas:
		var id := String(exp.get("id", ""))
		if id.is_empty():
			problemas += 1
			print("[M37][RF14] Problema: exposición sin 'id'")
			continue
		if vistos.has(id):
			problemas += 1
			print("[M37][RF14] Problema: id duplicado '%s' — renombrar" % id)
		vistos[id] = true
		var items: Array = exp.get("items", [])
		if items.is_empty():
			problemas += 1
			print("[M37][RF14] Problema: '%s' sin items — agregar piezas" % id)
		var recompensa := String(exp.get("recompensa_item_id", ""))
		if recompensa == "" and String(exp.get("recompensa_nombre", "")) != "":
			problemas += 1
			print("[M37][RF14] Problema: '%s' recompensa sin recompensa_item_id" % id)
	if problemas == 0:
		print("[M37][RF14] Catálogo OK: %d exposiciones, 0 problemas" % _exposiciones.size())
	return problemas


## Recompensa única (idempotente): marca y devuelve el ítem de recompensa
func otorgar_recompensa(exhibition_id: String) -> String:
	if not is_exhibition_completed(exhibition_id):
		return ""
	if is_reward_claimed(exhibition_id):
		return ""  # §4.2.4: nunca doble recompensa
	_exposiciones[exhibition_id]["recompensa_otorgada"] = true
	_recompensas[exhibition_id] = true
	var inv := get_node_or_null("/root/Inventario")
	var item := String(_exposiciones[exhibition_id].get("recompensa_item_id", ""))
	if inv != null and item != "":
		inv.agregar_items({item: 1})
	return item


func mark_reward_claimed(exhibition_id: String) -> void:
	_recompensas[exhibition_id] = true


func is_reward_claimed(exhibition_id: String) -> bool:
	return _recompensas.has(exhibition_id)


## Lista de piezas DONABLES de una exposición: no registradas + presentes
## en el inventario del jugador (para la UI de donación §4.1.2)
func donables_pendientes(exhibition_id: String) -> Array[String]:
	var result: Array[String] = []
	var inv := get_node_or_null("/root/Inventario")
	var exp: Dictionary = _exposiciones.get(exhibition_id, {})
	for item_id in exp.get("items", []):
		var iid := String(item_id)
		if is_registered(exhibition_id, iid):
			continue
		if inv != null and inv.count_item(iid) > 0:
			result.append(iid)
	return result


## ── Persistencia (M59, §8: bloque único atómico) ────────

func get_section_name() -> String:
	return "collections"


func get_save_data() -> Dictionary:
	var piezas := {}
	for id in _registradas:
		piezas[String(id)] = get_registered(String(id))
	return {
		"piezas": piezas,
		"recompensas": _recompensas.keys(),
	}


func restore_save_data(data: Dictionary) -> void:
	_registradas.clear()
	var piezas: Dictionary = data.get("piezas", {})
	for id in piezas:
		if _exposiciones.has(String(id)):
			var lista: Array[String] = []
			for p in piezas[id]:
				lista.append(String(p))
			_registradas[String(id)] = lista
		else:
			print("[M37] Huérfana ignorada al cargar: exposición %s" % String(id))
	_recompensas.clear()
	for r in data.get("recompensas", []):
		_recompensas[String(r)] = true
