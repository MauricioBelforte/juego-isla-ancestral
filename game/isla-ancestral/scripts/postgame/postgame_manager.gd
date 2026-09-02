# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M75: Postgame — PostgameManager (autoload "Postgame", diseño RF1 + M94).
#  - Detección del fin de la historia vía M22 (Historia) — M22 es la fuente
#    de verdad §2.2: 7 sellos marcados o final elegido → postgame activo.
#  - "¿Qué sigue?" tras créditos (RF1): actividades postgame data-driven
#    (data/postgame/actividades.json) con dueños por módulo; sugerencias
#    ROTATIVAS por día M29 (ignorables, sin FOMO — M94).
#  - Estado persistente ISaveProvider M59: sección "postgame" (activo,
#    epílogo visto, contadores de actividades repetibles).
#  - Señal postgame_activado para M92/M53/M21 (epílogo cozy, sin "Fin" frío).
# ⚠️ Sin class_name: es autoload (pitfall 07-GUIA-GODOT §9.17/§9.41).
extends Node

const RUTA_ACTIVIDADES: String = "res://data/postgame/actividades.json"

signal postgame_activado()
## Sugerencia rotativa "¿Qué sigue?" (RF1/M92; ignorables — M94)
signal sugerencias_postgame(sugerencias: Array)

## true cuando la historia principal terminó (fuente de verdad M22)
var activo: bool = false
## M92 muestra el epílogo tras los créditos (RF1)
var epilogo_visto: bool = false
## actividades del catálogo data-driven: id -> {nombre, tipo, repite, dueno, ...}
var _actividades: Dictionary = {}
## contadores de actividades realizadas: id -> cantidad
var _hechas: Dictionary = {}


func _ready() -> void:
	_cargar_actividades()
	_registrar_proveedor_guardado()
	_conectar_eventos()
	# Re-chequeo al arrancar (carga de partida con historia terminada)
	_checar_activacion()
	print("[M75] PostgameManager listo: %d actividades, activo=%s" % [_actividades.size(), str(activo)])


func _cargar_actividades() -> void:
	_actividades.clear()
	var texto := FileAccess.get_file_as_string(RUTA_ACTIVIDADES)
	var parseado: Variant = JSON.parse_string(texto)
	if typeof(parseado) != TYPE_DICTIONARY:
		push_error("[M75] actividades.json inválido")
		return
	for act in parseado.get("actividades", []):
		var id := String(act.get("id", ""))
		if id.is_empty():
			continue
		_actividades[id] = {
			"nombre": String(act.get("nombre", id)),
			"tipo": String(act.get("tipo", "")),
			"repite": bool(act.get("repite", false)),
			"dueno": String(act.get("dueno", "")),
			"nota": String(act.get("nota", "")),
		}
	print("[M75] Actividades postgame cargadas: %d" % _actividades.size())


func _registrar_proveedor_guardado() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)


## Detección event-driven: cada sello marcado (M22→prereq_met) re-chequea.
func _conectar_eventos() -> void:
	var bus := get_node_or_null("/root/EventBus")
	if bus == null:
		return
	if bus.quest != null and bus.quest.has_signal("prereq_met"):
		bus.quest.prereq_met.connect(func(_sello: String): _checar_activacion())


## ¿La historia terminó? Fuente de verdad M22 (§2.2): sellos completos o final.
func _checar_activacion() -> void:
	if activo:
		return
	var h := get_node_or_null("/root/Historia")
	if h == null:
		return
	var fin := false
	if h.has_method("sellos_count") and h.has_method("sellos_totales"):
		fin = int(h.sellos_count()) >= int(h.sellos_totales()) and int(h.sellos_totales()) > 0
	if not fin and h.has_method("final_elegido"):
		fin = String(h.final_elegido()) != ""
	if fin:
		activar_postgame()


func activar_postgame() -> void:
	if activo:
		return
	activo = true
	print("[M75] POSTGAME ACTIVADO — la historia de Aurora llegó a su cierre")
	postgame_activado.emit()
	var sm := get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("mark_dirty"):
		sm.mark_dirty()


