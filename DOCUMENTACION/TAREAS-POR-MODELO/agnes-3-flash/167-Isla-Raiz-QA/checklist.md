**Modelo:** agnes-3-flash (Agnes 3.0 Flash, Sapiens AI)
**Plataforma:** Kilo Code

**Módulo (QA-asistencia, sin reclamar):** 167-Isla-Raiz (167)

# Nota personal — QA visual V2-asistencia M167 (visión nativa)

> **2026-09-16.** No reclamo M167 (✅ 114/114); es la **verificación visual [V4]** que la fila global deja
> delegable. Aprobación estética final = usuario (M154); no genero arte (V5).

## Por qué elegí V4 (y no V3/M46)
M46 depende de **M45 (assets 3D)** → mi parte sería "confirmar que no hay assets" (poco valor). M167 está
completo y solo falta **la verificación visual del terreno** = mi perfil exacto (V2-asistencia + auditoría
data-driven vs spec).

## Lo que vi (visión) en las 3 capturas (`capturas/167-Isla-Raiz/`)
- **`overview` / `costa` / `smoke_regresion`:** terreno isla voxel **completo y correcto**, **perfil en
  capas** (montaña→plato→costa), paleta Maldivas (verde-arena-azul mar), player (cápsula) sobre césped, HUD
  (M30/hotbar/barras), **FPS 60** en las 3. **Sin artefactos visuales** (z-fight, pop-in de chunks, baches).
- **Evidencia concreta:** la **costa** muestra la **banda de espuma blanca (shore-fade) ANCHA sobre la arena**
  → respalda el KnownIssue "shore-fade cubre demasiada arena" (calibración `water_config.tres`, M49/M51;
  aprobación final = usuario).
- **Nota ajena:** el `SCRIPT ERROR … stress_runner.gd:64` que se ve en la consola de la captura es **M113** y
  es **caché stale del editor** — el estado en disco es limpio (test M113 + comparador → 0 `SCRIPT ERROR`,
  exit 0). **No tocar código.**

## Estado
- [x] T-V4 QA visual M167 V2-asistencia — nota §QA visual agregada a `05-Checklist.md` M167.
