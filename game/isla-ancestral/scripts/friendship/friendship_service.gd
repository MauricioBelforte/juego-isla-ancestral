# Modelo: ox-alpha
# Plataforma: Cline
# Fecha: 2026-08-26
#
# M20: Amistad — FriendshipService (autoload "Friendship")
# Unica autoridad del estado de amistad por vecino. Evalúa regalos
# (GiftEvaluator), registra charlas/envía cartas, aplica puntos, resuelve
# subidas de nivel y emite sobre EventBus (M07 dominio NPC):
#   EventBus.npc.friendship_level_up(npc_id, new_level)
#   EventBus.npc.gift_given(npc_id, item_id, liked)
# Proveedor de guardado (M59): sección "friendship".
# ⚠️ Sin class_name: es autoload (pitfall documentado). GiftEvaluator/VecinoAmistad son class_name.
extends Node

const EVALUADOR_SCRIPT := preload("res://scripts/friendship/gift_evaluator.gd")
const VECINO_SCRIPT := preload("res://scripts/friendship/vecino_amistad.gd")

## Recompensas por nivel de ejemplo.
const RECOMPENSAS_NIVEL := {
	2: ["receta_herramienta_basica"],
	3: ["decorativo_estatua"],
	5: ["receta_comida_gourmet"],
	8: ["decorativo_fuente"],
}

signal regalo_entregado(vecino_id: String, item_id: String, clase: int, puntos: int)
signal charla_realizada(vecino_id: String, puntos: int)
signal carta_enviada(vecino_id: String, texto_id: String)
signal nivel_subido(vecino_id: String, nivel: int)
signal evento_celebrado(evento_id: String, participantes: Array)

var _vecinos: Dictionary = {}   # vecino_id -> VecinoAmistad
var _dia: int = 0

func _ready() -> void:
	_sincronizar_con_game_time()
	_registrar_como_proveedor_guardado()

## Sincroniza el día de los límites diarios con GameTime (M29), usando
## dia_absoluto() (monótono). Fallback: día manual por set_dia/pivote_dia
## (tests fuera de árbol o sin M29).
func _sincronizar_con_game_time() -> void:
	var gt = get_node_or_null("/root/GameTime")
	if gt != null and gt.has_method("dia_absoluto"):
		_dia = gt.dia_absoluto()
		if gt.has_signal("dia_cambio"):
			gt.dia_cambio.connect(_on_dia_game_time)

func _on_dia_game_time(_info: Dictionary) -> void:
	var gt = get_node_or_null("/root/GameTime")
	if gt != null and gt.has_method("dia_absoluto"):
		_dia = gt.dia_absoluto()

func _registrar_como_proveedor_guardado() -> void:
	var sm = get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)

func pivote_dia(dia: int) -> void:
	_dia = dia

func set_dia(dia: int) -> void:
	_dia = dia

## ── Vecinos ───────────────────────────────────────────────

## Registra a un vecino (lo invoca M19 al mudarse). Idempotente.
func registrar_vecino(vecino_id: String) -> void:
	if vecino_id == "" or _vecinos.has(vecino_id):
		return
	_vecinos[vecino_id] = VECINO_SCRIPT.new(vecino_id)

## Asegura que un vecino exista (crea si llega una acción sin registro previo).
func _vecino(vecino_id: String) -> VecinoAmistad:
	if not _vecinos.has(vecino_id):
		_vecinos[vecino_id] = VECINO_SCRIPT.new(vecino_id)
	return _vecinos[vecino_id]

func vecinos() -> Array:
	return _vecinos.keys()

## ── Consultas (API J) ─────────────────────────────────────
func get_nivel(vecino_id: String) -> int:
	return _vecino(vecino_id).get_nivel()

func get_puntos(vecino_id: String) -> int:
	return _vecino(vecino_id).get_puntos()

func get_progreso(vecino_id: String) -> Dictionary:
	return _vecino(vecino_id).get_progreso()

func get_limite_dia(vecino_id: String, tipo: String) -> Dictionary:
	return _vecino(vecino_id).get_limite_dia(tipo)

func get_memoria(vecino_id: String) -> Array:
	return _vecino(vecino_id).get_memoria()

func get_recompensas_pendientes(vecino_id: String) -> Array:
	return _vecino(vecino_id).get_recompensas_pendientes()
## ── Acciones ──────────────────────────────────────────────

