# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01 (iter. 1-2) / 2026-09-02 (iter. 3)
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
# Iter. 3 (glm-5.3-flash 2026-09-02, Log 527):
#  - RF4: fecha de desbloqueo determinista (día absoluto + hora M29; CERO
#    reloj real — RN11) persistida con el logro.
#  - RF5: re_evaluar_todo() al restaurar partida → retroactividad: logros
#    cuya condición ya estaba cumplida se otorgan con fecha de carga.
#  - RF3: evaluación event-driven extendida a EventBus (inventory/economy/
#    npc/quest) — nunca por frame.
#  - RF4: write-through → SaveManager.mark_dirty() tras cada desbloqueo.
#  - RF6: toast no bloqueante vía EventBus.notify (cola/pool dueño M53).
#  - RF8: get_progreso_humano(id) "X de Y".
#  - RF10: API consulta completa (get_todos/get_estado/get_en_progreso/...).
#  - RF14: validar_catalogo() con errores accionables (id vacío, condición
#    vacía, tipo desconocido, stat_id vacío en stat_min).
# ⚠️ Sin class_name: es autoload (pitfall 07-GUIA-GODOT §9.17/§9.41).
extends Node

const RUTA_CATALOGO: String = "res://data/logros/logros.json"
const VERSION_ESTADO: int = 2  # v2: desbloqueados con fechas

signal logro_desbloqueado(logro_id: String, nombre: String)
signal logro_progreso(logro_id: String, logrado: float, requerido: float)

## logro_id -> {nombre, descripcion, condicion, oculto, progreso_parcial: bool}
var _logros: Dictionary = {}
## logros desbloqueados (orden de consecución)
var _desbloqueados: Array[String] = []
## RF4: fecha de desbloqueo por logro: logro_id -> {"dia": int, "hora": int}
var _fechas: Dictionary = {}


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
	# RF14: validación accionable en arranque (headless-friendly)
	var problemas := validar_catalogo()
	if problemas > 0:
		push_warning("[M72][RF14] Catálogo con %d problema(s)" % problemas)


func _registrar_proveedor_guardado() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)


## Evaluación event-driven (§7 estilo M71): señales de progreso y EventBus
## re-evalúan los logros aún no desbloqueados. NUNCA por frame.
func _conectar_eventos() -> void:
	var pm := get_node_or_null("/root/ProgressionManager")
	if pm == null:
		push_warning("[M72] ProgressionManager ausente; logros no evaluables")
	else:
		pm.progreso_hito_alcanzado.connect(func(_id: String, _n: String, _r: Array): evaluar_todos())
		pm.progreso_desbloqueado.connect(func(_id: String, _t: String, _v: String): evaluar_todos())
	# RF3: eventos de dominio en EventBus (evaluación por evento, nunca frame)
	var bus := get_node_or_null("/root/EventBus")
	if bus == null:
		return
	if bus.inventory != null and bus.inventory.has_signal("item_added"):
		bus.inventory.item_added.connect(func(_i: String, _q: int): evaluar_todos())
	if bus.economy != null and bus.economy.has_signal("purchase_done"):
		bus.economy.purchase_done.connect(func(_i: String, _c: int): evaluar_todos())
	if bus.npc != null and bus.npc.has_signal("gift_given"):
		bus.npc.gift_given.connect(func(_n: String, _i: String, _c: int): evaluar_todos())
	if bus.quest != null and bus.quest.has_signal("quest_completed"):
		bus.quest.quest_completed.connect(func(_q: String): evaluar_todos())


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


## RF5: re-evaluación retroactiva (al cargar partida): otorga logros cuya
## condición ya estaba cumplida; usa la fecha de la carga (día M29).
func re_evaluar_todo() -> int:
	var antes := _desbloqueados.size()
	evaluar_todos()
	var retro := _desbloqueados.size() - antes
	if retro > 0:
		print("[M72][RF5] Retroactividad: %d logro(s) otorgado(s) al cargar" % retro)
	return retro


## Desbloqueo idempotente (§3.1) — un logro se obtiene una sola vez.
## RF4: registra fecha determinista (M29) + write-through (mark_dirty M59)
## + toast no bloqueante vía EventBus.notify (RF6).
func desbloquear(logro_id: String) -> bool:
	if not _logros.has(logro_id) or logro_id in _desbloqueados:
		return false
	_desbloqueados.append(logro_id)
	_fechas[logro_id] = _fecha_actual()
	var nombre := String(_logros[logro_id].get("nombre", logro_id))
	logro_desbloqueado.emit(logro_id, nombre)
	print("[DOM-LOGRO] %s — %s (día %d)" % [logro_id, nombre, int(_fechas[logro_id].get("dia", 0))])
	# RF4: write-through inmediato (la escritura real la agrupa M59)
	var sm := get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("mark_dirty"):
		sm.mark_dirty()
	# RF6: toast no bloqueante (no roba input; cola dueño M53)
	_emitir_toast(logro_id, nombre)
	return true


