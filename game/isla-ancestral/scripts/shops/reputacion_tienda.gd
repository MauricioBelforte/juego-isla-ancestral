# Modelo: ox-alpha
# Plataforma: Cline
# Fecha: 2026-08-25
#
# M39: Reputación de tienda del jugador (datos puros)
# Niveles 0-5, cozy: SIN decaimiento, sin límite temporal (01-Requerimientos §Reputación).
# La UI (M53) consume esto después; aquí solo estado + reglas.
extends RefCounted

## Umbrales de XP por nivel (índice = nivel actual; XP acumulada necesaria para el siguiente)
const UMBRALES_NIVEL: Array[int] = [0, 50, 150, 350, 700, 1200]
const NIVEL_MAXIMO: int = 5

## Reputación ganada por tipo de venta (tabla del diseño)
enum MotivoVenta {
	NORMAL,        # +1
	GRANDE,        # +3 (3+ items en una visita)
	ITEM_RARO,     # +2
	VIAJERO,       # +5 (venta a NPC de otra isla)
	EVENTO_FERIA,  # +2 extra durante evento M73
}
const REP_POR_MOTIVO := {
	MotivoVenta.NORMAL: 1,
	MotivoVenta.GRANDE: 3,
	MotivoVenta.ITEM_RARO: 2,
	MotivoVenta.VIAJERO: 5,
	MotivoVenta.EVENTO_FERIA: 2,  # se SUMA al motivo base
}

var xp_actual: int = 0
var nivel_actual: int = 0

signal nivel_subio(nuevo_nivel: int)

## Registra reputación por una venta. `extra_evento=true` añade el bonus de feria.
func registrar_venta(motivo: MotivoVenta, extra_evento: bool = false) -> void:
	var ganancia := int(REP_POR_MOTIVO.get(motivo, 1))
	if extra_evento and motivo != MotivoVenta.EVENTO_FERIA:
		ganancia += int(REP_POR_MOTIVO[MotivoVenta.EVENTO_FERIA])
	xp_actual += ganancia
	_recalcular_nivel()

func _recalcular_nivel() -> void:
	# Nunca baja (sin decaimiento): solo sube
	while nivel_actual < NIVEL_MAXIMO and xp_actual >= UMBRALES_NIVEL[nivel_actual + 1]:
		nivel_actual += 1
		nivel_subio.emit(nivel_actual)

## Progreso hacia el siguiente nivel (para barra de UI M53): 0.0..1.0
func progreso_nivel() -> float:
	if nivel_actual >= NIVEL_MAXIMO:
		return 1.0
	var base := UMBRALES_NIVEL[nivel_actual]
	var siguiente := UMBRALES_NIVEL[nivel_actual + 1]
	return clampf(float(xp_actual - base) / float(siguiente - base), 0.0, 1.0)

## Desbloqueos por nivel (tablas del diseño) — consultas puras para otros módulos
func npc_especial_desbloqueado() -> String:
	match nivel_actual:
		3: return "mercader_viajero"
		4: return "coleccionista"
		5: return "sabio_anciano"
	return ""

func multiplicador_precio_venta() -> float:
	match nivel_actual:
		4: return 1.15   # bandera de la tienda
		5: return 1.20   # corona de comerciante
	return 1.0

func slots_extra_stock() -> int:
	return 10 if nivel_actual >= 3 else 0   # caja fuerte

func serializar() -> Dictionary:
	return {"xp": xp_actual, "nivel": nivel_actual}

func deserializar(d: Dictionary) -> void:
	xp_actual = int(d.get("xp", 0))
	nivel_actual = clampi(int(d.get("nivel", 0)), 0, NIVEL_MAXIMO)
	_recalcular_nivel()
