class_name MathUtils
extends RefCounted

## Utilidades matemáticas reutilizables (M111 - Código de Calidad).
## Acceso global vía class_name; no requiere autoload.

static func distance_squared(a: Vector3, b: Vector3) -> float:
	return a.distance_squared_to(b)

static func lerp_value(a: float, b: float, t: float) -> float:
	return a + (b - a) * t

static func clamp_value(v: float, min_v: float, max_v: float) -> float:
	return clamp(v, min_v, max_v)

static func normalize_angle(a: float) -> float:
	# Normaliza a rango (-PI, PI].
	return fposmod(a + PI, TAU) - PI
