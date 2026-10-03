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
#
# Lote B3 (2026-10-03, mimo-v2.6-flash-free): categorías de §2 (UI/mundo/
# bloque/paso con nivel_s2 + prioridad interna invertida), límites de §5
# (≤ 6 del mismo tipo, UI máx 2 simultáneos), pool **preallocado a 24
# slots** y PRNG cacheado con semilla del reloj M29.

extends Node

const MAX_VOCES := 24
const RUTA_SURFACES := "res://data/audio/sfx_surfaces.json"
const RUTA_TONES := "res://data/audio/sfx_tones.json"
const RUTA_CATALOG := "res://data/audio/sfx_catalog.json"

# 03-Diseno §2: niveles del diseño (1 = alta, 4 = baja) y la prioridad
# interna del pool (MAYOR gana: 10 reemplaza a 1 en el corte). `nivel_s2`
# conserva la numeración del documento; `prioridad` es su inversa porque
# `_reproducir` resuelve el corte con `prioridad > min_prio`.
# `max_simultaneos` solo lo declara §2 para UI (máx 2); las demás filas
# de §2 no fijan límite numérico, así que no lo llevan.
const CATEGORIAS := {
	"ui":     {"nivel_s2": 1, "prioridad": 10, "max_simultaneos": 2, "nunca_corta": true},
	"mundo":  {"nivel_s2": 2, "prioridad": 7},
	"bloque": {"nivel_s2": 3, "prioridad": 5},
	"paso":   {"nivel_s2": 4, "prioridad": 1, "se_corta_primero": true},
}
# 03-Diseno §5: ≤ 6 simultáneos del mismo SFX (los excesos se cortan,
# jamás se apilan).
const MAX_MISMO_TIPO := 6

var surfaces: Dictionary = {}
var tones: Dictionary = {}
var catalog: Dictionary = {}
var _voces: Array = []  # MAX_VOCES slots preallocados (§5); null = libre
var _rng := RandomNumberGenerator.new()  # único y cacheado: sin allocs por evento

func _ready() -> void:
	_voces.resize(MAX_VOCES)  # prealocación estática de 24 voces (§5)
	_rng.seed = _semilla_rng()
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

## Semilla del PRNG de variaciones: se resuelve UNA sola vez en `_ready()`,
## nunca por evento (03-Diseno §5: "sin allocs por frame"). Mezcla la
## semilla diaria de M29 (`GameTime`, si está) con la entropía del motor
## para que dos partidas no compartan el patrón de variaciones.
func _semilla_rng() -> int:
	var m29: int = 0
	var gt: Node = Engine.get_main_loop().root.get_node_or_null("GameTime")
	if gt != null and gt.has_method("dia_absoluto"):
		m29 = int(gt.dia_absoluto()) * 1000000 + int(gt.get_hora()) * 10000 + int(gt.get_minuto()) * 100
	return int(randi()) ^ m29 ^ 0x4D3433  # "M43"

## Categoría de 03-Diseno §2 que corresponde a una llamada. Si `categoria`
## viene dada se respeta; si no, se deduce de la prioridad (≥8 UI, ≥5 mundo,
## ≥3 bloque, resto pasos). Devuelve "" si la categoría no existe.
func categoria_de(prioridad: int, categoria: String = "") -> String:
	if not categoria.is_empty():
		return categoria if CATEGORIAS.has(categoria) else ""
	if prioridad >= 8:
		return "ui"
	if prioridad >= 5:
		return "mundo"
	if prioridad >= 3:
		return "bloque"
	return "paso"

func _contar_tipo(tipo: String) -> int:
	var n := 0
	for i in range(MAX_VOCES):
		var v: Variant = _voces[i]
		if v != null and String(v["tipo"]) == tipo:
			n += 1
	return n

func _contar_categoria(cat: String) -> int:
	var n := 0
	for i in range(MAX_VOCES):
		var v: Variant = _voces[i]
		if v != null and String(v.get("categoria", "")) == cat:
			n += 1
	return n

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
	_reproducir("superficie_%s" % superficie, prioridad, "paso")
	return variacion

## Reproduce un SFX directo con prioridad. Aplica límite duro del pool.
func reproducir(tipo: String, prioridad: int = 5, categoria: String = "") -> bool:
	return _reproducir(tipo, prioridad, categoria)

func _reproducir(tipo: String, prioridad: int, categoria: String = "") -> bool:
	var ahora := Time.get_ticks_msec()
	# Limpiar voces viejas (> 5 s) -> slot libre del pool preallocado
	for i in range(MAX_VOCES):
		var v: Variant = _voces[i]
		if v != null and ahora - int(v["tiempo_ms"]) > 5000:
			_voces[i] = null
	# §5: ≤ 6 simultáneos del mismo SFX (los excesos se cortan, jamás apilan)
	if _contar_tipo(tipo) >= MAX_MISMO_TIPO:
		return false
	# §2: límite por categoría (solo UI declara máx 2 simultáneos)
	var cat: String = categoria_de(prioridad, categoria)
	if not cat.is_empty() and CATEGORIAS[cat].has("max_simultaneos"):
		if _contar_categoria(cat) >= int(CATEGORIAS[cat]["max_simultaneos"]):
			return false
	# Slot libre en el pool preallocado (24 fijos, sin append)
	for i in range(MAX_VOCES):
		if _voces[i] == null:
			_voces[i] = {"tipo": tipo, "prioridad": prioridad, "categoria": cat, "tiempo_ms": ahora}
			return true
	# Pool lleno: corta la de menor prioridad si la nueva es mayor
	var idx_min := -1
	var min_prio := 999
	for i in range(MAX_VOCES):
		var p := int(_voces[i]["prioridad"])
		if p < min_prio:
			min_prio = p
			idx_min = i
	if idx_min >= 0 and prioridad > min_prio:
		_voces[idx_min] = {"tipo": tipo, "prioridad": prioridad, "categoria": cat, "tiempo_ms": ahora}
		return true
	return false  # descartada (límite duro)

func voces_activas() -> int:
	var n := 0
	for i in range(MAX_VOCES):
		if _voces[i] != null:
			n += 1
	return n

## Devuelve la definición tonal de un SFX de UI/evento (03-Diseno §4).
## Devuelve {} si el SFX no está en la familia tonal.
func tono(nombre: String) -> Dictionary:
	var t: Variant = tones.get(nombre, {})
	return t if typeof(t) == TYPE_DICTIONARY else {}

## Nombres de toda la familia tonal definida en `sfx_tones.json`.
func tonos_disponibles() -> Array:
	return tones.keys()