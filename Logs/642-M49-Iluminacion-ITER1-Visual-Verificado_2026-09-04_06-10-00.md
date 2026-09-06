# Log 642: M49 Iluminación — iter. 1 (sol cálido, sombras, ambiente cozy, fog)

**Fecha:** 2026-09-04
**Hora:** 06:10
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Primera iteración V2 (con visión) de M49 Iluminación: reemplazada la iluminación plana por un setup cozy completo en main_island.tscn. Verificado visualmente con captura antes/después (godot-mcp + screen capture).

## ANTES → DESPUÉS (verificación visual)

| Aspecto | Antes | Después |
|---|---|---|
| Sol | Neutro (1,1,1) energy 1.2 | Cálido (1, 0.96, 0.88) energy 1.35 |
| Sombras | enabled pero invisibles (flat) | Visibles: caras iluminadas vs sombreadas |
| Ambiente | Frío azul (0.6, 0.6, 0.7) 0.6 | Cálido cozy (0.85, 0.78, 0.68) 0.85 |
| Tonemap | linear (2) | ACES (3) + white 6.0 |
| Saturación | 1.0 (default) | 1.12 (colores ricos) |
| Fog | No | Sutil sky-affect 0.2, density 0.001 |
| Glow | No | Sutil 0.4/0.05 |
| FPS | 60 | 60 (sin costo) |

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `scenes/main_island.tscn` | DirectionalLight: color cálido, ángulo diagonal (manaña), shadow_bias ajustado, shadow_max_distance 120m, angular_distance 1.5. Environment: ACES, ambient cálido 0.85, glow sutil, fog sutil, adjustment (brillo/contraste/saturación cozy). Sky: gradación mejorada + sun_angle_max |

## Verificación Visual (captura godot-mcp)
- Caras de voxels con luz vs sombra claramente distinguibles ✓
- Horizonte con fog suave (profundidad) ✓
- Colores más saturados y cálidos (cozy) ✓
- Cielo con gradación y sol suave ✓
- FPS 60 sin costo de rendimiento ✓
- Boot sin errores nuevos ✓

## Archivos Modificados/Creados
- `game/isla-ancestral/scenes/main_island.tscn` *(Environment + DirectionalLight)*
- `Logs/ULTIMO_NUMERO.txt` *(→ 642)*
- `Logs/reservas/642-...txt` *(creado y borrado)*

## Pendientes M49 (iter. 2+)
- Presets por franja M31 (amanecer/atardecer/noche con colores distintos) — iter. 2 con curvas
- Faroles físicos en el pueblo (pool de OmniLight3D, máx 2 por vehículo/dueño)
- Verificación visual en interiores M18/M25
- Baked lightmaps (presupuesto M61)