## ── RF1: "¿Qué sigue?" (M92 tras créditos; M53 consume) ──

## Actividades del catálogo (con estado hecho/pendiente)
func actividades_disponibles() -> Array[Dictionary]:
	var lista: Array[Dictionary] = []
	for id in _actividades:
		var a: Dictionary = _actividades[id]
		lista.append({
			"id": String(id),
			"nombre": String(a.get("nombre", "")),
			"tipo": String(a.get("tipo", "")),
			"dueno": String(a.get("dueno", "")),
			"hecha": _hechas.has(String(id)) and not bool(a.get("repite", false)),
			"veces": int(_hechas.get(String(id), 0)),
		})
	return lista


## Sugerencias rotativas "¿Qué sigue?": deterministas por día M29, máx `limite`,
## IGNORABLES sin pérdida (M94: nada expira, nada se pierde por no jugar).
func sugerir_que_sigue(limite: int = 3) -> Array[Dictionary]:
	var dia := _dia_absoluto()
	var pendientes: Array[String] = []
	for id in _actividades:
		var a: Dictionary = _actividades[id]
		if bool(a.get("repite", false)) or not _hechas.has(String(id)):
			pendientes.append(String(id))
	# Rotación determinista: empieza por (día % n) — sin rand, sin frame
	pendientes.sort()
	var rotadas: Array[Dictionary] = []
	if pendientes.is_empty():
		return rotadas
	var offset: int = dia % pendientes.size()
	for i in range(mini(limite, pendientes.size())):
		var id: String = pendientes[(offset + i) % pendientes.size()]
		rotadas.append({"id": id, "nombre": String(_actividades[id].get("nombre", id)), "dueno": String(_actividades[id].get("dueno", ""))})
	return rotadas


## El jugador consulta sugerencias (M92/M53) → emite señal para el HUD
func pedir_sugerencias() -> void:
	sugerencias_postgame.emit(sugerir_que_sigue())


## Registrar actividad realizada (dueño llama: M25 ruina, M19 vecinos, etc.)
## Sin recompensas aquí (M38/M93 dueños) — solo contadores para el panel.
func registrar_actividad(id: String) -> bool:
	if not _actividades.has(id):
		return false
	_hechas[id] = int(_hechas.get(id, 0)) + 1
	print("[M75] Actividad postgame: %s (%d)" % [id, int(_hechas[id])])
	var sm := get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("mark_dirty"):
		sm.mark_dirty()
	return true


## RF1: epílogo visto tras créditos (M92 lo llama)
func marcar_epilogo_visto() -> void:
	if epilogo_visto:
		return
	epilogo_visto = true
	print("[M75] Epílogo visto; postgame sugerencias habilitadas (sin pantalla de Fin fría)")
	pedir_sugerencias()


func _dia_absoluto() -> int:
	var gt := get_node_or_null("/root/GameTime")
	if gt != null and gt.has_method("dia_absoluto"):
		return int(gt.dia_absoluto())
	return 0


## ── Persistencia (M59) ──────────────────────────────────

func get_section_name() -> String:
	return "postgame"


func get_save_data() -> Dictionary:
	return {
		"version": 1,
		"activo": activo,
		"epilogo_visto": epilogo_visto,
		"actividades_hechas": _hechas.duplicate(),
	}


func restore_save_data(data: Dictionary) -> void:
	_hechas.clear()
	var h: Dictionary = data.get("actividades_hechas", {})
	for k in h:
		if _actividades.has(String(k)):
			_hechas[String(k)] = int(h[k])
	epilogo_visto = bool(data.get("epilogo_visto", false))
	# NUNCA re-emitir postgame_activado al restaurar (§2.3 estilo M71)
	var estaba := activo
	activo = bool(data.get("activo", false))
	if not estaba and activo:
		print("[M75] Postgame restaurado desde guardado (sin re-emisión de señal)")
