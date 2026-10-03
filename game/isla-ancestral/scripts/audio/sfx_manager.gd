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
#
# Lote B4 (2026-10-03, mimo-v2.6-flash-free): API pública de 04-Codigo §2
# — `reproducir(efecto, pos, prioridad, categoria)` (firma de §2, el 2º
# argumento pasa a ser `pos`), `reproducir_localizado`,
# `configurar_volumen(bus, dB)` (delega en AudioConfig/M91) y
# `pausar()/reanudar()` con purga de residuos.
#
# Lote B5 (2026-10-03, mimo-v2.6-flash-free): ducking de diálogo (F92/F95) —
# `ducking_dialogo()` baja el bus SFX 6 dB y se suscribe en `_ready()` a
# `DialogueManager` (M21) **sin modificar sus archivos** (solo escucha
# `dialogue_started`/`dialogue_ended`).
#
# Lote B6 (2026-10-03, mimo-v2.6-flash-free): 7 suscripciones de §3 a
# autoloads reales (logros, crafting, tienda) + `_conectar_si()` defensivo
# (`has_signal` antes de `connect`).

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
var _pausado: bool = false  # API §2 pausar()/reanudar()
var _ducking: bool = false  # F92: ducking de diálogo activo
var _pausa_inicio: int = 0

func _ready() -> void:
	_voces.resize(MAX_VOCES)  # prealocación estática de 24 voces (§5)
	_rng.seed = _semilla_rng()
	_cargar_surfaces()
	_cargar_tones()
	_cargar_catalogo()
	_registrar_servicio()
	_conectar_dialogos()
	_conectar_autoloads()
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
## 04-Codigo §2: `reproducir(efecto, pos)`. `pos = null` es un SFX 2D (UI);
## con `Vector3` se registra como espacial (la emisión 3D queda a la espera de
## `AudioStreamPlayer3D`, §7). `prioridad`/`categoria` son de §2 y §5.
func reproducir(efecto: String, pos: Variant = null, prioridad: int = 5, categoria: String = "") -> bool:
	return _reproducir(efecto, prioridad, categoria, pos)

## 04-Codigo §2: `reproducir_localizado(tipo, material, pos)`. Resuelve las
## variaciones del material en el catálogo §3 y registra la posición. Devuelve
## la variación elegida o "" si el tipo/material no existe en §3.
func reproducir_localizado(tipo: String, material: String, pos: Vector3) -> String:
	var variaciones := _variaciones_de(tipo, material)
	if variaciones.is_empty():
		return ""
	var v := String(variaciones[_rng.randi_range(0, variaciones.size() - 1)])
	_reproducir("%s_%s" % [tipo, material], 5, tipo, pos)
	return v

## §3: variaciones de un (tipo, material). "paso" lee `sfx_surfaces.json`
## (nombres reales); "romper"/"colocar" solo declaran conteo en el catálogo,
## así que los nombres se generan por convención `<tipo>_<material>_<n>`.
func _variaciones_de(tipo: String, material: String) -> Array:
	if tipo == "paso":
		return surfaces.get(material, {}).get("variaciones", [])
	var n := catalogo_variaciones(tipo, material if tipo != "colocar" else "")
	if n <= 0:
		return []
	var pref: String = "colocar_" if tipo == "colocar" else "%s_%s_" % [tipo, material]
	var out: Array = []
	for i in range(n):
		out.append("%s%d" % [pref, i + 1])
	return out

## F92/F95: suscripción a M21. Se conecta solo si el autoload existe; los
## archivos de `dialogue_manager.gd` NO se modifican (M43 únicamente escucha).
func _conectar_dialogos() -> void:
	var dm := get_node_or_null("/root/DialogueManager")
	if dm == null:
		return
	if not dm.dialogue_started.is_connected(_on_dialogue_started):
		dm.dialogue_started.connect(_on_dialogue_started)
	if not dm.dialogue_ended.is_connected(_on_dialogue_ended):
		dm.dialogue_ended.connect(_on_dialogue_ended)

func _on_dialogue_started(_dialogue_id: String) -> void:
	ducking_dialogo(true)

func _on_dialogue_ended(_dialogue_id: String, _last_node_id: String) -> void:
	ducking_dialogo(false)

## §3: enlaces con otros módulos. Solo M43 cambia: cada nodo se toma con
## `get_node_or_null` y solo se conecta si `has_signal` — si otro módulo renombra
## su señal, M43 lo ignora en vez de romper el arranque (§12.2).
func _conectar_autoloads() -> void:
	_conectar_si("Achievements", "logro_desbloqueado", _on_logro_desbloqueado)
	_conectar_si("Crafting", "crafting_completed", _on_crafting_completed)
	_conectar_si("Crafting", "crafting_failed", _on_crafting_failed)
	_conectar_si("ShopManager", "compra_exitosa", _on_compra_exitosa)
	_conectar_si("ShopManager", "venta_exitosa", _on_venta_exitosa)
	_conectar_si("ShopManager", "compra_rechazada", _on_compra_rechazada)
	_conectar_si("ShopManager", "venta_rechazada", _on_venta_rechazada)

func _conectar_si(nodo: String, senal: String, cb: Callable) -> void:
	var n := get_node_or_null("/root/" + nodo)
	if n == null or not n.has_signal(senal):
		return
	if not n.is_connected(senal, cb):
		n.connect(senal, cb)

