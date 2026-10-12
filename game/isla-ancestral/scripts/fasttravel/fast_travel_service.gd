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
## Viaje pedido pero no concedido: motivo "costo" o "bloqueado".
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

func _ready() -> void:
	_cargar()

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

func costo_viaje() -> Dictionary:
	return _costo_viaje.duplicate(true)

## Coste en "unidades" del recursa configurado (para mostrar en el menú).
func costo_total() -> int:
	var total := 0
	for v in _costo_viaje.values():
		total += int(v)
	return total
