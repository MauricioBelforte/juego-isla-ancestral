# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M69: FastTravelService — anclas de viaje rápido (data-driven anclas.json),
# desbloqueo por visita y solicitud de viaje por señal (la ejecución la hace
# M28/M59). Sin UI (iter 2 con M53/M57).

extends Node

signal ancla_desbloqueada(ancla_id: String)
signal viaje_solicitado(ancla: Dictionary)
## Viaje pedido pero no concedido: motivo "costo", "bloqueado" o "horario".
signal viaje_rechazado(ancla_id: String, motivo: String)

const RUTA_ANCLAS := "res://data/fasttravel/anclas.json"

var _anclas: Array = []
var _desbloqueadas: Dictionary = {}
## Índice id -> ancla para lookup O(1) (D52). Se llena en _cargar().
var _indice: Dictionary = {}
## Coste de viaje configurable (RF4/P3). Formato: {"moneda": int} o {"tiempo": int}.
var _costo_viaje: Dictionary = {}
## Validador de coste inyectable (M38/M59). Vacío = siempre se puede.
var _puede_pagar_fn: Callable = Callable()
## Validador temporal inyectable (tests/M29-M31). Vacío = usa los autoloads reales.
var _restriccion_temporal_fn: Callable = Callable()
## K.21 (M28): mapeo ids de isla del módulo náutico -> clave de isla de anclas.json.
var _map_islas: Dictionary = {}

## K.32: el estado del viaje rápido persiste (M59). Sin SaveManager (CI) no pasa nada.
## Los tests que crean instancias extra ponen `registra_en_save = false` ANTES de
## add_child para no colisionar la sección "fast_travel" con el servicio del boot.
var registra_en_save: bool = true

func _ready() -> void:
	_cargar()
	_conectar_waypoints_m28()
	if registra_en_save:
		_registrar_proveedor_guardado()


## Registra el servicio como proveedor de guardado (M59). Duck typing.
func _registrar_proveedor_guardado() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)


func get_section_name() -> String:
	return "fast_travel"


## Persistencia: desbloqueados (la sincronía ancla<->waypoint la reconstruye el juego).
func get_save_data() -> Dictionary:
	return {"desbloqueadas": _desbloqueadas.keys()}


func restore_save_data(data: Dictionary) -> void:
	var lista: Array = data.get("desbloqueadas", [])
	if typeof(lista) != TYPE_ARRAY:
		return
	for id_v in lista:
		_desbloqueadas[String(id_v)] = true


## K.21: llegar por barco a una isla (señal travel_arrived de M28) desbloquea
## las anclas de viaje rápido de ESA isla. Duck typing: sin M28 no pasa nada.
func _conectar_waypoints_m28() -> void:
	var ts := get_node_or_null("/root/TravelService")
	if ts == null or not ts.has_signal("travel_arrived"):
		return
	if not ts.travel_arrived.is_connected(_on_isla_descubierta):
		ts.travel_arrived.connect(_on_isla_descubierta)


func _on_isla_descubierta(island_id: String) -> void:
	var sid := String(island_id)
	var clave := sid.to_upper()
	if _map_islas.has(sid):
		clave = String(_map_islas[sid]).to_upper()
	for a in _anclas:
		if String(a.get("isla", "")).to_upper() == clave:
			desbloquear(String(a.get("id", "")))

## Mapeo opcional id-isla-M28 -> clave de isla del catálogo (ej: {"isla_principal": "RIZ"}).
func set_mapa_islas(m: Dictionary) -> void:
	_map_islas = m.duplicate(true)


func mapa_islas() -> Dictionary:
	return _map_islas.duplicate(true)

## K.24 (M122): captura de crash si el portal falla. El teleport lo ejecuta el
## caller (M28/M59) — este punto también queda disponible para el dueño si SU
## teleport explota. Duck typing: sin CrashReporter queda push_error local.
func reportar_falla_portal(ancla_id: String, mensaje: String) -> void:
	var stack: Array = ["[M69] portal ancla=%s" % ancla_id]
	var cr := get_node_or_null("/root/CrashReporter")
	if cr != null and cr.has_method("reportar_crash"):
		cr.reportar_crash("portal_fail", mensaje, stack)
	else:
		push_error("[M69] falla de portal en %s: %s" % [ancla_id, mensaje])

