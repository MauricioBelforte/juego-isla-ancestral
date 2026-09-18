# Modelo: Atria-Dawn-Preview
# Plataforma: Kilo Code
# Fecha: 2026-09-18
#
# M164 (iter. 1 — parte data-driven): GemCurrency — moneda de acceso a la
# Isla de Combate. Designada como autoload "gem_currency" (patron M36:
# FaunaRegistry/FaunaManager). Persiste su estado via SaveManager (M59)
# con el provider GemSaveProvider (duck-typed, separado — AGENTS.md §15).
#
# Reglas cozy (checklist seccion B):
#  - Las gemas NUNCA se descartan (B.44) ni se pierden al morir (B.45).
#  - No se pueden comprar con dinero real en esta entrega (B.41/B.42 son
#    monetizacion pendiente — fuera de alcance del juego actual; ver
#    Notas del Agente en 04-Codigo.md).
#  - Unicamente se obtienen intercambiando herramientas encantadas por el
#    GemExchangeNPC (B.33-B.36) y derrotando enemigos (B.37-B.40).
class_name GemCurrency
extends Node

const VERSION_SAVE := 1
const SECCION_SAVE := "gemas_m164"

## Gemas actuales del jugador (cooldown cozy: nunca negativo).
var _gemas: int = 0

## Historial de transacciones para M71/M72 (hitos y logros): tipo + monto.
var _historial: Array[Dictionary] = []

signal gemas_cambiadas(nuevas: int)
signal gema_gastada(monto: int, destino: String)

## ── API publica (contrato 04-Codigo.md §2) ────────────────────────

func get_gems() -> int:
	return _gemas

func has_gems(amount: int) -> bool:
	return amount >= 0 and _gemas >= amount

## Agrega gemas (recompensa de combate o intercambio). Nunca falla.
func add_gems(amount: int, motivo: String = "combate") -> void:
	if amount <= 0:
		return
	_gemas += amount
	_historial.append({"tipo": "ganancia", "monto": amount, "motivo": motivo})
	gemas_cambiadas.emit(_gemas)

## Gasta gemas. Retorna false si no hay saldo suficiente (no gastar nada).
func spend_gems(amount: int, destino: String = "") -> bool:
	if amount <= 0:
		return true
	if _gemas < amount:
		return false
	_gemas -= amount
	_historial.append({"tipo": "gasto", "monto": amount, "destino": destino})
	gema_gastada.emit(amount, destino)
	gemas_cambiadas.emit(_gemas)
	return true

## ── Intercambio de herramientas encantadas (B.33-B.36) ─────────────
## T1=1, T2=2, T3=3, T4=5 gemas segun tier de la herramienta encantada.
static func valor_cambio_por_tier(tier: int) -> int:
	match tier:
		1: return 1
		2: return 2
		3: return 3
		4: return 5
		_: return 0

## Rango de gemas al derrotar un enemigo por categoria (B.37-B.40).
## Vector2i(min, max); el rollo concreto lo decide M64 con el PRNG del
## spawner — aqui solo la tabla canonica.
static func rango_gemas_categoria(categoria: int) -> Vector2i:
	# EnemyData.Categoria: 0=BASICO 1=MEDIO 2=FUERTE 3=JEFE
	match categoria:
		0: return Vector2i(1, 2)
		1: return Vector2i(2, 3)
		2: return Vector2i(3, 5)
		3: return Vector2i(5, 15)
	return Vector2i(0, 0)

## ── Persistencia M59 (ISaveProvider duck-typed) ────────────────────

func get_section_name() -> String:
	return SECCION_SAVE

func get_save_data() -> Dictionary:
	return {
		"version": VERSION_SAVE,
		"gemas": _gemas,
		"historial": _historial.duplicate(true),
	}

func restore_save_data(data: Dictionary) -> void:
	if data.is_empty():
		return
	var v: int = int(data.get("version", 0))
	if v < VERSION_SAVE:
		# Version antigua: no sobreescribir el estado actual (patron M36).
		return
	_gemas = max(0, int(data.get("gemas", 0)))
	var h = data.get("historial", [])
	if h is Array:
		_historial.clear()
		for entry in h:
			if entry is Dictionary:
				_historial.append(entry)
	gemas_cambiadas.emit(_gemas)
