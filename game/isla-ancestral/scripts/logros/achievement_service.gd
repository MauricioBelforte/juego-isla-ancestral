# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M72: Sistema de Logros — AchievementService (autoload "Achievements")
# Núcleo V0/V1 (03-Diseno §2-§4):
#  - Catálogo data-driven de logros en data/logros/logros.json. Cada logro
#    define una CONDICIÓN con el MISMO formato del catálogo de hitos M71
#    (§3.6: stat_min, dias_jugados, sello_historia, compuesta...) — la
#    evaluación SE DELEGA a ProgressionManager.evaluar_condicion() (§no
#    duplicar lógica; diseño §4: M72 usa el evaluador de M71).
#  - Progreso parcial perezoso (progreso_parcial de M71) para la UI.
#  - Desbloqueo idempotente + señales logro_desbloqueado (M53/M103/M104).
#  - % REAL de logros (fuera del anti-spoiler del diario — §3.2 M55: los
#    logros usan el total real, M72 es la fuente).
#  - Persistencia ISaveProvider M59: sección "achievements".
# ⚠️ Sin class_name: es autoload (pitfall 07-GUIA-GODOT §9.17/§9.41).
extends Node

const RUTA_CATALOGO: String = "res://data/logros/logros.json"

signal logro_desbloqueado(logro_id: String, nombre: String)
signal logro_progreso(logro_id: String, logrado: float, requerido: float)

## logro_id -> {nombre, descripcion, condicion, oculto, progreso_parcial: bool}
var _logros: Dictionary = {}
## logros desbloqueados (orden de consecución)
var _desbloqueados: Array[String] = []


func _ready() -> void:
	_cargar_catalogo()
	_registrar_proveedor_guardado()
	_conectar_eventos()


func _cargar_catalogo() -> void:
	_logros.clear()
	var texto := FileAccess.get_file_as_string(RUTA_CATALOGO)
	var parseado: Variant = JSON.parse_string(texto)
	if typeof(parseado) != TYPE_DICTIONARY:
		push_error("[M72] logros.json inválido")
		return
	for logro in parseado.get("logros", []):
		var id := String(logro.get("id", ""))
		if id.is_empty():
			continue
		_logros[id] = {
			"nombre": String(logro.get("nombre", id)),
			"descripcion": String(logro.get("descripcion", "")),
			"condicion": logro.get("condicion", {}),
			"oculto": bool(logro.get("oculto", false)),
			"progreso_parcial": bool(logro.get("progreso_parcial", false)),
		}
	print("[M72] Logros cargados: %d" % _logros.size())


func _registrar_proveedor_guardado() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)


## Evaluación: cada señal del ProgressionManager re-evalúa los logros aún
## no desbloqueados (event-driven, sin bucle por frame — §7 estilo M71).
func _conectar_eventos() -> void:
	var pm := get_node_or_null("/root/ProgressionManager")
	if pm == null:
		push_warning("[M72] ProgressionManager ausente; logros no evaluables")
		return
	pm.progreso_hito_alcanzado.connect(func(_id: String, _n: String, _r: Array): evaluar_todos())
	pm.progreso_desbloqueado.connect(func(_id: String, _t: String, _v: String): evaluar_todos())


## Evalúa todos los logros pendientes (idempotente por desbloqueo).
func evaluar_todos() -> void:
	var pm := get_node_or_null("/root/ProgressionManager")
	if pm == null:
		return
	for id in _logros:
		if id in _desbloqueados:
			continue
		var cond: Dictionary = _logros[id].get("condicion", {})
		if pm.evaluar_condicion(cond):
			desbloquear(String(id))


## Desbloqueo idempotente (§3.1) — un logro se obtiene una sola vez.
func desbloquear(logro_id: String) -> bool:
	if not _logros.has(logro_id) or logro_id in _desbloqueados:
		return false
	_desbloqueados.append(logro_id)
	logro_desbloqueado.emit(logro_id, String(_logros[logro_id].get("nombre", logro_id)))
	print("[DOM-LOGRO] %s — %s" % [logro_id, String(_logros[logro_id].get("nombre", logro_id))])
	return true


func esta_desbloqueado(logro_id: String) -> bool:
	return logro_id in _desbloqueados


## Progreso parcial de un logro (evaluación perezosa para la UI)
func progreso_de(logro_id: String) -> Dictionary:
	var pm := get_node_or_null("/root/ProgressionManager")
	if pm == null or not _logros.has(logro_id):
		return {"logrado": 0.0, "requerido": 0.0}
	var pp: Dictionary = pm.progreso_parcial(_logros[logro_id].get("condicion", {}).get("milestone_id", ""))
	var cond: Dictionary = _logros[logro_id].get("condicion", {})
	if String(cond.get("tipo", "")) == "stat_min":
		var stat: float = float(pm.profile.get_stat(String(cond.get("stat_id", "")))) if pm.profile != null else 0.0
		var req: float = float(cond.get("umbral", 0))
		logro_progreso.emit(logro_id, stat, req)
		return {"logrado": stat, "requerido": req}
	return {"logrado": float(esta_desbloqueado(logro_id)), "requerido": 1.0}


## ── % REAL (M55 §3.2: los logros usan el total real, no el anti-spoiler) ──

func porcentaje_real() -> float:
	if _logros.is_empty():
		return 0.0
	return float(_desbloqueados.size()) / float(_logros.size())


func desbloqueados() -> Array:
	return _desbloqueados.duplicate()


func logros_count() -> int:
	return _logros.size()


## Listado para la UI M53: ocultos no desbloqueados aparecen como "???"
func listado_para_ui() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for id in _logros:
		var desbloqueado := esta_desbloqueado(String(id))
		var oculto := bool(_logros[id].get("oculto", false))
		if oculto and not desbloqueado:
			result.append({"id": String(id), "nombre": "???", "descripcion": "Logro oculto", "desbloqueado": false, "oculto": true})
			continue
		result.append({
			"id": String(id),
			"nombre": String(_logros[id].get("nombre", "")),
			"descripcion": String(_logros[id].get("descripcion", "")),
			"desbloqueado": desbloqueado,
			"oculto": oculto,
		})
	return result


## ── Persistencia (M59) ──────────────────────────────────

func get_section_name() -> String:
	return "achievements"


func get_save_data() -> Dictionary:
	return {"desbloqueados": _desbloqueados.duplicate()}


func restore_save_data(data: Dictionary) -> void:
	_desbloqueados.clear()
	for id in data.get("desbloqueados", []):
		var lid := String(id)
		if _logros.has(lid):
			_desbloqueados.append(lid)
		else:
			print("[M72] Logro de catálogo viejo ignorado: %s" % lid)
	# §2.3 estilo M71: NUNCA re-emitir señales de logros restaurados