func _cargar() -> void:
	if not FileAccess.file_exists(RUTA_ANCLAS):
		push_warning("[M69] anclas.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_ANCLAS))
	if typeof(parsed) == TYPE_DICTIONARY:
		var viajes: Dictionary = parsed.get("viajes", {})
		for isla in viajes:
			for ancla in viajes[isla].get("anclas", []):
				ancla["isla"] = isla
				_anclas.append(ancla)
				_indice[String(ancla.get("id", ""))] = ancla
				if bool(ancla.get("desbloquea", false)):
					_desbloqueadas[String(ancla["id"])] = true
	print("[M69] FastTravelService listo (%d anclas, %d desbloqueadas)" % [_anclas.size(), _desbloqueadas.size()])

func anclas() -> Array:
	return _anclas

func anclas_desbloqueadas() -> Array:
	var out := []
	for a in _anclas:
		if _desbloqueadas.has(String(a.get("id", ""))):
			out.append(a)
	return out

func desbloquear(ancla_id: String) -> bool:
	if _desbloqueadas.has(ancla_id):
		return false
	_desbloqueadas[ancla_id] = true
	ancla_desbloqueada.emit(ancla_id)
	return true

func esta_desbloqueada(ancla_id: String) -> bool:
	return _desbloqueadas.has(ancla_id)

func solicitar_viaje(ancla_id: String) -> bool:
	if not _desbloqueadas.has(ancla_id):
		push_warning("[M69] Ancla no desbloqueada: %s" % ancla_id)
		viaje_rechazado.emit(ancla_id, "bloqueado")
		return false
	var a = _indice.get(ancla_id, null)
	if a == null:
		viaje_rechazado.emit(ancla_id, "inexistente")
		return false
	# K.24 (M122): portal roto = ancla declarada sin coordenadas. Se reporta el
	# crash al dueño y se rechaza sin emitir señal de viaje.
	if not (a.has("x") and a.has("z")):
		reportar_falla_portal(ancla_id, "ancla sin coordenadas (portal roto)")
		viaje_rechazado.emit(ancla_id, "portal")
		return false
	# K.22: restricción temporal (noche/tormenta, M29-31/M32). Los autoloads
	# reales mandan; `_restriccion_temporal_fn` inyecta el resultado en tests.
	if restriccion_temporal_activa():
		viaje_rechazado.emit(ancla_id, "horario")
		return false
	# RF4: el coste lo valida el destino (M59/M38). Si el adaptador declara que
	# no se puede pagar, no se emite el viaje. `puede_pagar_fn` es opcional.
	if _puede_pagar_fn.is_valid() and not bool(_puede_pagar_fn.call(ancla_id)):
		viaje_rechazado.emit(ancla_id, "costo")
		return false
	viaje_solicitado.emit(a)
	return true

## ── Índice O(1) (D52) ────────────────────────────────────────────────────

## Devuelve el diccionario de la ancla por id, o {} si no existe.
## Coste O(1): usa el índice, no recorre el Array.
func ancla_de(ancla_id: String) -> Dictionary:
	var a = _indice.get(ancla_id, null)
	return a if a != null else {}

## ── Costo de viaje (RF4 / P3) ────────────────────────────────────────────

## Fija el costo de viaje. Formato: {"moneda": int} y/o {"tiempo": int}.
## Un diccionario vacío (default) = viaje gratuito.
func set_costo_viaje(costo: Dictionary) -> void:
	_costo_viaje = costo.duplicate(true)

func set_puede_pagar_fn(fn: Callable) -> void:
	_puede_pagar_fn = fn

## ── Restricción temporal (K.22: noche / tormenta) ────────────────────────

func set_restriccion_temporal_fn(fn: Callable) -> void:
	_restriccion_temporal_fn = fn

## true = el viaje está bloqueado por hora del mundo (noche) o tormenta.
## Duck typing sobre los autoloads reales: si faltan, NO restringe (tests/CI).
## TORMENTA = 3 en el enum Clima de weather_service.gd (fallback numérico).
func restriccion_temporal_activa() -> bool:
	if _restriccion_temporal_fn.is_valid():
		return bool(_restriccion_temporal_fn.call())
	var gt := get_node_or_null("/root/GameTime")
	if gt != null and gt.has_method("es_de_dia") and not bool(gt.es_de_dia()):
		return true
	var we := get_node_or_null("/root/Weather")
	if we != null and we.has_method("get_clima"):
		var tormenta := 3
		var cl: Variant = we.get("Clima")
		if cl is Dictionary and cl.has("TORMENTA"):
			tormenta = int(cl["TORMENTA"])
		if int(we.get_clima()) == tormenta:
			return true
	return false

func costo_viaje() -> Dictionary:
	return _costo_viaje.duplicate(true)

## Coste en "unidades" del recurso configurado (para mostrar en el menú).
func costo_total() -> int:
	var total := 0
	for v in _costo_viaje.values():
		total += int(v)
	return total

## ── K.25 (M124): balance económico según distancia ──────────────────────

## Fórmula de costo por ancla inyectable (M124/M28 saben la posición real del
## jugador). Vacío = usa el costo global `_costo_viaje`.
var _costo_distancia_fn: Callable = Callable()

func set_costo_distancia_fn(fn: Callable) -> void:
	_costo_distancia_fn = fn

## Activa la fórmula cozy por defecto: 1 moneda + 1 cada 1200 u de distancia
## del CENTRO de la isla raíz (MundoRaiz, fuente de verdad), tope 8.
## Devuelve false si WorldRaiz no está disponible (no se activa nada).
func activar_costo_distancia_default() -> bool:
	var mr := get_node_or_null("/root/MundoRaiz")
	if mr == null or mr.get("CENTRO") == null:
		return false
	var centro: Vector2 = Vector2(mr.CENTRO)
	_costo_distancia_fn = func(a: Dictionary) -> int:
		var pos := Vector2(float(a.get("x", centro.x)), float(a.get("z", centro.y)))
		var d := pos.distance_to(centro)
		return clampi(1 + int(d / 1200.0), 1, 8)
	return true

## Costo POR VIAJE de una ancla: fórmula de distancia si hay, sino el global.
func costo_viaje_de(ancla_id: String) -> Dictionary:
	if _costo_distancia_fn.is_valid():
		var a = _indice.get(ancla_id, null)
		if a == null:
			return {}
		return {"moneda": int(_costo_distancia_fn.call(a))}
	return costo_viaje()

## Total de unidades del costo por viaje de una ancla (para el menú/M38).
func costo_total_de(ancla_id: String) -> int:
	var total := 0
	for v in costo_viaje_de(ancla_id).values():
		total += int(v)
	return total
