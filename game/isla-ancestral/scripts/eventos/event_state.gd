# Modelo: agnes-2.5-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M74: Eventos — Estado serializable por evento y año
#
# Persistible en GameState.M74. Maneja token anti-duplicado por año,
# participaciones, récords y historial.

extends RefCounted
class_name EventState

## Estados del evento
enum Estado { PENDIENTE, EN_CURSO, PARTICIPADO, NO_PARTICIPADO, CANCELADO }

var estado: Estado = Estado.PENDIENTE
var recompensas_recibidas: PackedStringArray = []
var mejor_puesto: int = 0
var anio_participacion: int = 0
var evento_id: StringName = &""
var anio: int = 0
## Token anti-duplicado: año en que se recibió la recompensa
var recompensa_token_anio: int = 0
## ¿Ya se usó una sorpresa esta semana?
var sorpresa_ya_usada: bool = false
## Día en que se canceló (para registro histórico)
var dia_cancelacion: int = 0
## Resultado de la participación (puesto, puntos, etc.)
var resultado: Dictionary = {}


func is_participated_this_year(anio_actual: int) -> bool:
	return estado == Estado.PARTICIPADO and anio_participacion == anio_actual


func puede_recibir_recompensa(anio_actual: int) -> bool:
	"""True si se puede entregar recompensa (no duplicada este año)."""
	return recompensa_token_anio != anio_actual


func marcar_recompensa_recibida(anio_actual: int) -> void:
	recompensa_token_anio = anio_actual
	estado = Estado.PARTICIPADO
	anio_participacion = anio_actual


func to_dict() -> Dictionary:
	return {
		"estado": estado,
		"recompensas_recibidas": recompensas_recibidas,
		"mejor_puesto": mejor_puesto,
		"anio_participacion": anio_participacion,
		"evento_id": str(evento_id),
		"anio": anio,
		"recompensa_token_anio": recompensa_token_anio,
		"sorpresa_ya_usada": sorpresa_ya_usada,
		"dia_cancelacion": dia_cancelacion,
		"resultado": resultado,
	}


static func from_dict(d: Dictionary) -> EventState:
	var es := EventState.new()
	es.estado = int(d.get("estado", 0))
	es.recompensas_recibidas = d.get("recompensas_recibidas", [])
	es.mejor_puesto = int(d.get("mejor_puesto", 0))
	es.anio_participacion = int(d.get("anio_participacion", 0))
	es.evento_id = d.get("evento_id", &"")
	es.anio = int(d.get("anio", 0))
	es.recompensa_token_anio = int(d.get("recompensa_token_anio", 0))
	es.sorpresa_ya_usada = d.get("sorpresa_ya_usada", false)
	es.dia_cancelacion = int(d.get("dia_cancelacion", 0))
	es.resultado = d.get("resultado", {})
	return es
