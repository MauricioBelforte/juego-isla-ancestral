# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M43: Efectos de Sonido — SFXManager (autoload)
# Pool de 24 voces con prioridades (04-Codigo.md §1.1): reproducción por
# superficie con variaciones, límite duro (si el pool está lleno y la nueva
# prioridad es mayor, corta la voz más antigua de menor prioridad; nunca
# crece sin tope). Diseño original (04-Codigo.md §1.1).
# ⚠️ Sin class_name: es autoload (pitfall §9.17/§9.41).
#
# Lote B1 (2026-10-03, mimo-v2.6-flash-free): se agrega la familia tonal
# de 03-Diseno §4 (`sfx_tones.json`) + API `tono()`. Compatibilidad total
# con los 15 checks originales de `test_sfx_m43.gd`.
#
# Lote B2 (2026-10-03, mimo-v2.6-flash-free): catálogo de 03-Diseno §3
# (`sfx_catalog.json`, 12 filas: 6 paso + 5 romper + 1 colocar) + API
# `catalogo()` / `catalogo_variaciones()`. `sfx_surfaces.json` ampliado a
# 9 superficies (hierba/nieve/arena nuevas y piedra 4 → 5, según §3).

extends Node

const MAX_VOCES := 24
const RUTA_SURFACES := "res://data/audio/sfx_surfaces.json"
const RUTA_TONES := "res://data/audio/sfx_tones.json"
const RUTA_CATALOG := "res://data/audio/sfx_catalog.json"

var surfaces: Dictionary = {}
var tones: Dictionary = {}
var catalog: Dictionary = {}
var _voces: Array = []  # [{tipo, prioridad, tiempo_ms}]

func _ready() -> void:
	_cargar_surfaces()
	_cargar_tones()
	_cargar_catalogo()
	_registrar_servicio()
	print("[M43] SFXManager listo (%d superficies, %d tonos, catálogo %s)" % [surfaces.size(), tones.size(), "OK" if not catalog.is_empty() else "FALTA"])

func _cargar_surfaces() -> void:
	if not FileAccess.file_exists(RUTA_SURFACES):
		push_warning("[M43] sfx_surfaces.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_SURFACES))
	if typeof(parsed) == TYPE_DICTIONARY:
		surfaces = parsed

func _cargar_tones() -> void:
	if not FileAccess.file_exists(RUTA_TONES):
		push_warning("[M43] sfx_tones.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_TONES))
	if typeof(parsed) == TYPE_DICTIONARY:
		tones = parsed

## Carga el catálogo de efectos (03-Diseno §3: efecto → variaciones).
func _cargar_catalogo() -> void:
	if not FileAccess.file_exists(RUTA_CATALOG):
		push_warning("[M43] sfx_catalog.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_CATALOG))
	if typeof(parsed) == TYPE_DICTIONARY:
		catalog = parsed

## Catálogo completo de efectos declarados en `sfx_catalog.json`.
func catalogo() -> Dictionary:
	return catalog

## Variaciones declaradas en el catálogo para un efecto/material.
## `material` aplica a "paso" y "romper"; para "colocar" pasar "" (familia única).
## Devuelve -1 si el efecto o la clave no existen.
func catalogo_variaciones(efecto: String, material: String = "") -> int:
	var sec: Variant = catalog.get(efecto)
	if typeof(sec) != TYPE_DICTIONARY:
		return -1
	var d: Dictionary = sec
	var clave: String = "variaciones" if (efecto == "colocar" or material.is_empty()) else material
	var v: Variant = d.get(clave, -1)
	if v is int or v is float:
		return int(v)
	return -1

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("sfx"):
		sr.register("sfx", self)

## Reproduce el sonido de una superficie (ej: "madera", "piedra").
## Prioridad 0-10. Devuelve la variación elegida o "" si se descartó.
func reproducir_superficie(superficie: String, prioridad: int = 5) -> String:
	var variaciones: Array = surfaces.get(superficie, {}).get("variaciones", [])
	if variaciones.is_empty():
		return ""
	var variacion := String(variaciones[randi() % variaciones.size()])
	_reproducir("superficie_%s" % superficie, prioridad)
	return variacion

## Reproduce un SFX directo con prioridad. Aplica límite duro del pool.
func reproducir(tipo: String, prioridad: int = 5) -> bool:
	return _reproducir(tipo, prioridad)

func _reproducir(tipo: String, prioridad: int) -> bool:
	var ahora := Time.get_ticks_msec()
	# Limpiar voces viejas (> 5 s)
	for i in range(_voces.size() - 1, -1, -1):
		if ahora - int(_voces[i]["tiempo_ms"]) > 5000:
			_voces.remove_at(i)
	if _voces.size() < MAX_VOCES:
		_voces.append({"tipo": tipo, "prioridad": prioridad, "tiempo_ms": ahora})
		return true
	# Pool lleno: buscar la voz de menor prioridad
	var idx_min := 0
	var min_prio := 999
	for i in range(_voces.size()):
		if int(_voces[i]["prioridad"]) < min_prio:
			min_prio = int(_voces[i]["prioridad"])
			idx_min = i
	if prioridad > min_prio:
		_voces[idx_min] = {"tipo": tipo, "prioridad": prioridad, "tiempo_ms": ahora}
		return true
	return false  # descartada (límite duro)

func voces_activas() -> int:
	return _voces.size()

## Devuelve la definición tonal de un SFX de UI/evento (03-Diseno §4).
## Devuelve {} si el SFX no está en la familia tonal.
func tono(nombre: String) -> Dictionary:
	var t: Variant = tones.get(nombre, {})
	return t if typeof(t) == TYPE_DICTIONARY else {}

## Nombres de toda la familia tonal definida en `sfx_tones.json`.
func tonos_disponibles() -> Array:
	return tones.keys()