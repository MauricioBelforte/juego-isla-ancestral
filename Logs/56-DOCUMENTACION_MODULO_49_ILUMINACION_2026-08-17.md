# Log 56 — Documentación Módulo 49 (Iluminación)

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Contexto

Continuación de la fase de documentación de diseño (de a un módulo, según directiva del usuario: documentar → pushear → siguiente).

## Módulo documentado

| ID | Módulo | Ítems | Prioridad | Complejidad | Estado |
|---|---|---|---|---|---|
| 49 | Iluminación | 116 | Media | 3 | ✅ DELEGABLE |

**Total: 116 ítems** en 10 archivos (5 × plan-inicial + 5 × plan-actual).

## Nota sobre la numeración del plan maestro

El plan inicial numera la sección 48 como "ILUMINACIÓN"; la tabla global la mapea como ID 49 (desfase idéntico al de M45-M48). Documentado en el `01-Requerimientos.md`.

## Verificaciones realizadas

- plan-inicial == plan-actual byte a byte (SHA-256 idénticos, 5 pares OK).
- Checklist: 116 `[x]`, 0 `[ ]`, 0 `[?]`.
- Firmas `**Modelo:** Deepseek V4 Flash` / `**Plataforma:** OpenCode`.
- Notas del Agente en `04-Codigo.md`.

## Coordinación multiagente

- CHECKLIST-GLOBAL.md: fila 49 → 🟢 Disponible, progreso real 116/116. Resumen: 54 módulos con documentación completa, 77 🟢 / 72 ⬜ / 3 🔵 / 0 ✅.
- DOCUMENTACION/README.md: entrada en árbol y tabla de estado.
- ESTADO-PARALELO.md: historial de completados.

## Contenido destacado

- **LightingService** (autoload): consume franja de M31 y clima de M32; aplica presets con easing de 3 s (sin snaps); regla anti-oscuridad (ambiente ≥ 0.15).
- **Presets por las 5 franjas** (elevación, color, intensidad, niebla) con valores de referencia calibrables + niebla por los 13 biomas (M09).
- **Perfiles por escena:** interior casa (baked lightmap), templo (rayo cenital), subterráneo (esporas M11).
- **Pool de luces dinámicas:** ≤ 6 con sombra y ≤ 20 totales por escena, desactivación por distancia 30 m, flicker determinista (≤ 2 Hz, ≤ 15% para M58).
- **Baked lightmaps** para estáticos (casas M18, templos M24/M26, ruinas M25, cuevas); SDFGI/niebla volumétrica OFF por defecto.
- **Sombras:** ≤ 4 cascades, bias voxel sin acne, resolución por preset M90, sombras suaves sin siluetas negras.
- **Validador** `validate_lighting.gd` + `lighting_budget.json` y prueba en hardware objetivo (M90).

## Archivos creados

- `DOCUMENTACION/49-Iluminacion/plan-inicial/` (5 archivos)
- `DOCUMENTACION/49-Iluminacion/plan-actual/` (5 archivos)