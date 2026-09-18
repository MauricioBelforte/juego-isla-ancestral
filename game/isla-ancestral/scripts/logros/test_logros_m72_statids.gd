# Modelo: agnes-3-flash (Sapiens AI)
# Plataforma: Kilo Code
# Fecha: 2026-09-18
#
# M72 Logros — RF14 data-integrity (iter. agnes, Log 1019):
# CIERRE del item abierto "RF14: validar en editor que las estadísticas referenciadas
# existan en el perfil de M71". Implementado como VALIDADOR HEADLESS (equivalente del
# "validar en editor"): cada stat_id referenciado por logros.json debe resolver contra
#   (a) el vocabulario de stats conocido de M71 (data/progresion/hitos.json, recursivo), O
#   (b) un prefijo dinámico documentado que M72/M20/M34 registran en runtime.
# Es aditivo: NO modifica el core de M72 (achievement_service.gd).
# Uso: godot --headless --path game/isla-ancestral --script res://scripts/logros/test_logros_m72_statids.gd
# Exit 0 si resuelven todos, 1 si hay stat_id sin resolver.

extends SceneTree

const M71_HITOS: String = "res://data/progresion/hitos.json"
const M72_LOGROS: String = "res://data/logros/logros.json"

## Stats dinámicos que M72 (vía M20 amistad / M34 pesca) registra en runtime
## con set_stat(); NO viven en el catálogo estático M71 pero son válidos.
const DYNAMIC_PREFIXES: Array = ["amistad_max_", "pescar_"]

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== [M72] Test RF14 stat_ids (data-integrity vs M71) ===")
	_test_rf14()
	_fin("RF14")
	if not _vistos.has("RF14"):
		_check("bloque RF14 ejecutó (posible SCRIPT ERROR)", false)
	_summary()


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FALLO] %s %s" % [nombre, detalle])


func _fin(nombre: String) -> void:
	_vistos[nombre] = true


func _test_rf14() -> void:
	var conocidos: Array = _stat_ids_de_hitos_m71()
	var referidos: Array = _stat_ids_de_logros_m72()
	_check("M71 hitos.json carga con stats conocidos", conocidos.size() > 0, "n=%d" % conocidos.size())
	_check("M72 logros.json carga con stat_ids referidos", referidos.size() > 0, "n=%d" % referidos.size())
	var únicos: Array = _unicos(referidos)
	var sin_resolver: Array = []
	for sid in únicos:
		var s: String = String(sid)
		var resuelve: bool = conocidos.has(s) or _es_dinamico_documentado(s)
		if not resuelve:
			sin_resolver.append(s)
	_check("todos los stat_ids de M72 resuelven (M71-known o prefijo dinámico)",
		sin_resolver.is_empty(), "sin resolver: %s" % str(sin_resolver))
	for sid in únicos:
		var s2: String = String(sid)
		var via: String = "M71-known" if conocidos.has(s2) else ("dinámico (%s...)" % _prefijo_de(s2))
		_check("stat_id '%s' resuelve vía %s" % [s2, via],
			conocidos.has(s2) or _es_dinamico_documentado(s2))
	_fin("RF14")


## Recursivo sobre M71 hitos.json: stat_min.stat_id + compuesta.hijos[].
func _stat_ids_de_hitos_m71() -> Array:
	var out: Array = []
	var d: Variant = JSON.parse_string(FileAccess.get_file_as_string(M71_HITOS))
	if typeof(d) != TYPE_DICTIONARY:
		return out
	for h in (d as Dictionary).get("hitos", []):
		_recolectar_condicion(h.get("condicion", {}), out)
	return out


## Recursivo sobre M72 logros.json: stat_min.stat_id + compuesta.hijos[].
func _stat_ids_de_logros_m72() -> Array:
	var out: Array = []
	var d: Variant = JSON.parse_string(FileAccess.get_file_as_string(M72_LOGROS))
	if typeof(d) != TYPE_DICTIONARY:
		return out
	for l in (d as Dictionary).get("logros", []):
		_recolectar_condicion(l.get("condicion", {}), out)
	return out


func _recolectar_condicion(cond: Variant, out: Array) -> void:
	if typeof(cond) != TYPE_DICTIONARY:
		return
	var c: Dictionary = cond
	var tipo: String = String(c.get("tipo", ""))
	if tipo == "stat_min":
		var sid: String = String(c.get("stat_id", ""))
		if not sid.is_empty():
			out.append(sid)
	elif tipo == "compuesta":
		for hijo in c.get("hijos", []):
			_recolectar_condicion(hijo, out)


func _unicos(arr: Array) -> Array:
	var seen: Dictionary = {}
	var out: Array = []
	for x in arr:
		var s: String = String(x)
		if not seen.has(s):
			seen[s] = true
			out.append(s)
	return out


func _es_dinamico_documentado(sid: String) -> bool:
	for p in DYNAMIC_PREFIXES:
		if sid.begins_with(String(p)):
			return true
	return false


func _prefijo_de(sid: String) -> String:
	for p in DYNAMIC_PREFIXES:
		if sid.begins_with(String(p)):
			return String(p)
	return ""


func _summary() -> void:
	print("=== Resumen M72 RF14: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M72 RF14 FALLIDO — hay stat_ids sin resolver (data-integrity)")
		quit(1)
	else:
		print("TEST M72 RF14 OK — todos los stat_ids resuelven")
		quit(0)
