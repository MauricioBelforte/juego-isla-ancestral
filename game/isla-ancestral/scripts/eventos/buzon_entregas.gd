# Modelo: stepfun-step-5-preview (Kilo Code)
# Fecha: 2026-10-11
#
# M74 Eventos — Buzón de entregas (RF6.9 / RF6.10).
#
# Cuando una recompensa de evento NO entra en el inventario (M14 lleno), se
# guarda acá en vez de perderse. El jugador la reclama cuando tenga espacio.
#
# Reglas:
#   * Retención mínima de RETENCION_DIAS (30) días del juego SIN pérdida.
#   * Reclamar reintenta la entrega al inventario; si sigue lleno, el pendiente
#     se queda (no se pierde).
#   * Persistente (M60) con esquema versionado.
#
# Núcleo puro: sin nodos ni autoloads, testeable en headless.

class_name BuzonEntregas
extends RefCounted

## Días mínimos que una entrega permanece en el buzón (RF6.10).
const RETENCION_DIAS: int = 30

## Versión del esquema de guardado.
const VERSION: int = 1

var _entradas: Array = []
var _ultimo_id: int = 0

# ── API ──────────────────────────────────────────────────────────────────

## Guarda una entrega pendiente. Devuelve el id de la entrada.
## `recompensa` es el Dictionary de `RecompensaDef.to_dict()`.
func agregar(evento_id: StringName, recompensa: Dictionary, dia_absoluto: int) -> int:
	_ultimo_id += 1
	_entradas.append({
		"id": _ultimo_id,
		"evento_id": str(evento_id),
		"recompensa": (recompensa as Dictionary).duplicate(true),
		"dia_absoluto": int(dia_absoluto),
	})
	return _ultimo_id

## Pendientes actuales (copia, sin aliasing).
func pendientes() -> Array:
	var out: Array = []
	for e in _entradas:
		out.append((e as Dictionary).duplicate(true))
	return out

func cantidad() -> int:
	return _entradas.size()

func esta_vacio() -> bool:
	return _entradas.is_empty()

## Reclama la entrada `entry_id` y la QUITA del buzón. Devuelve el Dictionary
## de la recompensa (o {} si no existe). Reintentar la entrega al inventario es
## responsabilidad del llamador (M74 manager), que conoce M14.
func reclamar(entry_id: int) -> Dictionary:
	for i in range(_entradas.size()):
		var e: Dictionary = _entradas[i]
		if int(e.get("id", 0)) == int(entry_id):
			_entradas.remove_at(i)
			return (e.get("recompensa", {}) as Dictionary).duplicate(true)
	return {}

## Devuelve (sin quitar) la recompensa de una entrada.
func ver(entry_id: int) -> Dictionary:
	for e in _entradas:
		if int((e as Dictionary).get("id", 0)) == int(entry_id):
			return (e as Dictionary).duplicate(true)
	return {}

## Entradas vencidas (más viejas que RETENCION_DIAS). No las borra.
func vencidas(dia_actual: int) -> Array:
	var out: Array = []
	for e in _entradas:
		if int((e as Dictionary).get("dia_absoluto", 0)) + RETENCION_DIAS < int(dia_actual):
			out.append((e as Dictionary).duplicate(true))
	return out

## Purga las vencidas. Devuelve cuántas se eliminaron.
## Con RETENCION_DIAS=30 ninguna entrada se pierde antes de los 30 días.
func purgar(dia_actual: int) -> int:
	var vivas: Array = []
	var borradas: int = 0
	for e in _entradas:
		if int((e as Dictionary).get("dia_absoluto", 0)) + RETENCION_DIAS < int(dia_actual):
			borradas += 1
			continue
		vivas.append(e)
	_entradas = vivas
	return borradas

func vaciar() -> void:
	_entradas.clear()
	_ultimo_id = 0

# ── Persistencia ─────────────────────────────────────────────────────────

func to_dict() -> Dictionary:
	return {
		"version": VERSION,
		"ultimo_id": _ultimo_id,
		"entradas": _entradas.duplicate(true),
	}

func from_dict(d: Dictionary) -> void:
	var v: int = int(d.get("version", 0))
	if v != VERSION:
		push_warning("[BuzonEntregas] versión de esquema %d inesperada (esperaba %d)" % [v, VERSION])
	_entradas.clear()
	var crudo: Variant = d.get("entradas", [])
	if crudo is Array:
		for e in crudo as Array:
			if e is Dictionary:
				_entradas.append((e as Dictionary).duplicate(true))
	_ultimo_id = int(d.get("ultimo_id", _entradas.size()))

## Round-trip estático (para tests y carga).
static func desde_dict(d: Dictionary) -> BuzonEntregas:
	var b := BuzonEntregas.new()
	b.from_dict(d)
	return b
