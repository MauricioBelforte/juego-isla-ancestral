# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-08-31
#
# M38: Economía — BarterSystem (autoload "Barter")
# Trueque objeto-por-objeto SIN moneda (03-Diseno §2.3/§3.4, checklist H):
#  - propuestas_disponibles(npc_id): filtra por amistad mínima (M20), temporada
#    (M29) y límite diario; el salvavidas (RF12) siempre está disponible.
#  - ejecutar_trueque(npc_id, oferta_id): validación completa + intercambio
#    atómico vía Inventario (M14 todo-o-nada) con rollback si no entra lo
#    recibido. Jamás toca monedas (trueque = sin moneda, RF7).
#  - límites diarios por npc_id reseteados por dia_absoluto (M29/M30).
#  - Persistencia ISaveProvider (M59): sección "barter" {dia, usos}.
#  - Señales: trueque_exitoso(npc_id, oferta_id, entregado, recibido) /
#    trueque_rechazado(motivo). Log DOM-ECO-TRUEQUE (convención del proyecto).
# ⚠️ Sin class_name: es autoload (pitfall documentado 07-GUIA-GODOT §9.17/§9.41).
extends Node

## Directorio de ofertas (una BarterOffer .tres por propuesta)
const DIR_OFERTAS: String = "res://data/economia/barter"
## Límite diario por NPC cuando la oferta no define uno propio
const LIMITE_DIARIO_DEFAULT: int = 2

signal trueque_exitoso(npc_id: String, oferta_id: StringName, entregado: Dictionary, recibido: Dictionary)
signal trueque_rechazado(motivo: String)

## Ofertas cargadas: oferta_id -> BarterOffer
var _ofertas: Dictionary = {}
## Usos del día actual: npc_id -> count
var _usos: Dictionary = {}
## Día absoluto en que se registraron los usos (reset automático)
var _dia_usos: int = -1


func _ready() -> void:
	_cargar_ofertas()
	_registrar_proveedor_guardado()


func _cargar_ofertas() -> void:
	_ofertas.clear()
	var dir := DirAccess.open(DIR_OFERTAS)
	if dir == null:
		push_warning("[M38] Directorio de trueques no encontrado: %s" % DIR_OFERTAS)
		return
	for archivo in dir.get_files():
		if not archivo.ends_with(".tres"):
			continue
		var oferta := load(DIR_OFERTAS + "/" + archivo) as BarterOffer
		if oferta == null or oferta.oferta_id == &"":
			push_warning("[M38] oferta inválida ignorada: %s" % archivo)
			continue
		_ofertas[oferta.oferta_id] = oferta


func _registrar_proveedor_guardado() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)


## ── API pública (03-Diseno §3.4) ─────────────────────────

func ofertas_count() -> int:
	return _ofertas.size()


## Propuestas visibles para un NPC: amistad OK + temporada OK + usos pendientes.
## El salvavidas (RF12) siempre aparece.
func propuestas_disponibles(npc_id: String) -> Array[BarterOffer]:
	_asegurar_dia()
	var result: Array[BarterOffer] = []
	var amistad := _amistad_nivel(npc_id)
	var estacion := _estacion_actual()
	for oferta in _ofertas.values():
		if oferta.npc_id != "" and oferta.npc_id != npc_id:
			continue
		if not oferta.es_salvavidas:
			if oferta.amistad_minima > amistad:
				continue
			if oferta.estaciones.size() > 0 and not oferta.estaciones.has(estacion):
				continue
			if usos_hoy(npc_id) >= _limite_de(oferta):
				continue
		result.append(oferta)
	return result