## Regalar. Devuelve Dictionary con resultado o motivo de rechazo.
func regalar(vecino_id: String, item_id: String) -> Dictionary:
	var v := _vecino(vecino_id)
	if not v.intentar_usar_limite("regalo", _dia):
		return {"ok": false, "motivo": "limite_diario"}
	var inv = get_node_or_null("/root/Inventario")
	var item_meta = _get_item_meta(item_id)
	if inv != null:
		if not bool(inv.remover_items({item_id: 1})):
			return {"ok": false, "motivo": "sin_item"}
	var vecino_data := _get_vecino_data(vecino_id)
	var evaluacion: Dictionary = EVALUADOR_SCRIPT.evaluar(vecino_data, item_meta, v.ha_regalado(item_id))
	var puntos := int(evaluacion["puntos"])
	var clase := int(evaluacion["clase"])
	v.registrar_regalo(item_id)
	var subio := v.aplicar_puntos(puntos, RECOMPENSAS_NIVEL)
	regalo_entregado.emit(vecino_id, item_id, clase, puntos)
	_emitir_npc_events(vecino_id, item_id, clase)
	if subio:
		nivel_subido.emit(vecino_id, v.get_nivel())
	_emitir_level_up(vecino_id, v.get_nivel())
	return {"ok": true, "clase": clase, "puntos": puntos, "nivel": v.get_nivel()}

## Charla diaria: 5 + 1 por nivel (max +10).
func charlar(vecino_id: String) -> Dictionary:
	var v := _vecino(vecino_id)
	if not v.intentar_usar_limite("charla", _dia):
		return {"ok": false, "motivo": "limite_diario"}
	var puntos := 5 + mini(v.get_nivel() - 1, 10)
	var subio := v.aplicar_puntos(puntos, RECOMPENSAS_NIVEL)
	charla_realizada.emit(vecino_id, puntos)
	if subio and v.get_nivel() > 1:
		_emitir_level_up(vecino_id, v.get_nivel())
	return {"ok": true, "clase": -1, "puntos": puntos, "nivel": v.get_nivel()}

## Enviar carta: límite 1/día, 8 puntos (placeholder de respuesta M21/M29).
func enviar_carta(vecino_id: String, texto_id: String) -> Dictionary:
	var v := _vecino(vecino_id)
	if not v.intentar_usar_limite("carta", _dia):
		return {"ok": false, "motivo": "limite_diario"}
	var subio := v.aplicar_puntos(8, RECOMPENSAS_NIVEL)
	carta_enviada.emit(vecino_id, texto_id)
	if subio and v.get_nivel() > 1:
		_emitir_level_up(vecino_id, v.get_nivel())
	return {"ok": true, "clase": -1, "puntos": 8, "nivel": v.get_nivel()}

func reclamar_recompensa(vecino_id: String, reward_id: String) -> bool:
	return _vecino(vecino_id).reclamar_recompensa(reward_id)

## ── Internos ──────────────────────────────────────────────
func _emitir_npc_events(vecino_id: String, item_id: String, clase: int) -> void:
	var bus = get_node_or_null("/root/EventBus")
	if bus == null:
		return
	var liked := clase >= EVALUADOR_SCRIPT.Clase.GUSTA
	if bus.npc != null:
		bus.npc.gift_given.emit(vecino_id, item_id, liked)

func _emitir_level_up(vecino_id: String, nuevo_nivel: int) -> void:
	var bus = get_node_or_null("/root/EventBus")
	if bus != null and bus.npc != null:
		bus.npc.friendship_level_up.emit(vecino_id, nuevo_nivel)

func _get_vecino_data(_vecino_id: String) -> Node:
	return null  # placeholder M19 (VecinoData) — sin él, evaluación neutral

func _get_item_meta(item_id: String):
	var db = get_node_or_null("/root/ItemDatabase")
	if db == null or not db.has_method("get_item"):
		return null
	return db.get_item(item_id)

## ── Persistencia (ISaveProvider M59) ──────────────────────
func get_section_name() -> String:
	return "friendship"

func get_save_data() -> Dictionary:
	var datos := {}
	for vid in _vecinos:
		datos[vid] = _vecinos[vid].serializar()
	return {"vecinos": datos, "dia": _dia}

func restore_save_data(data: Dictionary) -> void:
	_vecinos.clear()
	var vdata: Dictionary = data.get("vecinos", {})
	for vid in vdata:
		var v := VECINO_SCRIPT.new(str(vid))
		v.deserializar(vdata[vid])
		_vecinos[str(vid)] = v
	_dia = int(data.get("dia", 0))