# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M28: Viajes — BoatRoute (Resource). Metadatos de un trayecto origen → destino.
# Las rutas viven en data/viajes/rutas.json (data-driven, coherentes con
# balance travel.json de M93); BoatRoute es la representación runtime
# (la curva 3D llega en V2 — sample_position lineal hasta entonces).
class_name BoatRoute
extends Resource

@export var route_id: StringName = &""
@export var origin_island_id: String = ""
@export var destination_island_id: String = ""
## Duración base de la travesía en segundos reales (20-60 s según diseño §3.2)
@export var base_duration_seconds: float = 30.0
## Coste del boleto en AO (coherente con balance/travel.json de M93)
@export var cost_coins: int = 0
## Desbloqueo por M22 (flag de WorldState; "" = siempre disponible)
@export var required_quest: StringName = &""
## Rutas secretas: solo visibles si required_quest está activo (M22)
@export var is_secret: bool = false
## Línea nocturna (M29): solo embarque 21:00-05:00
@export var is_night_line: bool = false
## Temporada requerida (M29): "" = todas (coherente con travel.json)
@export var temporada: String = ""
## Progreso persistible en V2 (curva); V0: línea recta
@export var curve: Curve3D = null


## Posición del barco en el tramo t∈[0,1]. V2 usará curve.sample_baked.
func sample_position(t: float) -> Vector3:
	if curve != null:
		return curve.sample_baked(float(curve.get_baked_length()) * clampf(t, 0.0, 1.0))
	return Vector3(clampf(t, 0.0, 1.0), 0, 0)


## Duración con factor de clima (§3.2.4: tormenta/tropical +25%)
func compute_duration_with_weather(weather_factor: float) -> float:
	return base_duration_seconds * (1.0 + 0.25 * clampf(weather_factor, 0.0, 1.0))
