# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M67: Vehículos — VehicleController (lógica pura, diseño §2.2/§3.1).
# Física acotada por preset: aceleración hasta velocidad_max, giro por preset
# (0 = riel), frenado, reversa opcional. Sin nodos 3D: testeable headless.
# La integración con nodos reales (Node3D del vehículo) la hará el agente de
# la iter. 2 consumiendo `aplicar(delta, ...)` y leyendo velocidad/rumbo.
extends RefCounted

## Preset que gobierna los límites (no null)
var preset: VehiclePreset = null
## Velocidad actual (m/s, con signo: negativa = reversa)
var velocidad: float = 0.0
## Rumbo actual (radianes; 0 = norte)
var rumbo: float = 0.0
## Aceleración por tick hasta velocidad_max (m/s²) — cozy, sin arranques bruscos
const ACELERACION: float = 3.0


func aplicar(delta: float, acelerar: bool, girar: int, frenar: bool) -> void:
	if preset == null or delta <= 0.0:
		return
	# 1) Giro (riel: giro=0 → sin rotación libre, checklist F2)
	if girar != 0 and preset.giro > 0.0:
		rumbo += float(girar) * preset.giro * delta
		rumbo = wrapf(rumbo, 0.0, TAU)
	# 2) Frenado
	if frenar:
		var dv := preset.frenado * delta
		if absf(velocidad) <= dv:
			velocidad = 0.0
		else:
			velocidad -= signf(velocidad) * dv
		return
	# 3) Aceleración / crucero / reversa (§3.1: barco con reversa)
	if acelerar:
		velocidad = minf(velocidad + ACELERACION * delta, preset.velocidad_max)
	elif preset.tiene_reversa:
		velocidad = maxf(velocidad - ACELERACION * delta, -preset.velocidad_max * 0.4)
	else:
		velocidad = maxf(velocidad - ACELERACION * delta, 0.0)


## Velocidad de crucero: el controller no la fuerza sola (la usa el HUD/IA),
## pero se expone para el preset (checklist C2).
func velocidad_crucero() -> float:
	return preset.velocidad_crucero if preset != null else 0.0


## Avance en el plano XZ según velocidad y rumbo (para la iter. 2 Node3D).
func desplazamiento(delta: float) -> Vector3:
	return Vector3(sin(rumbo), 0.0, cos(rumbo)) * velocidad * delta
