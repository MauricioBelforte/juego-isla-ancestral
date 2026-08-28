extends Node

## Módulo 19: NPC y Vecinos — Estado emocional del vecino
##
## Maneja el ánimo base persistido + deltas calculados por clima, hora, eventos.
## clamp(-1.0, 1.0) en todo momento.

signal animo_cambio(valor: float, causa: String)

var animo_base: float = 0.0  ## Persistido en guardado
var _delta_clima: float = 0.0
var _delta_estacion: float = 0.0
var _delta_hora: float = 0.0
var _delta_eventos: float = 0.0
var _delta_temporal: float = 0.0  ## Deltas de regalos/interacciones (se desvanecen)
var _last_causa: String = ""


## Aplica un delta al ánimo con causa descriptiva.
func aplicar_delta(delta: float, causa: String) -> void:
	_delta_temporal += delta
	_last_causa = causa
	animo_cambio.emit(animo_efectivo(), causa)
	print("[Mood] %s: %+.2f (%s) → efectivo=%.2f" % [causa, delta, causa, animo_efectivo()])


## Retorna el ánimo efectivo (base + todos los deltas, clampado).
func animo_efectivo() -> float:
	var total: float = animo_base + _delta_clima + _delta_estacion + _delta_hora + _delta_eventos + _delta_temporal
	return clampf(total, -1.0, 1.0)


## Factor para tono de diálogos (M21): 0.5–1.5 según ánimo.
func factor_dialogo() -> float:
	return 1.0 + animo_efectivo() * 0.5


## Factor para intensidad de reacciones a regalos.
func factor_regalo() -> float:
	return 1.0 + absf(animo_efectivo()) * 0.3


## Estado emocional legible.
func estado_emocional() -> String:
	var e: float = animo_efectivo()
	if e > 0.3:
		return "alegre"
	elif e < -0.3:
		return "triste"
	return "neutral"


## Setea deltas de clima (desde M31/M32).
func set_delta_clima(delta: float) -> void:
	_delta_clima = delta


## Setea delta de estación (desde M29).
func set_delta_estacion(delta: float) -> void:
	_delta_estacion = delta


## Setea delta de hora (desde M29).
func set_delta_hora(delta: float) -> void:
	_delta_hora = delta


## Llamado por M29/M73 para eventos especiales.
func set_delta_eventos(delta: float) -> void:
	_delta_eventos = delta


## Desvanece el delta temporal (llamar cada día nuevo).
func desvanecer_temporal(factor: float = 0.8) -> void:
	_delta_temporal *= factor
	if absf(_delta_temporal) < 0.01:
		_delta_temporal = 0.0


## Serializa para guardado.
func serializar() -> Dictionary:
	return {
		"animo_base": animo_base,
		"delta_clima": _delta_clima,
		"delta_estacion": _delta_estacion,
		"delta_hora": _delta_hora,
	}


## Deserializa desde guardado.
func cargar(datos: Dictionary) -> void:
	animo_base = float(datos.get("animo_base", 0.0))
	_delta_clima = float(datos.get("delta_clima", 0.0))
	_delta_estacion = float(datos.get("delta_estacion", 0.0))
	_delta_hora = float(datos.get("delta_hora", 0.0))
