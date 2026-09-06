# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-04
#
# M158: Herramientas — JarManager (fuentes de ingreso: jarrones, checklist G).
# Jarrones en la isla principal: 10-15 activos, reposición cada 7 días (M29),
# contenido 5-15 monedas. Máx ~150 monedas/semana (anti-grind cozy).
# Lógica pura + API de colocación (el Node3D visual con dueño M45/M61).

extends RefCounted

const JARRONES_MAX: int = 15
const DIAS_REPOSICION: int = 7
const MONEDAS_MIN: int = 5
const MONEDAS_MAX: int = 15

## Estado de los jarrones: indice -> {abierto: bool, monedas: int, dia_reposicion: int}
var _jarrones: Dictionary = {}
## Última reposición (día absoluto)
var _ultima_reposicion: int = -1
## Total monedas obtenidas de jarrones (persistible)
var _total_monedas: int = 0


func _init() -> void:
	_reposicionar(0)


## Genera/repone los JARRONES_MAX jarrones con monedas PRNG deterministas.
## Idempotente: solo repone si pasaron DIAS_REPOSICION desde la última.
func _reposicionar(dia_absoluto: int) -> void:
	if _ultima_reposicion >= 0 and (dia_absoluto - _ultima_reposicion) < DIAS_REPOSICION:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = (dia_absoluto / DIAS_REPOSICION) * 104729  # determinista por semana
	_jarrones.clear()
	for i in range(JARRONES_MAX):
		_jarrones[i] = {
			"abierto": false,
			"monedas": rng.randi_range(MONEDAS_MIN, MONEDAS_MAX),
		}
	_ultima_reposicion = dia_absoluto


## Verifica reposición al consultar (day_started M29 llama esto).
func verificar_reposicion(dia_absoluto: int) -> bool:
	if _ultima_reposicion >= 0 and (dia_absoluto - _ultima_reposicion) < DIAS_REPOSICION:
		return false
	_reposicionar(dia_absoluto)
	print("[M158/Jars] Jarrones repuestos (%d activos)" % JARRONES_MAX)
	return true


## Abrir un jarrón: devuelve las monedas obtenidas (0 si ya estaba abierto).
## Idempotente por jarrón (sin duplicar recompensa).
func abrir_jarron(indice: int, dia_absoluto: int) -> int:
	verificar_reposicion(dia_absoluto)
	if not _jarrones.has(indice):
		return 0
	var j: Dictionary = _jarrones[indice]
	if bool(j.get("abierto", true)):
		return 0  # ya abierto: sin duplicado (anti-grind)
	j["abierto"] = true
	var monedas := int(j.get("monedas", 0))
	_total_monedas += monedas
	print("[M158/Jars] Jarrón %d abierto: %d AO" % [indice, monedas])
	return monedas


## Jarrones disponibles (no abiertos) para la UI
func jarrones_disponibles() -> int:
	var n := 0
	for k in _jarrones:
		if not bool(_jarrones[k].get("abierto", true)):
			n += 1
	return n


func total_monedas() -> int:
	return _total_monedas


func ultima_reposicion() -> int:
	return _ultima_reposicion


## ── Persistencia (M59, integrada en la sección del pool padre) ──

func get_save_data() -> Dictionary:
	return {
		"jarrones": _jarrones.duplicate(true),
		"ultima_reposicion": _ultima_reposicion,
		"total_monedas": _total_monedas,
	}


func restore_save_data(data: Dictionary) -> void:
	_jarrones.clear()
	var j: Dictionary = data.get("jarrones", {})
	for k in j:
		_jarrones[int(k)] = j[k]
	_ultima_reposicion = int(data.get("ultima_reposicion", -1))
	_total_monedas = int(data.get("total_monedas", 0))
	# §2.3: sin re-emisión (jarrones no emiten señales de reposición al restaurar)
