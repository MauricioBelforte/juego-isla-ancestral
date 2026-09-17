# Modelo: DeepSeek-V4.1-Flash / WorkBuddy
# Plataforma: WorkBuddy
# Fecha: 2026-09-14
#
# M26 — Templo Subterráneo (iteración 2).
# TempleTelemetria: registra por puzzle los intentos, las pistas usadas y el
# tiempo, y exporta JSON listo para el balance de dificultad de M24.
#
# Diseño: el reloj es INYECTABLE (`avanzar(delta)`) para que los tests sean
# deterministas — nada de `Time.get_ticks_msec()` dentro de la clase.

class_name TempleTelemetria
extends RefCounted

## Versión del formato exportado (M24 consume esto).
const VERSION := 1

var templo_id: String = "templo_subterraneo"
## puzzle_id -> {intentos, pistas, tiempo_s, resuelto, primer_intento_s, intentos_hasta_resolver}
var _puzzles: Dictionary = {}
var _reloj_s: float = 0.0


func _init(templo: String = "templo_subterraneo") -> void:
	templo_id = templo


## Avanza el reloj interno (inyectado; determinista en tests).
func avanzar(delta_s: float) -> void:
	_reloj_s += maxf(delta_s, 0.0)


func reloj_s() -> float:
	return _reloj_s


func _nuevo_puzzle() -> Dictionary:
	return {
		"intentos": 0,
		"pistas": 0,
		"tiempo_s": 0.0,
		"resuelto": false,
		"primer_intento_s": -1.0,
		"intentos_hasta_resolver": -1,
	}


func registrar_intento(puzzle_id: String, pistas_usadas: int = 0) -> void:
	if puzzle_id.is_empty():
		return
	var p: Dictionary = _puzzles.get(puzzle_id, _nuevo_puzzle())
	p["intentos"] = int(p["intentos"]) + 1
	if float(p["primer_intento_s"]) < 0.0:
		p["primer_intento_s"] = _reloj_s
	p["pistas"] = int(p["pistas"]) + maxi(pistas_usadas, 0)
	_puzzles[puzzle_id] = p


## Marca el puzzle como resuelto. Si no se pasa tiempo, usa el reloj interno.
func registrar_resolucion(puzzle_id: String, tiempo_s: float = -1.0) -> void:
	if puzzle_id.is_empty():
		return
	if not _puzzles.has(puzzle_id):
		registrar_intento(puzzle_id, 0)
	var p: Dictionary = _puzzles[puzzle_id]
	p["resuelto"] = true
	if tiempo_s >= 0.0:
		p["tiempo_s"] = tiempo_s
	else:
		var inicio := float(p["primer_intento_s"])
		p["tiempo_s"] = maxf(_reloj_s - inicio, 0.0) if inicio >= 0.0 else 0.0
	p["intentos_hasta_resolver"] = int(p["intentos"])
	_puzzles[puzzle_id] = p


func resumen(puzzle_id: String) -> Dictionary:
	var p: Variant = _puzzles.get(puzzle_id, {})
	if typeof(p) != TYPE_DICTIONARY:
		return {}
	return (p as Dictionary).duplicate(true)


func resumen_global() -> Dictionary:
	var intentos := 0
	var pistas := 0
	var resueltos := 0
	var tiempo := 0.0
	for pid in _puzzles:
		var p: Dictionary = _puzzles[pid]
		intentos += int(p["intentos"])
		pistas += int(p["pistas"])
		tiempo += float(p["tiempo_s"])
		if bool(p["resuelto"]):
			resueltos += 1
	return {
		"templo_id": templo_id,
		"puzzles": _puzzles.size(),
		"resueltos": resueltos,
		"intentos": intentos,
		"pistas": pistas,
		"tiempo_s": tiempo,
	}


## Payload para M24 (balance de dificultad). Determinista: puzzles ordenados por id.
func exportar_a_m24() -> Dictionary:
	var ids: Array = _puzzles.keys()
	ids.sort()
	var lista: Array = []
	for pid in ids:
		var p: Dictionary = _puzzles[pid]
		lista.append({
			"puzzle_id": str(pid),
			"intentos": int(p["intentos"]),
			"pistas": int(p["pistas"]),
			"tiempo_s": float(p["tiempo_s"]),
			"resuelto": bool(p["resuelto"]),
			"intentos_hasta_resolver": int(p["intentos_hasta_resolver"]),
		})
	return {
		"version": VERSION,
		"origen": "M26",
		"templo_id": templo_id,
		"resumen": resumen_global(),
		"puzzles": lista,
	}


func exportar_json() -> String:
	return JSON.stringify(exportar_a_m24(), "  ")


## Reimporta una exportación previa (idempotente en el payload exportado).
func cargar_json(txt: String) -> bool:
	var parsed: Variant = JSON.parse_string(txt)
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	var d: Dictionary = parsed as Dictionary
	var lista: Variant = d.get("puzzles", [])
	if typeof(lista) != TYPE_ARRAY:
		return false
	_puzzles.clear()
	for e in (lista as Array):
		if typeof(e) != TYPE_DICTIONARY:
			continue
		var ed: Dictionary = e as Dictionary
		var pid := str(ed.get("puzzle_id", ""))
		if pid.is_empty():
			continue
		var p := _nuevo_puzzle()
		p["intentos"] = int(ed.get("intentos", 0))
		p["pistas"] = int(ed.get("pistas", 0))
		p["tiempo_s"] = float(ed.get("tiempo_s", 0.0))
		p["resuelto"] = bool(ed.get("resuelto", false))
		p["intentos_hasta_resolver"] = int(ed.get("intentos_hasta_resolver", -1))
		_puzzles[pid] = p
	templo_id = str(d.get("templo_id", templo_id))
	return true


func reiniciar() -> void:
	_puzzles.clear()
	_reloj_s = 0.0


## Puzzles que requirieron más de `umbral` intentos: candidatos a ajuste de
## dificultad (lo que M24 quiere saber).
func puzzles_dificiles(umbral: int = 3) -> Array[String]:
	var dif: Array[String] = []
	for pid in _puzzles:
		if int((_puzzles[pid] as Dictionary)["intentos"]) > umbral:
			dif.append(str(pid))
	dif.sort()
	return dif
