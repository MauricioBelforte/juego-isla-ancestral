# Log 642: M49 Iluminación — iter. 1 (sol cálido, sombras, ambiente cozy) [VISIÓN]

**Fecha:** 2026-09-04
**Hora:** 06:15
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Primera iteración V2 (CON VISIÓN) de M49: reemplazada la iluminación plana de main_island.tscn por un setup cozy completo. **Verificado visualmente** con captura antes/después vía godot-mcp + screen capture. 6 ítems [x] → 6/117.

## Contexto: herencia de tareas
El usuario autorizó heredar TODAS las tareas de **deepseek-v4-flash-vision-exp** (ya no disponible). M49 Iluminación era su módulo V2 pendiente — tomado con mi vía de visión operativa (godot-mcp + screen capture).

## Verificación Visual (evidencia)

**ANTES:** terreno flat-lit sin sombras distinguibles, ambiente frío azulado, colores lavados.
**DESPUÉS:** caras de voxels con luz/sombra claramente separadas, cielo con gradación y sol suave, colores saturados cálidos, fog sutil en horizonte, **FPS 60 mantenido**.

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `scenes/main_island.tscn` | Environment: tonemap ACES (3) + white 6.0, ambient cálido (0.85, 0.78, 0.68) energy 0.85, glow sutil (0.4/0.05), fog (0.78, 0.84, 0.9) density 0.001 sky-affect 0.2, adjustment (1.02/1.06/1.12). DirectionalLight: color (1, 0.96, 0.88) energy 1.35, ángulo diagonal mañana, shadow_bias 0.08/normal 1.5, max_distance 120m. Sky: gradación mejorada + sun_angle_max 30 |

## Tests
- Boot: sin errores nuevos (solo warnings pre-existentes)
- FPS: 60 mantenido (la iluminación no cuesta frame budget)
- Captura visual: sombras/caras/cozy/fog verificados con mis "ojos" (screen capture)

## Archivos Modificados/Creados
- `game/isla-ancestral/scenes/main_island.tscn` *(modificado)*
- `DOCUMENTACION/49-Iluminacion/plan-actual/05-Checklist.md` *(6 ítems [x])*
- `CHECKLIST-GLOBAL.md` *(M49 iter. 1 — HERENCIA deepseek-vision)*
- `Logs/ULTIMO_NUMERO.txt` *(→ 642)*
- `Logs/reservas/642-...txt` *(creado y borrado)*

## Pendientes M49 (iter. 2+)
- Curvas de color por franja M31 (amanecer/atardecer/noche)
- Faroles físicos del pueblo (pool OmniLight3D, máx por escena)
- Presets de calidad por hardware (M90)
- Verificación visual en interiores M18/M25
