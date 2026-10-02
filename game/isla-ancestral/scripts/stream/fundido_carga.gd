# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-02
#
# M63 §6 (L99): fundido (fade) de la pantalla de carga hacia la escena.
# Maquina de estados PURA (sin nodo): la pantalla llama `avanzar(delta)` cada
# frame y consulta `alpha()`; cuando `terminado()` es true, oculta su CanvasLayer.
# §6/§6-bis: la transicion corta (Fast Travel) nunca supera DURACION_MAX (2 s).
# ⚠️ class_name: helper de logica (NO autoload — GUIA-GODOT §9.17).

class_name FundidoCarga
extends RefCounted

enum Estado { INACTIVO, FUNDIENDO, TERMINADO }

## Tope de duracion (§6: "transicion corta (<= 2 s)").
const DURACION_MAX: float = 2.0
const DURACION_DEFAULT: float = 0.4

var _estado: int = Estado.INACTIVO
var _t: float = 0.0
var _duracion: float = DURACION_DEFAULT


## Inicia un fundido de `duracion` segundos (acotada a [0, DURACION_MAX]).
## IDEMPOTENTE: re-iniciar mientras funde REINICIA el reloj (no acumula).
## Duracion <= 0 -> el fundido nace TERMINADO (alpha 0 inmediato).
func iniciar(duracion: float = DURACION_DEFAULT) -> void:
	_duracion = acotar_duracion(duracion)
	_t = 0.0
	_estado = Estado.TERMINADO if _duracion <= 0.0 else Estado.FUNDIENDO


## Avanza el fundido. `delta` negativo se ignora (nunca retrocede).
func avanzar(delta: float) -> void:
	if _estado != Estado.FUNDIENDO:
		return
	_t += maxf(delta, 0.0)
	if _t >= _duracion:
		_t = _duracion
		_estado = Estado.TERMINADO


## Opacidad de la pantalla de carga: 1.0 (visible) -> 0.0 (oculta).
func alpha() -> float:
	if _estado == Estado.INACTIVO:
		return 1.0
	if _estado == Estado.TERMINADO or _duracion <= 0.0:
		return 0.0
	return clampf(1.0 - (_t / _duracion), 0.0, 1.0)


## Progreso del fundido en [0.0, 1.0].
func progreso() -> float:
	if _estado == Estado.INACTIVO:
		return 0.0
	if _estado == Estado.TERMINADO or _duracion <= 0.0:
		return 1.0
	return clampf(_t / _duracion, 0.0, 1.0)


func terminado() -> bool:
	return _estado == Estado.TERMINADO


func estado() -> int:
	return _estado


## Acota una duracion a [0, DURACION_MAX] (§6: transicion corta).
static func acotar_duracion(duracion: float) -> float:
	return clampf(duracion, 0.0, DURACION_MAX)
