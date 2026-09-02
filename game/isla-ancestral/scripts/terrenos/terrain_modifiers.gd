# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02 (iter. 1) / 2026-09-02 (iter. 2)
#
# M156: Terrenos — TerrainModifiers (estático, diseño §1.4).
# Cálculos de velocidad efectiva puros (sin estado): testable unitario.
# Iter. 2 (Log 554): suavizado de cambios de velocidad (cozy, sin tirones)
# + puente M155 con mapa de ids numéricos → nombres de terreno.
class_name TerrainModifiers
extends RefCounted

## Velocidad efectiva = base × terreno × (1 + equipo). Cap de equipo 50% (§3.1)
static func calculate_effective_speed(base_speed: float, terrain_modifier: float, equipment_bonus: float) -> float:
	var bonus := clampf(equipment_bonus, 0.0, 0.5)
	return base_speed * maxf(terrain_modifier, 0.1) * (1.0 + bonus)


## Modificador desde el provider (desconocido → 1.0, §10.2)
static func get_terrain_modifier(provider: Node, terrain_id: int) -> float:
	if provider != null and provider.has_method("get_speed_modifier"):
		return float(provider.get_speed_modifier(terrain_id))
	return 1.0


## Bonificación de equipación desde M155 (0.0 si no está, §3.1)
## M155.get_terrain_bonus espera terrain_type: String (nombre del terreno);
## el provider de M156 usa ids numéricos → mapeo id→nombre del §4.1.
const NOMBRES_TERRENO := {
	0: "caminado", 1: "barro", 2: "césped", 3: "arena",
	4: "agua", 5: "nieve", 6: "rocas",
}

static func get_equipment_bonus(equipment_system: Node, terrain_id: int) -> float:
	if equipment_system != null and equipment_system.has_method("get_terrain_bonus"):
		# Puente tipado: M155 es String; si el manager rechaza int, convertir
		var nombre: String = String(NOMBRES_TERRENO.get(terrain_id, "caminado"))
		var bonus := 0.0
		var r: Variant = equipment_system.get_terrain_bonus(nombre)
		bonus = float(r)
		return bonus
	return 0.0


## Integración end-to-end (iter. 1): provider + equipo → velocidad efectiva
static func calculate_full(base_speed: float, provider: Node, terrain_id: int, equipment_system: Node) -> float:
	return calculate_effective_speed(base_speed, get_terrain_modifier(provider, terrain_id), get_equipment_bonus(equipment_system, terrain_id))


## ── Iter. 2: suavizado de cambios de velocidad (diseño "suavizar") ──

## Rapidez del suavizado (unidades/seg; mayor = más rápido converge)
const SUAVIZADO_RAPIDEZ: float = 4.0
## Umbral por debajo del cual se pega al objetivo (evita flicker final)
const SUAVIZADO_UMBRAL: float = 0.01

## Suaviza el multiplicador de velocidad actual hacia el objetivo.
## Llamar cada frame del jugador con delta: transiciones cozy sin tirones.
## Ej.: entrando a barro 1.0 → 0.6 baja progresivamente (~0.25 s con rapidez 4).
static func suavizar_velocidad(actual: float, objetivo: float, delta: float, rapidez: float = SUAVIZADO_RAPIDEZ) -> float:
	if delta <= 0.0:
		return actual
	var d := objetivo - actual
	if absf(d) <= SUAVIZADO_UMBRAL:
		return objetivo
	# Exponencial estable independiente del framerate (exp_decay)
	return actual + d * (1.0 - exp(-rapidez * delta))


## Calcula la velocidad efectiva YA suavizada hacia el objetivo del terreno.
## Comodín para el integrador de M11 (loop de movimiento):
##   velocidad = TerrainModifiers.calcular_suavizado(vel, base, provider, id, eq, delta)
static func calcular_suavizado(velocidad_actual: float, base_speed: float, provider: Node, terrain_id: int, equipment_system: Node, delta: float) -> float:
	var objetivo := calculate_effective_speed(base_speed, get_terrain_modifier(provider, terrain_id), get_equipment_bonus(equipment_system, terrain_id))
	return suavizar_velocidad(velocidad_actual, objetivo, delta)