## Ejecuta el trueque: valida y hace el intercambio atómico vía M14.
## Devuelve {ok: bool, motivo: String}.
func ejecutar_trueque(npc_id: String, oferta_id: StringName) -> Dictionary:
	_asegurar_dia()
	var oferta := _ofertas.get(oferta_id, null) as BarterOffer
	if oferta == null:
		var m := "oferta inexistente: %s" % oferta_id
		trueque_rechazado.emit(m)
		return {"ok": false, "motivo": m}
	if oferta.npc_id != "" and oferta.npc_id != npc_id:
		var m := "oferta de otro NPC: %s" % npc_id
		trueque_rechazado.emit(m)
		return {"ok": false, "motivo": m}
	if not oferta.es_salvavidas:
		if oferta.amistad_minima > _amistad_nivel(npc_id):
			var m := "amistad insuficiente (requiere %d)" % oferta.amistad_minima
			trueque_rechazado.emit(m)
			return {"ok": false, "motivo": m}
		if oferta.estaciones.size() > 0 and not oferta.estaciones.has(_estacion_actual()):
			var m := "temporada inválida"
			trueque_rechazado.emit(m)
			return {"ok": false, "motivo": m}
		if usos_hoy(npc_id) >= _limite_de(oferta):
			var m := "límite diario alcanzado"
			trueque_rechazado.emit(m)
			return {"ok": false, "motivo": m}
	# Intercambio atómico vía M14: primero verificar, luego remover todo-o-nada,
	# y si lo recibido no entra, rollback de lo pedido.
	var inv := get_node_or_null("/root/Inventario")
	if inv == null:
		var m := "inventario no disponible"
		trueque_rechazado.emit(m)
		return {"ok": false, "motivo": m}
	for item_id in oferta.pedido:
		if inv.count_item(String(item_id)) < int(oferta.pedido[item_id]):
			var m := "items insuficientes: %s" % item_id
			trueque_rechazado.emit(m)
			return {"ok": false, "motivo": m}
	if not inv.remover_items(oferta.pedido):
		var m := "no se pudo remover el pedido"
		trueque_rechazado.emit(m)
		return {"ok": false, "motivo": m}
	if not inv.agregar_items(oferta.entregado):
		inv.agregar_items(oferta.pedido)  # rollback cozy: nunca se pierde
		var m := "espacio insuficiente para lo recibido"
		trueque_rechazado.emit(m)
		return {"ok": false, "motivo": m}
	if not oferta.es_salvavidas:
		_usos[npc_id] = usos_hoy(npc_id) + 1
	print("[DOM-ECO-TRUEQUE] %s ok %s pedido=%s entregado=%s" % [npc_id, oferta_id, oferta.pedido, oferta.entregado])
	trueque_exitoso.emit(npc_id, oferta_id, oferta.pedido.duplicate(), oferta.entregado.duplicate())
	return {"ok": true, "motivo": ""}


## Límite diario vigente para el NPC (oferta específica o default)
func limite_diario(npc_id: String) -> int:
	var maximo := LIMITE_DIARIO_DEFAULT
	for oferta in _ofertas.values():
		if oferta.npc_id == npc_id and oferta.limite_diario > 0:
			maximo = maxi(maximo, oferta.limite_diario)
	return maximo


## Usos de hoy por NPC (los salvavidas no consumen límite)
func usos_hoy(npc_id: String) -> int:
	_asegurar_dia()
	return int(_usos.get(npc_id, 0))


## ── Internos ─────────────────────────────────────────────

func _amistad_nivel(npc_id: String) -> int:
	var fs := get_node_or_null("/root/Friendship")
	if fs == null or not fs.has_method("get_nivel"):
		return 0
	return int(fs.get_nivel(npc_id))


func _estacion_actual() -> int:
	var cal := get_node_or_null("/root/TimeCalendar")
	if cal != null and cal.has_method("get_estacion"):
		return int(cal.get_estacion())
	var gt := get_node_or_null("/root/GameTime")
	if gt != null and gt.has_method("get_estacion"):
		return int(gt.get_estacion())
	return 0


func _limite_de(oferta: BarterOffer) -> int:
	return oferta.limite_diario if oferta.limite_diario > 0 else LIMITE_DIARIO_DEFAULT


func _asegurar_dia() -> void:
	var dia := _dia_absoluto()
	if dia != _dia_usos:
		_dia_usos = dia
		_usos.clear()


func _dia_absoluto() -> int:
	var gt := get_node_or_null("/root/GameTime")
	if gt != null and gt.has_method("dia_absoluto"):
		return int(gt.dia_absoluto())
	var cal := get_node_or_null("/root/TimeCalendar")
	if cal != null and cal.has_method("get_dia_absoluto"):
		return int(cal.get_dia_absoluto())
	return 1


## ── Persistencia (ISaveProvider M59) ─────────────────────

func get_section_name() -> String:
	return "barter"


func get_save_data() -> Dictionary:
	_asegurar_dia()
	return {"dia": _dia_usos, "usos": _usos.duplicate()}


func restore_save_data(data: Dictionary) -> void:
	_dia_usos = int(data.get("dia", -1))
	_usos.clear()
	var u: Dictionary = data.get("usos", {})
	for k in u:
		_usos[String(k)] = int(u[k])