func _fecha_actual() -> Dictionary:
	# Determinista: día absoluto del calendario Aurora (M29); CERO reloj real.
	var dia := 0
	var hora := 0
	var gt := get_node_or_null("/root/GameTime")
	if gt != null and gt.has_method("dia_absoluto"):
		dia = int(gt.dia_absoluto())
	if gt != null and gt.has_method("get_hora"):
		hora = int(gt.get_hora())
	return {"dia": dia, "hora": hora}


func _emitir_toast(logro_id: String, nombre: String) -> void:
	var bus := get_node_or_null("/root/EventBus")
	if bus == null or not bus.has_signal("notify"):
		return
	var oculto := bool(_logros.get(logro_id, {}).get("oculto", false))
	var texto := "Logro desbloqueado"
	if not oculto:
		texto = String(_logros[logro_id].get("descripcion", "Logro desbloqueado"))
	bus.notify.emit({
		"tipo": "logro",
		"id": logro_id,
		"titulo": nombre,
		"texto": texto,
	})


func esta_desbloqueado(logro_id: String) -> bool:
	return logro_id in _desbloqueados


## Progreso parcial de un logro (evaluación perezosa para la UI)
func progreso_de(logro_id: String) -> Dictionary:
	var pm := get_node_or_null("/root/ProgressionManager")
	if pm == null or not _logros.has(logro_id):
		return {"logrado": 0.0, "requerido": 0.0}
	var cond: Dictionary = _logros[logro_id].get("condicion", {})
	if String(cond.get("tipo", "")) == "stat_min":
		var stat: float = float(pm.profile.get_stat(String(cond.get("stat_id", "")))) if pm.profile != null else 0.0
		var req: float = float(cond.get("umbral", 0))
		logro_progreso.emit(logro_id, stat, req)
		return {"logrado": minf(stat, req), "requerido": req}
	return {"logrado": float(esta_desbloqueado(logro_id)), "requerido": 1.0}


## RF8: progreso humano "X de Y" (clamp anti-redondeo: nunca supera el objetivo)
func get_progreso_humano(logro_id: String) -> String:
	var p := progreso_de(logro_id)
	return "%d de %d" % [int(p.get("logrado", 0.0)), int(p.get("requerido", 0.0))]


## ── % REAL (M55 §3.2: los logros usan el total real, no el anti-spoiler) ──

func porcentaje_real() -> float:
	if _logros.is_empty():
		return 0.0
	return float(_desbloqueados.size()) / float(_logros.size())


func desbloqueados() -> Array:
	return _desbloqueados.duplicate()


func logros_count() -> int:
	return _logros.size()


## ── RF10: API de consulta (para panel M53) ─────────────

func is_unlocked(logro_id: String) -> bool:
	return esta_desbloqueado(logro_id)


func get_definicion(logro_id: String) -> Dictionary:
	return _logros.get(logro_id, {})


func get_todos() -> Array[Dictionary]:
	var lista: Array[Dictionary] = []
	for id in _logros:
		lista.append(_estado_de(String(id)))
	return lista


func get_estado(logro_id: String) -> Dictionary:
	return _estado_de(logro_id)


func _estado_de(logro_id: String) -> Dictionary:
	var desbloqueado := esta_desbloqueado(logro_id)
	var oculto := bool(_logros.get(logro_id, {}).get("oculto", false))
	if oculto and not desbloqueado:
		return {"id": logro_id, "nombre": "???", "descripcion": "Logro oculto",
			"desbloqueado": false, "oculto": true, "progreso": ""}
	var fecha: Dictionary = _fechas.get(logro_id, {})
	return {
		"id": logro_id,
		"nombre": String(_logros.get(logro_id, {}).get("nombre", "")),
		"descripcion": String(_logros.get(logro_id, {}).get("descripcion", "")),
		"desbloqueado": desbloqueado,
		"oculto": oculto,
		"dia": int(fecha.get("dia", -1)),
		"hora": int(fecha.get("hora", -1)),
		"progreso": "" if desbloqueado else get_progreso_humano(logro_id),
	}


func get_desbloqueados() -> Array:
	return _desbloqueados.duplicate()


