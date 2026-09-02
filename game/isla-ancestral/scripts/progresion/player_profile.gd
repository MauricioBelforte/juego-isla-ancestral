# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M71: Progresión — PlayerProfile (autoload "PlayerProfile")
# Estadísticas acumuladas y del día, primeras veces, reputación y títulos
# (03-Diseno §3.4). Lógica pura, sin UI. Persistencia delegada al
# ProgressionManager (un solo punto de guardado de la sección "progresion").
# ⚠️ Sin class_name: es autoload (pitfall 07-GUIA-GODOT §9.17/§9.41).
extends Node

## Reputación (§4.5): 60% amistad, 40% contribución (ventas y trueques)
const PESO_AMISTAD: float = 0.6
const PESO_CONTRIBUCION: float = 0.4
## Normalizaciones de reputación (cozy: alcanzables sin grind)
const AMISTAD_POR_NIVEL_MAX: int = 10   # npc_count × nivel medio 4
const CONTRIBUCION_META: float = 2000.0  # AO de ventas+trueques = 100%

## estadística (String) -> valor acumulado (float/int)
var _totales: Dictionary = {}
## estadística (String) -> valor del día
var _dia: Dictionary = {}
## actividades marcadas como primera vez: id -> true
var _primeras_veces: Dictionary = {}
## contribución comunitaria: monedas ganadas por ventas/trueques (reputación)
var _contribucion: float = 0.0
## señales sucias desde la última reevaluación (dirty flags, diseño §1)
var _sucias: Dictionary = {}


func incrementar(stat_id: String, cantidad: int = 1) -> void:
	_totales[stat_id] = float(_totales.get(stat_id, 0.0)) + float(cantidad)
	_dia[stat_id] = float(_dia.get(stat_id, 0.0)) + float(cantidad)
	_sucias[stat_id] = true
	if stat_id == "monedas_ganadas":
		_contribucion += float(cantidad)


func set_stat(stat_id: String, valor: Variant) -> void:
	_totales[stat_id] = valor
	_sucias[stat_id] = true


func get_stat(stat_id: String) -> Variant:
	return _totales.get(stat_id, 0)


## Reset diario (lo llama ProgressionManager con day_started M29)
func reset_dia() -> void:
	_dia.clear()


func estadisticas_dia() -> Dictionary:
	return _dia.duplicate()


## ── Primeras veces (§3.4) ───────────────────────────────

func primera_vez(actividad_id: String) -> bool:
	return not _primeras_veces.has(actividad_id)


func marcar_primera_vez(actividad_id: String) -> void:
	_primeras_veces[actividad_id] = true


## ── Reputación (§4.5: 60% amistad + 40% contribución) ───

## amistad_normalizada: 0-1 que calcula el caller desde M20 (nivel medio/max)
func reputacion(amistad_normalizada: float = -1.0) -> float:
	var comp_amistad := clampf(amistad_normalizada, 0.0, 1.0)
	var comp_contrib := clampf(_contribucion / CONTRIBUCION_META, 0.0, 1.0)
	if amistad_normalizada < 0.0:
		# sin dato de amistad, solo contribución re-escalada al 100%
		return roundf(comp_contrib * 100.0)
	return roundf((comp_amistad * PESO_AMISTAD + comp_contrib * PESO_CONTRIBUCION) * 100.0)


func contribucion_actual() -> float:
	return _contribucion


## ── Dirty flags (UnlockSystem consume, diseño §1) ───────

func estadisticas_sucias() -> Array:
	return _sucias.keys()


func limpiar_sucia(stat_id: String) -> void:
	_sucias.erase(stat_id)


## ── Serialización (la usa ProgressionManager, §6) ───────

func guardar() -> Dictionary:
	return {
		"estadisticas_totales": _totales.duplicate(),
		"estadisticas_dia": _dia.duplicate(),
		"primeras_veces": _primeras_veces.keys(),
		"contribucion": _contribucion,
	}


func cargar(data: Dictionary) -> void:
	_totales.clear()
	var t: Dictionary = data.get("estadisticas_totales", {})
	for k in t:
		_totales[String(k)] = t[k]
	_dia.clear()
	var d: Dictionary = data.get("estadisticas_dia", {})
	for k in d:
		_dia[String(k)] = d[k]
	_primeras_veces.clear()
	for p in data.get("primeras_veces", []):
		_primeras_veces[String(p)] = true
	_contribucion = float(data.get("contribucion", 0.0))
	_sucias.clear()
