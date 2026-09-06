# Log 647: M50 Vegetación — iter. 8 (feedback usuario: tamaños por tipo + árboles en spawn) [VISIÓN]

**Fecha:** 2026-09-04
**Hora:** 09:20
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Iter. 8 de M50 con feedback directo del usuario: (1) Blender re-escala palmera_joven a 4.5m y flor_isla a 0.8m (antes invisible), (2) cercanias_spawn ahora incluye arbol_frutal y palmera_joven para referencia de escala cerca del jugador.

## Feedback del usuario
- Palmeras grandes ✅ (5m bien)
- Palmera_joven ❌ muy pequeña → **4.5m en Blender**
- Flores ❌ no las vio (0.25m invisible) → **0.8m en Blender**
- Árboles ❌ no los vio (estaban en bosque, lejos del spawn) → **agregados a cercanias_spawn**

## Cambios

| Archivo | Cambio |
|---|---|
| 2 GLBs re-exportados (Blender 4.2 bpy) | palmera_joven 4.5m, flor_isla 0.8m |
| `data/escalas/escalas.json` | palmera_joven y flor_isla = 1.0 (horneadas) |
| `scripts/vegetacion/vegetation_plan.gd` | cercanias_spawn ahora usa mix directo con árboles (arbol_frutal + palmera_joven) |

## Pendiente
- Verificación visual del usuario (moverse cerca del spawn)