## §3 M46: logro → familia tonal §4 (arpegio de tríada mayor, prioridad 10).
func _on_logro_desbloqueado(_logro_id: String, _nombre: String) -> void:
	reproducir("logro", null, 10)

## §3 M20: craft exitoso → `crafting_exito` (§4).
func _on_crafting_completed(_recipe: Variant, _cantidad: int) -> void:
	reproducir("crafting_exito", null, 6)

## §3 M20: craft fallido → `error` amable (§4: 0.4 s, nunca buzz).
func _on_crafting_failed(_recipe: Variant, _motivo: String) -> void:
	reproducir("error", null, 10)

## §3 M45: compra → `compra` (2 monedas + nota mayor, §4).
func _on_compra_exitosa(_shop_id: String, _item_id: String, _cantidad: int, _total: int, _precio: int) -> void:
	reproducir("compra", null, 6)

## §3 M45: venta → `venta` (monedas + nota media, distinto de compra, §4).
func _on_venta_exitosa(_shop_id: String, _item_id: String, _cantidad: int, _total: int, _precio: int) -> void:
	reproducir("venta", null, 6)

## §3 M45: transacción rechazada → `error` amable.
## `Motivo` es un enum con class_name de otro script: se recibe como Variant
## para no acoplar M43 a su tipo (GUIA-GODOT §9.50).
func _on_compra_rechazada(_shop_id: String, _item_id: String, _motivo: Variant) -> void:
	reproducir("error", null, 10)

func _on_venta_rechazada(_shop_id: String, _item_id: String, _motivo: Variant) -> void:
	reproducir("error", null, 10)

## F92: SFX -6 dB mientras hay diálogo (M21). Idempotente: repetir la misma
## llamada no acumula atenuación.
func ducking_dialogo(activar: bool) -> void:
	if activar == _ducking:
		return
	_ducking = activar
	_aplicar_ganancia_sfx(-6.0 if _ducking else 0.0)

## F95: el SFX queda por debajo del diálogo en la jerarquía de canales (M91
## ya separa Voice/SFX). Se recalcula la base desde AudioConfig en CADA cambio
## para no arrastrar un volumen obsoleto si el usuario movió el slider del
## diálogo mientras ducking estaba activo (M91 es el dueño del persistido).
func _aplicar_ganancia_sfx(delta_db: float) -> void:
	var idx := AudioServer.get_bus_index("SFX")
	if idx < 0:
		return
	AudioServer.set_bus_volume_db(idx, _db_base_sfx() + delta_db)

## Volumen base del bus SFX según M91 (lineal -> dB). Sin M91 devuelve 0 dB.
func _db_base_sfx() -> float:
	var ac: Node = Engine.get_main_loop().root.get_node_or_null("AudioConfig")
	if ac != null and ac.has_method("get_volumen"):
		var lin := float(ac.get_volumen("SFX"))
		if lin > 0.0:
			return 20.0 * log(lin) / log(10.0)
	return 0.0

## 04-Codigo §2: volumen de un bus en dB (0 = sin cambio, -6 dB ≈ 50 %).
## Delega en AudioConfig (M91), dueño del árbol de buses y de la persistencia:
## M43 NO toca `scripts/configuracion/` ni su data.
func configurar_volumen(bus: String, db: float) -> bool:
	var ac: Node = Engine.get_main_loop().root.get_node_or_null("AudioConfig")
	if ac == null or not ac.has_method("set_volumen"):
		return false
	var lineal: float = 0.0 if db <= -80.0 else pow(10.0, db / 20.0)
	return bool(ac.set_volumen(bus, clampf(lineal, 0.0, 1.0)))

## 04-Codigo §2: congela la reproducción de SFX. API propia de M43 — el
## enlace con la pausa global de M29 (`GameTime.pausa()`) lo hace el llamador.
func pausar() -> void:
	if _pausado:
		return
	_pausado = true
	_pausa_inicio = Time.get_ticks_msec()

## Reanuda y purga los residuos (F99): las voces no envejecen mientras el
## juego estuvo pausado (su `tiempo_ms` se desplaza por esa duración) y las
## que ya estaban vencidas se purgan aquí mismo.
func reanudar() -> void:
	if not _pausado:
		return
	_pausado = false
	var delta := Time.get_ticks_msec() - _pausa_inicio
	for i in range(MAX_VOCES):
		var v: Variant = _voces[i]
		if v != null:
			v["tiempo_ms"] = int(v["tiempo_ms"]) + delta
	_purgar_vencidas()

func _purgar_vencidas() -> void:
	var ahora := Time.get_ticks_msec()
	for i in range(MAX_VOCES):
		var v: Variant = _voces[i]
		if v != null and ahora - int(v["tiempo_ms"]) > 5000:
			_voces[i] = null


func _reproducir(tipo: String, prioridad: int, categoria: String = "", pos: Variant = null) -> bool:
	if _pausado:
		return false  # §2: en pausa no se emite nada nuevo
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
			_voces[i] = {"tipo": tipo, "prioridad": prioridad, "categoria": cat, "tiempo_ms": ahora, "pos": pos}
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
		_voces[idx_min] = {"tipo": tipo, "prioridad": prioridad, "categoria": cat, "tiempo_ms": ahora, "pos": pos}
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