func get_en_progreso() -> Array[Dictionary]:
	var lista: Array[Dictionary] = []
	for id in _logros:
		if esta_desbloqueado(String(id)):
			continue
		var p := progreso_de(String(id))
		if float(p.get("requerido", 0.0)) > 0.0 and float(p.get("logrado", 0.0)) > 0.0:
			lista.append({"id": String(id), "progreso": get_progreso_humano(String(id))})
	return lista


func get_porcentaje_completado() -> float:
	return porcentaje_real()


func fecha_de(logro_id: String) -> Dictionary:
	return _fechas.get(logro_id, {})


## Listado para la UI M53: ocultos no desbloqueados aparecen como "???"
func listado_para_ui() -> Array[Dictionary]:
	return get_todos()


## ── RF14: Validación de catálogo (errores accionables) ──

## Tipos de condición que el evaluador de M71 entiende (contrato §3.6)
const TIPOS_CONDICION_VALIDOS := [
	"stat_min", "dias_jugados", "sello_historia", "capitulo_historia",
	"riqueza_acumulada", "primera_vez", "hito_previo", "coleccion_completa",
	"nivel_modulo", "compuesta",
]


func validar_catalogo() -> int:
	"""RF14: devuelve cantidad de problemas; imprime cada uno accionable."""
	var problemas := 0
	var vistos := {}
	var texto := FileAccess.get_file_as_string(RUTA_CATALOGO)
	var parseado: Variant = JSON.parse_string(texto)
	var entradas: Array = parseado.get("logros", []) if typeof(parseado) == TYPE_DICTIONARY else []
	for logro in entradas:
		var id := String(logro.get("id", ""))
		if id.is_empty():
			problemas += 1
			print("[M72][RF14] Problema: logro sin 'id' — agregar campo id único")
			continue
		if vistos.has(id):
			problemas += 1
			print("[M72][RF14] Problema: id duplicado '%s' — renombrar una entrada" % id)
		vistos[id] = true
		var cond: Dictionary = logro.get("condicion", {})
		if cond.is_empty():
			problemas += 1
			print("[M72][RF14] Problema: '%s' sin condición — definir condicion" % id)
			continue
		problemas += _validar_condicion(id, cond)
	if problemas == 0:
		print("[M72][RF14] Catálogo OK: %d logros, 0 problemas" % _logros.size())
	return problemas


func _validar_condicion(id: String, cond: Dictionary) -> int:
	var problemas := 0
	var tipo := String(cond.get("tipo", ""))
	if not TIPOS_CONDICION_VALIDOS.has(tipo):
		problemas += 1
		print("[M72][RF14] Problema: '%s' tipo de condición desconocido '%s' — usar vocabulario M71 §3.6" % [id, tipo])
		return problemas
	if tipo == "stat_min" and String(cond.get("stat_id", "")).is_empty():
		problemas += 1
		print("[M72][RF14] Problema: '%s' stat_min sin stat_id" % id)
	if tipo == "compuesta":
		for hijo in cond.get("hijos", []):
			problemas += _validar_condicion(id, hijo)
	return problemas


## ── Persistencia (M59) — v2 con fechas; migra array v1 ──

func get_section_name() -> String:
	return "achievements"


func get_save_data() -> Dictionary:
	# Solo JSON-safe: diccionarios planos String/int.
	var desbloq := {}
	for id in _desbloqueados:
		var f: Dictionary = _fechas.get(id, {"dia": -1, "hora": -1})
		desbloq[id] = {"dia": int(f.get("dia", -1)), "hora": int(f.get("hora", -1))}
	return {"version": VERSION_ESTADO, "desbloqueados": desbloq}


func restore_save_data(data: Dictionary) -> void:
	_desbloqueados.clear()
	_fechas.clear()
	var raw: Variant = data.get("desbloqueados", {})
	if raw is Array:
		# v1 (migración suave): lista sin fechas; fecha = -1 hasta re-eval
		for id in raw:
			var lid := String(id)
			if _logros.has(lid):
				_desbloqueados.append(lid)
				_fechas[lid] = {"dia": -1, "hora": -1}
			else:
				print("[M72] Logro de catálogo viejo ignorado: %s" % lid)
	elif raw is Dictionary:
		# v2: dict con fechas
		for k in raw:
			var lid2 := String(k)
			if _logros.has(lid2):
				_desbloqueados.append(lid2)
				var f: Dictionary = raw[k] if raw[k] is Dictionary else {}
				_fechas[lid2] = {"dia": int(f.get("dia", -1)), "hora": int(f.get("hora", -1))}
			else:
				print("[M72] Logro de catálogo viejo ignorado: %s" % lid2)
	# §2.3 estilo M71: NUNCA re-emitir señales de logros restaurados
	# RF5: re-evaluación retroactiva tras cargar (condiciones ya cumplidas)
	call_deferred("re_evaluar_todo")
