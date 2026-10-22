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
## Modo rápida (checklist C2): true (DEFAULT, comportamiento histórico) =
## acelerar hasta velocidad_max_efectiva (mejoras M incluidas); false =
## limitar a velocidad_crucero (navegación tranquila).
var rapida: bool = true

## M67 (G-5.3-Flash-Agente 2026-10-22): dimension vertical LOGICA del dirigible
## (items [S] "Altitud maxima 60 m" y "techo de altitud"). Solo activa cuando el
## preset declara altitud_max > 0 (barco/submarino no vuelan). El Node3D de la
## iter. 2 aplica este valor a la escena del vehiculo.
var altitud: float = 0.0
## Velocidad vertical cozy (m/s) de subida/bajada
const VELOCIDAD_VERTICAL: float = 2.0


func aplicar(delta: float, acelerar: bool, girar: int, frenar: bool, subir: bool = false, bajar: bool = false) -> void:
	if preset == null or delta <= 0.0:
		return
	# 1) Giro (riel: giro=0 → sin rotación libre, checklist F2; respeta mejoras)
	if girar != 0 and preset.giro_efectivo() > 0.0:
		rumbo += float(girar) * preset.giro_efectivo() * delta
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
		var techo := preset.velocidad_crucero if not rapida else preset.velocidad_max_efectiva()
		velocidad = minf(velocidad + ACELERACION * delta, techo)
	elif preset.tiene_reversa:
		velocidad = maxf(velocidad - ACELERACION * delta, -preset.velocidad_max_efectiva() * 0.4)
	else:
		velocidad = maxf(velocidad - ACELERACION * delta, 0.0)
	# Dimension vertical (solo presets que vuelan; techo del preset con
	# mejoras: dirigible 60 -> 90 con el nivel maximo). Retrocompatible:
	# las llamadas de 4 argumentos existentes no tocan la altitud.
	var techo_altitud: float = preset.altitud_max_efectiva()
	if techo_altitud > 0.0:
		if subir:
			altitud = minf(altitud + VELOCIDAD_VERTICAL * delta, techo_altitud)
		elif bajar:
			altitud = maxf(altitud - VELOCIDAD_VERTICAL * delta, 0.0)


## Velocidad de crucero: el controller no la fuerza sola (la usa el HUD/IA),
## pero se expone para el preset (checklist C2).
func velocidad_crucero() -> float:
	return preset.velocidad_crucero if preset != null else 0.0


## Avance en el plano XZ según velocidad y rumbo (para la iter. 2 Node3D).
func desplazamiento(delta: float) -> Vector3:
	return Vector3(sin(rumbo), 0.0, cos(rumbo)) * velocidad * delta
